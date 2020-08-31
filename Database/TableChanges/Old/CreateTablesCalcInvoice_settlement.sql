IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_formula_value_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_formula_value]'))
ALTER TABLE [dbo].[calc_formula_value] DROP CONSTRAINT [FK_calc_formula_value_Calc_Invoice_Volume_variance]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_summary_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_summary]'))
ALTER TABLE [dbo].[calc_invoice_summary] DROP CONSTRAINT [FK_calc_invoice_summary_Calc_Invoice_Volume_variance]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume] DROP CONSTRAINT [FK_calc_invoice_volume_Calc_Invoice_Volume_variance]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]'))
ALTER TABLE [dbo].[calc_invoice_volume] DROP CONSTRAINT [FK_calc_invoice_volume_static_data_value]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_detail_Calc_Invoice_Volume_variance]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_detail]'))
ALTER TABLE [dbo].[calc_invoice_volume_detail] DROP CONSTRAINT [FK_calc_invoice_volume_detail_Calc_Invoice_Volume_variance]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_detail_static_data_value]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_detail]'))
ALTER TABLE [dbo].[calc_invoice_volume_detail] DROP CONSTRAINT [FK_calc_invoice_volume_detail_static_data_value]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_calc_invoice_volume_recorder_source_deal_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]'))
ALTER TABLE [dbo].[calc_invoice_volume_recorder] DROP CONSTRAINT [FK_calc_invoice_volume_recorder_source_deal_detail]
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
--USE [SettlementTracker2_1]
--GO
/****** Object:  Table [dbo].[calc_formula_value]    Script Date: 12/17/2008 16:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_formula_value]') AND type in (N'U'))
DROP TABLE [dbo].[calc_formula_value]
GO
/****** Object:  Table [dbo].[calc_invoice_summary]    Script Date: 12/17/2008 16:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_summary]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_summary]
GO
/****** Object:  Table [dbo].[calc_invoice_volume]    Script Date: 12/17/2008 16:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume]
GO
/****** Object:  Table [dbo].[calc_invoice_volume_detail]    Script Date: 12/17/2008 16:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_detail]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume_detail]
GO
/****** Object:  Table [dbo].[calc_invoice_volume_recorder]    Script Date: 12/17/2008 16:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[calc_invoice_volume_recorder]') AND type in (N'U'))
DROP TABLE [dbo].[calc_invoice_volume_recorder]
GO
/****** Object:  Table [dbo].[Calc_Invoice_Volume_variance]    Script Date: 12/17/2008 16:56:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance]') AND type in (N'U'))
DROP TABLE [dbo].[Calc_Invoice_Volume_variance]
GO

/****** Object:  Table [dbo].[calc_formula_value]    Script Date: 12/17/2008 16:56:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[calc_formula_value](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[invoice_line_item_id] [int] NULL,
	[seq_number] [int] NULL,
	[prod_date] [datetime] NULL,
	[counterparty_id] [int] NULL,
	[contract_id] [int] NULL,
	[value] [float] NULL,
	[formula_id] [int] NULL,
	[calc_id] [int] NULL,
	[hour] [int] NULL,
	[formula_str] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[qtr] [int] NULL,
	[half] [int] NULL,
 CONSTRAINT [PK_calc_formula_value] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[calc_invoice_summary]    Script Date: 12/17/2008 16:56:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[calc_invoice_summary](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[formula_id] [int] NULL,
	[invoice_line_item_id] [int] NULL,
	[seq_number] [int] NULL,
	[prod_date] [datetime] NULL,
	[as_of_date] [datetime] NULL,
	[value] [float] NULL,
	[counterparty_id] [int] NULL,
	[contract_id] [int] NULL,
	[calc_id] [int] NULL,
 CONSTRAINT [PK_calc_invoice_summary] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[calc_invoice_volume]    Script Date: 12/17/2008 16:56:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[calc_invoice_volume](
	[calc_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[calc_id] [int] NULL,
	[invoice_line_item_id] [int] NULL,
	[prod_date] [datetime] NULL,
	[Value] [float] NULL,
	[Volume] [float] NULL,
	[manual_input] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[default_gl_id] [int] NULL,
	[uom_id] [int] NULL,
	[price_or_formula] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[onpeak_offpeak] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[remarks] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[finalized] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[finalized_id] [int] NULL,
	[inv_prod_date] [datetime] NULL,
	[include_volume] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_td] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
	[default_gl_id_estimate] [int] NULL,
	[status] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_calc_invoice_volume] PRIMARY KEY CLUSTERED 
(
	[calc_detail_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[calc_invoice_volume_detail]    Script Date: 12/17/2008 16:56:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[calc_invoice_volume_detail](
	[calc_detail_id] [int] IDENTITY(1,1) NOT NULL,
	[calc_id] [int] NULL,
	[invoice_line_item_id] [int] NULL,
	[prod_date] [datetime] NULL,
	[Value] [float] NULL,
	[hour] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Volume] [float] NULL,
	[price_or_formula] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[formula_str] [varchar](2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
	[qtr] [int] NULL,
	[half] [int] NULL,
 CONSTRAINT [PK_calc_invoice_volume_detail] PRIMARY KEY CLUSTERED 
(
	[calc_detail_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[calc_invoice_volume_recorder]    Script Date: 12/17/2008 16:56:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[calc_invoice_volume_recorder](
	[calc_id] [int] IDENTITY(1,1) NOT NULL,
	[as_of_date] [datetime] NULL,
	[recorderid] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
	[ActualVolume] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[book_entries] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[finalized] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[invoice_id] [int] NULL,
	[deal_id] [int] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
	[original_volume] [float] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Calc_Invoice_Volume_variance]    Script Date: 12/17/2008 16:56:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Calc_Invoice_Volume_variance](
	[calc_id] [int] IDENTITY(1,1) NOT NULL,
	[as_of_date] [datetime] NULL,
	[recorderid] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
	[ActualVolume] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[book_entries] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[finalized] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[invoice_id] [int] NULL,
	[deal_id] [int] NULL,
	[create_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[create_ts] [datetime] NULL,
	[update_user] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[update_ts] [datetime] NULL,
	[estimated] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[calculation_time] [float] NULL,
 CONSTRAINT [PK_Calc_Invoice_Volume_variance] PRIMARY KEY CLUSTERED 
(
	[calc_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[calc_formula_value]  WITH CHECK ADD  CONSTRAINT [FK_calc_formula_value_Calc_Invoice_Volume_variance] FOREIGN KEY([calc_id])
REFERENCES [dbo].[Calc_Invoice_Volume_variance] ([calc_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calc_formula_value] CHECK CONSTRAINT [FK_calc_formula_value_Calc_Invoice_Volume_variance]
GO
ALTER TABLE [dbo].[calc_invoice_summary]  WITH CHECK ADD  CONSTRAINT [FK_calc_invoice_summary_Calc_Invoice_Volume_variance] FOREIGN KEY([calc_id])
REFERENCES [dbo].[Calc_Invoice_Volume_variance] ([calc_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calc_invoice_summary] CHECK CONSTRAINT [FK_calc_invoice_summary_Calc_Invoice_Volume_variance]
GO
ALTER TABLE [dbo].[calc_invoice_volume]  WITH CHECK ADD  CONSTRAINT [FK_calc_invoice_volume_Calc_Invoice_Volume_variance] FOREIGN KEY([calc_id])
REFERENCES [dbo].[Calc_Invoice_Volume_variance] ([calc_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calc_invoice_volume] CHECK CONSTRAINT [FK_calc_invoice_volume_Calc_Invoice_Volume_variance]
GO
ALTER TABLE [dbo].[calc_invoice_volume]  WITH CHECK ADD  CONSTRAINT [FK_calc_invoice_volume_static_data_value] FOREIGN KEY([invoice_line_item_id])
REFERENCES [dbo].[static_data_value] ([value_id])
GO
ALTER TABLE [dbo].[calc_invoice_volume] CHECK CONSTRAINT [FK_calc_invoice_volume_static_data_value]
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
GO
ALTER TABLE [dbo].[calc_invoice_volume_recorder]  WITH CHECK ADD  CONSTRAINT [FK_calc_invoice_volume_recorder_source_deal_detail] FOREIGN KEY([deal_id])
REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calc_invoice_volume_recorder] CHECK CONSTRAINT [FK_calc_invoice_volume_recorder_source_deal_detail]
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
