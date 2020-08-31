
IF OBJECT_ID(N'[dbo].[spa_run_forecast]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_run_forecast]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 --===============================================================================================================
 --Author: rajiv@pioneersolutionsglobal.com
 --Updated by rtimilsina@pioneersolutonsglobal.com
 --Updated date: 2017-02-21
 --Description: forecasting using R.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_run_forecast]
    @flag CHAR(1),
    @as_of_date DATETIME = NULL,
    @mapping_id VARCHAR(MAX) = NULL,
    @train NCHAR(1) = NULL,
	@export NCHAR(1) = NULL,
	@batch_process_id VARCHAR(100) = NULL,
	@batch_report_param VARCHAR(500) = NULL
AS
/*
DECLARE     @flag CHAR(1)='r',
    @as_of_date DATETIME = '2016-3-24',
    @mapping_id VARCHAR(MAX) = '13',
    @train NCHAR(1) = 'y',
	@export NCHAR(1) = 'y',
	@batch_process_id VARCHAR(250) ='assdasdasd123123123123qwd_afsasdasdasd',
	@batch_report_param VARCHAR(500) = NULL
--*/
SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT
DECLARE @result VARCHAR(MAX)
DECLARE @str_batch_table VARCHAR(MAX)
DECLARE @start_time DATETIME
DECLARE @end_time DATETIME
DECLARE @export_file_process_id VARCHAR(250)
DECLARE @user VARCHAR(250)
DECLARE @error_code VARCHAR(250)
DECLARE @report_name VARCHAR(250)
DECLARE @master_process_id VARCHAR(250)
DECLARE @process_id VARCHAR(250)
DECLARE @user_id VARCHAR(100) 
--DECLARE @desc VARCHAR(500)
DECLARE @export_file VARCHAR(1000)
DECLARE @reportname VARCHAR(250) 
DECLARE @url VARCHAR(500)

DECLARE @lmodel2 VARBINARY(MAX)
SET @lmodel2 = NULL

SELECT @user_id = dbo.FNADBUser()

DECLARE @threshold numeric(32,20) = NULL
		,@max_step numeric(32,20)= NULL 
		,@learning_rate numeric(32,20)= NULL 
		,@repetition numeric(32,20)= NULL 
		,@hidden_layer VARCHAR(200)= NULL 
		,@algorithm_nn VARCHAR(200)= NULL
		,@error_function VARCHAR(200) = NULL
		,@approval_required VARCHAR(200)



IF @flag = 'r'
BEGIN	
    DECLARE @input_process_table	VARCHAR(200),
            @user_name				VARCHAR(100) = dbo.FNADBUser()
           
    
    IF OBJECT_ID('tempdb..#temp_mappings') IS NOT NULL	
		DROP TABLE #temp_mappings
	 IF OBJECT_ID('tempdb..#forecast_result') IS NOT NULL	
		DROP TABLE #forecast_result
	
	CREATE TABLE #temp_mappings(mapping_id INT) 
	
	SET @master_process_id = @batch_process_id

	IF NULLIF(RTRIM(LTRIM(@mapping_id)), '') IS NULL
	BEGIN
		EXEC spa_ErrorHandler -1
				, 'spa_run_forecast'
				, 'spa_run_forecast'
				, 'Error'
				, 'Please run process selecting some mapping.'
				, ''
		RETURN
	END
	
	INSERT INTO #temp_mappings
	SELECT scsv.item
	FROM dbo.SplitCommaSeperatedValues(@mapping_id) scsv
    
	
	DECLARE  @temp_forecast_output AS TABLE (
		[Date1]               DATETIME,
		--[Hour]                INT,
		[Test_Data]           FLOAT,
		[Prediction_Data]     FLOAT,
		[RMSE]                FLOAT,
		[MAPE]                FLOAT 
		--[Unit]				  VARCHAR(200) 
	)

    IF EXISTS(SELECT 1 FROM #temp_mappings)
    BEGIN
    	--BEGIN TRY    		
    		IF CURSOR_STATUS('local','forecast_cursor') > = -1
			BEGIN
				DEALLOCATE forecast_cursor
			END
			
		CREATE TABLE #forecast_result
		( ErrorCode VARCHAR(100) COLLATE DATABASE_DEFAULT,
		  Module VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		  area VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		  status VARCHAR(100) COLLATE DATABASE_DEFAULT,
		  message VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		  recommendation VARCHAR(1000) COLLATE DATABASE_DEFAULT)
		  
		  DECLARE @status VARCHAR(100)

			DECLARE @run_mapping_id INT
			DECLARE @new_summary_id INT
			--DECLARE @url VARCHAR(MAX)
			DECLARE @job_name VARCHAR(200)
			DECLARE @columnlist VARCHAR(5000)
			DECLARE @delete_query VARCHAR(5000)
			DECLARE @neural_network VARCHAR(250)
    		DECLARE forecast_cursor CURSOR LOCAL FOR
			SELECT mapping_id
			FROM  #temp_mappings
			OPEN forecast_cursor
			FETCH NEXT FROM forecast_cursor
			INTO @run_mapping_id 
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @start_time = GETDATE()
				--BEGIN TRY
					SELECT @approval_required = approval_required
					FROM forecast_mapping fm
					WHERE fm.forecast_mapping_id = @run_mapping_id

						INSERT INTO #forecast_result			
						EXEC spa_run_forecast_model @forecast_mapping_id = @run_mapping_id,@as_of_date = @as_of_date,@process_table_name = @input_process_table OUTPUT,@columlist_data = @columnlist OUTPUT,@neural_network = @neural_network OUTPUT

						SELECT @status = status FROM #forecast_result
							
						SET @delete_query	 = 'DELETE FROM ' + @input_process_table +' WHERE ' 
						SET @columnlist= REPLACE(@columnlist,' ,',' IS NULL OR ')
						SELECT @columnlist = LEFT(@columnlist,LEN(@columnlist)-2)
						SET @delete_query = @delete_query + REPLACE(@columnlist, ',', ' ') + ' AND output_type <>''f'''
							
							
						SET @process_id = dbo.FNAGetNEWID()
									
						IF @status = 'Success'
							BEGIN			
								IF @export = 'y'
								BEGIN
									SELECT @export_file = document_path FROM connection_string
									SET @export_file= @export_file+'\Temp_Note\'
									SET @reportname = 'run_forecast_'
									SET @reportname = @reportname + @user_id+'_'+ @process_id+'.csv'
									SET @export_file = @export_file + @reportname
									

								EXEC spa_export_to_csv  @table_name = @input_process_table
														,@export_file_name = @export_file
														,@include_column_headers = 'y'
														,@delimiter = ','
														,@compress_file = 'n'
														,@use_date_conversion = 'y'
														,@strip_html = 'y'
														,@enclosed_with_quotes = 'n'
														,@result = @result OUTPUT
									
								SET @desc = 'Batch process completed for <b>' + @reportname + '</b>.'
								SET @url = '../../adiha.php.scripts/dev/shared_docs/temp_Note/' + @reportname 
								SET @desc = @desc +  'Report has been saved. Please <a target="_blank" href="' + @url + 
										'"><b>Click Here</a></b> to download.'

								--IF NOT EXISTS(SELECT 1 FROM  source_system_data_import_status WHERE master_process_id = master_process_id)
								--BEGIN
										INSERT INTO source_system_data_import_status (
											process_id
											,code
											,[module]
											,[source]
											,[type]
											,[description]
											,recommendation
											,master_process_id
											)
										SELECT @process_id
											,'forecast'
											,'forecast data'
											,'Forecast Export file'
											,'Export'
											,@desc
											,Recommendation
											,@master_process_id
									FROM #forecast_result
								--END
										INSERT INTO source_system_data_import_status_detail (
												process_id
												,[source]
												,[type]
												,[description]
												)
											SELECT @master_process_id
												,'Forecast File'
												,'Success'
												,@desc
								END
							 ELSE 
							 BEGIN
									INSERT INTO source_system_data_import_status (
												process_id
												,code
												,[module]
												,[source]
												,[type]
												,[description]
												,recommendation
												,master_process_id
												)
											SELECT @process_id
												,'forecast'
												,'forecast data'
												,'Forecast data Collection'
												,'Data'
												,Message
												,Recommendation
												,@master_process_id
										FROM #forecast_result
										
							 END
							END
		
					
				EXEC(@delete_query)
				
				SELECT @lmodel2 = model 
					FROM forecast_mapping 
					WHERE forecast_mapping_id = @run_mapping_id

					IF NULLIF(@lmodel2,'') IS NULL 
					BEGIN 
						SET @train = 'y'
					END

					IF @train = 'y'
					BEGIN	
						DECLARE @IntVariable INT;
						DECLARE @SQLString NVARCHAR(500);
						DECLARE @ParmDefinition NVARCHAR(500);

						SET @IntVariable = 500
						SET @SQLString = N'SELECT @threshold_out= threshold,
														@max_step_out = maximum_step,
														@learning_rate_out = learning_rate,
														@repetition_out  = repetition,
														@hidden_layer_out = hidden_layer,
														@algorithm_out = algorithm,
														@error_function_out = error_function
													   FROM ' + @neural_network;
							SET @ParmDefinition = N'@threshold_out VARCHAR(200) OUTPUT, @max_step_out numeric(38,20) OUTPUT,@learning_rate_out numeric(38,20) OUTPUT
							 ,@repetition_out numeric(38,20) OUTPUT,@hidden_layer_out VARCHAR(200) OUTPUT,@algorithm_out VARCHAR(200) OUTPUT,@error_function_out VARCHAR(200) OUTPUT';

								 
							EXECUTE sp_executesql @SQLString
									,@ParmDefinition
									,@threshold_out = @threshold OUTPUT
									,@max_step_out = @max_step OUTPUT
									,@learning_rate_out = @learning_rate OUTPUT
									,@repetition_out = @repetition OUTPUT
									,@hidden_layer_out = @hidden_layer OUTPUT
									,@algorithm_out = @algorithm_nn OUTPUT
									,@error_function_out = @error_function OUTPUT

							 
					SET @hidden_layer = 'c('+@hidden_layer+')'
					
					EXEC spa_run_forecast_train @flag = 's'
								,@input_process_table = @input_process_table
								,@mapping_id = @run_mapping_id
								,@threshold = @threshold
								,@max_step = @max_step
								,@learning_rate = @learning_rate
								,@repetation = @repetition
								,@hidden_layer = @hidden_layer
								,@algorithm_nn = @algorithm_nn
								,@error_function = @error_function

							SELECT @lmodel2 = model 
									FROM forecast_mapping 
									WHERE forecast_mapping_id = @run_mapping_id
					END
			
					
	
					--IF OBJECT_ID('tempdb..#temp_forecast_output') IS NOT NULL	
					--	DROP TABLE #temp_forecast_output
			
					--CREATE TABLE #temp_forecast_output(
					--	[Date1]               DATETIME,
					--	--[Hour]                INT,
			 	--		[Test_Data]           FLOAT,
			 	--		[Prediction_Data]     FLOAT,
					--	[RMSE]                FLOAT,
					--	[MAPE]                FLOAT 
			 	--		--[Unit]				  VARCHAR(200) COLLATE DATABASE_DEFAULT 
					--)
				DELETE FROM @temp_forecast_output

					DECLARE @nsql NVARCHAR(MAX)
					--SET @nsql = N' SELECT * FROM ' + @input_process_table + ' WHERE output_type == ''t'' ; '
				    SET @nsql = N' SELECT * FROM ' +@input_process_table  
					
								INSERT INTO @temp_forecast_output([Date1], [Test_Data], [Prediction_Data], [RMSE], [MAPE])
					EXEC sp_execute_external_script  @language =N'R'    
						,@script=N'
				#----------------------------
				# calculate range difference 
				nc1 <- which(colnames(Load_data)=="termstart" )
				n_check <- nc1+1
				n_start <- 1:(n_check-1)
				# ------------------------------------
				# step 1 ( load train data only)
				Load_train <- Load_data[Load_data$output_type == ''r'',]
				range_cal <- sapply(Load_train[,-n_start],range)
				diff_r <- range_cal[2,]-range_cal[1,]
				col <- which(diff_r!=0)
				columnname1 <- names(Load_train[,n_check:ncol(Load_train)])
				columnname <- columnname1[col]
				inpmat <- Load_train[,columnname]
				#
				nc <- ncol(inpmat)
				nl <- nc-1
				#---------------------
				#
				library(neuralnet)
				library(Scale)
				
				# scaling data in an interval of [0,1] so that each variable is treated equally
				# STEP 1 (scale train data only)
				input_train <- inpmat
				maxs   <- apply(input_train, 2, max) 
				mins   <- apply(input_train, 2, min)
				scaled_train1 <- as.data.frame(scale(input_train, center = mins, scale = maxs - mins))
				scaled_train <- scaled_train1[sample(nrow(scaled_train1)),]
				indx   <- nrow(scaled_train)

				# STEP 2 (scale test data)
				Load_test <- Load_data[Load_data$output_type == ''t'',]
				input_test <- Load_test[,columnname]
				scaled_test <- as.data.frame(scale(input_test, center = mins, scale = maxs - mins))
				indx2 <- nrow(scaled_test)
				# combine train and test data 
				hist_data <- rbind(input_train,input_test)

				# STEP 3 ( scale forecast data without the variable that is to be forecasted)
				Load_forecast <- Load_data[Load_data$output_type == ''f'',]
				input_forecast1 <- Load_forecast[,columnname]
				input_forecast <- input_forecast1[-nc]
				scaled_forecast <- as.data.frame(scale(input_forecast, center = mins[-nc], scale = maxs[-nc] - mins[-nc]))
				indx3 <- nrow(scaled_forecast)
				 
				#-----------------------------------------------------------------------------------------------------------------------
				# Conducting neural network 
				# Get NN parameters from trained model   
				nn <- unserialize(as.raw(model));
				
				#This section is for the prediction  in test data 
				test <- scaled_test
				prediction.test <- compute(nn, test[,1:nl])

				#results from nn are normalized and we need to bring back them to their real scale 
				prediction.nn.test <- (prediction.test$net.result) *(max(hist_data[,nl+1])-min(hist_data[,nl+1]))+min(hist_data[,nl+1])
				test.r <- (test[,nl+1])*(max(hist_data[,nl+1])-min(hist_data[,nl+1]))+min(hist_data[,nl+1])
				
				#This section is for the prediction 
				forcast1 <- scaled_forecast
				prediction.f <- compute(nn, forcast1[,1:nl])

				#results from nn are normalized and we need to bring back them to their real scale 
				prediction.nn.fcast <- (prediction.f$net.result) *(max(hist_data[,nl+1])-min(hist_data[,nl+1]))+min(hist_data[,nl+1])
				
				#-------------------------------------------------------------------------
				# Error Analysis 
				RMSE.nn  <-sqrt(mean((test.r-prediction.nn.test)^2))
				MAE.nn  <-mean(abs(test.r-prediction.nn.test)/(test.r))
				MAPE.nn <- MAE.nn*100

				n_row_test1 <-  indx2; 	
				MAPE1 <- rep(MAPE.nn,length.out=n_row_test1)
				RMSE1 <- rep(RMSE.nn,length.out=n_row_test1)

				n_row_test2 <-  indx3; 
				MAPE <- rep(MAPE.nn,length.out=n_row_test2)
				RMSE <- rep(RMSE.nn,length.out=n_row_test2)

				fcast_test <- rep("",length.out=n_row_test2)
				#--------------------------------------------------------------------------
				
				# create table of forecasted data 
				Date1 <- Load_test$termstart
				Date2 <- Load_forecast$termstart
				fcast <- data.frame(Date1 = Date1,Test_Data=(matrix(test.r)),Prediction_Data=(matrix(prediction.nn.test)),RMSE=RMSE1,MAPE=MAPE1)
				fcast1 <- data.frame(Date1 = Date2,Test_Data=(matrix(fcast_test)),Prediction_Data=(matrix(prediction.nn.fcast)),RMSE=RMSE,MAPE=MAPE)
				fin_fcast <- rbind(fcast,fcast1)

				#----------------------Performing simulations-------------------
				Load_data_out <- fin_fcast;'    
				,@input_data_1 = @nsql
				,@input_data_1_name = N' Load_data'
				,@output_data_1_name = N' Load_data_out' 
				,@params = N'@model varbinary(max)'  
				,@model = @lmodel2 
				
				INSERT INTO forecast_result_summary (process_id, forecast_mapping_id)
					SELECT @process_id, @run_mapping_id
			
					SELECT @new_summary_id = frs.forecast_result_summary_id
					FROM forecast_result_summary frs
					WHERE frs.process_id = @process_id
					AND frs.forecast_mapping_id = @run_mapping_id
			
			
					INSERT INTO forecast_result (
						process_id, 
						forecast_summary_id,
						maturity,
						predicition_data,
						test_data
					)
					SELECT @process_id, 
						   @new_summary_id, 
						  -- DATEADD(HOUR, [Hour], [date1]),--DATEADD(MINUTE, ISNULL([mins], 0), ),
						   Date1,
						   Prediction_Data,
						   Test_Data
					FROM @temp_forecast_output

					 INSERT INTO forecast_error_list(
					  [process_id]
					  ,[RMSE]
					  ,[MAPE])
					SELECT DISTINCT @process_id,
						    [RMSE]
							,[MAPE]
					FROM @temp_forecast_output
			
					SET @end_time = GETDATE()
					SELECT @desc = 'Forecasting process completed sucessfully. Forecast Type - ' + 
									sdv.code	 
									+ '. Total time enlapse time (s): ' 
									+CAST(DATEDIFF(s,@start_time,@end_time) AS VARCHAR(100))
					FROM forecast_mapping fm
					INNER JOIN forecast_model fmm ON fm.forecast_model_id = fmm.forecast_model_id
					INNER JOIN static_data_value sdv ON sdv.value_id = fmm.forecast_type
 					WHERE fm.forecast_mapping_id = @run_mapping_id	
					/** Error handeling and messaging - message for each mapping model - Success case - Start **/
				
				
				IF ISNULL(@approval_required,'y') = 'n'
				BEGIN 
					EXEC spa_forecast_parameters_mapping @flag ='v',@forecast_mapping_id = @run_mapping_id,@process_id = @process_id
				END


						INSERT INTO source_system_data_import_status(Process_id, code, module, source, type, description, recommendation, create_ts, create_user, rules_name,master_process_id) 
 						SELECT @process_id,
 							   'Success',
 							   'Forecast',
 							   'Forecast File',
 							   'Success',
 								@desc,
 							   '',
							   GETDATE(),
							   dbo.FNAdbuser()
							   ,sdv.code --'Forecast File Creation'
							   ,@master_process_id
						FROM forecast_mapping fm
						INNER JOIN forecast_model fmm ON fm.forecast_model_id = fmm.forecast_model_id
						INNER JOIN static_data_value sdv ON sdv.value_id = fmm.forecast_type
 						WHERE fm.forecast_mapping_id = @run_mapping_id
 					
 					
 					SET @job_name = 'Forecast_' + @process_id
 					
 					/** Error handeling and messaging - message for each mapping model - Success case - END **/
					--IF NOT EXISTS(SELECT 1 from source_system_data_import_status WHERE process_id = @batch_process_id)
					--BEGIN
 				--		INSERT INTO source_system_data_import_status (process_id, code, [module], [source], [type], [description], recommendation,master_process_id)
					--	SELECT @batch_process_id,
					--		  'Success',
					--		  'Forecast',
					--		  'Forecast File',
					--		  'Success',
					--		  @desc,--'<a href="javascript: second_level_drill(''EXEC spa_get_import_process_status_detail^' + @process_id + '^,^Forecast File^'')"></a>',
					--		  ''
					--		  ,@master_process_id
					--END
					SET @user =  dbo.FNAdbuser()
					
					INSERT INTO source_system_data_import_status_detail (process_id, [source], [type], [description])
					SELECT @batch_process_id, 'Forecast File', 'Success', @desc 	

					SELECT @url = './dev/spa_html.php?__user_name__=' + @user + '&spa=exec spa_get_import_process_status ''' + @master_process_id + ''','''+@user+''''
 	
					SELECT @desc = '<a target="_blank" href="' + @url + '"><ul style="padding:0px;margin:0px;list-style-type:none;">' 
 							+ '<li style="border:none">Forecasting process completed sucessfully.<br /> Forecast Rule Executed:<ul style="padding:0px 0px 0px 10px;margin:0px 0px 0px 10px;list-style-type:square;"><ul/></li><li style="border:none">Elasped Time(s): ' + CAST(DATEDIFF(s,@start_time,@end_time) AS VARCHAR(100)) + '.</li>'
 					
					EXEC spa_message_board 'u', @user,  NULL, 'Forecast', @desc, '', '', 's',  @job_name, NULL, @master_process_id, '', '', '', 'y'

				--END TRY
				--BEGIN CATCH
				--	/** Error handeling and messaging - message for each mapping model - Error case - Start **/
				--	IF NOT EXISTS(SELECT 1 FROM source_system_data_import_status WHERE master_process_id = @master_process_id)
				--	BEGIN
				--		INSERT INTO source_system_data_import_status (process_id, code, [module], [source], [type], [description], recommendation,master_process_id)
				--		SELECT @process_id,
				--			  'Error',
				--			  'Forecast',
				--			  'Forecast File',
				--			  'Error',
				--			  'Error found in forecasting process for model - ' + sdv.code,
				--			  'Please check detail error.'
				--			  ,@master_process_id
				--		FROM forecast_mapping fm
				--		INNER JOIN forecast_model fmm ON fm.forecast_model_id = fmm.forecast_model_id
				--		INNER JOIN static_data_value sdv ON sdv.value_id = fmm.forecast_type
 			--			WHERE fm.forecast_mapping_id = @run_mapping_id
 			--		END
 			--		SET @desc = 'Forecasting process completed with error. ( Errr Description:' + ERROR_MESSAGE() + ').'
 			--		EXEC spa_print @desc
 			--		INSERT INTO source_system_data_import_status_detail (process_id, [source], [type], [description])
				--	SELECT @process_id, 'Forecast File', 'Error', @desc 	
					
				--	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_name + '&spa=exec spa_get_import_process_status ''' + @process_id + ''','''+@user_name+''''
				--	SELECT @desc = '<a target="_blank" href="' + @url + '">' 
				--				   + 'Forecasting process completed with error. Forecast Type - ' + sdv.code + '.<br />' + ' (Error found)'
				--				   + '.</a>'	
				--	FROM forecast_mapping fm
				--	INNER JOIN forecast_model fmm ON fm.forecast_model_id = fmm.forecast_model_id
				--	INNER JOIN static_data_value sdv ON sdv.value_id = fmm.forecast_type
 			--		WHERE fm.forecast_mapping_id = @run_mapping_id	
 					
 			--		SET @job_name = 'Forecast_' + @process_id
 					
 			--		EXEC spa_message_board 'i', @user_name, NULL, 'Forecast', @desc, '', '', 'e' , @job_name, NULL, @process_id, '', '', '', 'y'
 			--		/** Error handeling and messaging - message for each mapping model - Error case - END **/		
				--END CATCH
				FETCH NEXT FROM forecast_cursor INTO @run_mapping_id
			END		
			CLOSE forecast_cursor
			DEALLOCATE forecast_cursor

			EXEC spa_ErrorHandler 0
				, 'spa_run_forecast'
				, 'spa_run_forecast'
				, 'Success'
				, 'Forecasting process completed sucessfully.'
				, ''
   -- 	END TRY
   -- 	BEGIN CATCH
   -- 		IF @@TRANCOUNT > 0
			--	ROLLBACK
			--SELECT @err_no = ERROR_NUMBER()
   -- 		IF CURSOR_STATUS('local','forecast_cursor') > = -1
			--BEGIN
			--	DEALLOCATE forecast_cursor
			--END
			--SET @desc = 'Forecasting process completed with error. ( Errr Description:' + ERROR_MESSAGE() + ').'
			
			--EXEC spa_ErrorHandler @err_no
			--	, 'spa_run_forecast'
			--	, 'spa_run_forecast'
			--	, 'Success'
			--	, @desc
			--	, ''
   -- 	END CATCH
    END	
END


