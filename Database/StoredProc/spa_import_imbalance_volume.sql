IF OBJECT_ID(N'[dbo].[spa_import_imbalance_volume]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_import_imbalance_volume]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-01-17
-- Description: Importing imbalance volume to staging table source_price_curve

-- Params:
-- @temp_table_name VARCHAR(100), -temporary table name
--	@table_id VARCHAR(100), - table id
--	@job_name VARCHAR(100), - job name
--	@process_id VARCHAR(100), - process id
--	@user_login_id VARCHAR(50) - user login id
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_import_imbalance_volume]
    @temp_table_name		VARCHAR(100),
	@table_id				VARCHAR(100),
	@job_name				VARCHAR(100),
	@process_id				VARCHAR(100),
	@user_login_id			VARCHAR(50)
AS

DECLARE @price_curve_table	VARCHAR(500)
DECLARE @sql_stmt VARCHAR(5000)

SET @process_id = dbo.FNAGetNewID() 
	
IF @user_login_id IS NULL
    SET @user_login_id = dbo.FNADBUser()

SET @job_name = 'importdata_source_price_curve' + '_' + @process_id
SET @price_curve_table = dbo.FNAProcessTableName('source_price_curve', @user_login_id, @process_id)

EXEC spa_print @price_curve_table

BEGIN TRY
	SET @sql_stmt = '
		SELECT tmp.source_curve_def_id [source_curve_def_id],
			   ''2'' [source_system_id] ,
				   cast(dbo.FNAGetSQLStandardDate([dbo].[FNAClientToSqlDate](tmp.as_of_date)) AS VARCHAR(10)) [as_of_date],
			   ''77'' [Assessment_curve_type_value_id],
			   ''4500'' [curve_source_value_id],
				   cast(dbo.FNAGetSQLStandardDate([dbo].[FNAClientToSqlDate](tmp.as_of_date)) AS VARCHAR(10)) [maturity_date],
			   dbo.FNAConvertIntegerTo15minTime(CAST(tmp.hour AS INT)) [maturity_hour],
			   0 [bid_value],
			   0 [ask_value],
			   tmp.volume  [curve_value],
			   CASE 
					WHEN CONVERT(VARCHAR(10), tmp.as_of_date, 103) = CONVERT(VARCHAR(10), md.[date], 103) 
						 AND dbo.FNAConvertIntegerTo15minTime(CAST(tmp.hour AS INT)) IN (''24:00'', ''24:15'', ''24:30'', ''24:45'') THEN 
						 ''1''
					ELSE ''0''
			   END [is_dst],
			   4008 [table_code] 
		INTO ' + @price_curve_table + '             
		FROM ' + @temp_table_name + ' tmp
			   LEFT JOIN mv90_DST md
					ON  CONVERT(VARCHAR(10), tmp.as_of_date, 103) = CONVERT(VARCHAR(10), md.[date], 103)
					AND md.insert_delete = ''i''' 				  

	EXEC(@sql_stmt)
	EXEC spa_print @sql_stmt				  		
END TRY
BEGIN CATCH
	DECLARE @error_msg  VARCHAR(1000)
	DECLARE @desc		VARCHAR(8000)
	DECLARE @error_code VARCHAR(5)
	DECLARE @url_desc	VARCHAR(8000)
	
	SET @error_msg = 'Error: ' + ERROR_MESSAGE()
	SET @error_code = 'e'
	EXEC spa_print @error_msg
	
	INSERT INTO source_system_data_import_status
	  (
		process_id,
		code,
		MODULE,
		[source],
		[TYPE],
		[description],
		recommendation
	  )
	  EXEC (
			 'SELECT DISTINCT ' 
			 + '''' + @process_id + '''' + ',' 
			 + '''Error'''  + ',' 
			 + '''source_price_curve''' + ',' 
			 + '''source_price_curve''' + ',' 
			 +  '''Error''' + ',' 
			 + '''' + @error_msg + '''' + ',' + 
			 '''Please check if the date format provided matches the Users Date format.''' + 
			 ' FROM ' + @temp_table_name
	  )
	
	SELECT @url_desc = './dev/spa_html.php?__user_name__=' + @user_login_id +
					   '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' 
					   + @user_login_id + ''''
	
	SELECT @desc = '<a target="_blank" href="' + @url_desc + '">' +
				   'Import Process Completed' +
				   CASE 
						WHEN (@error_code = 'e') THEN ' (ERRORS found)'
						ELSE ''
				   END +  ' </a>'
	
	EXEC spa_NotificationUserByRole 2, @process_id, 'Import Data', @desc , @error_code, @job_name, 1
	
	RETURN

END CATCH

SET @sql_stmt = 'UPDATE tmp
				SET tmp.maturity_hour = ''02:00''
				FROM   ' + @price_curve_table + ' tmp
					   INNER JOIN mv90_DST md
							ON  tmp.as_of_date = md.date
							AND md.insert_delete = ''i''
				WHERE tmp.maturity_hour = ''24:00''
				     
				UPDATE tmp
				SET tmp.maturity_hour = ''02:15''
				FROM   ' + @price_curve_table + ' tmp
					   INNER JOIN mv90_DST md
							ON  tmp.as_of_date = md.date
							AND md.insert_delete = ''i''
				WHERE tmp.maturity_hour = ''24:15''

				UPDATE tmp
				SET tmp.maturity_hour = ''02:30''
				FROM   ' + @price_curve_table + ' tmp
					   INNER JOIN mv90_DST md
							ON  tmp.as_of_date = md.date
							AND md.insert_delete = ''i''
				WHERE tmp.maturity_hour = ''24:30''

				UPDATE tmp
				SET tmp.maturity_hour = ''02:45''
				FROM   ' + @price_curve_table + ' tmp
					   INNER JOIN mv90_DST md
							ON  tmp.as_of_date = md.date
							AND md.insert_delete = ''i''
				WHERE tmp.maturity_hour = ''24:45''
				'

EXEC(@sql_stmt)
EXEC spa_print @sql_stmt

                       
--DROP TABLE #import_table_name
--EXEC ('select * from ' + @price_curve_table + ' where as_of_date = ''2011-10-30'' and is_dst = 1')

SET @sql_stmt = 'spa_import_data_job  ''' + @price_curve_table + ''',4008, ''' 
				+ @job_name + ''', ''' + @process_id + ''',''' + @user_login_id + ''''

EXEC spa_print @sql_stmt
EXEC(@sql_stmt)
