SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_valuation_curve_mapping]'))
	DROP TRIGGER [dbo].[TRGUPD_valuation_curve_mapping]
GO

CREATE TRIGGER [dbo].[TRGUPD_valuation_curve_mapping]
ON [dbo].[valuation_curve_mapping]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE valuation_curve_mapping
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM valuation_curve_mapping t
		INNER JOIN DELETED u ON t.valuation_curve_mapping_id = u.valuation_curve_mapping_id
	END
END
GO
