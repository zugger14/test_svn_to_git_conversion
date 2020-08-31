SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_payment_instruction_detail]'))
	DROP TRIGGER [dbo].[TRGUPD_payment_instruction_detail]
GO

CREATE TRIGGER [dbo].[TRGUPD_payment_instruction_detail]
ON [dbo].[payment_instruction_detail]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE payment_instruction_detail
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM payment_instruction_detail t
		INNER JOIN DELETED u ON t.payment_ins_detail_Id = u.payment_ins_detail_Id
	END
END
GO
