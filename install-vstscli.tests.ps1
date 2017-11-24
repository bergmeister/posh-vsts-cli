Describe 'Install-VstsCli' {

    It "installs the vsts cli" {
       Install-VstsCli
       Get-Command vsts | Should Not Be $null
    }
}