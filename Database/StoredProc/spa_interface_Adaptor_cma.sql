/*
* Update  CMA Curve Data Staging Table and import to main table
*/
IF OBJECT_ID('spa_interface_Adaptor_cma','p') IS NOT NULL
DROP PROCEDURE [dbo].[spa_interface_Adaptor_cma]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_interface_Adaptor_cma]
	@temp_table_name VARCHAR(256),
	@table_code VARCHAR(32),
	@process_id VARCHAR(128) = NULL,
	@user_login_id VARCHAR(128) = NULL
AS

BEGIN
-- Testing
--DECLARE 
--@temp_table_name varchar(256),
--@table_code VARCHAR(32),
--@process_id VARCHAR(128),
--@user_login_id VARCHAR(128)


--SET @temp_table_name='adiha_process.dbo.source_price_curve_farrms_admin_94E5371D_2551_448C_AC5D_F3BFCB2F8207_4e0a406953f7b'
--SET @table_code=''
--SET @process_id='XXX'
	
	DECLARE @q VARCHAR(MAX)
	DECLARE @update_query VARCHAR(1500)
	DECLARE @job_name VARCHAR(256)
	DECLARE @hour_field VARCHAR(500)
	DECLARE @fifteen_field VARCHAR(500), @curves_with_24dst VARCHAR(500)
	
	IF @user_login_id IS NULL
	SELECT @user_login_id = dbo.FNAdbuser()
	
	SET @curves_with_24dst = '''SPM#ELFW_NLAHR'', ''SPM#ELFW_BEAHR'''
	
	SET @job_name = 'CMA_import_data_' + @process_id
	

	-- handles for curves with 24hrs format DST data
	EXEC('DELETE tt FROM ' + @temp_table_name + ' tt INNER JOIN mv90_dst mv ON CAST(tt.maturity_date as datetime) = mv.[date]
		  AND insert_delete = ''d''  AND CAST(CAST(maturity_hour AS VARCHAR(2)) AS INT) + 1 = mv.[hour] WHERE
		  tt.source_curve_def_id IN(' + @curves_with_24dst + ')' )
		  
	EXEC('INSERT INTO ' + @temp_table_name + ' SELECT  source_curve_def_id, source_system_id, as_of_date,
	 Assessment_curve_type_value_id, curve_source_value_id, maturity_date,
	 maturity_hour, bid_value, ask_value, curve_value, 1 as is_dst, table_code,
	 [file_name], granularity_label, price_value_type
	 FROM ' + @temp_table_name + ' tt INNER JOIN mv90_dst mv ON CAST(tt.maturity_date as datetime) = mv.[date]
		  AND insert_delete = ''i'' AND CAST(CAST(maturity_hour AS VARCHAR(2)) AS INT) + 1 = mv.[hour] WHERE
		  tt.source_curve_def_id IN(' + @curves_with_24dst + ')' )
	
	
	SET @hour_field='CAST(SUBSTRING(granularity_label, 1, Charindex(''UD'', granularity_label, 0) - 1 ) - 1 AS INT)'
	SET @fifteen_field = '((CAST(SUBSTRING(granularity_label, 4, LEN(granularity_label) - 3) AS INT)-1)/4)'
	-- Query to update price type(bid, ask, mid(curve) ) update logic
	SET @q = '
				UPDATE tt
				SET 
				bid_value = (CASE WHEN curve_value IS NOT NULL AND ask_value IS NOT NULL AND bid_value IS NULL THEN
								CAST((CAST(curve_value AS FLOAT) * 2 - CAST(ask_value AS FLOAT )) as VARCHAR(20))	 
								  WHEN curve_value IS NOT NULL AND ask_value IS NULL AND bid_value IS NULL AND [price_value_type] IS NULL THEN 
									 curve_value
								 WHEN curve_value IS NULL AND ask_value IS NOT NULL AND bid_value IS NULL THEN
								 ask_value
									ELSE bid_value END), 
			                    
				ask_value = (CASE WHEN curve_value IS NOT NULL AND ask_value IS NULL AND bid_value IS NOT NULL THEN
								CAST((CAST(curve_value AS FLOAT) * 2 - CAST(bid_value AS FLOAT)) AS VARCHAR(20)) 
								  WHEN curve_value IS NOT NULL AND ask_value IS NULL AND bid_value IS NULL AND [price_value_type] IS NULL THEN 
										curve_value
								  WHEN curve_value IS NULL AND ask_value IS NULL AND bid_value IS NOT NULL THEN
								 bid_value		
									ELSE ask_value END),
									
				curve_value = (CASE WHEN curve_value IS NULL AND ask_value IS NOT NULL AND bid_value IS NOT NULL THEN
									CAST(((CAST(bid_value AS FLOAT ) + CAST(ask_value AS FLOAT))/2) AS VARCHAR(20))
								WHEN curve_value IS NULL AND ask_value IS NOT NULL AND bid_value IS NULL THEN
									ask_value
								WHEN curve_value IS NULL AND ask_value IS NULL AND bid_value IS NOT NULL THEN
									bid_value
								ELSE curve_value END),
			
				--maturity_date =	(CASE WHEN granularity_label LIKE ''%UD%'' THEN 
				--					CONVERT(VARCHAR, DATEADD(day, CAST(SUBSTRING(granularity_label, Charindex(''UD'', granularity_label, 0) + 2, 3) AS INT), maturity_date), 120)
				--				 ELSE maturity_date END),
				
				
				
				maturity_hour = (CASE WHEN source_curve_def_id NOT IN(' + @curves_with_24dst + ') THEN CASE WHEN granularity_label LIKE ''%UD%'' THEN  
									CONVERT(VARCHAR(5), CAST(( ISNULL(NULLIF( CAST(CASE WHEN ' + @hour_field + '>=mv.[Hour]-1 THEN ' + @hour_field + '+1 
											WHEN mv1.[Hour] IS NOT NULL AND ' + @hour_field + '>= mv1.[Hour] THEN ' + @hour_field + ' - 1 ELSE '+@hour_field+' END AS VARCHAR(2)) ,''''), ''00'') 
									 + '':00'') AS TIME) , 108)
						         WHEN granularity_label LIKE ''PTU%'' THEN  
						         	CONVERT(varchar(5), CAST((
						         	CAST(CASE WHEN ' + @fifteen_field + '>=mv.[Hour]-1 THEN ' + @fifteen_field + '+1 
											WHEN mv1.[Hour] IS NOT NULL AND ' + @fifteen_field + '>= mv1.[Hour] THEN ' + @fifteen_field + ' - 1 ELSE ' + @fifteen_field + ' END AS VARCHAR(2))
									+ '':'' +
									CAST(((CAST(SUBSTRING(granularity_label, 4, LEN(granularity_label) - 3) AS INT)-1)%4 * 15) AS VARCHAR(2)))
									 AS time), 108)
					             ELSE maturity_hour END ELSE maturity_hour END),
						 
				is_dst = CASE WHEN source_curve_def_id NOT IN(' + @curves_with_24dst + ') THEN CASE WHEN granularity_label LIKE ''%UD%'' THEN  
						   CASE WHEN mv1.[Hour] IS NOT NULL AND ' + @hour_field + '= mv1.[Hour] THEN 1 ELSE 0 END
						   WHEN granularity_label LIKE ''PTU%'' THEN 
							CASE WHEN mv1.[Hour] IS NOT NULL AND ' + @fifteen_field + '= mv1.[Hour] THEN 1 ELSE 0 END
						   ELSE 0
						 END ELSE is_dst END
				FROM ' + @temp_table_name + ' tt
					LEFT JOIN mv90_DST mv ON mv.date=tt.maturity_date
						AND mv.insert_delete=''d''
					LEFT JOIN mv90_DST mv1 ON mv1.date=tt.maturity_date
						AND mv1.insert_delete=''i'' '

	exec spa_print @q
	EXEC(@q)

	SET @update_query = 'UPDATE cst SET cst.source_curve_def_id = cst.source_curve_def_id + 
						 CASE WHEN granularity_label LIKE ''D%'' THEN '' - D'' -- daily
						 	  WHEN granularity_label LIKE ''M%'' THEN '' - M'' -- monthly
						 	  WHEN granularity_label LIKE ''Q%'' THEN '' - Q'' -- quaterly
						 	  WHEN granularity_label LIKE ''Y%'' THEN '' - Y'' -- yearly
						 	  WHEN granularity_label LIKE ''%UD%'' THEN '' - H'' -- hourly
  						 	  WHEN granularity_label LIKE ''PTU%'' AND [price_value_type] IS NULL THEN '' - F'' -- 15 mins
  						 	  WHEN granularity_label LIKE ''PTU%'' AND [price_value_type] IS NOT NULL THEN '' - '' + [price_value_type] -- 15 mins

						 ELSE
							  ''''	  
						 END
	                     FROM ' + @temp_table_name + ' cst
						 --INNER JOIN source_price_curve_def spcd ON spcd.curve_id LIKE cst.source_curve_def_id + ''%'' '


	exec spa_print @update_query
	EXEC(@update_query)

	-- Import to main 
	EXEC spa_import_data_job @temp_table_name, @table_code, @job_name, @process_id, @user_login_id, 'y',1, NULL, NULL, 'CMA Price Curve' 
							
	
	
END