
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
	FROM generator_data AS gc 
	INNER JOIN #genr g ON g.source_minor_location_id = gc.location_id



		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'APS1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'APS1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  'Duct Burner')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'APS1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'APS1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  'W/O Duct Burner')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'APS1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'APS1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			4,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  'Duct Burner')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'APS1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'APS1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			4,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  'W/O Duct Burner')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'APS1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'APS1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  'Duct Burner')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'APS1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'APS1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.88,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  'W/O Duct Burner')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'APS1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'APS1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  'Duct Burner')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'APS1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'APS1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  'W/O Duct Burner')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR3')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR3'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			'LT',
			5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR3')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR3'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			1,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR3')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR3'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			1,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR3')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR3'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR3')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR3'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM4'),
			NULL,
			1,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR4')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR4'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR4')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR4'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR4')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR4'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR4')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR4'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR4')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR4'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM4'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR5')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR5'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			30,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR5')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR5'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR5')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR5'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'BR5')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'BR5'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'HSM1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'HSM1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'HSM1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'HSM1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			1,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'HSM1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'HSM1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'HSM1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'HSM1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			NULL,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			90,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '1CT')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			90,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '1CT/ST')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			90,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '2CT')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			90,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '2CT/ST')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '1CT')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '1CT/ST')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '2CT')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '2CT/ST')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '1CT')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '1CT/ST')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '2CT')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '2CT/ST')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			18,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '1CT')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			18,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '1CT/ST')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			18,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '2CT')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			18,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '2CT/ST')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM4'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '1CT')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM4'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '1CT/ST')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM4'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '2CT')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'Joffre')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'Joffre'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM4'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '2CT/ST')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'MKR1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'MKR1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			172,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'MKR1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'MKR1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			2.4,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'MKR1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'MKR1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'MKR1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'MKR1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'PH1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'PH1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'PH1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'PH1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			4.16667,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'PH1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'PH1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'PH1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'PH1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			NULL,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'PR1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'PR1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			42,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'PR1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'PR1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'PR1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'PR1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'PR1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'PR1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			NULL,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'RB5')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'RB5'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'RB5')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'RB5'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			5.3,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'RB5')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'RB5'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'RB5')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'RB5'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'RL1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'RL1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'RL1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'RL1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			4.25532,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'RL1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'RL1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'RL1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'RL1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			NULL,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'SH1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'SH1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'SH1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'SH1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'SH1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'SH1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'SH1')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'SH1'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'SH2')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'SH2'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'SH2')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'SH2'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'SH2')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'SH2'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'SH2')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'SH2'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'VVW')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'VVW'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			15,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'VVW')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'VVW'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			4,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'VVW')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'VVW'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'VVW')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'VVW'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'VVW2')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'VVW2'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'Contractual Unit Min'),
			NULL,
			5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'VVW2')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'VVW2'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM1'),
			NULL,
			4,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'VVW2')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'VVW2'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM2'),
			NULL,
			0.5,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		

		IF EXISTS(SELECT 1 FROM source_minor_location WHERE Location_Name = 'VVW2')
		INSERT INTO generator_data(location_id, effective_date, effective_end_date, tou, hour_from, hour_to, data_type_value_id,
	 period_type, data_value, generator_config_value_id)
	 
		SELECT 			
			(SELECT source_minor_location_id FROM source_minor_location where Location_Name = 'VVW2'),
			'2016-09-30 00:00:00.000',
			NULL,
			NULL,
			1,
			24,
			(SELECT value_id FROM static_data_value where type_id = 44500 AND code =  'OM3'),
			NULL,
			0,
			(SELECT value_id FROM static_data_value where type_id = 44800 AND code =  '')
 		GO
 		
	
	
  SELECT * FROM #missing_gen
 		GO

 		