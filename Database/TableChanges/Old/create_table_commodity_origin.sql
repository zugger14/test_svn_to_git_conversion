SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[commodity_origin]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table [dbo].[commodity_origin] Already Exists'
END
ELSE
BEGIN
    CREATE TABLE [dbo].commodity_origin
    (
    	[commodity_origin_id]     INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    	source_commodity_id       INT REFERENCES [dbo].[source_commodity] NOT NULL,
    	origin                    INT REFERENCES [dbo].[static_data_value] ([value_id]),
    	[create_user]			  VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME DEFAULT GETDATE(),
    	[update_user]             VARCHAR(100) NULL,
    	[update_ts]               DATETIME NULL
    )

    PRINT 'Table [dbo].[commodity_origin] Successfully Created.'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_commodity_origin]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_commodity_origin]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_commodity_origin]
ON [dbo].[commodity_origin]
FOR UPDATE
AS
    UPDATE commodity_origin
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM commodity_origin o
      INNER JOIN DELETED u ON o.commodity_origin_id = u.commodity_origin_id
GO