IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_setup_archive_data]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_setup_archive_data]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
Object: Stored procedure [dbo].[spa_setup_archive_data]
Author: Subodh Khanal
Script Date: October 23, 2017
Description: This procedure is used for Setup Archive Data UI

Params:
	@flag CHAR(1)
	@data_type INT
	@as_of_date_from VARCHAR(20)
	@as_of_date_to VARCHAR(20)
	@data_location_left INT
	@data_location_right INT
	@archive_type_value_id INT
	@batch_process_id VARCHAR(50)
	@batch_report_param VARCHAR(5000)
*/

CREATE PROCEDURE [dbo].[spa_setup_archive_data]
	@flag CHAR(1) = NULL,
	@data_type INT = NULL,
	@as_of_date_from VARCHAR(20) = NULL,
	@as_of_date_to VARCHAR(20) = NULL,
	@data_location_left INT = NULL,
	@data_location_right INT = NULL,
	@archive_type_value_id INT = NULL,
	@exclude_archive INT = NULL,
	@batch_process_id VARCHAR(50) = NULL,
	@batch_report_param VARCHAR(5000) = NULL,
	@as_of_dates VARCHAR(MAX) = NULL,
	@ltr CHAR = 'y'
AS
BEGIN
	SET NOCOUNT ON
	
	IF @batch_process_id IS NOT NULL
	   AND @batch_report_param IS NOT NULL
	BEGIN
	    DECLARE @str_batch_table     VARCHAR(MAX) = '',
	            @temp_table_name     VARCHAR(200) = ''
	    
	    IF (@batch_process_id IS NULL)
	        SET @batch_process_id = REPLACE(NEWID(), '-', '_')
	    
	    SET @temp_table_name = dbo.FNAProcessTableName('batch_report', dbo.FNADBUser(), @batch_process_id)
	    
	    SET @str_batch_table = ' INTO ' + @temp_table_name
	END
	
	DECLARE @sql VARCHAR(MAX)
	DECLARE @table_name			VARCHAR(100),
	        @where_field		VARCHAR(100),
	        @source				VARCHAR(100),
	        @table_name_from	VARCHAR(100),
	        @table_name_to		VARCHAR(100),
	        @where_field_from	VARCHAR(100),
	        @where_field_to		VARCHAR(100)
	        
	IF @flag = 'c'
	BEGIN
	    SET @sql = '
			SELECT adpd.sequence table_name,
				   CASE 
						WHEN adpd.is_arch_table = 0 THEN ''Main''
						ELSE ''Archive '' + CAST(adpd.sequence -1 AS VARCHAR(2))
				   END
			FROM   archive_data_policy_detail adpd
				   INNER JOIN archive_data_policy adp
						ON  adpd.archive_data_policy_id = adp.archive_data_policy_id
						AND adp.archive_type_value_id = ' + CAST(@archive_type_value_id AS VARCHAR(100))
						
		IF @exclude_archive IS NOT NULL
		BEGIN
			SET @sql += '
				WHERE adpd.sequence <> ' + CAST(@exclude_archive AS VARCHAR(100))
		END
		
		EXEC(@sql)
	END
	
	ELSE IF @flag = 'l'
	BEGIN
	    SELECT @table_name = table_name,
	           @where_field     = where_field,
	           @source          = CASE 
	                          WHEN adpd.is_arch_table = 0 THEN '''Main'''
	                          ELSE '''Archive ' + CAST(adpd.sequence -1 AS VARCHAR(2)) + ''''
	                     END
	    FROM   archive_data_policy_detail adpd
	           INNER JOIN archive_data_policy adp
	                ON  adpd.archive_data_policy_id = adp.archive_data_policy_id
	                AND adp.archive_type_value_id = @data_type
	                AND adpd.sequence = @data_location_left
	                
	    SET @sql = 'SELECT DISTINCT ' + @source + ' AS [data_location], ' + @where_field + '[as_of_date] from ' +
	        @table_name + ' WHERE 1 = 1'
	    
	    IF @as_of_date_from IS NOT NULL
	        SET @sql += ' AND ' + @where_field + ' >= ''' + @as_of_date_from + ''''
	    
	    IF @as_of_date_to IS NOT NULL
	        SET @sql += ' AND ' + @where_field + ' <= ''' + @as_of_date_to + ''''
	    
	    EXEC (@sql)
	END
	
	ELSE IF @flag = 'r'
	BEGIN
	    SELECT @table_name = table_name,
	        @where_field     = where_field,
	        @source          = CASE 
	                        WHEN adpd.is_arch_table = 0 THEN '''Main'''
	                        ELSE '''Archive ' + CAST(adpd.sequence -1 AS VARCHAR(2)) + ''''
	                    END
	    FROM   archive_data_policy_detail adpd
	        INNER JOIN archive_data_policy adp
	                ON  adpd.archive_data_policy_id = adp.archive_data_policy_id
	                AND adp.archive_type_value_id = @data_type
	                AND adpd.sequence = @data_location_right
	         
	    SET @sql = 'SELECT DISTINCT ' + @source + ' AS [data_location], ' + @where_field + '[as_of_date] from ' +
	        @table_name + ' WHERE 1 = 1'
	         
	    IF @as_of_date_from IS NOT NULL
	        SET @sql += ' AND ' + @where_field + ' >= ''' + @as_of_date_from + ''''
	         
	    IF @as_of_date_to IS NOT NULL
	        SET @sql += ' AND ' + @where_field + ' <= ''' + @as_of_date_to + ''''
	         
	    EXEC (@sql)
	END
	
	ELSE IF @flag = 'z'
	     BEGIN	   
	     	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
			    DROP TABLE #temp
	         SELECT adpd.table_name,
	                adpd.sequence,
	                where_field
	         INTO   #temp
	         FROM   archive_data_policy_detail adpd
	                INNER JOIN archive_data_policy adp
	                     ON  adpd.archive_data_policy_id = adpd.archive_data_policy_id
	         WHERE  adp.archive_type_value_id = @data_type
	         
			 --select * from #temp
			 --PRINT 1
	         SELECT @table_name_from = table_name,
	                @where_field_from     = where_field
	         FROM   #temp
	         WHERE  sequence              = IIF(@ltr = 'y', @data_location_left, @data_location_right)
	         
	         SELECT @table_name_to = table_name,
	                @where_field_to     = where_field
	         FROM   #temp
	         WHERE  sequence            = IIF(@ltr = 'y', @data_location_right, @data_location_left)
	         --PRINT('''' + REPLACE(@as_of_dates, ',', ''', ''') + '''') return
	         
	         SELECT @table_name_from      table_name_from,
	                @table_name_to        table_name_to,
	                @where_field_from     where_field_from,
	                @where_field_to       where_field_to
	         
	         SET @sql = '
				INSERT INTO ' + @table_name_to + '
				SELECT * FROM ' + @table_name_from + ' 
					WHERE ' + @where_field_from + ' IN (''' + REPLACE(@as_of_dates, ',', ''', ''') + ''')
	
				DELETE FROM ' + @table_name_from + '
					WHERE ' + @where_field_from + ' IN (''' + REPLACE(@as_of_dates, ',', ''', ''') + ''')
	         '
	         exec(@sql)
	END
	
	IF @batch_process_id IS NOT NULL
	   AND @batch_report_param IS NOT NULL
	BEGIN
	    DECLARE @user_login_id         VARCHAR(100),
	            @end_time_sec          INT,
	            @Conv_time_min_sec     VARCHAR(100),
	            @desc                  VARCHAR(500),
	            @begin_time            DATETIME,
	            @job_name              VARCHAR(MAX)
	    
	    SET @user_login_id = dbo.FNADBUser()
	    SET @job_name = 'archive_data_batch_' + @batch_process_id
	    SET @end_time_sec = DATEDIFF(ss, @begin_time, GETDATE())
	    SET @Conv_time_min_sec = CAST(CAST(@end_time_sec / 60 AS INT) AS VARCHAR) + ' Mins ' + CAST(
	            @end_time_sec - CAST(@end_time_sec / 60 AS INT) * 60 AS VARCHAR
	        ) + ' Secs'
	    
	    SET @desc = 'The Data Archived Successfully.'
	    
	    EXEC spa_message_board 'u',
	         @user_login_id,
	         NULL,
	         'Archive Data',
	         @desc,
	         '',
	         '',
	         's',
	         @job_name,
	         NULL,
	         @batch_process_id,
	         NULL,
	         NULL,
	         '',
	         'y',
	         '',
	         @batch_report_param,
	         NULL,
	         NULL,
	         NULL,
	         ''
	    RETURN
	END
END