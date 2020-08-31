
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
	DELETE gc
	FROM generator_characterstics AS gc 
	INNER JOIN #genr g ON g.source_minor_location_id = gc.location_id
	--WHERE g.generator = 'br3'
		
	
	
		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'APS1')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'APS1'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  'Duct Burner'),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			14,
			0,
 			NULL,
			1,
			194,
			0
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'APS1')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'APS1'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  'Unused'),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			NULL,
			14,
			NULL,
 			NULL,
			173,
			194,
			0
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'APS1')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'APS1'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  'W/O Duct Burner'),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			6.79,
			0,
 			NULL,
			1,
			194,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR3')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR3'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Coal'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'Coal Curve'),
			0,
			11.24,
			145.47,
 			10,
			1,
			149,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR3')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR3'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			11,
			0,
 			10,
			1,
			149,
			0
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR4')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR4'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Coal'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'Coal Curve'),
			0,
			11.02,
			134.74,
 			NULL,
			1,
			155,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR4')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR4'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			11,
			0,
 			NULL,
			1,
			155,
			0
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR5')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR5'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Coal'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'Coal Curve'),
			0,
			10.21,
			266.98,
 			NULL,
			1,
			385,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'HSM1')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'HSM1'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0.0004,
			5,
			25,
 			NULL,
			1,
			6,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '1CT'),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			8.68,
			-186,
 			NULL,
			1,
			165,
			0
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '1CT/ST'),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			6.62,
			89,
 			NULL,
			1,
			220,
			0
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '2CT'),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			8.68,
			216,
 			NULL,
			1,
			350,
			0
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '2CT/ST'),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			6.62,
			264,
 			NULL,
			1,
			460,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'MKR1')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'MKR1'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			5.5,
			0,
 			NULL,
			0,
			202,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'OMRH')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'OMRH'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			0,
			0,
 			NULL,
			1,
			32,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'PH1')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'PH1'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			7.8,
			80,
 			NULL,
			1,
			48,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'PR1')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'PR1'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			5.2,
			0,
 			NULL,
			1,
			100,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'RB5')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'RB5'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			7.8,
			80,
 			NULL,
			1,
			50,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'RL1')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'RL1'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			8.1,
			0,
 			NULL,
			1,
			47,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'SH1')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'SH1'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Coal'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'Coal Curve'),
			0,
			10.03,
			261.71,
 			NULL,
			1,
			390,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'SH2')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'SH2'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Coal'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'Coal Curve'),
			0,
			10.03,
			261.71,
 			NULL,
			1,
			390,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'VVW')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'VVW'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			7.8,
			80,
 			NULL,
			1,
			50,
			1
		GO
		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'VVW2')
		INSERT INTO generator_characterstics (location_id, effective_date, generator_config_value_id,
	            fuel_value_id, fuel_curve_id, coeff_a, coeff_b, coeff_c, heat_rate,
	            unit_min, unit_max, is_default)
		SELECT  
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'VVW2'),
			'2016-09-30 00:00:00.000',
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  ''),
			(SELECT value_id FROM static_data_value where type_id = 10023 AND code =  'Gas'),
			(SELECT source_curve_def_id FROM source_price_curve_def where curve_id =  'AECO 5A'),
			0,
			7.8,
			80,
 			NULL,
			1,
			50,
			1
		GO
		
	
SELECT * FROM #missing_gen
				
				
						