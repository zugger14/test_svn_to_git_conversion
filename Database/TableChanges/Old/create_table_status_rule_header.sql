--DROP table [dbo].[status_rule_header]
IF OBJECT_ID(N'[dbo].[status_rule_header]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[status_rule_header]
	(
		[status_rule_id]	INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
		[status_rule_type]	INT ,
		[status_rule_name]	VARCHAR(100),
		[status_rule_desc]	VARCHAR(500),
		[active]			VARCHAR(1),
		[default]			VARCHAR(1),
		[create_user]		VARCHAR(50) DEFAULT dbo.fnadbuser(),
		[create_ts]			DATETIME DEFAULT GETDATE(),
		[update_user]		VARCHAR(50),
		[update_ts]			DATETIME
	)
END
ELSE
BEGIN
    PRINT 'Table status_rule_header EXISTS'
END

GO

IF OBJECT_ID(N'[dbo].[status_rule_detail]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[status_rule_detail]
	(
		[status_rule_detail_id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
		[status_rule_id]		INT REFERENCES status_rule_header(status_rule_id) NOT NULL,
		[event_id]				INT REFERENCES static_data_value(value_id),
		[from_status_id]		INT REFERENCES static_data_value(value_id),
		[to_status_id]			INT REFERENCES static_data_value(value_id),
		[Change_to_status_id]	INT REFERENCES static_data_value(value_id),
		[workflow_activity_id]	INT REFERENCES process_risk_controls(risk_control_id),
		[create_user]			VARCHAR(50) DEFAULT dbo.fnadbuser(),
		[create_ts]				DATETIME DEFAULT GETDATE(),
		[update_user]			VARCHAR(50),
		[update_ts]				DATETIME
	)
END
ELSE
BEGIN
    PRINT 'Table status_rule_detail EXISTS'
END

GO