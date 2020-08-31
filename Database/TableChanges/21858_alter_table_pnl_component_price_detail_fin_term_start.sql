
if object_id('[dbo].[pnl_component_price_detail]') is null
begin
	CREATE TABLE [dbo].[pnl_component_price_detail](
		[row_id] [int] IDENTITY(1,1) NOT NULL,
		[source_deal_header_id] [int] NOT NULL,
		[source_deal_detail_id] [int] NULL,
		[run_as_of_date] [date] NULL,
		[term_start] [date] NULL,
		[leg] [int] NULL,
		[as_of_date] [date] NULL,
		[maturity_date] [date] NULL,
		[curve_id] [int] NULL,
		[curve_value] [float] NULL,
		[deal_price_type_id] [int] NULL,
		[price_type_id] [int] NULL,
		[pricing_month] [date] NULL,
		[adder_currency] [int] NULL,
		[currency_id] [int] NULL,
		[uom_id] [int] NULL,
		[price_multiplier] [float] NULL,
		[price_adder] [float] NULL,
		[calc_type] [varchar](1) NULL,
		[is_formula] [varchar](1) NULL,
		[create_user] [varchar](50) NULL,
		[create_ts] [datetime] NULL,
		[update_user] [varchar](50) NULL,
		[update_ts] [datetime] NULL,
		[shipment_id] [int] NULL,
		[ticket_detail_id] [int] NULL,
		[fin_term_start] [datetime] NULL,
		[price_uom] [int] NULL,
		[price_currency] [int] NULL,
		[settlement_currency] [int] NULL,
		[uom_conversion] [float] NULL,
		[fx_rate_curve] [float] NULL,
		[fx_rate_adder] [float] NULL,
		[raw_price] [float] NULL,
		[raw_price_adder] [float] NULL
	) ON [PRIMARY]

	ALTER TABLE [dbo].[pnl_component_price_detail] ADD  DEFAULT ([dbo].[FNADBUser]()) FOR [create_user]
	ALTER TABLE [dbo].[pnl_component_price_detail] ADD  DEFAULT (getdate()) FOR [create_ts]
	ALTER TABLE [dbo].[pnl_component_price_detail]  WITH CHECK ADD FOREIGN KEY([source_deal_header_id])
	REFERENCES [dbo].[source_deal_header] ([source_deal_header_id])
	ON DELETE CASCADE


end
go




IF COL_LENGTH('pnl_component_price_detail', 'fin_term_start') IS NULL
BEGIN

	alter table [dbo].pnl_component_price_detail 
		add fin_term_start datetime
			,price_uom int
			,price_currency int
			,settlement_currency int
			,uom_conversion float
			,fx_rate_curve float
			,fx_rate_adder float
			,raw_price float,
			raw_price_adder float
END
ELSE
BEGIN
	PRINT 'Column fin_term_start EXISTS'
END

go

IF COL_LENGTH('pnl_component_price_detail', 'shipment_id') IS NULL
BEGIN

	alter table [dbo].pnl_component_price_detail add shipment_id int
			
END
ELSE
BEGIN
	PRINT 'Column shipment_id EXISTS'
END


go

IF COL_LENGTH('pnl_component_price_detail', 'ticket_detail_id') IS NULL
BEGIN

	alter table [dbo].pnl_component_price_detail add ticket_detail_id int
			
END
ELSE
BEGIN
	PRINT 'Column ticket_detail_id EXISTS'
END


go

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[pnl_component_price_detail]') AND name = N'cur_indx_pnl_component_price_detail')
DROP INDEX [cur_indx_pnl_component_price_detail] ON [dbo].[pnl_component_price_detail] WITH ( ONLINE = OFF )

CREATE UNIQUE CLUSTERED INDEX [cur_indx_pnl_component_price_detail] ON [dbo].[pnl_component_price_detail]
	(
		[source_deal_header_id] ASC,
		[curve_id] ASC,
		[ticket_detail_id] ASC,
		[shipment_id] ASC,
		[deal_price_type_id] ASC,
		[term_start] ASC,
		[leg] ASC,
		[run_as_of_date] ASC,
		[calc_type] ASC,
		[fin_term_start] ASC,
		[maturity_date] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
