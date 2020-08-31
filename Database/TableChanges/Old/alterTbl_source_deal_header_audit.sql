alter table [source_deal_header_audit] add
	[internal_desk_id] [int] NULL,
	[product_id] [int] NULL,
	[internal_portfolio_id] [int] NULL,
	[commodity_id] [int] NULL,
	[reference] [varchar](250) NULL,
	[deal_locked] [char](1) NULL,
	[close_reference_id] [int] NULL,
	[block_type] [int] NULL,
	[block_define_id] [int] NULL,
	[granularity_id] [int] NULL,
	[pricing] [int] NULL