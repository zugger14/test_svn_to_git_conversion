IF NOT EXISTS(SELECT 1 FROM data_component WHERE [type] = 107300)
	INSERT INTO data_component ([description],[type],data_source,paramset_hash,formula_id) VALUES('Meter',107300,'EXEC spa_meter_data_report ''@meter_id'',null,''@granularity'',''@prod_date'',''@prod_date_to'',null,null,''d'',''r'',''2'',null,null,''1'',''n''', NULL, NULL)
GO
IF NOT EXISTS(SELECT 1 FROM data_component WHERE [type] = 107301)
	INSERT INTO data_component ([description],[type],data_source,paramset_hash,formula_id) VALUES('Deal',107301,'EXEC spa_excel_addin_settlement_process @flag =''e'' , @unique_process_id = ''@process_id''',NULL,NULL)
GO

IF NOT EXISTS(SELECT 1 FROM data_component WHERE [type] = 107302)
	INSERT INTO data_component ([description],[type],data_source,paramset_hash,formula_id) VALUES('Price',107302,'EXEC spa_rfx_run_sql @paramset_id,@tablix_id,''as_of_date=@as_of_date,to_as_of_date=NULL,maturity_date=@prod_date,to_maturity_date=@prod_date_to,period_from=NULL,period_to=NULL,curve_id=NULL,Granularity=@granularity'', NULL, ''t''','EC6AC09D_B53C_40E8_B73E_75F4218AA61F',NULL)
GO

IF NOT EXISTS(SELECT 1 FROM data_component WHERE [type] = 107303)
	INSERT INTO data_component ([description],[type],data_source,paramset_hash,formula_id) VALUES('UDSQL',107303,NULL,NULL,NULL)
GO
-- Update 
UPDATE data_component
SET
	data_source = 'EXEC spa_rfx_run_sql @paramset_id,@tablix_id,''as_of_date=@prod_date,to_as_of_date=@prod_date_to,maturity_date=@prod_date,to_maturity_date=@prod_date_to,period_from=NULL,period_to=NULL,curve_id=@curve_id,Granularity=@granularity'', NULL, ''t'''
WHERE [type] = 107302

