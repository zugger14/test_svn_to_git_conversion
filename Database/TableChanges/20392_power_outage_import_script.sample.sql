 
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

	SELECT DISTINCT 'Generator:' + scsv.item + CASE WHEN sml.source_minor_location_id IS NULL THEN ' Not found' ELSE ' imported' END power_outage INTO #missing_gen    
    FROM dbo.SplitCommaSeperatedValues(@generator) AS scsv
    LEFT JOIN source_minor_location sml ON sml.Location_Name  = scsv.item
    --WHERE sml.source_minor_location_id IS NULL
  	   
    
	--SELECT *
	DELETE gc
	FROM power_outage AS gc 
	INNER JOIN #genr g ON g.source_minor_location_id = gc.source_generator_id

	



SELECT * FROM #missing_gen
  
 	GO
 	