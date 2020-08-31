IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_counterparty_margin]') AND TYPE IN (N'U'))
BEGIN
	PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[source_counterparty_margin] (
		[source_counterparty_margin_id] INT IDENTITY(1, 1) NOT NULL,
		[as_of_date] DATETIME NULL,
		[clearing_counterparty_id] INT NULL,
		[margin_contract_id] INT NULL,
		[margin_account] NUMERIC(38,17) NULL,
		[mtmt_t0] NUMERIC(38,17) NULL,
		[mtmt_t1] NUMERIC(38,17) NULL,
		[delta_mtm] NUMERIC(38,17) NULL,
		[margin_call_price] NUMERIC(38,17) NULL,
		[maintenance_margin_amount] NUMERIC(38,17) NULL,
		[additional_margin] NUMERIC(38,17) NULL,
		[current_portfolio_value] NUMERIC(38,17) NULL,
		[maintenance_margin_required] NUMERIC(38,17) NULL,
		[margin_call] NUMERIC(38,17) NULL,
		[margin_excess] NUMERIC(38,17) NULL,
		[create_user] VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME DEFAULT GETDATE(),
		[update_user] VARCHAR(100) NULL,
		[update_ts] DATETIME NULL,
		CONSTRAINT [pk_source_counterparty_margin_id] PRIMARY KEY CLUSTERED ([source_counterparty_margin_id] ASC) WITH (IGNORE_DUP_KEY = OFF)
		ON [PRIMARY]
		) ON [PRIMARY]

	PRINT 'Table Successfully Created'
END
GO      

                        
