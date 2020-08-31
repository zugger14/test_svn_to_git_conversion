SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.[ice_security_definition_staging]', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.[ice_security_definition_staging]
    (	[ID] [INT] IDENTITY(1, 1) NOT NULL,
    	product_id VARCHAR(500), 
		exchange_name VARCHAR(500), 
		product_name VARCHAR(500), 
		granularity VARCHAR(500), 
		tick_value VARCHAR(500), 
		uom VARCHAR(500), 
		hub_name VARCHAR(5000), 
		currency VARCHAR(500),
		cfi_code VARCHAR(500),
		hub_alias VARCHAR(500),
    	[create_user]       [VARCHAR](50) NULL DEFAULT dbo.FNAdbuser(),
    	[create_ts]         [DATETIME] NULL DEFAULT GETDATE()
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table ice_security_definition_staging EXISTS'
END

Go
