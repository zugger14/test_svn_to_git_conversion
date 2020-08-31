/****** Object:  Table [dbo].[calc_invoice_volume_detail]    Script Date: 01/05/2009 22:21:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
DROP TABLE [dbo].[calc_invoice_volume_detail]
GO

CREATE TABLE [dbo].[calc_invoice_volume_detail](
	[calc_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[calc_id] [int] NULL,
	[invoice_line_item_id] [int] NULL,
	[prod_date] [datetime] NULL,
	[Value] [float] NULL,
	[hour] [varchar](50) NULL,
	[Volume] [float] NULL,
	[price_or_formula] [char](1) NULL,
	[formula_str] [varchar](2000) NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[qtr] [int] NULL,
	[half] [int] NULL,
	[deal_id] [int] NULL,
 CONSTRAINT [PK_calc_invoice_volume_detail] PRIMARY KEY CLUSTERED 
(
	[calc_detail_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[calc_invoice_volume_detail]  WITH CHECK ADD  CONSTRAINT [FK_calc_invoice_volume_detail_Calc_Invoice_Volume_variance] FOREIGN KEY([calc_id])
REFERENCES [dbo].[Calc_Invoice_Volume_variance] ([calc_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calc_invoice_volume_detail] CHECK CONSTRAINT [FK_calc_invoice_volume_detail_Calc_Invoice_Volume_variance]
GO
ALTER TABLE [dbo].[calc_invoice_volume_detail]  WITH CHECK ADD  CONSTRAINT [FK_calc_invoice_volume_detail_static_data_value] FOREIGN KEY([invoice_line_item_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[calc_invoice_volume_detail] CHECK CONSTRAINT [FK_calc_invoice_volume_detail_static_data_value]

