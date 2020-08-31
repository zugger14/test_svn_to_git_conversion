go
IF OBJECT_ID('[dbo].[report_writer_view_users]') IS NOT NULL
DROP TABLE [dbo].[report_writer_view_users]

GO
CREATE TABLE [dbo].[report_writer_view_users](
	[functional_users_id] [int] IDENTITY(1,1) NOT NULL,
	[function_id] [int] NOT NULL,
	[role_id] [int] NULL,
	[login_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	--[role_user_flag] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[entity_id] [int] NULL,
	[create_user] [varchar](50) CONSTRAINT [DF_create_user_report_writer_view_users]  DEFAULT (dbo.FNADBUser()),
	[create_ts] [datetime] CONSTRAINT [DF_create_ts_report_writer_view_users]  DEFAULT (getdate()),
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_report_writer_view_users] PRIMARY KEY NONCLUSTERED 
(
	[functional_users_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[report_writer_view_users]  WITH NOCHECK ADD  CONSTRAINT [FK_report_writer_view_users_application_security_role] FOREIGN KEY([role_id])
REFERENCES [dbo].[application_security_role] ([role_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[report_writer_view_users] CHECK CONSTRAINT [FK_report_writer_view_users_application_security_role]
GO
ALTER TABLE [dbo].[report_writer_view_users]  WITH NOCHECK ADD  CONSTRAINT [FK_report_writer_view_users_application_users] FOREIGN KEY([login_id])
REFERENCES [dbo].[application_users] ([user_login_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[report_writer_view_users] CHECK CONSTRAINT [FK_report_writer_view_users_application_users]
GO
ALTER TABLE [dbo].[report_writer_view_users]  WITH NOCHECK ADD  CONSTRAINT [FK_report_writer_view_users_portfolio_hierarchy] FOREIGN KEY([entity_id])
REFERENCES [dbo].[portfolio_hierarchy] ([entity_id])
GO
ALTER TABLE [dbo].[report_writer_view_users] CHECK CONSTRAINT [FK_report_writer_view_users_portfolio_hierarchy]

GO



INSERT INTO   [dbo].[application_functions]
           ([function_id]
           ,[function_name]
           ,[function_desc]
           ,[func_ref_id]
)
     VALUES
           (536
           ,'Report Writer View'
           ,'Report Writer View'
           ,306
     )