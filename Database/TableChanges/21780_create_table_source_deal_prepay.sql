IF OBJECT_ID(N'source_deal_prepay', N'U') IS NOT NULL
BEGIN
	PRINT 'Table already exists.'
END
ELSE
BEGIN
	CREATE TABLE source_deal_prepay (
		[source_deal_prepay_id] INT IDENTITY(1, 1) CONSTRAINT [pk_source_deal_prepay] PRIMARY KEY CLUSTERED WITH (IGNORE_DUP_KEY = OFF) NOT NULL,
		[prepay] INT,
		[value] VARCHAR(1000),
		[percentage] FLOAT,
		[formula_id] INT,
		[settlement_date] DATETIME,
		[settlement_calendar] INT,
		[settlement_days] INT,
		[payment_date] DATETIME,
		[payment_calendar] INT,
		[payment_days] INT,
		[granularity] INT,
		[source_deal_header_id] INT REFERENCES source_deal_header(source_deal_header_id) NOT NULL,
		[create_user] VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME DEFAULT GETDATE(),
		[update_user] VARCHAR(100) NULL,
		[update_ts] DATETIME NULL
	)

	PRINT 'Table Created'
END
GO

IF EXISTS (SELECT 1 FROM sys.triggers WHERE [object_id] = OBJECT_ID(N'[dbo].[TRGUPD_source_deal_prepay]'))
    DROP TRIGGER [dbo].[TRGUPD_source_deal_prepay]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_source_deal_prepay]
	ON [dbo].[source_deal_prepay]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(update_ts)
    BEGIN
        UPDATE source_deal_prepay
        SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
        FROM source_deal_prepay an
        INNER JOIN DELETED d ON d.source_deal_prepay_id = an.source_deal_prepay_id
    END
END
GO