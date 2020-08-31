
IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[process_short_term_generation_unit_cost]') 
					AND name = N'indx_unq_cur_process_short_term_generation_unit_cost')
BEGIN
	create unique clustered index indx_unq_cur_process_short_term_generation_unit_cost on dbo.process_short_term_generation_unit_cost
	(
		location_id,
		is_mix,
		generator_config_value_id,
		fuel_value_id,
		term_hr
		,unit_value
	)	
END		

