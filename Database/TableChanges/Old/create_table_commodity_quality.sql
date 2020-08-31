GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[commodity_quality]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].commodity_quality
    (
    	[commodity_quality_id]     INT IDENTITY(1, 1) NOT NULL,
    	source_commodity_id        INT REFERENCES [dbo].[source_commodity] NOT NULL,
    	quality                    VARCHAR(100),
    	[range]                    VARCHAR(100),
    	from_value                 INT,
    	to_value                   INT,
    	uom                        INT,
    	[create_user]			   VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                DATETIME DEFAULT GETDATE(),
    	[update_user]              VARCHAR(100) NULL,
    	[update_ts]                DATETIME NULL,
    	CONSTRAINT [pk_commodity_quality_id] PRIMARY KEY CLUSTERED([commodity_quality_id] ASC)
    	WITH (IGNORE_DUP_KEY = OFF) 
    	ON [PRIMARY]
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
    END

GO