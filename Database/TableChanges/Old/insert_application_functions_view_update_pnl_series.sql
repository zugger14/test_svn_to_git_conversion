IF NOT EXISTS (SELECT  'x' FROM application_functions WHERE function_id = 10237300)
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	 VALUES
	(10237300,'View/Update Cum PNL Series','View/Update Cum PNL Series',10230000,'windowViewUpdateCumPNLSeries')

IF NOT EXISTS (SELECT  'x' FROM application_functions WHERE function_id = 10237310)
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call) 
	VALUES
	(10237310,'View/Update Cum PNL Series IU','View/Update Cum PNL Series IU',10237300,'windowViewUpdateCumPNLSeriesIU')

IF NOT EXISTS (SELECT  'x' FROM application_functions WHERE function_id = 10237311)
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id) 
	VALUES
	(10237311,'Delete Cum PNL Series','Delete Cum PNL Series',10237300)

	
