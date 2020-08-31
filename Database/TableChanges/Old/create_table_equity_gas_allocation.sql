GO
IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[equity_gas_allocation]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].equity_gas_allocation
    (
	[equity_gas_allocation_id]		INT IDENTITY(1,1) NOT NULL,
	[location_id]					INT NOT NULL,
	[del_location_id]				INT NOT NULL,
	[term_start]					DATETIME NOT NULL,
	[primary_secondary]				VARCHAR(100) NULL,
	[volume]						FLOAT NOT NULL,
	[split_percentage]				FLOAT NOT NULL,
	[create_user]					VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
	[create_ts]						DATETIME DEFAULT GETDATE(),
	[update_user]					VARCHAR(100) NULL,
	[update_ts]						DATETIME NULL,
	CONSTRAINT [pk_equity_gas_allocation_id] PRIMARY KEY CLUSTERED([equity_gas_allocation_id] ASC)WITH (IGNORE_DUP_KEY = OFF) 
	ON [PRIMARY]
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END

GO


