CREATE TABLE [dbo].[source_deal_error_log](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[as_of_date] [datetime] NOT NULL,
	[deal_id] [varchar](250) NOT NULL,
	[source] [varchar](255) NULL,
	[error_type_id] [int] NOT NULL,
	[error_description] [varchar](500) NULL,
	[create_user] [varchar](200) NOT NULL CONSTRAINT [DF_source_deal_error_log_create_user]  DEFAULT ([dbo].[FNADBUser]()),
	[create_ts] [datetime] NOT NULL CONSTRAINT [DF_source_deal_error_log_create_ts]  DEFAULT (getdate()),
 CONSTRAINT [PK_source_deal_error_log] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[source_deal_error_log]  WITH CHECK ADD  CONSTRAINT [FK_source_deal_error_log_source_deal_error_types] FOREIGN KEY([error_type_id])
REFERENCES [dbo].[source_deal_error_types] ([error_type_id])
GO
ALTER TABLE [dbo].[source_deal_error_log] CHECK CONSTRAINT [FK_source_deal_error_log_source_deal_error_types]
GO     