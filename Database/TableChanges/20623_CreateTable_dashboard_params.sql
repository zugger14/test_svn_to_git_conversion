SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[dashboard_params]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[dashboard_params](
    	[dashboard_params_id]     INT IDENTITY(1, 1) NOT NULL,
    	[dashboard_id]            INT REFERENCES pivot_report_dashboard(pivot_report_dashboard_id) NOT NULL,
    	[param_name]              VARCHAR(500) NULL,
    	[param_value]             VARCHAR(MAX) NULL,
    	[param_type]              INT NULL,
    	[create_user]             VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME NULL DEFAULT GETDATE(),
    	[update_user]             VARCHAR(50) NULL,
    	[update_ts]               DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table dashboard_params EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_dashboard_params]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_dashboard_params]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_dashboard_params]
ON [dbo].[dashboard_params]
FOR UPDATE
AS
    UPDATE dashboard_params
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM dashboard_params t
      INNER JOIN DELETED u ON t.[dashboard_params_id] = u.[dashboard_params_id]
GO