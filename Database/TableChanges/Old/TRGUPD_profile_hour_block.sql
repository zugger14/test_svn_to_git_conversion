SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_profile_hour_block]'))
	DROP TRIGGER [dbo].[TRGUPD_profile_hour_block]
GO

CREATE TRIGGER [dbo].[TRGUPD_profile_hour_block]
ON [dbo].[profile_hour_block]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE profile_hour_block
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM profile_hour_block t
		INNER JOIN DELETED u ON t.profile_hour_block_id = u.profile_hour_block_id
	END
END
GO
