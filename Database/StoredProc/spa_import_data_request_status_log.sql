/*
* Sp to process logs from Nominator Requests and CMA Interface
* For CMA module_type: 4008 (static_value id)
*/
IF OBJECT_ID('[dbo].[spa_import_data_request_status_log]','p') IS NOT NULL 
DROP PROC [dbo].[spa_import_data_request_status_log]
GO

CREATE PROC [dbo].[spa_import_data_request_status_log]
    @flag CHAR(1),
    @process_id VARCHAR(50) = NULL,
    @module_type VARCHAR(50) = NULL,
    @request_time DATETIME = NULL,
    @request_filename VARCHAR(50) = NULL,
    @as_of_date VARCHAR(32) = NULL,  -- format: YYYY-MM-DD
    @request_system VARCHAR(32) = NULL,
    @granularity VARCHAR(32) = NULL,
    @valuation_unit VARCHAR(32) = '',
    @market_value_id VARCHAR(32) = NULL,
    @key_value VARCHAR(50) = NULL,
    @request_id VARCHAR(16) = NULL,
    @response_time DATETIME = NULL,
    @response_filename VARCHAR(128) = NULL,
    @response_status VARCHAR(128) = NULL,
    @description VARCHAR(1000) = NULL,
    @data_filename VARCHAR(128) = NULL,
    @data_update_time DATETIME  = NULL,
    @data_update_status VARCHAR(128) = NULL,
    @update_by_key_value INT = NULL, --update by single key value(1) or multiple (2). For multiple, update_key_values sud be defined
    @update_key_values VARCHAR(1000) = NULL, -- comma seperated keys
    @curve_id_csv VARCHAR(1000) = NULL
AS

DECLARE @err_msg VARCHAR(1000)

BEGIN TRY
		/*
		* CMA Interface
		*/
		
		IF @module_type = '4008'
		BEGIN
			
			
			/*
			* Generates Request Xml
			*/
			IF @flag = 'a'
			BEGIN
        	
        			DECLARE @reqId VARCHAR(16),@reqTime VARCHAR(32), @requestXmlFileName VARCHAR(128), @crop_len INT
					DECLARE @base_unit VARCHAR(8)
					SET @base_unit = ''
	        		
        			SELECT @reqId = ISNULL(MAX(request_id),0)+1, 
	       				   @reqTime= dbo.FNAGetUTCTimeWithOffset(GETDATE(), NULL), --CONVERT(VARCHAR,GETDATE(),120), 
	       				   @requestXmlFileName = 'CMA_CURVE_REQ_'+@request_system+'_'+ 
	       					replace(replace(replace(convert(nvarchar(255),getDate(),20),'-',''),':',''),' ','_')+
	       					'.xml'
					FROM import_data_request_status_log idrsl
					
					SET @curve_id_csv = NULLIF(@curve_id_csv, '')
					
					SELECT '<?xml version=''1.0'' encoding=''UTF-8'' ?>' + 
					(SELECT(
						SELECT @reqId Request_Id, 
							   @reqTime as Request_Timestamp, 
							   @request_system AS Request_System 
						FOR XML PATH('EMG_Curve_Request_Header'), TYPE  
					),
					(
						SELECT (
							
							SELECT DISTINCT dbo.FNAGetSplitPart(curve_id, ' - ', 1) as Name,
							 	   CAST(@as_of_date as VARCHAR(10)) + 'T00:00:00+00:00' as Publish_Date,
								   @granularity AS Granularity,
								   --ISNULL(sdv.code, @granularity) AS Granularity,
								   @valuation_unit AS Valuation_Unit,
								   @base_unit AS Base_Unit
								   --sc.currency_id AS Base_Unit 
							FROM source_price_curve_def spcd
							  -- LEFT JOIN source_currency sc ON spcd.source_currency_id = sc.source_currency_id
							  -- LEFT JOIN static_data_value sdv ON sdv.value_id = spcd.Granularity
							  LEFT JOIN dbo.SplitCommaSeperatedValues(@curve_id_csv) scsv ON spcd.source_curve_def_id = scsv.Item
							  WHERE market_value_id = @market_value_id
								AND (@curve_id_csv IS NULL OR scsv.Item IS NOT NULL)
							FOR XML PATH('EMG_Price_Curve_Request'), TYPE  
						)

						FOR
						XML PATH('EMG_Curve_Request_List'),
						TYPE
					)
					FOR XML PATH(''),
					ROOT('EMG_Curve_Request')
					) AS req_xml, @reqId AS request_id


					-- UPDATE the log table					
					INSERT INTO import_data_request_status_log 
        			( key_value, request_id,  module_type, request_file_name, request_time, as_of_date ) 
					  SELECT DISTINCT dbo.FNAGetSplitPart(curve_id, ' - ', 1), @reqId, @module_type, @requestXmlFileName, CONVERT(VARCHAR(19), @reqTime, 127),  @as_of_date        			
        			  FROM source_price_curve_def spcd
					  LEFT JOIN dbo.SplitCommaSeperatedValues(@curve_id_csv) scsv ON spcd.source_curve_def_id = scsv.Item
        			  
					  -- LEFT JOIN source_currency sc ON spcd.source_currency_id = sc.source_currency_id
					  WHERE market_value_id = @market_value_id AND (@curve_id_csv IS NULL OR scsv.Item IS NOT NULL)


			END
			
			/* 
			* Check if request is required to be generated for given as of date
			*/
			ELSE IF @flag = 'q'
			BEGIN
				IF NOT EXISTS (
        			SELECT * FROM import_data_request_status_log i 
        			INNER JOIN source_price_curve_def s ON s.curve_id LIKE i.key_value + '%' 
        			WHERE CONVERT(VARCHAR(10),i.as_of_date,120) = @as_of_date 
        			AND s.market_value_id = 'CMA' AND module_type = @module_type
        		)
        			SELECT 1 AS require_request
        		ELSE 
        			SELECT 0 AS require_request
			END

        
			/* 
			* for any requests, checks whether or not the response is required
			*/
			ELSE IF @flag = 'r'
			BEGIN
        		IF EXISTS (
        		SELECT TOP 1 i.request_file_name FROM import_data_request_status_log i WHERE i.request_id = @request_id AND i.request_time IS NOT
        		NULL AND (i.response_time IS NULL OR i.response_status <> 'SUCCESS' OR i.data_update_status <> 'SUCCESS') AND module_type = @module_type ) 
        			SELECT 1 AS require_response
        		ELSE 
        			SELECT 0 AS require_response
			END
        
			/*
			* insert log with generated request
			*/
			ELSE IF @flag = 'i' 
	        BEGIN
        		DECLARE @kv AS VARCHAR(64)
        		SELECT @kv = curve_id FROM source_price_curve_def s WHERE s.market_value_id = @market_value_id
        		INSERT INTO import_data_request_status_log 
        		( request_id,  module_type, request_file_name, request_time, key_value, as_of_date ) VALUES
        		(@request_id, @module_type, @request_filename, @request_time  ,	@kv		 , @as_of_date  )

	        END
	        
			/*
			* updates log for respective response file
			*/
		    ELSE IF @flag = 'e'
		    BEGIN
		    	DECLARE @q VARCHAR(1000)
		    	
		    	--UPDATE import_data_request_status_log SET process_id = @process_id, response_time = @response_time  , response_file_name = 
		    	--@response_filename, response_status = @response_status, [description] = @description, data_file_name = @data_filename,
		    	--data_update_time = @data_update_time, data_update_status = @data_update_status 
		    	--WHERE request_id = @request_id AND module_type = @module_type
		    	
		    	SET @q = 'UPDATE i SET request_id = request_id '
		    	+ CASE WHEN @process_id IS NOT NULL THEN ', process_id = '+ dbo.FNASingleQuote(@process_id) ELSE '' END +
		    	+ CASE WHEN @key_value IS NOT NULL THEN ', key_value = '+ dbo.FNASingleQuote(@key_value) ELSE '' END + 
		    	+ CASE WHEN @response_time IS NOT NULL THEN ', response_time = '+ dbo.FNASingleQuote(@response_time) ELSE ''  END +
		    	+ CASE WHEN @response_filename IS NOT NULL THEN ', response_file_name = '+ dbo.FNASingleQuote(@response_filename) ELSE ''  END +
				+ CASE WHEN @response_status IS NOT NULL THEN ', response_status = '+ dbo.FNASingleQuote(@response_status) ELSE ''  END +
		    	+ CASE WHEN @description IS NOT NULL THEN ', [description] = '+ dbo.FNASingleQuote(@description) ELSE '' END +
		    	+ CASE WHEN @data_filename IS NOT NULL THEN ', data_file_name = '+ dbo.FNASingleQuote(@data_filename) ELSE '' END +
		    	+ CASE WHEN @data_update_time IS NOT NULL THEN ', data_update_time = '+ dbo.FNASingleQuote(@data_update_time) ELSE '' END +
		    	+ CASE WHEN @data_update_status IS NOT NULL THEN ', data_update_status = '+ dbo.FNASingleQuote(@data_update_status) ELSE '' END +
				' FROM import_data_request_status_log i '
				+ CASE WHEN @update_by_key_value = 2 THEN ' INNER JOIN dbo.SplitCommaSeperatedValues('''+@update_key_values+''') scsv ON i.key_value = scsv.Item ' ELSE '' END +
		    	' WHERE request_id = '+ dbo.FNASingleQuote(@request_id) + ' AND module_type = '+ dbo.FNASingleQuote(@module_type)
		    	+ CASE WHEN @update_by_key_value = 1 THEN ' AND key_value = ' + dbo.FNASingleQuote(@key_value) ELSE '' END
		    	exec spa_print @q
		    	EXEC (@q)
		    	
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


    