[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "")]Param()
Describe 'vsts-cli-tabcompletion' {
    Context 'Tabexpansion2' {

        It "vsts b gets expanded correctly to vsts build" {
            

            $poshvstscli_moduleName = 'vsts-cli-tabcompletion'
            Import-Module (Join-Path $PSScriptRoot "$poshvstscli_moduleName.psd1")
            Get-Module $poshvstscli_moduleName | Should Not Be $null
            try
            {
                TabExpansion2 -inputScript "vsts b" -cursorColumn 6 -ErrorAction Ignore # the first time it fails, this is a TODO item
            }
            catch
            {

            }
            $commandCompletion = TabExpansion2 -inputScript "vsts b" -cursorColumn 6
            $commandCompletion.CompletionMatches.CompletionText | Should Be 'build'
        }
    }
}