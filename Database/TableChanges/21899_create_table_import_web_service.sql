SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[import_web_service]', N'U') IS  NULL
BEGIN
	CREATE TABLE import_web_service (
		id INT IDENTITY(1,1) PRIMARY KEY,
		ws_name VARCHAR(200) NOT NULL,
		ws_description VARCHAR(1000),
		web_service_url VARCHAR(1000) NOT NULL,
		auth_token VARCHAR(500),
		user_name VARCHAR(100),
		password VARCHAR(100),
		clr_function_id INT,
		create_user VARCHAR(200) DEFAULT dbo.FNADBUser(),
		create_ts DATETIME DEFAULT GETDATE(),
		update_user VARCHAR(200),
		update_time DATETIME 
	)
END
ELSE
BEGIN
    PRINT 'Table import_web_service EXISTS'
END
GO

--Update Trigger
IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_import_web_service]'))
    DROP TRIGGER  [dbo].[TRGUPD_import_web_service]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_import_web_service]
ON [dbo].[import_web_service]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [dbo].[import_web_service]
        SET update_user = dbo.FNADBUser(), update_time = GETDATE()
        FROM [dbo].[import_web_service] fr
        INNER JOIN DELETED d ON d.id = fr.id
    END
END
GO

