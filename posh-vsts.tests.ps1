Describe 'posh-vsts-cli' {
    
    Context 'Module' {

        It "Imports OK and exports the correct functions" {
            $poshvstscli_moduleName = 'posh-vsts-cli'
            Import-Module (Join-Path $PSScriptRoot "$poshvstscli_moduleName.psd1")
            Get-Module $poshvstscli_moduleName | Should Not Be Null
            $exportedFunctions = Get-Command -Module $poshvstscli_moduleName
            $exportedFunctions.Length | Should Be 2
            $exportedFunctions | Where-Object Name -eq ConvertFrom-VstsCli | Should Not Be Null
            $exportedFunctions | Where-Object Name -eq Invoke-VstsCli | Should Not Be Null
        }
    }
}