SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[setup_menu]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[setup_menu]
    (
    	[setup_menu_id]      INT IDENTITY(1, 1) NOT NULL,
    	[function_id]        INT NOT NULL,
    	[window_name]        VARCHAR(1000) NULL,
    	[display_name]       VARCHAR(200) NOT NULL,
    	[default_parameter]  VARCHAR(5000) NULL,
    	[hide_show]          BIT NULL,
    	[parent_menu_id]     INT NULL,
    	[product_category]   INT NOT NULL,
    	[menu_order]         INT NOT NULL,
    	[menu_type]			 BIT NULL,
    	[create_user]        VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]          DATETIME NULL DEFAULT GETDATE(),
    	[update_user]        VARCHAR(50) NULL,
    	[update_ts]          DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table setup_menu already EXISTS.'
END
 
GO

--DROP TABLE setup_menu
