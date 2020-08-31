IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_forecast_profile_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[forecast_profile]'))
ALTER TABLE [dbo].[forecast_profile] DROP CONSTRAINT [FK_forecast_profile_static_data_value]
GO
/****** Object:  Table [dbo].[forecast_profile]    Script Date: 02/24/2011 14:52:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[forecast_profile]') AND type in (N'U'))
DROP TABLE [dbo].[forecast_profile]
/****** Object:  Table [dbo].[forecast_profile]    Script Date: 02/24/2011 14:52:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[forecast_profile](
	[profile_id] [int] NOT NULL,
	[external_id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[profile_type] [int] IDENTITY(1,1) NOT NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[forecast_profile]  WITH CHECK ADD  CONSTRAINT [FK_forecast_profile_static_data_value] FOREIGN KEY([profile_type])
REFERENCES [dbo].[static_data_value] ([value_id])