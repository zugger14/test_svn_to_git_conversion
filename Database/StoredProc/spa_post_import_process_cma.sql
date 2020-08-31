

/****** Object:  StoredProcedure [dbo].[spa_post_import_process_cma]    Script Date: 01/09/2012 17:10:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_post_import_process_cma]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_post_import_process_cma]
GO

/****** Object:  StoredProcedure [dbo].[spa_post_import_process_cma]    Script Date: 01/09/2012 17:10:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[spa_post_import_process_cma]
	@as_of_date DATETIME = NULL,
	@process_id VARCHAR(100) = NULL,
	@system_id VARCHAR(10) = 2

AS  


/*
	DECLARE @as_of_date DATETIME, @process_id VARCHAR(100),@system_id VARCHAR(10) 
	DECLARE @curve_id INT
	SET @as_of_date ='2011-10-29'
	SET @curve_id=82

--*/

BEGIN
	DECLARE @elapsed_sec  FLOAT
	DECLARE @errorcode    CHAR(1)


	--Audit table log
	IF NOT EXISTS(SELECT 1 FROM   import_data_files_audit WHERE  process_id = @process_id)
		EXEC spa_import_data_files_audit 'i', @as_of_date, NULL, @process_id, 'Import CMA Data', 
					 'CMA Data Sync(Table No.:4008)', @as_of_date, 'p', NULL, NULL, NULL, @system_id

	IF OBJECT_ID('tempdb..#cma_curve_import_source') IS NOT NULL
		DROP TABLE #cma_curve_import_source
	
	DECLARE @cma_curve AS TABLE(source_curve_def_id INT,settlement_curve_type_value_id INT,copy_curve_def_id INT,use_expiration_calendar CHAR(1),expiration_calendar_id INT)

	-- @cma_curve holds CMA curves
	INSERT INTO @cma_curve(source_curve_def_id,settlement_curve_type_value_id,copy_curve_def_id,use_expiration_calendar,expiration_calendar_id)
	
	--Find the curve id for forward and settled which does not use expiration calendar and whose curve is missing for as of date
	SELECT DISTINCT spcd.source_curve_def_id,spccr.settlement_curve_type_value_id,spccr.copy_curve_def_id,spccr.use_expiration_calendar,spcd.exp_calendar_id
	FROM 
		source_price_curve_def spcd 
		INNER JOIN source_price_curve_copy_rule spccr ON spccr.source_curve_def_id = spcd.source_curve_def_id 
		LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id 
			AND spc.as_of_date = @as_of_date
	WHERE 
		--CHARINDEX('CMA', spcd.market_value_id) = 1 AND  
		spccr.use_expiration_calendar = 'n'
		AND spc.curve_value IS NULL
		
	UNION
	
	--Find the curve id for settled which uses expiration calendar and whose curve is missing for as of date
	SELECT DISTINCT spcd.source_curve_def_id,spccr.settlement_curve_type_value_id,spccr.copy_curve_def_id,spccr.use_expiration_calendar,spcd.exp_calendar_id
	FROM 
		source_price_curve_def spcd 
		INNER JOIN source_price_curve_copy_rule spccr ON spccr.source_curve_def_id = spcd.source_curve_def_id 
		INNER JOIN holiday_group hg ON hg.hol_group_value_id = spcd.exp_calendar_id
			AND hg.exp_date = @as_of_date
		LEFT JOIN source_price_curve spc ON spc.source_curve_def_id = spcd.source_curve_def_id 
			AND hg.hol_date = spc.maturity_date
			AND hg.exp_date = spc.as_of_date
	WHERE 
		--CHARINDEX('CMA', spcd.market_value_id) = 1 AND
		spccr.use_expiration_calendar = 'y'
		--and spcd.source_curve_def_id=82
		AND spc.curve_value IS NULL
	

	-- insert into tmp table if Data Sync is required
	----##### Find the maximum price for  curves to copy from
	CREATE TABLE #cma_curve_import_source(source_curve_def_id INT ,as_of_date DATETIME ,maturity_date DATETIME ,is_dst CHAR(1) COLLATE DATABASE_DEFAULT,curve_value FLOAT,Assessment_curve_type_value_id INT , curve_source_value_id INT,bid_value FLOAT,ask_value FLOAT)
	
	-- Find The Price from the Curve for Maximum available date for forward curves
	INSERT INTO #cma_curve_import_source(source_curve_def_id,as_of_date,maturity_date,is_dst,curve_value,Assessment_curve_type_value_id ,curve_source_value_id,bid_value,ask_value)
	SELECT 
		a.source_curve_def_id,
		@as_of_date,
		spc.maturity_date,
		spc.is_dst,
		spc.curve_value,
		spc.Assessment_curve_type_value_id,
		spc.curve_source_value_id,
		spc.bid_value,
		spc.ask_value
	FROM
	(
		SELECT 
				cc.source_curve_def_id, 
				MAX(spc_available.as_of_date) as_of_date_available,
				MAX(cc.settlement_curve_type_value_id) settlement_curve_type_value_id,
				MAX(use_expiration_calendar) use_expiration_calendar
		FROM 
			@cma_curve cc
			INNER JOIN source_price_curve spc_available ON cc.source_curve_def_id = spc_available.source_curve_def_id
		WHERE 
			spc_available.as_of_date < @as_of_date
		GROUP BY 
			cc.source_curve_def_id
	) a
	LEFT JOIN source_price_curve spc ON a.source_curve_def_id=spc.source_curve_def_id
		AND a.as_of_date_available = spc.as_of_date
	INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = a.source_curve_def_id		
		
	WHERE
			--- For forward bring only forward months
			( ( spc.maturity_date >=  @as_of_date AND spcd.Granularity = 981 ) -- if daily granularity
			OR
			( spc.maturity_date >=  @as_of_date AND spcd.Granularity = 982 ) -- if hourly granularity
			OR 
			-- if other granularity
			( ( YEAR(spc.maturity_date) >=  YEAR(@as_of_date) OR MONTH(spc.maturity_date) >=  MONTH(@as_of_date) ) AND spcd.Granularity NOT IN (981,982) )
			)
		AND settlement_curve_type_value_id IS NULL
		AND use_expiration_calendar  = 'n'
			
	UNION
	
-- Find settled curve which does not have expiration calendar	
	SELECT 
		a.source_curve_def_id,
		@as_of_date,
		spc.maturity_date,
		spc.is_dst,
		spc.curve_value,
		spc.Assessment_curve_type_value_id,
		spc.curve_source_value_id,
		spc.bid_value,
		spc.ask_value
	FROM
	(
		SELECT 
				cc.source_curve_def_id, 
				MAX(spc_available.as_of_date) as_of_date_available,
				MAX(cc.settlement_curve_type_value_id) settlement_curve_type_value_id,
				MAX(use_expiration_calendar) use_expiration_calendar
		FROM 
			@cma_curve cc
			INNER JOIN source_price_curve spc_available ON cc.source_curve_def_id = spc_available.source_curve_def_id
		WHERE 
			spc_available.as_of_date < @as_of_date
		GROUP BY 
			cc.source_curve_def_id
	) a
	LEFT JOIN source_price_curve spc ON a.source_curve_def_id=spc.source_curve_def_id
		AND a.as_of_date_available = spc.as_of_date	
		
	WHERE
			spc.maturity_date <=  @as_of_date --- For forward bring only forward months
		AND settlement_curve_type_value_id IS NOT NULL	
		AND use_expiration_calendar  = 'n'
	UNION
	
	-- Find The Price from the Curve for Maximum available date for Settled curves
	SELECT 
		a.source_curve_def_id,
		@as_Of_date,
		(CONVERT(VARCHAR(10),hg.hol_date,101) +' '+ CONVERT(VARCHAR(10),spc.maturity_date,108)),
		spc.is_dst,
		spc.curve_value,
		spc.Assessment_curve_type_value_id,
		spc.curve_source_value_id,
		spc.bid_value,
		spc.ask_value
	FROM
	(
		SELECT 
				cc.source_curve_def_id, 
				MAX(spc_available.as_of_date) as_of_date_available,
				MAX(cc.settlement_curve_type_value_id) settlement_curve_type_value_id,
				MAX(expiration_calendar_id) expiration_calendar_id
		FROM 
			@cma_curve cc
			INNER JOIN source_price_curve spc_available ON cc.source_curve_def_id = spc_available.source_curve_def_id
		WHERE 
			spc_available.as_of_date < @as_of_date
		GROUP BY 
			cc.source_curve_def_id
	) a
	LEFT JOIN source_price_curve spc ON a.source_curve_def_id=spc.source_curve_def_id
		AND a.as_of_date_available = spc.as_of_date	
	LEFT JOIN holiday_group hg ON hg.hol_group_value_id =  a.expiration_calendar_id
		AND hg.exp_date = @as_of_date	
	WHERE
			settlement_curve_type_value_id IS NOT NULL
		AND hg.exp_date IS NOT NULL
		

		
----####### DST Logic
-- Check for DST hours. Delete extra hours from March
	DELETE 
		ccis
	FROM
		#cma_curve_import_source ccis
	INNER JOIN mv90_DST mv ON CONVERT(VARCHAR(10),ccis.maturity_date,120) = CONVERT(VARCHAR(10),mv.[date],120)
		AND mv.insert_delete = 'd'
		AND mv.[Hour] =DATEPART(hh,ccis.maturity_date)+1
	
-- Delete dst_hours if it is not DST DATE
	DELETE 
		ccis
	FROM
		#cma_curve_import_source ccis
	LEFT JOIN mv90_DST mv ON CONVERT(VARCHAR(10),ccis.maturity_date,120) = CONVERT(VARCHAR(10),mv.[date],120)
		AND mv.insert_delete = 'i'
		AND mv.[Hour] =DATEPART(hh,ccis.maturity_date)+1
	WHERE
		ccis.is_dst = 1
		AND mv.[Hour] IS NULL


	--select * from #cma_curve_import_source where is_dst=1
	-- Add extra hour for DST in October
	
	INSERT INTO #cma_curve_import_source(source_curve_def_id,as_of_date,maturity_date,is_dst,curve_value, Assessment_curve_type_value_id, curve_source_value_id, bid_value,ask_value)
	SELECT 		
		
		source_curve_def_id,as_of_date,maturity_date,1,MAX(curve_value),
		MAX(Assessment_curve_type_value_id), MAX(curve_source_value_id), 
		MAX(bid_value),MAX(ask_value)
	FROM
		#cma_curve_import_source ccis
		LEFT JOIN mv90_DST mv ON CONVERT(VARCHAR(10),ccis.maturity_date,120) = CONVERT(VARCHAR(10),mv.[date],120)
			AND mv.insert_delete = 'i'
			AND mv.[Hour] =DATEPART(hh,ccis.maturity_date)+1
			--AND ccis.is_dst = 0
	WHERE
		mv.[hour] IS NOT NULL
	GROUP BY 
		source_curve_def_id,as_of_date,maturity_date
	HAVING COUNT(*)=1	
		



	IF EXISTS( SELECT 1 FROM #cma_curve_import_source )
	BEGIN
		EXEC spa_print 'Sync Is Required.' 
		BEGIN TRY                                          	
			BEGIN TRAN
			-- for settlement curve
			INSERT INTO source_price_curve(source_curve_def_id, as_of_date, Assessment_curve_type_value_id, curve_source_value_id, maturity_date, curve_value, bid_value,ask_value, is_dst)
			SELECT 
				ccis.source_curve_def_id, 
				as_of_date, 
				ccis.Assessment_curve_type_value_id, 
				ccis.curve_source_value_id,		
				ccis.maturity_date,		
				ccis.curve_value, 
				ccis.bid_value, 
				ccis.ask_value, 
				ccis.is_dst
			FROM 
				#cma_curve_import_source ccis 

			select @process_id

			INSERT INTO source_system_data_import_status(process_id,code,module,[source],[type],[description],recommendation) 
			SELECT @process_id, 'Success', 'CMA Price Curve', 'Price Curves from previous as of dates',
			'Copy data for missing as_of_date', CAST(COUNT(ccis.source_curve_def_id) AS VARCHAR(15)) + ' Price Curve Imported for ' + CAST( COUNT(DISTINCT spcd.curve_id) AS VARCHAR(5)) + ' CMA curves', 'N/A'
			FROM 
				#cma_curve_import_source ccis
				LEFT JOIN source_price_curve_def spcd ON ccis.source_curve_def_id=spcd.source_curve_def_id


			INSERT INTO source_system_data_import_status_detail(process_id, [source], [type], [description])
			SELECT 
				@process_id, 'Curve ID: ' + spcd.curve_id , 'CMA Price Curve', CAST(COUNT(ccis.source_curve_def_id) AS VARCHAR(12)) + ' rows copied. Source As of date: ' + CAST(ccis.as_of_date AS VARCHAR(12))
			FROM #cma_curve_import_source ccis
				INNER JOIN source_price_curve_def spcd ON ccis.source_curve_def_id = spcd.source_curve_def_id 
			GROUP BY 
				spcd.curve_id, ccis.as_of_date

			IF EXISTS (SELECT 1 FROM source_system_data_import_status WHERE process_id=@process_id AND [code] <> 'Success')
				SET @errorcode = 'e'
			ELSE
				SET @errorcode = 's'		
			
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0 
 				ROLLBACK
				
			DECLARE @error_msg VARCHAR(1000)
			SET @error_msg = ERROR_MESSAGE()
			SET @errorcode = 'e'
			EXEC spa_print 'Catch Error: ', @error_msg
			
			INSERT INTO source_system_data_import_status(process_id,code,module,[source],[type],[description],recommendation) 
			SELECT @process_id, 'Error', 'CMA Price Curve', 'Price Curves from previous as of dates',
			'Copy data for missing as_of_date', 'Error Occured' , 'N/A'
			
		END CATCH
	END 
	ELSE
	BEGIN
		EXEC spa_print 'Sync Not Required.'
		SET @errorcode = 's'	
		INSERT INTO source_system_data_import_status(process_id,code,module,[source],[type],[description],recommendation) 
		SELECT @process_id, 'Success', 'CMA Price Curve', 'Price Curves from previous as of dates',
		'Copy data for missing as_of_date', 'No data is required to Sync with previous as of date' , 'N/A'
	END
	
	SELECT @elapsed_sec = DATEDIFF(second, create_ts, GETDATE()) FROM import_data_files_audit idfa
	WHERE idfa.process_id = @process_id		
	
	--audit table log update total execution time
	EXEC spa_import_data_files_audit
		@flag = 'u',
		@process_id = @process_id, 
		@status = @errorcode,
		@elapsed_time = @elapsed_sec	
END
GO


