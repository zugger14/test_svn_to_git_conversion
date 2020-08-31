SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_payment_instruction_header]'))
	DROP TRIGGER [dbo].[TRGUPD_payment_instruction_header]
GO

CREATE TRIGGER [dbo].[TRGUPD_payment_instruction_header]
ON [dbo].[payment_instruction_header]
FOR UPDATE
AS
BEGIN
IF NOT UPDATE (create_ts) AND NOT UPDATE (update_ts)
	BEGIN
		UPDATE payment_instruction_header
		SET update_user = dbo.FNADBUser(),
			update_ts = GETDATE()
		FROM payment_instruction_header t
		INNER JOIN DELETED u ON t.payment_ins_header_id = u.payment_ins_header_id
	END
END
GO
