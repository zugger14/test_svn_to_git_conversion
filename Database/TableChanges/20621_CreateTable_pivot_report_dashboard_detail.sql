SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[pivot_report_dashboard_detail]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[pivot_report_dashboard_detail](
    	[pivot_report_dashboard_detail_id] INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[dashboard_id]          INT REFERENCES pivot_report_dashboard(pivot_report_dashboard_id) NOT NULL,
    	[cell_id]               VARCHAR(10) NULL,
    	[view_id]               INT REFERENCES pivot_report_view(pivot_report_view_id) NOT NULL,
    	[height_percentage]     INT NOT NULL,
    	[width_percentage]      INT NOT NULL,
    	[create_user]           VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]             DATETIME NULL DEFAULT GETDATE(),
    	[update_user]           VARCHAR(50) NULL,
    	[update_ts]             DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table pivot_report_dashboard_detail EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_pivot_report_dashboard_detail]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_pivot_report_dashboard_detail]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_pivot_report_dashboard_detail]
ON [dbo].[pivot_report_dashboard_detail]
FOR UPDATE
AS
    UPDATE pivot_report_dashboard_detail
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM pivot_report_dashboard_detail t
      INNER JOIN DELETED u ON t.[pivot_report_dashboard_detail_id] = u.[pivot_report_dashboard_detail_id]
GO