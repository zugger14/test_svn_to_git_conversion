SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_APPLICATION_SECURITY_ROLE]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_APPLICATION_SECURITY_ROLE]
GO

CREATE TRIGGER [dbo].[TRGINS_APPLICATION_SECURITY_ROLE]
ON [dbo].[application_security_role]
FOR  INSERT
AS
	INSERT INTO application_security_role_audit
	  (
	    role_id,
	    role_name,
	    role_description,
	    role_type_value_id,
	    process_map_file_name,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    user_action
	  )
	SELECT role_id,
	       role_name,
	       role_description,
	       role_type_value_id,
	       process_map_file_name,
	       create_user,
	       create_ts,
	       update_user,
	       update_ts,
	       'insert'
	FROM   INSERTED
	

	


