SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[transfer_mapping]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[transfer_mapping](
    	[transfer_mapping_id]       INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[transfer_mapping_name]     VARCHAR(100) NULL,
    	[create_user]               VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                 DATETIME NULL DEFAULT GETDATE(),
    	[update_user]               VARCHAR(50) NULL,
    	[update_ts]                 DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table transfer_mapping EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_transfer_mapping]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_transfer_mapping]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_transfer_mapping]
ON [dbo].[transfer_mapping]
FOR UPDATE
AS
    UPDATE transfer_mapping
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM transfer_mapping t
      INNER JOIN DELETED u ON t.[transfer_mapping_id] = u.[transfer_mapping_id]
GO