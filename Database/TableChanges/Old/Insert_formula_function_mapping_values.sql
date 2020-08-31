Update formula_editor_parameter set custom_validation='greater_than_zero',is_numeric=1 WHERE formula_id = 828 and field_label='No of month to sum'
Update formula_editor_parameter set custom_validation=NULL,is_numeric=1 WHERE formula_id = 828 and field_label='No of month to skip'
Update formula_editor_parameter set custom_validation=NULL,is_numeric=1 WHERE formula_id = 828 and field_label='No of month to skip'
update formula_function_mapping set function_name='RollingAVG' WHERE function_name='Rolling'

update formula_function_mapping set arg1=NULL WHERE function_name='IF'

IF NOT EXISTS(SELECT 'X' FROM formula_function_mapping WHERE function_name='=')
	INSERT INTO formula_function_mapping(function_name,eval_string)
	SELECT '=','CASE WHEN cast(arg1 AS FLOAT) = cast(arg2 AS FLOAT) THEN 1 ELSE 0 END'




-- select * from formula_function_mapping order by function_name

----delete from formula_function_mapping WHERE function_name='GetCurveValue'
--select *from formula_function_mapping WHERE function_name='GetCurveValue'
--select *from formula_function_mapping WHERE function_name='CurveM'


IF NOT EXISTS(SELECT 'X' FROM formula_function_mapping WHERE function_name='GetCurveValue')
	INSERT INTO formula_function_mapping(function_name,eval_string,arg1,arg2,arg3,arg4,arg5,arg6,arg7)
	SELECT 'GetCurveValue','CASE WHEN @simulation_curve_criteria<0 THEN dbo.FNARGetCurveValueSimulation(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),CAST(NULLIF(arg5,''NULL'') AS FLOAT),wif.curve_shift_val  ,@curve_shift_per) ELSE dbo.FNARGetCurveValue(arg1 ,arg2,cast(arg3 as int), CAST(NULLIF(arg4,''NULL'') AS FLOAT),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),wif.curve_shift_val  ,wif.curve_shift_per) END',
	'convert(VARCHAR(20),t.prod_date,120)','convert(VARCHAR(20),t.as_of_date,120)','CASE WHEN ''@calc_type''=''s'' THEN cast(isnull(spcd_s.settlement_curve_id,f.arg1) as varchar) ELSE arg1 END ','arg2','convert(VARCHAR,t.hour)','convert(VARCHAR,t.mins)','convert(VARCHAR,t.is_dst)'


IF NOT EXISTS(SELECT 'X' FROM formula_function_mapping WHERE function_name='PriceMultiplier')
	INSERT INTO formula_function_mapping(function_name,eval_string,arg1,arg2,arg3,arg4,arg5,arg6)
	SELECT 'PriceMultiplier',' dbo.FNARPriceMultiplier(arg1,CAST(arg2 AS INT),CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT))',
	'convert(VARCHAR(20),t.prod_date,120)','convert(VARCHAR,t.counterparty_id)','convert(VARCHAR,t.contract_id) ','convert(VARCHAR,t.source_deal_detail_id)','convert(VARCHAR(10),ISNULL(t.source_deal_header_id,sdd.source_deal_header_id))','convert(VARCHAR,t.calc_aggregation)'


update formula_function_mapping SET eval_string='dbo.FNARIsHoliday(arg1, arg2)',arg1='CONVERT(VARCHAR(20),t.contract_id)',arg2='CONVERT(VARCHAR(20),t.prod_date,120)' WHERE function_name='IsHoliday'
update formula_function_mapping SET eval_string='dbo.FNARYear(arg1)',arg1='CONVERT(VARCHAR(20),t.prod_date,120)'  WHERE function_name='Year'
update formula_function_mapping SET eval_string='dbo.FNARDealMultiplier(cast(arg1  as INT),cast(arg2 as INT))',arg3=NULL WHERE  function_name='DealMultiplier'
update formula_function_mapping SET eval_string='dbo.FNARDealFloatPrice(cast(arg1  as INT),arg2,arg3,cast(arg4 as INT),cast(arg5 as INT),cast(arg6 as INT),cast(arg7 as INT))',arg8=NULL WHERE function_name = 'dealfloatprice'
update formula_function_mapping SET eval_string='dbo.FNARWeekDaysInMnth(arg1,cast(arg2 as INT))',arg1='CONVERT(VARCHAR(20),t.prod_date,120)',arg2='CONVERT(VARCHAR, t.contract_id)',function_name='WeekDaysInMth' where function_name='WeekDaysInMnth'

update formula_function_mapping SET eval_string='dbo.FNARWeekDay(arg1)' where function_name='WeekDay'

/*

select * from static_data_value where type_id=800 order by code

select * from static_data_value where type_id=978

select * from formula_editor_parameter where formula_id=818

select * from formula_editor_parameter where formula_id=-848

select * from source_deal_type
select internal_deal_subtype_value_id,* from source_deal_header
-905
select * from  formula_function_mapping WHERE function_name = 'Averageprice'

select * from map_function_category

select * from  formula_function_mapping WHERE function_name = 'metervol'


*/


--SELECT source_deal_type_id,deal_type_id FROM source_deal_type WHERE sub_type='n' ORDER BY deal_type_id

IF NOT EXISTS(SELECT 'X' FROM formula_editor_parameter WHERE formula_id=834)
	insert into formula_editor_parameter(formula_id,field_label,field_type,tooltip,field_size,sql_string,is_required,is_numeric,sequence,blank_option)
	SELECT 834,'UDF Fields','d','UDF Fields',0,'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 5500 ORDER BY code',1,0,1,0


IF NOT EXISTS(SELECT 'X' FROM formula_editor_parameter WHERE formula_id=857)
	insert into formula_editor_parameter(formula_id,field_label,field_type,tooltip,field_size,sql_string,is_required,is_numeric,sequence,blank_option)
	SELECT 857,'Deal Type','d','Deal Type',0,'SELECT source_deal_type_id,deal_type_id FROM source_deal_type WHERE sub_type=''n'' ORDER BY deal_type_id',1,0,1,0
	UNION ALL
	SELECT 857,'Internal Deal Sub Type','d','Internal Deal Sub Type',0,'SELECT internal_deal_type_subtype_id,internal_deal_type_subtype_type FROM internal_deal_type_subtype_types WHERE type_subtype_flag = ''y'' ORDER BY internal_deal_type_subtype_type',1,0,2,0





IF NOT EXISTS(SELECT 'X' FROM map_function_category WHERE function_id=-905)
	INSERT INTO map_function_category(function_id,category_id)
	SELECT -905,27403

--delete from formula_editor_parameter WHERE formula_id=-905

IF NOT EXISTS(SELECT 'X' FROM formula_editor_parameter WHERE formula_id=-905)
	insert into formula_editor_parameter(formula_id,field_label,field_type,tooltip,field_size,sql_string,is_required,is_numeric,sequence,blank_option)
	SELECT -905,'Curve ID','d','Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',1,0,1,0
	UNION ALL
	SELECT -905,'Block Definition','d','Block Definition',0,'select value_id, code from static_data_value where type_id = 10018',1,0,2,0
	UNION ALL
	SELECT -905,'Aggregation Level','d','Aggregation Level',0,'select value_id, code from static_data_value where type_id = 978 AND value_id IN(980,981,982,993)',1,0,3,0


IF NOT EXISTS(SELECT 'X' FROM formula_function_mapping WHERE function_name='Averageprice')
	INSERT INTO formula_function_mapping(function_name,eval_string,arg1,arg2,arg3,arg4,arg5)
	SELECT 'Averageprice','dbo.FNARAveragePrice(arg1, arg2, CAST(arg3 AS INT), CAST(arg4 AS INT), CAST(arg5 AS INT))',
	'convert(VARCHAR(20), t.prod_date, 120)','convert(VARCHAR(20), t.as_of_date, 120)','arg1','arg2','arg3'


IF NOT EXISTS(SELECT 'X' FROM formula_editor_parameter WHERE formula_id=-838)
	insert into formula_editor_parameter(formula_id,field_label,field_type,tooltip,field_size,sql_string,is_required,is_numeric,sequence,blank_option)
	SELECT -838,'Curve ID','d','Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',1,0,1,0


IF NOT EXISTS(SELECT 'X' FROM formula_editor_parameter WHERE formula_id=-844)
	insert into formula_editor_parameter(formula_id,field_label,field_type,tooltip,field_size,sql_string,is_required,is_numeric,sequence,blank_option)
	SELECT -844,'Curve ID','d','Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',1,0,1,0



IF NOT EXISTS(SELECT 'X' FROM formula_editor_parameter WHERE formula_id=-851)
	insert into formula_editor_parameter(formula_id,field_label,field_type,tooltip,field_size,sql_string,is_required,is_numeric,sequence,blank_option)
	SELECT -851,'Curve ID','d','Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',1,0,1,0



update formula_function_mapping SET arg4='convert(VARCHAR(10),t.granularity)	',arg5='arg1' where function_name='MnPrice'
update formula_function_mapping SET arg4='convert(VARCHAR(10),t.granularity)	',arg5='arg1' where function_name='MxPrice'
update formula_function_mapping SET arg3='convert(VARCHAR(10),t.granularity)	',arg4='arg1' where function_name='StaticCurve'

--DELETE FROM formula_editor_parameter WHERE formula_id=-811

IF NOT EXISTS(SELECT 'X' FROM formula_editor_parameter WHERE formula_id=-811)
	insert into formula_editor_parameter(formula_id,field_label,field_type,tooltip,field_size,sql_string,is_required,is_numeric,sequence,blank_option)
	SELECT -811,'Level','d','Level',0,'SELECT 1 AS value_id,1 AS Code UNION SELECT 2,2 UNION SELECT 3,3 UNION SELECT 4,4',1,0,1,0


update formula_function_mapping SET arg8='CONVERT(VARCHAR(10),ISNULL(t.source_deal_header_id,t.source_deal_detail_id))' where function_name='AllocVolm'


IF NOT EXISTS(SELECT 'X' FROM formula_editor_parameter WHERE formula_id=818)
	insert into formula_editor_parameter(formula_id,field_label,field_type,tooltip,field_size,sql_string,is_required,is_numeric,sequence,blank_option,default_value)
	SELECT 818,'Channel','t','Channel',0,NULL,1,1,1,0,1
	UNION 
	SELECT 818,'Block Definition','d','Block Definition',0,'select value_id, code from static_data_value where type_id = 10018',1,0,2,0,NULL

update formula_function_mapping SET eval_string='dbo.FNARECChannel(arg1 ,cast(arg2 as int),cast(arg3 as int),cast(arg4 as int),cast(arg5 as int),cast(arg6 as int),cast(arg7 as int),cast(arg8 as int),CAST(NULLIF(arg9,''NULL'') AS INT),cast(arg10 as int))', arg9='convert(VARCHAR(10),t.is_dst)' where function_name='Channel'
update  formula_function_mapping SET eval_string= 'dbo.FNARContractualOffPeakVolm(arg1,CAST(arg2 AS int),CAST(arg3 AS int))' where function_name='ContractualOffPeakVolm'
update  formula_function_mapping SET eval_string= 'dbo.FNARContractualOnPeakVolm(arg1,CAST(arg2 AS int),CAST(arg3 AS int))' where function_name='ContractualOnPeakVolm'


IF NOT EXISTS(SELECT 'X' FROM formula_editor_parameter WHERE formula_id=-848)
	insert into formula_editor_parameter(formula_id,field_label,field_type,tooltip,field_size,sql_string,is_required,is_numeric,sequence,blank_option)
	SELECT -848,'Country','d','Country',0,'select value_id, code from static_data_value where type_id = 14000',1,0,1,0
	UNION
	SELECT -848,'Block Definition','d','Block Definition',0,'select value_id, code from static_data_value where type_id = 10018',1,0,2,0

--select * from static_data_value where value_id=-848
Update static_data_value SET code='CptMeterVolm'  where value_id=-848
update formula_function_mapping SET eval_string='dbo.FNARCptMeterVolm(arg1,arg2,CAST(arg3 AS INT),CAST(arg4 AS INT),CAST(arg5 AS INT),CAST(arg6 AS INT))',arg6='arg2' where function_name='CptMeterVolm'
update formula_function_mapping set eval_string='dbo.FNARLocationVol(CAST(arg1 AS INT))',arg6=NULL where function_name='LocationVol'

--select * from formula_editor_parameter where field_label like '%book%'
--select * from source_system_book_map
--select * from source_book

IF NOT EXISTS(SELECT 'X' FROM formula_editor_parameter WHERE formula_id=-862)
	insert into formula_editor_parameter(formula_id,field_label,field_type,tooltip,field_size,sql_string,is_required,is_numeric,sequence,blank_option)
	SELECT -862,'Book 1','d','Book 1',0,'select source_book_id, source_system_book_id from source_book where source_system_book_type_value_id = 50',1,0,1,0
	UNION
	SELECT -862,'Book 2','d','Book 2',0,'select source_book_id, source_system_book_id from source_book where source_system_book_type_value_id = 51',1,0,2,0
	UNION
	SELECT -862,'Book 3','d','Book 3',0,'select source_book_id, source_system_book_id from source_book where source_system_book_type_value_id = 52',1,0,3,0
	UNION
	SELECT -862,'Book 4','d','Book 4',0,'select source_book_id, source_system_book_id from source_book where source_system_book_type_value_id = 53',1,0,4,0
	UNION
	SELECT -862,'Deal Type','d','Deal Type',0,'EXEC spa_getsourcedealtype @flag = s',1,0,5,0


update formula_function_mapping set eval_string='dbo.FNARCounterpartyRating(CAST(arg1 AS INT))' where function_name='CounterpartyRating'

IF NOT EXISTS(SELECT 'X' FROM formula_editor_parameter WHERE formula_id=835)
	insert into formula_editor_parameter(formula_id,field_label,field_type,tooltip,field_size,sql_string,is_required,is_numeric,sequence,blank_option)
	SELECT 835,'From UOM','d','From UOM',0,'select source_uom_id,uom_name FROM source_uom ORDER BY uom_name',1,0,1,0
	UNION
	SELECT 835,'To UOM','d','To UOM',0,'select source_uom_id,uom_name FROM source_uom ORDER BY uom_name',1,0,2,0


IF NOT EXISTS(SELECT 'X' FROM formula_function_mapping WHERE function_name='UOMConv')
	INSERT INTO formula_function_mapping(function_name,eval_string,arg1,arg2)
	SELECT 'UOMConv','dbo.FNAEMSUOMConv(CAST(arg1 AS INT), CAST(arg2 AS INT))','arg1','arg2'

