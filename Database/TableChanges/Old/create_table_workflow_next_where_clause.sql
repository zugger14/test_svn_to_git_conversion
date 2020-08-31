SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[workflow_where_clause]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[workflow_where_clause] (
    	[workflow_where_clause_id]		INT IDENTITY(1, 1) NOT NULL,
    	[module_events_id]              INT NULL,
    	[clause_type]					INT NULL,
    	[column_id]						INT NULL,
    	[operator_id]					INT NULL,
    	[column_value]					VARCHAR(1000) NULL,
    	[second_value]					VARCHAR(1000) NULL,
		[table_id]						INT NULL,
		[column_function]				VARCHAR(1000) NULL,
		[sequence_no]					INT NULL,
    	[create_user]					VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]						DATETIME NULL DEFAULT GETDATE(),
    	[update_user]					VARCHAR(50) NULL,
    	[update_ts]						DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table workflow_where_clause EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_workflow_where_clausee]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_where_clausee]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_workflow_where_clausee]
ON [dbo].[workflow_where_clause]
FOR UPDATE
AS
    UPDATE workflow_where_clause
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_next_where_clause t
      INNER JOIN DELETED u ON t.[workflow_where_clause_id] = u.[workflow_where_clause_id]
GO