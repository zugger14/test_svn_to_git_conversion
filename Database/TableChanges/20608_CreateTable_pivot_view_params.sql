SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[pivot_view_params]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[pivot_view_params](
    	[pivot_view_params_id]     INT IDENTITY(1, 1) NOT NULL,
    	[view_id]                  INT REFERENCES pivot_report_view(pivot_report_view_id) NOT NULL,
    	[column_id]                INT NULL,
    	[column_name]              VARCHAR(200) NULL,
    	[column_value]             VARCHAR(MAX) NULL,
    	[create_user]              VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                DATETIME NULL DEFAULT GETDATE(),
    	[update_user]              VARCHAR(50) NULL,
    	[update_ts]                DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table pivot_view_params EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_pivot_view_params]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_pivot_view_params]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_pivot_view_params]
ON [dbo].[pivot_view_params]
FOR UPDATE
AS
    UPDATE pivot_view_params
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM pivot_view_params t
      INNER JOIN DELETED u ON t.[pivot_view_params_id] = u.[pivot_view_params_id]
GO