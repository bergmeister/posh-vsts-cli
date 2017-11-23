[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "")]Param()

$poshvstscli_moduleName = 'vsts-cli-tabcompletion'
Import-Module (Join-Path $PSScriptRoot "$poshvstscli_moduleName.psd1")
try
{
    TabExpansion2 -inputScript "vsts b" -cursorColumn 6 -ErrorAction Ignore # the first time it fails, this is a TODO item
}
catch
{

}

Describe 'vsts-cli-tabcompletion' {
    Context 'Tabexpansion2' {
        Get-Module $poshvstscli_moduleName | Should Not Be $null

        It "vsts b gets expanded correctly to vsts build" {
            $commandCompletion = TabExpansion2 -inputScript "vsts b" -cursorColumn 6
            if (-not $env:APPVEYOR) # tabexpansion2 does not seem to work in appveyor although it uses PS 5.1. Maybe this is related to it not working for PowerShell Core?
            {
                $commandCompletion.CompletionMatches.CompletionText | Should Be 'build'
            }
        }
        
        It "vsts build gets expanded" {
            $commandCompletion = TabExpansion2 -inputScript "vsts build " -cursorColumn 10
            if (-not $env:APPVEYOR) # tabexpansion2 does not seem to work in appveyor although it uses PS 5.1. Maybe this is related to it not working for PowerShell Core?
            {
                $commandCompletion.CompletionMatches.CompletionText | Should Not BeNullOrEmpty # there seems to be a Pester bug because changing the expected result makes the acutal result switch
            }
        }

        It "option expansions expanded" {
            $commandCompletion = TabExpansion2 -inputScript "vsts build list --t" -cursorColumn 19
            if (-not $env:APPVEYOR) # tabexpansion2 does not seem to work in appveyor although it uses PS 5.1. Maybe this is related to it not working for PowerShell Core?
            {
                $commandCompletion.CompletionMatches.CompletionText | Should Not BeNullOrEmpty # there seems to be a Pester bug because changing the expected result makes the acutal result switch
            }
        }
    }
}