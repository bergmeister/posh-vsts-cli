# posh-vsts-cli [![Build status](https://ci.appveyor.com/api/projects/status/29qq8ghr1mhlkaeh?svg=true)](https://ci.appveyor.com/project/bergmeister/posh-vsts-cli) [![AppVeyor tests](http://flauschig.ch/batch.php?type=tests&account=bergmeister&slug=posh-vsts-cli)](https://ci.appveyor.com/project/bergmeister/posh-vsts-cli/build/tests) [![codecov](https://codecov.io/gh/bergmeister/posh-vsts-cli/branch/master/graph/badge.svg)](https://codecov.io/gh/bergmeister/posh-vsts-cli) [![PSScriptAnalyzer](https://img.shields.io/badge/Linter-PSScriptAnalyzer-blue.svg)](http://google.com) [![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

A `PowerShell` helper that enhances the [vsts-cli](https://github.com/Microsoft/vsts-cli):

- Wraps the CLI internally and converts the JSON or table output to a PowerShell object
- Tab completion (currently under development but it already working for group and subgroup commands, e.g. `vsts build queue`)

![Subgroup and command tab completion](demos/tabcompletion_demo.gif)
![Subgroup and command tab completion](demos/Convert-fromVstsCli.gif)

## Installation

Install it from the `PSGallery`

````powershell
Install-Module posh-vsts-cli
````

Alternatively you can also just clone/download this repo and import the `posh-vsts-cli.psd1` module.

## Usage

You can invoke the VSTS CLI directly via `Invoke-VstsCli` or its alias `iv` and the output gets converted to PowerShell objects.

````powershell
> $builds = iv build list --top 3 --output table
> $builds[2] # show the object properties of the third build
DefinitionName : My VSTS build
Id             : 199
Number         : 0.1.0+113
SourceBranch   : master
Reason         : individualCI
Result         : partiallySucceeded
Status         : completed
DefinitionId   : 3
QueuedTime     : 2017-10-01 22:41:02.456000
> $builds[2].Result # you can get at all those properties individually as well
partiallySucceeded
````

Under the hood the vsts cli gets called and then the output gets convertedd to a PowerShell object. It auto-detects if the output was in JSON or table format.

````powershell
> $builds = vsts build list --top 3 | ConvertFrom-VstsCli
````

The output conversion is currently only tested for the `build` commands of the VSTS CLI using `PowerShell 5.1` but should work with others as well.

## Tab Completion

Tab completion is experimental at the moment but already works for subgroups and commands (i.e. the first 2 words after the `vsts` or `iv` command). The first time you use it in a new shell, you need to press tab twice but after that just one tab completes the current command.

````powershell
>vsts <TAB><TAB>
>vsts build
>vsts build <TAB>
>vsts build list
>vsts build list <TAB>
>vsts build queue
````