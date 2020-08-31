--insert temp ID
if not exists(select 1 from source_commodity where  source_commodity_id in(-1,-2))
begin
	delete source_commodity where source_commodity_id in(-11,-22)

	set identity_insert source_commodity on
	insert into source_commodity (source_commodity_id,source_system_id,commodity_id,commodity_name)
	values(-11,2,'NaturalGasmmmm','Natural Gas')
	insert into source_commodity (source_commodity_id,source_system_id,commodity_id,commodity_name)
	values(-22,2,'Powergggg','POwer')
	set identity_insert source_commodity off

	update dbo.calc_implied_volatility set commodity_id=-11 where commodity_id=1
	update dbo.calc_implied_volatility set commodity_id=-22 where commodity_id=2

	update dbo.contract_size set commodity_id=-11 where commodity_id=1
	update dbo.contract_size set commodity_id=-22 where commodity_id=2

	update dbo.counterparty_credit_block_trading set comodity_id=-11 where comodity_id=1
	update dbo.counterparty_credit_block_trading set comodity_id=-22 where comodity_id=2

	update dbo.deal_confirmation_rule set commodity_id=-11 where commodity_id=1
	update dbo.deal_confirmation_rule set commodity_id=-22 where commodity_id=2

	update dbo.netting_group set source_commodity_id=-11 where source_commodity_id=1
	update dbo.netting_group set source_commodity_id=-22 where source_commodity_id=2

	update dbo.source_minor_location set commodity_id=-11 where commodity_id=1
	update dbo.source_minor_location set commodity_id=-22 where commodity_id=2

	update dbo.source_price_curve_def set commodity_id=-11 where commodity_id=1
	update dbo.source_price_curve_def set commodity_id=-22 where commodity_id=2

	update dbo.trader_ticket_template set commodity_id=-11 where commodity_id=1
	update dbo.trader_ticket_template set commodity_id=-22 where commodity_id=2

	update dbo.report_hourly_position_breakdown set commodity_id=-11 where commodity_id=1
	update dbo.report_hourly_position_breakdown set commodity_id=-22 where commodity_id=2

	update dbo.report_hourly_position_deal set commodity_id=-11 where commodity_id=1
	update dbo.report_hourly_position_deal set commodity_id=-22 where commodity_id=2

	update dbo.report_hourly_position_profile set commodity_id=-11 where commodity_id=1
	update dbo.report_hourly_position_profile set commodity_id=-22 where commodity_id=2

	update dbo.broker_fees set commodity=-11 where commodity=1
	update dbo.broker_fees set commodity=-22 where commodity=2

	delete source_commodity  where source_commodity_id in (1,2)


	set identity_insert source_commodity on

	insert into source_commodity (source_commodity_id,source_system_id,commodity_id,commodity_name,commodity_desc)
	values(-1,2,'Natural Gas','Natural Gas','Natural Gas')
	insert into source_commodity (source_commodity_id,source_system_id,commodity_id,commodity_name,commodity_desc)
	values(-2,2,'Power','Power','Power')

	set identity_insert source_commodity off

	update dbo.calc_implied_volatility set commodity_id=-1 where commodity_id=-11
	update dbo.calc_implied_volatility set commodity_id=-2 where commodity_id=-22

	update dbo.contract_size set commodity_id=-1 where commodity_id=-11
	update dbo.contract_size set commodity_id=-2 where commodity_id=-22

	update dbo.counterparty_credit_block_trading set comodity_id=-1 where comodity_id=-11
	update dbo.counterparty_credit_block_trading set comodity_id=-2 where comodity_id=-22

	update dbo.deal_confirmation_rule set commodity_id=-1 where commodity_id=-11
	update dbo.deal_confirmation_rule set commodity_id=-2 where commodity_id=-22

	update dbo.netting_group set source_commodity_id=-1 where source_commodity_id=-11
	update dbo.netting_group set source_commodity_id=-2 where source_commodity_id=-22

	update dbo.source_minor_location set commodity_id=-1 where commodity_id=-11
	update dbo.source_minor_location set commodity_id=-2 where commodity_id=-22

	update dbo.source_price_curve_def set commodity_id=-1 where commodity_id=-11
	update dbo.source_price_curve_def set commodity_id=-2 where commodity_id=-22

	update dbo.trader_ticket_template set commodity_id=-1 where commodity_id=-11
	update dbo.trader_ticket_template set commodity_id=-2 where commodity_id=-22

	update dbo.report_hourly_position_breakdown set commodity_id=-1 where commodity_id=-11
	update dbo.report_hourly_position_breakdown set commodity_id=-2 where commodity_id=-22

	update dbo.report_hourly_position_deal set commodity_id=-1 where commodity_id=-11
	update dbo.report_hourly_position_deal set commodity_id=-2 where commodity_id=-22

	update dbo.report_hourly_position_profile set commodity_id=-1 where commodity_id=-11
	update dbo.report_hourly_position_profile set commodity_id=-2 where commodity_id=-22
	
		update dbo.broker_fees set commodity=-1 where commodity=-11
	update dbo.broker_fees set commodity=-2 where commodity=-22

	
end
