SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[favourites_menu]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[favourites_menu] (
    	[favourites_menu_id]      INT IDENTITY(1, 1) NOT NULL,
    	[favourites_menu_name]    VARCHAR(100) NULL,
    	[group_id]				  INT NOT NULL DEFAULT (-1),
    	[function_id]			  INT REFERENCES application_functions(function_id) NOT NULL,
    	[window_name]			  VARCHAR(500),
    	[file_path]				  VARCHAR(5000),
    	seq_no					  INT NOT NULL,
    	[create_user]             VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME NULL DEFAULT GETDATE(),
    	[update_user]             VARCHAR(50) NULL,
    	[update_ts]               DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table favourites_menu EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_favourites_menu]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_favourites_menu]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_favourites_menu]
ON [dbo].[favourites_menu]
FOR UPDATE
AS
    UPDATE favourites_menu
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM favourites_menu t
      INNER JOIN DELETED u ON t.[favourites_menu_id] = u.[favourites_menu_id]
GO