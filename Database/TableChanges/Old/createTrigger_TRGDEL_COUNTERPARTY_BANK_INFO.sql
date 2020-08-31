SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGDEL_COUNTERPARTY_BANK_INFO]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_COUNTERPARTY_BANK_INFO]
GO

CREATE TRIGGER [dbo].[TRGDEL_COUNTERPARTY_BANK_INFO]
ON [dbo].[counterparty_bank_info]
FOR  DELETE
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
	SELECT d.[bank_id],
	       d.[counterparty_id],
	       d.[bank_name],
	       d.[wire_ABA],
	       d.[ACH_ABA],
	       d.[Account_no],
	       d.[accountname],
	       d.[reference],
	       d.[currency],
	       d.[address1],
	       d.[address2],
	       'delete',
	       sc.counterparty_name,
	       sc.source_system_id
	FROM   DELETED d
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = d.[counterparty_id]