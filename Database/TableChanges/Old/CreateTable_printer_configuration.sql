SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[printer_configuration]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[printer_configuration] (
    	[printer_id]           INT IDENTITY(1, 1) NOT NULL,
    	[printer_name]         VARCHAR(100) NULL,
    	[printer_description]  VARCHAR(500) NULL,
    	[create_user]          VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]            DATETIME NULL DEFAULT GETDATE(),
    	[update_user]          VARCHAR(50) NULL,
    	[update_ts]            DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table printer_configuration EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_printer_configuration]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_printer_configuration]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_printer_configuration]
ON [dbo].[printer_configuration]
FOR UPDATE
AS
    UPDATE printer_configuration
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM printer_configuration t
      INNER JOIN DELETED u ON t.printer_id = u.printer_id
GO