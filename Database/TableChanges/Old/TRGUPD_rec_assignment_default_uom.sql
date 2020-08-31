SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_rec_assignment_default_uom]'))
	DROP TRIGGER [dbo].[TRGUPD_rec_assignment_default_uom]
GO

CREATE TRIGGER [dbo].[TRGUPD_rec_assignment_default_uom]
ON [dbo].[rec_assignment_default_uom]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE rec_assignment_default_uom
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM rec_assignment_default_uom t
		INNER JOIN DELETED u ON t.assignment_type_value_id = u.assignment_type_value_id
	END
END
GO
