SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_COUNTERPARTY_BANK_INFO]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_COUNTERPARTY_BANK_INFO]
GO

CREATE TRIGGER [dbo].[TRGINS_COUNTERPARTY_BANK_INFO]
ON [dbo].[counterparty_bank_info]
FOR  INSERT
AS
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
	SELECT [bank_id],
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
	       'insert',
	       sc.counterparty_name,
	       sc.source_system_id
	FROM   INSERTED i
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = i.[counterparty_id]