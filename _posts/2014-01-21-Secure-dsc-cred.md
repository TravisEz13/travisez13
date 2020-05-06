---
toc: true
layout: post
description: Want to secure credentials in Windows PowerShell Desired State Configuration?
categories: [DSC]
title: Want to secure credentials in Windows PowerShell Desired State Configuration?
---

## Introduction

As you start using Windows PowerShell Desired State Configuration (DSC), you might need to specify credentials for resources. In a previous post we showed you how to define a resource that has a credential property.  In this post, I’ll discuss how to properly encrypt credentials when used in a DSC configuration.

## Prerequisites

First, let us discuss the requirements to encrypt a DSC configuration.

* You must have an Encryption capable certificate on the target node in the Local Computer’s Personal Store (in PowerShell the path to the store is `Cert:\LocalMachine\My`, we used the workstation authentication template, see all templates here.)
* If you are running the configuration, from a separate machine than the target node, you must export the public key of the certificate and import it on the machine you will be running the configuration from.
    * It is important that you keep the private key secure.  Since the public key is all that is needed to encrypt, I recommend you only export the public key to the machine you are writing your configurations on in order to keep the private key more secure.

#Assumptions
For this article I’m going to assume:

* You are using something like Active Directory Certificate Authority to issue and distribute the encryption certificates.
* Administrator access to the target node must be properly secured, as anyone with administrator access to the target node should be trusted with the credentials as the administrators can decrypt the credentials with enough effort.

## Overview

In order to encrypt credentials in a DSC configuration, you must follow a process.  You must have a certificate on each target node which supports encryption.  After that, you must have the public key and thumbprint of the certificate on the machine you are authoring the configuration on.  The public key must be provided using the configuration data, and I’ll show you how to provide the thumbprint using configuration data as well.  You must write a configuration script which configures the machine using the credentials, and sets up decryption by configuring the target node’s Local Configuration Manager (LCM) to decrypt the configuration using the encryption certificate as identified by its thumbprint.  Finally, you must run the configuration, including, setting the LCM settings and starting the DSC configuration.

<!-- place  -->

## Configuration Data

When dealing with encryption of DSC configuration, you must understand DSC configuration data. This structure describes, to a configuration, the list of nodes to be operated on, if credentials in a configuration should be encrypted or not for each node, how credential will be encrypted, and other information you want to include.  Below is an example of configuration data for a machine named `targetNode`, which I’d like to encrypt using a public key I’ve exported and saved to `C:\publicKeys\targetNode.cer`.

```powershell
$ConfigData=    @{
        AllNodes = @(
                        @{
                            # The name of the node we are describing
                            NodeName = “targetNode”

                            # The path to the .cer file containing the
                            # public key of the Encryption Certificate
                            # used to encrypt credentials for this node
                            CertificateFile = “C:\publicKeys\targetNode.cer”


                            # The thumbprint of the Encryption Certificate
                            # used to decrypt the credentials on target node
                            Thumbprint = “AC23EA3A9E291A75757A556D0B71CBBF8C4F6FD8″
                        };
                    );
    }
```

## Configuration Script

After we have the configuration data, we can start building our configuration.  Since credential are important to keep secure, you should always take the credential as a parameter to your configuration.  This is so the credentials are stored for the shortest time possible.  Below I’ll give an example of copying a file from a share that is secured to a user.

```powershell
configuration CredentialEncryptionExample
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PsCredential] $credential
        )


    Node $AllNodes.NodeName
    {
        File exampleFile
        {
            SourcePath = “\\Server\share\path\file.ext”
            DestinationPath = “C:\destinationPath”
            Credential = $credential
        }
    }
}
```

When you run CredentialEncryptionExample, DSC will prompt your for the credential and encrypt the mof using the CertificateFile associated with the node in the configuration data.

## Setting up Decryption

There is still one issue.  When you run [`Start-DscConfiguration`](http://technet.microsoft.com/en-us/library/dn521623.aspx), the Local Configuration Manager (LCM) of target node does not know which certificate to use to decrypt the credentials.  We need to add a LocalConfigurationManager resource to tell it.  You must set the CertificateId to the thumbprint of the certificate.  The first question becomes how to get the thumbprint.  Below is an example of how to find a local certificate that would work for encryption (you may need to customize this to find the exact certificate you want to use.)

```powershell
# Get the certificate that works for encryption
function Get-LocalEncryptionCertificateThumbprint
{
    (dir Cert:\LocalMachine\my) | %{
                        # Verify the certificate is for Encryption and valid
                        if ($_.PrivateKey.KeyExchangeAlgorithm -and $_.Verify())
                        {
                            return $_.Thumbprint
                        }
                    }
}
```

After we have the thumbprint, we use this to build the configuration data (given in the above configuration data example.)  Below is an example of the updated configuration with the LocalConfigurationManager resource, getting the value from the node in the configuration data.

```powershell
configuration CredentialEncryptionExample
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PsCredential] $credential
        )

    Node $AllNodes.NodeName
    {
        File exampleFile
        {
            SourcePath = “\\Server\share\path\file.ext”
            DestinationPath = “C:\destinationPath”
            Credential = $credential
        }

        LocalConfigurationManager
        {
             CertificateId = $node.Thumbprint
        }
    }
}
```

## Running the Configuration

From this point, we need to run the configuration, it will output one `*.meta.mof` to configure LCM to decrypt the credentials using the certificate installed to the local machine store identified by the thumbprint, and one mof to apply the configuration.  First, you will need to use [`Set-DscLocalConfigurationManager`](http://technet.microsoft.com/en-us/library/dn521621.aspx) to apply the `*.meta.mof` and then, `Start-DscConfiguration` to apply the configuration.  Here is an example of how you would run this:

```powershell
Write-Host “Generate DSC Configuration…”
CredentialEncryptionExample -ConfigurationData $ConfigData -OutputPath .\CredentialEncryptionExample

Write-Host “Setting up LCM to decrypt credentials…”
Set-DscLocalConfigurationManager .\CredentialEncryptionExample -Verbose

Write-Host “Starting Configuration…”
Start-DscConfiguration .\CredentialEncryptionExample -wait -Verbose
```

This example would push the configuration to the target node.  If you reference our blog on how to setup a pull configuration, you can modify the setting in the LocalConfigurationManager resource and use these steps to deploy this using a pull server.

## Summary

You should be able to build a sample that uses credentials securely in DSC using the information in this post.  I have written a more complete sample and have attached the code here:

[CredentialSample.psm1](https://msdnshared.blob.core.windows.net/media/MSDNBlogsFS/prod.evol.blogs.msdn.com/CommunityServer.Blogs.Components.WeblogFiles/00/00/00/63/74/6560.CredentialSample.psm1.txt)


The sample expands on what we discussed here and includes a helper cmdlet to export and copy the public keys to the local machine and an example how to use it.



Travis Plunk

Windows PowerShell DSC Test