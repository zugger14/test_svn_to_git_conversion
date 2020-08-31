IF EXISTS(SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[source_deal_delta_value_whatif]') AND TYPE IN (N'U'))
BEGIN
    PRINT 'Table Already Exists'
END
ELSE
BEGIN
	CREATE TABLE [dbo].[source_deal_delta_value_whatif](
		[criteria_id] [int] NOT NULL,
		[run_date] [datetime] NOT NULL,
		[as_of_date] [datetime] NOT NULL,
		[source_deal_detail_id] [int],
		[source_deal_header_id] [int] NOT NULL,
		[curve_id] [int],
		[term_start] [datetime] NOT NULL,
		[term_end] [datetime],
		[physical_financial_flag] [char](1),
		[counterparty_id] [int],
		[Position] [float],
		[market_value_delta] [float],
		[contract_value_delta] [float],
		[avg_value] [float],
		[delta_value] [float],
		[avg_delta_value] [float],
		[currency_id] [int],
		[pnl_source_value_id] [int],
		[formula_curve_id] [int],
		[curve_value] [float],
		[formula_curve_value] [float],
		[dis_market_value_delta] [float],
		[dis_contract_value_delta] [float],
		[dis_avg_value] [float],
		[dis_delta_value] [float],
		[dis_avg_delta_value] [float]
	)
END