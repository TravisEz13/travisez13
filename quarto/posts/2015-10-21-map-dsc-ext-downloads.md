---
toc: true
layout: post
description: How to map downloads of the extension dependencies to your own location.
categories: [DSC]
title: How to map downloads of the extension dependencies to your own location.
date: "October 21, 2015"
---

Originally Posted on [MSDN](https://blogs.msdn.microsoft.com/powershell/2015/10/21/azure-dsc-extension-2-8-how-to-map-downloads-of-the-extension-dependencies-to-your-own-location/).

**NOTE: For information on OS support, and other features, please refer to our** [release history](http://blogs.msdn.com/b/powershell/archive/2014/11/20/release-history-for-the-azure-dsc-extension.aspx).

# Overview
Today, we released version 2.8 of the Azure DSC Extension, we added support to map downloads of the extension dependencies to your own location.  This could be useful, if you want to configure the network, of a VM not to allow direct access to the Internet and host these files somewhere else.  This blog will show you how to use this feature in Azure Cloud Service Manager (ASM).  This assumes you already know how to use the DSC Extension as described in [How to use WMF 4 with Azure DSC Extension in Azure Resource Manager (ARM)](http://blogs.msdn.com/b/powershell/archive/2015/10/02/how-to-use-wmf-4-with-azure-dsc-extension-in-azure-resource-manager-arm.aspx) and [How to use WMF 4 with Azure DSC Extension in Azure Cloud Service Manager (ASM)](http://blogs.msdn.com/b/powershell/archive/2015/10/01/how-to-use-wmf-4-with-azure-dsc-extension-in-azure-cloud-service-manager-asm.aspx).  We are working to add this feature into the Azure PowerShell SDK DSC Extension Cmdlets directly.  Currently the Download Mapping feature is only available if you form the JSON yourself and send it to the extension using the generic extension Cmdlet (Set-AzureVMExtension.)

In this example I will show you:

1. How to update the function from the previous ASM example to add the download mappings JSON you need to send to the extension.
2. How to update the JSON from the previous ARM example to add the download mapping you need to send to the extension.

## Adding the Download Mappings JSON

In the `New-XAzureVmDscExtensionJson` from the previous [ASM blog](http://blogs.msdn.com/b/powershell/archive/2015/10/01/how-to-use-wmf-4-with-azure-dsc-extension-in-azure-cloud-service-manager-asm.aspx), add the download mapping parameter with the type of `HashTable`.  Additionally, we will update the `wmfVersion` parameter to not be required and set the default value to make the function easier to use.

```PowerShell
        [ValidateNotNullOrEmpty()]
        [ValidateSet('4.0','latest','5.0PP')]
        [string]
        $WmfVersion = 'latest',

        [AllowNull()]
        [hashtable]
        $DownloadMappings
```

Here is an explanation of the values for download mapping:

* The key of the hash table:
	* Should be the key for the download in the following format: `<PKG>_<PKGVersion>-<Platform>_<PlatformVersion>-<Arch>`
		* `PKG`
			* `WMF` - for WMF Packages
			* `NET` - for .NET packages
		* `PKGVerion`
			* The Version of the Package. Currently WMF has two valid versions, `4.0` or `5.0PP` (`latest` translates to `5.0PP`.)  .NET only has one valid version currently, `4.5`.
		* `Platform`
			* Reserved for future use, currently always `Windows'
		* `PlatformVersion'
			* Windows Server 2008 R2 - `6.1`
			* Windows Server 2012 - `6.2`
			* Windows Server 2012 R2 - `6.3`
			* Windows Server 2016 Technical Preview - `10.0`
		* `Arch`
			* AMD64/x64 - `x64`
			* x86 - `x86`
	* Example to map the download of WMF 4.0 for Windows Server 2008 R2 X64 to your own URL the key would be:
		*  `WMF_4.0-Windows_6.1-x64`
* The value of the table must be a HTTPS URL to download the package without credential (query strings are allowed.)

This function should produce a JSON that looks something like this.

```json
	"Properties":  {
                       "DestinationPath":  "C:\\test"
                   },
    "advancedOptions":  {
    	"DownloadMappings":  {
         	"WMF_4.0-Windows_6.1-x64":  "https://mystorage.blob.core.windows.net/mypubliccontainer/Windows6.1-KB2819745-x64-MultiPkg.msu"
         }
    },
    "WmfVersion":  "latest",
    "ConfigurationFunction":  "configuration.ps1\\ConfigurationName",
    "ModulesUrl":  "https://storageaccountname.blob.core.windows.net/windows-powershell-dsc/configuration.ps1.zip?<sastoken>"
}
```

## Putting it all together and Sending it to a VM
We put it all together the same as last time, just passing the HashTable with download key and the URL to map the download to.  The following is an example of how to do that.

```PowerShell
$storageAccountName = 'storageaccountname'
$publisher          = 'Microsoft.Powershell'
$dscVersion         = '2.8'
$serviceName        = 'servicename'
$vmName             = 'vmName'
$moduleName         = 'configuration.ps1'
$blobName           = "$moduleName.zip"
$configurationPath  = "$PSScriptRoot\$moduleName"
$ConfigurationName  = 'ConfigurationName'

$modulesUrl = Get-XAzureDscPublishedModulesUrl -blobName $blobName -configurationPath $configurationPath `
   -storageAccountName $storageAccountName
Write-Verbose -Message "ModulesUrl: $modulesUrl" -Verbose

$PublicConfigurationJson = New-XAzureVmDscExtensionJson -moduleName $moduleName -modulesUrl $modulesUrl `
    -properties @{DestinationPath = 'C:\test'} -configurationName $ConfigurationName -DownloadMappings @{'WMF_4.0-Windows_6.1-x64' = 'https://mystorage.blob.core.windows.net/mypubliccontainer/Windows6.1-KB2819745-x64-MultiPkg.msu'}
Write-Verbose -Message "PublicConfigurationJson: $PublicConfigurationJson" -Verbose

$vm = get-azurevm -ServiceName $serviceName -Name $vmName
$vm = Set-AzureVMExtension `
        -VM $vm `
        -Publisher $publisher `
        -ExtensionName 'DSC' `
        -Version $dscVersion `
        -PublicConfiguration $PublicConfigurationJson `
        -ForceUpdate

$vm | Update-AzureVM
```

After the VM is finished update, you should have a VM that used the URL you specified to download the WMF needed to install the extension.  I'll have a follow-up blog on how to do this in ARM.

I have published these samples to [GitHub](https://github.com/PowerShell/PowerShell-Blog-Samples/tree/master/2015-10-20-DSC-Extension-v2.8/ASM) as a working script.  Just update the, Service Name, etc. and run the script in the Azure PowerShell SDK.


## Adding the download mappings to the ARM JSON

In the previous [ARM blog](http://blogs.msdn.com/b/powershell/archive/2015/10/02/how-to-use-wmf-4-with-azure-dsc-extension-in-azure-resource-manager-arm.aspx), I described how to use visual studio to create an ARM Template to select which WMF the extension used.  I will start with the JSON that we ended with in that blog.

```json
{
    "name": "Microsoft.Powershell.DSC",
    "type": "extensions",
    "location": "[variables('location')]",
    "apiVersion": "2015-05-01-preview",
    "dependsOn": [
        "[concat('Microsoft.Compute/virtualMachines/', variables('vmName'))]"
    ],
    "tags": {
        "displayName": "Microsoft.Powershell.DSC"
    },
    "properties": {
        "publisher": "Microsoft.Powershell",
        "type": "DSC",
        "typeHandlerVersion": "2.1",
        "autoUpgradeMinorVersion": true,
        "settings": {
            "modulesUrl": "[concat(parameters('_artifactsLocation'), '/', 'dsc.zip')]",
            "sasToken": "[parameters('_artifactsLocationSasToken')]",
            "configurationFunction": "[variables('Microsoft.Powershell.DSCConfigurationFunction')]",
            "wmfVersion": "4.0",
            "properties": {
                "nodeName": "[variables('vmName')]"
            }
        },
        "protectedSettings": { }
    }
}
```

To that we will add the following JSON after `modulesUrl`.

```json
    "advancedOptions":  {
    	"DownloadMappings":  {
         	"WMF_4.0-Windows_6.1-x64":  "https://mystorage.blob.core.windows.net/mypubliccontainer/Windows6.1-KB2819745-x64-MultiPkg.msu"
         }
    },
```

This will result in the following JSON.

```json
{
    "name": "Microsoft.Powershell.DSC",
    "type": "extensions",
    "location": "[variables('location')]",
    "apiVersion": "2015-05-01-preview",
    "dependsOn": [
        "[concat('Microsoft.Compute/virtualMachines/', variables('vmName'))]"
    ],
    "tags": {
        "displayName": "Microsoft.Powershell.DSC"
    },
    "properties": {
        "publisher": "Microsoft.Powershell",
        "type": "DSC",
        "typeHandlerVersion": "2.1",
        "autoUpgradeMinorVersion": true,
        "settings": {
            "modulesUrl": "[concat(parameters('_artifactsLocation'), '/', 'dsc.zip')]",
			"advancedOptions":  {
    			"DownloadMappings":  {
         			"WMF_4.0-Windows_6.1-x64":  "https://mystorage.blob.core.windows.net/mypubliccontainer/Windows6.1-KB2819745-x64-MultiPkg.msu"
         		}
    		},
            "sasToken": "[parameters('_artifactsLocationSasToken')]",
            "configurationFunction": "[variables('Microsoft.Powershell.DSCConfigurationFunction')]",
            "wmfVersion": "4.0",
            "properties": {
                "nodeName": "[variables('vmName')]"
            }
        },
        "protectedSettings": { }
    }
}
```

To deploy, follow the instruction in the previous blog.  I've put the updated solution I built on [GitHub](https://github.com/PowerShell/PowerShell-Blog-Samples/tree/master/2015-10-20-DSC-Extension-v2.8/ARM).

## Feedback
Please feel free to reach to us posting comments to this post, or by posting feedback on [Connect](https://connect.microsoft.com/PowerShell/Feedback).
