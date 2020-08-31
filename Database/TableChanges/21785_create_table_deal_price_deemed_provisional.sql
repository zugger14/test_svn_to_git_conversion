IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_price_deemed_provisional]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[deal_price_deemed_provisional] (
		[deal_price_deemed_provisional_id] INT IDENTITY(1, 1) CONSTRAINT [pk_deal_price_deemed_provisional_id] PRIMARY KEY CLUSTERED WITH (IGNORE_DUP_KEY = OFF) NOT NULL,
		[source_deal_detail_id] INT NOT NULL REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id]),
		[pricing_index] INT NULL REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id]),
		[pricing_start] DATETIME NULL,
		[pricing_end] DATETIME NULL,
		[adder] FLOAT NULL,
		[currency] INT NULL,
		[multiplier] FLOAT NULL,
		[volume] NUMERIC(38, 20) NULL,
		[uom] INT NULL,
		[pricing_provisional] CHAR(1) NOT NULL,
		[pricing_type] CHAR(1) NULL,
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME DEFAULT GETDATE(),
		[update_user] VARCHAR(50) NULL,
		[update_ts] DATETIME NULL,
		[pricing_period] INT NULL,
		[fixed_price] FLOAT NULL,
		[pricing_uom] INT NULL,
		[adder_currency] INT NULL,
		[formula_id] INT NULL,
		[priority] INT NULL,
		[formula_currency] INT NULL REFERENCES [dbo].[source_currency] ([source_currency_id]),
		[fixed_cost] FLOAT NULL,
		[fixed_cost_currency] INT NULL REFERENCES [dbo].[source_currency] ([source_currency_id]),
		[deal_price_type_id] INT NULL REFERENCES [dbo].[deal_price_type_provisional] ([deal_price_type_provisional_id]) ON DELETE CASCADE,
		[include_weekends] CHAR(1) NULL,
		[rounding] INT NULL,
		[pricing_dates] VARCHAR(MAX) NULL,
		[BOLMO_pricing] CHAR(1) NULL
	)
END

IF OBJECT_ID('TRGUPD_deal_price_deemed_provisional') IS NOT NULL
	DROP TRIGGER [dbo].[TRGUPD_deal_price_deemed_provisional]
GO

CREATE TRIGGER [dbo].[TRGUPD_deal_price_deemed_provisional]
ON [dbo].[deal_price_deemed_provisional]
FOR UPDATE
AS
	UPDATE [dbo].[deal_price_deemed_provisional]
	SET update_user = dbo.FNADBUser(),
		update_ts = GETDATE()
	FROM deal_price_deemed t
	INNER JOIN DELETED u
		ON t.[deal_price_deemed_id] = u.[deal_price_deemed_provisional_id]
GO