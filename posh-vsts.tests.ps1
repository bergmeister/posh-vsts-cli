Describe 'posh-vsts-cli' {
    
    Context 'ConvertFrom-VstsCli' {

        It "Imports OK and exports the correct functions" {
            Import-Module (Join-Path $PSScriptRoot 'posh-vsts-cli.psd1')
            $exportedFunctions = Get-Command -Module posh-vsts-cli
            $exportedFunctions.Length | Should Be 1
        }
    }
}