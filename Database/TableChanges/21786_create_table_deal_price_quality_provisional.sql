IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_price_quality_provisional]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[deal_price_quality_provisional] (
		[deal_price_quality_provisional_id] INT IDENTITY(1, 1) CONSTRAINT [pk_deal_price_quality_provisional_id] PRIMARY KEY CLUSTERED WITH (IGNORE_DUP_KEY = OFF) NOT NULL,
		[source_deal_detail_id] INT NOT NULL REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id]) ON DELETE CASCADE,
		[attribute] INT NOT NULL,
		[operator] INT NOT NULL,
		[numeric_value] NUMERIC(38, 20) NULL,
		[text_value] VARCHAR(500) NULL,
		[uom] INT NULL,
		[basis] INT NULL,
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME DEFAULT GETDATE(),
		[update_user] VARCHAR(50) NULL,
		[update_ts] DATETIME NULL
	)
END

IF OBJECT_ID('TRGUPD_deal_price_quality_provisional') IS NOT NULL
	DROP TRIGGER [dbo].[TRGUPD_deal_price_quality_provisional]
GO

CREATE TRIGGER [dbo].[TRGUPD_deal_price_quality_provisional]
ON [dbo].[deal_price_quality_provisional]
FOR UPDATE
AS
	UPDATE [dbo].[deal_price_quality_provisional]
	SET update_user = dbo.FNADBUser(),
		update_ts = GETDATE()
	FROM deal_price_quality_provisional t
	INNER JOIN DELETED u
		ON t.[deal_price_quality_provisional_id] = u.[deal_price_quality_provisional_id]