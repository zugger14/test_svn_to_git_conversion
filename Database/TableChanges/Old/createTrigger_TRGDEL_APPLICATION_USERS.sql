SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGDEL_APPLICATION_USERS]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_APPLICATION_USERS]
GO

CREATE TRIGGER [dbo].[TRGDEL_APPLICATION_USERS]
ON [dbo].[application_users]
FOR  DELETE
AS
	INSERT INTO application_users_audit
	  (
	    user_login_id,
	    user_f_name,
	    user_m_name,
	    user_l_name,
	    user_pwd,
	    user_title,
	    entity_id,
	    user_address1,
	    user_address2,
	    user_address3,
	    city_value_id,
	    state_value_id,
	    user_zipcode,
	    user_off_tel,
	    user_main_tel,
	    user_pager_tel,
	    user_mobile_tel,
	    user_fax_tel,
	    user_emal_add,
	    message_refresh_time,
	    region_id,
	    user_active,
	    temp_pwd,
	    expire_date,
	    lock_account,
	    reports_to_user_login_id,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    timezone_id,
	    user_action
	  )
	SELECT user_login_id,
	       user_f_name,
	       user_m_name,
	       user_l_name,
	       user_pwd,
	       user_title,
	       entity_id,
	       user_address1,
	       user_address2,
	       user_address3,
	       city_value_id,
	       state_value_id,
	       user_zipcode,
	       user_off_tel,
	       user_main_tel,
	       user_pager_tel,
	       user_mobile_tel,
	       user_fax_tel,
	       user_emal_add,
	       message_refresh_time,
	       region_id,
	       user_active,
	       temp_pwd,
	       expire_date,
	       lock_account,
	       reports_to_user_login_id,
	       create_user,
	       create_ts,
	       dbo.FNADBUser(),
	       GETDATE(),
	       timezone_id,
	       'delete'
	FROM   DELETED


