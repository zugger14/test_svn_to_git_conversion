SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'[dbo].[expiration_calendar]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[expiration_calendar] (
    	[expiration_calendar_id]		INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[calendar_id]					INT NOT NULL FOREIGN KEY ([calendar_id])  REFERENCES [dbo].[static_data_value] ([value_id]) ON UPDATE  NO ACTION 
         ON DELETE CASCADE ,
		[holiday_calendar]              INT NULL,
    	[delivery_period]			    DATETIME NULL,
    	[expiration_from]				DATETIME NULL,
		[expiration_to]					DATETIME NULL, 
    	[create_user]                   VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                     DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                   VARCHAR(50) NULL,
    	[update_ts]                     DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table expiration_calendar exists'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_expiration_calendar]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_expiration_calendar]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_expiration_calendar]
ON [dbo].[expiration_calendar]
FOR UPDATE
AS
    UPDATE expiration_calendar
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM expiration_calendar t
      INNER JOIN DELETED u ON t.[expiration_calendar_id] = u.[expiration_calendar_id]
GO