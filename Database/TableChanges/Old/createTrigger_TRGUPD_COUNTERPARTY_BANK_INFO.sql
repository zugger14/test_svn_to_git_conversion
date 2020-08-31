SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_COUNTERPARTY_BANK_INFO]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_COUNTERPARTY_BANK_INFO]
GO

CREATE TRIGGER [dbo].[TRGUPD_COUNTERPARTY_BANK_INFO]
ON [dbo].[counterparty_bank_info]
FOR  UPDATE
AS
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.counterparty_bank_info
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.counterparty_bank_info cbi
	INNER JOIN DELETED u ON  cbi.bank_id = u.bank_id  
	
	INSERT INTO counterparty_bank_info_audit
	  (
	    [bank_id],
	    [counterparty_id],
	    [bank_name],
	    [wire_ABA],
	    [ACH_ABA],
	    [Account_no],
	    [account_name],
	    [reference],
	    [currency],
	    [address1],
	    [address2],
	    [user_action],
	    [counterparty_name],
	    [source_system]
	  )
	SELECT i.[bank_id],
	       i.[counterparty_id],
	       i.[bank_name],
	       i.[wire_ABA],
	       i.[ACH_ABA],
	       i.[Account_no],
	       i.[accountname],
	       i.[reference],
	       i.[currency],
	       i.[address1],
		   i.[address2],
	       'update' [user_action],
	       sc.counterparty_name,
	       sc.source_system_id
	FROM INSERTED i
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = i.[counterparty_id]