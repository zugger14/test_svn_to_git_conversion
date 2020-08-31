SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_ssis_parameters]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_ssis_parameters] (
    	[ixp_ssis_parameters_id]  INT IDENTITY(1, 1) NOT NULL,
    	[ixp_rules_id]            INT REFERENCES ixp_rules(ixp_rules_id) NOT NULL,
    	[parameter_name]          VARCHAR(100) NULL,
    	[parameter_label]         VARCHAR(100) NULL,
    	[operator_id]             INT NULL,
    	[field_type]              CHAR(1) NULL,
    	[default_value]           VARCHAR(200) NULL,
    	[default_value2]          VARCHAR(200) NULL,
    	[create_user]             VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME NULL DEFAULT GETDATE(),
    	[update_user]             VARCHAR(50) NULL,
    	[update_ts]               DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_ssis_parameter EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_ssis_parameters]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_ssis_parameters]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_ssis_parameters]
ON [dbo].[ixp_ssis_parameters]
FOR UPDATE
AS
    UPDATE ixp_ssis_parameters
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_ssis_parameters t
      INNER JOIN DELETED u ON t.[ixp_ssis_parameters_id] = u.[ixp_ssis_parameters_id]
GO