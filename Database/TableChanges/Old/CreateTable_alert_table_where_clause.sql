SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[alert_table_where_clause]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[alert_table_where_clause] (
    	[alert_table_where_clause_id]  INT IDENTITY(1, 1) NOT NULL,
    	[alert_id]                     VARCHAR(100) NULL,
    	[clause_type]                  INT NULL,
    	[column_id]                    INT NULL,
    	[operator_id]                  INT NULL,
    	[column_value]                 VARCHAR(1000) NULL,
    	[second_value]                 VARCHAR(1000) NULL,
    	[create_user]                  VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                    DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                  VARCHAR(50) NULL,
    	[update_ts]                    DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table alert_table_where_clause EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_alert_table_where_clause]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_alert_table_where_clause]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_alert_table_where_clause]
ON [dbo].[alert_table_where_clause]
FOR UPDATE
AS
    UPDATE alert_table_where_clause
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM alert_table_where_clause t
      INNER JOIN DELETED u ON t.[alert_table_where_clause_id] = u.[alert_table_where_clause_id]
GO