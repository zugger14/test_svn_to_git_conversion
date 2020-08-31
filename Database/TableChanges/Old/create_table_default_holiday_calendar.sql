SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[default_holiday_calendar]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[default_holiday_calendar]
    (
    [id]             INT IDENTITY(1, 1) NOT NULL,
    [def_code_id]    INT NULL,
    [calendar_desc]  INT NULL,
    [create_ts]      DATETIME NULL DEFAULT GETDATE(),
    [update_user]    VARCHAR(50) NULL,
    [update_ts]      DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table default_holiday_calendar EXISTS'
END
GO
