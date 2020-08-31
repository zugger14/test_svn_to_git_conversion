SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT  *  FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_var_measurement_criteria_detail]'))
	DROP TRIGGER [dbo].[TRGUPD_var_measurement_criteria_detail]
GO

CREATE TRIGGER [dbo].[TRGUPD_var_measurement_criteria_detail]
ON [dbo].[var_measurement_criteria_detail]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE var_measurement_criteria_detail
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM var_measurement_criteria_detail t
		INNER JOIN DELETED u ON t.id = u.id
	END
END
GO
