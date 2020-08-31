IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[process_generation_unit_cost]') 
					AND name = N'index_cur_uni_process_generation_unit_cost')
BEGIN
create unique clustered  index index_cur_uni_process_generation_unit_cost
on dbo.process_generation_unit_cost (location_id,is_mix, generator_config_value_id, fuel_value_id, term_hr,long_short)
	
END					

