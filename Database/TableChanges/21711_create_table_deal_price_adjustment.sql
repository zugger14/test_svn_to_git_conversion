IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_price_adjustment]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[deal_price_adjustment] (
		[deal_price_adjustment_id] INT IDENTITY(1, 1) CONSTRAINT [pk_deal_price_adjustment_id] PRIMARY KEY CLUSTERED WITH (IGNORE_DUP_KEY = OFF) NOT NULL,
		[source_deal_detail_id] INT NOT NULL REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id]) ON DELETE CASCADE,
		[udf_template_id] INT NOT NULL REFERENCES [dbo].[user_defined_fields_template] ([udf_template_id]),
		[udf_value] VARCHAR(2000) NULL,
		[formula_id] INT NULL,
		[deal_price_type_id] INT NULL REFERENCES [dbo].[deal_price_type] ([deal_price_type_id]),
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME DEFAULT GETDATE(),
		[update_user] VARCHAR(50) NULL,
		[update_ts] DATETIME NULL,
	)
END

IF OBJECT_ID('TRGUPD_deal_price_adjustment') IS NOT NULL
	DROP TRIGGER [dbo].[TRGUPD_deal_price_adjustment]
GO

CREATE TRIGGER [dbo].[TRGUPD_deal_price_adjustment]
ON [dbo].[deal_price_adjustment]
FOR UPDATE
AS
	UPDATE [dbo].[deal_price_adjustment]
	SET update_user = dbo.FNADBUser(),
		update_ts = GETDATE()
	FROM deal_price_adjustment t
	INNER JOIN DELETED u
		ON t.[deal_price_adjustment_id] = u.[deal_price_adjustment_id]