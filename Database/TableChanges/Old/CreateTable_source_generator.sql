--################ 
-- source_generator table
----##############

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_generator_source_minor_location]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_generator]'))
ALTER TABLE [dbo].[source_generator] DROP CONSTRAINT [FK_source_generator_source_minor_location]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_generator_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_generator]'))
ALTER TABLE [dbo].[source_generator] DROP CONSTRAINT [FK_source_generator_static_data_value]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_generator_static_data_value1]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_generator]'))
ALTER TABLE [dbo].[source_generator] DROP CONSTRAINT [FK_source_generator_static_data_value1]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_generator_static_data_value2]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_generator]'))
ALTER TABLE [dbo].[source_generator] DROP CONSTRAINT [FK_source_generator_static_data_value2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_generator_static_data_value3]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_generator]'))
ALTER TABLE [dbo].[source_generator] DROP CONSTRAINT [FK_source_generator_static_data_value3]
GO

/****** Object:  Table [dbo].[source_generator]    Script Date: 05/15/2009 10:43:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_generator]') AND type in (N'U'))
DROP TABLE [dbo].[source_generator]
GO
/****** Object:  Table [dbo].[source_generator]    Script Date: 05/15/2009 10:43:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[source_generator](
		[source_generator_id] [int] IDENTITY(1,1) NOT NULL,
		[generator_id] [varchar](50) NOT NULL,
		[generator_name] [varchar](100) NOT NULL,
		[generator_desc] [varchar](100) NULL,
		[generator_owner] [varchar](100) NULL,
		[generator_capacity] [varchar](20) NULL,
		[generator_start_date] [datetime] NULL,
		[technology] [int] NULL,
		[fuel_type] [int] NULL,
		[facility_address1] [varchar](100) NULL,
		[facility_address2] [varchar](100) NULL,
		[facility_phone] [varchar](20) NULL,
		[facility_email_address] [varchar](50) NULL,
		[facility_country] [varchar](50) NULL,
		[facility_city] [varchar](50) NULL,
		[generation_state] [int] NOT NULL,
		[location_id] [int] NOT NULL,
		[max_rampup_rate] [varchar](20) NULL,
		[max_rampdown_rate] [varchar](20) NULL,
		[upper_operating_limit] [varchar](20) NULL,
		[lower_operating_limit] [varchar](20) NULL,
		[max_response_level] [varchar](20) NULL,
		[max_interrupts] [varchar](20) NULL,
		[max_dispatch_level] [varchar](20) NULL,
		[min_dispatch_level] [varchar](20) NULL,
		[must_run_unit] [char](1) NULL,
		[generator_group_id] [int] NULL,
		[create_user] [varchar](50) NOT NULL,
		[create_ts] [datetime] NOT NULL,
		[update_user] [varchar](50) NOT NULL,
	[update_ts] [datetime] NOT NULL,
 CONSTRAINT [PK_source_generator] PRIMARY KEY CLUSTERED 
(
	[source_generator_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[source_generator]  WITH CHECK ADD  CONSTRAINT [FK_source_generator_source_minor_location] FOREIGN KEY([location_id])
REFERENCES [dbo].[source_minor_location] ([source_minor_location_id])
GO
ALTER TABLE [dbo].[source_generator] CHECK CONSTRAINT [FK_source_generator_source_minor_location]
GO
ALTER TABLE [dbo].[source_generator]  WITH CHECK ADD  CONSTRAINT [FK_source_generator_static_data_value] FOREIGN KEY([technology])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[source_generator] CHECK CONSTRAINT [FK_source_generator_static_data_value]
GO
ALTER TABLE [dbo].[source_generator]  WITH CHECK ADD  CONSTRAINT [FK_source_generator_static_data_value1] FOREIGN KEY([fuel_type])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[source_generator] CHECK CONSTRAINT [FK_source_generator_static_data_value1]
GO
ALTER TABLE [dbo].[source_generator]  WITH CHECK ADD  CONSTRAINT [FK_source_generator_static_data_value2] FOREIGN KEY([generation_state])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[source_generator] CHECK CONSTRAINT [FK_source_generator_static_data_value2]
GO
