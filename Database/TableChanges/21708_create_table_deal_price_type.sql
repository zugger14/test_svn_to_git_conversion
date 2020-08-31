IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_price_type]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[deal_price_type] (
		[deal_price_type_id] INT IDENTITY(1, 1) CONSTRAINT [pk_deal_price_type_id] PRIMARY KEY CLUSTERED WITH (IGNORE_DUP_KEY = OFF) NOT NULL,
		[source_deal_detail_id] INT NOT NULL REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id]) ON DELETE CASCADE,
		[price_type_id] INT NOT NULL,
		[description] VARCHAR(1000) NULL,
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME DEFAULT GETDATE(),
		[update_user] VARCHAR(50) NULL,
		[update_ts] DATETIME NULL,
		[priority] INT NULL
	)
END

IF OBJECT_ID('TRGUPD_deal_price_type') IS NOT NULL
	DROP TRIGGER [dbo].[TRGUPD_deal_price_type]
GO

CREATE TRIGGER [dbo].[TRGUPD_deal_price_type]
ON [dbo].[deal_price_type]
FOR UPDATE
AS
	UPDATE [dbo].[deal_price_type]
	SET update_user = dbo.FNADBUser(),
		update_ts = GETDATE()
	FROM deal_price_type t
	INNER JOIN DELETED u
		ON t.[deal_price_type_id] = u.[deal_price_type_id]
GO