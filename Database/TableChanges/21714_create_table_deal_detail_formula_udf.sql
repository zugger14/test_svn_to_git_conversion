IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[deal_detail_formula_udf]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[deal_detail_formula_udf] (
		[deal_detail_formula_udf_id] INT IDENTITY(1, 1) CONSTRAINT [pk_deal_detail_formula_udf_id] PRIMARY KEY CLUSTERED WITH (IGNORE_DUP_KEY = OFF) NOT NULL,
		[source_deal_detail_id] INT NOT NULL REFERENCES source_deal_detail ([source_deal_detail_id]),
		[udf_template_id] INT NOT NULL REFERENCES user_defined_fields_template ([udf_template_id]),
		[udf_value] VARCHAR(2000) NULL,
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME DEFAULT GETDATE(),
		[update_user] VARCHAR(50) NULL,
		[update_ts] DATETIME NULL,
		[formula_id] INT NULL,
		[deal_price_type_id] INT NULL
	)	
END

IF OBJECT_ID('TRGUPD_deal_detail_formula_udf') IS NOT NULL
	DROP TRIGGER [dbo].[TRGUPD_deal_detail_formula_udf]
GO

CREATE TRIGGER [dbo].[TRGUPD_deal_detail_formula_udf]
ON [dbo].[deal_detail_formula_udf]
FOR UPDATE
AS
	UPDATE [dbo].[deal_detail_formula_udf]
	SET update_user = dbo.FNADBUser(),
		update_ts = GETDATE()
	FROM deal_detail_formula_udf t
	INNER JOIN DELETED u
		ON t.[deal_detail_formula_udf_id] = u.[deal_detail_formula_udf_id]
