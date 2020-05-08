---
toc: true
layout: post
description: Decrypting the current MOF on WMF5
categories: [DSC]
title: Decrypting the current MOF on WMF5
---

At the PowerShell Summit in Bellevue, I presented about how DSC now automatically encrypts the `current.mof`, in order to address some customer concerns about the existing encryption.  After this talk, I was asked some questions about how to decrypt this new encryption.  When I got back to work, I added a simple function, `Unprotect-xDscConfiguration` to the [xDscDiagnostics](https://github.com/PowerShell/xDscDiagnostics) module on GitHub.  It takes a parameter for the name of the stage that you would like to decrypt (see the documention for the stage parameter of [Remove-DSCConfigurationDocument](http://bit.ly/1NkJm9X)).  The function will currently only work locally (feel free to submit an issue or a PR) and **must be run as administrator** to be able to decrypt the MOF.  Example usage and output are below as well.

## Installation
At the time of the writing, the release version (2.2.0.0) of xDscDiagnostics dose not have this change, but there are instruction on how to install the development version [using PowerShell Get on GitHub](https://github.com/PowerShell/DscResources#development-builds).

## Example Usage

```powershell
Unprotect-xDscConfigurtion -Stage Previous
```

## Example output

```mof
/*
@TargetNode='localhost'
@GeneratedBy=tplunk
@GenerationDate=04/07/2016 16:54:16
@GenerationHost=localhost
*/

instance of MSFT_LogResource as $MSFT_LogResource1ref
{
SourceInfo = "::1::24::log";
 ModuleName = "PsDesiredStateConfiguration";
 ResourceID = "[Log]example";
 Message = "example";

ModuleVersion = "1.0";
 ConfigurationName = "example";
};
instance of OMI_ConfigurationDocument

                    {
 Version="2.0.0";

                        MinimumCompatibleVersion = "1.0.0";

                        CompatibleVersionAdditionalProperties= {"Omi_BaseResource:ConfigurationName"};

                        Author="tplunk";

                        GenerationDate="04/07/2016 16:54:16";

                        GenerationHost="localhost";

                        Name="example";

                    };
```