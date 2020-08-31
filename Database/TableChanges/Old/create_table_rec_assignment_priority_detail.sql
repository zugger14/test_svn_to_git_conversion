SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[rec_assignment_priority_detail]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].rec_assignment_priority_detail
    (
    	[rec_assignment_priority_detail_id]  INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[rec_assignment_priority_group_id]   INT REFERENCES 
    		rec_assignment_priority_group(rec_assignment_priority_group_id) NOT NULL,
    	[priority_type]                      INT NOT NULL,
    	[create_user]                        VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                          DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                        VARCHAR(50) NULL,
    	[update_ts]                          DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table rec_assignment_priority_detail already EXISTS.'
END
 
GO