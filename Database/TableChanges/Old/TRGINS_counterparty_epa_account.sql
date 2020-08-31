SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_COUNTERPARTY_EPA_ACCOUNT]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_COUNTERPARTY_EPA_ACCOUNT]
GO

CREATE TRIGGER [dbo].[TRGINS_COUNTERPARTY_EPA_ACCOUNT]
ON [dbo].[counterparty_epa_account]
FOR  INSERT
AS
	INSERT INTO counterparty_epa_account_audit
	  (
	    counterparty_epa_account_id,
	    counterparty_id,
	    external_type_id,
	    external_value,
	    --create_user and create_ts are populated by default values. We need latest values, but not the original values.
	    --[create_user],
	    --[create_ts],
	    --Audit tables doesn't require update columns as data is never updated, but only inserted.
	    --[update_user],
	    --[update_ts],
	    user_action,
	    [counterparty_name],
	    [source_system]
	  )
	SELECT i.counterparty_epa_account_id,
	       i.counterparty_id,
	       i.external_type_id,
	       i.external_value,
	       --i.create_user,
	       --i.create_ts,
	       --i.update_user,
	       --i.update_ts,
	       'insert',
	       sc.counterparty_name,
	       sc.source_system_id
	FROM   INSERTED i
	INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = i.[counterparty_id]