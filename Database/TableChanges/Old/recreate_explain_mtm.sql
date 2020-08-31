if OBJECT_ID('explain_mtm') is not null
drop table dbo.[explain_mtm]

go
CREATE TABLE [dbo].[explain_mtm](
	[as_of_date_from] [date] NULL,
	[as_of_date_to] [date] NULL,
	[curve_id] [int] NULL,
	counterparty_id int,
	[charge_type] int ,
	[term_start] [date] NULL,
	[book_deal_type_map_id] [int] NULL,
	[physical_financial_flag] [varchar](1) NULL,
	[ob_mtm] [float] NULL,
	[new_deal] [float] NULL,
	[deal_modify] [float] NULL,
	[forecast_changed] [float] NULL,
	[deleted] [float] NULL,
	[delivered] [float] NULL,
	[price_changed] [float] NULL,
	un_explain  [float],
	[cb_mtm] [float] NULL,
	[currency_id] [int] NULL,
	[create_ts] [datetime] NULL,
	[create_user] [varchar](30) NULL
) ON [PRIMARY]


