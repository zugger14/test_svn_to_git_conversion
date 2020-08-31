IF OBJECT_ID('[dbo].[clr_error_log]') IS NULL
BEGIN
    CREATE TABLE [dbo].[clr_error_log]
    (
    	clr_error_log_id            INT PRIMARY KEY IDENTITY(1, 1),
    	[event_log_description]     NVARCHAR(1024),
    	[assembly_method]           NVARCHAR(512),
    	[object_name]               NVARCHAR(512),
    	[message]                   NVARCHAR(MAX),
    	[inner_exception]           NVARCHAR(MAX),
    	[stack_trace]               NVARCHAR(1024),
    	[log_date]                  DATETIME,
    	[user_name]                 NVARCHAR(255),
    	[param]                     NVARCHAR(1024),
    	[step_sequence]             INT,
    	[step_description]          NVARCHAR(1024),
    	[process_id]                NVARCHAR(255)
    )
END
ELSE
    PRINT 'clr_error_log table already exists'