SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGDEL_FORMULA_EDITOR]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_FORMULA_EDITOR]
GO

CREATE TRIGGER [dbo].[TRGDEL_FORMULA_EDITOR]
ON [dbo].[formula_editor]
FOR  DELETE
AS
	DECLARE @audit_id INT
	SET @audit_id = ISNULL((SELECT MAX(audit_id) FROM formula_editor_audit flda),0) + 1
		
	INSERT INTO formula_editor_audit
	  (
	    audit_id,
	    formula_id,
	    formula,
	    formula_type,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    formula_name,
	    system_defined,
	    static_value_id,
	    istemplate,
	    user_action
	  )
	SELECT @audit_id,
	       formula_id,
	       formula,
	       formula_type,
	       create_user,
	       create_ts,
	       update_user,
	       --update_ts,
	       GETDATE(),
	       formula_name,
	       system_defined,
	       static_value_id,
	       istemplate,
	       'delete' [user_action]
	FROM   DELETED


