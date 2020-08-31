
/****** Object:  Table [dbo].[expected_return]    Script Date: 05/18/2009 16:28:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[expected_return](
	[expected_return_id] [int] IDENTITY(1,1) NOT NULL,
	[as_of_date] [datetime] NULL,
	[curve_id] [int] NULL,
	[term] [datetime] NULL,
	[curve_source_value_id] [int] NULL,
	[value] [float] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[expected_return]  WITH CHECK ADD  CONSTRAINT [FK_expected_return_source_price_curve_def] FOREIGN KEY([curve_id])
REFERENCES [dbo].[source_price_curve_def] ([source_curve_def_id])
GO
ALTER TABLE [dbo].[expected_return] CHECK CONSTRAINT [FK_expected_return_source_price_curve_def]
GO
ALTER TABLE [dbo].[expected_return]  WITH CHECK ADD  CONSTRAINT [FK_expected_return_static_data_value] FOREIGN KEY([curve_source_value_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[expected_return] CHECK CONSTRAINT [FK_expected_return_static_data_value]