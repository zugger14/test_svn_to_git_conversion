DELETE FROM source_price_curve_def WHERE source_curve_def_id = 5

SET IDENTITY_INSERT source_price_curve_def on
IF NOT EXISTS(SELECT 'x' FROM source_price_curve_def WHERE source_curve_def_id = -1 AND source_system_id = 2)
BEGIN
	INSERT INTO source_price_curve_def(source_curve_def_id,source_system_id,curve_id,curve_name,curve_des,commodity_id,market_value_id,market_value_desc,source_currency_id,source_currency_to_id,source_curve_type_value_id,uom_id,proxy_source_curve_def_id,formula_id,obligation,sort_order,fv_level,create_user,create_ts,update_user,update_ts,Granularity,exp_calendar_id,risk_bucket_id,reference_curve_id,monthly_index,program_scope_value_id,curve_definition,block_type,block_define_id)
	VALUES(-1, 2, 'CO2e', 'CO2e', 'CO2e', 1, 'CO2e', 'CO2e', 1, NULL, 582, 4, NULL, NULL, 'y', NULL, NULL, 'farrms_admin', GETDATE(), 'farrms_admin', GETDATE(), 980, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
	
END
SET IDENTITY_INSERT source_price_curve_def off
