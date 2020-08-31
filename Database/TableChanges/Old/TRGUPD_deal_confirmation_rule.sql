SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_deal_confirmation_rule]'))
	DROP TRIGGER [dbo].[TRGUPD_deal_confirmation_rule]
GO

CREATE TRIGGER [dbo].[TRGUPD_deal_confirmation_rule]
ON [dbo].[deal_confirmation_rule]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE deal_confirmation_rule
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM deal_confirmation_rule t
		INNER JOIN DELETED u ON t.rule_id = u.rule_id
	END
END
GO
