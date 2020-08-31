IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_transportation_rate_schedule_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[transportation_rate_schedule]'))
ALTER TABLE [dbo].[transportation_rate_schedule] DROP CONSTRAINT [FK_transportation_rate_schedule_static_data_value]

GO
/****** Object:  Table [dbo].[transportation_rate_schedule]    Script Date: 04/02/2009 12:47:09 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[transportation_rate_schedule]') AND type in (N'U'))
DROP TABLE [dbo].[transportation_rate_schedule]

GO
/****** Object:  Table [dbo].[transportation_rate_schedule]    Script Date: 04/02/2009 12:43:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[transportation_rate_schedule](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[rate_schedule_id] [int] NULL,
	[rate_type_id] [int] NULL,
	[rate] [float] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_transportation_rate_schedule] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF

GO
ALTER TABLE [dbo].[transportation_rate_schedule]  WITH CHECK ADD  CONSTRAINT [FK_transportation_rate_schedule_static_data_value] FOREIGN KEY([rate_schedule_id])
REFERENCES [dbo].[rate_schedule] ([id])