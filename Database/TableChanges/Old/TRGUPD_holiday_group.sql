SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_holiday_group]'))
	DROP TRIGGER [dbo].[TRGUPD_holiday_group]
GO

CREATE TRIGGER [dbo].[TRGUPD_holiday_group]
ON [dbo].[holiday_group]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE holiday_group
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM holiday_group t
		INNER JOIN DELETED u ON t.hol_group_ID = u.hol_group_ID
	END
END

