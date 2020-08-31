GO

IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[credit_exposure_calculation_log]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].credit_exposure_calculation_log
	(
	[calculation_log_log_id] [int] IDENTITY(1,1) NOT NULL,
	[process_id] [varchar](50) NOT NULL,
	[code] [varchar](50) NOT NULL,
	[module] [varchar](50) NOT NULL,
	[source] [varchar](50) NOT NULL,
	[type] [varchar](50) NOT NULL,
	[description] [varchar](1000) NULL,
	[nextsteps] [varchar](255) NOT NULL,
	[create_user]		VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]			DATETIME DEFAULT GETDATE(),
	[update_user]		VARCHAR(100) NULL,
	[update_ts]			DATETIME NULL	
	) ON [PRIMARY]
	
    PRINT 'Table Successfully Created'
END

GO

--DROP TABLE credit_exposure_calculation_log