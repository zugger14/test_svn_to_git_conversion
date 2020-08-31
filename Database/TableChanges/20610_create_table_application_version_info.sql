SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[application_version_info]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[application_version_info] (
    	[version_label]				  VARCHAR(300) NULL,
    	[version_color]					  VARCHAR(100) NULL,
    	--
    	[create_user]             VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME NULL DEFAULT GETDATE(),
    	[update_user]             VARCHAR(50) NULL,
    	[update_ts]               DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table application_version_info EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_application_version_info]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_application_version_info]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_application_version_info]
ON [dbo].[application_version_info]
FOR UPDATE
AS
    UPDATE application_version_info
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
GO