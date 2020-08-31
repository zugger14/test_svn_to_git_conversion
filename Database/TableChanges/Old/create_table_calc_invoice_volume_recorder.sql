/****** Object:  Table [dbo].[calc_invoice_volume_recorder]    Script Date: 01/05/2009 22:21:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
DROP TABLE [dbo].[calc_invoice_volume_recorder]
GO

CREATE TABLE [dbo].[calc_invoice_volume_recorder](
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
	[original_volume] [float] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[calc_invoice_volume_recorder]  WITH CHECK ADD  CONSTRAINT [FK_calc_invoice_volume_recorder_source_deal_detail] FOREIGN KEY([deal_id])
REFERENCES [dbo].[source_deal_detail] ([source_deal_detail_id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[calc_invoice_volume_recorder] CHECK CONSTRAINT [FK_calc_invoice_volume_recorder_source_deal_detail]
