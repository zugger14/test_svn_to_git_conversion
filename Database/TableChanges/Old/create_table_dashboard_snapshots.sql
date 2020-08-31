SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[dashboard_snaphots]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].dashboard_snaphots (
		[dashboard_snaphots_id] INT IDENTITY(1, 1) NOT NULL,
		[dashboard_snaphots_name] VARCHAR(100),
		[pdf_xml] NVARCHAR(MAX),
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME NULL DEFAULT GETDATE()
    )
END
ELSE
BEGIN
    PRINT 'Table dashboard_snaphots EXISTS'
END
 
GO
