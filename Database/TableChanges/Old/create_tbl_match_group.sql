SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[match_group]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].match_group
    (
    [match_group_id]             INT IDENTITY(1, 1) NOT NULL,
    group_name      VARCHAR(100) NULL,
    [create_user]    VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      DATETIME NULL DEFAULT GETDATE(),
    [update_user]    VARCHAR(50) NULL,
    [update_ts]      DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table match_group EXISTS'
END
 
GO

