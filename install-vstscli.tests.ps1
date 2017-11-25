Describe 'Install-VstsCli' {

    Import-Module (Join-Path $PSScriptRoot "posh-vsts-cli.psd1") 

    It "installs the vsts cli" {
       Install-VstsCli
       Get-Command vsts | Should Not Be $null
    }
}