IF OBJECT_ID('source_deal_settlement_tou') IS NULL
BEGIN
	CREATE TABLE [dbo].[source_deal_settlement_tou](
		[as_of_date] [datetime] NULL,
		[settlement_date] [datetime] NULL,
		[payment_date] [datetime] NULL,
		[source_deal_header_id] [int] NULL,
		[term_start] [datetime] NULL,
		[term_end] [datetime] NULL,
		[volume] [float] NULL,
		[net_price] [float] NULL,
		[settlement_amount] [float] NULL,
		[settlement_currency_id] [int] NULL,
		[create_ts] [datetime] NULL,
		[create_user] [varchar](50) NULL,
		[volume_uom] [int] NULL,
		[fin_volume] [float] NULL,
		[fin_volume_uom] [int] NULL,
		[float_price] [float] NULL,
		[deal_price] [float] NULL,
		[price_currency] [int] NULL,
		[leg] [int] NULL,
		[market_value] [float] NULL,
		[contract_value] [float] NULL,
		[set_type] [char](1) NULL,
		[allocation_volume] [float] NULL,
		[settlement_amount_deal] [float] NULL,
		[settlement_amount_inv] [float] NULL,
		[deal_cur_id] [int] NULL,
		[inv_cur_id] [int] NULL,
		[shipment_id] [int] NULL,
		[ticket_detail_id] [int] NULL,
		[source_deal_settlement_id] [int] IDENTITY(1,1) NOT NULL,
		[tou_id] [int]
) ON [PRIMARY]
	CREATE UNIQUE CLUSTERED INDEX indx_unq_source_deal_settlement_tou ON dbo.source_deal_settlement_tou (
	[source_deal_header_id],[term_start],[leg],[as_of_date],[set_type],tou_id)
END