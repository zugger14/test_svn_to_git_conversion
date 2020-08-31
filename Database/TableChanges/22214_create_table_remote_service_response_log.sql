SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[remote_service_response_log]', N'U') IS NULL
BEGIN
	 CREATE TABLE [dbo].[remote_service_response_log] (
		[remote_service_response_log_id] INT IDENTITY(1, 1) NOT NULL
		, [remote_service_type_id] INT	
  		, [response_status] VARCHAR(200)
  		, [response_message] NVARCHAR(MAX)	
  		, [process_id] VARCHAR(80)
  		, [request_identifier] VARCHAR(MAX)
  		, [response_file_name] VARCHAR(80)
		, [response_msg_detail] VARCHAR(MAX)
		, [request_msg_detail] NVARCHAR(MAX)
		, [export_web_service_id] INT 
  		, [create_user] VARCHAR(50) NULL DEFAULT dbo.FNADBUser()
		, [create_ts]  DATETIME NULL DEFAULT GETDATE()
		FOREIGN KEY (remote_service_type_id) REFERENCES static_data_value(value_id)
	)
END
ELSE
BEGIN
    PRINT 'Table remote_service_response_log EXISTS'
END

IF OBJECT_ID('FK_remote_service_response_log_export_web_service') IS NULL
	ALTER TABLE [dbo].[remote_service_response_log] WITH NOCHECK ADD CONSTRAINT [FK_remote_service_response_log_export_web_service] FOREIGN KEY([export_web_service_id]) REFERENCES [dbo].[export_web_service] ([Id])
GO
	