/****** Object:  Table [dbo].[batch_process_notifications]    Script Date: 09/20/2010 12:43:33 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[batch_process_notifications]') AND type in (N'U'))
DROP TABLE [dbo].[batch_process_notifications]
/****** Object:  Table [dbo].[batch_process_notifications]    Script Date: 09/20/2010 12:43:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[batch_process_notifications](
	[notification_id] [int] IDENTITY(1,1) NOT NULL,
	[user_login_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[role_id] [int] NULL,
	[process_id] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[notification_type] [int] NULL,
	[attach_file] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[scheduled] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_user] VARCHAR(50),
	[create_ts] DATETIME	
 CONSTRAINT [PK_batch_process_notifications] PRIMARY KEY CLUSTERED 
(
	[notification_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Trigger [TRGINS_batch_process_notifications]    Script Date: 09/20/2010 16:08:10 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_batch_process_notifications]'))
DROP TRIGGER [dbo].[TRGINS_batch_process_notifications]
/****** Object:  Trigger [TRGINS_batch_process_notifications]    Script Date: 09/20/2010 16:08:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE TRIGGER [TRGINS_batch_process_notifications]
ON [dbo].[batch_process_notifications]
FOR INSERT
AS
UPDATE batch_process_notifications SET create_user =dbo.FNADBUser(), create_ts = getdate() where  batch_process_notifications.notification_id in (select notification_id from inserted)





