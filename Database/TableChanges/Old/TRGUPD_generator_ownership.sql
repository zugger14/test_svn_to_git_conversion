SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_generator_ownership]'))
	DROP TRIGGER [dbo].[TRGUPD_generator_ownership]
GO

CREATE TRIGGER [dbo].[TRGUPD_generator_ownership]
ON [dbo].[generator_ownership]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE generator_ownership
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM generator_ownership t
		INNER JOIN DELETED u ON t.generator_ownership_id = u.generator_ownership_id
	END
END
GO
