SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_rec_generator_assignment]'))
	DROP TRIGGER [dbo].[TRGUPD_rec_generator_assignment]
GO

CREATE TRIGGER [dbo].[TRGUPD_rec_generator_assignment]
ON [dbo].[rec_generator_assignment]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE rec_generator_assignment
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM rec_generator_assignment t
		INNER JOIN DELETED u ON t.generator_assignment_id = u.generator_assignment_id
	END
END
GO
