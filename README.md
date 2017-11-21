# posh-vsts-cli [![Build status](https://ci.appveyor.com/api/projects/status/29qq8ghr1mhlkaeh?svg=true)](https://ci.appveyor.com/project/bergmeister/posh-vsts-cli) [![AppVeyor tests](http://flauschig.ch/batch.php?type=tests&account=bergmeister&slug=posh-vsts-cli)](https://ci.appveyor.com/project/bergmeister/posh-vsts-cli/build/tests) [![codecov](https://codecov.io/gh/bergmeister/posh-vsts-cli/branch/master/graph/badge.svg)](https://codecov.io/gh/bergmeister/posh-vsts-cli) [![PSScriptAnalyzer](https://img.shields.io/badge/Linter-PSScriptAnalyzer-blue.svg)](http://google.com) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A `PowerShell` helper of the [vsts-cli](https://github.com/Microsoft/vsts-cli).
It can convert the output in JSON

## Usage

First clone the repo or download it, e.g. `git clone https://github.com/bergmeister/posh-vsts-cli.git`

Then import the module

```powershell
Import-Module .\vsts-cli.psd1 
```

You can invoke the VSTS CLI directly via `Invoke-VstsCli` or its alias `ivc`:

````powershell
ivc build list --top 3
````

You can convert the output from the vsts cli to a PowerShell object

````powershell
> $builds = ivc build list --top 3 --output table | ConvertFrom-VstsCli -FromTable # you could also use the vsts cli directly
> $builds[2] # show the object properties of the third build
DefinitionName : Pokemon Scanner-CI
Id             : 199
Number         : 0.1.0+113
SourceBranch   : master
Reason         : individualCI
Result         : partiallySucceeded
Status         : completed
DefinitionId   : 3
QueuedTime     : 2017-10-01 22:41:02.456000
> $builds[2].Result # you can get at all those properties
partiallySucceeded
````

It has been tested with the `build` commands of the VSTS CLI using `PowerShell 5.1` but should work with others as well.