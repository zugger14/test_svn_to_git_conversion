SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[deal_template_users]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].deal_template_users
    (
    [deal_template_users_id] INT IDENTITY(1, 1) NOT NULL,
	function_id	INT NOT NULL,
	role_id	INT,
	login_id VARCHAR(500),
	entity_id INT,
	create_user	VARCHAR(500),
	create_ts DATETIME,
	update_user VARCHAR(500),
	update_ts DATETIME,     
    )
END
ELSE
BEGIN
    PRINT 'Table deal_template_users EXISTS'
END

GO

IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'deal_template_users'      --table name
                      AND COLUMN_NAME = 'create_ts'    --column name where DEFAULT constaint it to be created
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE dbo.deal_template_users ADD CONSTRAINT
	DF_deal_template_users_create_ts default GETDATE() FOR create_ts
END
GO

IF NOT EXISTS(SELECT 1
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = 'dbo'
                      AND TABLE_NAME = 'deal_template_users'      --table name
                      AND COLUMN_NAME = 'create_user'    --column name where DEFAULT constaint it to be created
                      AND COLUMN_DEFAULT IS NOT NULL)
BEGIN
    ALTER TABLE dbo.deal_template_users ADD CONSTRAINT
	DF_deal_template_users_create_user default dbo.FNADBUser() FOR create_user
END
GO

