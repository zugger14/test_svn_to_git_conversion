delete from calc_invoice_summary
delete from calc_invoice_volume
delete from calc_invoice_volume_detail
delete from calc_formula_value


/****** Object:  Table [dbo].[calc_invoice_volume_variance]    Script Date: 01/05/2009 22:21:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_meter_id]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance] DROP CONSTRAINT [FK_Calc_Invoice_Volume_meter_id]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_rec_generator]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance] DROP CONSTRAINT [FK_Calc_Invoice_Volume_rec_generator]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_variance_source_deal_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance]'))
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance] DROP CONSTRAINT [FK_Calc_Invoice_Volume_variance_source_deal_detail]
GO


IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume] DROP CONSTRAINT [FK_calc_invoice_volume_Calc_Invoice_Volume_variance]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_detail_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_detail]'))
ALTER TABLE [dbo].[calc_invoice_volume_detail] DROP CONSTRAINT [FK_calc_invoice_volume_detail_Calc_Invoice_Volume_variance]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_summary_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_summary]'))
ALTER TABLE [dbo].[calc_invoice_summary] DROP CONSTRAINT [FK_calc_invoice_summary_Calc_Invoice_Volume_variance]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value] DROP CONSTRAINT [FK_calc_formula_value_Calc_Invoice_Volume_variance]
GO





/****** Object:  Table [dbo].[Calc_Invoice_Volume_variance]    Script Date: 01/06/2009 12:58:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance]') AND type in (N'U'))
DROP TABLE [dbo].[Calc_Invoice_Volume_variance]
GO

CREATE TABLE [dbo].[Calc_Invoice_Volume_variance](
	[calc_id] [int] IDENTITY(1,1) NOT NULL,
	[as_of_date] [datetime] NULL,
	[recorderid] [varchar](100) NULL,
	[counterparty_id] [int] NULL,
	[generator_id] [int] NULL,
	[contract_id] [int] NULL,
	[prod_date] [datetime] NULL,
	[metervolume] [float] NULL,
	[invoicevolume] [float] NULL,
	[allocationvolume] [float] NULL,
	[variance] [float] NULL,
	[onpeak_volume] [float] NULL,
	[offpeak_volume] [float] NULL,
	[UOM] [int] NULL,
	[ActualVolume] [char](1) NULL,
	[book_entries] [char](1) NULL,
	[finalized] [char](1) NULL,
	[invoice_id] [int] NULL,
	[deal_id] [int] NULL,
	[create_user] [varchar](50) NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) NULL,
	[update_ts] [datetime] NULL,
	[estimated] [char](1) NULL,
	[calculation_time] [float] NULL,
 CONSTRAINT [PK_Calc_Invoice_Volume_variance] PRIMARY KEY CLUSTERED 
(
	[calc_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance]  WITH CHECK ADD  CONSTRAINT [FK_Calc_Invoice_Volume_meter_id] FOREIGN KEY([recorderid])
REFERENCES [dbo].[meter_id] ([recorderid])
GO
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance] CHECK CONSTRAINT [FK_Calc_Invoice_Volume_meter_id]
GO
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance]  WITH CHECK ADD  CONSTRAINT [FK_Calc_Invoice_Volume_rec_generator] FOREIGN KEY([generator_id])
REFERENCES [dbo].[rec_generator] ([generator_id])
GO
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance] CHECK CONSTRAINT [FK_Calc_Invoice_Volume_rec_generator]
GO
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance]  WITH CHECK ADD  CONSTRAINT [FK_Calc_Invoice_Volume_variance_source_deal_detail] FOREIGN KEY([deal_id])
REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance] CHECK CONSTRAINT [FK_Calc_Invoice_Volume_variance_source_deal_detail]
GO


ALTER TABLE [dbo].[calc_invoice_volume]  WITH CHECK ADD  CONSTRAINT [FK_calc_invoice_volume_Calc_Invoice_Volume_variance] FOREIGN KEY([calc_id])
REFERENCES [dbo].[Calc_Invoice_Volume_variance] ([calc_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calc_invoice_volume_detail]  WITH CHECK ADD  CONSTRAINT [FK_calc_invoice_volume_detail_Calc_Invoice_Volume_variance] FOREIGN KEY([calc_id])
REFERENCES [dbo].[Calc_Invoice_Volume_variance] ([calc_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calc_invoice_summary]  WITH CHECK ADD  CONSTRAINT [FK_calc_invoice_summary_Calc_Invoice_Volume_variance] FOREIGN KEY([calc_id])
REFERENCES [dbo].[Calc_Invoice_Volume_variance] ([calc_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calc_formula_value]  WITH CHECK ADD  CONSTRAINT [FK_calc_formula_value_Calc_Invoice_Volume_variance] FOREIGN KEY([calc_id])
REFERENCES [dbo].[Calc_Invoice_Volume_variance] ([calc_id])
ON DELETE CASCADE
GO