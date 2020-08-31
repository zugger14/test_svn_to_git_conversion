SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID('[dbo].[TRGUPD_APPLICATION_SECURITY_ROLE]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_APPLICATION_SECURITY_ROLE]
GO

CREATE TRIGGER [dbo].[TRGUPD_APPLICATION_SECURITY_ROLE]
ON [dbo].[application_security_role]
FOR UPDATE
AS                                     
    
    DECLARE @update_user  VARCHAR(200)
    DECLARE @update_ts    DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.application_security_role
       SET update_user = @update_user,
           update_ts = @update_ts
    FROM dbo.application_security_role st
      INNER JOIN DELETED u ON st.role_id = u.role_id  
    

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
	       @update_user,
	       @update_ts,
	       'update' [user_action]
	FROM   INSERTED