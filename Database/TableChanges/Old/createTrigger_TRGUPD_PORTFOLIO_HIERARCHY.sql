SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_PORTFOLIO_HIERARCHY]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_PORTFOLIO_HIERARCHY]
GO

CREATE TRIGGER [dbo].[TRGUPD_PORTFOLIO_HIERARCHY]
ON [dbo].[portfolio_hierarchy]
FOR  UPDATE
AS
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.portfolio_hierarchy
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.portfolio_hierarchy st
	INNER JOIN DELETED u ON  st.entity_id = u.entity_id	
	
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
	       @update_user,
	       @update_ts,
	       'update' [user_action]
	FROM   INSERTED