--calc_formula_value|invoice_line_item_id|IX_calc_formula_value_invoice_line_item_id
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_calc_formula_value_invoice_line_item_id' AND [object_id] = OBJECT_ID('calc_formula_value'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_calc_formula_value_invoice_line_item_id ON calc_formula_value(invoice_line_item_id) 
END
	
--forecast_profile|profile_type|IX_forecast_profile_profile_type
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_forecast_profile_profile_type' AND [object_id] = OBJECT_ID('forecast_profile'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_forecast_profile_profile_type ON forecast_profile(profile_type) 
END
	
--formula_editor|static_value_id|IX_formula_editor_static_value_id
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_formula_editor_static_value_id' AND [object_id] = OBJECT_ID('formula_editor'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_formula_editor_static_value_id ON formula_editor(static_value_id) 
END
	
--hourly_block|block_value_id|IX_hourly_block_block_value_id
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_hourly_block_block_value_id' AND [object_id] = OBJECT_ID('hourly_block'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_hourly_block_block_value_id ON hourly_block(block_value_id) 
END
	
--source_deal_detail|strike_granularity|IX_source_deal_detail_strike_granularity
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_source_deal_detail_strike_granularity' AND [object_id] = OBJECT_ID('source_deal_detail'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_source_deal_detail_strike_granularity ON source_deal_detail(strike_granularity) 
END
	
--source_deal_header|confirmation_type|IX_source_deal_header_confirmation_type
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_source_deal_header_confirmation_type' AND [object_id] = OBJECT_ID('source_deal_header'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_source_deal_header_confirmation_type ON source_deal_header(confirmation_type) 
END
	
--source_deal_header|holiday_calendar|IX_source_deal_header_holiday_calendar
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_source_deal_header_holiday_calendar' AND [object_id] = OBJECT_ID('source_deal_header'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_source_deal_header_holiday_calendar ON source_deal_header(holiday_calendar) 
END
	
--source_deal_header|profile_granularity|IX_source_deal_header_profile_granularity
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_source_deal_header_profile_granularity' AND [object_id] = OBJECT_ID('source_deal_header'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_source_deal_header_profile_granularity ON source_deal_header(profile_granularity) 
END
	
--source_deal_pnl|pnl_source_value_id|IX_source_deal_pnl_pnl_source_value_id
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_source_deal_pnl_pnl_source_value_id' AND [object_id] = OBJECT_ID('source_deal_pnl'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_source_deal_pnl_pnl_source_value_id ON source_deal_pnl(pnl_source_value_id) 
END
	
--source_price_curve|Assessment_curve_type_value_id|IX_source_price_curve_Assessment_curve_type_value_id
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_source_price_curve_Assessment_curve_type_value_id' AND [object_id] = OBJECT_ID('source_price_curve'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_source_price_curve_Assessment_curve_type_value_id ON source_price_curve(Assessment_curve_type_value_id) 
END
	
--source_price_curve|curve_source_value_id|IX_source_price_curve_curve_source_value_id
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_source_price_curve_curve_source_value_id' AND [object_id] = OBJECT_ID('source_price_curve'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_source_price_curve_curve_source_value_id ON source_price_curve(curve_source_value_id) 
END
	
--stage_source_deal_pnl|pnl_source_value_id|IX_stage_source_deal_pnl_pnl_source_value_id
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = 'IX_stage_source_deal_pnl_pnl_source_value_id' AND [object_id] = OBJECT_ID('stage_source_deal_pnl'))
BEGIN
	CREATE NONCLUSTERED INDEX IX_stage_source_deal_pnl_pnl_source_value_id ON stage_source_deal_pnl(pnl_source_value_id) 
END