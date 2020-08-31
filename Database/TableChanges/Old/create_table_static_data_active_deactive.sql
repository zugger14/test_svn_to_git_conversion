SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[static_data_active_deactive]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].static_data_active_deactive
    (
    static_data_active_deactive_id INT IDENTITY(1, 1) NOT NULL,
    [type_id] INT,
    is_active  CHAR(1) NULL,
    [create_user]    VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]      DATETIME NULL DEFAULT GETDATE(),
    [update_user]    VARCHAR(50) NULL,
    [update_ts]      DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table static_data_active_deactive EXISTS'
END
 
GO

