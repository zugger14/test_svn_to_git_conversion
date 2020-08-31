IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[portfolio_mapping_trader]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].[portfolio_mapping_trader] (
		[portfolio_mapping_trader_id]      INT IDENTITY(1, 1) NOT NULL,
		[portfolio_mapping_source_id]    INT REFERENCES [dbo].[portfolio_mapping_source] NOT NULL,		
		[trader_id]                      INT NULL,
		[create_user]                    VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]                      DATETIME DEFAULT GETDATE(),
		[update_user]                    VARCHAR(100) NULL,
		[update_ts]                      DATETIME NULL,
    	
		CONSTRAINT [pk_portfolio_mapping_trader_id] PRIMARY KEY CLUSTERED([portfolio_mapping_trader_id] ASC) WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
GO