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

/****** Object:  Table [dbo].[location_price_index]    Script Date: 05/22/2009 12:16:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[location_price_index]') AND type in (N'U'))
DROP TABLE [dbo].[location_price_index]
GO
/****** Object:  Table [dbo].[location_price_index]    Script Date: 05/22/2009 12:16:30 ******/
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
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
 CONSTRAINT [PK_location_price_index] PRIMARY KEY CLUSTERED 
(
	[location_price_index_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[location_price_index]  WITH CHECK ADD  CONSTRAINT [FK_location_price_index_source_minor_location] FOREIGN KEY([location_id])
REFERENCES [dbo].[source_minor_location] ([source_minor_location_id])
GO
ALTER TABLE [dbo].[location_price_index]  WITH CHECK ADD  CONSTRAINT [FK_location_price_index_source_price_curve_def] FOREIGN KEY([curve_id])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
ALTER TABLE [dbo].[location_price_index]  WITH CHECK ADD  CONSTRAINT [FK_location_price_index_static_data_value] FOREIGN KEY([product_type_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[location_price_index]  WITH CHECK ADD  CONSTRAINT [FK_location_price_index_static_data_value1] FOREIGN KEY([price_type_id])
REFERENCES [dbo].[static_data_value] ([value_id])