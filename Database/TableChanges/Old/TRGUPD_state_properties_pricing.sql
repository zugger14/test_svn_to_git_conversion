SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_state_properties_pricing]'))
	DROP TRIGGER [dbo].[TRGUPD_state_properties_pricing]
GO

CREATE TRIGGER [dbo].[TRGUPD_state_properties_pricing]
ON [dbo].[state_properties_pricing]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE state_properties_pricing
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM state_properties_pricing t
		INNER JOIN DELETED u ON t.pricing_id = u.pricing_id
	END
END
GO
