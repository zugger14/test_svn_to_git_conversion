IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_route_group]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_route_group]
GO

CREATE PROC [dbo].[spa_route_group]
@flag AS CHAR(1),
@maintain_location_routes_id AS VARCHAR(MAX) = NULL,
@route_id INT = NULL,
@route_name AS VARCHAR(500) = NULL,
@delivery_location AS INT = NULL,
@delivery_meter_id AS INT = NULL,
@pipeline AS INT = NULL,
@contract_id AS INT = NULL,
@effective_date AS DATETIME = NULL,
@fuel_loss AS FLOAT = NULL,
@primary_secondary AS CHAR(1) = NULL,
@is_group AS VARCHAR(2000) = NULL,
@maintain_location_routes_detail_id AS INT = NULL, -- route_group_id
@route_order_in INT = NULL,
@route_name_text VARCHAR(1000) = NULL,
@location_text VARCHAR(1000) = NULL,
@time_series_definition_id INT = NULL,
@grid_xml TEXT = NULL


AS
SET NOCOUNT ON 

/***************debug code*******************
declare @flag AS CHAR(1),
@maintain_location_routes_id AS VARCHAR(MAX) = NULL,
@route_id INT = NULL,
@route_name AS VARCHAR(500) = NULL,
@delivery_location AS INT = NULL,
@delivery_meter_id AS INT = NULL,
@pipeline AS INT = NULL,
@contract_id AS INT = NULL,
@effective_date AS DATETIME = NULL,
@fuel_loss AS FLOAT = NULL,
@primary_secondary AS CHAR(1) = NULL,
@is_group AS VARCHAR(2000) = NULL,
@maintain_location_routes_detail_id AS INT = NULL, -- route_group_id
@route_order_in INT = NULL,
@route_name_text VARCHAR(1000) = NULL,
@location_text VARCHAR(1000) = NULL,
@time_series_definition_id INT = NULL,
@grid_xml VARCHAR(MAX) = NULL

select @flag='d',@maintain_location_routes_id='4,2,8,9,10',@is_group='yes,no,no,no,no'
--***************debug code*******************/


DECLARE @route_id_val INT
DECLARE @idoc1 INT
DECLARE @idoc INT

IF @flag = 's'
BEGIN
	DECLARE @sql_str VARCHAR(MAX)
	--  added blank with alias grouping_name to get space in frontend path_type column due to annal dai change
	SET @sql_str = 'SELECT  CASE WHEN mlr.is_group = ''y'' THEN	''GROUP ROUTE''  ELSE ''SINGLE ROUTE'' END [Type],								
							mlr.route_name [Route Name],							
							mlr.maintain_location_routes_id [ID],
							CASE WHEN smlo.Location_Name <> smlo.location_id 
								THEN smlo.location_id + '' - '' + smlo.Location_Name 
								ELSE smlo.Location_Name END 
								+ CASE WHEN sml.location_name IS NULL THEN '''' ELSE  '' ['' + sml.location_name + '']'' END  AS [Delivery Location],
							CASE 
								WHEN mlr.primary_secondary = ''p'' THEN ''Primary''
								WHEN mlr.primary_secondary = ''s'' THEN ''Secondary''
						   END AS [Primary/Secondary],
						   dbo.FNADateFormat(mlr.effective_date) AS [Effective Date],
						   mlr.fuel_loss [Fuel Loss],
						   spd.time_series_name [Fuel Loss Group],
						   sc.counterparty_name AS [Pipeline],
						   cg.contract_name AS [Contract],
						   CASE 
								WHEN mlr.is_group = ''y'' THEN ''yes''
								ELSE ''No''
							END AS [Is Group]
					FROM maintain_location_routes mlr
					LEFT JOIN source_minor_location smlo ON mlr.delivery_location = smlo.source_minor_location_id
					LEFT JOIN source_major_location sml ON smlo.source_major_location_ID = sml.source_major_location_ID
					LEFT JOIN meter_id mi ON mlr.delivery_meter_id = mi.meter_id
					LEFT JOIN source_counterparty sc ON mlr.pipeline = sc.source_counterparty_id
					LEFT JOIN contract_group cg ON mlr.contract_id = cg.contract_id			
					LEFT JOIN time_series_definition spd ON mlr.time_series_definition_id = spd.time_series_definition_id
	                WHERE mlr.maintain_location_routes_detail_id IS NULL			
					'
	
	--PRINT (@sql_str)	
	EXEC (@sql_str)	
END
ELSE IF @flag = 'i'
BEGIN
BEGIN TRY
	BEGIN TRAN
		IF EXISTS (SELECT 1 FROM maintain_location_routes WHERE route_name = @route_name AND maintain_location_routes_detail_id IS NULL)
		BEGIN
			EXEC spa_ErrorHandler -1, '', 'spa_nomination_group', 'DBError', 'Route name should not be duplicate.', ''
			RETURN
		END
	
		INSERT INTO maintain_location_routes
		  (
			route_name,
			delivery_location,
			delivery_meter_id,
			pipeline,
			contract_id,
			effective_date,
			fuel_loss,
			primary_secondary,
			is_group,
			maintain_location_routes_detail_id,
			route_description,
			time_series_definition_id
		  )
		VALUES
		  (
			@route_name,
			@delivery_location,
			@delivery_meter_id,
			@pipeline,
			@contract_id,
			@effective_date,
			@fuel_loss,
			@primary_secondary,
			@is_group,
			@maintain_location_routes_detail_id,
			@route_name,
			@time_series_definition_id
		  )
      
		  SET @route_id_val = SCOPE_IDENTITY();
      
		  UPDATE maintain_location_routes
		  SET route_id = @route_id_val
		  WHERE  maintain_location_routes_id = @route_id_val
    COMMIT 
		  EXEC spa_ErrorHandler 0, '', 'spa_route_group', 'Success', 'Changes have been saved successfully.', @route_id_val	
	END TRY
	BEGIN CATCH
		DECLARE @error VARCHAR(5000)
		SET @error = ERROR_MESSAGE()
		EXEC spa_ErrorHandler -1
			, ''--tablename
			, 'spa_route_group'--sp
			, 'DB Error'--error type
			, 'Failed Updating Data.'
			, @error --personal msg
			
		ROLLBACK 
		
	END CATCH
END
ELSE IF @flag = 'u'
BEGIN
BEGIN TRY
	BEGIN TRAN
		IF EXISTS (SELECT 1 FROM maintain_location_routes WHERE route_name = @route_name AND maintain_location_routes_detail_id IS NULL AND maintain_location_routes_id <> @maintain_location_routes_id)
		BEGIN
			EXEC spa_ErrorHandler -1, '', 'spa_route_group', 'DBError', 'Selected data combination already exists.', ''
			RETURN
		END
	
		UPDATE maintain_location_routes
		SET route_name = @route_name,
			delivery_location = @delivery_location,
			delivery_meter_id = @delivery_meter_id,
			pipeline = @pipeline,
			contract_id = @contract_id,
			effective_date = @effective_date,
			fuel_loss = @fuel_loss,
			primary_secondary = @primary_secondary,
			is_group = @is_group,
			maintain_location_routes_detail_id = @maintain_location_routes_detail_id,
			route_description = @route_name,
			time_series_definition_id = @time_series_definition_id
		WHERE maintain_location_routes_id = @maintain_location_routes_id
    
    COMMIT
		EXEC spa_ErrorHandler 0, '', 'spa_nomination_group', 'Success', 'Changes have been saved successfully.', ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, ''--tablename
			, 'spa_route_group'--sp
			, 'DB Error'--error type
			, 'Failed Updating Data.'
			, '' --personal msg
			
		ROLLBACK 
		
	END CATCH
END

ELSE IF @flag = 't'
/******Update for group route******/
BEGIN
BEGIN TRY
	BEGIN TRAN
		IF EXISTS (SELECT 1 FROM maintain_location_routes WHERE route_name = @route_name AND maintain_location_routes_detail_id = @maintain_location_routes_detail_id AND maintain_location_routes_id <> @maintain_location_routes_id)
		BEGIN
			EXEC spa_ErrorHandler -1, '', 'spa_nomination_group', 'DBError', 'Selected data combination already exists.', ''
			RETURN
		END

		IF EXISTS (SELECT 1 FROM maintain_location_routes WHERE route_name = @route_name AND maintain_location_routes_detail_id IS NULL AND maintain_location_routes_id <> @maintain_location_routes_id)
		BEGIN
			EXEC spa_ErrorHandler -1, '', 'spa_nomination_group', 'DBError', 'Route name should not be duplicate.', ''
			RETURN
		END

	
		EXEC sp_xml_preparedocument @idoc1 OUTPUT, @grid_xml
	
		SELECT * INTO #temp_group_route_grid1
		FROM   OPENXML(@idoc1, '/GridGroup/PSRecordset', 2)
				WITH (
					maintain_location_routes_id INT '@route_id',
					route_order INT '@route_order',
					route_name VARCHAR(100) '@route_name',
					delivery_location INT '@delivery_location',
					fuel_loss FLOAT '@fuel_loss',
					fuel_loss_shrinkage_curve INT '@fuel_loss_shrinkage_curve',
					pipeline INT '@pipeline',
					contract INT '@contract',
					effective_date VARCHAR(50) '@effective_date',
					primary_secondary CHAR(1) '@primary_secondary'
				)
	
		
		UPDATE #temp_group_route_grid1
		SET fuel_loss = NULL
		WHERE fuel_loss = -1 

		UPDATE maintain_location_routes
		SET route_name = @route_name,
			delivery_location = @delivery_location,
			delivery_meter_id = @delivery_meter_id,
			pipeline = @pipeline,
			contract_id = @contract_id,
			effective_date = @effective_date,
			fuel_loss = @fuel_loss,
			primary_secondary = @primary_secondary,
			is_group = @is_group,
			maintain_location_routes_detail_id = @maintain_location_routes_detail_id,
			route_description = @route_name,
			time_series_definition_id = @time_series_definition_id
		WHERE maintain_location_routes_id = @maintain_location_routes_id
   

	   --grid rows			 
   
				UPDATE mlr 
				SET 
					route_id = @maintain_location_routes_id,
					route_name = tcg.route_name,
					delivery_location = tcg.delivery_location,
					pipeline = tcg.pipeline,
					contract_id = tcg.contract,
					effective_date = dbo.FNAGetSQLStandardDateTime(tcg.effective_date),
					fuel_loss = case when tcg.fuel_loss = -1 then null else tcg.fuel_loss end,
					primary_secondary = tcg.primary_secondary,
					is_group = 'y',
					maintain_location_routes_detail_id = @maintain_location_routes_id,
					route_order_in = tcg.route_order,
					route_description = tcg.route_name,
					time_series_definition_id = tcg.fuel_loss_shrinkage_curve
					
					FROM #temp_group_route_grid1 tcg
					INNER JOIN maintain_location_routes mlr
					ON tcg.maintain_location_routes_id = mlr.maintain_location_routes_id
							

				DELETE mlr FROM maintain_location_routes mlr
					LEFT JOIN #temp_group_route_grid1 tcg ON tcg.maintain_location_routes_id = mlr.maintain_location_routes_id
					WHERE tcg.maintain_location_routes_id IS NULL AND mlr.maintain_location_routes_detail_id = @maintain_location_routes_id		
			
				INSERT INTO maintain_location_routes 
				(
					route_id,
					route_name,
					delivery_location,
					pipeline,
					contract_id,
					effective_date,
					fuel_loss,
					primary_secondary,
					is_group,
					maintain_location_routes_detail_id,
					route_order_in,
					route_description,
					time_series_definition_id
				)
				SELECT  
					@maintain_location_routes_id,
					tcg.route_name,
					tcg.delivery_location,
					tcg.pipeline,
					tcg.[contract],
					dbo.FNAGetSQLStandardDateTime(tcg.effective_date),
					tcg.fuel_loss,
					tcg.primary_secondary,
					'y',
					@maintain_location_routes_id,
					tcg.route_order,
					tcg.route_name,
					tcg.fuel_loss_shrinkage_curve
				FROM  #temp_group_route_grid1 tcg
				LEFT JOIN maintain_location_routes mlr ON tcg.maintain_location_routes_id = mlr.maintain_location_routes_id
				WHERE tcg.maintain_location_routes_id = 0
			
	COMMIT
		EXEC spa_ErrorHandler 0, '', 'spa_nomination_group', 'Success', 'Changes have been saved successfully.', ''
	
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, ''--tablename
			, 'spa_route_group'--sp
			, 'DB Error'--error type
			, 'Failed Updating Data.'
			, '' --personal msg
			
		ROLLBACK 
		
	END CATCH
END

ELSE IF @flag = 'd'
BEGIN
BEGIN TRY
IF NOT EXISTS(
	SELECT 1 
	FROM source_minor_location_nomination_group smlng 
	INNER JOIN dbo.SplitCommaSeperatedValues(@maintain_location_routes_id) i 
		ON i.item = smlng.group_id
)
BEGIN
	BEGIN TRAN
		--select  s.* from dbo.SplitCommaSeperatedValues('9,10,12,1,2,3,4') s--(@maintain_location_routes_id) s
		--LEFT JOIN source_minor_location_nomination_group smlng
		--	ON s.item = smlng.group_id
		--Where smlng.group_id IS NULL
			
		DELETE mlr
		--select distinct *
		FROM maintain_location_routes mlr
		INNER JOIN dbo.SplitCommaSeperatedValues(@maintain_location_routes_id) i 
		ON i.item = mlr.maintain_location_routes_id
		INNER JOIN dbo.SplitCommaSeperatedValues(REPLACE(REPLACE(@is_group,'no','n'),'yes','y')) j
		ON j.item = mlr.is_group
		WHERE mlr.is_group = 'n'
			
		DELETE mlr
		--select *
		FROM maintain_location_routes mlr
		INNER JOIN dbo.SplitCommaSeperatedValues(@maintain_location_routes_id) i
		ON i.item = mlr.maintain_location_routes_id or i.item = mlr.route_id
		INNER JOIN dbo.SplitCommaSeperatedValues(REPLACE(REPLACE(@is_group,'no','n'),'yes','y')) j
		ON j.item = mlr.is_group
		WHERE mlr.is_group = 'y'
		--select * from maintain_location_routes
		/*
		UPDATE maintain_location_routes
		SET route_order_in = route_order_in - 1
		WHERE route_order_in > @route_order_in AND maintain_location_routes_detail_id = @maintain_location_routes_detail_id
		*/
	COMMIT
	EXEC spa_ErrorHandler 0, '', 'spa_nomination_group', 'Success', 'Changes have been saved successfully.', @maintain_location_routes_id
END
ELSE
BEGIN
	EXEC spa_ErrorHandler -1
			, ''--tablename
			, 'spa_route_group'--sp
			, 'DB Error'--error type
			, 'Data mapped in Setup Location.'
			, '' --personal msg
END
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, ''--tablename
			, 'spa_route_group'--sp
			, 'DB Error'--error type
			, 'Failed Deleting Data.'
			, '' --personal msg
			
		ROLLBACK 
		
	END CATCH
		
END

ELSE IF @flag = 'a'
BEGIN
	SELECT mlr.maintain_location_routes_id,
		   mlr.route_name,
	       mlr.delivery_location,
	       sml.location_name,
	       mlr.delivery_meter_id,
	       mi.recorderid,
	       mlr.pipeline,
	       mlr.contract_id,
	       dbo.FNADateFormat(mlr.effective_date),
	       CAST(mlr.fuel_loss AS VARCHAR(10)) fuel_loss,
	       mlr.primary_secondary,
	       mlr.is_group,
	       mlr.maintain_location_routes_detail_id,
		   mlr.time_series_definition_id
	FROM maintain_location_routes AS mlr
		LEFT JOIN source_minor_location sml ON mlr.delivery_location = sml.source_minor_location_id
		LEFT JOIN meter_id mi ON mlr.delivery_meter_id = mi.meter_id
	WHERE  mlr.maintain_location_routes_id = @maintain_location_routes_id
END
ELSE IF @flag = 'z'
BEGIN
	SELECT  mlr.maintain_location_routes_id AS [route_id],
			mlr.route_order_in AS [route_order],
			mlr.route_description AS [route_name],
			mlr.delivery_location AS [delivery_location],
			--mi.recorderid AS [Delivery Meter],
			mlr.fuel_loss AS [fuel_loss],
			NULLIF(mlr.time_series_definition_id, '') [fuel_loss_shrinkage_curve],
			mlr.pipeline AS [pipeline],
			mlr.contract_id AS [contract],
			dbo.FNADateFormat(mlr.effective_date) AS [effective_date],
			mlr.primary_secondary [primary_secondary]			
	FROM maintain_location_routes mlr
		LEFT JOIN source_minor_location sml ON mlr.delivery_location = sml.source_minor_location_id
		LEFT JOIN meter_id mi ON mlr.delivery_meter_id = mi.meter_id
		LEFT JOIN source_counterparty sc ON mlr.pipeline = sc.source_counterparty_id
		LEFT JOIN contract_group cg ON mlr.contract_id = cg.contract_id
	WHERE mlr.maintain_location_routes_detail_id = @maintain_location_routes_id
	ORDER BY mlr.route_order_in ASC
END
ELSE IF @flag = 'r'
BEGIN
BEGIN TRY
	BEGIN TRAN	
		IF EXISTS (SELECT 1 FROM maintain_location_routes WHERE route_name = @route_name AND maintain_location_routes_detail_id = @maintain_location_routes_detail_id)
		BEGIN
			EXEC spa_ErrorHandler -1, '', 'spa_nomination_group', 'DBError', 'Selected data combination already exists.', ''
			RETURN
		END

		IF EXISTS (SELECT 1 FROM maintain_location_routes WHERE route_name = @route_name AND @maintain_location_routes_id IS NULL)
		BEGIN
			EXEC spa_ErrorHandler -1, '', 'spa_nomination_group', 'DBError', 'Route name should not be duplicate.', ''
			RETURN
		END
	
		EXEC sp_xml_preparedocument @idoc OUTPUT, @grid_xml
	
		SELECT * INTO #temp_group_route_grid
		FROM   OPENXML(@idoc, '/GridGroup/PSRecordset', 2)
				WITH (
					route_id INT '@route_id',
					route_order INT '@route_order',
					route_name VARCHAR(100) '@route_name',
					delivery_location INT '@delivery_location',
					fuel_loss FLOAT '@fuel_loss',
					fuel_loss_shrinkage_curve INT '@fuel_loss_shrinkage_curve',
					pipeline INT '@pipeline',
					contract INT '@contract',
					effective_date VARCHAR(50) '@effective_date',
					primary_secondary CHAR(1) '@primary_secondary'
				)

		UPDATE #temp_group_route_grid
		SET fuel_loss = NULL
		WHERE fuel_loss = -1
			
		INSERT INTO maintain_location_routes
		  (
			route_name,
			delivery_location,
			delivery_meter_id,
			pipeline,
			contract_id,
			effective_date,
			fuel_loss,
			primary_secondary,
			is_group,
			maintain_location_routes_detail_id,
			route_description,
			time_series_definition_id
		  )
		VALUES
		  (
			@route_name,
			@delivery_location,
			@delivery_meter_id,
			@pipeline,
			@contract_id,
			@effective_date,
			@fuel_loss,
			@primary_secondary,
			@is_group,
			@maintain_location_routes_detail_id,
			@route_name,
			@time_series_definition_id
		  )
      
      
		  SET @route_id_val = SCOPE_IDENTITY();
      
		  INSERT INTO maintain_location_routes 
				(
					route_id,
					route_name,
					delivery_location,
					delivery_meter_id,
					pipeline,
					contract_id,
					effective_date,
					fuel_loss,
					primary_secondary,
					is_group,
					maintain_location_routes_detail_id,
					route_order_in,
					route_description,
					time_series_definition_id
				)
				SELECT  
					@route_id_val,
					route_name,
					delivery_location,
					delivery_location,
					pipeline,
					[contract],
					effective_date,
					fuel_loss,
					primary_secondary,
					'y',
					@route_id_val,
					route_order,
					route_name,
					fuel_loss_shrinkage_curve
				FROM  #temp_group_route_grid tcg
			
		
	COMMIT
		EXEC spa_ErrorHandler 0, '', 'spa_nomination_group', 'Success', 'Changes have been saved successfully.', @route_id_val
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, ''--tablename
			, 'spa_route_group'--sp
			, 'DB Error'--error type
			, 'Failed Updating Data.'
			, '' --personal msg
			
		ROLLBACK 
		
	END CATCH
END

ELSE IF @flag = 'l'
BEGIN
	SELECT sml1.source_minor_location_id,
		       CASE WHEN sml1.Location_Name <> sml1.location_id THEN sml1.location_id + ' - ' + sml1.Location_Name ELSE sml1.Location_Name END + CASE WHEN sml2.location_name IS NULL THEN '' ELSE  ' [' + sml2.location_name + '] ' END  [name]
	 FROM source_minor_location sml1
		LEFT JOIN source_major_location sml2 ON sml2.source_major_location_id = sml1.source_major_location_id
	 WHERE sml2.location_name IN ('M2','Gathering System','Storage','Pool','DM')
	 ORDER BY CASE WHEN sml1.Location_Name <> sml1.location_id THEN sml1.location_id + ' - ' + sml1.Location_Name ELSE sml1.Location_Name END + CASE WHEN sml2.location_name IS NULL THEN '' ELSE  ' [' + sml2.location_name + '] ' END
END

ELSE IF @flag = 'y' -- pipeline dropdown and grid
BEGIN	
	SELECT sc.source_counterparty_id [ID],
		   	CASE  
				WHEN sc.source_system_id = 2 THEN '' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + ' - ' + sc.counterparty_name END 
				ELSE ssd.source_system_name + '.' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + ' - ' + sc.counterparty_name END 
			END  [Pipeline Name]
	FROM source_counterparty sc
	INNER JOIN source_system_description ssd ON ssd.source_system_id = sc.source_system_id
	INNER JOIN static_data_value sdv ON sdv.value_id = sc.type_of_entity 
	WHERE sc.type_of_entity = 301994
	ORDER BY CASE  
				WHEN sc.source_system_id = 2 THEN '' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + ' - ' + sc.counterparty_name END 
				ELSE ssd.source_system_name + '.' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + ' - ' + sc.counterparty_name END 
			END 
END

ELSE IF @flag = 'h' -- fuel_loss_shrinkage_curve dropdown and grid
BEGIN	
	SET @sql_str = 'SELECT time_series_definition_id, name 
					FROM (SELECT NULL [time_series_definition_id], '''' [name]
							UNION ALL
							(
							SELECT time_series_definition_id [time_series_definition_id], time_series_name [name] 
							FROM time_series_definition tsd
							INNER JOIN static_data_value sdv ON sdv.value_id = tsd.time_series_type_value_id 
							WHERE sdv.value_id = 39003
							) ) a
					WHERE 1 = 1 '
	IF @route_order_in IS NULL
	SET @sql_str = @sql_str + ' AND  time_series_definition_id IS NOT NULL '
	SET @sql_str = @sql_str + ' ORDER BY [name]'
	--PRINT (@sql_str)
	EXEC (@sql_str)
END

ELSE IF @flag = 'g' -- list contract group
BEGIN	
	SELECT cg.contract_id [ID],
		CASE WHEN cg.source_contract_id <> cg.[contract_name] THEN cg.source_contract_id + ' - ' + cg.[contract_name] ELSE cg.[contract_name] END  [Contract Name]
	FROM contract_group cg 
	WHERE cg.contract_type_def_id = 38402
		 --AND cg.is_active = 'y'
	ORDER BY CASE WHEN cg.source_contract_id <> cg.[contract_name] THEN cg.source_contract_id + ' - ' + cg.[contract_name] ELSE cg.[contract_name] END	
END


ELSE IF @flag = 'c' -- copy route
BEGIN
BEGIN TRY
	BEGIN TRAN	
	DECLARE @route_temp_name VARCHAR(200)
	DECLARE @route_temp_num INT
	
	SELECT @route_temp_name = route_name FROM maintain_location_routes WHERE maintain_location_routes_id = @maintain_location_routes_id
	
	SELECT @route_temp_num = ROW_NUMBER() OVER(ORDER BY mlr.maintain_location_routes_id) FROM maintain_location_routes mlr WHERE mlr.route_name = 'Copy of ' + @route_temp_name
		
	INSERT INTO maintain_location_routes
      (
        route_name,
        delivery_location,
        delivery_meter_id,
        pipeline,
        contract_id,
        effective_date,
        fuel_loss,
        primary_secondary,
        is_group,
        maintain_location_routes_detail_id,
		route_description,
		time_series_definition_id
      )
   SELECT  
		--'Copy of ' + route_name,
		'Copy of ' + route_name + CASE WHEN @route_temp_num > 0 THEN ' ' + CAST(@route_temp_num AS VARCHAR(5)) ELSE '' END,
        delivery_location,
        delivery_meter_id,
        pipeline,
        contract_id,
        effective_date,
        fuel_loss,
        primary_secondary,
        is_group,
        maintain_location_routes_detail_id,
		'Copy of ' + route_description + CASE WHEN @route_temp_num > 0 THEN ' ' + CAST(@route_temp_num AS VARCHAR(5)) ELSE '' END,
		time_series_definition_id
	FROM  maintain_location_routes mlr
   WHERE mlr.maintain_location_routes_id = @maintain_location_routes_id
   
   SET @route_id_val = SCOPE_IDENTITY();
   
   --SELECT @route_temp_name = route_name FROM maintain_location_routes WHERE maintain_location_routes_id = @route_id_val
   --SELECT ROW_NUMBER() FROM maintain_location_routes mlr WHERE mlr.route_name
   
   IF EXISTS (SELECT 1 FROM maintain_location_routes WHERE maintain_location_routes_id <> @route_id_val)
   
   IF @is_group = 'y'
   BEGIN
   		
   		INSERT INTO maintain_location_routes 
			(
				route_id,
				route_name,
				delivery_location,
				delivery_meter_id,
				pipeline,
				contract_id,
				effective_date,
				fuel_loss,
				primary_secondary,
				is_group,
				maintain_location_routes_detail_id,
				route_order_in,
				route_description,
				time_series_definition_id
			)
			SELECT  
				@route_id_val,
				route_name,
				delivery_location,
				delivery_meter_id,
				pipeline,
				contract_id,
				effective_date,
				fuel_loss,
				primary_secondary,
				is_group,
				@route_id_val,
				route_order_in,
				route_description,
				time_series_definition_id
			FROM  maintain_location_routes mlr
			WHERE mlr.route_id = @maintain_location_routes_id
   END
   ELSE
   	BEGIN
		UPDATE maintain_location_routes
			SET route_id = @route_id_val
		WHERE  maintain_location_routes_id = @route_id_val
   	END

	COMMIT
    EXEC spa_ErrorHandler 0, '', 'spa_nomination_group', 'Success', 'Changes have been saved successfully.', @route_id_val
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, ''--tablename
			, 'spa_route_group'--sp
			, 'DB Error'--error type
			, 'Failed copying Data.'
			, '' --personal msg
			
		ROLLBACK 
		
	END CATCH

END
