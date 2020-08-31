if OBJECT_ID('explain_position') is not null
drop table dbo.[explain_position]

go

CREATE TABLE [dbo].[explain_position](
	[as_of_date_from] [date] NULL,
	[as_of_date_to] [date] NULL,
	[curve_id] [int] NULL,
	[proxy_curve_id] [int] NULL,
	[term_start] [date] NULL,
	Hr tinyint,
	[book_deal_type_map_id] [int] NULL,
	[counterparty_id] [int] NULL,
	[uom_id] [int] NULL,
	[physical_financial_flag] [varchar](1) NULL,
	[tou_id] [int] NULL,
	[ob_value] [numeric](18, 10) NULL,
	[new_deal] [numeric](18, 10) NULL,
	[modify_deal] [numeric](18, 10) NULL,
	[forecast_changed] [numeric](18, 10) NULL,
	[deleted] [numeric](18, 10) NULL,
	[delivered] [numeric](18, 10) NULL,
	[cb_value] [numeric](18, 10) NULL,
	un_explain [numeric](18, 10) NULL,
	[create_ts] [datetime] NULL,
	[create_user] [varchar](30) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
