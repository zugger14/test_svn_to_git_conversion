SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[commodity_form_attribute1]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table [dbo].[commodity_form_attribute1] Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].commodity_form_attribute1
    (
    	[commodity_form_attribute1_id]		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    	commodity_form_id					INT REFERENCES [dbo].[commodity_form]([commodity_form_id]) ON DELETE CASCADE NOT NULL,
    	attribute_id						INT REFERENCES [dbo].[commodity_attribute] ([commodity_attribute_id]),
		attribute_form_id					INT REFERENCES [dbo].[commodity_attribute_form] ([commodity_attribute_form_id]),
    	[create_user]						VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]							DATETIME DEFAULT GETDATE(),
    	[update_user]						VARCHAR(100) NULL,
    	[update_ts]							DATETIME NULL
    )

    PRINT 'Table [dbo].[commodity_form_attribute1] Successfully Created.'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_commodity_form_attribute1]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_commodity_form_attribute1]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_commodity_form_attribute1]
ON [dbo].[commodity_form_attribute1]
FOR UPDATE
AS
    UPDATE commodity_form_attribute1
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM commodity_form_attribute1 o
      INNER JOIN DELETED u ON o.commodity_form_attribute1_id = u.commodity_form_attribute1_id
GO