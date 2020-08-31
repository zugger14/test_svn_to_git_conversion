SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[pivot_report_view_columns]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[pivot_report_view_columns](
    	[pivot_report_view_columns_id]     INT IDENTITY(1, 1) NOT NULL,
    	[pivot_report_view_id]             INT REFERENCES pivot_report_view(pivot_report_view_id) NOT NULL,
    	[columns_name]                     VARCHAR(100) NULL,
    	[columns_position]                 CHAR(1) NULL,
    	[label]                            VARCHAR(50) NULL,
    	[render_as]                        CHAR(1) NULL,
    	[date_format]                      VARCHAR(50) NULL,
    	[currency]                         CHAR(1) NULL,
    	[thou_sep]                         CHAR(1) NULL,
    	[rounding]                         INT NULL,
    	[neg_as_red]                       CHAR(1) NULL,
    	[create_user]                      VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                        DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                      VARCHAR(50) NULL,
    	[update_ts]                        DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table pivot_report_view_columns EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_pivot_report_view_columns]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_pivot_report_view_columns]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_pivot_report_view_columns]
ON [dbo].[pivot_report_view_columns]
FOR UPDATE
AS
    UPDATE pivot_report_view_columns
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM pivot_report_view_columns t
      INNER JOIN DELETED u ON t.[pivot_report_view_columns_id] = u.[pivot_report_view_columns_id]
GO