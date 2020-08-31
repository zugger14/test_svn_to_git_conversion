SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[workflow_activities_audit_summary]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[workflow_activities_audit_summary] (
    	[workflow_activities_audit_summary_id]  INT IDENTITY(1, 1) NOT NULL,
    	[risk_control_activity_audit_id]		INT,
    	[source_name]                           VARCHAR(400) NULL,
    	[source_id]                             VARCHAR(50) NULL,
    	[activity_name]                         VARCHAR(5000) NULL,
    	[activity_detail]                       VARCHAR(MAX) NULL,
    	[run_as_of_date]                        VARCHAR(MAX) NULL,
    	[prior_status]                          VARCHAR(400) NULL,
    	[current_status]                        VARCHAR(400) NULL,
    	[activity_description]                  VARCHAR(5000) NULL,
    	[run_by]                                VARCHAR(400) NULL,
    	[activity_create_date]                  VARCHAR(400) NULL,
    	[create_user]                           VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                             DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                           VARCHAR(50) NULL,
    	[update_ts]                             DATETIME NULL
     CONSTRAINT [PK_workflow_activities_audit_summary] PRIMARY KEY CLUSTERED 
	(
		[workflow_activities_audit_summary_id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table workflow_activities_audit_summary EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_workflow_activities_audit_summary]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_activities_audit_summary]
GO

 
CREATE TRIGGER [dbo].[TRGUPD_workflow_activities_audit_summary]
ON [dbo].[workflow_activities_audit_summary]
FOR UPDATE
AS
    UPDATE workflow_activities_audit_summary
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_activities_audit_summary t
      INNER JOIN DELETED u ON t.[workflow_activities_audit_summary_id] = u.[workflow_activities_audit_summary_id]
GO