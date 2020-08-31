SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[pivot_report_view]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[pivot_report_view](
    	[pivot_report_view_id]       INT IDENTITY(1, 1) NOT NULL,
    	[pivot_report_view_name]     VARCHAR(100) NULL,
    	[paramset_hash]				 VARCHAR(100) NULL,
    	[renderer]					 VARCHAR(100) NULL,
    	[row_fields]                 VARCHAR(MAX) NULL,
    	[columns_fields]             VARCHAR(MAX) NULL,
    	[detail_fields]              VARCHAR(MAX) NULL,
    	[create_user]				 VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                  DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                VARCHAR(50) NULL,
    	[update_ts]                  DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table pivot_report_view EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_pivot_report_view]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_pivot_report_view]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_pivot_report_view]
ON [dbo].[pivot_report_view]
FOR UPDATE
AS
    UPDATE pivot_report_view
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM pivot_report_view t
      INNER JOIN DELETED u ON t.[pivot_report_view_id] = u.[pivot_report_view_id]
GO