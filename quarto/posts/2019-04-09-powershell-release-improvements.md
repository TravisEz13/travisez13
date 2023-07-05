---
toc: true
layout: post
description: PowerShell Core Release Improvements
categories: [PowerShell]
title: PowerShell Core Release Improvements
date: April 09, 2010
---

## Overview

For [PowerShell Core](https://github.com/powershell/powershell), we basically had to build a new engineering system to build and release it.  How we build it has evolved over time as we learn and our other teams have implemented features that make some tasks easier.  We are finally at a state that we believe we can engineer a system that builds PowerShell Core for release with as little human interaction as necessary.

## Current state

Before the changes described here, we had one build per platform.  After the binaries were built, they had to be tested and then packaged into the various packages for release.  This is done in a private [Azure DevOps Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/?view=azure-devops) instance.  In this state, it took a good deal of people's time to do a PowerShell Core release.  Before these changes, it would take 3-4 people about a week to release PowerShell Core.  During this time, the percentage of time people were focused on the release probably averaged 50%.

## Goals

1. Remain compliant with Microsoft and external standards we are required to follow.
2. Automate as much of the build, test, and release process as possible.
   * This should significantly reduce the amount of human toil needed in each release.
3. Hopefully, provide some tools or practices others can follow.

## What we have done so far

1. We ported our [CI](https://en.wikipedia.org/wiki/Continuous_integration) tests to Azure DevOps Pipelines.
    * We have used this in a release and we see that this allowed us to run at least those test in our private Azure DevOps Pipelines instance.
    * This saves us 2-4 man hours per release and a day or more of calendar time if all goes well.

2. We have moved our release build definitions to [YAML](https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema?view=azure-devops&tabs=schema#job-templates).
    * We have used this in a release and we see that this allows us to treat the release build as code and iterate more quickly.
    * This saves us 1-2 man hours per release, when we have done everything correctly.

3. I have begun to merge the the different platform builds into one combined build.
    * We have not yet used this in a release but we believe this should allow us to have a single button that gets us ready to test.
    * This has not been in use long enough to determine how much time it will save.

4. We have begun to automate our releases testing.  Our release testing is very similar to our CI testing just across more distributions and versions of  Windows.  We plan to be able to run this through Azure DevOps Pipelines as well.
    * This has not been in use long enough to determine how much time it will save.

5. We have automated the generation of the draft of the change log and categorizing the entries based on labels the maintainers apply to the PRs.  After generation, the maintainers still need to review the change descriptions to make sure it makes sense in the change log.
    * This saves us 2-4 man hours per release.

### Summary of improvements

After all these changes, we can now release with 2-3 people in 2 to 3 days, with an average of 25% time focusing on the release.

## Details of the combined build

Azure DevOps Pipelines allows us to define complex build pipeline.  The build will be complex but things like [templates in Azure DevOps](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops) makes breaking it into a manageable pieces.

Although this design does not technically reduce the number of parts, one significant thing it does for us it put all of our [artifacts](https://docs.microsoft.com/en-us/azure/devops/pipelines/artifacts/artifacts-overview?view=azure-devops), in one place.  Having the artifacts in one place, reduces the input to the steps in the rest of the build such as test and release.

I'm not going to discuss it much, but in order to coordinate this work we are keeping diagram of the build.  I'll include it here.  If you want me to post another blog on the details, please leave a comment.

![diagram](https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/releaseBuild/azureDevOps/diagram.svg?sanitize=true)

## What is left to do

1. We still have to add the other various NuGet package build steps to the coordinated build.
2. We need to automate functionality (CI tests) across a representative sample of supported platforms.
3. It would be nice if we could enforce in GitHub the process that helps us automate the change log generation.
4. We need to automate the release process including:
    * Automating package testing.  For example, MSI, Zip, Deb, RPM, and Snap.
    * Automating the actual release to GitHub, mcr.microsoft.com, packages.microsoft.com and the Snap store.
