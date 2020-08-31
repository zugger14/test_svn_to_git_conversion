SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_SOURCE_DEAL_TYPE]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_SOURCE_DEAL_TYPE]
GO

CREATE TRIGGER [dbo].[TRGINS_SOURCE_DEAL_TYPE]
ON [dbo].[source_deal_type]
FOR  INSERT
AS
		
	INSERT INTO source_deal_type_audit
	  (
	    source_deal_type_id,
	    source_system_id,
	    deal_type_id,
	    source_deal_type_name,
	    source_deal_desc,
	    sub_type,
	    expiration_applies,
	    disable_gui_groups,
	    break_individual_deal,
	    seperate_rec_value_used,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    user_action
	  )
	SELECT source_deal_type_id,
	       source_system_id,
	       deal_type_id,
	       source_deal_type_name,
	       source_deal_desc,
	       sub_type,
	       expiration_applies,
	       disable_gui_groups,
	       break_individual_deal,
	       seperate_rec_value_used,
	       ISNULL(create_user, dbo.FNADBUser()),
	       ISNULL(create_ts, GETDATE()),
	       update_user,
	       update_ts,
	       'insert'
	FROM   INSERTED


