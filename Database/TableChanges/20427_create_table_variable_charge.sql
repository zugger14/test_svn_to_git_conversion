IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[variable_charge]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].variable_charge
    (
	[id]		INT IDENTITY(1,1) NOT NULL,
	[rate_schedule_id]			VARCHAR(50) NOT NULL,
	[rate_type_id]	INT NOT NULL,
	[zone_from] INT NULL,
	[zone_to] INT NULL,
	[rate]	INT NOT NULL,
	[effective_date] DATETIME NULL,
	[uom_id] INT NULL,
	[formula_id] INT NULL,	
	[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]				DATETIME DEFAULT GETDATE(),
	[update_user]			VARCHAR(100) NULL,
	[update_ts]				DATETIME NULL,
	CONSTRAINT [pk_id] PRIMARY KEY CLUSTERED([id] ASC)WITH (IGNORE_DUP_KEY = OFF) 
	ON [PRIMARY]
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END

GO

