SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[setup_workflow]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[setup_workflow]
    (
    [menu_id]			INT IDENTITY(1, 1) NOT NULL,
    [menu_name]			VARCHAR(100) NOT NULL,
    [function_id]		INT NULL,
	[menu_level]        TINYINT NOT NULL,
    [parent_menu_id]    INT NULL,
    [role_id]			INT NULL,
	[user_id]           VARCHAR(100) NULL,
    [sequence_order]    INT NULL,
    [tool_tip]			VARCHAR(100) NULL,
    [create_user]		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]			DATETIME NULL DEFAULT GETDATE(),
    [update_user]		VARCHAR(50) NULL,
    [update_ts]			DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table setup_workflow EXISTS'
END
 
GO


