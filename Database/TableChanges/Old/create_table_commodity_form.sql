SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[commodity_form]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table [dbo].[commodity_form] Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].commodity_form
    (
    	[commodity_form_id]     INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    	commodity_origin_id		INT REFERENCES [dbo].[commodity_origin]([commodity_origin_id]) ON DELETE CASCADE NOT NULL,
    	form					INT REFERENCES [dbo].[commodity_type_form] ([commodity_type_form_id]),
    	[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]             DATETIME DEFAULT GETDATE(),
    	[update_user]           VARCHAR(100) NULL,
    	[update_ts]             DATETIME NULL
    )

    PRINT 'Table [dbo].[commodity_form] Successfully Created.'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_commodity_form]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_commodity_form]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_commodity_form]
ON [dbo].[commodity_form]
FOR UPDATE
AS
    UPDATE commodity_form
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM commodity_form o
      INNER JOIN DELETED u ON o.commodity_form_id = u.commodity_form_id
GO