SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_cash_flow_model_type]'))
	DROP TRIGGER [dbo].[TRGUPD_cash_flow_model_type]
GO

CREATE TRIGGER [dbo].[TRGUPD_cash_flow_model_type]
ON [dbo].[cash_flow_model_type]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE cash_flow_model_type
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM cash_flow_model_type t
		INNER JOIN DELETED u ON t.model_id = u.model_id
	END
END
GO
