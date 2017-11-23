[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")] # needed to override tab completion
Param()

$global:VstsCompletion = @{}

$script:flagRegex = "^  (-[^, =]+),? ?(--[^= ]+)?"

function script:Get-Build
{
    vsts build list | ConvertFrom-VstsCli
}

function script:Get-AutoCompleteResult
{
    param([Parameter(ValueFromPipeline = $true)] $value)
    
    Process
    {
        New-Object System.Management.Automation.CompletionResult $value
    }
}

filter script:MatchingCommand($commandName)
{
    if ($_.StartsWith($commandName))
    {
        $_
    }
}

$completion_Vsts = {
    param($commandName, $commandAst, $cursorPosition)

    $command = $null
    $commandParameters = @{}
    $state = "Unknown"
    $wordToComplete = $commandAst.CommandElements | Where-Object { $_.ToString() -eq $commandName } | Foreach-Object { $commandAst.CommandElements.IndexOf($_) }

    for ($i = 1; $i -lt $commandAst.CommandElements.Count; $i++)
    {
        $p = $commandAst.CommandElements[$i].ToString()

        if ($p.StartsWith("--"))
        {
            if ($commandAst.CommandElements.Count -eq 2 -or $commandAst.CommandElements.Count -eq 3)
            {
                @('--help') | Get-AutoCompleteResult
            }
            elseif($commandAst.CommandElements.Count -eq 4)
            {
                @('--help') | Get-AutoCompleteResult # TODO: parse other options
            }

            if ($state -eq "Unknown" -or $state -eq "Options")
            {
                $commandParameters[$i] = "Option"
                $state = "Options"
            }
            else
            {
                $commandParameters[$i] = "CommandOption"
                $state = "CommandOptions"
            }
        } 
        else 
        {
            if ($state -ne "CommandOptions")
            {
                $commandParameters[$i] = "Command"
                $command = $p
                $state = "CommandOptions"
            } 
            else 
            {
                $commandParameters[$i] = "CommandOther"
            }
        }
    }

    if ($global:VstsCompletion.Count -eq 0)
    {
        $global:VstsCompletion["commands"] = @{}
        $global:VstsCompletion["options"] = @()
        
        vsts --help | ForEach-Object {
            Write-Output $_
            if ($_ -match "^\s{4,5}(\w+)\s+(.+)") # 4 spaces in help before commands
            {
                $global:VstsCompletion["commands"][$Matches[1]] = @{}
                
                $currentCommand = $global:VstsCompletion["commands"][$Matches[1]]
                $currentCommand["options"] = @()
            }
            elseif ($_ -match $flagRegex)
            {
                $global:VstsCompletion["options"] += $Matches[1]
                if ($Matches[2] -ne $null)
                {
                    $global:VstsCompletion["options"] += $Matches[2]
                }
            }
        }

    }
    
    if ($wordToComplete -eq $null)
    {
        $commandToComplete = "Command"
        if ($commandParameters.Count -gt 0)
        {
            if ($commandParameters[$commandParameters.Count] -eq "Command")
            {
                $commandToComplete = "CommandOther"
            }
        } 
    }
    else
    {
        $commandToComplete = $commandParameters[$wordToComplete]
    }

    switch ($commandToComplete)
    {
        "Command" { $global:VstsCompletion["commands"].Keys | MatchingCommand -Command $commandName | Sort-Object | Get-AutoCompleteResult }
        "Option" { $global:VstsCompletion["options"] | MatchingCommand -Command $commandName | Sort-Object | Get-AutoCompleteResult }
        "CommandOption"
        { 
            $options = $global:VstsCompletion["commands"][$command]["options"]
            if ($options.Count -eq 0)
            {
                vsts $command --help | ForEach-Object {
                    if ($_ -match $flagRegex)
                    {
                        $options += $Matches[1]
                        if ($Matches[2] -ne $null)
                        {
                            $options += $Matches[2]
                        }
                    }
                }
            }

            $global:VstsCompletion["commands"][$command]["options"] = $options
            $options | MatchingCommand -Command $commandName | Sort-Object | Get-AutoCompleteResult
        }
        "CommandOther"
        {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")] 
            $filter = $null
            switch ($command)
            {
                "build" { @('list', 'queue', 'show')  | Get-AutoCompleteResult }
                "code" { @('pr', 'repo')             | Get-AutoCompleteResult }
                "project" { @('create', 'list', 'show') | Get-AutoCompleteResult }
                "work" { @('item')                   | Get-AutoCompleteResult }
            }
            
        }
        default { $global:VstsCompletion["commands"].Keys | MatchingCommand -Command $commandName }
    }
}

# Register the TabExpension2 function
if (-not $global:options) { $global:options = @{CustomArgumentCompleters = @{}; NativeArgumentCompleters = @{}}
}
$global:options['NativeArgumentCompleters']['vsts'] = $Completion_Vsts
$global:options['NativeArgumentCompleters']['iv'] = $Completion_Vsts
$global:options['NativeArgumentCompleters']['Invoke-VstsCli'] = $Completion_Vsts

$function:tabexpansion2 = $function:tabexpansion2 -replace 'End\r\n{', 'End { if ($null -ne $options) { $options += $global:options} else {$options = $global:options}'
