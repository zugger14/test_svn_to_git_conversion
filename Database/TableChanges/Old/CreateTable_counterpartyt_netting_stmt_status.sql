SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[counterpartyt_netting_stmt_status]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[counterpartyt_netting_stmt_status] (
    	[netting_stmt_status_id]           INT IDENTITY(1, 1) NOT NULL,
    	[calc_id]						   INT NOT NULL,
    	[status_id]						   INT NOT NULL,
    	[create_user]					   VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]						   DATETIME NULL DEFAULT GETDATE(),
    	[update_user]					   VARCHAR(50) NULL,
    	[update_ts]						   DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table counterpartyt_netting_stmt_status EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGINS_counterpartyt_netting_stmt_status]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_counterpartyt_netting_stmt_status]
GO
 
CREATE TRIGGER [dbo].[TRGINS_counterpartyt_netting_stmt_status]
ON [dbo].[counterpartyt_netting_stmt_status]
FOR INSERT
AS
    UPDATE counterpartyt_netting_stmt_status
       SET create_user = dbo.FNADBUser(),
           create_ts = GETDATE()
    FROM counterpartyt_netting_stmt_status t
    INNER JOIN INSERTED u ON t.netting_stmt_status_id = u.netting_stmt_status_id
 
GO
   
IF OBJECT_ID('[dbo].[TRGUPD_counterpartyt_netting_stmt_status]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_counterpartyt_netting_stmt_status]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_counterpartyt_netting_stmt_status]
ON [dbo].[counterpartyt_netting_stmt_status]
FOR UPDATE
AS
    UPDATE counterpartyt_netting_stmt_status
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM counterpartyt_netting_stmt_status t
      INNER JOIN DELETED u ON t.netting_stmt_status_id = u.netting_stmt_status_id
GO