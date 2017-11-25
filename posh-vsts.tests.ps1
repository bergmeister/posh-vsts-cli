Describe 'posh-vsts-cli' {

    Import-Module (Join-Path $PSScriptRoot "posh-vsts-cli.psd1") 

    Context 'Pre-Requisites' {
        It "VSTS is installed" {
            Get-Command vsts | Should Not Be $null
        }
    }
    
    Context 'Module' {

        It "Imports OK and exports the correct functions and alias" {
            $poshvstscli_moduleName = 'posh-vsts-cli'
            Get-Module $poshvstscli_moduleName | Should Not Be $null
            $exportedFunctions = Get-Command -Module $poshvstscli_moduleName
            $exportedFunctions.Length | Should Be 3
            $exportedFunctions | Where-Object Name -eq ConvertFrom-VstsCli | Should Not Be $null
            $exportedFunctions | Where-Object Name -eq Invoke-VstsCli | Should Not Be $null
            $exportedFunctions | Where-Object Name -eq Install-VstsCli | Should Not Be $null
            Get-Alias iv | Should Not Be $null
        }
    }

    Context 'Convert-FromVstsCli' {
        It 'converts table output from build list' {
            $output = @("  ID  Number     Status     Result                Definition ID  Definition Name      Source Branch    Queued Time                 Reason",
                        "----  ---------  ---------  ------------------  ---------------  -------------------  ---------------  --------------------------  ------------",
                        " 201  0.1.0+113  completed  partiallySucceeded                3  My Fancy Project-CI  master           2017-11-20 23:29:23.266209  manual",
                        " 200  0.1.0+113  completed  succeeded                         3  My Fancy Project-CI  master           2017-10-02 22:37:08.197612  manual",
                        "  99  0.1.0+113  completed  failed                            3  My Fancy Project-CI  master           2017-10-01 22:41:02.456000  individualCI"
            )
            
            $outputAsObject = $output | ConvertFrom-VstsCli
            $outputAsObject | Should Not BeNullOrEmpty 
            $outputAsObject.Length | Should Be 3
            $outputAsObject[0].Id | Should Be 201
            $outputAsObject[2].Id | Should Be 99
            $outputAsObject[0].Number | Should Be '0.1.0+113'
            $outputAsObject[0].Status | Should Be 'completed'
            $outputAsObject[0].Result | Should Be 'partiallySucceeded'
            $outputAsObject[1].Result | Should Be 'succeeded'
            $outputAsObject[2].Result | Should Be 'failed'
            $outputAsObject[0].DefinitionID | Should Be 3
            $outputAsObject[0].DefinitionName | Should Be 'My Fancy Project-CI'
            $outputAsObject[0].SourceBranch | Should Be 'master'
            $outputAsObject[0].QueuedTime | Should Be '2017-11-20 23:29:23.266209'
            $outputAsObject[0].Reason | Should Be 'manual'
            $outputAsObject[2].Reason | Should Be 'individualCI'
        }
    }

    Context 'PSScriptAnalyzer' {
        It 'There are no PScriptAnalyzer warnings' {
            $results = Invoke-ScriptAnalyzer . -Recurse
            $results | Should Be $null
        }
    }
}