SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_source_formula_audit]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_source_formula_audit]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_source_formula_audit]
ON [dbo].[ems_source_formula_audit]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_source_formula_audit
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_source_formula_audit t
		INNER JOIN DELETED u ON t.audit_id = u.audit_id
	END
END
GO
