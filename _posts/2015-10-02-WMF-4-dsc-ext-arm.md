---
toc: true
layout: post
description: How to use WMF 4 with Azure DSC Extension in Azure Resource Manager (ARM)
categories: [DSC]
title: How to use WMF 4 with Azure DSC Extension in Azure Resource Manager (ARM)
---
Originally posted on [MSDN](https://blogs.msdn.microsoft.com/powershell/2015/10/02/how-to-use-wmf-4-with-azure-dsc-extension-in-azure-resource-manager-arm/).

## Overview

In version 2.7 of the Azure DSC Extension, we added support to leave your Virtual Machine on the latest supported version of WMF 4.0.  This blog will show you how to use this feature in Azure Resource Manager (ARM) templates.  For this, I will use the Azure Resource Manger Tools, that were released with Azure SDK 2.6 for .NET.  I will assume you already have Visual Studio 2015 setup.  I also assume you have read ['How to use WMF 4 with Azure DSC Extension in Azure Cloud Service Manager (ASM)'](http://blogs.msdn.com/b/powershell/archive/2015/10/01/how-to-use-wmf-4-with-azure-dsc-extension-in-azure-cloud-service-manager-asm.aspx), as it describes the meaning of some of the terms.   The MSDN topic ['Creating and Deploying Azure Resource Group Deployment Projects'](https://msdn.microsoft.com/en-us/library/azure/dn872471.aspx) has a general walk-though of using the tools I will use in this blog.  I would suggest you read though and refer back to this page if you loose you way while

In this Example I will show you:

1. How to setup the SDK for .NET, which will add the tools to Visual Studio 2015 to design and deploy an ARM Template.
2. How to create an ARM project in Visual Studio
3. How to add DSC to the ARM template
3. How to send this JSON to the extension on an existing VM.

## Setup Azure SDK for .NET

If you haven't already, download and install the latest Azure SDK for .NET.  At the time I wrote this, the current download link for the Azure SDK for .NET was [here](http://go.microsoft.com/fwlink/?linkid=518003&clcid=0x409).  The current links to download the SDK can be found [here](https://azure.microsoft.com/en-us/downloads/).

## Create a ARM Project

See the MSDN topic ['Creating and Deploying Azure Resource Group Deployment Projects'](https://msdn.microsoft.com/en-us/library/azure/dn872471.aspx) on how to 'Create Azure Resource Group projects'.

## Add Powershell DSC Extension

Once you have created you project, you need to add the 'Powershell DSC Extension' to the ARM Template.

1. In **Solution Explorer**, expand **templates**
2. Click **WindowsVirtualMachine.json**
3. Open the **JSON Outline** (this is usually on the left hand pane)
4. In the **JSON Outline**, expand **resources**
5. In the **JSON Outline**, right click **Virtual Machine**
6. In the context menu, click **Add New Resource**
7. In the **Add Resource Window**, click **Powershell DSC Extension**
8. In the **Add Resource Window**, in the **Name** field, type `Microsoft.Powershell.DSC` (Note, this is important for the SDK to work properly.)
9.  In the **Add Resource Window**, click Add

This should add a section of JSON which looks like this:

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
            "properties": {
                "nodeName": "[variables('vmName')]"
            }
        },
        "protectedSettings": { }
    }
}
```

## Using the new WMF Version feature

### Updating the Extension version

You must make sure you use at least the 2.7 version of the extension.  In the DSC Extension JSON update `"typeHandlerVersion": "2.1"` to `"typeHandlerVersion": "2.7"`.  This will update the DSC Extension version ARM installs from 2.1 to 2.7.

### Adding the property to configure the WMF Version

You must tell the DSC Extension what version of the WMF you want to use.  If you don't it will use the latest.  In the settings section add a wmfVersion property with the value 4.0.  Here is an example `"wmfVersion": "[parameters('wmfVersion')]"`.

After this the JSON should look like this:

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

## Deploying your configuration

The solution should include a `Microsoft.Powershell.DSCConfiguration.ps1` which it will deploy using the DSC Extension.

See the MSDN topic ['Creating and Deploying Azure Resource Group Deployment Projects'](https://msdn.microsoft.com/en-us/library/azure/dn872471.aspx) on 'Deploying an Azure Resource Group project to an Azure resource group'.

For a more detailed description of how to deploy see the blog ["Deploying a Website with Content through Visual Studio with Resource Groups"](http://blogs.technet.com/b/georgewallace/archive/2015/05/10/deploying-a-website-with-content-through-visual-studio-with-resource-groups.aspx)

## Summary

This should be enough to let you choose which version of WMF you want to use with ARM.  I've put the solution I built on [GitHub](https://github.com/PowerShell/PowerShell-Blog-Samples/tree/master/2019-09-30-DSC-Extension-v2.7/ARM) and turned the WmfVersion into a parameter on the template.  This will let you choose what version you want at deployment time.  I also modified the default DSC configuration to report the WMF major Version so it's easy to verify it is working without logging into the machine.

## Notes

Windows Server 2016 Technical Preview has the equivalent of WMF 5 already installed.  Therefore, specifying WMF 4 for this OS is not a valid option.

## References

If you want to dive in further on ARM concepts, Greg Oliver has written the blog ["Developing DSC scripts for the Azure Resource Manager DSC Extension".](http://blogs.msdn.com/b/golive/archive/2015/09/01/developing-dsc-scripts-for-the-azure-resource-manager-dsc-extension.aspx)