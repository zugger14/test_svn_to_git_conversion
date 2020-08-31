IF NOT EXISTS(SELECT 'X' FROM map_function_category WHERE function_id=870)
	INSERT INTO map_function_category(category_id,function_id)
	SELECT 27403,870

IF EXISTS(SELECT 'X' FROM formula_editor_parameter WHERE formula_id=870)
	DELETE FROM formula_editor_parameter WHERE formula_id=870

	INSERT INTO formula_editor_parameter(formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	SELECT 870,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',1,0,NULL,1,0
	UNION
	SELECT 870,'Relative Year','t',0,'Relative Year',0,NULL,1,0,NULL,2,0
	UNION
	SELECT 870,'Strip Month From','t',0,'Strip Month From',0,NULL,1,0,NULL,3,0
	UNION
	SELECT 870,'Lag Months','t',0,'Lag Months',0,NULL,1,0,NULL,4,0
	UNION
	SELECT 870,'Strip Month To','t',0,'Strip Month To',0,NULL,1,0,NULL,5,0
	UNION
	SELECT 870,'Currency','d',NULL,'Currency',0,'exec spa_source_currency_maintain @flag=''p''',1,0,NULL,6,0
	UNION
	SELECT 870,'Price Adder','t',0,'Price Adder',0,NULL,1,0,NULL,7,0
	UNION
	SELECT 870,'Volume Multiplier','t',1,'Volume Multiplier',0,NULL,1,0,NULL,8,0
	UNION
	SELECT 870,'Expiration Type','t',NULL,'Expiration Type',0,NULL,1,0,NULL,9,0
	UNION
	SELECT 870,'Expiration Value','t',NULL,'Expiration Value',0,NULL,1,0,NULL,10,0
