USE [Adiha_Process]
GO
IF NOT EXISTS (
       SELECT 1
       FROM   sysfulltextcatalogs ftc
       WHERE  ftc.name = N'TRMTrackerFTI'
   )
    CREATE FULLTEXT CATALOG [TRMTrackerFTI] WITH ACCENT_SENSITIVITY = ON
	AUTHORIZATION [dbo]
GO

