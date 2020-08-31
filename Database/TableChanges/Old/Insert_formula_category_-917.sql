IF NOT EXISTS(SELECT 'X' FROM map_function_category where function_id=-917)
	insert into map_function_category(category_id,function_id)
	select 27403,-917

IF NOT EXISTS(SELECT 'X' FROM formula_editor_parameter where formula_id=-917)
	INSERT INTO formula_editor_parameter(formula_id,field_label,field_type,tooltip,field_size,sql_string,is_required,is_numeric,sequence)
	select -917,'Time Series','d','Time Series',0,'select time_series_definition_id,time_series_name FROM time_series_definition',1,0,1
