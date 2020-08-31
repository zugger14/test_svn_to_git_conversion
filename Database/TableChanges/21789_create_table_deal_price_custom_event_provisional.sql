IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_price_custom_event_provisional]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[deal_price_custom_event_provisional](
		[deal_price_custom_event_provisional_id] INT IDENTITY(1, 1) CONSTRAINT [pk_deal_price_custom_event_provisional_id] PRIMARY KEY CLUSTERED WITH (IGNORE_DUP_KEY = OFF) NOT NULL,
		[source_deal_detail_id] INT NOT NULL REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id]),
		[event_type] INT NULL,
		[event_date] DATETIME NULL,
		[pricing_index] INT NOT NULL REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id]),
		[skip_days] INT NULL,
		[quotes_before] INT NULL,
		[quotes_after] INT NULL,
		[include_event_date] CHAR(1) NULL,
		[include_holidays] CHAR(1) NULL,
		[adder] FLOAT NULL,
		[currency] INT NULL,
		[multiplier] FLOAT NULL,
		[volume] NUMERIC(38, 20) NULL,
		[uom] INT NULL,
		[pricing_provisional] CHAR(1) NOT NULL,
		[pricing_type] CHAR(1) NULL,
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME DEFAULT GETDATE(),
		[update_user] [varchar](50) NULL,
		[update_ts] DATETIME NULL,
		[rounding] INT NULL,
		[deal_price_type_id] INT NULL REFERENCES [dbo].[deal_price_type_provisional] ([deal_price_type_provisional_id]) ON DELETE CASCADE,
		[pricing_month] [date] NULL,
		[skip_granularity] INT NULL,
		[BOLMO_pricing] CHAR(1) NULL
	)
END

IF OBJECT_ID('TRGUPD_deal_price_custom_event_provisional') IS NOT NULL
	DROP TRIGGER [dbo].[TRGUPD_deal_price_custom_event_provisional]
GO

CREATE TRIGGER [dbo].[TRGUPD_deal_price_custom_event_provisional]
ON [dbo].[deal_price_custom_event_provisional]
FOR UPDATE
AS
	UPDATE [dbo].[deal_price_custom_event_provisional]
	SET update_user = dbo.FNADBUser(),
		update_ts = GETDATE()
	FROM deal_price_custom_event_provisional t
	INNER JOIN DELETED u
		ON t.[deal_price_custom_event_provisional_id] = u.[deal_price_custom_event_provisional_id]