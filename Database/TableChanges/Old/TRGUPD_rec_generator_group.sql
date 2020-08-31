SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_rec_generator_group]'))
	DROP TRIGGER [dbo].[TRGUPD_rec_generator_group]
GO

CREATE TRIGGER [dbo].[TRGUPD_rec_generator_group]
ON [dbo].[rec_generator_group]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE rec_generator_group
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM rec_generator_group t
		INNER JOIN DELETED u ON t.generator_group_id = u.generator_group_id
	END
END
GO
