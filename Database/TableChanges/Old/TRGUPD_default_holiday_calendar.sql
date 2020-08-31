SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_default_holiday_calendar]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_default_holiday_calendar]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_default_holiday_calendar]
ON [dbo].[default_holiday_calendar]
FOR UPDATE
AS
    UPDATE default_holiday_calendar
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM default_holiday_calendar t
      INNER JOIN DELETED u ON t.id = u.id
GO
