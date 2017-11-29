
<#
.SYNOPSIS
Installs the VSTS CLI. Requires PowerShell to be launched as Administrator.
.EXAMPLE
Install-VstsCli
#>
Function Install-VstsCli
{
    [CmdletBinding()]
    param()
    
    Import-Module BitsTransfer # in case the machine is locked down, one can use Invoke-WebRequest instead as well but BitsTransfer is much faster
    Write-Verbose "Downloading installer" -Verbose
    Start-BitsTransfer -Source https://aka.ms/vsts-cli-windows-installer -Destination vsts-cli_installer.msi
    Write-Verbose "Installing VSTS-CLI" -Verbose
    $result = Start-Process msiexec.exe -Wait -ArgumentList "/I $((Get-ChildItem .\vsts-cli_installer.msi).FullName) /quiet" -PassThru -Verb runas
    Write-Verbose "Installer Exit Code: $($result.ExitCode)"
    # refresh path in powershell https://gist.github.com/bill-long/230830312b70742321e0
    foreach($level in "Machine","User") {
      [Environment]::GetEnvironmentVariables($level).GetEnumerator() | ForEach-Object {
          # For Path variables, append the new values, if they're not already in there
          if($_.Name -match 'Path$') { 
            $_.Value = ($((Get-Content "Env:$($_.Name)") + ";$($_.Value)") -split ';' | Select-Object -unique) -join ';'
          }
          $_
      } | Set-Content -Path { "Env:$($_.Name)" }
    }
    Remove-Item .\vsts-cli_installer.msi
    vsts --version
}

<#
.SYNOPSIS
Invokes the VSTS CLI and converts the output to a PowerShell object.
.EXAMPLE
ivc build list
.EXAMPLE
ivc build list --output table
#>
Function Invoke-VstsCli
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "")]
    param()

    $arguments = $args -join " "
    & Invoke-Expression "vsts $($arguments)" | ConvertFrom-VstsCli
}

<#
.SYNOPSIS
Converts the JSON or table output of the vsts-cli output to PowerShell objects
.EXAMPLE
vsts build list | ConvertFrom-VstsCli
.EXAMPLE
vsts build list --output table | ConvertFrom-VstsCli
#>
function ConvertFrom-VstsCli
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [string]$InputObject
    )

        
    begin
    {
        $positions = $null;
        $scippedSecondLine = $false;
    }

    process
    {
        if ($null -eq $isTableFormat)
        {
            $isTableFormat = $InputObject.startswith("[")
        }

        if (-not $isTableFormat)
        {
            foreach ($oneInputObject in $InputObject)
            {
                if ($null -eq $positions)
                {
                    $positions = GetColumnInfo -HeaderRow $oneInputObject
                }
                else
                {
                    if ($scippedSecondLine)
                    {
                        ParseRow -row $oneInputObject -ColumnInfo $positions
                    }
                    else
                    {
                        $scippedSecondLine = $true # the second line consists only of dashes
                    }
                }
            }
        }
        else
        {
            # the JSON string comes in one character at a time in the pipeline
            if ($null -eq $stringBuilder)
            {
                $stringBuilder = [System.Text.StringBuilder]::new()
            }
            foreach($oneInputObject in $InputObject)
            {
                [void]$stringBuilder.AppendLine($oneInputObject)
            }
        }
    }
    
    end
    {
        if ($null -ne $stringBuilder)
        {
            $stringBuilder.ToString() | ConvertFrom-Json
        }
        $isTableFormat = $null     
    }
}

#region Table output parsing
function PascalName($name)
{
    $name =  $name.Trim(' ') # get rid of leading whitespace
    $parts = $name.Split(" ")
    for ($i = 0 ; $i -lt $parts.Length ; $i++)
    {
        $parts[$i] = [char]::ToUpper($parts[$i][0]) + $parts[$i].SubString(1).ToLower();
    }
    $parts -join ""
}
function GetHeaderBreak($headerRow, $startPoint = 0)
{
    $i = $startPoint
    while ( $i + 1 -lt $headerRow.Length)
    {
        if ($headerRow[$i] -eq ' ' -and $headerRow[$i + 1] -eq ' ')
        {
            return $i
            break
        }
        $i += 1
    }
    return -1
}
function GetHeaderNonBreak($headerRow, $startPoint = 0)
{
    $i = $startPoint
    while ( $i + 1 -lt $headerRow.Length)
    {
        if ($headerRow[$i] -ne ' ')
        {
            return $i
            break
        }
        $i += 1
    }
    return -1
}
function GetColumnInfo($headerRow)
{
    $lastIndex = 2 # the first 2 characters are just whitespace
    $i = 4 # id starts at 2
    while ($i -lt $headerRow.Length)
    {
        $i = GetHeaderBreak $headerRow $lastIndex
        if ($i -lt 0)
        {
            $name = $headerRow.Substring($lastIndex)
            New-Object PSObject -Property @{ HeaderName = $name; Name = PascalName $name; Start = $lastIndex; End = -1}
            break
        }
        else
        {
            $name = $headerRow.Substring($lastIndex, $i - $lastIndex)
            $temp = $lastIndex
            $lastIndex = GetHeaderNonBreak $headerRow $i
            if ($temp -eq 2) # the first ID columns is right aligned -> move position to the very left
            {
                $temp = 0
            }
            if ($lastIndex -lt 0)
            {
                $lastIndex = $headerRow.Length - 1 # last columns sometimes 'overflows'
            }
            New-Object PSObject -Property @{ HeaderName = $name; Name = PascalName $name; Start = $temp; End = $lastIndex}
        }
    }
}
function ParseRow($row, $columnInfo)
{
    $values = @{}
    $columnInfo | ForEach-Object {
        if ($_.End -lt 0)
        {
            $len = $row.Length - $_.Start
        }
        else
        {
            $len = $_.End - $_.Start
        }
        $values[$_.Name] = $row.SubString($_.Start, $len).Trim()
    }
    New-Object PSObject -Property $values
}
#endregion
