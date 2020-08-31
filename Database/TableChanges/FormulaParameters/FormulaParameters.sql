DELETE FROM formula_editor_parameter WHERE formula_id=-923 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-923,'Recorder ID','d',0,'Recorder ID',0,'SELECT mi.meter_id, mi.recorderid FROM meter_id mi',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-923,'Block Definition','d',1,'Block Definition',0,'EXEC spa_uk_block_definitions',1,0,'',2,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-922 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-922,'UK Rate Group','d',0,'UK Rate Group',0,'EXEC spa_uk_rates_group',0,0,'',1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-921 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-921,'Charge Type','d',0,'Charge Type',0,'SELECT value_id,code FROM static_data_value where type_id=10019 ORDER BY Code',0,0,'',1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-920 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-920,'Charge Type','d',0,'Charge Type',0,'SELECT value_id,code FROM static_data_value where type_id=10019 ORDER BY Code',0,0,'',1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-917 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-917,'Time Series','d',NULL,'Time Series',0,'select time_series_definition_id,time_series_name FROM time_series_definition',1,0,NULL,1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-916 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-916,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions ''s''',0,0,'',1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-909 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-909,'Row Number','t',NULL,'Row Number',0,'',1,0,'greater_than_zero',1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-909 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-909,'Relative Production Month Number','t',NULL,'Relative Production Month Number',0,'',1,0,'',2,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-909,'Relative As Of Date Number','t',NULL,'Relative As Of Date Number',0,'',1,0,'greater_than_zero',3,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-905 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-905,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',1,0,NULL,1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-905,'Block Definition','d',NULL,'Block Definition',0,'select value_id, code from static_data_value where type_id = 10018',1,0,NULL,2,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-905,'Aggregation Level','d',NULL,'Aggregation Level',0,'select value_id, code from static_data_value where type_id = 978 AND value_id IN(980,981,982,993)',1,0,NULL,3,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-901 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-901,'Mapping Table','d',NULL,'Mapping Table',0,'SELECT mapping_table_id, mapping_name FROM generic_mapping_header WHERE mapping_name IN (''Contract Meters'', ''Contract Curves'', ''Contract Value'')',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-901,'Logical Name','d',NULL,'Logical Name',0,'SELECT max(generic_mapping_values_id), clm3_value FROM generic_mapping_values GROUP BY clm3_value',0,0,'',2,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-899 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-899,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-899,'Month','t',0,'Month',0,'',1,1,'greater_than_zero',2,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-898,'Recorder ID','d',NULL,'Recorder ID',0,'SELECT mi.meter_id, mi.recorderid FROM meter_id mi',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-898,'Channel','d',NULL,'Channel',0,'SELECT channel, channel_description FROM recorder_properties',0,0,'',1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-888 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-888,'UDF Charges','d',NULL,'UDF Charges',0,'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 5500 ORDER BY code',0,0,'',1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-874 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-874,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-874,'Granularity','d',NULL,'Granularity',0,'SELECT value_id, code FROM static_data_value sdv WHERE [TYPE_ID] = 978',0,0,'',2,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-873 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-873,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-873,'Average Type','d',NULL,'Average Type',0,'SELECT 0 ID , ''Simple Average'' Value UNION SELECT 1 ID , ''Volume Weighted Average'' Value',0,0,'',2,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-872 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-872,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-872,'Average Type','d',NULL,'Average Type',0,'SELECT 0 ID , ''Simple Average'' Value UNION SELECT 1 ID , ''Volume Weighted Average'' Value',0,0,'',2,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-871 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-871,'UDF Charges','d',NULL,'UDF Charges',0,'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 5500 ORDER BY code',0,0,'',1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-862 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-862,'Book 1','d',NULL,'Book 1',0,'select source_book_id, source_system_book_id from source_book where source_system_book_type_value_id = 50',1,0,NULL,1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-862,'Book 2','d',NULL,'Book 2',0,'select source_book_id, source_system_book_id from source_book where source_system_book_type_value_id = 51',1,0,NULL,2,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-862,'Book 3','d',NULL,'Book 3',0,'select source_book_id, source_system_book_id from source_book where source_system_book_type_value_id = 52',1,0,NULL,3,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-862,'Book 4','d',NULL,'Book 4',0,'select source_book_id, source_system_book_id from source_book where source_system_book_type_value_id = 53',1,0,NULL,4,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-862,'Deal Type','d',NULL,'Deal Type',0,'EXEC spa_getsourcedealtype @flag = s',1,0,NULL,5,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-857 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-857,'Meter ID','d',NULL,'Meter ID',0,'SELECT mi.meter_id, mi.recorderid FROM meter_id mi',1,0,NULL,1,1)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-857,'Channel','d',NULL,'Channel',0,'SELECT channel, channel_description FROM recorder_properties',1,0,NULL,1,1)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-857,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',0,0,NULL,1,1)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-857,'Number of Continous Hours','t',NULL,'Number of Continous Hours',0,'',1,0,NULL,1,1)

DELETE FROM formula_editor_parameter WHERE formula_id=-855 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-855,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions ''s'',NULL,NULL,NULL',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-855,'Granularity','d',NULL,'Granularity',0,'SELECT value_id, code FROM static_data_value sdv WHERE [TYPE_ID] = 978',0,0,'',2,1)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-855,'Index Group','d',NULL,'Index Group',0,'SELECT value_id, code FROM static_data_value sdv WHERE [TYPE_ID] = 15100',0,0,'',3,1)

DELETE FROM formula_editor_parameter WHERE formula_id=-852 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-852,'Deal Type','d',NULL,'Deal Type',0,'EXEC spa_getsourcedealtype @flag = s',0,0,'',1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-851 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-851,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',1,0,NULL,1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-849 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-849,'UDF Charges','d',NULL,'UDF Charges',0,'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 5500 ORDER BY code',0,0,'',1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-848 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-848,'Country','d',NULL,'Country',0,'select value_id, code from static_data_value where type_id = 14000',1,0,NULL,1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-848,'Block Definition','d',NULL,'Block Definition',0,'select value_id, code from static_data_value where type_id = 10018',1,0,NULL,2,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-844 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-844,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',1,0,NULL,1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-844,'Granularity','d',NULL,'Granularity',0,'SELECT value_id, code FROM static_data_value sdv WHERE [TYPE_ID] = 978',0,0,'',2,1)


DELETE FROM formula_editor_parameter WHERE formula_id=-838 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-838,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',1,0,NULL,1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-838,'Granularity','d',NULL,'Granularity',0,'SELECT value_id, code FROM static_data_value sdv WHERE [TYPE_ID] = 978',0,0,'',2,1)

DELETE FROM formula_editor_parameter WHERE formula_id=-821 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-821,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-821,'Granularity','d',NULL,'Granularity',0,'SELECT value_id, code FROM static_data_value sdv WHERE [TYPE_ID] = 978',0,0,'',2,1)

DELETE FROM formula_editor_parameter WHERE formula_id=-820 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-820,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-820,'Granularity','d',NULL,'Granularity',0,'SELECT value_id, code FROM static_data_value sdv WHERE [TYPE_ID] = 978',0,0,'',2,1)

DELETE FROM formula_editor_parameter WHERE formula_id=-819 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-819,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-819,'Granularity','d',NULL,'Granularity',0,'SELECT value_id, code FROM static_data_value sdv WHERE [TYPE_ID] = 978',0,0,'',2,1)

DELETE FROM formula_editor_parameter WHERE formula_id=-818 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-818,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-818,'Granularity','d',NULL,'Granularity',0,'SELECT value_id, code FROM static_data_value sdv WHERE [TYPE_ID] = 978',0,0,'',2,1)

DELETE FROM formula_editor_parameter WHERE formula_id=-811 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-811,'Level','d',NULL,'Level',0,'SELECT 1 AS value_id,1 AS Code UNION SELECT 2,2 UNION SELECT 3,3 UNION SELECT 4,4',1,0,NULL,1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=-801 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-801,'Block Definition','d',NULL,'Block Definition',0,'select value_id, code from static_data_value where type_id = 10018',0,0,NULL,1,1)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-801,'Block Type','d',NULL,'Block Type',0,'SELECT value_id, code FROM static_data_value WHERE [type_id]=12000',0,0,NULL,2,1)

DELETE FROM formula_editor_parameter WHERE formula_id=813 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(813,'Contract','d',NULL,'Contract',0,'select contract_id, contract_name from contract_group',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(813,'Charge Type','d',NULL,'Charge Type',0,'select value_id, code from static_data_value where type_id = 10019',0,0,'',2,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(813,'Row Number','t',NULL,'Row Number',0,'',1,0,'greater_than_zero',3,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(813,'Prior Month','t',0,'Prior Month',0,'',1,0,'non_negative',4,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(813,'Month','d',NULL,'Month',0,'SELECT 1 [id], ''1'' [value] UNION ALL SELECT 2 [id], ''2'' [value] UNION ALL SELECT 3 [id], ''3'' [value] UNION ALL SELECT 4 [id], ''4'' [value] UNION ALL SELECT 5 [id], ''5'' [value] UNION ALL SELECT 6 [id], ''6'' [value] UNION ALL SELECT 7 [id], ''7'' [value] UNION ALL SELECT 8 [id], ''8'' [value] UNION ALL SELECT 9 [id], ''9'' [value] UNION ALL SELECT 10 [id], ''10'' [value] UNION ALL SELECT 11 [id], ''11'' [value] UNION ALL SELECT 12 [id], ''12'' [value]',0,0,'',5,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(813,'Relative As of Date','d',NULL,'Relative As of Date',0,'SELECT -1 ID , ''Prior As of Date'' Value UNION SELECT 0 ID , ''Max As of Date'' Value UNION SELECT 1 ID , ''Same As of Date'' Value',0,0,'',6,0)

DELETE FROM formula_editor_parameter WHERE formula_id=818 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(818,'Channel','t',1,'Channel',0,NULL,1,1,NULL,1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(818,'Block Definition','d',NULL,'Block Definition',0,'select value_id, code from static_data_value where type_id = 10018',1,0,NULL,2,0)

DELETE FROM formula_editor_parameter WHERE formula_id=820 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(820,'Row','t',NULL,'Row Value',0,'',1,0,'greater_than_zero',1,0)
	
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(820,'Offset','t',0,'Offset Value',0,'',0,0,'',2,0)
	
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(820,'Aggregation','d',NULL,'Aggregation Value',0,'SELECT 0 ID , ''SUM'' Value UNION SELECT 1 ID , ''AVERAGE'' Value',0,0,'',3,0)

DELETE FROM formula_editor_parameter WHERE formula_id=821 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(821,'Number of Row','t',NULL,'Number of Rows',0,'',1,0,'greater_than_zero',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(821,'Number of Month','t',NULL,'Number of Month',0,'',1,0,'greater_than_zero',2,0)

DELETE FROM formula_editor_parameter WHERE formula_id=828 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(828,'Row No','t',NULL,'Row No',0,'',1,0,'greater_than_zero',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(828,'No of month to sum','t',NULL,'No of month to sum',0,'',1,0,'greater_than_zero',2,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(828,'No of month to skip','t',NULL,'No of month to skip',0,'',1,0,'numeric_validation',3,0)

DELETE FROM formula_editor_parameter WHERE formula_id=834 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(834,'UDF Fields','d',NULL,'UDF Fields',0,'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 5500 ORDER BY code',1,0,NULL,1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=835 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(835,'From UOM','d',NULL,'From UOM',0,'select source_uom_id,uom_name FROM source_uom ORDER BY uom_name',1,0,NULL,1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(835,'To UOM','d',NULL,'To UOM',0,'select source_uom_id,uom_name FROM source_uom ORDER BY uom_name',1,0,NULL,2,0)

DELETE FROM formula_editor_parameter WHERE formula_id=850 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(850,'Recorder ID','d',NULL,'Recorder ID',0,'SELECT mi.meter_id, mi.recorderid FROM meter_id mi',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(850,'Month','t',0,'Month',0,'',1,0,'',2,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(850,'Channel','d',NULL,'Channel',0,'SELECT channel, channel_description FROM recorder_properties',1,0,'',3,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(850,'Block Definition','d',NULL,'Block Defination',0,'select value_id, code from static_data_value where type_id = 10018',0,0,NULL,4,1)

DELETE FROM formula_editor_parameter WHERE formula_id=857 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(857,'Deal Type','d',NULL,'Deal Type',0,'SELECT source_deal_type_id,deal_type_id FROM source_deal_type WHERE sub_type=''n'' ORDER BY deal_type_id',1,0,NULL,1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(857,'Internal Deal Sub Type','d',NULL,'Internal Deal Sub Type',0,'SELECT internal_deal_type_subtype_id,internal_deal_type_subtype_type FROM internal_deal_type_subtype_types WHERE type_subtype_flag = ''y'' ORDER BY internal_deal_type_subtype_type',1,0,NULL,2,0)

DELETE FROM formula_editor_parameter WHERE formula_id=861 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(861,'UDF Charges','d',NULL,'UDF Charges',0,'SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 5500 ORDER BY code',0,0,'',1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=877 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(877,'Deal Type','d',NULL,'Deal Type',0,'EXEC spa_getsourcedealtype @flag = s',0,0,'',1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=894 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(894,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(894,'Block Definition','d',NULL,'Block Defination',0,'select '' [value], '' [code] UNION ALL select value_id, code from static_data_value where type_id = 10018',0,0,'',4,1)

DELETE FROM formula_editor_parameter WHERE formula_id=896 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(896,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(896,'Month','t',0,'Month',0,'',1,1,'greater_than_zero',2,0)

DELETE FROM formula_editor_parameter WHERE formula_id=899 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(899,'Check Fixation','d',0,'Check Fixation',0,'SELECT 0 as [Value], 0 as [Text] UNION SELECT 1,1',0,0,'',1,0)

DELETE FROM formula_editor_parameter WHERE formula_id=870 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(870,'Currency','d',NULL,'Currency',0,'exec spa_source_currency_maintain @flag=''p''',1,0,NULL,6,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(870,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions @flag = s',1,0,NULL,1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(870,'Expiration Type','t',NULL,'Expiration Type',0,NULL,1,0,NULL,9,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(870,'Expiration Value','t',NULL,'Expiration Value',0,NULL,1,0,NULL,10,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(870,'Lag Months','t',0,'Lag Months',0,NULL,1,0,NULL,4,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(870,'Price Adder','t',0,'Price Adder',0,NULL,1,0,NULL,7,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(870,'Relative Year','t',0,'Relative Year',0,NULL,1,0,NULL,2,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(870,'Strip Month From','t',0,'Strip Month From',0,NULL,1,0,NULL,3,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(870,'Strip Month To','t',0,'Strip Month To',0,NULL,1,0,NULL,5,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(870,'Volume Multiplier','t',1,'Volume Multiplier',0,NULL,1,0,NULL,8,0)


DELETE FROM formula_editor_parameter WHERE formula_id=860 

DELETE FROM formula_editor_parameter WHERE formula_id=886 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(886,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions ''s''',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(886,'Period','d',NULL,'Period',0,'SELECT 0 [value],''Day'' [code] UNION SELECT 1 [value],''Month'' [code] UNION SELECT 2 [value],''Year'' [code] ',0,0,'',2,0)



DELETE FROM formula_editor_parameter WHERE formula_id=-841 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-841,'Frequency','d',NULL,'Period',0,'SELECT 0 [value],''Day'' [code] UNION SELECT 1 [value],''Month'' [code] UNION SELECT 2 [value],''Quarter'' [code] UNION SELECT 3 [value],''Year'' [code] ',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-841,'Number','t',NULL,'Number',0,'',1,0,'greater_than_zero',2,0)


DELETE FROM formula_editor_parameter WHERE formula_id=-861 
	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-861,'Curve ID','d',NULL,'Curve ID',0,'EXEC spa_GetAllPriceCurveDefinitions ''s''',0,0,'',1,0)

	INSERT INTO formula_editor_parameter (formula_id,field_label,field_type,default_value,tooltip,field_size,sql_string,is_required,is_numeric,custom_validation,sequence,blank_option)
	Values(-861,'Offset','t',0,'Offset',0,NULL,1,0,NULL,2,0)
	
DELETE FROM formula_editor_parameter WHERE formula_id = -926

 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-926, 'Curve ID1', 'd', '',  'Curve ID1','','EXEC spa_GetAllPriceCurveDefinitions @flag = s','0','0','','1','farrms_admin', GETDATE())

 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-926, 'Curve ID2', 'd', '',  'Curve ID2','','EXEC spa_GetAllPriceCurveDefinitions @flag = s','0','0','','1','farrms_admin', GETDATE())

 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-926, 'Holiday', 'd', '',  'Holiday','','SELECT sdv.value_id, sdv.code FROM static_data_value sdv WHERE sdv.[type_id] = 10017 ORDER BY code','0','0','','1','farrms_admin', GETDATE())
	
DELETE FROM formula_editor_parameter WHERE formula_id = -927
 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-927, 'Mapping Name', 'd', '',  'Mapping Name','','SELECT gmh.mapping_table_id [Value], gmh.mapping_name [Code] FROM generic_mapping_header gmh WHERE gmh.mapping_name IN (''APX Markup'',''Endex Markup'')','0','0','','1','farrms_admin', GETDATE())

 	INSERT INTO formula_editor_parameter (formula_id, field_label, field_type, default_value, tooltip, field_size, sql_string, is_required, is_numeric, custom_validation, sequence, create_user, create_ts)
	VALUES (-927, 'Row', 't', '',  'Row','','','0','0','','2','farrms_admin', GETDATE())
