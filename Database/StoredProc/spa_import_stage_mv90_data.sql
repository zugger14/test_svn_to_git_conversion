
/****** Object:  StoredProcedure [dbo].[spa_import_stage_mv90_data]    Script Date: 05/02/2012 19:04:22 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_import_stage_mv90_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_import_stage_mv90_data]
GO
/****** Object:  StoredProcedure [dbo].[spa_import_stage_mv90_data]    Script Date: 05/04/2012 14:11:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_import_stage_mv90_data]
	@flag CHAR(1),	-- c: create tables, p: process
	@process_id varchar(100),  
	@user_login_id varchar(50),
	@error_code INT = 0
AS 
/*
DECLARE @flag CHAR(1)	-- c: create tables, p: process
DECLARE @process_id varchar(100)  
DECLARE @user_login_id varchar(50)
DECLARE @error_code INT = 0
DROP TABLE #inserted_meter_id
DROP TABLE #month_data_count
DROP TABLE #hour_data_count
DROP TABLE #min15_data_count
DROP TABLE #dver_gas_data
DROP TABLE #error_code
DROP TABLE #dver_final_meter
DROP TABLE #temp_dup_data
DROP TABLE #inserted_sub_meters
DROP TABLE #total_meter
DROP TABLE #all_mv90_stage_test1

SET @flag ='p'
SET @process_id= 'F452F2D8_04C9_485D_8517_AF0D3EE62307_4ffd7dbb03e29' 
SET @user_login_id ='farrms_admin'

 --*/


--BEGIN TRAN


DECLARE @sql VARCHAR(8000)

DECLARE @stage_mv90_data VARCHAR(500), 
		@stage_mv90_data_hour VARCHAR(500), 
		@stage_mv90_data_mins VARCHAR(500)
DECLARE @stage_ebase_mv90_data_header VARCHAR(128)		
-- header information of all source file is inserted in same stage table.
SELECT @stage_ebase_mv90_data_header = dbo.FNAProcessTableName('stage_ebase_mv90_data_header', @user_login_id, @process_id)

SELECT @stage_mv90_data = dbo.FNAProcessTableName('mv90_data', @user_login_id, @process_id)
SELECT @stage_mv90_data_hour = dbo.FNAProcessTableName('mv90_data_hour', @user_login_id, @process_id)
SELECT @stage_mv90_data_mins = dbo.FNAProcessTableName('mv90_data_mins', @user_login_id, @process_id)

IF @flag = 'c'
BEGIN
	SET @sql = 'IF OBJECT_ID(''' + @stage_mv90_data + ''') IS NOT NULL
		DROP TABLE ' + @stage_mv90_data 
	--PRINT (@sql)
	EXEC(@sql)
	
	SET @sql = 'IF OBJECT_ID(''' + @stage_mv90_data_hour + ''') IS NOT NULL
		DROP TABLE ' + @stage_mv90_data_hour 
	EXEC(@sql)	

	SET @sql = 'IF OBJECT_ID(''' + @stage_mv90_data_mins + ''') IS NOT NULL
		DROP TABLE ' + @stage_mv90_data_mins 
	EXEC(@sql)

	SET @sql = 'IF OBJECT_ID(''' + @stage_ebase_mv90_data_header + ''') IS NOT NULL
		DROP TABLE ' + @stage_ebase_mv90_data_header 
	EXEC(@sql)		
		
	SET @sql = 'CREATE TABLE ' + @stage_mv90_data + ' (
		[mv90_data_id] [INT] IDENTITY(1,1) NOT NULL,
		[meter_id] [varchar](100) NULL,
		[channel] [varchar](10) NULL,
		[date] [varchar](10) NULL,
		[hour] [varchar](5) NULL,
		[value] [varchar](100) NULL,
		[h_filename] [varchar](100) NULL, 
		[h_error] [varchar](1000) NULL, 
		[d_filename] [varchar](100) NULL, 
		[d_error] [varchar](1000) NULL,		
	)'
	EXEC(@sql)
	
	SET @sql = 'CREATE TABLE ' + @stage_mv90_data_hour + ' (
		[mv90_data_id] [INT] IDENTITY(1,1) NOT NULL,
		[meter_id] [varchar](100) NULL,
		[channel] [varchar](10) NULL,
		[date] [varchar](10) NULL,
		[hour] [varchar](5) NULL,
		[value] [varchar](100) NULL,
		[h_filename] [varchar](100) NULL, 
		[h_error] [varchar](1000) NULL, 
		[d_filename] [varchar](100) NULL, 
		[d_error] [varchar](1000) NULL,
	)'
	EXEC(@sql)
	
	SET @sql = 'CREATE TABLE ' + @stage_mv90_data_mins + ' (
		[mv90_data_id] [INT] IDENTITY(1,1) NOT NULL,
		[meter_id] [varchar](100) NULL,
		[channel] [varchar](10) NULL,
		[date] [varchar](10) NULL,
		[hour] [varchar](5) NULL,
		[value] [varchar](100) NULL,
		[h_filename] [varchar](100) NULL, 
		[h_error] [varchar](1000) NULL, 
		[d_filename] [varchar](100) NULL, 
		[d_error] [varchar](1000) NULL,
	)'
	EXEC(@sql)
	
	SET @sql = 'CREATE TABLE ' + @stage_ebase_mv90_data_header + ' (

		[meter_id] [VARCHAR](100) NULL,
		[granularity] [VARCHAR](25) NULL,
		[uom] [VARCHAR](25) NULL,
		[counterparty] [VARCHAR](25) NULL,
		[commodity] [VARCHAR](25) NULL,
		[filetype] [VARCHAR](25) NULL,
		[timestamp] [VARCHAR](25) NULL,
		[dataversion] [VARCHAR](25) NULL,
		[h_filename] [VARCHAR] (100) NULL,
		[h_error] [VARCHAR] (500) NULL,
		[error_code] [VARCHAR] (10) NULL,
		[file_category] TINYINT NULL,
		[country] VARCHAR(50) NULL
	)'
	EXEC(@sql)
		
END

IF @flag = 'p'
BEGIN
	
	DECLARE @type CHAR(2)
	DECLARE @url_desc VARCHAR(500)  
	DECLARE @url VARCHAR(250)
	DECLARE @desc VARCHAR(250) = ''
	DECLARE @caught BIT = 0
	DECLARE @elapsed_sec INT, @elapse_sec_text VARCHAR(150)
	DECLARE @all_gran VARCHAR(700), @each_gran VARCHAR(255)
	
	SET @all_gran = @stage_mv90_data + ',' + @stage_mv90_data_hour + ',' + @stage_mv90_data_mins

	IF @error_code = 2  -- empty folder error
	BEGIN
		SET @type = 'e'
		EXEC spa_source_system_data_import_status_detail 'i', @process_id, '', 'Data Error', 'Data Folder Empty', 'Data Folder Empty', @user_login_id, 1 , 'Import Data'
	END	
	ELSE 
	BEGIN
		
		BEGIN TRY
		

			CREATE TABLE #temp_dup_data(mv90_data_id INT)
				
			--delete from detail		
			-- delete dublicate datas if found for all granularity,
			-- occurs when two files have same set of data for same meter but different filename
			DECLARE c CURSOR FOR 
				SELECT Item FROM dbo.SplitCommaSeperatedValues(@all_gran)
			OPEN c 
			FETCH NEXT FROM c INTO @each_gran 

			WHILE @@FETCH_STATUS = 0
			BEGIN
				--BEGIN TRAN
				--SELECT @each_gran e

				--delete error data
				EXEC('DELETE s FROM ' + @each_gran + ' s 
					INNER JOIN ' + @stage_ebase_mv90_data_header + ' h ON h.meter_id = s.meter_id AND h.h_filename = s.h_filename
				  WHERE h.error_Code <> ''0''  ')				

				-- delete error rows in detail level/ handles ignoring NaN issue
				--EXEC('DELETE s FROM ' + @each_gran + ' s WHERE s.d_error = ''NaN''  ')
				EXEC('DELETE s FROM ' + @each_gran + ' s WHERE s.d_error <> ''''  ')
				 
				-- ignore data as defined in allocation delay table for Power data
				EXEC('DELETE m FROM ' + @each_gran + ' m
			  INNER JOIN ' + @stage_ebase_mv90_data_header + ' h ON h.meter_id = m.meter_id
			  LEFT JOIN power_allocation_map_ebase p ON p.source_commodity_id = -2 AND p.country = h.country
		      WHERE h.commodity = ''Power'' AND ( CAST(m.date AS DATETIME) BETWEEN 
		      DATEADD(d, (-1) * p.allocation_delay, CONVERT(DATETIME, CAST(h.timestamp AS VARCHAR(8)), 11) ) AND CONVERT(DATETIME, CAST(h.timestamp AS VARCHAR(8)), 11) )
		       AND h.file_category = ''1'' ' )

				--delete from detail
				EXEC('INSERT INTO #temp_dup_data SELECT MIN(mv90_data_id) mv90_data_id
						FROM ' + @each_gran + ' GROUP BY meter_id, channel, date,hour HAVING COUNT(*)>1')
				
				
				EXEC('DELETE a FROM ' + @each_gran + ' a
					INNER JOIN #temp_dup_data tdd ON tdd.mv90_data_id = a.mv90_data_id
					LEFT JOIN mv90_dst dst ON a.[date]= CONVERT(VARCHAR(10),dst.[date],120) AND dst.insert_delete = ''i''
						AND dst.[hour]-1=CAST(LEFT(a.[hour],2) AS INT)
					WHERE
						dst.[hour] IS NULL	
					')

				TRUNCATE TABLE #temp_dup_data
				--COMMIT TRAN
				FETCH NEXT FROM c INTO @each_gran 
			END

			CLOSE c
			DEALLOCATE c 



		BEGIN TRAN

		-- insert recorderid if Not found
		CREATE TABLE #inserted_meter_id(recorderid VARCHAR(100) COLLATE DATABASE_DEFAULT)
		EXEC('INSERT INTO meter_id(recorderid, description, counterparty_id, commodity_id, country_id, granularity)
			  OUTPUT INSERTED.recorderid INTO #inserted_meter_id 	
			  SELECT DISTINCT sm.meter_id, sm.meter_id, NULL, sc.source_commodity_id, sdv.value_id, sm.granularity  FROM ' + @stage_ebase_mv90_data_header + ' sm 
			  LEFT JOIN meter_id mi ON mi.recorderid = sm.meter_id
			  LEFT JOIN source_commodity sc ON sc.commodity_id = sm.commodity AND sc.source_system_id = 2
			  LEFT JOIN static_data_value sdv ON sdv.code = sm.country	
			  WHERE mi.recorderid IS NULL AND sm.error_code =''0'' AND sdv.type_id = ''14000'' ')

		-- update granularity only if it's null 
		EXEC('UPDATE mi SET mi.granularity = sm.granularity FROM ' + @stage_ebase_mv90_data_header + ' sm
			  INNER JOIN meter_id mi ON sm.meter_id = mi.recorderid
			  LEFT JOIN source_counterparty scp ON scp.counterparty_id = sm.counterparty AND scp.source_system_id = 2 
			  LEFT JOIN source_commodity sc ON sc.commodity_id = sm.commodity AND sc.source_system_id = 2
			  LEFT JOIN static_data_value sdv ON sdv.code = sm.country	
			  WHERE mi.recorderid IS NOT NULL AND mi.granularity IS NULL AND sm.error_code =''0'' AND sdv.type_id = ''14000'' ')

		
		CREATE TABLE #month_data_count(row_count INT)
		CREATE TABLE #hour_data_count(row_count INT)
		CREATE TABLE #min15_data_count(row_count INT)

		EXEC('INSERT INTO #month_data_count SELECT COUNT(*) FROM ' + @stage_mv90_data)
		EXEC('INSERT INTO #hour_data_count SELECT COUNT(*) FROM ' + @stage_mv90_data_hour)
		EXEC('INSERT INTO #min15_data_count SELECT COUNT(*) FROM ' + @stage_mv90_data_mins)

		IF EXISTS(SELECT 1 FROM #inserted_meter_id)
		BEGIN
			EXEC('INSERT INTO recorder_properties( meter_id, channel, mult_factor, uom_id )
			SELECT DISTINCT mi.meter_id, 1, 1, su.source_uom_id FROM #inserted_meter_id i 
			INNER JOIN meter_id mi ON mi.recorderid = i.recorderid
			INNER JOIN ' + @stage_ebase_mv90_data_header + ' h ON h.meter_id = i.recorderid
			INNER JOIN source_uom su ON su.uom_id = h.uom
			WHERE h.error_code = ''0''
			')
			
			INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
			SELECT @process_id, 'Success', 'Import Data', '', 'meter_id', 'A new meter_id has been inserted. meter_id: ' + recorderid
			FROM #inserted_meter_id
		END
		

		-- Exception case for power commodity with NL country where Delivery/redelivery logic requires value to be mulitplied by -1
		EXEC('UPDATE m SET m.value = m.value * (-1) FROM ' + @stage_mv90_data + ' m
			  INNER JOIN meter_id mi ON mi.recorderid = m.meter_id
			  INNER JOIN ' + @stage_ebase_mv90_data_header + ' h ON h.meter_id = mi.recorderid
		      WHERE h.commodity = ''Power'' AND h.country = ''NL'' 
		      -- AND mi.sub_meter_id IS NOT NULL' )
		EXEC('UPDATE m SET m.value = m.value * (-1) FROM ' + @stage_mv90_data_hour + ' m
			  INNER JOIN meter_id mi ON mi.recorderid = m.meter_id
			  INNER JOIN ' + @stage_ebase_mv90_data_header + ' h ON h.meter_id = mi.recorderid
		      WHERE h.commodity = ''Power'' AND h.country = ''NL'' 
		      ' )
		EXEC('UPDATE m SET m.value = CAST(m.value AS NUMERIC(38,20)) * (-1) FROM ' + @stage_mv90_data_mins + ' m
			  INNER JOIN meter_id mi ON mi.recorderid = m.meter_id
			  INNER JOIN ' + @stage_ebase_mv90_data_header + ' h ON h.meter_id = mi.recorderid
		      WHERE h.commodity = ''Power'' AND h.country = ''NL'' 
		      ' )


		--Delivery/redelivery logic

		-- logic to create seperate redelivery meter with _R suffix in meterID so as to import redelivery data into it.

		CREATE TABLE #inserted_sub_meters(recorderid VARCHAR(100) COLLATE DATABASE_DEFAULT)
	
		CREATE TABLE #all_mv90_stage_test1(meter_id VARCHAR(100) COLLATE DATABASE_DEFAULT, h_filename varchar(100) COLLATE DATABASE_DEFAULT, value varchar (100) COLLATE DATABASE_DEFAULT)

		EXEC('INSERT INTO #all_mv90_stage_test1(meter_id,h_filename,[value])
				SELECT DISTINCT meter_id, h_filename, value FROM ' + @stage_mv90_data + '
				UNION ALL
				SELECT DISTINCT meter_id, h_filename, value FROM ' + @stage_mv90_data_hour + '
				UNION ALL
				SELECT DISTINCT meter_id, h_filename, value FROM ' + @stage_mv90_data_mins )

		EXEC('INSERT INTO meter_id(recorderid, description, counterparty_id, commodity_id, country_id,granularity)
			OUTPUT INSERTED.recorderid INTO #inserted_sub_meters
			SELECT DISTINCT sm.meter_id + ''_R'', sm.meter_id + ''_R'', NULL, sc.source_commodity_id, sdv.value_id,sm.granularity
			FROM ' + @stage_ebase_mv90_data_header + ' sm
			INNER JOIN meter_id mi ON mi.recorderid = sm.meter_id
			LEFT JOIN meter_id mi2 ON mi2.recorderid = sm.meter_id + ''_R''
			INNER JOIN #all_mv90_stage_test1 s ON s.meter_id = sm.meter_id AND s.h_filename = sm.h_filename
			--LEFT JOIN source_counterparty scp ON scp.counterparty_id = sm.counterparty AND scp.source_system_id = 2
			LEFT JOIN source_commodity sc ON sc.commodity_id = sm.commodity AND sc.source_system_id = 2
			LEFT JOIN static_data_value sdv ON sdv.code = sm.country    
			WHERE sm.error_code =''0'' AND sdv.type_id = ''14000'' AND mi2.recorderid IS NULL --sm.meter_id + ''_R'' IS NULL
			AND CAST(s.value AS NUMERIC(38,20)) < 0
			')	
     
		EXEC('UPDATE mi2 SET mi2.sub_meter_id = mi.meter_id FROM meter_id mi
           INNER JOIN #inserted_sub_meters i ON i.recorderid = mi.recorderid
           INNER JOIN meter_id mi2 ON mi2.recorderid = LEFT(i.recorderid, LEN(i.recorderid) - 2) -- dbo.FNAGetSplitPart(i.recorderid ,''_'',1)
           ')
           
        IF EXISTS(SELECT 1 FROM #inserted_sub_meters)
		BEGIN
			EXEC('INSERT INTO recorder_properties( meter_id, channel, mult_factor, uom_id )
			SELECT DISTINCT mi.meter_id, 1, 1, su.source_uom_id FROM #inserted_sub_meters i 
			INNER JOIN meter_id mi ON mi.recorderid = i.recorderid
			INNER JOIN ' + @stage_ebase_mv90_data_header + ' h ON h.meter_id = LEFT(i.recorderid, LEN(i.recorderid) - 2)  -- dbo.FNAGetSplitPart(i.recorderid ,''_'',1)
			INNER JOIN source_uom su ON su.uom_id = h.uom
			WHERE h.error_code = ''0''
			')
			
			INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
			SELECT @process_id, 'Success', 'Import Data', '', 'meter_id', '(For Re-Delivery)A new meter_id has been inserted. meter_id: ' + recorderid
			FROM #inserted_sub_meters
		END

	
			-- logic to Handle counterparty switch case
			EXEC('INSERT INTO meter_counterparty(meter_id, counterparty_id, term_start, term_end)
			
			   SELECT distinct sm.meter_id, scp.source_counterparty_id, CAST(s.date AS DATETIME), NULL
			  FROM( 
			  	SELECT DISTINCT mi.meter_id meter_id, h1.meter_id meter_name, h1.counterparty, h1.error_code, h1.h_filename FROM ' + @stage_ebase_mv90_data_header + ' h1
			  	INNER JOIN meter_id mi ON mi.recorderid = h1.meter_id
			  	 WHERE h1.error_code = ''0''
			  )sm 	 

   			  INNER JOIN (
				SELECT  meter_id, h_filename, MIN(date) date FROM ' + @stage_mv90_data + ' GROUP BY meter_id, h_filename
				UNION ALL
				SELECT  meter_id, h_filename, MIN(date) date FROM ' + @stage_mv90_data_hour + ' GROUP BY meter_id, h_filename
				UNION ALL
				SELECT meter_id, h_filename, MIN(date) date FROM ' + @stage_mv90_data_mins + ' GROUP BY meter_id, h_filename
		      ) s ON s.meter_id = sm.meter_name AND s.h_filename = sm.h_filename

			  INNER JOIN source_counterparty scp ON scp.counterparty_id = sm.counterparty AND scp.source_system_id = 2 
	  		  OUTER APPLY(			  
				SELECT meter_id, counterparty_id,term_start,term_end FROM meter_counterparty
				WHERE meter_id = sm.meter_id AND counterparty_id = scp.source_counterparty_id
				AND (  CAST(s.date AS DATETIME) BETWEEN ISNULL(term_start,''1900-01-01'') AND ISNULL(term_end,''9999-01-01'') )
			   )	 mc		  	
			  	  
			  WHERE mc.meter_id IS NULL 

			  ')	
			  
			  -- meter counterparty insertion for redelevery meter 
			exec('INSERT INTO meter_counterparty(meter_id, counterparty_id, term_start, term_end)
			
			   SELECT DISTINCT sm.meter_id, scp.source_counterparty_id, CAST(s.date AS DATETIME), NULL
			  FROM( 
			  	SELECT DISTINCT mi.meter_id meter_id, h1.meter_id + ''_R'' meter_name, h1.counterparty, h1.error_code, h1.h_filename FROM ' + @stage_ebase_mv90_data_header + ' h1
			  	INNER JOIN meter_id mi ON mi.recorderid = h1.meter_id + ''_R''
			  	 WHERE h1.error_code = ''0''
			  )sm 	 

   			  INNER JOIN (
				SELECT  meter_id + ''_R'' meter_id, h_filename, value, CAST(CONVERT(VARCHAR(7),MIN(date),120)+''-01'' AS DATETIME) date FROM ' + @stage_mv90_data + ' WHERE CAST(value AS NUMERIC(38,20)) < 0 GROUP BY meter_id, h_filename, value
				UNION ALL
				SELECT  meter_id + ''_R'' meter_id, h_filename, value, CAST(CONVERT(VARCHAR(7),MIN(date),120)+''-01'' AS DATETIME)  date FROM ' + @stage_mv90_data_hour + ' WHERE CAST(value AS NUMERIC(38,20)) < 0 GROUP BY meter_id, h_filename, value
				UNION ALL
				SELECT meter_id + ''_R'' meter_id, h_filename, value,  CAST(CONVERT(VARCHAR(7),MIN(date),120)+''-01'' AS DATETIME)  date FROM ' + @stage_mv90_data_mins + ' WHERE CAST(value AS NUMERIC(38,20)) < 0 GROUP BY meter_id, h_filename, value
		      ) s ON s.meter_id = sm.meter_name AND s.h_filename = sm.h_filename

			  INNER JOIN source_counterparty scp ON scp.counterparty_id = sm.counterparty AND scp.source_system_id = 2 
		  
	  		  OUTER APPLY(			  
				SELECT meter_id, counterparty_id,term_start,term_end FROM meter_counterparty
				WHERE meter_id = sm.meter_id AND counterparty_id = scp.source_counterparty_id
				AND (  CAST(s.date AS DATETIME) BETWEEN ISNULL(term_start,''1900-01-01'') AND ISNULL(term_end,''9999-01-01'') )
			   ) mc		  	
			  	  
			  WHERE mc.meter_id IS NULL

			  ')
						
			SELECT ROW_NUMBER() OVER (ORDER BY meter_id,term_start) row_id, meter_id, counterparty_id, term_start, term_end INTO #meter_cp FROM meter_counterparty

			UPDATE mc SET mc.term_end = (mc2.term_start - 1) FROM #meter_cp mc
			INNER JOIN #meter_cp mc2 ON mc2.meter_id = mc.meter_id AND mc2.row_id = mc.row_id + 1

			UPDATE mc SET mc.term_end = CONVERT(CHAR(11), m.term_end, 126) + '23:59:59.997' FROM meter_counterparty mc
			INNER JOIN #meter_cp m ON m.meter_id = mc.meter_id AND m.counterparty_id = mc.counterparty_id AND m.term_start = mc.term_start			
	
		
		--save new rows value as 0 for volume <0  and update existing meter_id with sub_meter_id value
		--monthly data		
		EXEC('INSERT INTO ' + @stage_mv90_data + ' (meter_id, channel, date, hour, value, h_filename, h_error, d_filename, d_error)
			  SELECT s.meter_id, s.channel, s.date, s.hour, ''0'', s.h_filename, s.h_error, s.d_filename, s.d_error FROM ' + @stage_mv90_data + ' s
			  INNER JOIN meter_id mi ON mi.recorderid = s.meter_id
		      WHERE CAST(s.value AS NUMERIC(38,20)) < 0 AND mi.sub_meter_id IS NOT NULL')
		EXEC('INSERT INTO ' + @stage_mv90_data + ' (meter_id, channel, date, hour, value, h_filename, h_error, d_filename, d_error)
			  SELECT mi_sub.recorderid, s.channel, s.date, s.hour, ''0'', s.h_filename, s.h_error, s.d_filename, s.d_error FROM ' + @stage_mv90_data + ' s
			  INNER JOIN meter_id mi ON mi.recorderid = s.meter_id
			  INNER JOIN meter_id mi_sub ON mi_sub.meter_id = mi.sub_meter_id
		      WHERE CAST(s.value AS NUMERIC(38,20)) >= 0 ')

		EXEC('UPDATE t SET t.meter_id = mi_sub.recorderid FROM ' + @stage_mv90_data + ' t
				INNER JOIN meter_id mi ON mi.recorderid = t.meter_id
				INNER JOIN meter_id mi_sub ON mi_sub.meter_id = mi.sub_meter_id
				WHERE CAST(t.value AS NUMERIC(38,20)) < 0 ')
		      
		--hourly data		
		EXEC('INSERT INTO ' + @stage_mv90_data_hour + ' (meter_id, channel, date, hour, value, h_filename, h_error, d_filename, d_error)
			  SELECT s.meter_id, s.channel, s.date, s.hour, ''0'', s.h_filename, s.h_error, s.d_filename, s.d_error FROM ' + @stage_mv90_data_hour + ' s
			  INNER JOIN meter_id mi ON mi.recorderid = s.meter_id
		      WHERE CAST(s.value AS NUMERIC(38,20)) < 0 AND mi.sub_meter_id IS NOT NULL')
		EXEC('INSERT INTO ' + @stage_mv90_data_hour + ' (meter_id, channel, date, hour, value, h_filename, h_error, d_filename, d_error)
			  SELECT mi_sub.recorderid, s.channel, s.date, s.hour, ''0'', s.h_filename, s.h_error, s.d_filename, s.d_error FROM ' + @stage_mv90_data_hour + ' s
			  INNER JOIN meter_id mi ON mi.recorderid = s.meter_id
			  INNER JOIN meter_id mi_sub ON mi_sub.meter_id = mi.sub_meter_id
		      WHERE CAST(s.value AS NUMERIC(38,20)) >= 0 ')
		      
		EXEC('UPDATE t SET t.meter_id = mi_sub.recorderid FROM ' + @stage_mv90_data_hour + ' t
				INNER JOIN meter_id mi ON mi.recorderid = t.meter_id
				INNER JOIN meter_id mi_sub ON mi_sub.meter_id = mi.sub_meter_id
				WHERE CAST(t.value AS NUMERIC(38,20)) < 0 ')

		--15mins data		
		EXEC('INSERT INTO ' + @stage_mv90_data_mins + ' (meter_id, channel, date, hour, value, h_filename, h_error, d_filename, d_error)
			  SELECT s.meter_id, s.channel, s.date, s.hour, ''0'', s.h_filename, s.h_error, s.d_filename, s.d_error FROM ' + @stage_mv90_data_mins + ' s
			  INNER JOIN meter_id mi ON mi.recorderid = s.meter_id
		      WHERE CAST(s.value AS NUMERIC(38,20)) < 0 AND mi.sub_meter_id IS NOT NULL')
		EXEC('INSERT INTO ' + @stage_mv90_data_mins + ' (meter_id, channel, date, hour, value, h_filename, h_error, d_filename, d_error)
			  SELECT mi_sub.recorderid, s.channel, s.date, s.hour, ''0'', s.h_filename, s.h_error, s.d_filename, s.d_error FROM ' + @stage_mv90_data_mins + ' s
			  INNER JOIN meter_id mi ON mi.recorderid = s.meter_id
			  INNER JOIN meter_id mi_sub ON mi_sub.meter_id = mi.sub_meter_id
		      WHERE CAST(s.value AS NUMERIC(38,20)) >= 0 ')

		EXEC('UPDATE t SET t.meter_id = mi_sub.recorderid FROM ' + @stage_mv90_data_mins + ' t
				INNER JOIN meter_id mi ON mi.recorderid = t.meter_id
				INNER JOIN meter_id mi_sub ON mi_sub.meter_id = mi.sub_meter_id
				WHERE CAST(t.value AS NUMERIC(38,20)) < 0 ')


			
		-- DST handle for october data (hourly data)
		EXEC('UPDATE t1 SET t1.hour = CASE  
			WHEN t1.hour IN(''2:00'', ''02:00'') THEN ''24:00''
			ELSE t1.hour
		END
		FROM ' + @stage_mv90_data_hour + ' t1 
		INNER JOIN (	--, t.hour (respective hr value)
			SELECT MAX(t.mv90_data_id) mv90_data_id  FROM ' + @stage_mv90_data_hour + ' t
			INNER JOIN mv90_dst m ON m.date = CONVERT(DATETIME, t.date, 120)
			WHERE m.insert_delete = ''i'' GROUP BY t.meter_id, t.date, t.hour
			HAVING COUNT(t.mv90_data_id) > 1
		) t2
		ON t1.mv90_data_id = t2.mv90_data_id')
		
		-- DST handle for october data (15mins data)
		EXEC('UPDATE t1 SET t1.hour = CASE 
		WHEN t1.hour IN(''2:00'', ''02:00'') THEN ''24:00''
		WHEN t1.hour IN(''2:15'', ''02:15'') THEN ''24:15''
		WHEN t1.hour IN(''2:30'', ''02:30'') THEN ''24:30''
		WHEN t1.hour IN(''2:45'', ''02:45'') THEN ''24:45''
		ELSE t1.hour
		END
		FROM ' + @stage_mv90_data_mins + ' t1 
		INNER JOIN (	--, t.hour (respective hr value)
			SELECT MAX(t.mv90_data_id) mv90_data_id  FROM ' + @stage_mv90_data_mins + ' t
			INNER JOIN mv90_dst m ON m.date = CONVERT(DATETIME, t.date, 120)
			WHERE m.insert_delete = ''i'' GROUP BY t.meter_id, t.date, t.hour
			HAVING COUNT(t.mv90_data_id) > 1
		) t2
		ON t1.mv90_data_id = t2.mv90_data_id ')


		CREATE TABLE #dver_final_meter(meter_id INT, prod_date VARCHAR(30) COLLATE DATABASE_DEFAULT)
		--logic to clear data for 'Final' dataversion in batch process

		
		EXEC('INSERT INTO #dver_final_meter(meter_id, prod_date) 
		
			  -- Deletion logic for all commodity except gas
			  SELECT DISTINCT mi.meter_id, s.date 
			  FROM ' + @stage_ebase_mv90_data_header + ' h
			  INNER JOIN source_commodity sc ON sc.commodity_id = h.commodity
			  INNER JOIN (
			  	SELECT DISTINCT meter_id, h_filename, date FROM ' + @stage_mv90_data + '
			  	UNION ALL 
			  	SELECT DISTINCT meter_id, h_filename, date FROM ' + @stage_mv90_data_hour + '
			  	UNION ALL
			  	SELECT DISTINCT meter_id, h_filename, date FROM ' + @stage_mv90_data_mins + '
			  ) s ON s.meter_id = h.meter_id AND s.h_filename = h.h_filename
			  INNER JOIN static_data_value sdv ON sdv.code = h.country
			  INNER JOIN meter_id mi ON mi.commodity_id = sc.source_commodity_id
			  AND mi.country_id = sdv.value_id
			  WHERE h.file_category = ''1'' AND h.dataversion = ''Final'' AND h.error_code = ''0'' AND h.commodity <> ''Gas''

			  UNION ALL

	  		 -- Deletion logic for Gas commodity
			 SELECT DISTINCT mi.meter_id, s.date 
			  FROM ' + @stage_ebase_mv90_data_header + ' h
			  INNER JOIN source_commodity sc ON sc.commodity_id = h.commodity
			  INNER JOIN (
			  	SELECT DISTINCT meter_id, h_filename, date FROM ' + @stage_mv90_data + '
			  	UNION ALL 
			  	SELECT DISTINCT meter_id, h_filename, date FROM ' + @stage_mv90_data_hour + '
			  	UNION ALL
			  	SELECT DISTINCT meter_id, h_filename, date FROM ' + @stage_mv90_data_mins + '
			  ) s ON s.meter_id = h.meter_id AND s.h_filename = h.h_filename
			  INNER JOIN static_data_value sdv ON sdv.code = h.country
			  INNER JOIN meter_id mi ON mi.commodity_id = sc.source_commodity_id
			  AND mi.country_id = sdv.value_id
			  WHERE h.file_category = ''1'' AND h.dataversion = ''Final'' AND h.error_code = ''0'' AND h.commodity = ''Gas''
			  AND DAY(s.date) <> 1  
		   ')

		-- using granularity column to get meter monthly granularity
		EXEC('INSERT INTO #dver_final_meter(meter_id, prod_date) 
			  SELECT DISTINCT mi.meter_id, s.date 
			  FROM ' + @stage_ebase_mv90_data_header + ' h
			  INNER JOIN source_commodity sc ON sc.commodity_id = h.commodity
			  INNER JOIN  ' + @stage_mv90_data + ' s ON s.meter_id = h.meter_id AND s.h_filename = h.h_filename
			  INNER JOIN static_data_value sdv ON sdv.code = h.country
			  INNER JOIN meter_id mi ON mi.commodity_id = sc.source_commodity_id AND mi.country_id = sdv.value_id
			  WHERE h.file_category = ''1'' AND h.dataversion = ''Final'' AND h.error_code = ''0'' AND h.commodity = ''Gas''
			  AND mi.granularity = ''M''
		   ')
		
		
		DELETE mdh 
		FROM mv90_data_hour mdh
				INNER JOIN [mv90_data] md ON md.[meter_data_id] = mdh.[meter_data_id]
				INNER JOIN #dver_final_meter dfm ON dfm.meter_id = md.meter_id
				INNER JOIN meter_id mi ON mi.meter_id = md.meter_id AND mdh.[prod_date] = dfm.[prod_date] 

		DELETE mdm 
		FROM mv90_data_mins mdm
				INNER JOIN [mv90_data] md ON md.[meter_data_id] = mdm.[meter_data_id]
				INNER JOIN #dver_final_meter dfm ON dfm.meter_id = md.meter_id
				INNER JOIN meter_id mi ON mi.meter_id = md.meter_id AND mdm.[prod_date] = dfm.[prod_date] 

		-- Delete monthly data only for monthly granularity.
		EXEC('DELETE md FROM mv90_data md
				INNER JOIN #dver_final_meter dfm ON dfm.meter_id = md.meter_id
				INNER JOIN meter_id mi ON mi.meter_id = md.meter_id AND 
				[dbo].[FNAgetcontractmonth](md.[from_date]) = [dbo].[FNAgetcontractmonth](dfm.[prod_date])
				LEFT JOIN ' + @stage_ebase_mv90_data_header + ' h ON
				h.meter_id = mi.recorderid
			  WHERE h.granularity = ''M'' ')


		CREATE TABLE #temp_header_country_commodity(country varchar(100) COLLATE DATABASE_DEFAULT,commodity varchar(100) COLLATE DATABASE_DEFAULT,h_filename varchar(100) COLLATE DATABASE_DEFAULT,file_category varchar(100) COLLATE DATABASE_DEFAULT) 
		EXEC('INSERT INTO #temp_header_country_commodity(country, commodity, h_filename, file_category)
			  SELECT DISTINCT country, commodity, [h_filename], file_category FROM ' + @stage_ebase_mv90_data_header )
		CREATE CLUSTERED INDEX IDX_temp_header_country_commodity ON #temp_header_country_commodity(country)
		
		CREATE TABLE #mins_data_meter(meter_id VARCHAR(100) COLLATE DATABASE_DEFAULT )
		EXEC('INSERT INTO #mins_data_meter(meter_id) SELECT DISTINCT meter_id FROM ' + @stage_mv90_data_mins )
		CREATE CLUSTERED INDEX IDX_mins_data_meter ON #mins_data_meter(meter_id)
		
		DECLARE @qr VARCHAR(MAX)
		CREATE TABLE #stage_mins_zero_vol (
			[mv90_data_id] [INT] IDENTITY(1,1) NOT NULL,
			[meter_id] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
			[channel] [varchar](10) COLLATE DATABASE_DEFAULT NULL,
			[date] [varchar](10) COLLATE DATABASE_DEFAULT NULL,
			[hour] [varchar](5) COLLATE DATABASE_DEFAULT NULL,
			[value] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
			[h_filename] [varchar](100) COLLATE DATABASE_DEFAULT NULL, 
			[h_error] [varchar](1000) COLLATE DATABASE_DEFAULT NULL, 
			[d_filename] [varchar](100) COLLATE DATABASE_DEFAULT NULL, 
			[d_error] [varchar](1000) COLLATE DATABASE_DEFAULT NULL)
		
		
		CREATE TABLE #zero_vol_meter (meter_id VARCHAR(255) COLLATE DATABASE_DEFAULT)
		--all meters (for that country and commodity) which were not imported will be set to zero for days less than export timestamp minus allocation delay day.
		
		SET @qr = '		

			INSERT INTO #stage_mins_zero_vol (meter_id, channel, date, hour, value, h_filename, h_error, d_filename, d_error)
			 SELECT mi.recorderid meter_id, 1 channel, a.[date] [date], a.[hour] [hour], 0 value, '''' [h_filename], '''' [h_error], '''' [d_filename], '''' [d_error]
			 FROM	
			 (
				SELECT DISTINCT sdv.value_id country,sc.source_commodity_id commodity,a.[date],a.[hour]
				 FROM #temp_header_country_commodity h      
				 INNER JOIN static_data_value sdv ON sdv.code = h.country
				 INNER JOIN source_commodity sc ON sc.commodity_id = h.commodity      
				 CROSS APPLY
					(SELECT DISTINCT [date], [hour] FROM '+@stage_mv90_data_mins+' WHERE [d_filename]=h.[h_filename]) a
				 WHERE sdv.type_id = 14000 AND sc.source_commodity_id = -2 AND h.file_category = ''1''
			 ) a				  
			 INNER JOIN meter_id mi ON mi.commodity_id = a.commodity AND mi.country_id = a.country   
			 LEFT JOIN #mins_data_meter s ON s.meter_id = mi.recorderid
			 WHERE s.meter_id IS NULL AND mi.granularity = ''Q''
		'
		EXEC spa_print @qr
		EXEC(@qr)
		
		-- zero out missing days for importing meter.
		SET @qr = '		

			INSERT INTO #stage_mins_zero_vol (meter_id, channel, date, hour, value, h_filename, h_error, d_filename, d_error)
			 SELECT mi.recorderid meter_id, 1 channel, a.[date] [date], a.[hour] [hour], 0 value, '''' [h_filename], '''' [h_error], '''' [d_filename], '''' [d_error]
			 FROM	
			 (
				SELECT DISTINCT sdv.value_id country,sc.source_commodity_id commodity,a.[date],a.[hour]
				 FROM #temp_header_country_commodity h      
				 INNER JOIN static_data_value sdv ON sdv.code = h.country
				 INNER JOIN source_commodity sc ON sc.commodity_id = h.commodity      
				 CROSS APPLY
					(SELECT DISTINCT [date], [hour] FROM '+@stage_mv90_data_mins+' WHERE [d_filename]=h.[h_filename]) a
				 WHERE sdv.type_id = 14000 AND sc.source_commodity_id = -2 AND h.file_category = ''1''
			 ) a				  
			 INNER JOIN meter_id mi ON mi.commodity_id = a.commodity AND mi.country_id = a.country   
			 INNER JOIN #mins_data_meter s ON s.meter_id = mi.recorderid
			 LEFT JOIN '+@stage_mv90_data_mins+' m ON m.meter_id = s.meter_id AND m.date = a.date --AND m.hour = a.hour
			 WHERE mi.granularity = ''Q'' AND m.mv90_data_id IS NULL
		'
		EXEC spa_print @qr
		EXEC(@qr)		
		
		CREATE TABLE #null_gran_meter(meter_id VARCHAR(255) COLLATE DATABASE_DEFAULT, term DATETIME)
		
		SET @qr = '		

			INSERT INTO #stage_mins_zero_vol (meter_id, channel, date, hour, value, h_filename, h_error, d_filename, d_error)
			OUTPUT INSERTED.meter_id, INSERTED.date INTO #null_gran_meter
			 SELECT mi.recorderid meter_id, 1 channel, a.[date] [date], a.[hour] [hour], 0 value, '''' [h_filename], '''' [h_error], '''' [d_filename], '''' [d_error]
			 FROM	
			 (
				SELECT DISTINCT sdv.value_id country,sc.source_commodity_id commodity,a.[date],a.[hour]
				 FROM #temp_header_country_commodity h      
				 INNER JOIN static_data_value sdv ON sdv.code = h.country
				 INNER JOIN source_commodity sc ON sc.commodity_id = h.commodity      
				 CROSS APPLY
					(SELECT DISTINCT [date], [hour] FROM '+@stage_mv90_data_mins+' WHERE [d_filename]=h.[h_filename]) a
				 WHERE sdv.type_id = 14000 AND sc.source_commodity_id = -2 AND h.file_category = ''1''
			 ) a				  
			 INNER JOIN meter_id mi ON mi.commodity_id = a.commodity AND mi.country_id = a.country   
			 LEFT JOIN #mins_data_meter s ON s.meter_id = mi.recorderid
			 WHERE s.meter_id IS NULL AND mi.granularity IS NULL
		'
		EXEC spa_print @qr
		EXEC(@qr)


		EXEC('		
			INSERT INTO ' + @stage_mv90_data_mins + ' (meter_id, channel, date, hour, value, h_filename, h_error, d_filename, d_error)
			OUTPUT INSERTED.meter_id INTO #zero_vol_meter
			SELECT meter_id,channel, date, hour, [value], h_filename, h_error, d_filename, d_error FROM #stage_mins_zero_vol	
		')

		-- requires insertion in header since the table is joined to detail table.
		EXEC('INSERT INTO ' + @stage_ebase_mv90_data_header + '([meter_id], [granularity], [uom], [counterparty], [commodity], 
			  [filetype], [timestamp], [dataversion], [h_filename], [h_error], [error_code], [file_category], [country])
			  SELECT DISTINCT mi.recorderid, ''Q'', su.uom_id, '''', ''Power'', '''', '''', '''', '''', '''', ''0'', 1, '''' FROM #zero_vol_meter z 
			  INNER JOIN meter_id mi ON mi.recorderid = z.meter_id
			  INNER JOIN recorder_properties rp ON rp.meter_id = mi.meter_id
			  INNER JOIN source_uom su ON su.source_uom_id = rp.uom_id
			  LEFT JOIN ' + @stage_ebase_mv90_data_header + ' h ON h.meter_id = z.meter_id
			  WHERE h.meter_id IS NULL
			  
			  ') 

		        
 	    CREATE TABLE #dver_gas_data(meter_id INT, prod_date VARCHAR(30) COLLATE DATABASE_DEFAULT)
 	    
 	    CREATE TABLE #all_mv90_stage_date(meter_id varchar(100) COLLATE DATABASE_DEFAULT, h_filename varchar(100) COLLATE DATABASE_DEFAULT, date datetime)
 	    EXEC('INSERT INTO #all_mv90_stage_date(meter_id, h_filename, date)
 				SELECT DISTINCT meter_id, h_filename, date FROM ' + @stage_mv90_data + '
			  	UNION ALL 
			  	SELECT DISTINCT meter_id, h_filename, date FROM ' + @stage_mv90_data_hour + '
			  	UNION ALL
			  	SELECT DISTINCT meter_id, h_filename, date FROM ' + @stage_mv90_data_mins )
		CREATE CLUSTERED INDEX IDX_all_mv90_stage_date ON #all_mv90_stage_date(meter_id)
 	     
 	    
	    -- logic to update first day of the month ( [Hr 7 to 24] to NULL since Hr 1 to 6 will have data of previous month)
		EXEC('INSERT INTO #dver_gas_data(meter_id, prod_date) 
			  SELECT mi.meter_id, MIN(s.date) 
			  FROM ' + @stage_ebase_mv90_data_header + ' h
			  INNER JOIN source_commodity sc ON sc.commodity_id = h.commodity
			  INNER JOIN #all_mv90_stage_date s ON s.meter_id = h.meter_id AND s.h_filename = h.h_filename
			  INNER JOIN static_data_value sdv ON sdv.code = h.country
			  INNER JOIN meter_id mi ON mi.commodity_id = sc.source_commodity_id
			  AND mi.country_id = sdv.value_id
			  WHERE h.file_category = ''1'' AND h.dataversion = ''Final'' AND h.error_code = ''0'' AND h.commodity = ''Gas''
			  AND DAY(s.date) = 1  GROUP BY mi.meter_id') 
  

  
		UPDATE mdh SET mdh.Hr7 = NULL, mdh.Hr8 = NULL, mdh.Hr9 = NULL, mdh.Hr10 = NULL, mdh.Hr11 = NULL, mdh.Hr12 = NULL, mdh.Hr13 = NULL,
					   mdh.Hr14 = NULL, mdh.Hr15 = NULL, mdh.Hr16 = NULL, mdh.Hr17 = NULL, mdh.Hr18 = NULL, mdh.Hr19 = NULL, mdh.Hr20 = NULL,
					   mdh.Hr21 = NULL, mdh.Hr22 = NULL, mdh.Hr23 = NULL, mdh.Hr24 = NULL, mdh.Hr25 = NULL  
				FROM mv90_data_hour mdh
				INNER JOIN [mv90_data] md ON md.[meter_data_id] = mdh.[meter_data_id]
				INNER JOIN #dver_gas_data dfm ON dfm.meter_id = md.meter_id
							AND mdh.[prod_date] = dfm.[prod_date] 
		
		UPDATE mdh SET mdh.Hr1 = NULL, mdh.Hr2 = NULL, mdh.Hr3 = NULL, mdh.Hr4 = NULL, mdh.Hr5 = NULL, mdh.Hr6 = NULL
		FROM mv90_data_hour mdh
			INNER JOIN [mv90_data] md ON md.[meter_data_id] = mdh.[meter_data_id]
			INNER JOIN #dver_gas_data dfm ON dfm.meter_id = md.meter_id
						 AND mdh.[prod_date] = DATEADD(mm, 1, dfm.[prod_date])

 
		UPDATE mdh SET 
		   mdh.Hr7_15 = NULL,mdh.Hr7_30 = NULL,mdh.Hr7_45 = NULL,mdh.Hr7_60 = NULL,    
		   mdh.Hr8_15 = NULL,mdh.Hr8_30 = NULL,mdh.Hr8_45 = NULL,mdh.Hr8_60 = NULL,   
		   mdh.Hr9_15 = NULL,mdh.Hr9_30 = NULL,mdh.Hr9_45 = NULL,mdh.Hr9_60 = NULL,   
		   mdh.Hr10_15 = NULL,mdh.Hr10_30 = NULL,mdh.Hr10_45 = NULL,mdh.Hr10_60 = NULL,   
		   mdh.Hr11_15 = NULL,mdh.Hr11_30 = NULL,mdh.Hr11_45 = NULL,mdh.Hr11_60 = NULL,   
		   mdh.Hr12_15 = NULL,mdh.Hr12_30 = NULL,mdh.Hr12_45 = NULL,mdh.Hr12_60 = NULL,
		   mdh.Hr13_15 = NULL,mdh.Hr13_30 = NULL,mdh.Hr13_45 = NULL,mdh.Hr13_60 = NULL,
		   mdh.Hr14_15 = NULL,mdh.Hr14_30 = NULL,mdh.Hr14_45 = NULL,mdh.Hr14_60 = NULL,
		   mdh.Hr15_15 = NULL,mdh.Hr15_30 = NULL,mdh.Hr15_45 = NULL,mdh.Hr15_60 = NULL,
		   mdh.Hr16_15 = NULL,mdh.Hr16_30 = NULL,mdh.Hr16_45 = NULL,mdh.Hr16_60 = NULL,
		   mdh.Hr17_15 = NULL,mdh.Hr17_30 = NULL,mdh.Hr17_45 = NULL,mdh.Hr17_60 = NULL,
		   mdh.Hr18_15 = NULL,mdh.Hr18_30 = NULL,mdh.Hr18_45 = NULL,mdh.Hr18_60 = NULL,
		   mdh.Hr19_15 = NULL,mdh.Hr19_30 = NULL,mdh.Hr19_45 = NULL,mdh.Hr19_60 = NULL,
		   mdh.Hr20_15 = NULL,mdh.Hr20_30 = NULL,mdh.Hr20_45 = NULL,mdh.Hr20_60 = NULL,
		   mdh.Hr21_15 = NULL,mdh.Hr21_30 = NULL,mdh.Hr21_45 = NULL,mdh.Hr21_60 = NULL,
		   mdh.Hr22_15 = NULL,mdh.Hr22_30 = NULL,mdh.Hr22_45 = NULL,mdh.Hr22_60 = NULL,
		   mdh.Hr23_15 = NULL,mdh.Hr23_30 = NULL,mdh.Hr23_45 = NULL,mdh.Hr23_60 = NULL,
		   mdh.Hr24_15 = NULL,mdh.Hr24_30 = NULL,mdh.Hr24_45 = NULL,mdh.Hr24_60 = NULL,
		   mdh.Hr25_15 = NULL,mdh.Hr25_30 = NULL,mdh.Hr25_45 = NULL,mdh.Hr25_60 = NULL		
		FROM [mv90_data_mins] mdh
		INNER JOIN [mv90_data] md ON md.[meter_data_id] = mdh.[meter_data_id]
		INNER JOIN #dver_gas_data dfm ON dfm.meter_id = md.meter_id
					AND mdh.[prod_date] = dfm.[prod_date] 

		
		UPDATE mdh SET mdh.Hr1_15 = NULL,mdh.Hr1_30 = NULL,mdh.Hr1_45 = NULL,mdh.Hr1_60 = NULL,    
					   mdh.Hr2_15 = NULL,mdh.Hr2_30 = NULL,mdh.Hr2_45 = NULL,mdh.Hr2_60 = NULL,   
					   mdh.Hr3_15 = NULL,mdh.Hr3_30 = NULL,mdh.Hr3_45 = NULL,mdh.Hr3_60 = NULL,   
					   mdh.Hr4_15 = NULL,mdh.Hr4_30 = NULL,mdh.Hr4_45 = NULL,mdh.Hr4_60 = NULL,   
					   mdh.Hr5_15 = NULL,mdh.Hr5_30 = NULL,mdh.Hr5_45 = NULL,mdh.Hr5_60 = NULL,   
					   mdh.Hr6_15 = NULL,mdh.Hr6_30 = NULL,mdh.Hr6_45 = NULL,mdh.Hr6_60 = NULL
		FROM mv90_data_mins mdh
			INNER JOIN [mv90_data] md ON md.[meter_data_id] = mdh.[meter_data_id]
			INNER JOIN #dver_gas_data dfm ON dfm.meter_id = md.meter_id
						 AND mdh.[prod_date] = DATEADD(mm, 1, dfm.[prod_date])

		

		-- updating volume after deletion in hourly table
		--UPDATE md
		--SET md.volume = mvh.vol
	select DISTINCT meter_id, CAST(CONVERT(VARCHAR(7),prod_date,120)+'-01' AS DATETIME) prod_date INTO #total_meter FROM #dver_final_meter
	UPDATE mv set mv.volume = a.vol	
	FROM
	mv90_data mv INNER JOIN		
	(select md.meter_id,md.from_date,mvh.vol
	FROM 
		mv90_data md
		INNER JOIN #total_meter dhm ON dhm.[meter_id] = md.[meter_id]
			AND CAST(md.from_date AS DATETIME)  BETWEEN CAST(dhm.prod_date AS DATETIME) AND  DATEADD(m,1,CAST(dhm.prod_date AS DATETIME))
		CROSS APPLY(
			SELECT SUM(
				CASE WHEN COALESCE(mdh.Hr1,mdh.Hr2,mdh.Hr3,mdh.Hr4,mdh.Hr5,mdh.Hr6,mdh.Hr7,mdh.Hr8,mdh.Hr9,mdh.Hr10,mdh.Hr11,mdh.Hr12,mdh.Hr13,
						 mdh.Hr14,mdh.Hr15,mdh.Hr16,mdh.Hr17,mdh.Hr18,mdh.Hr19,mdh.Hr20,mdh.Hr21,mdh.Hr22,mdh.Hr23,mdh.Hr24) IS NULL THEN NULL
					 ELSE 	 
					ISNULL(mdh.Hr1,0) + ISNULL(mdh.Hr2,0) + ISNULL(mdh.Hr3,0) + ISNULL(mdh.Hr4,0) + ISNULL(mdh.Hr5,0) + ISNULL(mdh.Hr6,0) + ISNULL(mdh.Hr7,0) + ISNULL(mdh.Hr8,0) + ISNULL(mdh.Hr9,0) + ISNULL(mdh.Hr10,0)+
					ISNULL(mdh.Hr11,0) + ISNULL(mdh.Hr12,0) + ISNULL(mdh.Hr13,0) + ISNULL(mdh.Hr14,0) + ISNULL(mdh.Hr15,0) + ISNULL(mdh.Hr16,0) + ISNULL(mdh.Hr17,0) + ISNULL(mdh.Hr18,0) + ISNULL(mdh.Hr19,0) + ISNULL(mdh.Hr20,0) + ISNULL(mdh.Hr21,0)+
					ISNULL(mdh.Hr22,0) + ISNULL(mdh.Hr23,0) + ISNULL(mdh.Hr24,0) END
				) vol
			FROM 
				 mv90_data_hour mdh 
			WHERE
				mdh.meter_data_id = md.meter_data_id		
		) mvh
	)a ON mv.meter_id =a.meter_id AND mv.from_date = a.from_date
	


	 DELETE mdh
	 FROM
	  mv90_data mv INNER JOIN mv90_data_hour mdh ON mv.meter_data_id=mdh.meter_data_id AND mv.volume IS NULL
	  INNER JOIN(SELECT DISTINCT meter_id FROM #total_meter) b
	  ON mv.meter_id = b.meter_id 


	DELETE md
		FROM mv90_data md
			INNER JOIN(SELECT DISTINCT meter_id FROM #total_meter) dhm ON dhm.meter_id = md.meter_id
			LEFT JOIN mv90_data_hour mdh ON mdh.meter_data_id = md.meter_data_id
		WHERE mdh.recid IS NULL
   
	   
		CREATE TABLE #error_code ([type] CHAR(1) COLLATE DATABASE_DEFAULT)


		
		IF EXISTS (SELECT 1 FROM #month_data_count WHERE row_count > 0)
		BEGIN
			INSERT INTO #error_code 
			EXEC spa_import_monthly_data @stage_mv90_data, 5466, 'Import Monthly Data', @process_id, @user_login_id, 2, @stage_ebase_mv90_data_header
		END

		IF EXISTS (SELECT 1 FROM #hour_data_count WHERE row_count > 0)
		BEGIN
			INSERT INTO #error_code 
			EXEC spa_import_hourly_data @stage_mv90_data_hour, 5466, 'Import Hourly Data', @process_id, @user_login_id, 2, @stage_ebase_mv90_data_header
		END
		
		IF EXISTS (SELECT 1 FROM #min15_data_count WHERE row_count > 0)
		BEGIN
			INSERT INTO #error_code 
			EXEC spa_import_15_mins_data @stage_mv90_data_mins, 5466, 'Import 15 mins Data', @process_id, @user_login_id, 2, @stage_ebase_mv90_data_header	
			
			--delete 0 data from mins table for meter with granularity null
			-- requires since we are inserting 0 data in stage table and the 15mins import proc imports data in mins and hour table both.
			SELECT n.meter_id, MIN(n.term) term INTO #null_gran_meter2 FROM #null_gran_meter n GROUP BY n.meter_id

			DELETE mdm FROM mv90_data mv 
			INNER JOIN meter_id mi ON mi.meter_id = mv.meter_id
			INNER JOIN #null_gran_meter2 n ON n.meter_id = mi.recorderid
			INNER JOIN mv90_data_mins mdm ON mv.meter_data_id=mdm.meter_data_id AND mv.from_date = CONVERT(VARCHAR(7),n.term,120)+'-01'
			
		END
			
	
		COMMIT

		
		--log error meter_id with errors
		EXEC('INSERT INTO source_system_data_import_status( Process_id, code, module, source, [type], [description])
			OUTPUT CASE WHEN INSERTED.[code] = ''Error'' THEN ''e'' ELSE ''s'' END  INTO #error_code
			SELECT ''' + @process_id + ''', ''Error'', ''Import Data'', CASE granularity WHEN ''M'' THEN ''Monthly'' WHEN ''H'' THEN ''Hourly'' WHEN ''Q'' THEN ''15 mins'' ELSE '''' END + '' Data Import ('' + sm.h_filename + '')'', ''Results'', sm.h_error 
			FROM ' + @stage_ebase_mv90_data_header + ' sm 
			WHERE sm.error_code <> ''0'' ')

	
	END TRY
	BEGIN CATCH
		SET @caught = 1
		SET @desc = ERROR_MESSAGE()

		IF @@TRANCOUNT > 0
			ROLLBACK		
		
	END CATCH
	
	IF @caught = 1 
	BEGIN
		SET @type = 'e'
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT 1 FROM source_system_data_import_status WHERE Process_id = @process_id AND TYPE = 'Error')
			SET @type = 'e'	
		IF EXISTS (SELECT 1 FROM #error_code WHERE [type] = 'e')
			SET @type = 'e'
		ELSE 
			SET @type = 's'

	END
END

--logic to check gas allocation delay month for 0 fill / disable if manual
CREATE TABLE #manual(do_exists BIT)
DECLARE @empty_dir BIT
EXEC('INSERT INTO #manual SELECT DISTINCT 1 FROM ' + @stage_ebase_mv90_data_header + ' WHERE file_category = 0') 
SET @empty_dir = CASE WHEN @error_code = 2 THEN 1 ELSE 0 END

IF NOT EXISTS (SELECT 1 FROM #manual) AND @caught = 0
BEGIN
	EXEC spa_check_gas_allocation_ebase @stage_ebase_mv90_data_header, @stage_mv90_data_hour, @empty_dir
	--print 'EXEC spa_check_gas_allocation_ebase '+@stage_ebase_mv90_data_header+', '+@stage_mv90_data_hour+', '--+@empty_dir
END

	--result set required to return to SSIS package to move conflict files from processed to error folder 

	SELECT '' [filename] WHERE 1 = 2 -- currently not used this feature but can be used if any files is needed to be moved to error from processed folder after import

	SELECT @elapsed_sec = DATEDIFF(second, create_ts, GETDATE()) FROM import_data_files_audit idfa WHERE idfa.process_id = @process_id
	SET @elapse_sec_text = CAST(CAST(@elapsed_sec/60 AS INT) AS VARCHAR) + ' Mins ' + CAST(@elapsed_sec - CAST(@elapsed_sec/60 AS INT) * 60 AS VARCHAR) + ' Secs'
 
	SELECT @desc = CASE WHEN @caught = 0 THEN 
				   'Meter data import process completed on as of date ' + dbo.FNAUserDateFormat(GETDATE(), @user_login_id)
				   ELSE @desc END	
	  
	SET @url = './dev/spa_html.php?__user_name__=' + @user_login_id + '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id + ''''        
	SET @url_desc = '<a target="_blank" href="' + @url + '">' +
					  @desc 
					+ '.</a> <br>' + CASE WHEN (@type = 'e') THEN ' (ERRORS found)' ELSE '' END + ' [Elapse time: ' + ISNULL(@elapse_sec_text, ' (Debug mode)') + ']'        

	  --audit table log update total execution time
	  EXEC spa_import_data_files_audit 'u',NULL, NULL,@process_id, NULL, NULL, NULL, @type, @elapsed_sec

	EXEC spa_message_board 'i', @user_login_id, NULL, 'Import Data', @url_desc, '', '', @type, 'Import Meter Data'	
	
	--removing Ad-hoc message
	DELETE mb FROM message_board mb WHERE mb.job_name = 'ImportData_' + @process_id 

END

