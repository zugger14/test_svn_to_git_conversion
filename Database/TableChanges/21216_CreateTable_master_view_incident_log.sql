SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[master_view_incident_log]', N'U') IS NULL
BEGIN
   CREATE TABLE [dbo].[master_view_incident_log] (
		[master_view_incident_log_id] INT IDENTITY(1, 1) CONSTRAINT PK_master_view_incident_log PRIMARY KEY NOT NULL,
		[incident_log_id]             INT REFERENCES incident_log([incident_log_id]) NOT NULL,
		[incident_type]               VARCHAR(500) NULL,
		[incident_description]        VARCHAR(500) NULL,
		[incident_status]             VARCHAR(500) NULL,
		[buyer_from]                  VARCHAR(500) NULL,
		[seller_to]                   VARCHAR(500) NULL,
		[location]                    VARCHAR(500) NULL,
		[date_initiated]              VARCHAR(500) NULL,
		[date_closed]                 VARCHAR(500) NULL,
		[trader]                      VARCHAR(500) NULL,
		[logistics]                   VARCHAR(500) NULL,
		[corrective_action]           VARCHAR(500) NULL,
		[preventive_action]           VARCHAR(500) NULL,
		[contract]                    VARCHAR(500) NULL,
		[counterparty]                VARCHAR(500) NULL,
		[internal_counterparty]       VARCHAR(500) NULL
	)
END
ELSE
BEGIN
    PRINT 'Table master_view_incident_log EXISTS'
END
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_incident_log]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_incident_log] (
		incident_type, incident_description, incident_status, buyer_from, seller_to, [location], date_initiated, date_closed, trader, logistics, corrective_action, preventive_action, [contract], [counterparty], [internal_counterparty]
	) KEY INDEX PK_master_view_incident_log;
	PRINT 'FULLTEXT INDEX ON master_view_incident_log created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_incident_log Already Exists.'
GO