--DROP TABLE [dbo].[message_log_template]

IF OBJECT_ID('[dbo].[message_log_template]') IS NULL
BEGIN
	CREATE TABLE [dbo].[message_log_template](
		[id] [int] IDENTITY(1,1) NOT NULL,
		[message_number] INT,
		[message_status] VARCHAR(100),
		[message_type] VARCHAR(1000),
		[message] VARCHAR(5000),
		[recommendation] VARCHAR(3000),
		[create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts] DATETIME NULL DEFAULT GETDATE()
)
END
ELSE
    PRINT 'Table message_log_template Already Exists'