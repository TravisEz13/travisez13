---
toc: true
layout: post
description: Installing WSUS on Windows Server “8” Beta using PowerShell
categories: [WSUS]
title: Installing WSUS on Windows Server “8” Beta using PowerShell
---

Originally posted on [Technet](https://blogs.technet.microsoft.com/sus/2012/03/20/installing-wsus-on-windows-server-8-beta-using-powershell/).

#### Authors:

* Travis Plunk, Software Developer Engineer
* [Yuri Diogenes](https://twitter.com/yuridiogenes), Senior Technical Writer

#### Technical Reviewers:

* Cecilia Cole, Program Manager

In our [previous post](http://blogs.technet.com/b/sus/archive/2012/03/02/getting-started-with-wsus-on-the-windows-server-8-beta-installing-the-wsus-role-using-the-new-server-manager.aspx), we demonstrated how to install the WSUS Role on the Windows Server “8” Beta using the new Server Manager.  In this post you will learn how to perform the same task using PowerShell.

To install WSUS on Windows Server “8” Beta using PowerShell,
follow the steps below:

1. Sign in on Windows Server “8” Beta

1. On the taskbar click Windows PowerShell button.
   ![8156.image_1FBE9383](/content/images/2019/02/8156.image_1FBE9383.png)

1. In the PowerShell Console type `Install-WindowsFeature -Name UpdateServices, UpdateServices-Ui` and press **ENTER**.

1. The installation process will start and a progress counter will appear on the screen. Wait until the installation reaches 100% and you receive a message that the installation succeeded before moving on to the next step.

1. Type `& 'C:\Program Files\Update Services\Tools\WsusUtil.exe' postinstall contentdir=C:\Mycontent` and press **ENTER**.

1. Wait until you receive the message that the post installation successfully finished.

1. Type Exit and press **ENTER** to leave the PowerShell interface.

At this point the WSUS installation is completed and you may launch the WSUS Console using the Tools menu. When you launch WSUS for the first time the **WSUS Configuration Wizard** will appear. For more information about how to configure WSUS, read [Step 3: Configure WSUS](http://technet.microsoft.com/en-us/library/hh852346.aspx) in the [Deploying Windows Server Updates Services in the Organization](http://technet.microsoft.com/en-us/library/hh852340.aspx) article at the TechNet Library.

If you want to perform the full installation and post installation tasks using PowerShell you should run this script once you finish the installation via PowerShell.

Stay tuned for more exciting stuff on this blog and the Windows Server Blog from the server leadership team.
