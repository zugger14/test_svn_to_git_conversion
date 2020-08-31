
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_location_price_index_source_minor_location]') AND parent_object_id = OBJECT_ID(N'[dbo].[location_price_index]'))
ALTER TABLE [dbo].[location_price_index] DROP CONSTRAINT [FK_location_price_index_source_minor_location]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_location_price_index_source_price_curve_def]') AND parent_object_id = OBJECT_ID(N'[dbo].[location_price_index]'))
ALTER TABLE [dbo].[location_price_index] DROP CONSTRAINT [FK_location_price_index_source_price_curve_def]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_location_price_index_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[location_price_index]'))
ALTER TABLE [dbo].[location_price_index] DROP CONSTRAINT [FK_location_price_index_static_data_value]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_location_price_index_static_data_value1]') AND parent_object_id = OBJECT_ID(N'[dbo].[location_price_index]'))
ALTER TABLE [dbo].[location_price_index] DROP CONSTRAINT [FK_location_price_index_static_data_value1]
GO
/****** Object:  Table [dbo].[location_price_index]    Script Date: 05/18/2009 16:15:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[location_price_index]') AND type in (N'U'))
DROP TABLE [dbo].[location_price_index]
/****** Object:  Table [dbo].[location_price_index]    Script Date: 05/18/2009 16:15:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[location_price_index](
	[location_price_index_id] [int] IDENTITY(1,1) NOT NULL,
	[location_id] [int] NOT NULL,
	[product_type_id] [int] NOT NULL,
	[price_type_id] [int] NOT NULL,
	[curve_id] [int] NOT NULL,
	[create_user] [varchar](50) NOT NULL,
	[create_ts] [datetime] NOT NULL,
	[update_user] [varchar](50) NOT NULL,
	[update_ts] [datetime] NOT NULL,
 CONSTRAINT [PK_location_price_index] PRIMARY KEY CLUSTERED 
(
	[location_price_index_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[location_price_index]  WITH CHECK ADD  CONSTRAINT [FK_location_price_index_source_minor_location] FOREIGN KEY([location_id])
REFERENCES [dbo].[source_minor_location] ([source_minor_location_id])
GO
ALTER TABLE [dbo].[location_price_index] CHECK CONSTRAINT [FK_location_price_index_source_minor_location]
GO
ALTER TABLE [dbo].[location_price_index]  WITH CHECK ADD  CONSTRAINT [FK_location_price_index_source_price_curve_def] FOREIGN KEY([curve_id])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
ALTER TABLE [dbo].[location_price_index] CHECK CONSTRAINT [FK_location_price_index_source_price_curve_def]
GO
ALTER TABLE [dbo].[location_price_index]  WITH CHECK ADD  CONSTRAINT [FK_location_price_index_static_data_value] FOREIGN KEY([product_type_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[location_price_index] CHECK CONSTRAINT [FK_location_price_index_static_data_value]
GO
ALTER TABLE [dbo].[location_price_index]  WITH CHECK ADD  CONSTRAINT [FK_location_price_index_static_data_value1] FOREIGN KEY([price_type_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[location_price_index] CHECK CONSTRAINT [FK_location_price_index_static_data_value1]