SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_ssis_configurations]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_ssis_configurations] (
    	[ixp_ssis_configurations_id]  INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[package_name]                VARCHAR(150) NOT NULL,
    	[package_description]         VARCHAR(500) NOT NULL,
    	[config_filter_value]         VARCHAR(300) NOT NULL,
    	[create_user]                 VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                   DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                 VARCHAR(50) NULL,
    	[update_ts]                   DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_ssis_configurations EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_ssis_configurations]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_ssis_configurations]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_ssis_configurations]
ON [dbo].[ixp_ssis_configurations]
FOR UPDATE
AS
    UPDATE ixp_ssis_configurations
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_ssis_configurations t
      INNER JOIN DELETED u ON t.[ixp_ssis_configurations_id] = u.[ixp_ssis_configurations_id]
GO