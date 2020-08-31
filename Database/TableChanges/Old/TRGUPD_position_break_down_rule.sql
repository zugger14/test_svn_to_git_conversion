SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_position_break_down_rule]'))
	DROP TRIGGER [dbo].[TRGUPD_position_break_down_rule]
GO

CREATE TRIGGER [dbo].[TRGUPD_position_break_down_rule]
ON [dbo].[position_break_down_rule]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE position_break_down_rule
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM position_break_down_rule t
		INNER JOIN DELETED u ON t.strip_from = u.strip_from AND t.lag = u.lag AND t.strip_to = u.strip_to 
			AND t.phy_month = u.phy_month AND t.phy_day = u.phy_day AND t.pricing_term = u.pricing_term
	END
END
GO
