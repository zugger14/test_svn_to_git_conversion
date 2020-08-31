SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_interest_expense]'))
	DROP TRIGGER [dbo].[TRGUPD_interest_expense]
GO

CREATE TRIGGER [dbo].[TRGUPD_interest_expense]
ON [dbo].[interest_expense]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE interest_expense
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM interest_expense t
		INNER JOIN DELETED u ON t.interest_expenses_id = u.interest_expenses_id
	END
END
GO
