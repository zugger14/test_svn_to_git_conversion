SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGDEL_COUNTERPARTY_EPA_ACCOUNT]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_COUNTERPARTY_EPA_ACCOUNT]
GO

CREATE TRIGGER [dbo].[TRGDEL_COUNTERPARTY_EPA_ACCOUNT]
ON [dbo].[counterparty_epa_account]
FOR  DELETE
	AS
	INSERT INTO counterparty_epa_account_audit
	  (
		counterparty_epa_account_id
		, counterparty_id
		, external_type_id
		, external_value
		--create_user and create_ts are populated by default values. We need latest values, but not the original values.
	    --[create_user],
	    --[create_ts],
	    --Audit tables doesn't require update columns as data is never updated, but only inserted.
	    --[update_user],
	    --[update_ts],
		, user_action
		, [counterparty_name]
		, [source_system]
	  )
	SELECT  d.counterparty_epa_account_id
			, d.counterparty_id
			, d.external_type_id
			, d.external_value
			--, d.create_user
			--, d.create_ts
			--, d.update_user
			--, GETDATE()
			, 'delete'
			, sc.counterparty_name
			, sc.source_system_id
	FROM   DELETED d
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = d.[counterparty_id]