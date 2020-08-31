
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_source_price_curve_def_arch2]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_price_curve_arch2]'))
ALTER TABLE [dbo].[source_price_curve_arch2] DROP CONSTRAINT [FK_source_price_curve_source_price_curve_def_arch2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_static_data_value_arch2]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_price_curve_arch2]'))
ALTER TABLE [dbo].[source_price_curve_arch2] DROP CONSTRAINT [FK_source_price_curve_static_data_value_arch2]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_source_price_curve_static_data_value1_arch2]') AND parent_object_id = OBJECT_ID(N'[dbo].[source_price_curve_arch2]'))
ALTER TABLE [dbo].[source_price_curve_arch2] DROP CONSTRAINT [FK_source_price_curve_static_data_value1_arch2]
GO

/****** Object:  Table [dbo].[source_price_curve]    Script Date: 02/17/2011 17:53:43 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[source_price_curve_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[source_price_curve_arch2]
GO
/****** Object:  Table [dbo].[source_price_curve]    Script Date: 02/17/2011 17:53:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[source_price_curve_arch2](
	[source_curve_def_id] [int] NOT NULL,
	[as_of_date] [datetime] NOT NULL,
	[Assessment_curve_type_value_id] [int] NOT NULL,
	[curve_source_value_id] [int] NOT NULL,
	[maturity_date] [datetime] NOT NULL,
	[curve_value] [float] NOT NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[bid_value] [float] NULL,
	[ask_value] [float] NULL,
	[is_dst] [int] NOT NULL CONSTRAINT [DF_source_price_curve_is_dst_arch2]  DEFAULT ((0)),
 CONSTRAINT [PK_source_price_curve_arch2] PRIMARY KEY NONCLUSTERED 
(
	[source_curve_def_id] ASC,
	[as_of_date] ASC,
	[Assessment_curve_type_value_id] ASC,
	[curve_source_value_id] ASC,
	[maturity_date] ASC,
	[is_dst] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[source_price_curve_arch2]  WITH NOCHECK ADD  CONSTRAINT [FK_source_price_curve_source_price_curve_def_arch2] FOREIGN KEY([source_curve_def_id])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
ALTER TABLE [dbo].[source_price_curve_arch2] CHECK CONSTRAINT [FK_source_price_curve_source_price_curve_def_arch2]
GO
ALTER TABLE [dbo].[source_price_curve_arch2]  WITH NOCHECK ADD  CONSTRAINT [FK_source_price_curve_static_data_value_arch2] FOREIGN KEY([Assessment_curve_type_value_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[source_price_curve_arch2] CHECK CONSTRAINT [FK_source_price_curve_static_data_value_arch2]
GO
ALTER TABLE [dbo].[source_price_curve_arch2]  WITH NOCHECK ADD  CONSTRAINT [FK_source_price_curve_static_data_value1_arch2] FOREIGN KEY([curve_source_value_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[source_price_curve_arch2] CHECK CONSTRAINT [FK_source_price_curve_static_data_value1_arch2]