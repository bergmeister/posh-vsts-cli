[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "")]Param()

$poshvstscli_moduleName = 'vsts-cli-tabcompletion'
Import-Module (Join-Path $PSScriptRoot "$poshvstscli_moduleName.psd1")
try {
    TabExpansion2 -inputScript "vsts b" -cursorColumn 6 -ErrorAction Ignore # the first time it fails, this is a TODO item
}
catch {

}

Describe 'vsts-cli-tabcompletion' {
    Context 'Tabexpansion2' {
        Get-Module $poshvstscli_moduleName | Should Not Be $null

        It "vsts b gets expanded correctly to vsts build" {
            $commandCompletion = TabExpansion2 -inputScript "vsts b" -cursorColumn 6
            $commandCompletion.CompletionMatches.CompletionText | Should Be 'build'
        }

        It "vsts help option gets expanded" {
            $commandCompletion = TabExpansion2 -inputScript "vsts --h" -cursorColumn 8
            $commandCompletion.CompletionMatches.CompletionText | Should be '--help'
        }

        It "option gets expanded" {		
            $commandCompletion = TabExpansion2 -inputScript "vsts build list --b" -cursorColumn 19		
            $commandCompletion.CompletionMatches.CompletionText[0] | Should be '--branch'
        }
    }
}