SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_farrms_config_setting]'))
	DROP TRIGGER [dbo].[TRGUPD_farrms_config_setting]
GO

CREATE TRIGGER [dbo].[TRGUPD_farrms_config_setting]
ON [dbo].[farrms_config_setting]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE farrms_config_setting
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM farrms_config_setting t
		INNER JOIN DELETED u ON t.esi_id = u.esi_id
	END
END
GO
