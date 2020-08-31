
alter TABLE [dbo].[deal_detail_hour] add
	[source_deal_header_id] [int] NULL,
	[commodity_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[fas_book_id] [int] NULL,
	[leg] [int] NULL,
	[curve_id] [int] NULL,
	[source_system_book_id1] [int] NULL,
	[source_system_book_id2] [int] NULL,
	[source_system_book_id3] [int] NULL,
	[source_system_book_id4] [int] NULL,
	[deal_date] [datetime] NULL,
	[multiplier] [float] NULL,
	[volume_multiplier2] [float] NULL,
	[buy_sell_flag] [char](1) NULL
