IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_location_ranking]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_location_ranking]
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
/************************************************************************************/
/*	Created By:  Navaraj Shrestha													*/
/*	Created By: 04/11/2014														   */
/*	Description: CRUD operation for location_ranking								*/
/************************************************************************************/

CREATE PROC [dbo].[spa_location_ranking]
	@flag							CHAR(1),
	@location_ranking_id			VARCHAR(max) = NULL,
	@rank_id						INT = NULL,
	@effective_date					VARCHAR(10) = NULL,
	@location_id_xml				TEXT = NULL,
	@path_id_xml					TEXT = NULL,
	@path_id						VARCHAR(1000) = NULL,
	@location_id					VARCHAR(1000) = NULL,
	@location_group					VARCHAR(15) = NULL,
	@path_location					VARCHAR(15) = NULL,
	@location_group_id					INT = NULL

AS

SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
DECLARE @msg1 VARCHAR(1000)
DECLARE @source_system_id INT = NULL

IF @source_system_id IS NULL
	SET @source_system_id=2

IF @flag = 'i' OR @flag = 'u' 
BEGIN
	BEGIN TRY
	BEGIN TRAN
		
		DECLARE @idoc1 INT
		DECLARE @idoc2 INT
		
		/******** For location ********************************************/
		IF OBJECT_ID('tempdb..#tmp_location_ranking') IS NOT NULL DROP TABLE #tmp_location_ranking
		
		IF @location_id_xml IS NOT NULL
		BEGIN
			EXEC sp_xml_preparedocument @idoc1 OUTPUT, @location_id_xml	
		END
		
		SELECT 
			location_id,	
			name,
			ranking_id,
			delete_flag
		INTO #tmp_location_ranking
		FROM   OPENXML (@idoc1, '/Root/PSRecordset',2)
		WITH ( 
			location_id				INT						'@edit_grid0',
			name					VARCHAR(100)			'@edit_grid1',
			ranking_id				VARCHAR(200)			'@edit_grid2',
			delete_flag				INT						'@edit_grid3' --edit_grid hardcoded in frontend
		)

		EXEC sp_xml_removedocument @idoc1
		
		MERGE location_ranking AS lr  
		USING (SELECT location_id, item [location_ranking_id], @rank_id [rank_id], @effective_date [effective_date], delete_flag  FROM #tmp_location_ranking rl1
				CROSS APPLY dbo.FNASplit(rl1.ranking_id, '|') f
		) AS  source 
		ON (lr.location_ranking_id = ISNULL(NULLIF(source.location_ranking_id, 'NULL'), -1))	
		WHEN NOT MATCHED BY TARGET  THEN
						INSERT (location_id, rank_id, effective_date)
							VALUES (source.location_id, @rank_id, @effective_date)
			
		WHEN MATCHED AND source.delete_flag = 0 THEN
			UPDATE SET lr.location_id = source.location_id, lr.rank_id = @rank_id, lr.effective_date = @effective_date
		WHEN MATCHED AND source.delete_flag = 1 THEN
			DELETE;
			
			
		
		IF OBJECT_ID('tempdb..#tmp_location_ranking') IS NOT NULL DROP TABLE #tmp_location_ranking
		
		/******** For location END********************************************/

		/******** For delivery path ********************************************/
		IF OBJECT_ID('tempdb..#delivery_path') IS NOT NULL DROP TABLE #delivery_path
		
		IF @path_id_xml IS NOT NULL
		BEGIN
			EXEC sp_xml_preparedocument @idoc2 OUTPUT, @path_id_xml	
		END
		
		SELECT 
			location_id,	
			name,
			ranking_id,
			delete_flag
		INTO #delivery_path
		FROM   OPENXML (@idoc2, '/Root/PSRecordset',2)
		WITH ( 
			location_id				INT						'@edit_grid0',
			name					VARCHAR(100)			'@edit_grid1',
			ranking_id				VARCHAR(200)			'@edit_grid2',
			delete_flag				INT						'@edit_grid3' --edit_grid hardcoded in frontend
		)

		EXEC sp_xml_removedocument @idoc2
		
		MERGE location_ranking AS lr  
		USING (SELECT location_id, item [location_ranking_id], @rank_id [rank_id], @effective_date [effective_date], delete_flag  FROM #delivery_path rl1
				cross apply dbo.FNASplit(rl1.ranking_id, '|') f
		) AS  source 
		ON (lr.location_ranking_id = ISNULL(NULLIF(source.location_ranking_id, 'NULL'), -1))	
		WHEN NOT MATCHED BY TARGET  THEN
						INSERT (path_id, rank_id, effective_date)
							VALUES (source.location_id, @rank_id, @effective_date)
			
		WHEN MATCHED AND source.delete_flag = 0 THEN
			UPDATE SET lr.path_id = source.location_id, lr.rank_id = @rank_id, lr.effective_date = @effective_date
		WHEN MATCHED AND source.delete_flag = 1 THEN
			DELETE;
		
		IF OBJECT_ID('tempdb..#delivery_path') IS NOT NULL DROP TABLE #delivery_path;
		
		/******** For Delivery path END********************************************/

		/****Remove duplicate rows keeping 1*/
		WITH dup AS (
			SELECT ROW_NUMBER() OVER(PARTITION BY rank_id, effective_date, location_id, path_id ORDER BY rank_id, effective_date, location_id, path_id) AS row
			FROM [dbo].location_ranking) 
		DELETE FROM dup
		WHERE row > 1;
		/****************************************/

		IF @flag = 'i'
			SET @msg1  =  'Successfully saved location ranking.'
		ELSE
			SET @msg1  =  'Successfully updated location ranking.'

		EXEC spa_ErrorHandler 0
			 , 'Location Ranking'
			 , 'spa_location_ranking'
			 , 'Success'
			 , @msg1
			 , ''			 
		COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK

		IF @flag = 'i'
			SET @msg1  =  'Failed to save location ranking.'
		ELSE
			SET @msg1  =  'Failed to update location ranking.'
		
		EXEC spa_ErrorHandler @@ERROR
			, 'Location Ranking'
			, 'spa_location_ranking'
			, 'DB ERROR'
			, @msg1
			, ''
   	END CATCH
END

ELSE IF @flag = 'd'
BEGIN
	SET @sql = '
		 DELETE 
		 FROM   [dbo].location_ranking
		 WHERE  location_ranking_id IN (' + @location_ranking_id + ')'
	 EXEC(@sql)
     IF @@ERROR <> 0
     BEGIN
         EXEC spa_ErrorHandler @@ERROR
              , 'Delete Location Ranking.'
              , 'spa_location_ranking'
              , 'DB Error'
              , 'Delete Location ranking failed.'
              , ''
         
         RETURN
     END
     ELSE
 	 BEGIN
 		EXEC spa_ErrorHandler 0,
              'Delete Location Ranking.',
              'spa_location_ranking',
              'Success',
              'Successfully Deleted Location Ranking.',
              ''
 	 END     
END

ELSE IF @flag = 'a' 
BEGIN
	
	SET @sql = '
	DECLARE @_rank_id VARCHAR(20) = ''''
	DECLARE @_effective_date VARCHAR(50) = ''''
	DECLARE @_location_id VARCHAR(1000) = ''''
	DECLARE @_path_id VARCHAR(20) = ''''
	
	SELECT 
		@_rank_id = COALESCE(@_rank_id + '','', '''') + CAST(rank_id AS VARCHAR),					
		@_effective_date = COALESCE(@_effective_date + '','', '''') + CAST([dbo].FNADateFormat(effective_date) AS VARCHAR),			
		@_location_id = COALESCE(@_location_id + '','', '''') + CAST(ISNULL(location_id, '''') AS VARCHAR),
		@_path_id += COALESCE(@_path_id + '','', '''') + CAST(ISNULL(path_id, '''') AS VARCHAR)
	FROM location_ranking 
	WHERE location_ranking_id IN (' + @location_ranking_id + ')
	
	SELECT STUFF(@_rank_id,1,1,''''), STUFF(@_effective_date,1,1,''''), STUFF(@_location_id,1,1,''''), STUFF(@_path_id,1,1,'''')
	'			
	EXEC(@sql)
END

ELSE IF @flag = 's' OR @flag = 'e'
BEGIN
	DECLARE @max_eff_date VARCHAR(20) = ''
	
	SELECT top 1 @max_eff_date = effective_date FROM location_ranking WHERE effective_date <= @effective_date
	ORDER BY effective_date DESC
	
	IF OBJECT_ID('tempdb..##tmp_location_ranking_result') IS NOT NULL DROP TABLE ##tmp_location_ranking_result
	
	SET @sql = '
			SELECT lr.location_ranking_id [location_ranking_id], 						
				[dbo].FNADateFormat(lr.effective_date) [Effective Date],
				CASE
					WHEN lr.path_id IS NOT NULL THEN ''Path''
					ELSE  sml2.location_name 
				END [Type],			
				CASE
					WHEN lr.path_id IS NOT NULL THEN dp.path_code
				ELSE sml1.Location_Name
				END [Location],
				rnk.code [Rank]	
				INTO ##tmp_location_ranking_result
			FROM location_ranking lr
			LEFT JOIN source_minor_location sml1 ON sml1.source_minor_location_id = lr.location_id
			LEFT JOIN source_major_location sml2 ON 
				sml2.source_major_location_ID = sml1.source_major_location_ID
			LEFT JOIN delivery_path dp ON dp.path_id = lr.path_id	
			LEFT JOIN static_data_value rnk ON rnk.value_id = lr.rank_id '	
					
		IF ISNULL(@path_location, '') <> 'Location'
		BEGIN
			SET @sql += ' LEFT JOIN (
				SELECT dp1.path_id [path_id],  sml4.location_name [location_name] FROM delivery_path dp1
					INNER JOIN source_minor_location sml3 ON 
					sml3.source_minor_location_id = dp1.from_location OR sml3.source_minor_location_id = dp1.to_location'
			
			--IF ISNULL(@location_group, '') = 'M2'  
			--	SET @sql += 'sml3.source_minor_location_id = dp1.from_location '
			--ELSE IF ISNULL(@location_group, '') = 'MQ' 
			--	SET @sql += 'sml3.source_minor_location_id = dp1.to_location '
			--ELSE 
			--	SET @sql += 'sml3.source_minor_location_id = dp1.from_location OR sml3.source_minor_location_id = dp1.to_location'
			
			SET @sql += ' INNER JOIN source_major_location sml4 ON sml4.source_major_location_ID = sml3.source_major_location_ID
						WHERE 1 = 1'
			IF @location_group_id IS NOT NULL
				SET @sql += ' AND sml4.source_major_location_ID = ' + CAST(@location_group_id AS VARCHAR)
			SET @sql += ' ) P ON P.path_id = dp.path_id '	
		END
		
		SET @sql += 'WHERE 1 = 1 '
		 
		IF @rank_id IS NOT NULL
			SET @sql += 'AND lr.rank_id = ' + CAST(@rank_id AS VARCHAR(15)) + ' '
		
		--unused code start--	
		--IF @location_group IS NOT NULL AND (@path_location = 'Location')
		--	SET @sql += 'AND sml2.location_name = ''' + @location_group + ''' '
		--ELSE IF @location_group IS NOT NULL AND (@path_location = 'Path')
		--	SET @sql += 'AND P.location_name = ''' + @location_group + ''' '
		--ELSE IF @location_group IS NOT NULL
		--	SET @sql += 'AND (sml2.location_name = ''' + @location_group + ''' OR P.location_name = ''' + @location_group + ''') '
		--IF @path_location = 'Path' AND @location_group IS NULL
		--	SET @sql += 'AND lr.path_id IS NOT NULL '
		--IF @path_location = 'Location'
		--	SET @sql += 'AND lr.path_id IS NULL '
		--IF @path_id IS NOT NULL AND @location_id IS NOT NULL
		--	SET @sql += 'AND (lr.path_id IN (' + @path_id + ') OR lr.location_id IN (' + @location_id + ')) '
		--ELSE IF @path_id IS NOT NULL
		--	SET @sql += 'AND lr.path_id IN (' + @path_id + ') '
		--ELSE IF @location_id IS NOT NULL
		--	SET @sql += 'AND lr.location_id IN (' + @location_id + ') '
		--unused code end--
		
		IF @location_group_id IS NOT NULL
			SET @sql += ' AND sml2.source_major_location_ID = ' + CAST(@location_group_id AS VARCHAR)
		IF @location_id IS NOT NULL
			SET @sql += 'AND lr.location_id IN (' + @location_id + ') '
				
	EXEC(@sql)
	--SELECT @effective_date, cast(@max_eff_date AS  date)
	--SELECT * FROM ##tmp_location_ranking_result
	
	IF @flag = 's'
	BEGIN
		SELECT MAX(tlrr.location_ranking_id) location_ranking_id, MAX(tlrr.[Effective Date]) [Effective Date], tlrr.[Type], tlrr.[Location],  tlrr.[Rank] 
		FROM ##tmp_location_ranking_result tlrr 
		WHERE tlrr.[Effective Date] <= CASE WHEN @effective_date IS NOT NULL THEN CAST(@max_eff_date AS  DATE)  ELSE tlrr.[Effective Date] END
		GROUP BY tlrr.[Rank], tlrr.[Location], tlrr.[Type] 
		, CASE WHEN @effective_date IS NULL THEN tlrr.[Effective Date] ELSE tlrr.[Type] END
		
	END
	ELSE
		BEGIN
		SELECT MAX(tlrr.[Effective Date]) [Effective Date], tlrr.[Type], tlrr.[Location],  tlrr.[Rank] 
		FROM ##tmp_location_ranking_result tlrr 
		WHERE tlrr.[Effective Date] <= CASE WHEN @effective_date IS NOT NULL THEN CAST(@max_eff_date AS  DATE)  ELSE tlrr.[Effective Date] END
		GROUP BY tlrr.[Rank], tlrr.[Location], tlrr.[Type] 
		, CASE WHEN @effective_date IS NULL THEN tlrr.[Effective Date] ELSE tlrr.[Type] END
		
	END
	
	
	IF OBJECT_ID('tempdb..##tmp_location_ranking_result') IS NOT NULL DROP TABLE ##tmp_location_ranking_result
				
END

IF @flag = 'l'
BEGIN
		SET @sql = ' 	
			SELECT 
				s.source_minor_location_ID [ID],
				   CASE 
						WHEN source_Major_Location.location_name IS NULL THEN ''''
						ELSE S.[Location_Name] + '' - > ''
				   END + source_Major_Location.location_name AS [Name],'
				IF @location_ranking_id IS NOT NULL
				BEGIN
					SET @sql += ' STUFF((SELECT ''|'' + CAST(lr.location_ranking_id AS VARCHAR)
						FROM location_ranking lr
				          WHERE 1 = 1 '
						 
						SET @sql += 'AND lr.location_id = s.source_minor_location_ID '					
											 
						SET @sql += 'AND location_ranking_id IN (' + @location_ranking_id + ')'
						SET @sql += 'FOR XML PATH ('''')), 1,1,'''') '	
				END 
				ELSE
				BEGIN
					SET @sql += ''''' '
				END

				SET @sql += '[location_ranking_id], '
				SET @sql += 'source_Major_Location.location_name [Type] '
						   
		SET @sql +='	FROM   [dbo].source_minor_location S
			INNER JOIN source_Major_Location ON S.source_Major_Location_Id = source_Major_Location.source_major_location_ID '
			+ 
			CASE WHEN @location_group IS NOT NULL THEN
				'INNER JOIN dbo.SplitCommaSeperatedValues(''' + @location_group + ''') scsv on scsv.item = source_Major_Location.location_name '
				ELSE ''
			END
		

		
		IF @location_group_id IS NOT NULL
			SET @sql += 'AND source_Major_Location.source_major_location_ID = ' + CAST(@location_group_id AS VARCHAR(20))
			
		SET @sql += ' ORDER BY [Name] ASC, S.source_minor_location_id DESC'
    
		
    	EXEC (@sql)
	END
	
ELSE IF @flag = 'p'
BEGIN
		SELECT @sql = 'SELECT 
			dp.path_id [Path ID],
			dp.path_code [Path Code], '
		IF @location_ranking_id IS NOT NULL
		BEGIN 
			SET @sql +='STUFF((SELECT '','' + CAST(lr.location_ranking_id AS VARCHAR)
						FROM location_ranking lr
				          WHERE 1 = 1  AND lr.path_id = dp.path_id '
		
			SET @sql += 'AND location_ranking_id IN (' + @location_ranking_id + ') '	
			SET @sql += 'FOR XML PATH ('''')), 1,1,'''') '
		END	
		ELSE 
		BEGIN
			SET @sql += ''''' ' 
		END	
		SET @sql += '[location_ranking_id] '
			SET @sql += 'FROM dbo.delivery_path dp
						left join source_counterparty scp on scp.source_counterparty_id= dp.counterParty
						left join source_minor_location_meter smlm	ON smlm.source_minor_location_id = dp.from_location AND smlm.meter_id = dp.meter_from	
						left join source_minor_location_meter smlm1	ON smlm1.source_minor_location_id = dp.to_location AND smlm1.meter_id = dp.meter_to
						left join source_minor_location sml on smlm.source_minor_location_id= sml.source_minor_location_id
						left join source_minor_location sml1 on smlm1.source_minor_location_id= sml1.source_minor_location_id
						LEFT JOIN meter_id mi ON mi.meter_id=smlm.meter_id
						LEFT JOIN meter_id mi1 ON mi1.meter_id=smlm1.meter_id
						LEFT JOIN  dbo.static_data_value sdv ON sdv.value_id = dp.delivery_means
						left JOIN source_commodity sc ON sc.source_commodity_id = dp.commodity
						left JOIN location_loss_factor llf on llf.from_location_id = dp.from_location AND llf.to_location_id=dp.to_location	
						LEFT JOIN 
						(
							SELECT dpd_min.* FROM 
							delivery_path_detail dpd_min
							INNER JOIN 
							(SELECT MIN(delivery_path_detail_id) delivery_path_detail_id
								FROM delivery_path_detail dpd_group
								GROUP BY dpd_group.Path_id
							) p_min ON dpd_min.delivery_path_detail_id = p_min.delivery_path_detail_id
						)dpd_from ON dp.path_id = dpd_from.path_id AND ISNULL(dp.groupPath, ''n'') = ''y''
						LEFT JOIN delivery_path dp_from ON dpd_from.path_name = dp_from.path_id 
						LEFT JOIN 
						(
							SELECT dpd_max.* FROM 
							delivery_path_detail dpd_max
							INNER JOIN 
							(SELECT MAX(delivery_path_detail_id) delivery_path_detail_id
								FROM delivery_path_detail dpd_group
								GROUP BY dpd_group.Path_id
							) p_max ON dpd_max.delivery_path_detail_id = p_max.delivery_path_detail_id
						)dpd_to ON dp.path_id = dpd_to.Path_id AND ISNULL(dp.groupPath, ''n'') = ''y''
						LEFT JOIN delivery_path dp_to ON dpd_to.Path_name = dp_to.path_id
						'	
	EXEC(@sql)	
		
END	

ELSE IF @flag = 'n'
BEGIN
	SET @sql = '
		INSERT [location_ranking](rank_id, effective_date, location_id)
		SELECT distinct NULL, ''' + ISNULL(@effective_date, CONVERT(VARCHAR(10), GETDATE(), 21)) + ''', location_id
		FROM location_ranking 
		WHERE Rank_id IS NOT NULL 
		AND  location_ranking_id IN (' + @location_ranking_id + ')'
	 EXEC(@sql)
     IF @@ERROR <> 0
     BEGIN
         EXEC spa_ErrorHandler @@ERROR
              , 'Unranked Location Ranking.'
              , 'spa_location_ranking'
              , 'DB Error'
              , 'Unranked selected data failed.'
              , ''
         
         RETURN
     END
     ELSE
 	 BEGIN
 		EXEC spa_ErrorHandler 0,
              'Unranked Location Ranking.',
              'spa_location_ranking',
              'Success',
              'Successfully unranked selected data.',
              ''
 	 END     
END

ELSE IF @flag = 'm'
BEGIN
	SELECT @effective_date
	SET @sql = '
		INSERT [location_ranking](rank_id, effective_date, location_id)
		SELECT distinct NULL, ''' + ISNULL(@effective_date, CONVERT(VARCHAR(10), GETDATE(), 21)) + ''' , location_id
		FROM location_ranking 
		WHERE Rank_id IS NOT NULL'
	 EXEC(@sql)
     IF @@ERROR <> 0
     BEGIN
         EXEC spa_ErrorHandler @@ERROR
              , 'Unranked Location Ranking.'
              , 'spa_location_ranking'
              , 'DB Error'
              , 'Unranked data failed.'
              , ''
         
         RETURN
     END
     ELSE
 	 BEGIN
 		EXEC spa_ErrorHandler 0,
              'Unranked Location Ranking.',
              'spa_location_ranking',
              'Success',
              'Successfully unranked all data.',
              ''
 	 END     
END
	
ELSE IF  @flag = 'g'
	BEGIN
		SET @sql =' 	
			SELECT 			 
			  sm.[source_major_location_ID] as [Location Group ID]
			  ,sm.[location_name] as [Location Group]
		  FROM [dbo].[source_major_location] sm '

		IF @source_system_id IS NOT NULL
			SET @sql = @sql +  'WHERE sm.source_system_id =' + CONVERT(VARCHAR(20), @source_system_id)
		EXEC(@sql)
	END

ELSE IF @flag = 'b'
BEGIN
	SELECT gmv.clm1_value
	FROM generic_mapping_header gmh
	INNER JOIN generic_mapping_definition gmd 
	ON gmd.mapping_table_id = gmh.mapping_table_id
	INNER JOIN generic_mapping_values gmv
	ON gmv.mapping_table_id = gmh.mapping_table_id
	WHERE gmd.clm1_label  = 'Sub Book' AND  gmh.mapping_name = 'Flow Optimization Mapping'
END