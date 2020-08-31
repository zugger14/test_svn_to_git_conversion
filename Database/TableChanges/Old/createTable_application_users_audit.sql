SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[application_users_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[application_users_audit]
    (
    	[audit_id]                  [INT] IDENTITY(1, 1) NOT NULL,
    	[user_login_id]             [VARCHAR](50) NOT NULL,
    	[user_f_name]               [VARCHAR](50) NOT NULL,
    	[user_m_name]               [VARCHAR](50) NULL,
    	[user_l_name]               [VARCHAR](100) NOT NULL,
    	[user_pwd]                  [VARCHAR](50) NOT NULL,
    	[user_title]                [VARCHAR](50) NULL,
    	[entity_id]                 [INT] NULL,
    	[user_address1]             [VARCHAR](250) NULL,
    	[user_address2]             [VARCHAR](250) NULL,
    	[user_address3]             [VARCHAR](250) NULL,
    	[city_value_id]             [VARCHAR](100) NULL,
    	[state_value_id]            [INT] NULL,
    	[user_zipcode]              [VARCHAR](20) NULL,
    	[user_off_tel]              [VARCHAR](20) NULL,
    	[user_main_tel]             [VARCHAR](20) NULL,
    	[user_pager_tel]            [VARCHAR](20) NULL,
    	[user_mobile_tel]           [VARCHAR](20) NULL,
    	[user_fax_tel]              [VARCHAR](20) NULL,
    	[user_emal_add]             [VARCHAR](100) NULL,
    	[message_refresh_time]      [INT] NULL,
    	[region_id]                 [INT] NOT NULL,
    	[user_active]               [VARCHAR](1) NULL,
    	[temp_pwd]                  [VARCHAR](1) NULL,
    	[expire_date]               [DATETIME] NULL,
    	[lock_account]              [VARCHAR](1) NULL,
    	[reports_to_user_login_id]  [VARCHAR](50) NULL,
    	[create_user]               [VARCHAR](50) NULL,
    	[create_ts]                 [DATETIME] NULL,
    	[update_user]               [VARCHAR](50) NULL,
    	[update_ts]                 [DATETIME] NULL,
    	[timezone_id]               [INT] NULL,
    	[user_action]               [VARCHAR] (50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table application_users_audit EXISTS'
END

GO

