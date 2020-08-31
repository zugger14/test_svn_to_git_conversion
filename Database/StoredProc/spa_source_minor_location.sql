
/****** Object:  StoredProcedure [dbo].[spa_source_minor_location]    Script Date: 07/28/2009 18:00:38 ******/
IF EXISTS (SELECT * FROM   sys.objects WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_source_minor_location]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_source_minor_location]
/****** Object:  StoredProcedure [dbo].[spa_source_minor_location]    Script Date: 07/28/2009 18:00:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
/*
	Modified By:Pawan KC
	Modification Date:23/03/2009
	Description: Added Parameters @owner,@operator,@contract,@volume,@uom,@region,@is_pool,@term_pricing_index
				 as Tables source_minor_location,minor_location_detail are merged and Made necessary changes in the i,u,a,d blocks.
*/

CREATE PROC [dbo].[spa_source_minor_location]
    @flag VARCHAR(100),
    @source_minor_location_ID VARCHAR(500) = NULL,
    @source_system_id [int] = NULL,
    @source_major_location_ID VARCHAR(500) = NULL,
    @Location_Name VARCHAR(100) = NULL,
    @Location_Description VARCHAR(50) = NULL,
    @Meter_ID VARCHAR(100) = NULL,
    @Pricing_Index INT = NULL,
    @Commodity_id INT = NULL,
    @location_type INT = NULL,
    @time_zone INT = NULL,
    @owner VARCHAR(100) = NULL,
    @operator VARCHAR(100) = NULL,
    @contract INT = NULL,
    @volume FLOAT = NULL,
    @uom INT = NULL,
    @region VARCHAR(1000) = NULL,
    @is_pool CHAR(1) = NULL,
    @term_pricing_index INT = NULL,
    @bid_offer_formulator_id INT = NULL,
    @profile INT = NULL,
    @proxy_profile INT = NULL,
    @grid_value_id INT = NULL,
    @country INT = NULL,
    @is_active VARCHAR(1) = NULL,
    @postal_code VARCHAR(100) = NULL,
    @province VARCHAR(100) = NULL, 
    @physical_shipper VARCHAR(100) = NULL,
    @profile_code VARCHAR(100) = NULL,
    @nominator_sap_code VARCHAR(100) = NULL,
    @forecasting_group VARCHAR(100) = NULL,
    @forecast_needed CHAR(1) = NULL,
    @calc_method VARCHAR(100) = NULL,
    @location_id VARCHAR(1000) = NULL,
    @location_name_group BIT = 0,
    @show_only_storage CHAR(1) = 'n',
	@not_in_location_name VARCHAR(500) = NULL,
	@proxy_location_id VARCHAR(500) = NULL,
	@filter_value VARCHAR(1000) = NULL
    
AS 
SET NOCOUNT ON
DECLARE @Sql_Select    VARCHAR(8000),
        @msg_err       VARCHAR(2000),
        @error_number  INT

IF @source_system_id IS NULL
    SET @source_system_id = 2

/**
 * This block is added for the browser field selected values only
 * There will be no need to check the privilege for this
 * Performance enhancement
 */
IF @flag = 'o' AND NULLIF(@filter_value, '<FILTER_VALUE>') IS NOT NULL
BEGIN
	SELECT sml.source_minor_location_id [id], sml.Location_Name [name], 'Enable' [status]
	FROM source_minor_location sml
	INNER JOIN dbo.SplitCommaSeperatedValues(@filter_value) s
		ON s.item = sml.source_minor_location_id
	
	RETURN
END

IF @flag IN('o', 'l', 'r', 'b') --Collect Location Privilege
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'location'
END

IF @flag = 'get_storage_location'
BEGIN 
	CREATE TABLE #get_storage_location(source_minor_location_id INT, [name] VARCHAR(1000) COLLATE DATABASE_DEFAULT, [status] VARCHAR(100) COLLATE DATABASE_DEFAULT)
	INSERT INTO #get_storage_location
	EXEC spa_source_minor_location  'o'

	SELECT gsl.source_minor_location_id, gsl.[name], gsl.[status] 
	FROM #get_storage_location gsl
	INNER JOIN source_minor_location sml ON sml.source_minor_location_id = gsl.source_minor_location_id
	INNER JOIN source_major_location smjr ON smjr.source_major_location_ID = sml.source_major_location_ID
	WHERE smjr.location_name = 'Storage'
END 

IF @flag = 'post_insert'
BEGIN
		IF OBJECT_ID('tempdb..#deal_to_calc') IS NOT NULL	
				DROP TABLE #deal_to_calc
		CREATE TABLE #deal_to_calc(source_deal_header_id INT)

		INSERT INTO dbo.process_deal_position_breakdown (source_deal_header_id,create_user,create_ts,process_status,insert_type,deal_type,commodity_id,fixation,internal_deal_type_value_id)
				OUTPUT INSERTED.source_deal_header_id INTO #deal_to_calc(source_deal_header_id)
			SELECT sdh.source_deal_header_id, MAX(sdh.create_user), GETDATE(), 9 process_status, 0 deal_type, MAX(ISNULL(sdh.internal_desk_id, 17300)) deal_type, 
			MAX(ISNULL(spcd.commodity_id, -1)) commodity_id, MAX(ISNULL(sdh.product_id, 4101)) fixation, MAX(ISNULL(sdh.internal_deal_type_value_id, -999999))
			FROM source_deal_detail sdd 
			INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id and sdd.curve_id IS NOT NULL
			WHERE sdd.location_id = @source_minor_location_id
			GROUP BY sdh.source_deal_header_id

		IF EXISTS(SELECT 1 FROM #deal_to_calc)
			EXEC dbo.spa_calc_pending_deal_position @call_from = 1	
END

IF @flag = 'l' OR @flag = 's' OR @flag = 'c' OR @flag = 'w'
BEGIN
	IF @flag = 's'
	BEGIN	
		SET @Sql_Select = ' 	
			SELECT s.source_minor_location_ID [ID],
				   CASE 
						WHEN source_Major_Location.location_name IS NULL THEN ''''
						ELSE source_Major_Location.location_name + '' - > ''
				   END + S.[Location_Name] AS [Name],
				   S.[Location_Description] AS [Description],
				   S.[Meter_ID] AS [Meter ID],
				   spcd.curve_name [Spot Index],
				   spcd1.curve_name [Term Index],
				   source_commodity.[Commodity_id] [Commodity ID],
				   sdv.[code] AS [Location Type],
				   sdv1.[code] AS [Time Zone],
				   s.bid_offer_formulator_id,
				   S.[create_user] [Created User],
				   dbo.FNADateTimeFormat(S.[create_ts], 1) [Created Date],
				   S.[update_user] [Updated User],
				   dbo.FNADateTimeFormat(S.[update_ts], 1) [Updated Date]
			FROM   [dbo].source_minor_location S
			LEFT JOIN source_price_curve_def spcd ON S.[Pricing_Index]=spcd.source_curve_def_id
			LEFT JOIN source_price_curve_def spcd1 ON S.[term_pricing_index]=spcd1.source_curve_def_id
			left JOIN source_commodity ON S.Commodity_id=source_commodity.source_commodity_id
			LEFT JOIN source_Major_Location ON S.source_Major_Location_Id=source_Major_Location.source_major_location_ID
			LEFT JOIN static_data_value sdv ON Sdv.value_id=S.location_type
			LEFT JOIN static_data_value sdv1 ON Sdv1.value_id=S.time_zone
			WHERE 1=1'
	END 
	IF @flag = 'c'
	BEGIN	
		SET @Sql_Select = ' 	
			SELECT s.source_minor_location_ID [ID],
				   CASE 
						WHEN source_Major_Location.location_name IS NULL THEN ''''
						ELSE source_Major_Location.location_name + '' - > ''
				   END + S.[Location_Name] AS [Name]
			FROM   [dbo].source_minor_location S
			LEFT JOIN source_price_curve_def spcd ON S.[Pricing_Index]=spcd.source_curve_def_id
			LEFT JOIN source_price_curve_def spcd1 ON S.[term_pricing_index]=spcd1.source_curve_def_id
			left JOIN source_commodity ON S.Commodity_id=source_commodity.source_commodity_id
			LEFT JOIN source_Major_Location ON S.source_Major_Location_Id=source_Major_Location.source_major_location_ID
			LEFT JOIN static_data_value sdv ON Sdv.value_id=S.location_type
			LEFT JOIN static_data_value sdv1 ON Sdv1.value_id=S.time_zone
			WHERE 1=1'
	END 
	ELSE IF @flag = 'l'
	BEGIN
		SET @Sql_Select  = 'SELECT DISTINCT
								s.source_minor_location_ID [source_minor_location_id],
								S.[Location_Name] AS [location_name],
								s.location_id [location_id],
								ISNULL(source_major_location.location_name, ''General'') [source_major_location_id],
								source_commodity.[Commodity_name] [commodity_id],
								spcd1.curve_name [term_pricing_index],
								CASE 
								WHEN S.is_active = ''y'' THEN ''Yes''
								ELSE ''No''
								END AS [is_active],				   
								s.Location_Description [location_description],
								CASE WHEN sc.counterparty_name <> sc.counterparty_id THEN sc.counterparty_id + '' - '' + sc.counterparty_name ELSE sc.counterparty_id END [ppipeline],
								4031 type_id,
								ISNULL(sdad.is_active, 0) is_privilege_active
								--,
								--sdv3.code country,
								--sdv4.code region,
								--sdv5.code province,
								--sdv2.code grid_value_id
						FROM #final_privilege_list fpl
						' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
						 source_minor_location s ON s.source_minor_location_id = fpl.value_id
						LEFT JOIN source_price_curve_def spcd ON S.[Pricing_Index] = spcd.source_curve_def_id
						LEFT JOIN source_price_curve_def spcd1 ON S.[term_pricing_index] = spcd1.source_curve_def_id
						LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = S.pipeline
						LEFT JOIN source_commodity ON S.Commodity_id = source_commodity.source_commodity_id
						LEFT JOIN source_Major_Location ON S.source_Major_Location_Id = source_Major_Location.source_major_location_ID
						LEFT JOIN static_data_value sdv ON Sdv.value_id = S.location_type
						LEFT JOIN static_data_value sdv1 ON Sdv1.value_id = S.time_zone
						LEFT JOIN static_data_value sdv2 ON sdv2.value_id = s.grid_value_id
						LEFT JOIN static_data_value sdv3 ON sdv3.value_id = s.country
						LEFT JOIN static_data_value sdv4 ON sdv4.value_id = s.region
						LEFT JOIN static_data_value sdv5 ON sdv5.value_id = s.province
						LEFT JOIN static_data_active_deactive sdad ON sdad.type_id = 4031 --location type id :4000			
						WHERE 1=1 '	
	
	END
	ELSE IF @flag = 'w' --To show the Default value of the Location field in the Field Template
	BEGIN		
		SET @Sql_Select = ' 	
			SELECT s.source_minor_location_ID [ID],
				   S.[Location_Name] AS [Name]
			FROM   [dbo].source_minor_location S
			LEFT JOIN source_price_curve_def spcd ON S.[Pricing_Index]=spcd.source_curve_def_id
			LEFT JOIN source_price_curve_def spcd1 ON S.[term_pricing_index]=spcd1.source_curve_def_id
			left JOIN source_commodity ON S.Commodity_id=source_commodity.source_commodity_id
			LEFT JOIN source_Major_Location ON S.source_Major_Location_Id=source_Major_Location.source_major_location_ID
			LEFT JOIN static_data_value sdv ON Sdv.value_id=S.location_type
			LEFT JOIN static_data_value sdv1 ON Sdv1.value_id=S.time_zone
			WHERE 1=1'
	END 		
	IF @is_active = 'y'
	BEGIN  
		SET @Sql_Select = @Sql_Select + 'AND s.is_active = ''y'''
	END 
	ELSE IF @is_active = 'n'
	BEGIN
		SET @Sql_Select = @Sql_Select + 'AND s.is_active = ''n'' OR s.is_active IS NULL'	
	END
	
    IF @source_system_id IS NOT NULL 
		SET @Sql_Select = @Sql_Select + ' AND s.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id)
            
    IF @Location_Name IS NOT NULL 
		SET @Sql_Select = @Sql_Select + ' AND s.location_name LIKE ''' + @Location_Name + ''''
	
	IF @Commodity_id IS NOT NULL 
		SET @Sql_Select = @Sql_Select + ' AND s.commodity_id=' + CONVERT(VARCHAR(20), @Commodity_id)
	
	IF @region IS NOT NULL  
		SET @Sql_Select = @Sql_Select + ' AND s.region=' + CONVERT(VARCHAR(20), @region)
	
	IF @source_major_location_ID IS NOT NULL 
		SET @Sql_Select = @Sql_Select + ' AND s.source_Major_Location_Id=' + CONVERT(VARCHAR(20), @source_major_location_ID)
	
	IF @Pricing_Index IS NOT NULL 
		SET @Sql_Select = @Sql_Select + ' AND s.pricing_index=' + CONVERT(VARCHAR(20), @Pricing_Index)
	
	IF @term_pricing_index IS NOT NULL 
		SET @Sql_Select = @Sql_Select + ' AND s.term_pricing_index=' + CONVERT(VARCHAR(20), @term_pricing_Index)
	
	IF @profile IS NOT NULL 
		SET @Sql_Select = @Sql_Select + ' AND s.profile_id = ' + CAST(@profile AS VARCHAR)
	
	IF @proxy_profile IS NOT NULL 
		SET @Sql_Select = @Sql_Select + ' AND s.proxy_profile_id=' + CAST(@proxy_profile as VARCHAR)
	
	SET @Sql_Select = @Sql_Select + ' ORDER BY s.Location_Name ASC, S.source_minor_location_id DESC'
    
		--PRINT ( @SQL_select )
    
    EXEC (@SQL_select)
END

IF @flag = 'i' 
BEGIN
	BEGIN TRY
		IF EXISTS (SELECT 1 FROM source_minor_location WHERE location_id = @location_id)
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'Source Minor Location',
				 'spa_source_minor_location',
				 'Error',
				 'Please enter unique location ID.',
				 ''
			
			RETURN
		END
		
		
		IF EXISTS (	SELECT 1
				FROM   adiha_default_codes_values
				WHERE  default_code_id = 56
					   AND var_value = 1
				
		) AND @term_pricing_index IS NULL  		
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'Source Minor Location',
				 'spa_source_minor_location',
				 'Error',
				 'Please insert Term Pricing Index.',
				 ''
			RETURN
		END
		
		INSERT  INTO [dbo].source_minor_location
			(
				[source_system_id]
				,[source_major_location_ID]
				,[Location_Name]
				,[Location_Description]
				,[Meter_ID]
				,[Pricing_Index]
				,[Commodity_id]
				,[location_type]
				,[time_zone]
				,[owner]
				,[operator]
				,[contract]
				,[volume]
				,[uom]
				,[region]
				,[is_pool]
				,[term_pricing_index]
				,[bid_offer_formulator_id]
				,[profile_id]
				,[proxy_profile_id]
				,[create_user]
				,[create_ts]
				,[update_user]
				,[update_ts]
				,[grid_value_id]
				,[country]
				,[is_active]
				,postal_code
				,province
				,physical_shipper
				,profile_code
				,nominatorsapcode
				,forecasting_group
				,forecast_needed
				,calculation_method
				,location_id
			  )
		VALUES  (
				@source_system_id
				,@source_major_location_ID
				,@Location_Name
				,@Location_Description
				,@Meter_ID
				,@Pricing_Index
				,@Commodity_id
				,@location_type
				,@time_zone
				,@owner
				,@operator
				,@contract
				,@volume
				,@uom
				,@region
				,@is_pool
				,@term_pricing_index
				,@bid_offer_formulator_id
				,@profile
				,@proxy_profile
				,dbo.FNADBUser()
				,GETDATE()
				,dbo.FNADBUser()
				,GETDATE()
				,@grid_value_id
				,@country
				,@is_active
				,@postal_code
				,@province
				,@physical_shipper
				,@profile_code
				,@nominator_sap_code
				,@forecasting_group
				,@forecast_needed
				,@calc_method
				,@location_id
			  )
		SET @source_minor_location_id = SCOPE_IDENTITY() 
		
		EXEC spa_ErrorHandler 0,
			 'Source Minor Location',
			 'spa_source_minor_location',
			 'Success',
			 'Successfully saved location data.',
			 @source_minor_location_id
	    
	END TRY
	BEGIN CATCH
		SET @error_number = ERROR_NUMBER()
		IF @error_number = 2627
		BEGIN
		    SET @msg_err = 'The selected location details already exist'
		END
		ELSE
		BEGIN
		    SET @msg_err = 'Fail Insert Data.'
		END
		EXEC spa_ErrorHandler @@ERROR,
	         'Source Minor Location',
	         'spa_source_minor_location',
	         'DB Error',
	         @msg_err,
	         ''
	END CATCH    
END

ELSE IF @flag = 'u' 
BEGIN
	BEGIN TRY
		IF  EXISTS (
			   SELECT 1
			   FROM source_minor_location
			   WHERE location_id = @location_id AND source_minor_location_id <> @source_minor_location_ID
		   )
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'Source Minor Location',
				 'spa_source_minor_location',
				 'Error',
				 'Duplicate location ID cannot be inserted.',
				 ''
			RETURN
		END
		
		IF EXISTS (	SELECT 1
				FROM   adiha_default_codes_values
				WHERE  default_code_id = 56
					   AND var_value = 1
				
		) AND @term_pricing_index IS NULL  		
		BEGIN
			EXEC spa_ErrorHandler -1,
				 'Source Minor Location',
				 'spa_source_minor_location',
				 'Error',
				 'Please insert Term Pricing Index.',
				 ''
			RETURN
		END
		
	    UPDATE [dbo].source_minor_location
	    SET    [source_system_id] = @source_system_id,
	           [source_major_location_ID] = @source_major_location_ID,
	           [Location_Name] = @Location_Name,
	           [Location_Description] = @Location_Description,
	           [Meter_ID] = @Meter_ID,
	           [Pricing_Index] = @Pricing_Index,
	           [Commodity_id] = @Commodity_id,
	           [location_type] = @location_type,
	           [time_zone] = @time_zone,
	           [owner] = @owner,
	           [operator] = @operator,
	           [contract] = @contract,
	           [volume] = @volume,
	           [uom] = @uom,
	           [region] = @region,
	           [is_pool] = @is_pool,
	           [term_pricing_index] = @term_pricing_index,
	           [bid_offer_formulator_id] = @bid_offer_formulator_id,
	           [profile_id] = @profile,
	           [proxy_profile_id] = @proxy_profile,
	           update_user = dbo.FNADBUser(),
	           update_ts = GETDATE(),
	           grid_value_id = @grid_value_id,
	           country = @country,
	           is_active = @is_active,
	           postal_code = @postal_code,
	           province = @province,
	           physical_shipper = @physical_shipper,
	           profile_code = @profile_code,
	           nominatorsapcode = @nominator_sap_code,
	           forecasting_group = @forecasting_group,
	           forecast_needed = @forecast_needed,
	           calculation_method = @calc_method,
	           location_id = @location_id
	    WHERE  source_minor_location_ID = @source_minor_location_ID		
		
		IF EXISTS (	SELECT 1
				FROM   adiha_default_codes_values
				WHERE  default_code_id = 56
					   AND var_value = 1)		
		BEGIN
			UPDATE sdd
			SET    curve_id = sml.term_pricing_index
			FROM   source_deal_detail sdd
				   INNER JOIN source_minor_location sml
						ON  sdd.location_id = sml.source_minor_location_id
			WHERE  sdd.location_id = @source_minor_location_ID	
			AND sdd.fixed_float_leg = 't' AND sdd.physical_financial_flag = 'p'
			
			DECLARE @sql VARCHAR(1000), @source_deal_header_tmp VARCHAR(200), @process_id VARCHAR(200)
			SET @process_id = dbo.FNAGetNewID()
			SELECT @source_deal_header_tmp = dbo.FNAProcessTableName('report_position', dbo.FNADBUser() , @process_id)
			
			SET @sql = ' CREATE TABLE ' +  @source_deal_header_tmp + ' 
			(
				source_deal_header_id  INT,
				[action]               VARCHAR(1)
			)
			'		
			EXEC(@sql)
				   
			                       
			SET @sql = ' INSERT INTO ' + @source_deal_header_tmp + 
						' (
							source_deal_header_id,
							ACTION
						  )	
						  SELECT distinct sdd.source_deal_header_id, ''i'' 
						  FROM source_deal_detail sdd 
						  WHERE sdd.location_id = ' + CAST(@source_minor_location_ID AS VARCHAR(10)) + '
						  AND sdd.fixed_float_leg = ''t'' AND sdd.physical_financial_flag = ''p''
						  '
		
			EXEC (@sql)		 
					     
			EXEC dbo.spa_update_deal_total_volume NULL,
				 @process_id,
				 0
		END
		
		
		EXEC spa_ErrorHandler 0,
	         'Source Minor Location',
	         'spa_source_minor_location',
	         'Success',
	         'Data Updated Successfully.',
	         @source_minor_location_ID
	END TRY
	BEGIN CATCH
		SET @error_number = ERROR_NUMBER()
		IF @error_number = 2627
		BEGIN
		    SET @msg_err = 'The selected location details already exist'
		END
		ELSE
		BEGIN
		    SET @msg_err = 'Fail to update data.'
		END
		EXEC spa_ErrorHandler @@ERROR,
	         'Source Minor Location',
	         'spa_source_minor_location',
	         'DB Error',
	         @msg_err,
	         ''
	END CATCH    
END

ELSE IF @flag = 'k'
BEGIN
	CREATE TABLE #temp_location
	(
	source_minor_location_id INT
	)
	CREATE TABLE #temp_location_data
	(
	source_minor_location_id INT
	)
 
	INSERT INTO #temp_location_data
	SELECT source_minor_location_id
	FROM   [dbo].source_minor_location S
		INNER JOIN delivery_path dp
			 ON  S.source_minor_location_id = dp.from_location
	WHERE  dp.imbalance_from = 'y'

	INSERT INTO #temp_location_data
	SELECT source_minor_location_id
	FROM   [dbo].source_minor_location S
		INNER JOIN delivery_path dp
			 ON  S.source_minor_location_id = dp.to_location
	WHERE  dp.imbalance_to = 'y'

	INSERT INTO #temp_location
	SELECT DISTINCT source_minor_location_id
	FROM   #temp_location_data

	SET @Sql_Select = ' SELECT s.source_minor_location_ID [ID],
							   CASE 
									WHEN source_Major_Location.location_name IS NULL THEN ''''
									ELSE source_Major_Location.location_name + '' - > ''
							   END + S.[Location_Name] AS [Name],
							   S.[Location_Description] AS [Description],
							   S.[Meter_ID] AS [Meter ID],
							   spcd.curve_name [Spot Index],
							   spcd1.curve_name [Term Index],
							   source_commodity.[Commodity_id] [Commodity ID],
							   sdv.[code] AS [Location Type],
							   sdv1.[code] AS [Time Zone],
							   s.bid_offer_formulator_id,
							   S.[create_user] [Created User],
							   dbo.FNADateTimeFormat(S.[create_ts], 1) [Created Date],
							   S.[update_user] [Updated User],
							   dbo.FNADateTimeFormat(S.[update_ts], 1) [Updated Date]
						FROM   [dbo].source_minor_location S
							   INNER JOIN #temp_location tl ON  S.source_minor_location_id = tl.source_minor_location_id
							   LEFT JOIN source_price_curve_def spcd ON  S.[Pricing_Index] = spcd.source_curve_def_id
							   LEFT JOIN source_price_curve_def spcd1 ON  S.[term_pricing_index] = spcd1.source_curve_def_id
							   LEFT JOIN source_commodity ON  S.Commodity_id = source_commodity.source_commodity_id
							   LEFT JOIN source_Major_Location ON  S.source_Major_Location_Id = source_Major_Location.source_major_location_ID
							   LEFT JOIN static_data_value sdv ON  Sdv.value_id = S.location_type
							   LEFT JOIN static_data_value sdv1 ON  Sdv1.value_id = S.time_zone
						WHERE  1 = 1'

	IF @is_active = 'y'
	BEGIN
	    SET @Sql_Select = @Sql_Select + 'AND s.is_active = ''y'''
	END
	ELSE 
	IF @is_active = 'n'
	BEGIN
	    SET @Sql_Select = @Sql_Select + 'AND s.is_active = ''n'' OR s.is_active IS NULL'
	END
	
	IF @source_system_id IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND s.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id)

	IF @Location_Name IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND s.location_name LIKE ''' + @Location_Name + ''''

	IF @Commodity_id IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND s.commodity_id=' + CONVERT(VARCHAR(20), @Commodity_id)

	IF @region IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND s.region=' + CONVERT(VARCHAR(20), @region)

	IF @source_major_location_ID IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND s.source_Major_Location_Id=' + CONVERT(VARCHAR(20), @source_major_location_ID)

	IF @Pricing_Index IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND s.pricing_index=' + CONVERT(VARCHAR(20), @Pricing_Index)

	IF @term_pricing_index IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND s.term_pricing_index=' + CONVERT(VARCHAR(20), @term_pricing_Index)

	IF @profile IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND s.profile_id = ' + CAST(@profile AS VARCHAR)

	IF @proxy_profile IS NOT NULL
		SET @Sql_Select = @Sql_Select + ' AND s.proxy_profile_id=' + CAST(@proxy_profile AS VARCHAR)

	SET @Sql_Select = @Sql_Select + ' ORDER BY s.Location_Name ASC, S.source_minor_location_id DESC'

	exec spa_print @SQL_select
	BEGIN TRY
	EXEC (@SQL_select)
	END TRY
	BEGIN CATCH
	SELECT ERROR_NUMBER() AS ErrorNumber,
		   ERROR_SEVERITY() AS ErrorSeverity,
		   ERROR_STATE() AS ErrorState,
		   ERROR_PROCEDURE() AS ErrorProcedure,
		   ERROR_LINE() AS ErrorLine,
		   ERROR_MESSAGE() AS ErrorMessage
	END CATCH
END
ELSE IF @flag = 'm'
BEGIN
	SELECT MAX(sml.source_minor_location_id) [source_minor_location_id],
	       sml.location_name,
	       SUM(
	           CASE buy_sell_flag
	                WHEN 's' THEN (sdd.deal_volume * -1)
	                ELSE sdd.deal_volume
	           END
	       ) [deal_volume],
	       MAX(sml.x_position) [x_position],
	       MAX(sml.y_position) [y_position],
	       d.source_curve_def_id,
	       d.curve_name
	FROM source_minor_location sml
	LEFT JOIN source_deal_detail sdd ON sml.source_minor_location_id = sdd.location_id
	LEFT JOIN source_price_curve_def d ON d.source_curve_def_id=sml.Pricing_Index	
	GROUP BY sml.location_name ,d.source_curve_def_id,d.curve_name
	ORDER BY sml.location_name
END
------------- end interactive section -------------------
ELSE IF @flag = 'd' 
BEGIN
	DECLARE @del_id INT = 1
	DECLARE @count_ids INT = NULL
	DECLARE @check_exec INT = 0
	DECLARE @rec_msg VARCHAR(100) = @source_minor_location_ID
	
	IF OBJECT_ID(N'tempdb..#lists') IS NOT NULL 
		DROP TABLE #lists
			
	CREATE TABLE #lists
	(
		row_id INT IDENTITY (1,1),
		loc_id INT
	)
	
	INSERT INTO #lists (
		loc_id	
	)
	SELECT item FROM dbo.FNASplit(@source_minor_location_ID, ',')
	
	SELECT @count_ids  = COUNT(item) FROM dbo.FNASplit(@source_minor_location_ID, ',')
	
	WHILE @count_ids >= @del_id
	BEGIN
		SELECT @source_minor_location_ID = loc_id
		FROM #lists
		WHERE row_id = @del_id
		
		IF NOT EXISTS (SELECT 1 FROM source_deal_detail WHERE location_id = @source_minor_location_ID)
		BEGIN
			BEGIN TRY 
				BEGIN TRAN
					SET @Sql_Select = 'DELETE  [dbo].source_minor_location_meter
									   WHERE   source_minor_location_id IN (' + @source_Minor_location_id + ')
							   
									   DELETE  [dbo].source_minor_location_nomination_group
									   WHERE   source_minor_location_id IN (' + @source_Minor_location_id + ')
							   
									   DELETE  [dbo].location_ranking
									   WHERE   location_id IN (' + @source_Minor_location_id + ')
							   
									   DELETE  [dbo].source_minor_location
									   WHERE   source_minor_location_id IN (' + @source_Minor_location_id + ')'
			
					EXEC (@Sql_Select)
					SET @check_exec += 1
					COMMIT TRAN
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN 
				DECLARE @desc VARCHAR(5000)
				SET @desc = dbo.FNAHandleDBError(NULL)
			
				EXEC spa_ErrorHandler -1, 
					'Process Form Data', 
					'spa_process_form_data', 
					'Error', 
					@desc, 
						''
				RETURN
			END CATCH
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler -1,
				'Source Minor Location',
				'spa_source_minor_location',
				'Error',
				'Failed to delete location. Deal(s) are entered for this location.',
				''
			RETURN
		END
		SET @del_id += 1
	END

	IF @count_ids = @check_exec
	BEGIN
		EXEC spa_ErrorHandler 0,
			'Source Minor Location',
			'spa_source_minor_location',
			'Success',
			'Changes have been saved successfully.',
			@rec_msg
	END
END

ELSE IF @flag = 'a' 
BEGIN
	 SELECT sml.[source_minor_location_ID],
               sml.[source_system_id],
               sml.[source_major_location_ID],
               sml.[Location_Name] ,
               sml.[Location_Description],
               sml.[Meter_ID],
               [Pricing_Index],
               [Commodity_id],
               sml.[location_type],
               time_zone,
               sml.[owner],
               sml.[operator],
               sml.[contract],
               sml.[volume],
               sml.[uom],
               sml.[region],
               [is_pool],
               [term_pricing_index],
               [bid_offer_formulator_id],
               sml.[profile_id],
               sml.[proxy_profile_id],
               [grid_value_id],
               [country],
               is_active,
               postal_code,
               province,
               physical_shipper,
               profile_code,
               nominatorsapcode,
               forecasting_group,
               forecast_needed,
               calculation_method,
               fp1.profile_name,
               fp2.profile_name,
               location_id
        FROM   [dbo].source_minor_location sml
        LEFT JOIN forecast_profile fp1 ON fp1.profile_id = sml.profile_id
        LEFT JOIN forecast_profile fp2 ON fp2.profile_id = sml.proxy_profile_id
        LEFT JOIN source_major_location sml2 ON sml2.source_major_location_ID = sml.source_major_location_ID
        WHERE   sml.source_minor_location_ID = @source_minor_location_ID
END        
ELSE IF @flag = 'n' --used in deal_entry
BEGIN
        SELECT	
		sml.source_minor_location_ID [ID],
		ISNULL(smj.location_name + ' - > ', '') + sml.[Location_Name] AS [Name]
		FROM source_minor_location sml
		LEFT JOIN source_Major_Location smj ON smj.source_Major_Location_Id = sml.source_major_location_ID
		WHERE sml.is_active = ISNULL(@is_active, 'n')
END

ELSE IF @flag = 'f'  --get the the minor location of the corresponding major location
BEGIN

    SET @Sql_Select = 'SELECT source_minor_location_id,
                              location_name [Location Name]
						FROM   source_minor_location sml
						'
	IF @source_major_location_ID IS NOT NULL
	SET @Sql_Select = ' INNER JOIN dbo.FNASplit(''' + @source_major_location_ID + ''', '','') i ON i.item = sml.region'
		

	--PRINT(@Sql_Select)
    EXEC(@Sql_Select)
END
ELSE IF @flag = 'p'  --get the the index of the corresponding minor location
BEGIN
    SET @Sql_Select = 'SELECT spcd.source_curve_def_id,
                              spcd.curve_name
                       FROM   source_minor_location sml
                       JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = sml.Pricing_Index
                       WHERE  source_minor_location_id IN ('+ CAST(@source_minor_location_id AS VARCHAR)+ ')'
    EXEC ( @Sql_Select)
END

ELSE IF @flag = 'g'
BEGIN
	SELECT source_minor_location_id,
		location_name
	FROM   source_minor_location
order by location_name asc
END
ELSE IF @flag = 't'	--show all from location defined in delivery path
BEGIN
	SELECT sml.source_minor_location_id,
		sml.location_name
	FROM   source_minor_location sml
	INNER JOIN delivery_path dp ON sml.source_minor_location_id = dp.from_location
END
IF @flag IN ('o', 'b') --Location Dropdown and Browser
BEGIN
	SET @sql = 'SELECT DISTINCT smlo.source_minor_location_id,
					   CASE WHEN ('''+CAST(@location_name_group AS CHAR)+''' =''1'') THEN CASE WHEN smlo.Location_Name <> smlo.location_id THEN smlo.location_id + '' - '' + smlo.Location_Name ELSE smlo.Location_Name END + CASE WHEN sml.location_name IS NULL THEN '''' ELSE  '' ['' + sml.location_name + '']'' END ELSE smlo.Location_Name END [name],
					   IIF(MAX(smlo.is_active) = ''n'' AND ''y'' = ''' + ISNULL(@is_active, 'n') + ''', ''Disable'', MIN(fpl.is_enable)) [status]
				FROM #final_privilege_list fpl
				' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
				 source_minor_location smlo ON smlo.source_minor_location_id = fpl.value_id 
				' + CASE WHEN @flag = 'b' THEN ' INNER JOIN' ELSE ' LEFT JOIN' END  +' source_major_location sml ON  smlo.source_major_location_ID = sml.source_major_location_ID WHERE 1 = 1 '
	IF @is_active = 'n'
		SET @sql += ' AND smlo.is_active = ''' + @is_active + ''''

	IF nullif(nullif(@source_major_location_ID, 'NULL'), '') IS NOT NULL
		SET @sql = @sql  + ' AND  sml.source_major_location_ID in (' + @source_major_location_ID + ')'
	
	IF @grid_value_id IS NOT NULL AND @source_minor_location_ID IS NOT NULL
		SET @sql += CASE WHEN @grid_value_id = @source_minor_location_ID THEN  ' AND smlo.source_minor_location_id = ' + CAST(@source_minor_location_ID AS VARCHAR(100)) 
						ELSE ' AND smlo.region=' + CAST(@grid_value_id AS VARCHAR(100)) END
	ELSE IF @region IS NOT NULL
		SET @sql += ' AND smlo.region IN(' + @region + ')'
						
	IF @location_name IS NOT NULL		
		SET @sql = @sql  + 'AND sml.Location_Name IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @location_name + ''')) '

	IF @not_in_location_name IS NOT NULL		
		SET @sql = @sql  + 'AND sml.Location_Name NOT IN (SELECT item FROM dbo.SplitCommaSeperatedValues(''' + @not_in_location_name + ''')) '

	SET @sql += ' GROUP BY smlo.source_minor_location_id, smlo.location_name, smlo.location_id, sml.location_name'
	SET @sql = @sql  + ' ORDER BY [name]'
	EXEC(@sql)
END
IF @flag = 'r' --Meter Location Browser
BEGIN
	SET @sql = '
		SELECT sml.source_minor_location_id, 
				sml.location_name,
				MIN(fpl.is_enable) [status]
		FROM #final_privilege_list fpl
		' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
		 source_minor_location sml ON sml.source_minor_location_id = fpl.value_id
		INNER JOIN source_minor_location_meter smlm ON sml.source_minor_location_id = smlm.source_minor_location_id'
	SET @sql += ' GROUP BY sml.source_minor_location_id, sml.location_name'
	EXEC(@sql)
END
IF @flag = 'q' --Show Locations in Field Template Mapping
BEGIN
	SET @sql = 'SELECT smlo.source_minor_location_id,
					   CASE WHEN smlo.Location_Name <> smlo.location_id THEN smlo.location_id + '' - '' + smlo.Location_Name ELSE smlo.Location_Name END + CASE WHEN sml.location_name IS NULL THEN '''' ELSE  '' ['' + sml.location_name + '']'' END  [name]
				FROM source_minor_location smlo  
				LEFT JOIN source_major_location sml ON  smlo.source_major_location_ID = sml.source_major_location_ID WHERE 1 = 1 AND sml.source_major_location_id <> 3 
				ORDER BY CASE WHEN smlo.Location_Name <> smlo.location_id THEN smlo.location_id + '' - '' + smlo.Location_Name ELSE smlo.Location_Name END'
	EXEC(@sql)
END
IF @flag = '1' --Used for tree view in new dhtmlx form
BEGIN
	SELECT	Location_Name, 
			Location_Description
	FROM source_minor_location
	-- WHERE Location_Name LIKE @Location_Name
END
ELSE IF @flag = '2'
BEGIN 
	SET @sql = 'SELECT smlo.source_minor_location_id,
					   CASE WHEN smlo.Location_Name <> smlo.location_id THEN smlo.location_id + '' - '' + smlo.Location_Name ELSE smlo.Location_Name END + CASE WHEN sml.location_name IS NULL THEN '''' ELSE  '' ['' + sml.location_name + '']'' END  [name]
				FROM source_minor_location smlo  
				LEFT JOIN source_major_location sml ON  smlo.source_major_location_ID = sml.source_major_location_ID 
				WHERE 1 = 1 
				'
	IF @grid_value_id IS NOT NULL     
		SET @sql =  @sql + CASE WHEN @grid_value_id = @source_minor_location_ID THEN  ' AND smlo.source_minor_location_id = ' + CAST(@source_minor_location_ID AS VARCHAR(100)) 
					ELSE ' AND smlo.region=' + CAST(@grid_value_id AS VARCHAR(100)) END  

	EXEC spa_print @sql
	EXEC(@sql)
END
else if @flag = 'e' --check parent proxy location is already defined on other child proxy and also copy position type is set or not, while saving location
begin
	if exists(
		select top 1 1
		from source_minor_location sml
		inner join dbo.SplitCommaSeperatedValues(@proxy_location_id) scsv on scsv.item = sml.source_minor_location_id
		where sml.proxy_position_type is not null
	) --if parent proxy loc has proxy position type defined, avoid saving loc
	begin
		select null [child_proxy_loc], sml.proxy_position_type [proxy_position_type], 0 [is_valid_to_proceed], 'Proxy Position Type has been already defined on parent proxy location.' [msg]
		from source_minor_location sml
		inner join dbo.SplitCommaSeperatedValues(@proxy_location_id) scsv on scsv.item = sml.source_minor_location_id
		where sml.proxy_position_type is not null
	end 
	else if exists(
		select top 1 1 
		from source_minor_location sml 
		inner join dbo.SplitCommaSeperatedValues(@proxy_location_id) scsv on scsv.item = sml.proxy_location_id
		where sml.proxy_position_type is not null and sml.source_minor_location_id <> @source_minor_location_ID
	) --if any child proxy loc of parent proxy loc has proxy position type defined, avoid saving loc
	begin
		select sml.source_minor_location_id [child_proxy_loc], sml.proxy_position_type, 0 [is_valid_to_proceed], 'Proxy Position Type has been already defined on one of child proxy location.' [msg]
		from source_minor_location sml 
		inner join dbo.SplitCommaSeperatedValues(@proxy_location_id) scsv on scsv.item = sml.proxy_location_id
		where sml.proxy_position_type is not null and sml.source_minor_location_id <> @source_minor_location_ID
	end
	else --none of any have proxy position type defined, proceed saving loc
	begin
		select null [child_proxy_loc], null [proxy_position_type], 1 [is_valid_to_proceed], 'Proxy Position Type yet not defined.' [msg]
		
	end
end
else if @flag = 'z' --get source major location details 
begin
	SELECT 
		sml2.location_name source_major_location,
		sml2.source_major_location_id,
		sml.source_minor_location_id,
		sml.location_name source_minor_location
	FROM source_minor_location sml
	inner join source_major_location sml2 on sml2.source_major_location_id = sml.source_major_location_id 
	where sml.source_minor_location_id = @source_minor_location_id
end
GO
