SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_internal_deal_type_subtype_types]'))
	DROP TRIGGER [dbo].[TRGUPD_internal_deal_type_subtype_types]
GO

CREATE TRIGGER [dbo].[TRGUPD_internal_deal_type_subtype_types]
ON [dbo].[internal_deal_type_subtype_types]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE internal_deal_type_subtype_types
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
	FROM internal_deal_type_subtype_types t
	INNER JOIN DELETED u ON t.internal_deal_type_subtype_id = u.internal_deal_type_subtype_id
	END
END
GO

