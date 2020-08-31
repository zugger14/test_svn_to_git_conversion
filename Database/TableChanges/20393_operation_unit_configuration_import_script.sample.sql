	DECLARE @generator VARCHAR(MAX) = 'BR3,Joffre,PH1,OMRH,BR4,BR5,SH1,SH2,MKR1,APS1,VVW,VVW2,RL1,RB5,PR1,HSM1' --
 	--SELECT * FROM dbo.SplitCommaSeperatedValues(@generator) AS scsv
 	
	IF OBJECT_ID('tempdb..#genr') IS NOT NULL
		DROP TABLE #genr
	IF OBJECT_ID('tempdb..#missing_gen') IS NOT NULL
		DROP TABLE #missing_gen
		 
   	SELECT DISTINCT sdd.source_deal_header_id, scsv.item generator,sml.source_minor_location_id into #genr 
  	FROM source_deal_detail sdd 
		INNER JOIN source_minor_location sml ON sdd.location_id = sml.source_minor_location_id
		INNER join dbo.SplitCommaSeperatedValues(@generator) AS scsv ON scsv.item = sml.Location_Name	

	SELECT DISTINCT 'Generator:' + scsv.item + CASE WHEN sml.source_minor_location_id IS NULL THEN ' Not found' ELSE ' imported' END msg INTO #missing_gen    
    FROM dbo.SplitCommaSeperatedValues(@generator) AS scsv
    LEFT JOIN source_minor_location sml ON sml.Location_Name  = scsv.item
    --WHERE sml.source_minor_location_id IS NULL
  	   
    
	--SELECT *
	DELETE ouc
	FROM operation_unit_configuration AS ouc 
	INNER JOIN #genr g ON g.source_minor_location_id = ouc.location_id
 		
 	

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'APS1')
		INSERT INTO operation_unit_configuration (location_id, effective_date, effective_end_date,
	            generator_config_value_id, period_type, fuel_value_id, tou, hour_from, hour_to,
	            unit_from, unit_to)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'APS1'),
			'2016-12-22 00:00:00.000',
			'2016-12-22 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  'Duct Burner'),
			NULL,
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT value_id FROM static_data_value where type_id = 10018 AND code =  ''),
			1,
			2,
			101,
			122 
			
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'APS1')
		INSERT INTO operation_unit_configuration (location_id, effective_date, effective_end_date,
	            generator_config_value_id, period_type, fuel_value_id, tou, hour_from, hour_to,
	            unit_from, unit_to)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'APS1'),
			'2016-12-22 00:00:00.000',
			'2016-12-22 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  'Duct Burner'),
			NULL,
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT value_id FROM static_data_value where type_id = 10018 AND code =  ''),
			3,
			23,
			173,
			194 
			
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR3')
		INSERT INTO operation_unit_configuration (location_id, effective_date, effective_end_date,
	            generator_config_value_id, period_type, fuel_value_id, tou, hour_from, hour_to,
	            unit_from, unit_to)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR3'),
			'2016-09-30 00:00:00.000',
			NULL,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			NULL,
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT value_id FROM static_data_value where type_id = 10018 AND code =  ''),
			NULL,
			NULL,
			9,
			26 
			
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR4')
		INSERT INTO operation_unit_configuration (location_id, effective_date, effective_end_date,
	            generator_config_value_id, period_type, fuel_value_id, tou, hour_from, hour_to,
	            unit_from, unit_to)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR4'),
			'2016-09-30 00:00:00.000',
			NULL,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			NULL,
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT value_id FROM static_data_value where type_id = 10018 AND code =  ''),
			NULL,
			NULL,
			9,
			26 
			
		GO
			
 	
	
SELECT * FROM #missing_gen
							
		GO
		