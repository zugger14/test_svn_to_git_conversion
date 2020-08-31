SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_PORTFOLIO_HIERARCHY]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_PORTFOLIO_HIERARCHY]
GO

CREATE TRIGGER [dbo].[TRGINS_PORTFOLIO_HIERARCHY]
ON [dbo].[portfolio_hierarchy]
FOR  INSERT
AS
	INSERT INTO portfolio_hierarchy_audit
	  (
	    entity_id,
	    entity_name,
	    entity_type_value_id,
	    hierarchy_level,
	    parent_entity_id,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    user_action
	  )
	SELECT entity_id,
	       entity_name,
	       entity_type_value_id,
	       hierarchy_level,
	       parent_entity_id,
	       create_user,
	       create_ts,
	       update_user,
	       update_ts,
	       'insert'
	FROM   INSERTED
	

	


