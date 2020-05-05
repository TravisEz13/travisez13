---
toc: true
layout: post
description: Best Practices for Securing WSUS with SSL
categories: [WSUS]
title: Best Practices for Securing WSUS with SSL
---

## Introduction

One of the questions that always come up during the planning phase of WSUS is how to secure the communication between WSUS and the clients. The general guidelines for this deployment are documented at [Securing WSUS with the Secure Sockets Layer Protocol](http://technet.microsoft.com/en-us/library/cc708467%28WS.10%29.aspx) article and you should always read it first. The goal of this article is to extent this list and highlight additional considerations that you should take while planning this type of deployment.

## Additional Considerations while Deploying WSUS with SSL

* Use an [FQDN](http://en.wikipedia.org/wiki/FQDN) wherever you refer to the WSUS server, including the common name used to create the SSL Certificate even on an intranet.
* Require SSL so that you know your connections are secure.
* Use a certificate chained to already known trusted root, issued from a certificate authority that maintains [CRL](http://en.wikipedia.org/wiki/Certificate_revocation_list) (in case your certificate becomes compromised).

Consider the Algorithm and Certificate Key length of the certificate you are using:

* “The National Institute of Standards and Technology (NIST) has issued a statement that says SSL certificates with a key length of 1,024 bits or fewer will be insufficient for security after December 31, 2010, because NIST estimates that computers will be powerful enough to perform a brute-force crack of keys of that size.” http://www.windowsitpro.com/article/security/Are-Your-SSL-Certificates-Secure
* The research … has the specific purpose of convincing Certification Authorities to drop `MD5` and move on to more secure algorithms, such as ~~`SHA-1`~~, `SHA-2`, or the upcoming `SHA-3`. http://news.softpedia.com/news/SSL-Security-Broken-101075.shtml
