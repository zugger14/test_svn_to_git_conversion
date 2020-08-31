IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_counterparty_margin]') AND TYPE IN (N'U'))
BEGIN
	PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].source_counterparty_margin (
		[source_counterparty_margin_id] INT IDENTITY(1, 1) NOT NULL,
		[as_of_date] DATETIME NULL,
		[clearing_counterparty_id] INT NULL,
		[margin_contract_id] INT NULL,
		[margin_account] FLOAT NULL,
		[mtmt_t0] FLOAT NULL,
		[mtmt_t1] FLOAT NULL,
		[delta_mtm] FLOAT NULL,
		[margin_call_price] FLOAT NULL,
		[maintenance_margin_amount] FLOAT NULL,
		[additional_margin] FLOAT NULL,
		[current_portfolio_value] FLOAT NULL,
		[maintenance_margin_required] FLOAT NULL,
		[margin_call] FLOAT NULL,
		[margin_excess] FLOAT NULL,
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