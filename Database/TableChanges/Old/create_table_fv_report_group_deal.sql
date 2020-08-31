GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[fv_report_group_deal]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].fv_report_group_deal
    (
    	fv_report_group_deal_id    INT IDENTITY(1, 1) NOT NULL,
		source_deal_header_id	int,
    	term_start              datetime ,
    	fv_level_value_id       INT NULL,
    	[effective_date]        DATETIME,
    	[create_user]           VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]             DATETIME DEFAULT GETDATE(),
    	[update_user]           VARCHAR(100) NULL,
    	[update_ts]             DATETIME NULL
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END

GO

