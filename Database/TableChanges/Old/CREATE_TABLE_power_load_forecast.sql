 
/****** Object:  Table [dbo].[power_load_forecast]    Script Date: 03/18/2010 22:00:56 ******/
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_power_load_forecast_source_minor_location]') AND parent_object_id = OBJECT_ID(N'[dbo].[power_load_forecast]'))
ALTER TABLE [dbo].[power_load_forecast] DROP CONSTRAINT [FK_power_load_forecast_source_minor_location]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_power_load_forecast_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[power_load_forecast]'))
ALTER TABLE [dbo].[power_load_forecast] DROP CONSTRAINT [FK_power_load_forecast_static_data_value]
GO

/****** Object:  Table [dbo].[power_load_forecast]    Script Date: 03/22/2010 11:16:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[power_load_forecast]') AND type in (N'U'))
DROP TABLE [dbo].[power_load_forecast]
GO
CREATE TABLE [dbo].[power_load_forecast](
      [load_forecast_id] [int] IDENTITY(1,1) NOT NULL,
      [location_id] [int] NOT NULL,
      [forecast_date] [datetime] NOT NULL,
      [forecast_hour] [int] NOT NULL,
      [granularity_id] [int] NULL,
      [volume] [nchar](10) NOT NULL,
      [price] [nchar](10) NULL,
      [create_user] [varchar](50) NULL,
      [create_ts] [datetime] NULL,
      [update_user] [varchar](50) NULL,
      [update_ts] [datetime] NULL,
 CONSTRAINT [PK_power_load_forecast] PRIMARY KEY CLUSTERED 
(
      [load_forecast_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
 
GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[power_load_forecast]  WITH CHECK ADD  CONSTRAINT [FK_power_load_forecast_source_minor_location] FOREIGN KEY([location_id])
REFERENCES [dbo].[source_minor_location] ([source_minor_location_id])
GO
ALTER TABLE [dbo].[power_load_forecast] CHECK CONSTRAINT [FK_power_load_forecast_source_minor_location]
GO
ALTER TABLE [dbo].[power_load_forecast]  WITH CHECK ADD  CONSTRAINT [FK_power_load_forecast_static_data_value] FOREIGN KEY([granularity_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[power_load_forecast] CHECK CONSTRAINT [FK_power_load_forecast_static_data_value]
