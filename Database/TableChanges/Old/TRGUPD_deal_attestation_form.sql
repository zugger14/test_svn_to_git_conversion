SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_deal_attestation_form]'))
	DROP TRIGGER [dbo].[TRGUPD_deal_attestation_form]
GO

CREATE TRIGGER [dbo].[TRGUPD_deal_attestation_form]
ON [dbo].[deal_attestation_form]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE deal_attestation_form
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM deal_attestation_form t
		INNER JOIN DELETED u ON t.attestation_id = u.attestation_id
	END
END
GO
