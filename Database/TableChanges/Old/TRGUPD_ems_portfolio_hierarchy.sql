SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_ems_portfolio_hierarchy]'))
	DROP TRIGGER [dbo].[TRGUPD_ems_portfolio_hierarchy]
GO

CREATE TRIGGER [dbo].[TRGUPD_ems_portfolio_hierarchy]
ON [dbo].[ems_portfolio_hierarchy]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE ems_portfolio_hierarchy
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM ems_portfolio_hierarchy t
		INNER JOIN DELETED u ON t.entity_id = u.entity_id
	END
END
GO
