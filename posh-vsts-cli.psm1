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