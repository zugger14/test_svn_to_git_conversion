SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT  *  FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_var_measurement_criteria]'))
	DROP TRIGGER [dbo].[TRGUPD_var_measurement_criteria]
GO

CREATE TRIGGER [dbo].[TRGUPD_var_measurement_criteria]
ON [dbo].[var_measurement_criteria]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE var_measurement_criteria
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM var_measurement_criteria t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO
