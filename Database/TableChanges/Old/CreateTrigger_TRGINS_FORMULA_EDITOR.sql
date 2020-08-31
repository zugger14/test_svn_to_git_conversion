/****** Object:  Trigger [dbo].[TRGINS_FORMULA_EDITOR]    Script Date: 01/10/2012 02:27:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



IF OBJECT_ID('[dbo].[TRGINS_FORMULA_EDITOR]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_FORMULA_EDITOR]
GO

CREATE TRIGGER [dbo].[TRGINS_FORMULA_EDITOR]
ON [dbo].[formula_editor]
FOR  INSERT
AS
	-- Logic Adapted to Default Value and Binding
	--UPDATE dbo.formula_editor
	--SET    create_user = dbo.FNADBUser(),
	--       create_ts = GETDATE()
	--WHERE  formula_editor.formula_id IN (SELECT formula_id FROM   INSERTED)

	DECLARE @audit_id INT
	SET @audit_id = ISNULL((SELECT MAX(audit_id) FROM formula_editor_audit fea),0) + 1
	
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
	       update_ts,
	       formula_name,
	       system_defined,
	       static_value_id,
	       istemplate,
	       'insert' [user_action]
	FROM   INSERTED

