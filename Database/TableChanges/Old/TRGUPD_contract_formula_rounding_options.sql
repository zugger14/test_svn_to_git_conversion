SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_contract_formula_rounding_options]'))
	DROP TRIGGER [dbo].[TRGUPD_contract_formula_rounding_options]
GO

CREATE TRIGGER [dbo].[TRGUPD_contract_formula_rounding_options]
ON [dbo].[contract_formula_rounding_options]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE contract_formula_rounding_options
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM contract_formula_rounding_options t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO

