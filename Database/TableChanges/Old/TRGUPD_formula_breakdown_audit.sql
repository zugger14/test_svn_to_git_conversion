SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_formula_breakdown_audit]'))
	DROP TRIGGER [dbo].[TRGUPD_formula_breakdown_audit]
GO

CREATE TRIGGER [dbo].[TRGUPD_formula_breakdown_audit]
ON [dbo].[formula_breakdown_audit]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE formula_breakdown_audit
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM formula_breakdown_audit t
		INNER JOIN DELETED u ON t.formula_audit_id = u.formula_audit_id
	END
END
GO