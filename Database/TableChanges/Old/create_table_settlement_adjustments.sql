if object_id('[dbo].[settlement_adjustments]','u') is not null
	drop table [dbo].[settlement_adjustments]
go

CREATE TABLE [dbo].[settlement_adjustments](
	[calc_id] [int] NOT NULL,
	[counterparty_id] [int] NULL,
	[counterparty_name] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[code] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[invoice_line_item_id] [int] NOT NULL,
	[prod_date] [datetime] NULL,
	[allocationvolume_old] [float] NULL,
	[allocationvolume_new] [float] NULL,
	[value_old] [float] NULL,
	[value_new] [float] NULL,
	[volume_diff] [float] NULL,
	[value_diff] [float] NULL,
 CONSTRAINT [PK_settlement_adjustments] PRIMARY KEY CLUSTERED 
(
	[calc_id] ASC,
	[invoice_line_item_id] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

