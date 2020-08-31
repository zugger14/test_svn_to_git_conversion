SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[favourites_group]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[favourites_group](
    	[favourites_group_id]       INT IDENTITY(1, 1) NOT NULL,
    	[favourites_group_name]     VARCHAR(100) NOT NULL,
    	[seq_no]					INT NOT NULL,
    	[create_user]               VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                 DATETIME NULL DEFAULT GETDATE(),
    	[update_user]               VARCHAR(50) NULL,
    	[update_ts]                 DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table favourites_group EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_favourites_group]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_favourites_group]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_favourites_group]
ON [dbo].[favourites_group]
FOR UPDATE
AS
    UPDATE favourites_group
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM favourites_group t
      INNER JOIN DELETED u ON t.[favourites_group_id] = u.[favourites_group_id]
GO