IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[import_data_request_status_log]') AND type in (N'U'))

CREATE TABLE [dbo].[import_data_request_status_log](
	[import_status_id] [INT] IDENTITY NOT NULL,
	[request_id] [INT]  NOT NULL,
	[process_id] [VARCHAR](50) NULL,
	[module_type] [VARCHAR](50) NULL,
	[request_file_name] [VARCHAR] (255) NULL,
	[request_time] [DATETIME] NULL,
	[request_string] [VARCHAR] (1000) NULL,
	[response_time] [DATETIME] NULL,
	[response_file_name] [VARCHAR] (255) NULL,
	[response_status] [VARCHAR] (32) NULL,
	[description] [VARCHAR] (255) NULL,
	[key_value] [VARCHAR] (50) NULL,
	[as_of_date] [DATETIME] NULL,
	[data_file_name] [VARCHAR] (255) NULL,
	[data_update_time] [DATETIME] NULL,
	[data_update_status] [VARCHAR] (32) NULL
 CONSTRAINT [PK_import_status_id] PRIMARY KEY CLUSTERED 
(
	[import_status_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF