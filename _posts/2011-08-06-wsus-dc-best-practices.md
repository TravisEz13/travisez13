---
toc: true
layout: post
description: Guidance about WSUS on a Domain Controller
categories: [WSUS]
title: Guidance about WSUS on a Domain Controller
---

Originally posted on [TechNet](https://social.technet.microsoft.com/wiki/contents/articles/4236.guidance-about-wsus-on-a-domain-controller.aspx)

## Introduction

A common question that comes up during WSUS planning phase is if WSUS is supported on when installed on a Domain Controller. Although this is documented in TechNet in various locations, it is important to highlight some additional recommendations as well as enumerate the main source of documentation for that. The goal of this article is to consolidate the Guidance on running WSUS on a Domain Controller.

## Additional Considerations for Domain Controllers and WSUS

* The best practice is to not run WSUS on a Domain Controller. “If WSUS is installed a domain controller, this will cause database access issues due to how the database is configured.” This is documented in this [best practice](http://technet.microsoft.com/en-us/library/ff646928(WS.10).aspx)  article.
* “You cannot use a server configured as a domain controller for the back end of the remote SQL pair.” This is documented in the [Deployment Guide](http://www.microsoft.com/download/en/details.aspx?displaylang=en&id=22234).
* “When you Configure WSUS for Network Load Balancing, none of the servers taking part in the cluster should be a front-end domain controller.” This is documented in the [Deployment Guide](http://www.microsoft.com/download/en/details.aspx?displaylang=en&id=22234).
* If someone unfamiliar with Domain Controllers is troubleshooting a WSUS and removes the Windows Internal Database, this would be catastrophic to the domain.
* It is important to emphasize that by adding another critical role (such as patch management) on the Domain Controller you increase the overall impact in case this server goes offline for any reason.
* Separation of server roles is a vital recommendation for high availability scenarios. For this reason, consider server virtualization, where each server role will be in a different virtual machine.


Thanks to Rob Coffey and Yuri Diogenes for his help with this Article.
