
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_import_shaped_hourly_data]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_import_shaped_hourly_data]
GO
--===================================================================
-- Author:		mmanandhar@pioneersolutionsglobal.us
-- Create date: 2011-4-28
-- Description:	Imports shaped hourly data of deal from a staging table. 

--History
--Author:       ssingh@pioneersolutionsglobal.us
--Modified Date: 2012-2-29
--Description: Import shaped hourly data from multiple files in a folder.

--Params:
--@temp_table_name VARCHAR(100) Temporary table name,  
--@job_name	       VARCHAR(100) Job name,  
--@process_id      VARCHAR(100) Process id,
--@file_name       VARCHAR(200) Filename,
--@user_login_id   VARCHAR(50)  Username,
--@start_ts		   DATETIME     Start Timestamp,
--@call_from_flag  CHAR(1)      If import called from SSIS then 's' else If from a file 'f'
--@error_code	   CHAR(1)		Since data format errors are already handled By the SSIS itself ,catch block to update 
--								message box wont execute for data format errors the @error_code value is set to 'e' .
-- ============================================================================================================================

CREATE PROCEDURE [dbo].[spa_import_shaped_hourly_data]
	@temp_table_name	VARCHAR(100),  
	@job_name			VARCHAR(100) = NULL,  
	@process_id			VARCHAR(100),
	@file_name			VARCHAR(200) = NULL,
	@user_login_id		VARCHAR(50),
	@start_ts			DATETIME = NULL,
	@call_from_flag		CHAR(1) = 'f',
	@error_code			CHAR(1) = 's'
AS

SET NOCOUNT ON;
/*********************************** TEST DATA START ***************************************/
/*
DECLARE @call_from_flag   CHAR(1),
        @temp_table_name  VARCHAR(100),
        @job_name         VARCHAR(100),
        @process_id       VARCHAR(100),
        @file_name        VARCHAR(200),
        @user_login_id    VARCHAR(50),
        @start_ts         DATETIME,
        @error_code		  CHAR(1)
        

SET @call_from_flag = 's'	
SET @temp_table_name = 'adiha_process.dbo.stage_hourly_shape_farrms_admin_20120327_111953'

SET @process_id = '20120327_111953'
SET @user_login_id = 'farrms_admin'
SET @file_name = NULL

IF OBJECT_ID(N'tempdb..#tmp_second_table', 'U') IS NOT NULL
    DROP TABLE #tmp_second_table

IF OBJECT_ID(N'tempdb..#tmp_unique_deals', 'U') IS NOT NULL
    DROP TABLE #tmp_unique_deals

IF OBJECT_ID(N'tempdb..#data_count', 'U') IS NOT NULL
    DROP TABLE #data_count

IF OBJECT_ID(N'tempdb..#tmp_missing_deals', 'U') IS NOT NULL
    DROP TABLE #tmp_missing_deals

IF OBJECT_ID(N'tempdb..#tmp_invalid_deals', 'U') IS NOT NULL
    DROP TABLE #tmp_invalid_deals

IF OBJECT_ID(N'tempdb..#tmp_non_shaped_deals', 'U') IS NOT NULL
    DROP TABLE #tmp_non_shaped_deals

IF OBJECT_ID(N'tempdb..#tmp_hour_block_term', 'U') IS NOT NULL
    DROP TABLE #tmp_hour_block_term

IF OBJECT_ID(N'tempdb..#tmp_deal_volume', 'U') IS NOT NULL
    DROP TABLE #tmp_deal_volume

IF OBJECT_ID(N'tempdb..#tmp_error_deals', 'U') IS NOT NULL
    DROP TABLE #tmp_error_deals

IF OBJECT_ID(N'tempdb..#hour_block_term', 'U') IS NOT NULL
    DROP TABLE #hour_block_term
    
IF OBJECT_ID(N'tempdb..#a', 'U') IS NOT NULL
    DROP TABLE #a

IF OBJECT_ID(N'tempdb..#tbl_null_deals', 'U') IS NOT NULL
    DROP TABLE #tbl_null_deals

DECLARE @report_position_deals_table VARCHAR(150)
		
SET @report_position_deals_table = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
EXEC (
         'IF OBJECT_ID(N''' + @report_position_deals_table + ''', N''U'') IS NOT NULL 
		DROP TABLE ' + @report_position_deals_table
     )
--*/	
/*********************************** TEST DATA END ***************************************/

DECLARE @sql                       	VARCHAR(8000)
DECLARE @url                       	VARCHAR(5000)
DECLARE @desc                      	VARCHAR(1000)
DECLARE @total_count               	INT
DECLARE @elapsed_sec               	FLOAT
DECLARE @baseload_block_type       	VARCHAR(10)
DECLARE @baseload_block_define_id  	VARCHAR(10)
DECLARE @error_msg                 	VARCHAR(1000)
DECLARE @start_time					DATETIME
	
SET @baseload_block_type = '12000'	-- Internal Static Data
SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10))
FROM   static_data_value
WHERE  [type_id] = 10018
       AND code LIKE 'Base Load' -- External Static Data 
       
IF @baseload_block_define_id IS NULL
    SET @baseload_block_define_id = 'NULL'

-- @start_ts selected from create_ts when the job was run by  spa_interface_adaptor_job
SELECT  @start_ts = ISNULL(MIN(create_ts),GETDATE()) FROM import_data_files_audit WHERE process_id = @process_id

--IF no data format occurs in the SSIS package @error_code is passed as ''   
IF @error_code = ''
	SET @error_code = NULL

IF @user_login_id IS NULL
    SET @user_login_id = dbo.FNADBUser()

SET @sql = 'UPDATE ' + @temp_table_name + ' SET hour = 3 WHERE hour = ''3B'''  
EXEC (@sql)  
  
SET @sql = 'UPDATE ' + @temp_table_name + ' SET price = NULL WHERE price = ''0''' 
EXEC (@sql)

IF @call_from_flag = 'f' --import from a file, using file uploading
BEGIN
    SET @sql = 'ALTER TABLE ' + @temp_table_name +
        ' ADD [filename] VARCHAR(200) NOT NULL DEFAULT ''' + @file_name + ''',
		 [has_error] BIT NOT NULL DEFAULT 0'
    
    EXEC (@sql)
    exec spa_print @sql
END

CREATE TABLE #tmp_second_table
(
	[source_deal_header_id]  INT,
	[deal_id]                VARCHAR(150) COLLATE DATABASE_DEFAULT,
	[deal_detail_id]         INT,
	[leg]                    INT,
	[date]                   DATETIME,
	[hour]                   TINYINT,
	[volume]                 NUMERIC(38, 20),
	[price]                  NUMERIC(38, 20),
	[filename]               VARCHAR(200) COLLATE DATABASE_DEFAULT,
	[has_error]              BIT
)

BEGIN TRY
	--copy all data from staging table to second one
	SET @sql = 
	    '
		INSERT INTO #tmp_second_table(deal_id, source_deal_header_id, leg, [date], [hour], volume, price, [filename])
		SELECT tst.deal_id, tst.source_deal_header_id
			, CAST(tst.leg AS INT) leg, [dbo].[FNAClientToSqlDate](tst.date) [date], CAST(tst.[hour] AS INT) [hour]
			, CAST(tst.volume AS NUMERIC(38, 20)) volume, CAST(tst.price AS NUMERIC(38, 20)) price, [filename]
		FROM ' + @temp_table_name + ' tst
		'
	
	EXEC spa_print @sql
	EXEC (@sql)
		
	--store unique deal_ids whose source_deal_header_id is not given
	CREATE TABLE #tmp_unique_deals
	(
		source_deal_header_id  INT,
		deal_id VARCHAR(100) COLLATE DATABASE_DEFAULT
	)
	
	--insert unique deal_ids to map to its source_deal_header_id
	INSERT INTO #tmp_unique_deals
	  (
	    source_deal_header_id,
	    deal_id
	  )
	SELECT DISTINCT sdh.source_deal_header_id,
	       tst.deal_id
	FROM #tmp_second_table tst
	       LEFT JOIN source_deal_header sdh
	            ON  tst.deal_id = sdh.deal_id
	WHERE  tst.source_deal_header_id IS NULL
	       AND tst.deal_id IS NOT NULL
	
	--update source_deal_header_id for those whose deal_id is given in file, but not source_deal_header_id
	--After updating, source_deal_header_id won't have NULL values in #tmp_second_table, but deal_id may be NULL
	UPDATE #tmp_second_table
	SET    source_deal_header_id = tud.source_deal_header_id
	FROM   #tmp_second_table tst
	       LEFT JOIN #tmp_unique_deals tud
	            ON  tst.deal_id = tud.deal_id
	WHERE  tst.source_deal_header_id IS NULL
	       AND tst.deal_id IS NOT NULL
	
	--get deal_detail_id for all records
	UPDATE #tmp_second_table
	SET    deal_detail_id = sdd.source_deal_detail_id
	FROM   #tmp_second_table tst
	       INNER JOIN source_deal_detail sdd
	            ON  tst.source_deal_header_id = sdd.source_deal_header_id
	            AND tst.[date] BETWEEN sdd.term_start AND sdd.term_end
	            AND ISNULL(tst.leg, 1) = sdd.leg
END TRY
BEGIN CATCH
	SET @error_msg = 'Error: ' + ERROR_MESSAGE()
	SET @error_code = 'e'
	EXEC spa_print @error_msg
	
	--Incase of SSIS import, data format errors are already handled by SSIS, so the error handler code here is just for satisfying the codition
	INSERT INTO source_system_data_import_status
	  (
	    process_id,
	    code,
	    module,
	    [source],
	    [type],
	    [description],
	    recommendation
	  )
	  EXEC (
			 'SELECT DISTINCT ' + '''' + @process_id + '''' + ',' + '''Error''' 
			 + ',' + '''Import Shaped Hourly Data''' + ',' + '[filename],' + 
			 '''Error'''
			 + ',' + '''' + @error_msg + '''' + ',' + 
			 '''Please import correct Shaped Hourly data file.''' + 
			 ' FROM ' + @temp_table_name
		 )
	
	SET @error_code = ISNULL(NULLIF(@error_code, ''), 's') --IF value of error code is passed blank from SSIS then NULLIF converts it to NULL
	SET @elapsed_sec = DATEDIFF(SECOND, @start_ts, GETDATE())
	
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id +
	       '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' 
	       + @user_login_id + ''''
	
	SELECT @desc = '<a target="_blank" href="' + @url + '">' +
	       'Deal Shaped Hourly Data import process completed' +
	       CASE 
	            WHEN (@error_code = 'e') THEN ' (ERRORS found)'
	            ELSE ''
	       END +
	       '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(100)) + ' sec </a>'
	
	EXEC spa_NotificationUserByRole 2, @process_id, 'Import Shaped Hourly Data123', @desc , @error_code, @job_name, 1
	
	RETURN
END CATCH 

CREATE TABLE #data_count
(
	total_rows INT,
	[filename] VARCHAR(200) COLLATE DATABASE_DEFAULT
)
CREATE TABLE #tmp_missing_deals
(
	source_deal_header_id  INT ,
	deal_id                VARCHAR(1000) COLLATE DATABASE_DEFAULT ,
	[filename]             VARCHAR(200) COLLATE DATABASE_DEFAULT
)
CREATE TABLE #tmp_invalid_deals
(
	source_deal_header_id  INT ,
	deal_id                VARCHAR(1000) COLLATE DATABASE_DEFAULT,
	term                   DATETIME,
	leg                    INT,
	[filename]             VARCHAR(200) COLLATE DATABASE_DEFAULT
)
CREATE TABLE #tmp_non_shaped_deals
(
	source_deal_header_id  INT,
	deal_id                VARCHAR(1000) COLLATE DATABASE_DEFAULT,
	[filename]             VARCHAR(200) COLLATE DATABASE_DEFAULT
)

--count total number of rows in a file 
SET @sql = 'INSERT INTO #data_count(total_rows, [filename]) SELECT COUNT(*), [filename] FROM  ' + @temp_table_name + ' GROUP BY [filename]'
EXEC (@sql)
SELECT @total_count = total_rows
FROM   #data_count 

IF @total_count = 0
BEGIN
    SET @error_code = 'e'
    INSERT INTO source_system_data_import_status
      (
        process_id,
        code,
        module,
        [source],
        [type],
        [description],
        recommendation
      )
    EXEC (
             'SELECT DISTINCT ' + '''' + @process_id + '''' + ',' + '''Error''' 
             + ',' + '''Import Shaped Hourly Data''' + ',' + '[filename],' + 
             '''Error'''
             + ',' + '''Staging table is empty.''' + ',' + 
             '''Please import correct Shaped deal hourly data file.''' + 
             ' FROM ' + @temp_table_name
         )
END
ELSE
BEGIN
    BEGIN TRY
    	BEGIN TRAN
    	DECLARE @min_date  DATETIME,
    	        @max_date  DATETIME
    	
    	--get missing deals ids
    	INSERT INTO #tmp_missing_deals
    	  (
    	    source_deal_header_id,
    	    deal_id,
    	    [filename]
    	  )
    	SELECT tmp.source_deal_header_id,
    	       tmp.deal_id,
    	       tmp.[filename]
    	FROM   #tmp_second_table tmp
    	       LEFT JOIN source_deal_header sdh
    	            ON  sdh.source_deal_header_id = tmp.source_deal_header_id
    	WHERE sdh.source_deal_header_id IS NULL
    	AND (tmp.source_deal_header_id IS NOT NULL AND tmp.deal_id IS NOT NULL) 
    	
    	EXEC spa_print 'DATA INSERTED INTO #tmp_missing_deals '
    	
    	-- get data mismatched deals (i.e. deals having non existing term or leg)
    	INSERT INTO #tmp_invalid_deals
    	  (
    	    source_deal_header_id,
    	    deal_id,
    	    term,
    	    leg,
    	    [filename]
    	  )
    	SELECT tmp.source_deal_header_id,
    	       tmp.deal_id,
    	       tmp.[date],
    	       tmp.leg,
    	       tmp.[filename]
    	FROM   #tmp_second_table tmp
    	WHERE  tmp.deal_detail_id IS NULL
    	       AND NOT EXISTS (
    	               SELECT 1
    	               FROM   #tmp_missing_deals
    	               WHERE  deal_id = tmp.deal_id
    	           ) --exclude missing deals in this check
    	       AND NOT EXISTS (
    	               SELECT 1
    	               FROM   #tmp_missing_deals
    	               WHERE  source_deal_header_id = tmp.source_deal_header_id
    	           ) --exclude missing deals in this check 
    	       AND (tmp.source_deal_header_id IS NOT NULL AND tmp.deal_id IS NOT NULL) 
    	       
    	EXEC spa_print 'DATA INSERTED INTO #tmp_invalid_deals ' 
    	
    	--get non shaped deals, as those deals won't be imported
    	INSERT INTO #tmp_non_shaped_deals
    	  (
    	    source_deal_header_id,
    	    deal_id,
    	    [filename]
    	  )
    	SELECT tst.source_deal_header_id,
    	       tst.deal_id,
    	       tst.[filename]
    	FROM   #tmp_second_table tst
    	       INNER JOIN source_deal_header sdh
    	            ON  tst.source_deal_header_id = sdh.source_deal_header_id
    	       LEFT JOIN static_data_value sdv
    	            ON  sdv.value_id = sdh.internal_desk_id
    	WHERE  ISNULL(sdv.value_id, -1) <> 17302
    	
    	EXEC spa_print 'DATA INSERTED INTO #tmp_non_shaped_deals '    	
    	EXEC spa_print 'DELETE MISSING & NON-SHAPED DEALS FROM STAGING TABLE'
    	
    	-- delete missing deals from staging table
    	DELETE tmp
    	FROM   #tmp_second_table tmp
    	       INNER JOIN #tmp_missing_deals tmd
					ON  tmd.source_deal_header_id = tmp.source_deal_header_id
    	
    	-- delete non-shaped deals from staging table
    	DELETE tmp
    	FROM   #tmp_second_table tmp
    	       INNER JOIN #tmp_non_shaped_deals tnsd
    	            ON  tnsd.source_deal_header_id = tmp.source_deal_header_id
    	
    	EXEC spa_print 'DELETE ERRORNEOUS DEALS'
    	-- delete errorneous deals
    	DELETE tmp
    	FROM   #tmp_second_table tmp
    	       INNER JOIN #tmp_invalid_deals tid
    	            ON  tmp.source_deal_header_id = tid.source_deal_header_id
    	            AND tid.term = tmp.date
    	            AND tid.leg = tmp.leg
    	
    	--SELECT @min_date = MIN(CONVERT(DATETIME, date, 120)),
    	--       @max_date = MAX(CONVERT(DATETIME, date, 120))
	 	SELECT @min_date = MIN(date),
			 @max_date = MAX(date)
    	FROM   #tmp_second_table
    	
    	DELETE source_deal_detail_hour
    	FROM   source_deal_detail_hour sddh
    	       INNER JOIN #tmp_second_table t
    	            ON  sddh.source_deal_detail_id = t.deal_detail_id
    	            AND t.date = sddh.term_date
    	            AND ((sddh.hr = CAST(t.hour AS VARCHAR)) OR (REPLACE(sddh.hr, ':00', '') = (RIGHT('0'+CAST(t.hour AS VARCHAR),2))))
    	
    	IF OBJECT_ID('tempdb..#tmp_hour_block_term') IS NOT NULL
    	    DROP TABLE #tmp_hour_block_term
    	
    	--copy the required portion of holiday_term_block for performance reasons		
    	CREATE TABLE #tmp_hour_block_term
    	(
    		block_define_id   INT,
    		block_type        INT,
    		term_date         DATETIME,
    		hol_date          DATETIME,
    		term_start        DATETIME,
    		volume_mult       INT,
    		dst_applies       VARCHAR(1) COLLATE DATABASE_DEFAULT,
    		add_dst_hour      INT,
    		on_peak_off_peak  INT,
    		[hour]            INT
    	)
    	
    	--SELECT * INTO #hour_block_term FROM hour_block_term WHERE term_date BETWEEN @min_date AND @max_date 
    	SELECT hbt.* INTO #hour_block_term 
    	       --SELECT count(*)
    	FROM   hour_block_term hbt
    	       INNER JOIN (
    	                SELECT DISTINCT COALESCE(spcd.block_type, sdh.block_type, @baseload_block_type)
    	                       block_type,
    	                       COALESCE(
    	                           spcd.block_define_id,
    	                           sdh.block_define_id,
    	                           @baseload_block_define_id
    	                       ) block_define_id
    	                FROM   #tmp_second_table tst
    	                       INNER JOIN source_deal_detail sdd
    	                            ON  tst.deal_detail_id = sdd.source_deal_detail_id
    	                       INNER JOIN source_deal_header sdh
    	                            ON  sdh.source_deal_header_id = sdd.source_deal_header_id
    	                       LEFT JOIN source_price_curve_def spcd
    	                            ON  spcd.source_curve_def_id = sdd.curve_id
    	            ) sdd
    	            ON  hbt.block_type = sdd.block_type
    	            AND hbt.block_define_id = sdd.block_define_id
    	WHERE  term_date BETWEEN @min_date AND @max_date 	
    	
    	INSERT INTO #tmp_hour_block_term
    	  (
    	    block_define_id,
    	    block_type,
    	    term_date,
    	    hol_date,
    	    term_start,
    	    volume_mult,
    	    dst_applies,
    	    add_dst_hour,
    	    on_peak_off_peak,
    	    [hour]
    	  )
    	SELECT block_define_id,
    	       block_type,
    	       term_date,
    	       hol_date,
    	       term_start,
    	       volume_mult,
    	       dst_applies,
    	       add_dst_hour,
    	       on_peak_off_peak,
    	       REPLACE(hour, 'hr', '') [hour]
    	FROM   (
    	        SELECT DISTINCT hb.block_define_id, hb.block_type, hb.term_date, hb.hol_date, hb.term_start, hb.volume_mult
				, hb.dst_applies, hb.add_dst_hour, hb.Hr1, hb.Hr2, hb.Hr3, hb.Hr4, hb.Hr5, hb.Hr6, hb.Hr7, hb.Hr8, hb.Hr9
				, hb.Hr10, hb.Hr11, hb.Hr12, hb.Hr13, hb.Hr14, hb.Hr15, hb.Hr16, hb.Hr17, hb.Hr18, hb.Hr19, hb.Hr20, hb.Hr21
				, hb.Hr22, hb.Hr23, hb.Hr24 
				FROM #tmp_second_table tst
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = tst.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = tst.deal_detail_id
					AND sdd.source_deal_header_id = sdh.source_deal_header_id					
				INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
				INNER JOIN #hour_block_term hb ON hb.term_date = tst.date
				WHERE term_date BETWEEN @min_date AND @max_date 
    	       ) hbt
    	       UNPIVOT(
    	           on_peak_off_peak FOR [hour] IN (Hr1, Hr2, Hr3, Hr4, Hr5, Hr6, 
    	                                          Hr7, Hr8, Hr9, Hr10, Hr11, 
    	                                          Hr12, Hr13, Hr14, Hr15, Hr16, 
    	                                          Hr17, Hr18, Hr19, Hr20, Hr21, 
    	                                          Hr22, Hr23, Hr24)
    	       ) AS unpivot_hour
    	
    	--insert new hourly data for each source_deal_detail_id
    	EXEC spa_print 'DATA INSERTED INTO source_deal_detail_hour'
    	
    	INSERT INTO source_deal_detail_hour
    	  (
    	    source_deal_detail_id,
    	    term_date,
    	    hr,
    	    volume,
    	    price,
    	    is_dst,
    	    granularity 
    	  )
    	SELECT DISTINCT sdd.source_deal_detail_id,
    	       tst.[date] --date in MMDDYYYY format
    	       ,
    	       tst.[hour],
    	       tst.volume,
    	       tst.price,
    	       (
    	           CASE 
    	                WHEN ROW_NUMBER() OVER(
    	                         PARTITION BY tst.[deal_detail_id],
    	                         tst.leg,
    	                         tst.[date],
    	                         tst.[hour] ORDER BY tst.date
    	                     ) = 2 THEN 1
    	                ELSE 0
    	           END
    	       ) is_dst,
    	       982 --Granularity is 982 For Hourly Deals
    	FROM   #tmp_second_table tst
    	       INNER JOIN source_deal_header sdh
    	            ON  sdh.deal_id = tst.[deal_id]
    	            OR sdh.source_deal_header_id = tst.source_deal_header_id
    	       INNER JOIN source_deal_detail sdd
    	            ON  sdd.source_deal_detail_id = tst.deal_detail_id
    	            AND sdd.source_deal_header_id = sdh.source_deal_header_id
    	       INNER JOIN source_price_curve_def spcd
    	            ON  spcd.source_curve_def_id = sdd.curve_id
    	       INNER JOIN #tmp_hour_block_term thbt
    	            ON  thbt.block_type = COALESCE(spcd.block_type, sdh.block_type, @baseload_block_type)
    	            AND thbt.block_define_id = COALESCE(
    	                    spcd.block_define_id,
    	                    sdh.block_define_id,
    	                    @baseload_block_define_id
    	                )
    	            AND thbt.term_date = tst.date
    	            AND thbt.hour = tst.hour
    	       LEFT JOIN source_deal_detail_hour sddh
    	            ON  sddh.source_deal_detail_id = tst.deal_detail_id
    	            AND sddh.hr = tst.hour
    	            AND sddh.term_date = tst.date
    	WHERE  thbt.on_peak_off_peak = 1
    	       AND sddh.source_deal_detail_id IS NULL 
    	       
		--update has_error=1 for deals having source_deal_header_id  NULL AND deal_id  NULL
		SET @sql = 'UPDATE ' +@temp_table_name + ' SET has_error = 1 WHERE source_deal_header_id IS NULL AND deal_id IS NULL '
		EXEC spa_print @sql
		EXEC(@sql)

		--Log such errors that have source_deal_header_id  NULL AND deal_id  NULL
		CREATE TABLE #tbl_null_deals (
			[filename] VARCHAR(200) COLLATE DATABASE_DEFAULT
		)
		
		SET @sql ='INSERT INTO #tbl_null_deals([filename])
				SELECT DISTINCT [filename]
				FROM '+ @temp_table_name + ' WHERE source_deal_header_id IS NULL AND deal_id IS NULL
				'
				
		EXEC (@sql)
		
		IF EXISTS (SELECT 1 FROM #tbl_null_deals)
		BEGIN 
			SET @error_code = 'e'
			
			--To count the number of distinct filename from #tmp_missing_deals
			SELECT @file_name = MAX(filename)
			FROM #tbl_null_deals tmd
				CROSS JOIN (
					SELECT COUNT(DISTINCT [filename]) cnt
					FROM #tbl_null_deals  tmd
				) data_cnt
			WHERE data_cnt.cnt = 1
			

			IF @file_name IS NULL
			BEGIN 
				INSERT INTO source_system_data_import_status
					  (
						process_id,
						code,
						module,
						[type],
						[description],
						recommendation
					  )
				EXEC('SELECT DISTINCT ' + '''' +@process_id+ '''' + ',' + '''Error''' 
				 + ',' + '''Import Shaped Hourly Data''' + ','  + 
				 '''Error'''
				 + ',' + '''Deal ID and  Reference ID cannot be blank.''' + ',' + 
				 '''Please check/correct the supplied Deal ID and Reference ID.''' + 
				 ' FROM ' + @temp_table_name + ' WHERE source_deal_header_id IS NULL AND deal_id IS NULL')
			END
			ELSE
			BEGIN
	    		INSERT INTO source_system_data_import_status
				  (
					process_id,
					[source],
					code,
					module,
					[type],
					[description],
					recommendation
				  )
				  EXEC('SELECT DISTINCT ' + '''' +@process_id + '''' + ',' + '''' +@file_name + '''' + ','+ '''Error''' 
					 + ',' + '''Import Shaped Hourly Data''' + ','  + 
					 '''Error'''
					 + ',' + '''Deal ID and  Reference ID cannot be blank.''' + ',' + 
					 '''Please check/correct the supplied Deal ID.''' + 
					 ' FROM ' + @temp_table_name + ' WHERE source_deal_header_id IS NULL AND deal_id IS NULL')
			
			END
    		EXEC spa_print 'data inserted for null deals' 
    		
    		 INSERT INTO source_system_data_import_status_detail
    	      (
    	        [source],
    	        process_id,
    	        [type],
    	        [description],
    	        type_error
    	      )
    	       EXEC('SELECT DISTINCT [filename],'+ '''' +@process_id + '''' + ','+'''Error''' 
					 + ',' + '''Deal ID and  Reference ID cannot be blank.''' + ','  + 
					 '''Deal ID and  Reference ID cannot be blank.''' + 
					 ' FROM ' + @temp_table_name + ' WHERE source_deal_header_id IS NULL AND deal_id IS NULL')
					 
			EXEC spa_print 'DATA INSERTED FOR NULL DEALS IN source_system_data_import_status_detail'
		END 
    	
    	--update the has_error = 1 in the staging table  for files that have errors in them.
    	SET @sql = 'UPDATE ttn SET ttn.has_error = 1 
    	            FROM ' + @temp_table_name + ' ttn  
    					INNER JOIN 
						(
							SELECT source_deal_header_id, deal_id, [filename] FROM #tmp_missing_deals 
							UNION 
							SELECT source_deal_header_id, deal_id, [filename] FROM #tmp_invalid_deals
							UNION 
							SELECT source_deal_header_id, deal_id, [filename] FROM #tmp_non_shaped_deals
						) ted 
							ON  ttn.source_deal_header_id = ted.source_deal_header_id
							AND ttn.deal_id = ted.deal_id
							AND ttn.filename = ted.filename'
    	
    	exec spa_print @sql
    	EXEC (@sql)
    	
    	IF EXISTS (SELECT 1 FROM #tmp_missing_deals)
    	BEGIN
    	    SET @error_code = 'e'
    	    
    	    --To count the number of distinct filename from #tmp_missing_deals
			SELECT @file_name = MAX(filename)
			FROM #tmp_missing_deals tmd
				CROSS JOIN (
					SELECT COUNT(DISTINCT [filename]) cnt
					FROM #tmp_missing_deals tmd
				) data_cnt
			WHERE data_cnt.cnt = 1
			
			
    	    IF @file_name IS NULL
    	    BEGIN
    			INSERT INTO source_system_data_import_status
    			  (
    				process_id,
    				code,
    				module,
    				[type],
    				[description],
    				recommendation
    			  )
    			SELECT DISTINCT @process_id,
    				   'Error',
    				   'Import Shaped Hourly Data',
    				   'Error',
    				   'Deal ID does not exist in the system.',
    				   'Please check/correct the supplied Deal ID.'
    			FROM   #tmp_missing_deals
    	    END
    	    ELSE
    	    BEGIN
    	    	INSERT INTO source_system_data_import_status
    			  (
    				process_id,
    				[source],
    				code,
    				module,
    				[type],
    				[description],
    				recommendation
    			  )
    			SELECT DISTINCT @process_id,
    					@file_name,
    				   'Error',
    				   'Import Shaped Hourly Data',
    				   'Error',
    				   'Deal ID does not exist in the system.',
    				   'Please check/correct the supplied Deal ID.'
    			FROM   #tmp_missing_deals
    	    END
    	    
    	    EXEC spa_print 'DATA INSERTED INTO SOURCE_SYSTEM_DATA_IMPORT_STATUS FOR MISSING DEALS'
    	    
    	    INSERT INTO source_system_data_import_status_detail
    	      (
    	        [source],
    	        process_id,
    	        [type],
    	        [description],
    	        type_error
    	      )
    	    SELECT DISTINCT [filename],
    	           @process_id,
    	           'Data Error',
    	           (
    	               CASE 
    	                    WHEN deal_id IS NOT NULL THEN ' Deal ID:'
    	                    ELSE ' Source Deal Header ID:'
    	               END
    	           )
    	           + COALESCE(deal_id, CAST(source_deal_header_id AS VARCHAR(30)), '') 
    	           + ' does not exist in the system.',
    	           'Deal ID does not exist in the system.'
    	    FROM   #tmp_missing_deals
    	    
    	    EXEC spa_print 
    	    'DATA INSERTED INTO SOURCE_SYSTEM_DATA_IMPORT_STATUS_DETAIL FOR MISSING DEALS'
    	END
    	
    	IF EXISTS (SELECT 1 FROM #tmp_non_shaped_deals)
    	BEGIN
    	    SET @error_code = 'e'
    	    
    	    --To count the number of distinct filename from #tmp_non_shaped_deals
			SELECT @file_name = MAX(filename)
			FROM #tmp_non_shaped_deals tnd
				CROSS JOIN (
					SELECT COUNT(DISTINCT [filename]) cnt
					FROM #tmp_non_shaped_deals tnd
				) data_cnt
			WHERE data_cnt.cnt = 1
			
			IF @file_name IS NULL
			BEGIN
    			INSERT INTO source_system_data_import_status
    			  (
    				process_id,
    				code,
    				module,
    				[type],
    				[description],
    				recommendation
    			  )
    			SELECT DISTINCT @process_id,
    				   'Error',
    				   'Import Shaped Hourly Data',
    				   'Error',
    				   'Non Shaped Deals in the file.',
    				   'Please correct Data.'
    			FROM   #tmp_non_shaped_deals
    	    END 
    	    ELSE
    	    BEGIN
    	    	INSERT INTO source_system_data_import_status
    			  (
    				process_id,
    				[source],
    				code,
    				module,
    				[type],
    				[description],
    				recommendation
    			  )
    			SELECT DISTINCT @process_id,
    					@file_name,
    				   'Error',
    				   'Import Shaped Hourly Data',
    				   'Error',
    				   'Non Shaped Deals in the file.',
    				   'Please correct Data.'
    			FROM   #tmp_non_shaped_deals
    	    END
    	    
    	    EXEC spa_print 'DATA INSERTED INTO  SOURCE_SYSTEM_DATA_IMPORT_STATUS FOR NON SHAPED DEALS'
    	    
    	    INSERT INTO source_system_data_import_status_detail
    	      (
    	        [source],
    	        process_id,
    	        [type],
    	        [description],
    	        type_error
    	      )
    	    SELECT DISTINCT [filename],
    	           @process_id,
    	           'Data Error',
    	           (
    	               CASE 
    	                    WHEN deal_id IS NOT NULL THEN 'Deal ID:'
    	                    ELSE 'Source Deal Header ID:'
    	               END
    	           )
    	           + COALESCE(deal_id, CAST(source_deal_header_id AS VARCHAR(30)), '')
    	           + '  is not a hourly shaped deal.',
    	           'Non Shaped Deals in the file.'
    	    FROM   #tmp_non_shaped_deals
    	    
    	    EXEC spa_print'DATA INSERTED INTO SOURCE_SYSTEM_DATA_IMPORT_STATUS_DETAIL FOR NON SHAPED DEALS'
    	END
    	
    	IF EXISTS (SELECT 1 FROM #tmp_invalid_deals)
    	BEGIN
    	    SET @error_code = 'e'
    	    
    	    --To count the number of distinct filename from #tmp_invalid_deals
			SELECT @file_name = MAX(filename)
			FROM #tmp_invalid_deals tid
			CROSS JOIN (
				SELECT COUNT(DISTINCT [filename]) cnt
				FROM #tmp_invalid_deals tid
			) data_cnt
			WHERE data_cnt.cnt = 1
			
			IF @file_name IS NULL
			BEGIN
    			INSERT INTO source_system_data_import_status
    			  (
    				process_id,
    				code,
    				module,
    				[type],
    				[description],
    				recommendation
    			  )
    			SELECT DISTINCT @process_id,
    				   'Error',
    				   'Import Shaped Hourly Data',
    				   'Error',
    				   'Data mismatch in the file.',
    				   'Please correct Data.'
    			FROM   #tmp_invalid_deals tmd
    	    END 
    	    ELSE
    	    BEGIN
    	    	INSERT INTO source_system_data_import_status
    			  (
    				process_id,
    				[source],
    				code,
    				module,
    				[type],
    				[description],
    				recommendation
    			  )
    			SELECT  DISTINCT  @process_id,
    					[filename],
    				   'Error',
    				   'Import Shaped Hourly Data',
    				   'Error',
    				   'Data mismatch in the file.',
    				   'Please correct Data.'
    			FROM   #tmp_invalid_deals tmd
    	    END
    	        	    
    	    EXEC spa_print 'DATA INSERTED INTO SOURCE_SYSTEM_DATA_IMPORT_STATUS FOR INVALID DEALS'
    	    
    	   -- select ISNULL(deal_id,'') ,* from #tmp_invalid_deals
    	    
    	    INSERT INTO source_system_data_import_status_detail
    	      (
    	        [source],
    	        process_id,
    	        [type],
    	        [description],
    	        type_error
    	      )
    	    SELECT DISTINCT [filename],
    	           @process_id,
    	           'Data Error',
    	           'Leg:' + ISNULL(CAST(leg AS VARCHAR(5)), '') + ' and Term: ' + 
    	           ISNULL(dbo.FNADateFormat(term), '')
    	           + ' for  Deal ID: ' + ISNULL(deal_id,'') + ' does not exist in the system.',
    	           'Data mismatch in the file.'
    	    FROM   #tmp_invalid_deals
    	    
    	    EXEC spa_print 
    	    'DATA INSERTED INTO SOURCE_SYSTEM_DATA_IMPORT_STATUS_DETAIL FOR INVALID DEALS'
    	END 
    	
    	-- get count of staging table	
    	DECLARE @count_valid_deals INT
    	
    	-- if no error yet, set as success
    	SET @error_code = ISNULL(NULLIF(@error_code, ''), 's')
    	
    	--IF @count_valid_deals > 0
    	BEGIN
    	    INSERT INTO source_system_data_import_status
    	      (
    	        [source],
    	        process_id,
    	        code,
    	        module,
    	        [type],
    	        [description],
    	        recommendation
    	      )
			SELECT DISTINCT dc.[filename],
				@process_id,
				'Success',
				'Import Shaped Hourly Data',
				'Success',
				CAST(COUNT(tst.[filename]) AS VARCHAR(15)) + ' rows out of ' + 
				CAST(MAX(dc.total_rows) AS VARCHAR(15)) + ' imported for File:'
				+ dc.[filename],
				''
			FROM #data_count dc  
				LEFT JOIN #tmp_second_table tst ON tst.[filename] = dc.[filename] 
			WHERE tst.source_deal_header_id IS NOT NULL OR tst.deal_id IS NOT NULL
			GROUP BY dc.[filename]
    	END 
    	
    	/********************************************Update total monthly volume and price START********************************************************/
    	DECLARE @vol_frequency  CHAR(1),
    	        @deal_volume    NUMERIC(38, 20),
    	        @price          NUMERIC(38, 20)
    	
    	CREATE TABLE #tmp_deal_volume
    	(
    		average_vol  NUMERIC(38, 20),
    		sum_vol      NUMERIC(38, 20)
    	)
    	
    	SELECT @vol_frequency = sdd.deal_volume_frequency
    	FROM   #tmp_second_table tst
    	       INNER JOIN source_deal_detail sdd
    	            ON  sdd.source_deal_detail_id = tst.deal_detail_id
    	
    	UPDATE sdd
    	SET    deal_volume = sum_sddh.deal_volume,deal_volume_frequency = 't'
    	FROM   source_deal_detail sdd
    	       INNER JOIN (
    	                SELECT tst.deal_detail_id,
    	                       (
    	                            SUM(sddh.volume)
    	                           
    	                       ) deal_volume
    	                FROM   (
    	                           SELECT DISTINCT deal_detail_id
    	                           FROM   #tmp_second_table
    	                       ) tst
    	                       INNER JOIN source_deal_detail_hour sddh
    	                            ON  tst.deal_detail_id = sddh.source_deal_detail_id
    	                GROUP BY
    	                       deal_detail_id
    	            ) sum_sddh
    	            ON  sum_sddh.deal_detail_id = sdd.source_deal_detail_id
    	
    	IF NOT EXISTS (SELECT 'x' FROM #tmp_second_table WHERE  price IS NULL)
    	BEGIN
    	    UPDATE sdd
    	    SET    fixed_price = sum_sddh.fixed_price
    	    FROM   source_deal_detail sdd
    	           INNER JOIN (
    	                    SELECT deal_detail_id,
    	                           (
    	                             SUM(volume)    	                            
    	                           ) deal_volume,
    	                           SUM(volume * price) / SUM(volume) 
    	                           [fixed_price]
    	                    FROM   #tmp_second_table
    	                    GROUP BY
    	                           deal_detail_id
    	                ) sum_sddh
    	                ON  sum_sddh.deal_detail_id = sdd.source_deal_detail_id
    	END 
    	
    	DECLARE @spa                    VARCHAR(1000)
    	DECLARE @report_position_deals  VARCHAR(150)
    	
    	SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)
    	EXEC spa_print @report_position_deals
    	EXEC (
    	         'CREATE TABLE ' + @report_position_deals + 
    	         '( source_deal_header_id INT, action CHAR(1))'
    	     )
    	
    	SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action)
					SELECT DISTINCT source_deal_header_id ,''u''
					FROM #tmp_second_table'
    	
    	EXEC (@sql)
    	
    	SET @spa = 'spa_update_deal_total_volume NULL,''' + CAST(@process_id AS VARCHAR(1000)) + ''''    	
    	SET @job_name = 'spa_update_deal_total_volume_' + @process_id 
    	
    	EXEC spa_run_sp_as_job @job_name,
    	     @spa,
    	     'spa_update_deal_total_volume',
    	     @user_login_id 
    	/********************************************Update total monthly volume and price END********************************************************/
    	
    	COMMIT TRAN
    END TRY
    BEGIN CATCH
    	IF @@TRANCOUNT > 0
    	    ROLLBACK TRAN
    	
    	--DECLARE @error_msg VARCHAR(1000)
    	
    	SET @error_msg = 'Error: ' + ERROR_MESSAGE()
    	SET @error_code = 'e'
    	EXEC spa_print @error_msg    	
    	
    	INSERT INTO source_system_data_import_status
    	  (
    	    [source],
    	    process_id,
    	    code,
    	    module,
    	    [type],
    	    [description],
    	    recommendation
    	  )
    	SELECT DISTINCT tmp_error_deal.[filename],
    	       @process_id,
    	       'Error',
    	       'Import Shaped Hourly Data',
    	       'Error',
    	       @error_msg,
    	       'Please import correct Shaped Deal Hourly Data file.'
    	FROM   (
    	           SELECT source_deal_header_id,
    	                  deal_id,
    	                  [filename]
    	           FROM   #tmp_missing_deals 
    	           UNION 
    	           SELECT source_deal_header_id,
    	                  deal_id,
    	                  [filename]
    	           FROM   #tmp_invalid_deals
    	           UNION 
    	           SELECT source_deal_header_id,
    	                  deal_id,
    	                  [filename]
    	           FROM   #tmp_non_shaped_deals
    	       ) AS tmp_error_deal
    	
    	EXEC spa_print 'DATA INSERTED IN SOURCE_SYSTEM_DATA_IMPORT_STATUS FOR ERROR DEALS'
    END CATCH
END

--update message board

--incase of no error, mark as success
SET @error_code = ISNULL(NULLIF(@error_code, ''), 's')
SET @elapsed_sec = DATEDIFF(SECOND, @start_ts, GETDATE())

SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id +
			   '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id 
			   + ''''

SELECT @desc = '<a target="_blank" href="' + @url + '">' +
			   'Deal Shaped Hourly Data import process completed' +
			   CASE 
					WHEN (@error_code = 'e') THEN ' (ERRORS found)'
					ELSE ''
			   END +
			   '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(100)) + ' sec </a>'

--EXEC spa_message_board 'i',
--     @user_login_id,
--     NULL,
--     'Import Shaped Hourly Data',
--     @desc,
--     '',
--     '',
--     @error_code,
--     @job_name
 
EXEC spa_NotificationUserByRole 2, @process_id, 'Import Shaped Hourly Data', @desc , @error_code, @job_name, 1
     
--updating using flag 'e' which automatically calculate the estimated time.
EXEC spa_import_data_files_audit
     @flag = 'e',
     @process_id = @process_id,
     @status = @error_code
    
