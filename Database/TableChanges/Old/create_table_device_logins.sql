SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[device_logins]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[device_logins] (
    	[device_logins_id]   INT IDENTITY(1, 1) NOT NULL,
    	[user_login_id]	  VARCHAR(50) NOT NULL,
    	[device_token]	  VARCHAR(500) NOT NULL UNIQUE,
    	[os]	  VARCHAR(100) NOT NULL,
    	[create_ts]       DATETIME NULL DEFAULT GETDATE(),
    	[update_ts]       DATETIME NULL DEFAULT GETDATE()
    )
END
ELSE
BEGIN
    PRINT 'Table device_logins EXISTS'
END


GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
                    AND   tc.Table_Name = 'device_logins'           --table name
                    AND ccu.COLUMN_NAME = 'user_login_id'          --column name where FK constaint is to be created
)
BEGIN	
	ALTER TABLE [dbo].[device_logins] WITH NOCHECK ADD CONSTRAINT [FK_device_logins_application_users] FOREIGN KEY(user_login_id)
	REFERENCES [dbo].[application_users] ([user_login_id])  ON DELETE CASCADE

END
GO
