
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_load_forecast_source_minor_location]') AND parent_object_id = OBJECT_ID(N'[dbo].[load_forecast]'))
ALTER TABLE [dbo].[load_forecast] DROP CONSTRAINT [FK_load_forecast_source_minor_location]
GO

GO
/****** Object:  Table [dbo].[load_forecast]    Script Date: 06/02/2009 09:28:08 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[load_forecast]') AND type in (N'U'))
DROP TABLE [dbo].[load_forecast]
/****** Object:  Table [dbo].[load_forecast]    Script Date: 06/02/2009 09:28:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[load_forecast](
	[load_forecast_id] [int] IDENTITY(1,1) NOT NULL,
	[location_id] [int] NOT NULL,
	[load_forecast_date] [datetime] NOT NULL,
	[load_forecast_hour] [int] NOT NULL,
	[load_forecast_volume] [float] NOT NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_load_forecast] PRIMARY KEY CLUSTERED 
(
	[load_forecast_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[load_forecast]  WITH CHECK ADD  CONSTRAINT [FK_load_forecast_source_minor_location] FOREIGN KEY([location_id])
REFERENCES [dbo].[source_minor_location] ([source_minor_location_id])
GO
ALTER TABLE [dbo].[load_forecast] CHECK CONSTRAINT [FK_load_forecast_source_minor_location]