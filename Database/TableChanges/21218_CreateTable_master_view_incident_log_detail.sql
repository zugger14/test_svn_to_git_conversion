SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[master_view_incident_log_detail]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[master_view_incident_log_detail] (
		[master_view_incident_log_detail_id] INT IDENTITY(1, 1) CONSTRAINT PK_master_view_incident_log_detail PRIMARY KEY NOT NULL,
		[incident_log_detail_id]             INT REFERENCES incident_log_detail([incident_log_detail_id]) NOT NULL,
		[incident_log_id]                    INT REFERENCES incident_log([incident_log_id]) NOT NULL,
		[incident_status]                    VARCHAR(500) NULL,
		[incident_update_date]               VARCHAR(500) NULL,
		[comments]                           VARCHAR(2000) NULL
	)
END
ELSE
BEGIN
    PRINT 'Table master_view_incident_log_detail EXISTS'
END
 
GO


SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_incident_log_detail]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_incident_log_detail] (
		incident_status,incident_update_date,comments
	) KEY INDEX PK_master_view_incident_log_detail;
	PRINT 'FULLTEXT INDEX ON master_view_incident_log_detail created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_incident_log_detail Already Exists.'
GO