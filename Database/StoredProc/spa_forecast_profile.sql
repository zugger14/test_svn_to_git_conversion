IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_forecast_profile]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_forecast_profile]
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_forecast_profile]
	@flag VARCHAR(25),
	@profile_id INT = NULL,
	@profile_name VARCHAR(50) = NULL, 
	@external_id VARCHAR(50) = NULL, 
	@profile_type_id INT = NULL, 
	@uom INT = NULL, 	
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,  --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS
BEGIN
	SET NOCOUNT ON
	
	/*******************************************1st Paging Batch START**********************************************/
	DECLARE @str_batch_table VARCHAR(8000)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @sql_paging VARCHAR(8000)
	DECLARE @is_batch bit
	SET @str_batch_table = ''
	SET @user_login_id = dbo.FNADBUser() 
	SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END
	IF @is_batch = 1
	   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)
	IF @enable_paging = 1 --paging processing
	BEGIN
		IF @batch_process_id IS NULL
			SET @batch_process_id = dbo.FNAGetNewID()
	
		SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)
	   
		--retrieve data from paging table instead of main table
	   IF @page_no IS NOT NULL
	   BEGIN
		  SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)
		  EXEC (@sql_paging)
		  RETURN
	   END
	END
	/*******************************************1st Paging Batch END**********************************************/


	DECLARE @sql VARCHAR(MAX)
	DECLARE @err_no VARCHAR(100), @msg VARCHAR(500)
	
	IF @flag = 's'
	BEGIN
--		SELECT [profile_id] [Profile ID], [external_id] [External ID],sdv.code [Profile Type] FROM forecast_profile fp
--		INNER JOIN static_data_value sdv ON sdv.value_id = fp.profile_type 
--		ORDER BY [external_id]

		SET @sql = 'SELECT 
						[profile_id] [Profile ID], 
						profile_name [Profile Name], 
						[external_id] [EAN],
						sdv.code [Profile Type],
						su.uom_name + case when ssd.source_system_name=''farrms'' then '''' else   ''.'' + ssd.source_system_name end as [UOM]						 
					' + @str_batch_table + '
		            FROM forecast_profile fp
					INNER JOIN static_data_value sdv ON sdv.value_id = fp.profile_type
					LEFT JOIN source_uom su ON su.source_uom_id = fp.uom_id
					LEFT JOIN source_system_description ssd ON su.source_system_id = ssd.source_system_id
		            WHERE 1=1 '
		
		IF @profile_name IS NOT NULL 
		BEGIN 
			SET @sql = @sql + ' AND profile_name LIKE ''' + @profile_name + ''''
		END 
					
		IF @external_id IS NOT NULL 
		BEGIN
			SET @sql = @sql + ' AND external_id LIKE ''' + @external_id + ''''
		END
		
		IF @profile_type_id IS NOT NULL 
		BEGIN
			SET @sql = @sql + ' AND profile_type = ' + CAST(@profile_type_id AS VARCHAR)
		END 
		
		SET @sql = @sql + ' ORDER BY [Profile Type]'
		EXEC spa_print @sql 
		EXEC (@sql)
	END	
	
	
	IF @flag = 'i'
	BEGIN
		
		BEGIN TRY 
--		SELECT @profile_name, @external_id, @profile_type_id 
			INSERT INTO forecast_profile (profile_name, external_id, profile_type, uom_id)
			VALUES (@profile_name, @external_id, @profile_type_id, @uom)
			SET @profile_id = SCOPE_IDENTITY()
			Exec spa_ErrorHandler 0, 'Forecast Profile', 
					'spa_forecast_profile', 'Success', 
					'Forecast Profile successfully inserted.', 
					@profile_id
								
			--COMMIT 
		END TRY 
		BEGIN CATCH 
			
			SET @err_no = ERROR_NUMBER() 
			
			IF @err_no = 2601
			BEGIN
				SET @msg = 'Duplicate profile detail cannot be inserted.'
			END
			ELSE
			BEGIN
				SET @msg = 'Failed to insert Forecast Profile.'
			END
			
			EXEC spa_ErrorHandler -1, 'Forecast Profile', 
					'spa_forecast_profile', 'DB Error', 
					@msg,''
			RETURN 

		END CATCH 
		
	END
	
	
	IF @flag = 'u'
	BEGIN
		BEGIN TRY 
		
			UPDATE forecast_profile 
			SET external_id = @external_id,
				profile_type = @profile_type_id,
				profile_name = @profile_name, 
				uom_id = @uom
			WHERE profile_id = @profile_id 
			
			Exec spa_ErrorHandler 0, 'Forecast Profile', 
					'spa_forecast_profile', 'Success', 
					'Forecast Profile successfully updated.', ''
								
			COMMIT 
			
		END TRY 
		BEGIN CATCH 

			SET @err_no = ERROR_NUMBER() 
			
			IF @err_no = 2601
			BEGIN
				SET @msg = 'Duplicate profile detail cannot be inserted.'
			END
			ELSE
			BEGIN
				SET @msg = 'Failed to update Forecast Profile.'
			END
			
			EXEC spa_ErrorHandler -1, 'Forecast Profile', 
					'spa_forecast_profile', 'DB Error', 
					@msg,''
			RETURN 

		END CATCH 
	END
	
	IF @flag = 'd'
	BEGIN
		BEGIN TRY 
			DELETE FROM forecast_profile WHERE profile_id = @profile_id 
			EXEC spa_maintain_udf_header 'd', NULL, @profile_id
			
			EXEC spa_ErrorHandler 0, 'forecast_profile table',
				'spa_forecast_profile', 'Success', 'Data Successfully Deleted', ''

		END TRY 
		BEGIN CATCH 
			SET @err_no = ERROR_NUMBER()
			
			IF @err_no = 547 -- Delete statement conflicted with reference constraint
			BEGIN 
				EXEC spa_ErrorHandler -1, 'forecast_profile table',
					'spa_forecast_profile', 'Success', 'The selected profile is in use and can not be deleted.', ''
			END 
			ELSE 
			BEGIN
				EXEC spa_ErrorHandler -1, 'forecast_profile table',
					'spa_forecast_profile', 'Success', 'Error deleting data', ''
			END
		END CATCH 
	END
	
	IF @flag = 'a'
	BEGIN
		SELECT 
			profile_id, profile_name, external_id, profile_type, available, uom_id 
		FROM forecast_profile WHERE profile_id = @profile_id 
	END
	
	IF @flag = 'v'
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM forecast_profile fp WHERE fp.external_id = @external_id)
		BEGIN
			SET @msg = 'EAN No. (' + @external_id + ') does not exist in the system.'
			EXEC spa_ErrorHandler
				@error = -1,
				@msgType1 = 'Forecast Profile',
				@msgType2 = 'spa_forecast_profile',
				@msgType3 = 'Error',
				@msg = @msg,
				@recommendation = ''
		END
		ELSE
		BEGIN
			SET @msg = 'EAN No. (' + @external_id + ') exits.'
			EXEC spa_ErrorHandler
				@error = 0,
				@msgType1 = 'Forecast Profile',
				@msgType2 = 'spa_forecast_profile',
				@msgType3 = 'Success',
				@msg = @msg,
				@recommendation = ''
		END
	END

	IF @flag = 'x'
	BEGIN
		SET @sql = '
		SELECT fp.profile_id, fp.profile_name, ''enable'' [state]
		FROM forecast_profile fp
		'
		IF @profile_type_id IS NOT NULL
		BEGIN
			SET @sql += ' WHERE profile_type = ' + CAST(@profile_type_id AS VARCHAR(50))
		END
		SET @sql += ' ORDER BY fp.profile_name'

		EXEC(@sql)

		RETURN
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
				WHERE sdd.profile_id = @profile_id
				GROUP BY sdh.source_deal_header_id

			IF EXISTS(SELECT 1 FROM #deal_to_calc)
				EXEC dbo.spa_calc_pending_deal_position @call_from = 1	
	END


	/*******************************************2nd Paging Batch START**********************************************/
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
	   SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)
	   EXEC(@str_batch_table)   
	   SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_load_forecast_report', 'Load Forecast Report') --TODO: modify sp and report name
	   EXEC(@str_batch_table) 
	   RETURN
	END

	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
	   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
	   EXEC(@sql_paging)
	END
	/*******************************************2nd Paging Batch END**********************************************/
	
END