# Finding machines not compliant with a specific security bulletin

Originally posted on [TechNet](https://blogs.technet.microsoft.com/wsus/2008/07/07/finding-machines-not-compliant-with-a-specific-security-bulletin/).

I read Marc’s [post about Compliance Reporting](http://blogs.technet.com/wsus/archive/2008/06/20/baseline-compliance-report-using-public-wsus-views.aspx) and it was similar to a problem I deal with in my job.  Part of my job is to run Update Management on one of the domains consisting of around 12,000 managed computers at Microsoft using WSUS.  We do this in order to validate WSUS (and similar products) in an environment with real users.  Another group at Microsoft audits my compliance, and often request a list of non-compliant machines for specific security bulletins.  I have adapted Marc’s SQL script to do just that.

I ran into one issue, Marc’s SQL script will blocks clients from scanning while it runs.  Since the script can take a long time to execute on larger data sets, I decided to allow SQL to read dirty data and unblock my clients (`SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED`.).

I hope you find this useful.

Travis Plunk

Software Design Engineer in Test II, WSUS

```sql
-- Find computers within a target group that need a security bulletin

USE SUSDB
go

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

GO

DECLARE @TargetGroup nvarchar(30)


DECLARE @Bulletin nvarchar(9)

SELECT @TargetGroup = 'All Computers'


SELECT @Bulletin = 'MS08-030'


-- Find the computers not compliant for each security bulletin in the given @TargetGroup
-- where the approved occured between @Days and @DaysEnd days ago


SELECT       ct.Name,@Bulletin as Bulletin,ct.LastReportedStatusTime
FROM         PUBLIC_VIEWS.vComputerGroupMembership as cgm INNER JOIN
                      PUBLIC_VIEWS.vComputerTarget as ct ON
                      cgm.ComputerTargetId = ct.ComputerTargetId INNER JOIN
                      PUBLIC_VIEWS.vComputerTargetGroup as ctg ON
                      cgm.ComputerTargetGroupId = ctg.ComputerTargetGroupId
WHERE     (ctg.Name = @TargetGroup)

-- And only select those for which an update is approved for install, the
-- computer status for that update is either 2 (not installed), 3 (downloaded),
-- 5 (failed), or 6 (installed pending reboot), and
-- the update bulletin is the one provided.

                              AND EXISTS
                          (SELECT     1
                            FROM          PUBLIC_VIEWS.vUpdateEffectiveApprovalPerComputer as ueapc INNER JOIN
                                                   PUBLIC_VIEWS.vUpdateApproval as ua ON
                                                   ua.UpdateApprovalId = ueapc.UpdateApprovalId INNER JOIN
                                                   PUBLIC_VIEWS.vUpdateInstallationInfoBasic uiib ON
                                                   uiib.ComputerTargetId = ct.ComputerTargetId AND
                                                   ua.UpdateId = uiib.UpdateId
                                                   inner join PUBLIC_VIEWS.vUpdate as u on ua.updateid=u.updateId 
                            WHERE      (ueapc.ComputerTargetId = ct.ComputerTargetId) AND
                                                   (ua.Action = 'Install') AND (uiib.State IN (2, 3, 5, 6)) AND u.securityBulletin is not null and u.securityBulletin=@Bulletin )
```
