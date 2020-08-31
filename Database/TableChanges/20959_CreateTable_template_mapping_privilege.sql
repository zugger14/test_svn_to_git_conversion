SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[template_mapping_privilege]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[template_mapping_privilege] (
		[template_mapping_privilege_id] INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		[template_mapping_id]           INT REFERENCES template_mapping([template_mapping_id]) NOT NULL,
		[user_id]						VARCHAR(50) REFERENCES application_users(user_login_id) NULL,
		[role_id]						INT REFERENCES application_security_role (role_id) NULL,
		[create_user]                   VARCHAR(50) NULL DEFAULT [dbo].[FNADBUser](),
		[create_ts]                     DATETIME NULL DEFAULT GETDATE(),
		[update_user]                   VARCHAR(50) NULL,
		[update_ts]                     DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table template_mapping_privilege EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_template_mapping_privilege]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_template_mapping_privilege]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_template_mapping_privilege]
ON [dbo].[template_mapping_privilege]
FOR UPDATE
AS
    UPDATE template_mapping_privilege
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM template_mapping_privilege t
      INNER JOIN DELETED u ON t.[template_mapping_privilege_id] = u.[template_mapping_privilege_id]
GO