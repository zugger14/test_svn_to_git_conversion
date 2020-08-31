SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[lock_as_of_date]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[lock_as_of_date]
    (
    	[lock_as_of_date_id]  INT IDENTITY(1, 1) NOT NULL,
    	[sub_ids]             VARCHAR(5000) NULL,
    	[close_date]          DATETIME NULL,
    	[close_on]            DATETIME NULL DEFAULT GETDATE(),
    	[close_by]            VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_user]         VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]           DATETIME NULL DEFAULT GETDATE(),
    	[update_user]         VARCHAR(50) NULL,
    	[update_ts]           DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table lock_as_of_date EXISTS'
END
 
GO