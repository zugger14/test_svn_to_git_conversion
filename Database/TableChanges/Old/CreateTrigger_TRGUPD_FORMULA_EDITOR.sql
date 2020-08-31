/****** Object:  Trigger [dbo].[TRGUPD_FORMULA_EDITOR]    Script Date: 01/10/2012 02:37:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_FORMULA_EDITOR]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_FORMULA_EDITOR]
GO

CREATE TRIGGER [dbo].[TRGUPD_FORMULA_EDITOR]
ON [dbo].[formula_editor]
FOR UPDATE
AS                                     
	
	DECLARE @update_user    VARCHAR(200)
	DECLARE @update_ts  DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.formula_editor
       SET update_user = @update_user,
           update_ts = @update_ts
    FROM dbo.formula_editor fe
      INNER JOIN DELETED u ON fe.formula_id = u.formula_id     

	DECLARE @audit_id INT
	SET @audit_id = ISNULL((SELECT MAX(audit_id)  FROM formula_editor_audit flda), 0) + 1

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
		   @update_user,
		   @update_ts,
		   formula_name,
		   system_defined,
		   static_value_id,
		   istemplate,
		   'update' [user_action]
	FROM   INSERTED