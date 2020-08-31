SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_fas_link_header_detail_audit_map]'))
	DROP TRIGGER [dbo].[TRGUPD_fas_link_header_detail_audit_map]
GO

CREATE TRIGGER [dbo].[TRGUPD_fas_link_header_detail_audit_map]
ON [dbo].[fas_link_header_detail_audit_map]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE fas_link_header_detail_audit_map
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM fas_link_header_detail_audit_map t
		INNER JOIN DELETED u ON t.map_id = u.map_id
	END
END
GO
