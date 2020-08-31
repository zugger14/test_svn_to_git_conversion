/*
* Sp to process logs from Nominator Requests
* For Nominator module_type: 4035 (static_value id)
*/
IF OBJECT_ID('[dbo].[spa_load_forecast_nominator_request_log]','p') IS NOT NULL 
DROP PROC [dbo].[spa_load_forecast_nominator_request_log]
GO

CREATE PROC [dbo].[spa_load_forecast_nominator_request_log]
    @flag CHAR(1),
    @process_id VARCHAR(50) = NULL,
    @module_type VARCHAR(50) = NULL,
    @request_time DATETIME = NULL,
    @request_filename VARCHAR(100) = NULL,
    @as_of_date VARCHAR(32) = NULL,  -- format: YYYY-MM-DD
    @request_id VARCHAR(16) = NULL,
    @source_commodity VARCHAR(16) = NULL,
    @header_buy_sell_flag CHAR(2) = NULL

AS

DECLARE @err_msg VARCHAR(1000)

BEGIN TRY

		/*
		* Load Forecast Nominator requests
		*/
		IF @module_type = '4035'
		BEGIN
		
			--Description column in import_data_request_status_log table holds csv value of commodity and deal header buy/sell flag
			
			/*
			* Extract request string from log inserted after Pratos import is successful
			* module_type is static_data_value id
			*/
			IF @flag = 's'
			BEGIN

        		SELECT i.request_string, i.[description] FROM [import_data_request_status_log] i WHERE 
        		CONVERT(VARCHAR(10),i.as_of_date,120) = @as_of_date AND i.request_time IS NULL AND module_type = @module_type
				AND i.process_id = @process_id AND dbo.FNAGetSplitPart(i.[description], ',', 1) = @source_commodity
				AND dbo.FNAGetSplitPart(i.[description], ',', 2) = @header_buy_sell_flag
				ORDER BY
				CASE SUBSTRING(request_string,1,1)
					WHEN ';' THEN NULL
					ELSE dbo.fnagetsplitpart(request_string, ';', 1) 
				END ,  ---location
				CONVERT(DATETIME,
						CASE SUBSTRING(request_string,1,1)
							WHEN ';' THEN dbo.fnagetsplitpart(request_string, ';', 1) 
							ELSE dbo.fnagetsplitpart(request_string, ';', 2) 
						END, 
						103) ---test
			END
	        
			/*
			* Extract process Id from log whose as_of_date and module_type is as defined and no request is processed yet
			*/
			ELSE IF @flag = 'p'
			BEGIN
	        	
        		SELECT DISTINCT process_id, dbo.FNAGetSplitPart([description], ',', 1) source_commodity, dbo.FNAGetSplitPart([description], ',', 2) header_buy_sell_flag --, COUNT(*) request_count  
				FROM import_data_request_status_log
				WHERE request_time IS NULL AND module_type = @module_type AND CONVERT(VARCHAR(10),as_of_date,120) = @as_of_date AND [description] IS NOT null
				--GROUP BY [description],process_id

			END
	        
			/*
			* updates log after nominator file is generated
			*/
			ELSE IF @flag = 'u'
			BEGIN
        		IF @process_id IS NOT NULL AND @process_id != '' 
        		BEGIN
					UPDATE import_data_request_status_log SET 
					request_time = getdate(), request_file_name = @request_filename
					WHERE process_id = @process_id  AND module_type = @module_type
					AND dbo.FNAGetSplitPart([description], ',', 1) = @source_commodity
					AND dbo.FNAGetSplitPart([description], ',', 2) = @header_buy_sell_flag
					EXEC spa_print 'log update query executed'
				END
			END

		END
		
END TRY

BEGIN CATCH
    DECLARE @error_no INT
    SET @error_no = error_number()
    SET @err_msg = ''
    IF @flag = 'u'
        SET @err_msg = 'Fail to update log'
	Exec spa_ErrorHandler @error_no, 'import_data_request_status_log', 
					'import_data_request_status_log', 'DB Error', 
					@err_msg, ''
END CATCH
		
		