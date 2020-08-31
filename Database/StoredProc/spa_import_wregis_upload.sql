
IF EXISTS(SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_import_wregis_upload]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_import_wregis_upload]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_import_wregis_upload]
	@temp_table_name	VARCHAR(500),
	@process_id			VARCHAR(500),
	@job_name			VARCHAR(250) = NULL,  
	@file_name			VARCHAR(200) = NULL,
	@user_login_id		VARCHAR(50)

AS

    /* 
    --TO DEBUG
    --select * from adiha_process.dbo.ixp_wregis_inventory_import_template_0_farrms_admin_F73F4EC9_5BA9_4A67_8B76_5F90B0EBACEB
    --update adiha_process.dbo.ixp_wregis_inventory_import_template_0_farrms_admin_F73F4EC9_5BA9_4A67_8B76_5F90B0EBACEB set certificate_serial_number = '801-NM-110782-1 to 950', quantity = 950 
    DECLARE @contextinfo VARBINARY(300) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON'); SET CONTEXT_INFO @contextinfo
    DECLARE @temp_table_name	VARCHAR(300) = 'adiha_process.dbo.ixp_wregis_rps_import_template_0_farrms_admin_43DC2382_8527_4866_9D6C_CF784C6133A5',
	   @process_id			VARCHAR(300) = 'F73F4EC9_5BA9_4A67_8B76_5F90B0EBACEB',
	   @job_name			VARCHAR(300) = 'importdata_5487_F73F4EC9_5BA9_4A67_8B76_5F90B0EBACEB',  
	   @file_name			VARCHAR(200) = NULL,
	   @user_login_id		VARCHAR(50) = 'farrms_admin'
    */


DECLARE @file_full_path VARCHAR(500),  
 @sql VARCHAR(MAX), @book_deal_type_map_id INT, @template_id INT,-- @user_login_id VARCHAR(100), @process_id VARCHAR(100),@job_name VARCHAR(100),
 @sql2 VARCHAR(MAX)	, @error_msg VARCHAR(250), @certificate_id INT

DECLARE @desc VARCHAR(8000),@error_code CHAR(1), @start_ts DATETIME

--SET @process_id = REPLACE(NEWID(),'-','_')

SELECT  @start_ts = isnull(min(create_ts),GETDATE()) from import_data_files_audit where process_id = @process_id

-- Here template name and Deal Detail Status - Cetified hardcoded. TODO update value id with negative number.
SELECT @certificate_id = value_id FROM static_data_value WHERE type_id = 25000  AND code = 'Certified'
SELECT @template_id = template_id from source_deal_header_template where template_name = 'REC REC'

--SET @template_id =  45 -- --6 -- 391 -- 5

--SET @book_deal_type_map_id =  4 -- --4 -- 321 -- 8
--SET @user_login_id = dbo.FNADBUser()

--SET  @file_full_path='\\lhotse\DB_Backup\Import test\REC import file with EE Costs.csv'
--SET  @file_full_path='d:\Hydro import final.csv'

IF OBJECT_ID('tempdb.dbo.#tmp_dff') IS NOT NULL
DROP TABLE #tmp_dff

IF OBJECT_ID('tempdb.dbo.#state') IS NOT NULL
DROP TABLE #state

IF OBJECT_ID('tempdb..##global_tmp_dff') is not null
DROP TABLE ##global_tmp_dff

IF OBJECT_ID('tempdb..#state2') is not null
DROP TABLE #state2

SET @sql = 'UPDATE temp SET temp.[wregis_gu_id] = a.value
 FROM ' + @temp_table_name + ' temp 
 CROSS APPLY
 (
	SELECT gmv.clm1_value value FROM generic_mapping_header gsm 
	INNER JOIN generic_mapping_definition gmd ON gsm.mapping_table_id = gmd.mapping_table_id
	INNER JOIN generic_mapping_values gmv on gmv.mapping_table_id = gmd.mapping_table_id
	WHERE gmv.clm2_value = temp.[wregis_gu_id]
	AND gsm.mapping_name = ''WREGIS Facility Mapping''
 ) a'
 
EXEC spa_print @sql
EXEC(@sql)

SET @sql = 'SELECT * INTO ##global_tmp_dff from  ' + @temp_table_name + ' where 1=2'

EXEC(@sql)

SELECT * INTO #tmp_dff from ##global_tmp_dff

DROP TABLE ##global_tmp_dff

DECLARE @name varchar(1000)
	, @name_with_case varchar(8000)
	, @name_with_datatype varchar(8000)
	, @name_state varchar(1000)
	, @name_with_td2 VARCHAR(1000)
	, @name_with_max2 VARCHAR(1000) 
	, @auto_assignment_type INT
	, @deal_volume float
	, @source_deal_detail_id2 INT
	, @source_deal_detail_id_from INT
	, @deal_date varchar(100)
	, @state_value_id INT
	, @assigned_date datetime
	, @cert_to float
	, @url VARCHAR(MAX)
	, @elapsed_sec float 

--select * from #tmp_dff
--select COL_LENGTH('#tmp_dff','Reason')

--Removed columns added by import script.
IF EXISTS (SELECT * FROM TempDB.INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME like '%#tmp_dff%' and COLUMN_NAME = 'import_file_name' )
ALTER TABLE #tmp_dff DROP COLUMN import_file_name

IF EXISTS (SELECT * FROM TempDB.INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME like '%#tmp_dff%' and COLUMN_NAME = 'source_system_id' )
ALTER TABLE #tmp_dff DROP COLUMN source_system_id

--RPS UPLOAD
IF EXISTS (SELECT * FROM TempDB.INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME like '%#tmp_dff%' and COLUMN_NAME = 'retirement_type' )
BEGIN
	
	SELECT  @start_ts = isnull(min(create_ts),GETDATE()) from import_data_files_audit where process_id = @process_id
	
	DECLARE @compliance_year VARCHAR(100), @inserted_source_deal_header_id VARCHAR(MAX),
	 @inserted_source_deal_detail_id VARCHAR(MAX)
	 
	ALTER TABLE #tmp_dff DROP COLUMN sub_account_name
	ALTER TABLE #tmp_dff DROP COLUMN [state_province]
	ALTER TABLE #tmp_dff DROP COLUMN [compliance_period]
	ALTER TABLE #tmp_dff DROP COLUMN Reason
	ALTER TABLE #tmp_dff DROP COLUMN [additional_detail]
	ALTER TABLE #tmp_dff DROP COLUMN [retirement_type]


	ALTER TABLE #tmp_dff DROP COLUMN [wregis_gu_id]
	ALTER TABLE #tmp_dff DROP COLUMN [generator_plant_unit_name]
	ALTER TABLE #tmp_dff DROP COLUMN country
	ALTER TABLE #tmp_dff DROP COLUMN [State]
	ALTER TABLE #tmp_dff DROP COLUMN [fuel_type]
	ALTER TABLE #tmp_dff DROP COLUMN [Month]
	ALTER TABLE #tmp_dff DROP COLUMN [Year]
	ALTER TABLE #tmp_dff DROP COLUMN [certificate_serial_number]
	ALTER TABLE #tmp_dff DROP COLUMN Quantity
	ALTER TABLE #tmp_dff DROP COLUMN [green_energy_eligible]
	ALTER TABLE #tmp_dff DROP COLUMN [ecologo_certified]
	ALTER TABLE #tmp_dff DROP COLUMN [hydro_certification]
	ALTER TABLE #tmp_dff DROP COLUMN [smud_eligible]
	ALTER TABLE #tmp_dff DROP COLUMN [etag_matched]
	ALTER TABLE #tmp_dff DROP COLUMN [eTag]

	select * into #state from #tmp_dff

	--select * from #tmp_dff

	--return

	ALTER TABLE #tmp_dff ADD  generator VARCHAR(1000) 
	ALTER TABLE #tmp_dff ADD  [monthly term] VARCHAR(1000) 
	ALTER TABLE #tmp_dff ADD  volume FLOAT
	ALTER TABLE #tmp_dff ADD  [cert from] VARCHAR(1000) 
	ALTER TABLE #tmp_dff ADD  [cert to] VARCHAR(1000) 
	ALTER TABLE #tmp_dff ADD  [Compliance Year] VARCHAR(1000) 
	ALTER TABLE #tmp_dff ADD  tier VARCHAR(1000) 
	ALTER TABLE #tmp_dff ADD [state] VARCHAR(100) 

	--DECLARE @name varchar(1000), @name_with_case varchar(8000), @name_with_datatype varchar(8000), @name_state varchar(1000)
	select @name = ISNULL(@name,'') + CASE WHEN @name is null THEN '' ELSE ',' END + '[' + name+ ']' from tempdb.sys.columns where object_id =
	object_id('tempdb..#tmp_dff') and name not in ('generator','monthly term','volume','cert from','cert to','Compliance Year','tier','state', 'temp_id')
	
	select @name_with_td2 = ISNULL(@name_with_td2,'') + CASE WHEN @name_with_td2 is null THEN '' ELSE ',' END + 'td.[' + name+ ']' from tempdb.sys.columns where object_id =
	object_id('tempdb..#tmp_dff') and name not in ('generator','monthly term','volume','cert from','cert to','Compliance Year','tier','state', 'temp_id')

	select @name_with_max2 = ISNULL(@name_with_max2,'') + CASE WHEN @name_with_max2 is null THEN '' ELSE ',' END + 'MAX([' + name+ '])' from tempdb.sys.columns where object_id =
	object_id('tempdb..#tmp_dff') and name not in ('generator','monthly term','volume','cert from','cert to','Compliance Year','tier','state', 'temp_id')

	select @name_with_case = ISNULL(@name_with_case,'') + CASE WHEN @name_with_case is null THEN '' ELSE ',' END + ' CASE WHEN ' + '[' + name + ']'+ '= ''No'' THEN ' + '['+ name + '] ELSE ''' + name + ''' END ' from tempdb.sys.columns where object_id =
	object_id('tempdb..#tmp_dff') and name not in ('generator','monthly term','volume','cert from','cert to', 'Compliance Year','tier','state', 'temp_id')
	
	select @name_with_datatype = ISNULL(@name_with_datatype,'') + CASE WHEN @name_with_datatype is null THEN '' ELSE ';' END + 'ALTER TABLE #tmp_dff4 ADD [' + name + ']' + ' VARCHAR(100) ' from tempdb.sys.columns where object_id =
     object_id('tempdb..#tmp_dff') and name not in ('generator','monthly term','volume','cert from','cert to', 'Compliance Year','tier','state', 'temp_id')


	SET @sql ='INSERT INTO #tmp_dff(generator , [monthly term] , volume , [cert from] , [cert to], [Compliance Year], tier, [state], ' + @name + '  ) 
			 SELECT [wregis_gu_id], [Year]+''/''+[Month]+''/1'', Quantity,
			 SUBSTRING([certificate_serial_number],0,CHARINDEX('' to'',[certificate_serial_number])), 
			 SUBSTRING([certificate_serial_number],0,LEN([certificate_serial_number])-CHARINDEX(''-'',REVERSE([certificate_serial_number]))+1)+''-''+SUBSTRING([certificate_serial_number],CHARINDEX(''to '',[certificate_serial_number])+3,LEN([certificate_serial_number])),
			 [compliance_period], Reason, [state], ' + @name_with_case + '
			 FROM '+@temp_table_name

	EXEC spa_print @sql
	EXEC(@sql)
	
	CREATE TABLE #tmp_dff4(generator VARCHAR(100) COLLATE DATABASE_DEFAULT
		, [monthly term] VARCHAR(100) COLLATE DATABASE_DEFAULT 
		, volume FLOAT
		, [cert from] VARCHAR(100) COLLATE DATABASE_DEFAULT 
		, [cert to] VARCHAR(100) COLLATE DATABASE_DEFAULT 
		, [Compliance Year] VARCHAR(100) COLLATE DATABASE_DEFAULT  
		, tier VARCHAR(100) COLLATE DATABASE_DEFAULT 
		, [state] VARCHAR(100) COLLATE DATABASE_DEFAULT)
	
	SET @sql = @name_with_datatype
	
	EXEC spa_print @sql
	EXEC(@sql)
	
	--select * from #tmp_dff
	
	--select * from #tmp_dff
--	set @sql = '
--	INSERT INTO #tmp_dff4(generator , [state], [monthly term] , volume , [cert from], [cert to], [Compliance Year], tier, ' + @name + ')
--	SELECT  MAX(generator) generator, MAX([state]) [state], MAX([monthly term]) [monthly term], SUM(volume) volume, MAX([cert from]) [cert from], MAX([cert to]) [cert to],
--	MAX([Compliance Year]) [Compliance Year], MAX(tier) tier, ' + @name_with_max2 + '
--	FROM (
--		SELECT DISTINCT td.generator , td.[state], td.[monthly term] , (CAST(td.volume AS FLOAT)) volume,
--		 (td.[cert from]) , 
--		(td2.[cert to]) , td.[Compliance Year], td.tier , ' + @name_with_td2 + '
--		--select td.*
--		FROM #tmp_dff td
--		INNER JOIN #tmp_dff td2 ON td2.[monthly term] = td.[monthly term] AND td2.generator = td.generator
--		AND SUBSTRING(ISNULL(td.[cert from],''-1''),0,LEN(ISNULL(td.[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL(td.[cert from],''-1''))))+1 )
--		= SUBSTRING(ISNULL(td2.[cert from],''-1''),0,LEN(ISNULL(td2.[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL(td2.[cert from],''-1''))))+1 )
--		AND CASE WHEN td.[cert to] IS NULL THEN ''-1'' ELSE (CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td.[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL(td.[cert to],''-1'')),0))) AS INT) + 1) END
--		= CASE WHEN td.[cert from] IS NULL THEN ''-1'' ELSE CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td2.[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL(td2.[cert from],''-1'')),0))) AS INT) END
--		UNION ALL
--		SELECT DISTINCT td2.generator , td2.[state], td2.[monthly term] , (CAST(td2.volume AS FLOAT)) volume ,
--		 (td.[cert from]) , 
--		(td2.[cert to]) , td2.[Compliance Year], td2.tier, ' + @name_with_td2 + '
--		--select td.*
--		FROM #tmp_dff td
--		INNER JOIN #tmp_dff td2 ON td2.[monthly term] = td.[monthly term] AND td2.generator = td.generator
--		AND SUBSTRING(ISNULL(td.[cert from],''-1''),0,LEN(ISNULL(td.[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL(td.[cert from],''-1''))))+1 )
--		= SUBSTRING(ISNULL(td2.[cert from],''-1''),0,LEN(ISNULL(td2.[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL(td2.[cert from],''-1''))))+1 )
--		AND CASE WHEN td.[cert to] IS NULL THEN ''-1'' ELSE (CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td.[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL(td.[cert to],''-1'')),0))) AS INT) + 1) END
--		= CASE WHEN td.[cert from] IS NULL THEN ''-1'' ELSE CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td2.[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL(td2.[cert from],''-1'')),0))) AS INT) END
--		) a
--GROUP BY generator, [monthly term]'

--EXEC spa_print @sql
--EXEC(@sql)

----return

--SELECT td.* INTO #tmp_delete2 FROM #tmp_dff td INNER JOIN ( 
--SELECT DISTINCT  td.generator , td.[state], td.[monthly term] , (CAST(td.volume AS FLOAT)) volume,
-- (td.[cert from]) [cert from] , 
--(td.[cert to])  [cert to]
----select td.*
--FROM #tmp_dff td
--INNER JOIN #tmp_dff td2 ON td2.[monthly term] = td.[monthly term] AND td2.generator = td.generator
--AND SUBSTRING(ISNULL(td.[cert from],'-1'),0,LEN(ISNULL(td.[cert from],'-1'))-(CHARINDEX('-',REVERSE(ISNULL(td.[cert from],'-1'))))+1 )
--= SUBSTRING(ISNULL(td2.[cert from],'-1'),0,LEN(ISNULL(td2.[cert from],'-1'))-(CHARINDEX('-',REVERSE(ISNULL(td2.[cert from],'-1'))))+1 )
--AND CASE WHEN td.[cert to] IS NULL THEN '-1' ELSE (CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td.[cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL(td.[cert to],'-1')),0))) AS INT) + 1) END
--= CASE WHEN td.[cert from] IS NULL THEN '-1' ELSE CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td2.[cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL(td2.[cert from],'-1')),0))) AS INT) END
--) a ON td.generator = a.generator AND td.[monthly term] = a.[monthly term] AND ISNULL(td.[cert from],'-1') = ISNULL(a.[cert from],'-1') AND ISNULL(td.[cert to],'-1') = ISNULL(a.[cert to],'-1')

--DELETE td FROM #tmp_dff td INNER JOIN ( 
--SELECT DISTINCT td2.generator , td2.[state], td2.[monthly term] , (CAST(td2.volume AS FLOAT)) volume ,
-- (td2.[cert from]) [cert from] , 
--(td2.[cert to]) [cert to] 
----select td.*
--FROM #tmp_dff td
--INNER JOIN #tmp_dff td2 ON td2.[monthly term] = td.[monthly term] AND td2.generator = td.generator
--AND SUBSTRING(ISNULL(td.[cert from],'-1'),0,LEN(ISNULL(td.[cert from],'-1'))-(CHARINDEX('-',REVERSE(ISNULL(td.[cert from],'-1'))))+1 )
--= SUBSTRING(ISNULL(td2.[cert from],'-1'),0,LEN(ISNULL(td2.[cert from],'-1'))-(CHARINDEX('-',REVERSE(ISNULL(td2.[cert from],'-1'))))+1 )
--AND CASE WHEN td.[cert to] IS NULL THEN '-1' ELSE (CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td.[cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL(td.[cert to],'-1')),0))) AS INT) + 1) END
--= CASE WHEN td.[cert from] IS NULL THEN '-1' ELSE CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td2.[cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL(td2.[cert from],'-1')),0))) AS INT) END
--) a ON td.generator = a.generator AND td.[monthly term] = a.[monthly term] AND ISNULL(td.[cert from],'-1') = ISNULL(a.[cert from],'-1') AND ISNULL(td.[cert to],'-1') = ISNULL(a.[cert to],'-1')
----return

--DELETE td FROM #tmp_dff td INNER JOIN #tmp_delete2 tdd ON td.generator = tdd.generator AND td.[monthly term] = tdd.[monthly term] 
--AND ISNULL(td.[cert from],'-1') = ISNULL(tdd.[cert from],'-1') AND ISNULL(td.[cert to],'-1') = ISNULL(tdd.[cert to],'-1')

    SET @sql = '  INSERT INTO #tmp_dff4(generator , [state], [monthly term] , volume ,   [cert from] , [cert to], [Compliance Year], tier, ' + @name + ')
			   SELECT  generator , [state], [monthly term] , (CAST(volume AS FLOAT)) , ([cert from]) , ([cert to]), [Compliance Year], tier, ' + @name + ' FROM #tmp_dff'

    EXEC spa_print @sql

    EXEC(@sql)
	--select * from #tmp_dff
	--return


	--CREATE TABLE #tmp_dff (generator VARCHAR(1000) COLLATE DATABASE_DEFAULT , [monthly term] VARCHAR(1000) COLLATE DATABASE_DEFAULT , volume VARCHAR(1000) COLLATE DATABASE_DEFAULT ,
	--[member] VARCHAR(1000) COLLATE DATABASE_DEFAULT , [percentage] VARCHAR(1000) COLLATE DATABASE_DEFAULT , [cert from] VARCHAR(1000) COLLATE DATABASE_DEFAULT , 
	--[cert to] VARCHAR(1000) COLLATE DATABASE_DEFAULT , [compliance YEAR] VARCHAR(1000) COLLATE DATABASE_DEFAULT , [sub-book1] VARCHAR(1000) COLLATE DATABASE_DEFAULT 
	----, [sub-book2] VARCHAR(1000) COLLATE DATABASE_DEFAULT 
	--, [tier] VARCHAR(100) COLLATE DATABASE_DEFAULT 
	--)

	--EXEC('INSERT INTO #tmp_dff(generator , [monthly term] , volume ,
	--[member] , [percentage] , [cert from] , 
	--[cert to] , [compliance YEAR], [sub-book1]
	----, [sub-book2]
	--,[tier] )
	--SELECT generator , [monthly term] , volume ,
	--[counterparty] , [percentage] , [cert from] , 
	--[cert to] , [compliance YEAR],  [sub-book1]
	----, [sub-book2]
	--,[tier] FROM '+@temp_table_name)


	--EXEC('
	--BULK INSERT #tmp_dff
	--		FROM '''+@file_full_path +'''
	--		WITH 
	--		( 
	--			FIRSTROW = 2, 
	--			FIELDTERMINATOR = '','', 
	--			ROWTERMINATOR = ''\n'' 
	--		)
	--')

	--SELECT * FROM #tmp_dff

	IF OBJECT_ID('tempdb.dbo.#tmp_final') IS NOT NULL
	DROP TABLE #tmp_final

	SELECT generator , [monthly term] , max(volume) volume ,
	 --[member] , MAX([percentage]) [percentage] , 
	 [cert from] , 
	MAX([cert to]) [cert to], [compliance YEAR], MAX([state]) [state]
	--, MAX([sub-book1]) [sub-book1]
	--, MAX([sub-book2]) [sub-book2]
	, tier
	INTO #tmp_final FROM #tmp_dff4 GROUP BY generator, [monthly term], [compliance YEAR], tier , [cert from]

	--SELECT * FROM #tmp_final

	--return


	IF OBJECT_ID('tempdb.dbo.#identified_deals') IS NOT NULL
	DROP TABLE #identified_deals
	
	CREATE TABLE #identified_deals(entire_term_start DATETIME
		, counterparty_id INT
		, source_deal_header_id INT
		, source_deal_detail_id INT
		, settlement_uom INT
		, deal_volume_uom_id INT
		, volume FLOAT 
		, [cert FROM] VARCHAR(100) COLLATE DATABASE_DEFAULT 
		, [cert to] VARCHAR(100) COLLATE DATABASE_DEFAULT  
		, [compliance YEAR] INT
		, tier_value_id INT
		, [book_deal_type_map_id] INT
		, gis_certificate_number_from VARCHAR(100) COLLATE DATABASE_DEFAULT  
		, code VARCHAR(100) COLLATE DATABASE_DEFAULT 
		, state_value_id INT)
	
	--LOGIC to import correct volume and discard others if volume exceeds in case of multiple states of same term and generator
	--DECLARE @term VARCHAR(100), @total_volume FLOAT = 0, @used_state VARCHAR(100), @used_gen VARCHAR(100)
	
	--DECLARE  used_states CURSOR LOCAL FOR
	--SELECT [monthly term], generator, [state] from #tmp_final order by [monthly term], generator, [state]
	--OPEN used_states;
	--FETCH NEXT FROM used_states INTO @term, @used_gen, @used_state
	--WHILE @@FETCH_STATUS = 0
	--BEGIN
	
		--IF EXISTS(SELECT 1 from #tmp_final WHERE [monthly term] = @term AND generator = @used_gen AND [state] = @used_state having count(*) > 1)
		--BEGIN
		--	SELECT @total_volume = @total_volume + tf.Volume
		--	FROM source_deal_header sdh 
		--	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		--	LEFT JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
		--	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		--	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--	CROSS APPLY(
		--		SELECT MAX(volume) Volume ,  [cert FROM], MAX([cert to]) [cert to]
		--		--, MAX([sub-book2]) [sub-book2]
		--		, [compliance YEAR], ISNULL(sdv_tier.value_id,'-1') tier_value_id ,MAX(tf.[state]) [state]
		--		FROM #tmp_final tf
		--		LEFT JOIN (select * from static_data_value where type_id = 15000) sdv_tier ON sdv_tier.code = ISNULL(tf.tier,'-1') 
		--		WHERE 1=1 
		--			AND tf.[monthly term] = @term
		--			AND tf.generator = @used_gen
		--			AND tf.[state] = @used_state
		--			AND tf.generator = rg.code 
		--			AND sdh.entire_term_start = tf.[monthly term]
		--			--AND COALESCE(gc.gis_certificate_number_from,tf.[cert FROM],'-1') = ISNULL(tf.[cert FROM],'-1')
		--			AND (
		--			SUBSTRING(ISNULL(gc.gis_certificate_number_from,[cert from]),0,LEN(ISNULL(gc.gis_certificate_number_from,[cert from]))-(CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from]))))+1 )
		--			= SUBSTRING(ISNULL([cert from],gc.gis_certificate_number_from),0,LEN(ISNULL([cert from],gc.gis_certificate_number_from))-(CHARINDEX('-',REVERSE(ISNULL([cert from],gc.gis_certificate_number_from))))+1 )
		--			AND	(
		--					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],gc.gis_certificate_number_from)),0,CHARINDEX('-',REVERSE(ISNULL([cert from],gc.gis_certificate_number_from)),0))) AS INT) BETWEEN 
		--					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0))) AS INT)
		--						AND CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0))) AS INT)
		--					AND CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],gc.gis_certificate_number_to)),0,CHARINDEX('-',REVERSE(ISNULL([cert to],gc.gis_certificate_number_to)),0))) AS INT) BETWEEN
		--					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0))) AS INT)
		--						AND CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0))) AS INT)
		--				)
		--		)
					
		--			group by tf.[compliance year], ISNULL(sdv_tier.value_id,'-1'), [cert FROM]
		--		) tf
		--		INNER JOIN (select * from static_data_value where type_id = 10002) sdv ON sdv.code = tf.[state]
		--	WHERE 1=1
		--	--and sdh.source_deal_header_id = 46888
		--		AND (CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) -
		--			CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) + 1) = volume
		--		AND	sdd.buy_sell_flag ='b'
		--		AND sdh.assignment_type_value_id IS NULL
		--		AND sdh.close_reference_id IS NULL
		--		--AND tf.[cert FROM] IS NOT NULL
		--		AND sdd.volume_left >= tf.volume
		--	END
		--	ELSE
		--	BEGIN
		--		SELECT @total_volume = tf.Volume
		--		FROM source_deal_header sdh 
		--		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		--		LEFT JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
		--		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		--		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--		CROSS APPLY(
		--			SELECT MAX(volume) Volume ,  [cert FROM], MAX([cert to]) [cert to]
		--			--, MAX([sub-book2]) [sub-book2]
		--			, [compliance YEAR], ISNULL(sdv_tier.value_id,'-1') tier_value_id ,MAX(tf.[state]) [state]
		--			FROM #tmp_final tf
		--			LEFT JOIN (select * from static_data_value where type_id = 15000) sdv_tier ON sdv_tier.code = ISNULL(tf.tier,'-1') 
		--			WHERE 1=1 
		--				AND tf.[monthly term] = @term
		--				AND tf.generator = @used_gen
		--				AND tf.[state] = @used_state
		--				AND tf.generator = rg.code 
		--				AND sdh.entire_term_start = tf.[monthly term]
		--				--AND COALESCE(gc.gis_certificate_number_from,tf.[cert FROM],'-1') = ISNULL(tf.[cert FROM],'-1')
		--				AND (
		--				SUBSTRING(ISNULL(gc.gis_certificate_number_from,[cert from]),0,LEN(ISNULL(gc.gis_certificate_number_from,[cert from]))-(CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from]))))+1 )
		--				= SUBSTRING(ISNULL([cert from],gc.gis_certificate_number_from),0,LEN(ISNULL([cert from],gc.gis_certificate_number_from))-(CHARINDEX('-',REVERSE(ISNULL([cert from],gc.gis_certificate_number_from))))+1 )
		--				AND	(
		--						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],gc.gis_certificate_number_from)),0,CHARINDEX('-',REVERSE(ISNULL([cert from],gc.gis_certificate_number_from)),0))) AS INT) BETWEEN 
		--						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0))) AS INT)
		--							AND CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0))) AS INT)
		--						AND CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],gc.gis_certificate_number_to)),0,CHARINDEX('-',REVERSE(ISNULL([cert to],gc.gis_certificate_number_to)),0))) AS INT) BETWEEN
		--						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0))) AS INT)
		--							AND CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0))) AS INT)
		--					)
		--			)
						
		--				group by tf.[compliance year], ISNULL(sdv_tier.value_id,'-1'), [cert FROM]
		--			) tf
		--			INNER JOIN (select * from static_data_value where type_id = 10002) sdv ON sdv.code = tf.[state]
		--		WHERE 1=1
		--		--and sdh.source_deal_header_id = 46888
		--			AND (CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) -
		--				CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) + 1) = volume
		--			AND	sdd.buy_sell_flag ='b'
		--			AND sdh.assignment_type_value_id IS NULL
		--			AND sdh.close_reference_id IS NULL
		--			--AND tf.[cert FROM] IS NOT NULL
		--			AND sdd.volume_left >= tf.volume
		--	END
			
	
		--select * from #identified_deals
		INSERT INTO #identified_deals(entire_term_start, counterparty_id, source_deal_header_id, source_deal_detail_id, settlement_uom, deal_volume_uom_id,
		volume , [cert FROM], [cert to]	, [compliance YEAR], tier_value_id, [book_deal_type_map_id], gis_certificate_number_from, code, state_value_id)
		SELECT DISTINCT sdh.entire_term_start, sdh.counterparty_id, sdh.source_deal_header_id, sdd.source_deal_detail_id, sdd.settlement_uom, sdd.deal_volume_uom_id,
		tf.volume , tf.[cert FROM], tf.[cert to], tf.[compliance YEAR], tf.tier_value_id, rg.fas_book_id [book_deal_type_map_id], gc.gis_certificate_number_from, rg.code, sdv.value_id state_value_id
		--select *
		--, sdd.volume_left
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		 
		--LEFT JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd.source_deal_detail_id
		--INNER JOIN Gis_Certificate gc_assign ON gc_assign.source_deal_header_id = aa.source_deal_header_id
		CROSS APPLY(
			SELECT MAX(volume) Volume ,  [cert FROM], MAX([cert to]) [cert to]
			--, MAX([sub-book2]) [sub-book2]
			, [compliance YEAR], ISNULL(sdv_tier.value_id,'-1') tier_value_id ,MAX(tf.[state]) [state]
			FROM #tmp_final tf
			LEFT JOIN (select * from static_data_value where type_id = 15000) sdv_tier ON sdv_tier.code = ISNULL(tf.tier,'-1') 
			WHERE 1=1 
				--AND tf.[monthly term] = @term
				--AND tf.generator = @used_gen
				--AND tf.[state] = @used_state
				AND tf.generator = rg.code 
				AND sdh.entire_term_start = tf.[monthly term]
				AND (
				SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc.gis_certificate_number_from)))+1 )
				= SUBSTRING([cert from],0,LEN([cert from])-(CHARINDEX('-',REVERSE([cert from])))+1 )
				AND	(
						CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
						CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
							AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
						CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
							AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
					)
			)
				
				group by tf.[compliance year], ISNULL(sdv_tier.value_id,'-1'), [cert FROM]
			) tf
			INNER JOIN (select * from static_data_value where type_id = 10002) sdv ON sdv.code = tf.[state]
		WHERE 1=1
		--and sdh.source_deal_header_id = 46888
			AND (CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) -
				CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) + 1) = volume
			AND	sdd.buy_sell_flag ='b'
			AND sdh.assignment_type_value_id IS NULL
			AND sdh.close_reference_id IS NULL
			--AND tf.[cert FROM] IS NOT NULL
			AND sdd.volume_left >= tf.volume
			--AND sdd.volume_left >= @total_volume
		
		--FETCH NEXT FROM used_states INTO @term, @used_gen, @used_state
		--select * from #identified_deals
	--END
	--CLOSE used_states;
	--DEALLOCATE used_states;	
		--return
		
		--return
		
	DECLARE @process_table VARCHAR(300)
	SET @process_id=dbo.FNAGetNewID()
	SET @process_table = dbo.FNAProcessTableName('process_table', @user_login_id,@process_id)

	SET @sql = 'CREATE TABLE ' + @process_table + '([ID] INT
					,[Volume Assign] float
					, [cert_from] varchar(1000), 
	[cert_to] varchar(1000), uom int,  compliance_year varchar(1000), tier_value_id INT, book_deal_type_map_id INT, state_value_id INT)'
	EXEC spa_print @sql
	EXEC(@sql)


	set @sql = 'INSERT INTO ' + @process_table + '
	([ID], [Volume Assign], [cert_from], [cert_to], uom, compliance_year, tier_value_id, book_deal_type_map_id, state_value_id ) 
	select source_deal_detail_id, volume, 1, CAST(volume AS VARCHAR), deal_volume_uom_id, [compliance year], tier_value_id, book_deal_type_map_id, state_value_id
		from #identified_deals '
	EXEC spa_print @sql
	EXEC(@sql)
	
	--select @process_table
	
	--select * from adiha_process.dbo.process_table_farrms_admin_23BDC006_FF33_4A8B_9267_183770AB0B36
	
	--return

	BEGIN TRAN
	BEGIN TRY 


	SELECT @compliance_year =  max([compliance YEAR]) FROM #tmp_final
	SELECT @assigned_date = dbo.fnastddate(CAST('12-31-'+@compliance_year AS DATETIME))
	--select @compliance_year, @assigned_date
	--SELECT @book_deal_type_map_id = max(book_deal_type_map_id) FROM source_system_book_map ssbm
	--INNER JOIN #tmp_final tf ON tf.[sub-book1] = ssbm.logical_name

	SELECT @book_deal_type_map_id = fas_book_id from rec_generator rg INNER JOIN #tmp_final tf ON rg.code = tf.generator



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
			SELECT DISTINCT 'WREGIS',
				@process_id,
				'Error',
				'Import WREGIS RPS Upload',
				'Error',
				'Inventory is not enough for RPS Compliance for listed certificates ' + tf.generator + ' for term ' + tf.[monthly term] + ' 
				as  volume ' + CAST((tf.volume) AS VARCHAR) + ' is greater than volume available of deal ' + CAST(sdh.source_deal_header_id AS VARCHAR),''
			--select *
			 FROM source_deal_header sdh 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
			INNER JOIN #tmp_final tf ON tf.generator = rg.code
				AND tf.[monthly term] = sdh.entire_term_start
			AND (
			SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc.gis_certificate_number_from)))+1 )
			= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
			AND	(
					CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
				)
			)
			WHERE sdd.volume_left < tf.volume
			AND sdd.buy_sell_flag ='b'
			AND sdh.assignment_type_value_id IS NULL
			AND sdh.close_reference_id IS NULL
			
			 
			
			
			--INSERT INTO source_system_data_import_status
   -- 			  (
   -- 				[source],
   -- 				process_id,
   -- 				code,
   -- 				module,
   -- 				[type],
   -- 				[description],
   -- 				recommendation
   -- 			  )
			--SELECT DISTINCT tf.generator,
			--	@process_id,
			--	'Error',
			--	'Import WREGIS RPS Upload',
			--	'Error',
			--	'RECS for ' + tf.generator + ' for term ' + tf.[monthly term] + ' have already been assigned for ' + sdv.code ,''
			----select *
			-- FROM source_deal_header sdh 
			--INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			--INNER JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
			--LEFT JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd.source_deal_detail_id
			--INNER JOIN Gis_Certificate gc_assign ON gc_assign.source_deal_header_id = aa.source_deal_header_id
			--INNER JOIN static_data_value sdv ON sdv.value_id = aa.assignment_type
			--INNER JOIN #tmp_final tf ON tf.generator = rg.code
			--	AND tf.[monthly term] = sdh.entire_term_start
			--	AND (
			--	SUBSTRING(ISNULL(gc.gis_certificate_number_from,[cert from]),0,LEN(ISNULL(gc.gis_certificate_number_from,[cert from]))-(CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from]))))+1 )
			--	= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
			--	AND	(
			--			CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
			--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0))) AS INT)
			--				AND CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0))) AS INT)
			--			AND CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
			--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0))) AS INT)
			--				AND CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0))) AS INT)
			--		)
			--	)
			--WHERE sdd.buy_sell_flag ='b'
			--AND sdh.assignment_type_value_id IS NULL
			--AND sdh.close_reference_id IS NULL
			----AND tf.generator IS NOT NULL
			--AND CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT)  BETWEEN gc_assign.certificate_number_from_int AND gc_assign.certificate_number_to_int
			--OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT)  BETWEEN gc_assign.certificate_number_from_int AND gc_assign.certificate_number_to_int
			
			
			
			DECLARE @error_flag INT, @success_flag INT
			
			SET @error_flag = 0
			SET @success_flag = 0
			
			IF EXISTS( SELECT 1 FROM source_deal_header sdh 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			LEFT JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
			INNER JOIN #tmp_final tf ON tf.generator = rg.code
				AND tf.[monthly term] = sdh.entire_term_start
			AND (
			SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc.gis_certificate_number_from)))+1 )
			= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
			AND	(
					CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
				)
			)
			WHERE sdd.volume_left < tf.volume
			AND sdd.buy_sell_flag ='b'
			AND sdh.assignment_type_value_id IS NULL
			AND sdh.close_reference_id IS NULL
			 )
				SET @error_flag = 1
				
			IF EXISTS(SELECT 1 FROM #tmp_final td  
			WHERE (CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) -
			CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) + 1) <> volume
			)
			SET @error_flag = 1
			
			--IF EXISTS(SELECT 1 FROM source_deal_header sdh 
			--INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			--INNER JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
			----LEFT JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd.source_deal_detail_id
			----INNER JOIN Gis_Certificate gc_assign ON gc_assign.source_deal_header_id = aa.source_deal_header_id
			----INNER JOIN static_data_value sdv ON sdv.value_id = aa.assignment_type
			--INNER JOIN #tmp_final tf ON tf.generator = rg.code
			--	AND tf.[monthly term] = sdh.entire_term_start
			--	AND (
			--	SUBSTRING(ISNULL(gc.gis_certificate_number_from,[cert from]),0,LEN(ISNULL(gc.gis_certificate_number_from,[cert from]))-(CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from]))))+1 )
			--	= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
			--	AND	(
			--			CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
			--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0))) AS INT)
			--				AND CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0))) AS INT)
			--			OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
			--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0))) AS INT)
			--				AND CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0))) AS INT)
			--		)
			--	)
			--WHERE sdd.buy_sell_flag ='b'
			--AND sdh.assignment_type_value_id IS NULL
			--AND sdh.close_reference_id IS NULL
			----AND tf.generator IS NOT NULL
			----AND CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT)  BETWEEN gc_assign.certificate_number_from_int AND gc_assign.certificate_number_to_int
			----OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT)  BETWEEN gc_assign.certificate_number_from_int AND gc_assign.certificate_number_to_int
			
			--)
			--SET @error_flag = 1
			
			IF EXISTS(select 1 from #tmp_final tf
			INNER JOIN rec_generator rg ON rg.code = tf.generator
			INNER JOIN source_deal_header sdh ON sdh.entire_term_start = tf.[monthly term]
				AND sdh.generator_id = rg.generator_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				 AND (
			SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc.gis_certificate_number_from)))+1 )
			<> SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
			OR	(
					CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) NOT BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) NOT BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
				)
		)
			WHERE 1=1 
			AND sdh.deal_id not like '%assigned%'
			GROUP BY tf.generator, tf.[monthly term])
				SET @error_flag = 1
				
			IF EXISTS(select 1 from #tmp_final tf
			LEFT JOIN rec_generator rg ON rg.code = tf.generator
			LEFT JOIN source_deal_header sdh ON sdh.entire_term_start = tf.[monthly term]
				AND sdh.generator_id = rg.generator_id
			LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
			--AND (
			--SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc.gis_certificate_number_from)))+1 )
			--= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
			--AND	(
			--		CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
			--		CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
			--			AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
			--		OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
			--		CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
			--			AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
			--	)
			--)
			WHERE 1=1 AND ( sdh.entire_term_start IS NULL OR rg.code IS NULL OR gc.gis_certificate_number_from IS NULL OR tf.[cert from] IS NULL
			)
			GROUP BY tf.generator, tf.[monthly term])
				SET @error_flag = 1
				
		IF EXISTS(SELECT 1 FROM source_deal_header sdh 
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd.source_deal_detail_id
		--INNER JOIN Gis_Certificate gc_assign ON gc_assign.source_deal_header_id = aa.source_deal_header_id
		INNER JOIN #tmp_final tf ON tf.generator = rg.code
			AND tf.[monthly term] = sdh.entire_term_start
			AND (
			SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc.gis_certificate_number_from)))+1 )
			= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
			AND	(
					CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
				)
			)
		LEFT JOIN (select * from static_data_value where type_id = 10002) sdv ON sdv.code = tf.[state]
		WHERE 1=1
		AND sdv.code IS  NULL )
			SET @error_flag = 1
				
		IF EXISTS( SELECT 1	 FROM source_deal_header sdh 
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd.source_deal_detail_id
		--INNER JOIN Gis_Certificate gc_assign ON gc_assign.source_deal_header_id = aa.source_deal_header_id
		INNER JOIN #tmp_final tf ON tf.generator = rg.code
			AND tf.[monthly term] = sdh.entire_term_start
			 AND (
			SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc.gis_certificate_number_from)))+1 )
			= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
			AND	(
					CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
				)
			)
		INNER JOIN (select * from static_data_value where type_id = 10002) sdv ON sdv.code = tf.[state]
		WHERE sdd.volume_left >= tf.volume
		AND (CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) -
			CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) + 1) = volume
		AND sdd.buy_sell_flag ='b'
		AND sdh.assignment_type_value_id IS NULL
		AND sdh.close_reference_id IS NULL
		--AND CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) NOT BETWEEN gc_assign.certificate_number_from_int AND gc_assign.certificate_number_to_int
		--AND CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) NOT BETWEEN gc_assign.certificate_number_from_int AND gc_assign.certificate_number_to_int
		)
			SET @success_flag = 1
			
			--GROUP BY sdh.source_deal_header_id, tf.[monthly term],tf.generator

--select * from #tmp_final
	--	--SELECT distinct sdh.source_deal_header_id,tf.volume, sdd.volume_left
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
		SELECT DISTINCT 'WREGIS',
			@process_id,
			'Error',
			'Import WREGIS RPS Upload',
			'Error',
			'The jurisdictions ' + tf.[state] + ' does not exist in the system',
			''
		--select tf.[state],*
		 FROM source_deal_header sdh 
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd.source_deal_detail_id
		--INNER JOIN Gis_Certificate gc_assign ON gc_assign.source_deal_header_id = aa.source_deal_header_id
		INNER JOIN #tmp_final tf ON tf.generator = rg.code
			AND tf.[monthly term] = sdh.entire_term_start
			AND (
			SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc.gis_certificate_number_from)))+1 )
			= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
			AND	(
					CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
				)
			)
		LEFT JOIN (select * from static_data_value where type_id = 10002) sdv ON sdv.code = tf.[state]
		WHERE 1=1
		AND sdv.code IS  NULL
		
		
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
		SELECT DISTINCT 'WREGIS',
			@process_id,
			'Success',
			'Import WREGIS RPS Upload',
			'Success',
			'WREGIS RPS for generator ' + tf.generator + ' for term ' + tf.[monthly term] + ', volume ' + (CAST(tf.volume AS VARCHAR)) + ' uploaded',
			''
		 FROM source_deal_header sdh 
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd.source_deal_detail_id
		--INNER JOIN Gis_Certificate gc_assign ON gc_assign.source_deal_header_id = aa.source_deal_header_id
		INNER JOIN #tmp_final tf ON tf.generator = rg.code
			AND tf.[monthly term] = sdh.entire_term_start
			AND (
			SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc.gis_certificate_number_from)))+1 )
			= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
			AND	(
					CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
				)
			)
		INNER JOIN (select * from static_data_value where type_id = 10002) sdv ON sdv.code = tf.[state]
		WHERE sdd.volume_left >= tf.volume
		AND (CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) -
			CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) + 1) = volume
		AND sdd.buy_sell_flag ='b'
		AND sdh.assignment_type_value_id IS NULL
		AND sdh.close_reference_id IS NULL
		--AND CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) NOT BETWEEN gc_assign.certificate_number_from_int AND gc_assign.certificate_number_to_int
		--AND CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) NOT BETWEEN gc_assign.certificate_number_from_int AND gc_assign.certificate_number_to_int
		
		--INSERT INTO source_system_data_import_status
  --  	      (
  --  	        [source],
  --  	        process_id,
  --  	        code,
  --  	        module,
  --  	        [type],
  --  	        [description],
  --  	        recommendation
  --  	      )
		--SELECT tf.generator,
		--		@process_id,
		--		'Error',
		--		'Import WREGIS RPS Upload',
		--		'Error',
		--		'REC does not have enough volume to assign deal.',
		--		''
		-- FROM source_deal_header sdh 
		--	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		--	LEFT JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
		--	INNER JOIN #tmp_final tf ON tf.generator = rg.code
		--		AND tf.[monthly term] = sdh.entire_term_start
		--		 AND (
		--	SUBSTRING(ISNULL(gc.gis_certificate_number_from,[cert from]),0,LEN(ISNULL(gc.gis_certificate_number_from,[cert from]))-(CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from]))))+1 )
		--	= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
		--	AND	(
		--			CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
		--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0))) AS INT)
		--				AND CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0))) AS INT)
		--			AND CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
		--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0))) AS INT)
		--				AND CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0))) AS INT)
		--		)
		--)
		--	WHERE sdd.volume_left < tf.volume
		--	AND sdd.buy_sell_flag ='b'
		--	AND sdh.assignment_type_value_id IS NULL
		--	AND sdh.close_reference_id IS NULL
			
		
		--select * from #tmp_final
		
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
			SELECT DISTINCT 'WREGIS',
				@process_id,
				'Error',
				'Import WREGIS RPS Upload',
				'Error',
				'WREGIS RECs for generator ' + td.generator + ' failed . Certificate should match volume.',
				''
			FROM #tmp_final td  
			WHERE (CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) -
			CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) + 1) <> volume
			
			--select * from #tmp_final
			
			--update #tmp_final set [cert from] = '801-NM-100733-151',[cert to] = '801-NM-100733-200'
			
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
		SELECT DISTINCT 'WREGIS',
			@process_id,
			'Error',
			'Import WREGIS RPS Upload',
			'Error',
			'The listed certficates for RPS Compliance: ' + tf.generator + ' for term ' + tf.[monthly term] + ' have already been assigned',
			''
			--select tf.generator, tf.[monthly term],sdh.source_deal_header_id,CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) 
				--,gc.*	,CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0))) AS INT)
				--	, CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0))) AS INT)
			--,gc.source_certificate_number,gc.source_deal_header_id, sdd.source_deal_detail_id
			--select *
			from #tmp_final tf
			INNER JOIN rec_generator rg ON rg.code = tf.generator
			INNER JOIN source_deal_header sdh ON sdh.entire_term_start = tf.[monthly term]
				AND sdh.generator_id = rg.generator_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
			INNER JOIN (select * from static_data_value where type_id = 10002) sdv ON sdv.code = tf.[state]
			WHERE 1=1 
			AND sdd.volume_left >= tf.volume
			AND (CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) -
			CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) + 1) = volume
			AND (
			SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc.gis_certificate_number_from)))+1 )
			= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
			AND	(
					CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
				)
			)
			AND sdh.deal_id like '%assigned%'
			GROUP BY tf.generator, tf.[monthly term]
		
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
		SELECT DISTINCT 'WREGIS',
			@process_id,
			'Error',
			'Import WREGIS RPS Upload',
			'Error',
			'Listed RECs does not exist for RPS Compliance: ' + tf.generator + ' for term ' + tf.[monthly term],
			''
			--select tf.generator, tf.[monthly term],sdh.source_deal_header_id,CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) ,
					--CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_from,[cert from])),0))) AS INT)
					--	, CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0,CHARINDEX('-',REVERSE(ISNULL(gc.gis_certificate_number_to,[cert to])),0))) AS INT)
			--,gc.source_certificate_number,gc.source_deal_header_id, sdd.source_deal_detail_id
			--select *
			from #tmp_final tf
			LEFT JOIN rec_generator rg ON rg.code = tf.generator
			LEFT JOIN source_deal_header sdh ON sdh.entire_term_start = tf.[monthly term]
				AND sdh.generator_id = rg.generator_id
			LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
			--AND (
			--SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc.gis_certificate_number_from)))+1 )
			--= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
			--AND	(
			--		CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
			--		CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
			--			AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
			--		OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
			--		CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
			--			AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
			--	)
			--)
			WHERE 1=1 AND ( sdh.entire_term_start IS NULL OR rg.code IS NULL OR gc.gis_certificate_number_from IS NULL OR tf.[cert from] IS NULL
			)
			GROUP BY tf.generator, tf.[monthly term]
			
			--select @success_flag, @error_flag
			

	EXEC spa_assign_rec_deals
	NULL,
	5146, -- Assignment_type
	NULL,-- static_data_value for the state
	@compliance_year, -- compliance year from the file
	@assigned_date, -- year end of complaince year
	NULL,
	NULL,
	NULL,
	@process_table,
	0, NULL, NULL, NULL, NULL, NULL, NULL, NULL ,NULL ,NULL,
	@template_id,NULL,0,NULL,0,
	@call_from_old = 2,
	@inserted_source_deal_header_id = @inserted_source_deal_header_id OUTPUT
	

--select * from #tmp_final
--commit
--return
				
				INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date)
				select sdd.source_deal_detail_id, tf.[cert from], tf.[cert to], REVERSE(SUBSTRING(REVERSE(tf.[cert from]),0,CHARINDEX('-',REVERSE(tf.[cert from]),0))),
				REVERSE(SUBSTRING(REVERSE(tf.[cert to]),0,CHARINDEX('-',REVERSE(tf.[cert to]),0))),
				GETDATE()
				--select *
				FROM source_deal_header sdh 
				INNER JOIN dbo.SplitCommaSeperatedValues(@inserted_source_deal_header_id) scsv ON scsv.item = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_header sdh_org on sdh_org.source_deal_header_id = sdh.ext_deal_id
				INNER JOIN source_deal_detail sdd_org on sdd_org.source_deal_header_id = sdh_org.source_deal_header_id
				INNER JOIN (select  max(gis_certificate_number_from) gis_certificate_number_from, max(gis_certificate_number_to) gis_certificate_number_to
				, source_deal_header_id  from gis_certificate group by source_deal_header_id) gc_org on gc_org.source_deal_header_id = sdd_org.source_deal_detail_id
				INNER JOIN rec_generator rg on rg.generator_id=sdh.generator_id 
				INNER JOIN (select generator, [monthly term], [cert from], MAX([cert to]) [cert to], [compliance YEAR]
				FROM #tmp_final GROUP BY generator, [monthly term], [cert from], [compliance YEAR]) tf ON tf.generator = rg.code
					AND sdh.entire_term_start = tf.[monthly term] 
					 AND (
					SUBSTRING(gc_org.gis_certificate_number_from,0,LEN(gc_org.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc_org.gis_certificate_number_from)))+1 )
					= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
					AND	(
							CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) BETWEEN 
							CAST(REVERSE(SUBSTRING(REVERSE(gc_org.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc_org.gis_certificate_number_from),0))) AS INT)
								AND CAST(REVERSE(SUBSTRING(REVERSE(gc_org.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc_org.gis_certificate_number_to),0))) AS INT)
							OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) BETWEEN
							CAST(REVERSE(SUBSTRING(REVERSE(gc_org.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc_org.gis_certificate_number_from),0))) AS INT)
								AND CAST(REVERSE(SUBSTRING(REVERSE(gc_org.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc_org.gis_certificate_number_to),0))) AS INT)
						)
				)
				
				--select * from #tmp_final
				--SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )+'-'+ 
				
				
				--INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date)
					CREATE TABLE #gis_certificate(source_deal_header_id INT
						, state_value_id INT
						, gis_certificate_number_from VARCHAR(100) COLLATE DATABASE_DEFAULT  
						, gis_certificate_number_to VARCHAR(100) COLLATE DATABASE_DEFAULT 
						, certificate_number_from_int FLOAT
						, certificate_number_to_int FLOAT
						, gis_cert_date DATETIME)
					
					INSERT INTO #gis_certificate(source_deal_header_id, state_value_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date)
					select sdd.source_deal_detail_id, sdv.value_id, SUBSTRING(tf.[cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )+'-'+ 
					CASE WHEN CAST(REVERSE(SUBSTRING(REVERSE(tf.[cert to]),0,CHARINDEX('-',REVERSE(tf.[cert to]),0))) AS INT) >= gc.certificate_number_to_int
					THEN '0' ELSE CAST(CAST(REVERSE(SUBSTRING(REVERSE(tf.[cert to]),0,CHARINDEX('-',REVERSE(tf.[cert to]),0))) AS INT)+1 AS VARCHAR) END,
					SUBSTRING(tf.[cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )+'-'+ 
					CASE WHEN CAST(REVERSE(SUBSTRING(REVERSE(tf.[cert to]),0,CHARINDEX('-',REVERSE(tf.[cert to]),0))) AS INT) >= gc.certificate_number_to_int
					THEN '0' ELSE CAST(gc.certificate_number_to_int AS VARCHAR) END,
					CASE WHEN CAST(REVERSE(SUBSTRING(REVERSE(tf.[cert to]),0,CHARINDEX('-',REVERSE(tf.[cert to]),0))) AS INT) >= gc.certificate_number_to_int
					THEN '0' ELSE CAST(CAST(REVERSE(SUBSTRING(REVERSE(tf.[cert to]),0,CHARINDEX('-',REVERSE(tf.[cert to]),0))) AS INT)+1 AS FLOAT) END,
					CASE WHEN CAST(REVERSE(SUBSTRING(REVERSE(tf.[cert to]),0,CHARINDEX('-',REVERSE(tf.[cert to]),0))) AS INT) >= gc.certificate_number_to_int
					THEN '0' ELSE gc.certificate_number_to_int END, GETDATE()
					 --select sdd.volume_left,gc.*
					 from source_deal_header sdh
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
					INNER JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					INNER JOIN (select generator, [monthly term], MAX(volume) volume, [cert from], MAX([cert to]) [cert to], [compliance YEAR], MAX([state]) [state]
					FROM #tmp_final GROUP BY generator, [monthly term], [cert from], [compliance YEAR]
								) tf ON tf.generator = rg.code
								AND sdh.entire_term_start = tf.[monthly term]
								 AND (
								SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc.gis_certificate_number_from)))+1 )
								= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
									AND	(
											CAST(REVERSE(SUBSTRING(REVERSE(tf.[cert from]),0,CHARINDEX('-',REVERSE(tf.[cert from]),0))) AS INT) BETWEEN 
											CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
												AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
											OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE(tf.[cert to]),0))) AS INT) BETWEEN
											CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
												AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
										)
								)
					INNER JOIN #identified_deals id ON id.source_deal_header_id = sdh.source_deal_header_id
					
					INNER JOIN (select * from static_data_value where type_id = 10002) sdv ON sdv.code = tf.[state]
					WHERE sdh.deal_id not like '%assigned%'
					--AND sdd.volume_left >= tf.volume
					AND (CAST(REVERSE(SUBSTRING(REVERSE(tf.[cert to]),0,CHARINDEX('-',REVERSE(tf.[cert to]),0))) AS INT) -
					CAST(REVERSE(SUBSTRING(REVERSE(tf.[cert from]),0,CHARINDEX('-',REVERSE(tf.[cert from]),0))) AS INT) + 1) = tf.volume
					
					--select * from #tmp_final
					
					DELETE gc from source_deal_header sdh
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
					INNER JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					INNER JOIN (select generator, [monthly term],  MAX(volume) volume, [cert from], MAX([cert to]) [cert to], [compliance YEAR], MAX([state]) [state]
					FROM #tmp_final GROUP BY generator, [monthly term], [cert from], [compliance YEAR]) tf ON tf.generator = rg.code
						AND sdh.entire_term_start = tf.[monthly term]
					 AND (
								SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc.gis_certificate_number_from)))+1 )
								= SUBSTRING([cert from],0,LEN(tf.[cert from])-(CHARINDEX('-',REVERSE(tf.[cert from])))+1 )
									AND	(
											CAST(REVERSE(SUBSTRING(REVERSE(tf.[cert from]),0,CHARINDEX('-',REVERSE(tf.[cert from]),0))) AS INT) BETWEEN 
											CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
												AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
											OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE(tf.[cert to]),0))) AS INT) BETWEEN
											CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
												AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
										)
								)
					INNER JOIN #identified_deals id ON id.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN (select * from static_data_value where type_id = 10002) sdv ON sdv.code = tf.[state]
					WHERE sdh.deal_id not like '%assigned%'
					--AND sdd.volume_left >= tf.volume
					AND (CAST(REVERSE(SUBSTRING(REVERSE(tf.[cert to]),0,CHARINDEX('-',REVERSE(tf.[cert to]),0))) AS INT) -
					CAST(REVERSE(SUBSTRING(REVERSE(tf.[cert from]),0,CHARINDEX('-',REVERSE(tf.[cert from]),0))) AS INT) + 1) = tf.volume
					
					INSERT INTO gis_certificate(source_deal_header_id, state_value_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date)
					SELECT source_deal_header_id, state_value_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date FROM #gis_certificate
				
					
	--			--INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date)
	--			--select sdd.source_deal_detail_id, [cert from], [cert to], REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))),
	--			--REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))),
	--			--GETDATE()
	--			--FROM source_deal_header sdh 
	--			--INNER JOIN #deal_header dh ON dh.source_deal_header_id = sdh.source_deal_header_id
	--			--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	--			--INNER JOIN rec_generator rg on rg.generator_id=sdh.generator_id 
	--			--INNER JOIN (select generator, [monthly term], MAX([cert from]) [cert from], MAX([cert to]) [cert to]
	--			--FROM #tmp_final GROUP BY generator, [monthly term]) tf ON tf.generator = rg.id
	--			--	AND sdh.entire_term_start = tf.[monthly term] 
					
	--			--IF @inserted_source_deal_header_id IS NOT NULL 
	--			--BEGIN 
	--			--	exec spa_sourcedealheader 'd',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	--			--	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,@process_id2
	--			--END 
				
			
		COMMIT 
		--ROLLBACK 
		
		


	--DECLARE @url VARCHAR(MAX)
			
	SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id +
		   '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id 
		   + ''''
	--DECLARE @elapsed_sec float 
	      
	 SET @elapsed_sec = DATEDIFF(second, @start_ts, GETDATE())
	 
	IF(@error_flag = 1 AND @success_flag = 1)
	BEGIN
	SELECT @desc = '<a target="_blank" href="' + @url + '">'+'<font color="red">' +
	   'WREGIS RPS Uploaded with errors' + '</font>' + '</a>'+ ' '+
	   '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(1000)) + ' sec </a>'
	  SET @error_code = 'e'
	END
	ELSE IF(@error_flag = 0 AND @success_flag = 1)
	BEGIN
	SELECT @desc = '<a target="_blank" href="' + @url + '">' +
	   'WREGIS RPS Uploaded' +'</a>'+ ' '+
	   '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(1000)) + ' sec </a>'
	  SET @error_code = 's'
	END
	ELSE IF(@error_flag = 1 AND @success_flag = 0)
	BEGIN
	SELECT @desc = '<a target="_blank" href="' + @url + '">' + '<font color="red">'+
	   'WREGIS RPS Upload Failed' + '</font>' + '</a>'+ ' '+
	   '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(1000)) + ' sec </a>'
	  SET @error_code = 'e'
	END

	END TRY
	BEGIN CATCH
		SET @error_msg  = 'error' + ERROR_MESSAGE()
		EXEC spa_print @error_msg
		SET @error_code = 'e'
		SET @desc ='Unable to complete WREGIS RPS Upload'
		ROLLBACK 
	END CATCH
	
	

	EXEC spa_NotificationUserByRole 2, @process_id, 'WREGIS RPS Upload', @desc , @error_code, @job_name, 1

	--updating using flag 'e' which automatically calculate the estimated time.
	EXEC spa_import_data_files_audit
		 @flag = 'e',
		 @process_id = @process_id,
		 @status = @error_code
		 
END -- SOLD/TRANSFER UPLOAD
ELSE IF EXISTS (SELECT * FROM TempDB.INFORMATION_SCHEMA.COLUMNS WHERE  TABLE_NAME like '%#tmp_dff%' and COLUMN_NAME = 'Transferor' )

BEGIN
	
	
IF OBJECT_ID('tempdb.dbo.#tmp_dff2') IS NOT NULL
DROP TABLE #tmp_dff2

CREATE TABLE #tmp_dff2 (generator VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[monthly term] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		volume VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		assigned_date VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		counterparty VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		desc1 VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		 desc2 VARCHAR(1000) COLLATE DATABASE_DEFAULT, 
		 desc3 VARCHAR(1000) COLLATE DATABASE_DEFAULT 
		)

EXEC('INSERT INTO #tmp_dff2(generator , [monthly term] , volume, assigned_date, counterparty, desc1, desc2, desc3)
SELECT [wregis_gu_id], [Year]+''/''+[Month]+''/1'', Quantity, [date_transfer], transferee, [login_name], transferor, [transaction_id] 
FROM '+@temp_table_name)

CREATE TABLE #tmp_dff5 (generator VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[monthly term] VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		volume VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		assigned_date VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		counterparty VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		desc1 VARCHAR(1000) COLLATE DATABASE_DEFAULT, 
		desc2 VARCHAR(1000) COLLATE DATABASE_DEFAULT, 
		desc3 VARCHAR(1000) COLLATE DATABASE_DEFAULT
		)

--return

--INSERT INTO #tmp_dff5( generator , [monthly term] , volume , assigned_date , counterparty, desc1, desc2, desc3)
--SELECT  MAX(generator) generator, MAX([monthly term]) [monthly term], SUM(volume) volume, MAX(assigned_date) , MAX(counterparty), MAX(desc1), MAX(desc2), MAX(desc3) 
-- FROM (
--SELECT  td.generator , td.[monthly term] , (CAST(td.volume AS FLOAT)) volume,
-- td.assigned_date , td.counterparty, td.desc1, td.desc2, td.desc3 
----select td.*
--FROM #tmp_dff2 td
--INNER JOIN #tmp_dff2 td2 ON td2.[monthly term] = td.[monthly term] AND td2.generator = td.generator
--UNION 
--SELECT  td2.generator , td2.[monthly term] , (CAST(td2.volume AS FLOAT)) volume ,
-- td2.assigned_date , td2.counterparty, td2.desc1, td2.desc2, td2.desc3
----select td.*
--FROM #tmp_dff2 td
--INNER JOIN #tmp_dff2 td2 ON td2.[monthly term] = td.[monthly term] AND td2.generator = td.generator

--) a
--GROUP BY generator, [monthly term]


--DELETE td FROM #tmp_dff2 td INNER JOIN ( 
--SELECT  td.generator , td.[monthly term] , (CAST(td.volume AS FLOAT)) volume
----select td.*
--FROM #tmp_dff2 td
--INNER JOIN #tmp_dff2 td2 ON td2.[monthly term] = td.[monthly term] AND td2.generator = td.generator
--) a ON td.generator = a.generator AND td.[monthly term] = a.[monthly term] 


INSERT INTO #tmp_dff5(generator , [monthly term] , volume , assigned_date , counterparty, desc1, desc2, desc3)
SELECT  generator , [monthly term] , volume , assigned_date , counterparty, desc1, desc2, desc3 FROM #tmp_dff2


--select * from #tmp_dff2
--select * from #tmp_final2

IF OBJECT_ID('tempdb.dbo.#tmp_final2') IS NOT NULL
	DROP TABLE #tmp_final2

	SELECT generator , [monthly term] , MAX(volume) volume, MAX(assigned_date) assigned_date, MAX(counterparty) counterparty, 
	MAX(desc1) desc1, MAX(desc2) desc2, MAX(desc3) desc3
	 --[member] , MAX([percentage]) [percentage] , 
	
	INTO #tmp_final2 FROM #tmp_dff5 GROUP BY generator, [monthly term]
	
	IF OBJECT_ID('tempdb.dbo.#identified_deals2') IS NOT NULL
	DROP TABLE #identified_deals2
	--select * from #identified_deals2
	SELECT MAX(sdh.entire_term_start) entire_term_start,
	MAX(sc.source_counterparty_id) counterparty, MAX(tf.assigned_date) assigned_date, MAX(tf.desc1) desc1, MAX(tf.desc2) desc2, MAX(tf.desc3) desc3, MAX(sdh.source_deal_header_id) source_deal_header_id, MAX(sdd.source_deal_detail_id) source_deal_detail_id, MAX(sdd.settlement_uom) settlement_uom, MAX(sdd.deal_volume_uom_id) deal_volume_uom_id,
	MAX(tf.volume) volume , MAX(rg.fas_book_id) [book_deal_type_map_id]
	INTO #identified_deals2
	--SELECT  rg.code,tf.*
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	--INNER JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
	
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	CROSS APPLY(
		SELECT  Volume, counterparty, assigned_date, desc1, desc2, desc3, tf.generator, tf.[monthly term]
		FROM #tmp_final2 tf
		WHERE tf.generator = rg.code 
			AND sdh.entire_term_start = tf.[monthly term]
		) tf
	INNER JOIN source_counterparty sc ON sc.counterparty_name = tf.counterparty
	WHERE
		sdd.buy_sell_flag ='b'
		AND sdh.assignment_type_value_id IS NULL
		AND sdh.close_reference_id IS NULL
		--AND tf.[cert FROM] IS NOT NULL
		AND sdd.volume_left >= tf.volume
	GROUP BY tf.generator, tf.[monthly term]
		
	DECLARE @error_flag2 INT, @success_flag2 INT
			
			SET @error_flag2 = 0
			SET @success_flag2 = 0
		
	IF NOT EXISTS(SELECT sc.counterparty_name , tf.counterparty FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	CROSS APPLY(
		SELECT  Volume, counterparty, assigned_date, desc1, desc2, desc3
		FROM #tmp_final2 tf
		WHERE tf.generator = rg.code 
			AND sdh.entire_term_start = tf.[monthly term]
		) tf
	INNER JOIN source_counterparty sc ON sc.counterparty_name = tf.counterparty
		)
		SET @error_flag2 = 1
		
	DECLARE @wrong_counterparty VARCHAR(8000)
	
	SELECT @wrong_counterparty = ISNULL(@wrong_counterparty,'')+ CASE WHEN @wrong_counterparty IS NULL THEN '' ELSE ';' END + tf.counterparty 
		FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	CROSS APPLY(
		SELECT  Volume, counterparty, assigned_date, desc1, desc2, desc3
		FROM #tmp_final2 tf
		WHERE tf.generator = rg.code 
			AND sdh.entire_term_start = tf.[monthly term]
		) tf
	LEFT JOIN source_counterparty sc ON sc.counterparty_name = tf.counterparty
	WHERE sc.source_counterparty_id IS NULL
	group by tf.counterparty
	

		
	IF @wrong_counterparty IS NOT NULL
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
		SELECT DISTINCT 'WREGIS',
			@process_id,
			'Error',
			'Import WREGIS RPS Upload',
			'Error',
			'Listed counterparty does not exist for SOLD/Transfer: ' + @wrong_counterparty
			,''
			
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
				SELECT 'Non-Existing Counterparty List',
				@process_id,
				'Error',
				'Import WREGIS REC Upload',
				'Error',
				'List of Non-Existing Counterparties Import Format',
				''
			
		INSERT INTO source_system_data_import_status_counterparty_detail(
			process_id,
			source,
			[type],
			Counterparty_Id,
			[Counterparty_Name],
			[Counterparty Type],
			[Entity Type],
			[Counterparty_Description],
			[Parent Counterparty],
			[Dun #],
			[Tax ID],
			[Contact Title],
			[Contact Name] ,
			[Contact Address 1],
			[Contact Address 2],
			[Contact City],
			[Contact State],
			[Contact Zip],
			[Contact Phone No],
			[Contact Fax],
			[Contact Email]   
		)
		SELECT	@process_id,
				'Non-Existing Counterparty List',
				'Error',
				NULL,
				scsv.item,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL
				FROM dbo.SplitByPassedParameterSeperatedValues(@wrong_counterparty,';') scsv
		
	END
		
	DECLARE @process_table2 VARCHAR(300)
	--SET @process_id=dbo.FNAGetNewID()
	SET @process_table2 = dbo.FNAProcessTableName('process_table', @user_login_id,@process_id)

	SET @sql = 'CREATE TABLE ' + @process_table2 + '([ID] INT,[Volume Assign] float, uom int,  book_deal_type_map_id INT, assigned_date datetime, counterparty INT,
	desc1 VARCHAR(100), desc2 VARCHAR(100), desc3 VARCHAR(100))'
	EXEC spa_print @sql
	EXEC(@sql)


	set @sql = 'INSERT INTO ' + @process_table2 + '
	([ID], [Volume Assign],  uom,  book_deal_type_map_id, assigned_date, counterparty, desc1, desc2, desc3 ) 
	select source_deal_detail_id, volume, deal_volume_uom_id, book_deal_type_map_id, assigned_date, counterparty, desc1, desc2, desc3
	from #identified_deals2 '
	EXEC spa_print @sql
	EXEC(@sql)
	
	BEGIN TRAN
	--BEGIN TRY 

	DECLARE  @inserted_source_deal_header_id2 VARCHAR(MAX),
	 @inserted_source_deal_detail_id2 VARCHAR(MAX), @book_deal_type_map_id2 INT 
	

	SELECT @book_deal_type_map_id2 = fas_book_id from rec_generator rg INNER JOIN #tmp_final2 tf ON rg.code = tf.generator

	IF EXISTS( SELECT 1 FROM source_deal_header sdh 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			LEFT JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
			INNER JOIN #tmp_final2 tf ON tf.generator = rg.code
				AND tf.[monthly term] = sdh.entire_term_start
			WHERE sdd.volume_left < tf.volume
			AND sdd.buy_sell_flag ='b'
			AND sdh.assignment_type_value_id IS NULL
			AND sdh.close_reference_id IS NULL
			)
				SET @error_flag2 = 1
				
			IF EXISTS(select 1 from #tmp_final2 tf
			LEFT JOIN rec_generator rg ON rg.code = tf.generator
			LEFT JOIN source_deal_header sdh ON sdh.entire_term_start = tf.[monthly term]
				AND sdh.generator_id = rg.generator_id
			LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			WHERE 1=1 AND ( sdh.entire_term_start IS NULL OR rg.code IS NULL)
			GROUP BY tf.generator, tf.[monthly term])
				SET @error_flag2= 1
				
			IF EXISTS( SELECT 1	 FROM source_deal_header sdh 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #tmp_final2 tf ON tf.generator = rg.code
				AND tf.[monthly term] = sdh.entire_term_start
			INNER JOIN source_counterparty sc ON sc.counterparty_name = tf.counterparty
			WHERE sdd.volume_left >= tf.volume
			AND sdd.buy_sell_flag ='b'
			AND sdh.assignment_type_value_id IS NULL
			AND sdh.close_reference_id IS NULL
			)
			SET @success_flag2 = 1
			
			--IF NOT EXISTS( SELECT 1	 FROM source_deal_header sdh 
			--INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			--INNER JOIN #tmp_final2 tf ON tf.generator = rg.code
			--	AND tf.[monthly term] = sdh.entire_term_start
			--INNER JOIN source_counterparty sc ON sc.counterparty_name = tf.counterparty
			--WHERE sdd.volume_left >= tf.volume
			--AND sdd.buy_sell_flag ='b'
			--AND sdh.assignment_type_value_id IS NULL
			--AND sdh.close_reference_id IS NULL
			--AND sdh.deal_id not like '%assigned%'
			--)
			--SET @error_flag2 = 1
				
			--GROUP BY sdh.source_deal_header_id, tf.[monthly term],tf.generator

	--	--SELECT distinct sdh.source_deal_header_id,tf.volume, sdd.volume_left
			--INSERT INTO source_system_data_import_status
   -- 			  (
   -- 				[source],
   -- 				process_id,
   -- 				code,
   -- 				module,
   -- 				[type],
   -- 				[description],
   -- 				recommendation
   -- 			  )
			--SELECT DISTINCT 'WREGIS',
			--@process_id,
			--'Error',
			--'Import WREGIS SOLD/Transfer Upload',
			--'Error',
			--'RECs for generator ' + tf.generator + ' for term ' + tf.[monthly term] + ' does not exist',
			--''
			-- FROM source_deal_header sdh 
			--INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			--INNER JOIN #tmp_final2 tf ON tf.generator = rg.code
			--	AND tf.[monthly term] = sdh.entire_term_start
			--INNER JOIN source_counterparty sc ON sc.counterparty_name = tf.counterparty
			--WHERE sdd.volume_left >= tf.volume
			----AND sdd.buy_sell_flag ='b'
			--AND sdh.assignment_type_value_id IS NULL
			--AND sdh.close_reference_id IS NULL
			--AND sdh.deal_id not like '%assigned%'
		 
--select * from #tmp_final2
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
		SELECT DISTINCT 'WREGIS',
			@process_id,
			'Success',
			'Import WREGIS SOLD/Transfer Upload',
			'Success',
			'WREGIS SOLD/Transfer for generator ' + tf.generator + ' for term ' + tf.[monthly term] + ', volume ' + (tf.volume) + ' uploaded',
			''
			--select sdd.term_start,sdh.assignment_type_value_id,sdd.source_deal_header_id,tf.*, sdd.deal_volume,sdd.volume_left
		 FROM source_deal_header sdh 
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
		INNER JOIN #tmp_final2 tf ON tf.generator = rg.code
			AND tf.[monthly term] = sdd.term_start
		WHERE 1=1
		and sdd.volume_left >= tf.volume
		AND sdd.buy_sell_flag ='b'
		AND sdh.assignment_type_value_id IS NULL
		AND sdh.close_reference_id IS NULL   
		
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
		SELECT DISTINCT 'WREGIS',
			@process_id,
			'Error',
			'Import WREGIS SOLD Transfer Upload',
			'Error',
			'Listed RECs does not exist for SOLD/Transfer: ' + tf.generator + ' for term ' + tf.[monthly term],
			''
			--select tf.generator, tf.[monthly term]
			--,gc.source_certificate_number,gc.source_deal_header_id, sdd.source_deal_detail_id
			from #tmp_final2 tf
			LEFT JOIN rec_generator rg ON rg.code = tf.generator
			LEFT JOIN source_deal_header sdh ON sdh.entire_term_start = tf.[monthly term]
				AND sdh.generator_id = rg.generator_id
			LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			WHERE 1=1 AND ( sdh.entire_term_start IS NULL OR rg.code IS NULL 
			)
			GROUP BY tf.generator, tf.[monthly term]
	


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
			SELECT DISTINCT 'WREGIS',
				@process_id,
				'Error',
				'Import WREGIS SOLD/Transfer Upload',
				'Error',
				'Inventory is not enough for SOLD/Transfer for listed certificates ' + tf.generator + ' for term ' + tf.[monthly term] + ' could not be imported
				as  volume ' + CAST((tf.volume) AS VARCHAR) + ' is greater than volume available of deal ' + CAST(sdh.source_deal_header_id AS VARCHAR),''
			--select *
			 FROM source_deal_header sdh 
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			LEFT JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
			INNER JOIN #tmp_final2 tf ON tf.generator = rg.code
				AND tf.[monthly term] = sdh.entire_term_start
			WHERE sdd.volume_left < tf.volume
			AND sdd.buy_sell_flag ='b'
			AND sdh.assignment_type_value_id IS NULL
			AND sdh.close_reference_id IS NULL
			
			
			
			--commit return
			
			
		--select @error_flag2,@success_flag2

	EXEC spa_assign_rec_deals
	NULL,
	5173, -- Assignment_type
	310401,	--type id 10002	CO-- static_data_value for the state
	NULL, -- compliance year from the file
	NULL, -- year end of complaince year
	NULL,
	NULL,
	NULL,
	@process_table2,
	0, NULL, NULL, NULL, NULL, NULL, NULL, NULL ,NULL ,NULL,
	@template_id,NULL,0,NULL,0,
	@call_from_old = 3,
	@inserted_source_deal_header_id = @inserted_source_deal_header_id OUTPUT
		
	

	--commit 
	--return
	
	--select 'EXEC spa_assign_rec_deals',
	--NULL,
	--5173, -- Assignment_type
	--293423,-- static_data_value for the state
	--NULL, -- compliance year from the file
	--NULL, -- year end of complaince year
	--NULL,
	--NULL,
	--NULL,
	--@process_table2,
	--0, NULL, NULL, NULL, NULL, NULL, NULL, NULL ,NULL ,NULL,
	--45,NULL,0,NULL,0,
	-- 3
	--select * from #tmp_final2

	IF EXISTS(SELECT 1 FROM  source_deal_header sdh 
				INNER JOIN dbo.SplitCommaSeperatedValues(@inserted_source_deal_header_id) scsv ON scsv.item = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN assignment_audit aa ON aa.source_deal_header_id = sdd.source_deal_detail_id
				INNER JOIN source_deal_detail sdd_org ON sdd_org.source_deal_detail_id = aa.source_deal_header_id_from
				INNER JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd_org.source_deal_detail_id
				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_detail_id = aa2.source_deal_header_id
				GROUP BY sdd.source_deal_header_id
				HAVING COUNT(sdd2.source_deal_header_id) > 1
				)
	BEGIN
		INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date)
		SELECT MAX(sdd.source_deal_detail_id), SUBSTRING(MAX(gc.gis_certificate_number_from),0,LEN(MAX(gc.gis_certificate_number_from))-(CHARINDEX('-',REVERSE(MAX(gc.gis_certificate_number_from))))+1 ) + '-' + CAST((max(gc.certificate_number_to_int) + 1) AS VARCHAR),
		SUBSTRING(MAX(gc.gis_certificate_number_from),0,LEN(MAX(gc.gis_certificate_number_from))-(CHARINDEX('-',REVERSE(MAX(gc.gis_certificate_number_from))))+1 ) + '-' + CAST((max(gc.certificate_number_to_int) + min(sdd.deal_volume)) AS VARCHAR)
		, max(gc.certificate_number_to_int) + 1, max(gc.certificate_number_to_int) + min(sdd.deal_volume), GETDATE() 
		FROM source_deal_header sdh 
		INNER JOIN dbo.SplitCommaSeperatedValues(@inserted_source_deal_header_id) scsv ON scsv.item = sdh.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN assignment_audit aa ON aa.source_deal_header_id = sdd.source_deal_detail_id
		INNER JOIN source_deal_detail sdd_org ON sdd_org.source_deal_detail_id = aa.source_deal_header_id_from
		INNER JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd_org.source_deal_detail_id
		INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_detail_id = aa2.source_deal_header_id
		LEFT JOIN Gis_Certificate gc ON gc.source_deal_header_id = sdd2.source_deal_detail_id
		INNER JOIN source_deal_header sdh2 ON sdh2.source_deal_header_id = sdd2.source_deal_header_id
		where aa2.assignment_ID <> aa.assignment_ID
		having max(aa2.assignment_ID) < min(aa.assignment_ID)
		ORDER BY max(aa2.assignment_ID)
	END
	ELSE
	BEGIN
		INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date)
		SELECT sdd.source_deal_detail_id, gc_org.gis_certificate_number_from, 
		SUBSTRING(gc_org.gis_certificate_number_from,0,LEN(gc_org.gis_certificate_number_from)-(CHARINDEX('-',REVERSE(gc_org.gis_certificate_number_from)))+1 ) + '-' + dbo.FNARemovetrailingzero(sdd.deal_volume)
		, gc_org.certificate_number_from_int,
		CAST(dbo.FNARemovetrailingzero(sdd.deal_volume) AS FLOAT),
		GETDATE()
		FROM source_deal_header sdh 
		INNER JOIN dbo.SplitCommaSeperatedValues(@inserted_source_deal_header_id) scsv ON scsv.item = sdh.source_deal_header_id
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_deal_header sdh_org on sdh_org.source_deal_header_id = sdh.ext_deal_id
		INNER JOIN source_deal_detail sdd_org on sdd_org.source_deal_header_id = sdh_org.source_deal_header_id
		INNER JOIN gis_certificate gc_org on gc_org.source_deal_header_id = sdd_org.source_deal_detail_id
		INNER JOIN rec_generator rg on rg.generator_id=sdh.generator_id 
		INNER JOIN (select generator, [monthly term]
		FROM #tmp_final2 GROUP BY generator, [monthly term]) tf ON tf.generator = rg.code
			AND sdh.entire_term_start = tf.[monthly term] 
			--AND ISNULL(gc_org.gis_certificate_number_from,'-1') = ISNULL(tf.[cert from],'-1')
	END
	
	COMMIT 
	
	
		
					
					
	--			--INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date)
	--			--select sdd.source_deal_detail_id, [cert from], [cert to], REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))),
	--			--REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))),
	--			--GETDATE()
	--			--FROM source_deal_header sdh 
	--			--INNER JOIN #deal_header dh ON dh.source_deal_header_id = sdh.source_deal_header_id
	--			--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	--			--INNER JOIN rec_generator rg on rg.generator_id=sdh.generator_id 
	--			--INNER JOIN (select generator, [monthly term], MAX([cert from]) [cert from], MAX([cert to]) [cert to]
	--			--FROM #tmp_final GROUP BY generator, [monthly term]) tf ON tf.generator = rg.id
	--			--	AND sdh.entire_term_start = tf.[monthly term] 
					
	--			--IF @inserted_source_deal_header_id IS NOT NULL 
	--			--BEGIN 
	--			--	exec spa_sourcedealheader 'd',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	--			--	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,@process_id2
	--			--END 
				
			
		
		--ROLLBACK 
		
		


	DECLARE @url2 VARCHAR(MAX)
			
	SELECT @url2 = './dev/spa_html.php?__user_name__=' + @user_login_id +
		   '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id 
		   + ''''
	DECLARE @elapsed_sec2 float 
	      
	 SET @elapsed_sec2 = DATEDIFF(second, @start_ts, GETDATE())
	 
	IF(@error_flag2 = 1 AND @success_flag2 = 1)
	BEGIN
	SELECT @desc = '<a target="_blank" href="' + @url2 + '">' + '<font color =''red''>' +
	   'WREGIS SOLD/Transfer Uploaded with errors' + '</font>' +'</a>'+ ' '+
	   '.Elapsed time:' + CAST(@elapsed_sec2 AS VARCHAR(1000)) + ' sec </a>'
	  SET @error_code = 'e'
	END
	ELSE IF(@error_flag2 = 0 AND @success_flag2 = 1)
	BEGIN
	SELECT @desc = '<a target="_blank" href="' + @url2 + '">' +
	   'WREGIS SOLD/Transfer Uploaded' +'</a>'+ ' '+
	   '.Elapsed time:' + CAST(@elapsed_sec2 AS VARCHAR(1000)) + ' sec </a>'
	  SET @error_code = 's'
	END
	ELSE IF(@error_flag2 = 1 AND @success_flag2 = 0)
	BEGIN
	SELECT @desc = '<a target="_blank" href="' + @url2 + '">' + '<font color =''red''>' +
	   'WREGIS SOLD/Transfer Upload Failed' + '</font>' +'</a>'+ ' '+
	   '.Elapsed time:' + CAST(@elapsed_sec2 AS VARCHAR(1000)) + ' sec </a>'
	  SET @error_code = 'e'
	END

	--END TRY
	--BEGIN CATCH
	--	EXEC spa_print 'error' +ERROR_MESSAGE()
	--	SET @error_code = 'e'
	--	SET @desc ='Unable to complete WREGIS RPS Download'
	--	ROLLBACK 
	--END CATCH

	--EXEC spa_NotificationUserByRole 2, @process_id, 'WREGIS SOLD/Transfer Upload', @desc , @error_code, @job_name, 1

	--updating using flag 'e' which automatically calculate the estimated time.
	EXEC spa_import_data_files_audit
		 @flag = 'e',
		 @process_id = @process_id,
		 @status = @error_code
	
	
END
ELSE -- REC UPLOAD
BEGIN


	
ALTER TABLE #tmp_dff DROP COLUMN sub_account_name
ALTER TABLE #tmp_dff DROP COLUMN [wregis_gu_id]
ALTER TABLE #tmp_dff DROP COLUMN [generator_plant_unit_name]
ALTER TABLE #tmp_dff DROP COLUMN country

ALTER TABLE #tmp_dff DROP COLUMN [fuel_type]
ALTER TABLE #tmp_dff DROP COLUMN [Month]
ALTER TABLE #tmp_dff DROP COLUMN [Year]
ALTER TABLE #tmp_dff DROP COLUMN [certificate_serial_number]
ALTER TABLE #tmp_dff DROP COLUMN Quantity
ALTER TABLE #tmp_dff DROP COLUMN [green_energy_eligible]
ALTER TABLE #tmp_dff DROP COLUMN [ecologo_certified]
ALTER TABLE #tmp_dff DROP COLUMN [hydro_certification]
ALTER TABLE #tmp_dff DROP COLUMN [smud_eligible]
ALTER TABLE #tmp_dff DROP COLUMN [etag_matched]
ALTER TABLE #tmp_dff DROP COLUMN [eTag]

--SELECT * INTO #temp_dff from #tmp_dff

--ALTER TABLE #tmp_dff DROP COLUMN [State]
--select * from #gis_certificate2

select * into #state2 from #tmp_dff

ALTER TABLE #tmp_dff ADD  generator VARCHAR(1000) 
ALTER TABLE #tmp_dff ADD  [monthly term] VARCHAR(1000) 
ALTER TABLE #tmp_dff ADD  volume FLOAT
ALTER TABLE #tmp_dff ADD   [cert from] VARCHAR(1000) 
ALTER TABLE #tmp_dff ADD  [cert to] VARCHAR(1000) 


--DECLARE @name varchar(1000), @name_with_case varchar(8000), @name_with_datatype varchar(8000), @name_state varchar(1000)
--DECLARE @temp_dff_name VARCHAR(1000), @temp_dff_name_with_case VARCHAR(1000)
DECLARE @name_state_no VARCHAR(MAX), @name_with_max VARCHAR(1000), @name_with_td VARCHAR(1000)
DECLARE @temp_name varchar(8000)
select @name = ISNULL(@name,'') + CASE WHEN @name is null THEN '' ELSE ',' END + '[' + name+ ']' from tempdb.sys.columns where object_id =
object_id('tempdb..#tmp_dff') and name not in ('generator','monthly term','volume','cert from','cert to','temp_id', 'State')

select @name_with_td = ISNULL(@name_with_td,'') + CASE WHEN @name_with_td is null THEN '' ELSE ',' END + 'td.[' + name+ ']' from tempdb.sys.columns where object_id =
object_id('tempdb..#tmp_dff') and name not in ('generator','monthly term','volume','cert from','cert to','temp_id', 'State')

select @name_with_max = ISNULL(@name_with_max,'') + CASE WHEN @name_with_max is null THEN '' ELSE ',' END + 'MAX([' + name+ '])' from tempdb.sys.columns where object_id =
object_id('tempdb..#tmp_dff') and name not in ('generator','monthly term','volume','cert from','cert to','temp_id', 'State')

select @temp_name = ISNULL(@temp_name,'') + CASE WHEN @temp_name is null THEN '' ELSE ' OR ' END + ' td.[' + name+ ']=@state' from tempdb.sys.columns where object_id =
object_id('tempdb..#tmp_dff') and name not in ('generator','monthly term','volume','cert from','cert to','temp_id')

--select @temp_dff_name = ISNULL(@temp_dff_name,'') + CASE WHEN @temp_dff_name is null THEN '' ELSE ',' END + '[' + name+ ']' from tempdb.sys.columns where object_id =
--object_id('tempdb..#temp_dff') and name not in ('generator','monthly term','volume','cert from','cert to','temp_id', 'state')

select @name_with_case = ISNULL(@name_with_case,'') + CASE WHEN @name_with_case is null THEN '' ELSE ',' END + ' CASE WHEN ' + '[' + name + ']'+ '= ''No'' THEN ' + '['+ name + '] ELSE ''' + name + ''' END ' from tempdb.sys.columns where object_id =
object_id('tempdb..#tmp_dff') and name not in ('generator','monthly term','volume','cert from','cert to','temp_id', 'State')

--select @temp_dff_name_with_case = ISNULL(@temp_dff_name_with_case,'') + CASE WHEN @temp_dff_name_with_case is null THEN '' ELSE ',' END + ' CASE WHEN ' + '[' + name + ']'+ '= ''No'' THEN ' + '['+ name + '] ELSE ''' + name + ''' END ' from tempdb.sys.columns where object_id =
--object_id('tempdb..#temp_dff') and name not in ('generator','monthly term','volume','cert from','cert to','temp_id','state')

select @name_with_datatype = ISNULL(@name_with_datatype,'') + CASE WHEN @name_with_datatype is null THEN '' ELSE ';' END + 'ALTER TABLE #tmp_dff3 ADD [' + name + ']' + ' VARCHAR(100) ' from tempdb.sys.columns where object_id =
object_id('tempdb..#tmp_dff') and name not in ('generator','monthly term','volume','cert from','cert to','temp_id', 'State')


--select * from #tmp_dff

--RETURN

--select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'WREGIS_REC_Download_farrms_admin_0BD4BC40_E116_4FBC_B239_86E4F5FF6863'

--set @sql = 'select name from sys.columns where object_id =
--object_id(''WREGIS_REC_Download_farrms_admin_0BD4BC40_E116_4FBC_B239_86E4F5FF6863'') and name not in (''sub_account_name'',''wregis_gu_id'',''generator_plant_unit_name'',''country'',''State''
--,''fuel_type'',''Month'',''Year'',''certificate_serial_number'',''Quantity'',''green_energy_eligible'',''ecologo_certified'',''hydro_certification'',''smud_eligible'',''etag_matched'',''eTag'')'

--exec(@sql)
--return

--CASE WHEN AZ = ''No'' THEN AZ ELSE ''AZ'' END, CASE WHEN BC = ''No'' THEN BC ELSE ''BC'' END, CASE WHEN CA = ''No'' THEN CA ELSE ''CA'' END,
 --CASE WHEN CO = ''No'' THEN CO ELSE ''CO'' END, CASE WHEN MT = ''No'' THEN MT ELSE ''MT'' END, CASE WHEN NV = ''No'' THEN NV ELSE ''NV'' END
 --, CASE WHEN NM = ''No'' THEN NM ELSE ''NM'' END, CASE WHEN TX = ''No'' THEN TX ELSE ''TX'' END, CASE WHEN WA = ''No'' THEN WA ELSE ''WA'' END
 --, CASE WHEN [OR] = ''No'' THEN [OR] ELSE ''OR'' END, CASE WHEN AB = ''No'' THEN AB ELSE ''AB'' END, CASE WHEN UT = ''No'' THEN UT ELSE ''UT'' END
--, AZ VARCHAR(100), BC VARCHAR(100), CA VARCHAR(100), CO VARCHAR(100), MT VARCHAR(100), NV VARCHAR(100),
--NM VARCHAR(100), TX VARCHAR(100), WA VARCHAR(100), [OR] VARCHAR(100), AB VARCHAR(100), UT VARCHAR(100)
--)

SET @sql ='INSERT INTO #tmp_dff(generator , [state], [monthly term] , volume ,
  [cert from] , 
[cert to], ' + @name + '
 )
select [wregis_gu_id], [state], [Year]+''/''+[Month]+''/1'', Quantity,
  SUBSTRING([certificate_serial_number],0,CHARINDEX('' to'',[certificate_serial_number])), 
 SUBSTRING([certificate_serial_number],0,LEN([certificate_serial_number])-CHARINDEX(''-'',REVERSE([certificate_serial_number]))+1)+''-''+SUBSTRING([certificate_serial_number],CHARINDEX(''to '',[certificate_serial_number])+3,LEN([certificate_serial_number])),
' + @name_with_case + '
from '+@temp_table_name

EXEC spa_print @sql
exec(@sql)



select @name_state_no = ISNULL(@name_state_no,'') + CASE WHEN @name_state_no is null THEN '' ELSE ' OR ' END + '['+ name + ']  = t.name  '
 from tempdb.sys.columns  where object_id =
object_id('tempdb..#tmp_dff') and name not in ('generator','monthly term','volume','cert from','cert to','temp_id','state')


--select * from #tmp_dff

 --CASE WHEN AB= 'No' THEN [AB] ELSE '[AB]' END , CASE WHEN AZ= 'No' THEN [AZ] ELSE '[AZ]' END , CASE WHEN BC= 'No' THEN [BC] ELSE '[BC]' END , CASE WHEN CA= 'No' THEN [CA] ELSE '[CA]' END , CASE WHEN CO= 'No' THEN [CO] ELSE '[CO]' END , CASE WHEN MT= 'No' THEN [MT] ELSE '[MT]' END , CASE WHEN NM= 'No' THEN [NM] ELSE '[NM]' END , CASE WHEN NV= 'No' THEN [NV] ELSE '[NV]' END , CASE WHEN OR= 'No' THEN [OR] ELSE '[OR]' END , CASE WHEN TX= 'No' THEN [TX] ELSE '[TX]' END , CASE WHEN UT= 'No' THEN [UT] ELSE '[UT]' END , CASE WHEN WA= 'No' THEN [WA] ELSE '[WA]' END 

--return

--select * from #tmp_dff

--return

--EXEC('
--BULK INSERT #tmp_dff
--		FROM '''+@file_full_path +'''
--		WITH 
--		( 
--			FIRSTROW = 2, 
--			FIELDTERMINATOR = '','', 
--			ROWTERMINATOR = ''\n'' 
--		)
--')
--RETURN 
--SELECT  *
--FROM    #tmp_dff2
--RETURN 
IF OBJECT_ID('tempdb..#tmp_dff3') is NOT NULL
DROP TABLE #tmp_dff3

CREATE TABLE #tmp_dff3(id INT identity(1,1)
	, row_no VARCHAR(100) COLLATE DATABASE_DEFAULT
	, generator VARCHAR(1000) COLLATE DATABASE_DEFAULT 
	, [state] VARCHAR(1000) COLLATE DATABASE_DEFAULT 
	, [monthly term] VARCHAR(1000) COLLATE DATABASE_DEFAULT 
	, volume VARCHAR(1000) COLLATE DATABASE_DEFAULT 
	, [cert from] VARCHAR(1000) COLLATE DATABASE_DEFAULT 
	, [cert to] VARCHAR(1000) COLLATE DATABASE_DEFAULT)


SET @sql = @name_with_datatype
EXEC spa_print @sql
EXEC(@sql)
--select * from #tmp_dff3

--''__farrms__'' + cast(ROW_NUMBER() OVER(ORDER BY (td2.[cert FROM])) AS VARCHAR),
--select * from #tmp_dff
--SET @sql = '
--INSERT INTO #tmp_dff3( generator , [state], [monthly term] , volume , [cert from] , [cert to], ' + @name + ')
--SELECT  MAX(generator) generator, MAX([state]) [state], MAX([monthly term]) [monthly term], SUM(volume) volume, MAX([cert from]) [cert from], MAX([cert to]) [cert to],
--' + @name_with_max + '
-- FROM (
--SELECT  td.generator , td.[state], td.[monthly term] , (CAST(td.volume AS FLOAT)) volume,
-- (td.[cert from]) , 
--(td2.[cert to]) , ' + @name_with_td + '
----select td.*
--FROM #tmp_dff td
--INNER JOIN #tmp_dff td2 ON td2.[monthly term] = td.[monthly term] AND td2.generator = td.generator
--AND SUBSTRING(ISNULL(td.[cert from],''-1''),0,LEN(ISNULL(td.[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL(td.[cert from],''-1''))))+1 )
--= SUBSTRING(ISNULL(td2.[cert from],''-1''),0,LEN(ISNULL(td2.[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL(td2.[cert from],''-1''))))+1 )
--AND (CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td.[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL(td.[cert to],''-1'')),0))) AS INT) + 1)
--= CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td2.[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL(td2.[cert from],''-1'')),0))) AS INT)
--UNION ALL
--SELECT  td2.generator , td2.[state], td2.[monthly term] , (CAST(td2.volume AS FLOAT)) volume ,
-- (td.[cert from]) , 
--(td2.[cert to]) , ' + @name_with_td + '
----select td.*
--FROM #tmp_dff td
--INNER JOIN #tmp_dff td2 ON td2.[monthly term] = td.[monthly term] AND td2.generator = td.generator
--AND SUBSTRING(ISNULL(td.[cert from],''-1''),0,LEN(ISNULL(td.[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL(td.[cert from],''-1''))))+1 )
--= SUBSTRING(ISNULL(td2.[cert from],''-1''),0,LEN(ISNULL(td2.[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL(td2.[cert from],''-1''))))+1 )
--AND (CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td.[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL(td.[cert to],''-1'')),0))) AS INT) + 1)
--= CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td2.[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL(td2.[cert from],''-1'')),0))) AS INT)
--) a
--GROUP BY generator, [monthly term]'

--EXEC spa_print @sql
--EXEC(@sql)


--SELECT td.* INTO #tmp_delete FROM #tmp_dff td INNER JOIN ( 
--SELECT '__farrms__' + cast(ROW_NUMBER() OVER(ORDER BY (td.[cert FROM])) AS VARCHAR) row_no, td.generator , td.[state], td.[monthly term] , (CAST(td.volume AS FLOAT)) volume,
-- (td.[cert from]) [cert from] , 
--(td.[cert to])  [cert to]
----select td.*
--FROM #tmp_dff td
--INNER JOIN #tmp_dff td2 ON td2.[monthly term] = td.[monthly term] AND td2.generator = td.generator
--AND SUBSTRING(ISNULL(td.[cert from],'-1'),0,LEN(ISNULL(td.[cert from],'-1'))-(CHARINDEX('-',REVERSE(ISNULL(td.[cert from],'-1'))))+1 )
--= SUBSTRING(ISNULL(td2.[cert from],'-1'),0,LEN(ISNULL(td2.[cert from],'-1'))-(CHARINDEX('-',REVERSE(ISNULL(td2.[cert from],'-1'))))+1 )
--AND (CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td.[cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL(td.[cert to],'-1')),0))) AS INT) + 1)
--= CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td2.[cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL(td2.[cert from],'-1')),0))) AS INT)
--) a ON td.generator = a.generator AND td.[monthly term] = a.[monthly term] AND td.[cert from] = a.[cert from] AND td.[cert to] = a.[cert to]

--DELETE td FROM #tmp_dff td INNER JOIN ( 
--SELECT '__farrms__' + cast(ROW_NUMBER() OVER(ORDER BY (td2.[cert FROM])) AS VARCHAR) row_no, td2.generator , td2.[state], td2.[monthly term] , (CAST(td2.volume AS FLOAT)) volume ,
-- (td2.[cert from]) [cert from] , 
--(td2.[cert to]) [cert to] 
----select td.*
--FROM #tmp_dff td
--INNER JOIN #tmp_dff td2 ON td2.[monthly term] = td.[monthly term] AND td2.generator = td.generator
--AND SUBSTRING(ISNULL(td.[cert from],'-1'),0,LEN(ISNULL(td.[cert from],'-1'))-(CHARINDEX('-',REVERSE(ISNULL(td.[cert from],'-1'))))+1 )
--= SUBSTRING(ISNULL(td2.[cert from],'-1'),0,LEN(ISNULL(td2.[cert from],'-1'))-(CHARINDEX('-',REVERSE(ISNULL(td2.[cert from],'-1'))))+1 )
--AND (CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td.[cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL(td.[cert to],'-1')),0))) AS INT) + 1)
--= CAST(REVERSE(SUBSTRING(REVERSE(ISNULL(td2.[cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL(td2.[cert from],'-1')),0))) AS INT)
--) a ON td.generator = a.generator AND td.[monthly term] = a.[monthly term] AND td.[cert from] = a.[cert from] AND td.[cert to] = a.[cert to]
----return

--DELETE td FROM #tmp_dff td INNER JOIN #tmp_delete tdd ON td.generator = tdd.generator AND td.[monthly term] = tdd.[monthly term] 
--AND td.[cert from] = tdd.[cert from] AND td.[cert to] = tdd.[cert to]

--''__farrms__'' + cast(ROW_NUMBER() OVER(ORDER BY ([cert FROM]))+1 AS VARCHAR),

SET @sql = '
INSERT INTO #tmp_dff3(generator , [state], [monthly term] , volume ,
 [cert from] , 
[cert to], ' + @name + ')
SELECT  generator , [state], [monthly term] , (CAST(volume AS FLOAT)) ,
 ([cert from]) , 
([cert to]),  ' + @name + ' FROM #tmp_dff'

EXEC spa_print @sql
EXEC(@sql)

--return

UPDATE td SET td.row_no = rownum FROM
(select  '__farrms__' + cast(ROW_NUMBER() OVER(ORDER BY (td.id)) AS VARCHAR) rownum, row_no 
from #tmp_dff3 td
) as td


----SELECT * FROM #tmp_dff3


----select * from #tmp_dff2

if OBJECT_ID('tempdb..#flag') IS NOT NULL
drop table #flag

create table #flag(flag char(1) COLLATE DATABASE_DEFAULT)

--select * from #tmp_dff2
--set @sql = 'SELECT distinct [state] FROM
--					(select '+ @name + ' from #tmp_dff2) p
--					UNPIVOT
--					([state] for #tmp_dff2 IN (' + @name + ')
--					) AS unpvt where [state] <> ''No'''
--EXEC spa_print @sql
--exec(@sql)

IF OBJECT_ID('tempdb..#gis_certificate2') IS NOT NULL
	DROP TABLE #gis_certificate2
			
			--select * from #gis_Certificate2
CREATE TABLE #gis_certificate2(source_certificate_number INT
	, source_deal_header_id INT
	, gis_certificate_number_from VARCHAR(100) COLLATE DATABASE_DEFAULT 
	, gis_certificate_number_to VARCHAR(100) COLLATE DATABASE_DEFAULT  
	, certificate_number_from_int FLOAT
	, certificate_number_to_int FLOAT
	, gis_cert_date DATETIME
	, state_value_id INT
	, tier_type INT
	, contract_expiration_date DATETIME)

INSERT INTO #gis_certificate2(source_certificate_number, source_deal_header_id, gis_certificate_number_from ,
gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int ,
gis_cert_date, state_value_id, tier_type, contract_expiration_date)
SELECT 
source_certificate_number, source_deal_header_id, gis_certificate_number_from ,
gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int ,
gis_cert_date, state_value_id, tier_type, contract_expiration_date 
FROM Gis_Certificate gc2 
where substring(reverse(gis_certificate_number_from),0,charindex('-',reverse(gis_certificate_number_from))) NOT LIKE '%[a-z]%'
-- REVERSE(SUBSTRING(REVERSE(gc2.gis_certificate_number_from),0,CHARINDEX('-',REVERSE(gc2.gis_certificate_number_from),0)))
--NOT LIKE '%[a-z]%' AND REVERSE(SUBSTRING(REVERSE(gc2.gis_certificate_number_to),0,CHARINDEX('-',REVERSE(gc2.gis_certificate_number_to),0))) NOT LIKE '%[a-z]%'
 --SUBSTRING(SUBSTRING(gis_certificate_number_from,CHARINDEX('-',SUBSTRING(SUBSTRING(gis_certificate_number_from,CHARINDEX('-',gis_certificate_number_from)+1,LEN(gis_certificate_number_from)),CHARINDEX('-',SUBSTRING(gis_certificate_number_from,CHARINDEX('-',gis_certificate_number_from)+1,LEN(gis_certificate_number_from)))+2,LEN(gis_certificate_number_from)))+2,LEN(gis_certificate_number_from)),CHARINDEX('-',SUBSTRING(gis_certificate_number_from,CHARINDEX('-',SUBSTRING(SUBSTRING(gis_certificate_number_from,CHARINDEX('-',gis_certificate_number_from)+1,LEN(gis_certificate_number_from)),CHARINDEX('-',SUBSTRING(gis_certificate_number_from,CHARINDEX('-',gis_certificate_number_from)+1,LEN(gis_certificate_number_from)))+2,LEN(gis_certificate_number_from)))+2,LEN(gis_certificate_number_from))),LEN(gis_certificate_number_from)) not like '%[a-z]%'
 AND 
 CHARINDEX('-',SUBSTRING(SUBSTRING(gis_certificate_number_from,CHARINDEX('-',SUBSTRING(SUBSTRING(gis_certificate_number_from,CHARINDEX('-',gis_certificate_number_from)+1,LEN(gis_certificate_number_from)),CHARINDEX('-',SUBSTRING(gis_certificate_number_from,CHARINDEX('-',gis_certificate_number_from)+1,LEN(gis_certificate_number_from)))+2,LEN(gis_certificate_number_from)))+2,LEN(gis_certificate_number_from)),CHARINDEX('-',SUBSTRING(gis_certificate_number_from,CHARINDEX('-',SUBSTRING(SUBSTRING(gis_certificate_number_from,CHARINDEX('-',gis_certificate_number_from)+1,LEN(gis_certificate_number_from)),CHARINDEX('-',SUBSTRING(gis_certificate_number_from,CHARINDEX('-',gis_certificate_number_from)+1,LEN(gis_certificate_number_from)))+2,LEN(gis_certificate_number_from)))+2,LEN(gis_certificate_number_from))),LEN(gis_certificate_number_from))) <> 0

--select * from #tmp_dff3

--return

SET @sql = 'IF EXISTS(SELECT sdd.source_deal_header_id
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	INNER JOIN #tmp_dff3 tmp ON tmp.generator = rg.code
		 AND (tmp.[monthly term]) = sdd.term_start
	LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
	--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
	--				 FROM  source_deal_header sdh2 
	--					INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
	--					INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
	--					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
	--					INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
	--	) a ON a.code = tmp.generator
	--		AND a.term_start  = tmp.[monthly term]
	--		AND a.gis_certificate_number_from = tmp.[cert from]
	CROSS JOIN ( 
				SELECT [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN ( ' + @name + ')
					) AS unpvt 
				) s
	WHERE 1=1 
	--AND a.code IS NULL
   
    AND (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
			
		)
	
     )
      INSERT INTO #flag SELECT ''u''
ELSE IF EXISTS(SELECT sdd.source_deal_header_id
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	INNER JOIN #tmp_dff3 tmp ON tmp.generator = rg.code
		 AND (tmp.[monthly term]) = sdd.term_start
	LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
	WHERE gc2.gis_certificate_number_from IS NULL
	)
		INSERT INTO #flag SELECT ''u''
IF EXISTS(SELECT 1 
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	INNER JOIN #tmp_dff3 tmp ON tmp.generator = rg.code
	LEFT JOIN gis_certificate gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
	--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
	--				 FROM  source_deal_header sdh2 
	--					INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
	--					INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
	--					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
	--					INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
	--	) a ON a.code = tmp.generator
	--		AND a.term_start  = tmp.[monthly term]
	--		AND a.gis_certificate_number_from = tmp.[cert from]
	
	WHERE 1=1 
	--AND a.code IS NULL
	AND gc2.gis_certificate_number_from IS NULL
    AND tmp.[monthly term] = sdd.term_start
      )
     INSERT INTO #flag SELECT ''o''
IF EXISTS(SELECT tmp.generator 
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	RIGHT JOIN #tmp_dff3 tmp ON tmp.generator = rg.code
		AND (tmp.[monthly term]) = sdd.term_start
	LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
	--WHERE gc2.gis_certificate_number_from IS NULL
	WHERE
	 rg.code IS NULL OR sdd.source_deal_header_id IS NULL OR gc2.gis_certificate_number_from IS NULL
	)
	INSERT INTO #flag SELECT ''i''
	'
	
EXEC spa_print @sql
exec(@sql)


--select * from #tmp_dff3
--select * from #flag
--if exists (select * from #flag where  flag in ('i', 'o', 'u'))
--begin
--   update  #flag set flag = 'o' where  flag in ('i', 'o', 'u')
--end 
--return

SET @sql ='DECLARE @state VARCHAR(100)
			DECLARE  state_status CURSOR LOCAL FOR
			SELECT distinct [state] FROM
					(select '+ @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt where [state] <> ''No''
				
			OPEN state_status;

			FETCH NEXT FROM state_status INTO @state
			WHILE @@FETCH_STATUS = 0
			BEGIN
IF EXISTS(SELECT sdd.source_deal_header_id
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	INNER JOIN #tmp_dff3 tmp ON tmp.generator = rg.code
		 AND (tmp.[monthly term]) = sdd.term_start
	LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
	--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
	--				 FROM  source_deal_header sdh2 
	--					INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
	--					INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
	--					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
	--					INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
	--	) a ON a.code = tmp.generator
	--		AND a.term_start  = tmp.[monthly term]
	--		AND a.gis_certificate_number_from = tmp.[cert from]
	CROSS JOIN ( 
				SELECT [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN ( ' + @name + ')
					) AS unpvt 
				) s
	WHERE 1=1 
	--AND a.code IS NULL
   
    AND (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
		)
	
     )
      INSERT INTO #flag SELECT ''u''
      
IF EXISTS(SELECT 1 
	FROM source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	INNER JOIN #tmp_dff3 tmp ON tmp.generator = rg.code
	LEFT JOIN gis_certificate gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
	--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
	--				 FROM  source_deal_header sdh2 
	--					INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
	--					INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
	--					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
	--					INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
	--	) a ON a.code = tmp.generator
	--		AND a.term_start  = tmp.[monthly term]
	--		AND a.gis_certificate_number_from = tmp.[cert from]
	
	WHERE 1=1 
	--AND a.code IS NULL
	AND gc2.gis_certificate_number_from IS NULL
    AND tmp.[monthly term] = sdd.term_start
      )
     INSERT INTO #flag SELECT ''o''
ELSE
	INSERT INTO #flag SELECT ''i''
	FETCH NEXT FROM state_status INTO @state
			END;

			CLOSE state_status;
			DEALLOCATE state_status;	
	'
	
EXEC spa_print @sql
EXEC(@sql)




--select * from #flag
	
	--return
	IF OBJECT_ID('tempdb..#inserted_source_deal_header_id') is NOT NULL
		DROP TABLE #inserted_source_deal_header_id
	CREATE TABLE #inserted_source_deal_header_id(source_deal_header_id INT, row_no VARCHAR(100) COLLATE DATABASE_DEFAULT)
		
	IF OBJECT_ID('tempdb..#update_source_deal_header_id') is NOT NULL
		DROP TABLE #update_source_deal_header_id
	CREATE TABLE #update_source_deal_header_id(source_deal_header_id INT, row_no VARCHAR(100) COLLATE DATABASE_DEFAULT)
		
	IF OBJECT_ID('tempdb..#update_source_deal_header_id2') is NOT NULL
		DROP TABLE #update_source_deal_header_id2
	CREATE TABLE #update_source_deal_header_id2(source_deal_header_id INT, row_no VARCHAR(100) COLLATE DATABASE_DEFAULT)
		
	IF OBJECT_ID('tempdb..#update_assigned_source_deal_header_id') is NOT NULL
		DROP TABLE #update_assigned_source_deal_header_id
	CREATE TABLE #update_assigned_source_deal_header_id(source_deal_header_id_from INT
		, source_deal_header_id INT
		, row_order INT
		, row_no VARCHAR(100) COLLATE DATABASE_DEFAULT)
	
	IF OBJECT_ID('tempdb..#already_assigned') IS NOT NULL
			DROP TABLE #already_assigned
		 
		 CREATE TABLE #already_assigned(row_no VARCHAR(100) COLLATE DATABASE_DEFAULT, source_deal_header_id INT)	
		--select * from #update_source_deal_header_id
		--select * from #inserted_source_deal_header_id

BEGIN TRAN
BEGIN TRY

	
		
		--select * from #tmp_dff3
		--select * from #flag
			
	IF EXISTS(SELECT 1 from #flag where flag = 'u')
	BEGIN
		

		IF OBJECT_ID('tempdb..#prev_volume') IS NOT NULL
			DROP TABLE #prev_volume
			
		IF OBJECT_ID('tempdb..#prev_assigned_volume') IS NOT NULL
			DROP TABLE #prev_assigned_volume
		
		--CREATE TABLE #prev_volume(source_deal_header_id INT, prev_vol FLOAT, prev_vol_left FLOAT)
		
		CREATE TABLE #prev_assigned_volume(assigned_source_deal_header_id INT, assigned_prev_vol FLOAT, assigned_prev_vol_left FLOAT)
		--select * from #prev_volume
		--select * from #tmp_dff3
		
		--SELECT [state] into #state FROM
		--			(select [AB],[AZ],[BC],[CA],[CO],[MT],[NM],[NV],[OR],[TX],[UT],[WA] from #tmp_dff3) p
		--			UNPIVOT
		--			([state] for #tmp_dff3 IN ([AB],[AZ],[BC],[CA],[CO],[MT],[NM],[NV],[OR],[TX],[UT],[WA])
		--			) AS unpvt 
		
		
		
		--	SELECT  (tmp.generator),
  --  			'E52C8C17_298F_4117_989F_41FD8429670E',
  --  			'Error',
  --  			'Import WREGIS Upload',
  --  			'Error',
  --  			'The volume is already assigned. Please unassign.',
  --  			''
		--FROM source_deal_header sdh 
		--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		--INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		--INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
		--INNER JOIN #tmp_dff3 tmp ON tmp.generator = rg.code
		--	AND (tmp.[monthly term]) = sdd.term_start
		--LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		----LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
		----			 FROM  source_deal_header sdh2 
		----				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
		----				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
		----				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
		----				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		----) a ON a.code = tmp.generator
		----	AND a.term_start  = tmp.[monthly term]
		----	AND a.gis_certificate_number_from = tmp.[cert from]
		--CROSS JOIN ( 
		--				SELECT distinct [state]  FROM
		--			(select [AB],[AZ],[BC],[CA],[CO],[MT],[NM],[NV],[OR],[TX],[UT],[WA] from #tmp_dff3) p
		--			UNPIVOT
		--			([state] for #tmp_dff3 IN ([AB],[AZ],[BC],[CA],[CO],[MT],[NM],[NV],[OR],[TX],[UT],[WA])
		--			) AS unpvt 
		--		) s
		--INNER JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		--INNER JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		--INNER JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id 
		--WHERE 1=1 
		----AND a.code IS NOT NULL
		--AND ( 
  --   -- logic that checks that certificate falls within the given range
	 --SUBSTRING(ISNULL([cert from],'-1'),0,CHARINDEX('-',ISNULL([cert from],'-1')))+'-'+'s.state'+'-'+ SUBSTRING(SUBSTRING(ISNULL([cert from],'-1'),CHARINDEX('-',ISNULL([cert from],'-1'))+1,LEN(ISNULL([cert from],'-1'))),CHARINDEX('-',SUBSTRING(ISNULL([cert from],'-1'),CHARINDEX('-',ISNULL([cert from],'-1'))+1,LEN(ISNULL([cert from],'-1'))))+1,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1') )))
	 --= SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1'),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1'))-(CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1'))))+1)
	 --AND	(
		--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) BETWEEN 
		--			CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
		--				AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
		--			OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT) BETWEEN
		--			CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
		--				AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
		--			AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0))) AS INT) BETWEEN
		--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
		--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
		--			OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0))) AS INT) BETWEEN
		--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
		--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
		--	)
		
		--)
	 --OR (
		--	SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1'),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1'))-(CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1'))))+1 )
		--	= SUBSTRING(ISNULL([cert from],'-1'),0,LEN(ISNULL([cert from],'-1'))-(CHARINDEX('-',REVERSE(ISNULL([cert from],'-1'))))+1 )
		--	 AND	(
		--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) BETWEEN 
		--			CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
		--				AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
		--			OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT) BETWEEN
		--			CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
		--				AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
		--			AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0))) AS INT) BETWEEN
		--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
		--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
		--			OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0))) AS INT) BETWEEN
		--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
		--			CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
		--		)
		
		--)
		--  GROUP BY tmp.generator, tmp.[monthly term]
		--  HAVING MAX(tmp.volume) < MAX(aa2.assigned_volume)


--SELECT sdh.source_deal_header_id, MAX(tmp.row_no)  FROM source_deal_header sdh 
--		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
--		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
--		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
--		CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
--			AND (tmp.[monthly term]) = sdd.term_start
			
--			) tmp 
--		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
--		--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
--		--			 FROM  source_deal_header sdh2 
--		--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
--		--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
--		--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
--		--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
--		--) a ON a.code = tmp.generator
--		--	AND a.term_start  = tmp.[monthly term]
--		--	AND ISNULL(a.gis_certificate_number_from, tmp.[cert from]) = tmp.[cert from]
--		CROSS JOIN ( 
--				SELECT [state] FROM
--					(select [AB],[AZ],[BC],[CA],[CO],[MT],[NM],[NV],[OR],[TX],[UT],[WA] from #tmp_dff3) p
--					UNPIVOT
--					([state] for #tmp_dff3 IN ([AB],[AZ],[BC],[CA],[CO],[MT],[NM],[NV],[OR],[TX],[UT],[WA])
--					) AS unpvt 
--				) s
--		LEFT JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
--		WHERE 1=1 
--		AND sdh.assignment_type_value_id IS NULL
--		AND sdd.deal_volume <> 0
--			--AND a.code IS NULL
--		AND(1=1
--		AND (
--	 SUBSTRING(ISNULL([cert from],'-1'),0,CHARINDEX('-',ISNULL([cert from],'-1')))+'-'+'s.state'+'-'+ SUBSTRING(SUBSTRING(ISNULL([cert from],'-1'),CHARINDEX('-',ISNULL([cert from],'-1'))+1,LEN(ISNULL([cert from],'-1'))),CHARINDEX('-',SUBSTRING(ISNULL([cert from],'-1'),CHARINDEX('-',ISNULL([cert from],'-1'))+1,LEN(ISNULL([cert from],'-1'))))+1,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1') )))
--	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1'),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1'))-(CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1'))))+1)
--	 AND	(
--					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) BETWEEN 
--					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
--						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
--					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT) BETWEEN
--					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
--						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
				
--					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0))) AS INT) BETWEEN
--					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
--					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
--					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0))) AS INT) BETWEEN
--					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
--					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
--				)
--			AND sdh.assignment_type_value_id IS NULL
--		)
--	 OR (
--			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1'),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1'))-(CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1'))))+1 )
--			= SUBSTRING(ISNULL([cert from],'-1'),0,LEN(ISNULL([cert from],'-1'))-(CHARINDEX('-',REVERSE(ISNULL([cert from],'-1'))))+1 )
--			 AND	(
--					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) BETWEEN 
--					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
--						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
--					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT) BETWEEN
--					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
--						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
				
--					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],'-1')),0))) AS INT) BETWEEN
--					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
--					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
--					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],'-1')),0))) AS INT) BETWEEN
--					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
--					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
--				)
				
--		AND sdh.assignment_type_value_id IS NULL
--		)
--		)
--		GROUP BY sdh.source_deal_header_id
--		HAVING MAX(tmp.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tmp.volume))
		
		
		SET @sql = 'INSERT INTO source_system_data_import_status
    	      (
    	        [source],
    	        process_id,
    	        code,
    	        module,
    	        [type],
    	        [description],
    	        recommendation
    	      )
    	SELECT  ''WREGIS'',
    			'''+ @process_id + ''',
    			''Error'',
    			''Import WREGIS REC Upload'',
    			''Error'',
    			''The volume for generator '' + tmp.generator + '' and term '' + tmp.[monthly term] +'' is already assigned. Please unassign.'',
    			''''
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
		INNER JOIN #tmp_dff3 tmp ON tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
		--			 FROM  source_deal_header sdh2 
		--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
		--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
		--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
		--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		--) a ON a.code = tmp.generator
		--	AND a.term_start  = tmp.[monthly term]
		--	AND a.gis_certificate_number_from = tmp.[cert from]
		CROSS JOIN ( 
				SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt 
				) s
		INNER JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		INNER JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		INNER JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id 
		WHERE 1=1 
		--AND a.code IS NOT NULL
		AND ( 
     -- logic that checks that certificate falls within the given range
	 SUBSTRING(ISNULL([cert from],''-1''),0,CHARINDEX(''-'',ISNULL([cert from],''-1'')))+''-''+''s.state''+''-''+ SUBSTRING(SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))),CHARINDEX(''-'',SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))))+1,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'') )))
	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1)
	 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
			)
		
		)
	 OR (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
		
		)
		  GROUP BY tmp.generator, tmp.[monthly term]
		  HAVING MAX(tmp.volume) < MAX(aa2.assigned_volume)'
		  
		 EXEC spa_print @sql
		 EXEC(@sql)
		 
		 --IF OBJECT_ID('tempdb..#already_assigned') IS NOT NULL
			--DROP TABLE #already_assigned
		 
		 --CREATE TABLE #already_assigned(row_no VARCHAR(100) COLLATE DATABASE_DEFAULT , source_deal_header_id INT)
		 
		set @sql=' 
		INSERT INTO #already_assigned(row_no,source_deal_header_id)
		SELECT  tmp.row_no, sdh.source_deal_header_id
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
		INNER JOIN #tmp_dff3 tmp ON tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
		--			 FROM  source_deal_header sdh2 
		--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
		--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
		--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
		--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		--) a ON a.code = tmp.generator
		--	AND a.term_start  = tmp.[monthly term]
		--	AND a.gis_certificate_number_from = tmp.[cert from]
		CROSS JOIN ( 
				SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt 
				) s
		INNER JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		INNER JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		INNER JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id 
		WHERE 1=1 
		--AND a.code IS NOT NULL
		AND ( 
     -- logic that checks that certificate falls within the given range
	 SUBSTRING(ISNULL([cert from],''-1''),0,CHARINDEX(''-'',ISNULL([cert from],''-1'')))+''-''+''s.state''+''-''+ SUBSTRING(SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))),CHARINDEX(''-'',SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))))+1,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'') )))
	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1)
	 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
			)
		
		)
	 OR (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
		
		)
		  GROUP BY tmp.row_no, sdh.source_deal_header_id
		  HAVING MAX(tmp.volume) < MAX(aa2.assigned_volume)'
		  
		 EXEC spa_print @sql
		 EXEC(@sql)
		 
		 
		 --select * from #already_assigned
		 --select * from #tmp_dff3
		 --SELECT  (row_no) row_no, (volume) volume FROM #tmp_dff3 tmp where tmp.row_no = (select min(row_no) from #tmp_dff3 tmp)
		 --CREATE
		 
		 --return
		 --commit return
		 
		  UPDATE udddf SET udf_value = dbo.FNARemoveTrailingZero(a.volume) FROM
		 --select a.* from
		 (
		 select sdh.source_deal_header_id, MAX(sdd.deal_volume) volume, MAX(sdh.template_id) template_id ,max(tmp_cnt.cnt) cnt1 , max(tmp_sdh_cnt.cnt) cnt2
		 from source_deal_header sdh 
		 INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		 INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		 LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		 INNER JOIN #tmp_dff3 td ON td.generator = rg.code
			AND td.[monthly term] = sdd.term_start
		 CROSS APPLY(select count(generator) cnt from #tmp_dff3 td2 WHERE td2.generator = rg.code
					AND td2.[monthly term] = sdd.term_start
					GROUP BY td2.generator, td2.[monthly term]
		) tmp_cnt
		CROSS APPLY(SELECT count(sdh2.source_deal_header_id) cnt from source_deal_header sdh2 
					INNER JOIN source_deal_detail sdd2 on sdd2.source_deal_header_id = sdh2.source_deal_header_id
					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
					WHERE rg2.code = td.generator AND sdd2.term_start = td.[monthly term]
					AND sdd2.buy_sell_flag = 'b'
					GROUP BY rg2.code, sdd2.term_start
		) tmp_sdh_cnt
		 WHERE sdd.buy_sell_flag = 'b'
			AND gc2.gis_certificate_number_from IS NULL
		GROUP BY sdh.source_deal_header_id
		--HAVING (max(tmp_cnt.cnt) <> max(tmp_sdh_cnt.cnt) AND max(tmp_sdh_cnt.cnt) <> 1)
			) a 
		OUTER APPLY(select a.cnt1 cnt from #tmp_dff3 where a.cnt1 = a.cnt2 and a.cnt1 = 1 and a.cnt2=1) b
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = a.template_id
		INNER JOIN user_defined_deal_detail_fields udddf ON udddf.udf_template_id = uddft.udf_template_id
			AND udddf.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE uddft.Field_label = 'volume'
			AND sdd.deal_volume <> 0
			and b.cnt IS NULL
		 
	
		 INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id, udf_template_id, udf_value)
		 select sdd.source_deal_detail_id, uddft.udf_template_id, dbo.FNARemoveTrailingZero(a.volume) FROM
		 (
		 select sdh.source_deal_header_id, MAX(sdd.deal_volume) volume, MAX(sdh.template_id) template_id ,max(tmp_cnt.cnt) cnt1 , max(tmp_sdh_cnt.cnt) cnt2
		 from source_deal_header sdh 
		 INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		 INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		 LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		 INNER JOIN #tmp_dff3 td ON td.generator = rg.code
			AND td.[monthly term] = sdd.term_start
		 CROSS APPLY(select count(generator) cnt from #tmp_dff3 td2 WHERE td2.generator = rg.code
					AND td2.[monthly term] = sdd.term_start
					GROUP BY td2.generator, td2.[monthly term]
		) tmp_cnt
		CROSS APPLY(SELECT count(sdh2.source_deal_header_id) cnt from source_deal_header sdh2 
					INNER JOIN source_deal_detail sdd2 on sdd2.source_deal_header_id = sdh2.source_deal_header_id
					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
					WHERE rg2.code = td.generator AND sdd2.term_start = td.[monthly term]
					AND sdd2.buy_sell_flag = 'b'
					GROUP BY rg2.code, sdd2.term_start
		) tmp_sdh_cnt
		 WHERE sdd.buy_sell_flag = 'b'
			AND gc2.gis_certificate_number_from IS NULL
		GROUP BY sdh.source_deal_header_id
		--HAVING (max(tmp_cnt.cnt) <> max(tmp_sdh_cnt.cnt) AND max(tmp_sdh_cnt.cnt) <> 1)
			) a 
		outer apply(select a.cnt1 cnt from #tmp_dff3 where a.cnt1 = a.cnt2 and a.cnt1 = 1 and a.cnt2=1) b
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = a.template_id
		LEFT JOIN user_defined_deal_detail_fields udddf ON udddf.udf_template_id = uddft.udf_template_id
		AND udddf.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE uddft.Field_label = 'volume'
			AND udddf.source_deal_detail_id IS NULL
			AND sdd.deal_volume <> 0
			and b.cnt IS NULL
			
		
		UPDATE sdd SET sdd.deal_volume = 0 FROM 
		--SELECT sdd.* from
		(
		select sdh.source_deal_header_id,max(tmp_cnt.cnt) cnt1 , max(tmp_sdh_cnt.cnt) cnt2 from source_deal_header sdh 
		 INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		 INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		 LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		 INNER JOIN #tmp_dff3 td ON td.generator = rg.code
			AND td.[monthly term] = sdd.term_start
		 CROSS APPLY(select count(generator) cnt from #tmp_dff3 td2 WHERE td2.generator = rg.code
					AND td2.[monthly term] = sdd.term_start
					GROUP BY td2.generator, td2.[monthly term]
		) tmp_cnt
		CROSS APPLY(SELECT count(sdh2.source_deal_header_id) cnt from source_deal_header sdh2 
					INNER JOIN source_deal_detail sdd2 on sdd2.source_deal_header_id = sdh2.source_deal_header_id
					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
					WHERE rg2.code = td.generator AND sdd2.term_start = td.[monthly term]
					AND sdd2.buy_sell_flag = 'b'
					GROUP BY rg2.code, sdd2.term_start
		) tmp_sdh_cnt
		
		 WHERE sdd.buy_sell_flag = 'b'
			AND gc2.gis_certificate_number_from IS NULL
			
		GROUP BY sdh.source_deal_header_id
		--NOT HAVING (max(tmp_cnt.cnt) = max(tmp_sdh_cnt.cnt)  AND max(tmp_sdh_cnt.cnt) = 1  AND max(tmp_cnt.cnt) = 1)
		) a INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		outer apply(select a.cnt1 cnt from #tmp_dff3 where a.cnt1 = a.cnt2 and a.cnt1 = 1 and a.cnt2=1) b
		where sdd.deal_volume <> 0
		and b.cnt IS NULL
		
		UPDATE sdd SET sdd.deal_volume = 0 FROM 
		(
		select aa.source_deal_header_id, max(tmp_cnt.cnt) cnt1 , max(tmp_sdh_cnt.cnt) cnt2 from source_deal_header sdh 
		 INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
		 INNER JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd.source_deal_detail_id
		 INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		 LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		 INNER JOIN #tmp_dff3 td ON td.generator = rg.code
			AND td.[monthly term] = sdd.term_start
		 CROSS APPLY(select count(generator) cnt from #tmp_dff3 td2 WHERE td2.generator = rg.code
					AND td2.[monthly term] = sdd.term_start
					GROUP BY td2.generator, td2.[monthly term]
		) tmp_cnt
		CROSS APPLY(SELECT count(sdh2.source_deal_header_id) cnt from source_deal_header sdh2 
					INNER JOIN source_deal_detail sdd2 on sdd2.source_deal_header_id = sdh2.source_deal_header_id
					INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
					WHERE rg2.code = td.generator AND sdd2.term_start = td.[monthly term]
					AND sdd2.buy_sell_flag = 'b'
					GROUP BY rg2.code, sdd2.term_start
		) tmp_sdh_cnt
		 WHERE sdd.buy_sell_flag = 'b'
			AND gc2.gis_certificate_number_from IS NULL
		GROUP BY sdh.source_deal_header_id, aa.source_deal_header_id
		--HAVING (max(tmp_cnt.cnt) <> max(tmp_sdh_cnt.cnt) AND max(tmp_sdh_cnt.cnt) <> 1)
		) a 
		outer apply(select a.cnt1 cnt from #tmp_dff3 where a.cnt1 = a.cnt2 and a.cnt1 = 1 and a.cnt2=1) b
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = a.source_deal_header_id
		where sdd.deal_volume <> 0
		and b.cnt IS NULL
		 
		 --Updating volume of mv90/manually inserted deals
		-- UPDATE sdd set sdd.deal_volume = a.volume FROM
		--(
		--SELECT max(tmp.volume) volume, (sdd.source_deal_header_id) source_deal_header_id,max(tmp.row_no) row_no FROM source_deal_header sdh 
		--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		--INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		--INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
		--CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
		--	AND (tmp.[monthly term]) = sdd.term_start
		--	AND tmp.row_no IN (select min(row_no) from #tmp_dff3 tmp
		--	INNER JOIN source_deal_detail sdd ON sdd.term_start = (tmp.[monthly term])
		--	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		--	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--		AND rg.code = tmp.generator
		--	GROUP BY tmp.generator, tmp.[monthly term])
		--	) tmp 
		--LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		--LEFT JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		--LEFT JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id 
		--WHERE gc2.gis_certificate_number_from IS NULL
		--	AND ISNULL(sdd.[status],-1) = 25001
		--GROUP BY sdd.source_deal_header_id
		--  HAVING MAX(tmp.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tmp.volume))
		-- ) a
		-- INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id

	
		----select * from #tmp_dff3
		
		----inserting volume of deal(actual volume) into volume udf for non-certified deal
		--UPDATE udddf SET udf_value = dbo.FNARemoveTrailingZero(a.volume) FROM
		--(
		--SELECT MAX(sdd.deal_volume) volume, (sdd.source_deal_header_id) source_deal_header_id, MAX(sdh.template_id) template_id FROM source_deal_header sdh 
		--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		--INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		--INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
		--CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
		--	AND (tmp.[monthly term]) = sdd.term_start
		--	AND tmp.row_no IN (select min(row_no) from #tmp_dff3 tmp
		--	INNER JOIN source_deal_detail sdd ON sdd.term_start = (tmp.[monthly term])
		--	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		--	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--		AND rg.code = tmp.generator
		--	GROUP BY tmp.generator, tmp.[monthly term])
		--	) tmp 
		--LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		--LEFT JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		--LEFT JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id 
		--WHERE gc2.gis_certificate_number_from IS NULL
		--	AND ISNULL(sdd.[status],-1) <> 25001
		--GROUP BY  sdd.source_deal_header_id
		--  HAVING MAX(tmp.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tmp.volume))
		-- ) a
		--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		--INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = a.template_id
		--INNER JOIN user_defined_deal_detail_fields udddf ON udddf.udf_template_id = uddft.udf_template_id
		--	AND udddf.source_deal_detail_id = sdd.source_deal_detail_id
		--WHERE uddft.Field_label = 'volume'
		
		
		
		-- UPDATE sdd set sdd.deal_volume = a.volume FROM
		--(
		--SELECT MAX(tmp.volume) volume, (sdd.source_deal_header_id) source_deal_header_id FROM source_deal_header sdh 
		--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		--INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		--INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
		--CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
		--	AND (tmp.[monthly term]) = sdd.term_start
		--	AND tmp.row_no IN (select min(row_no) from #tmp_dff3 tmp
		--	INNER JOIN source_deal_detail sdd ON sdd.term_start = (tmp.[monthly term])
		--	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		--	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--		AND rg.code = tmp.generator
		--	GROUP BY tmp.generator, tmp.[monthly term])
		--	) tmp 
		--LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		--LEFT JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		--LEFT JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id 
		--WHERE gc2.gis_certificate_number_from IS NULL
		--	AND ISNULL(sdd.[status],-1) <> 25001
		--GROUP BY  sdd.source_deal_header_id
		--  HAVING MAX(tmp.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tmp.volume))
		-- ) a
		--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		
	
		-- copying old deal volume to udf volume	 
		 	 SET @sql2 = '  UPDATE udddf SET udf_value = dbo.FNARemoveTrailingZero(a.volume) FROM
		(
		select sdh.source_deal_header_id, MAX(sdd.deal_volume) volume, MAX(sdh.template_id) template_id 
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		LEFT JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		LEFT JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh3.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
			AND ISNULL(rga.counterparty_id, sc.source_counterparty_id) = sc.source_counterparty_id 
		CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
			
			) tmp 
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
		--			 FROM  source_deal_header sdh2 
		--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
		--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
		--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
		--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		--) a ON a.code = tmp.generator
		--	AND a.term_start  = tmp.[monthly term]
		--	AND a.gis_certificate_number_from = tmp.[cert from]
		CROSS JOIN ( 
				SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt 
				) s
		
		WHERE 1=1 
		AND sdh.assignment_type_value_id IS NULL 
		AND sdd.deal_volume <> 0
		AND ISNULL(sdd.[status],-1) <>' + CAST(@certificate_id AS VARCHAR(10)) + '

		 AND(1=1
	 AND (
	 SUBSTRING(ISNULL([cert from],''-1''),0,CHARINDEX(''-'',ISNULL([cert from],''-1'')))+''-''+''s.state''+''-''+ SUBSTRING(SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))),CHARINDEX(''-'',SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))))+1,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'') )))
	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1)
	 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		)
	 OR (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		
		)
		)
		  GROUP BY sdh.source_deal_header_id
		   HAVING MAX(tmp.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tmp.volume))
		 ) a
		   INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = a.template_id
		INNER JOIN user_defined_deal_detail_fields udddf ON udddf.udf_template_id = uddft.udf_template_id
		AND udddf.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE uddft.Field_label = ''volume''
		'
		--AND a.code IS NOT NULL
	-- logic that checks that certificate falls within the given range
	 --SET @sql2= ' 
	
		--  '
		  
		  
		  
         EXEC spa_print @sql2
		 EXEC(@sql2)
		
		 
		 SET @sql2 = 'INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id, udf_template_id, udf_value)
		 select sdd.source_deal_detail_id, uddft.udf_template_id, dbo.FNARemoveTrailingZero(a.volume) FROM
		(
		select sdh.source_deal_header_id, MAX(sdd.deal_volume) volume, MAX(sdh.template_id) template_id 
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		LEFT JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		LEFT JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh3.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
			AND ISNULL(rga.counterparty_id, sc.source_counterparty_id) = sc.source_counterparty_id 
		CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
			
			) tmp 
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
		--			 FROM  source_deal_header sdh2 
		--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
		--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
		--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
		--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		--) a ON a.code = tmp.generator
		--	AND a.term_start  = tmp.[monthly term]
		--	AND a.gis_certificate_number_from = tmp.[cert from]
		CROSS JOIN ( 
				SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt 
				) s
		
		WHERE 1=1 
		AND sdh.assignment_type_value_id IS NULL 
		AND sdd.deal_volume <> 0
		AND ISNULL(sdd.[status],-1) <> 
		' + CAST(@certificate_id AS VARCHAR(10)) + '
		AND(1=1
	 AND (
	 SUBSTRING(ISNULL([cert from],''-1''),0,CHARINDEX(''-'',ISNULL([cert from],''-1'')))+''-''+''s.state''+''-''+ SUBSTRING(SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))),CHARINDEX(''-'',SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))))+1,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'') )))
	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1)
	 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		)
	 OR (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		
		)
		)
		  GROUP BY sdh.source_deal_header_id
		   HAVING MAX(tmp.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tmp.volume))
		 ) a
		   INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = a.template_id
		LEFT JOIN user_defined_deal_detail_fields udddf ON udddf.udf_template_id = uddft.udf_template_id
		AND udddf.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE uddft.Field_label = ''volume''
		AND udddf.source_deal_detail_id IS NULL
		'
		--AND a.code IS NOT NULL
	-- logic that checks that certificate falls within the given range
		
		  
		 EXEC spa_print @sql
		 EXEC spa_print @sql2
		 EXEC(@sql2)
		 
		 --copying old deal volume of assigned deal to udf volume
		 	 SET @sql2 = '  UPDATE udddf SET udf_value = dbo.FNARemoveTrailingZero(a.volume) FROM
		(
		select sdh3.source_deal_header_id, MAX(sdd3.deal_volume) volume, MAX(sdh3.template_id) template_id 
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		INNER JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		INNER JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh3.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
			AND ISNULL(rga.counterparty_id, sc.source_counterparty_id) = sc.source_counterparty_id 
		CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
			
			) tmp 
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
		--			 FROM  source_deal_header sdh2 
		--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
		--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
		--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
		--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		--) a ON a.code = tmp.generator
		--	AND a.term_start  = tmp.[monthly term]
		--	AND a.gis_certificate_number_from = tmp.[cert from]
		CROSS JOIN ( 
				SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt 
				) s
		
		WHERE 1=1 
		AND sdh.assignment_type_value_id IS NULL 
		AND sdd.deal_volume <> 0
		AND ISNULL(sdd.[status],-1) <> 
		' + CAST(@certificate_id AS VARCHAR(10)) + ' 
		 
	 AND(1=1
	 AND (
	 SUBSTRING(ISNULL([cert from],''-1''),0,CHARINDEX(''-'',ISNULL([cert from],''-1'')))+''-''+''s.state''+''-''+ SUBSTRING(SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))),CHARINDEX(''-'',SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))))+1,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'') )))
	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1)
	 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		)
	 OR (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		
		)
		)
		  GROUP BY sdh.source_deal_header_id, sdh3.source_deal_header_id
		   HAVING MAX(tmp.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tmp.volume))
		 ) a
		   INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = a.template_id
		INNER JOIN user_defined_deal_detail_fields udddf ON udddf.udf_template_id = uddft.udf_template_id
		AND udddf.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE uddft.Field_label = ''volume''
		'
		--AND a.code IS NOT NULL
	-- logic that checks that certificate falls within the given range
	
		  
		 EXEC spa_print @sql
		 EXEC spa_print @sql2
		 EXEC(@sql2)
		 
		 
		  SET @sql2 = 'INSERT INTO user_defined_deal_detail_fields(source_deal_detail_id, udf_template_id, udf_value)
		 select sdd.source_deal_detail_id, uddft.udf_template_id, dbo.FNARemoveTrailingZero(a.volume) FROM
		(
		select sdh3.source_deal_header_id, MAX(sdd3.deal_volume) volume, MAX(sdh3.template_id) template_id 
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		INNER JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		INNER JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh3.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
			AND ISNULL(rga.counterparty_id, sc.source_counterparty_id) = sc.source_counterparty_id 
		CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
			
			) tmp 
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
		--			 FROM  source_deal_header sdh2 
		--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
		--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
		--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
		--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		--) a ON a.code = tmp.generator
		--	AND a.term_start  = tmp.[monthly term]
		--	AND a.gis_certificate_number_from = tmp.[cert from]
		CROSS JOIN ( 
				SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt 
				) s
		
		WHERE 1=1 
		AND sdh.assignment_type_value_id IS NULL 
		AND sdd.deal_volume <> 0
		AND ISNULL(sdd.[status],-1) <> 
		' + CAST(@certificate_id AS VARCHAR(10)) + ' 
		 AND(1=1
	 AND (
	 SUBSTRING(ISNULL([cert from],''-1''),0,CHARINDEX(''-'',ISNULL([cert from],''-1'')))+''-''+''s.state''+''-''+ SUBSTRING(SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))),CHARINDEX(''-'',SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))))+1,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'') )))
	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1)
	 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		)
	 OR (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		
		)
		)
		  GROUP BY sdh.source_deal_header_id, sdh3.source_deal_header_id
		   HAVING MAX(tmp.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tmp.volume))
		 ) a
		   INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = a.template_id
		LEFT JOIN user_defined_deal_detail_fields udddf ON udddf.udf_template_id = uddft.udf_template_id
		AND udddf.source_deal_detail_id = sdd.source_deal_detail_id
		WHERE uddft.Field_label = ''volume''
		AND udddf.source_deal_detail_id IS NULL
		'
		--AND a.code IS NOT NULL
	-- logic that checks that certificate falls within the given range
	 
		  
		  
		 EXEC spa_print @sql
		 EXEC spa_print @sql2
		 EXEC(@sql2)
		 
		--In case of Gen Allocation not exists
		SET @sql2 = 'UPDATE sdd set sdd.deal_volume = a.volume FROM
		(
		SELECT MAX(tmp.volume) volume, MAX(sdd.source_deal_header_id) source_deal_header_id FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
		CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
			
			) tmp 
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
		--			 FROM  source_deal_header sdh2 
		--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
		--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
		--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
		--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		--) a ON a.code = tmp.generator
		--	AND a.term_start  = tmp.[monthly term]
		--	AND a.gis_certificate_number_from = tmp.[cert from]
		CROSS JOIN ( 
				SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt 
				) s
		LEFT JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		LEFT JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		LEFT JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id 
		WHERE 1=1 
		AND sdh.assignment_type_value_id IS NULL
		--AND a.code IS NOT NULL
		AND rga.generator_id IS NULL 
		AND sdd.deal_volume <> 0
		AND(1=1
		AND ( 
     -- logic that checks that certificate falls within the given range
	 SUBSTRING(ISNULL([cert from],''-1''),0,CHARINDEX(''-'',ISNULL([cert from],''-1'')))+''-''+''s.state''+''-''+ SUBSTRING(SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))),CHARINDEX(''-'',SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))))+1,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'') )))
	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1)
	 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		)
	 OR (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		
		)
		)
		  GROUP BY  sdd.source_deal_header_id
		  HAVING MAX(tmp.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tmp.volume))
		 ) a
		  INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id

		'
		
		  
		  
		 EXEC spa_print @sql
		 EXEC spa_print @sql2
		 EXEC(@sql2)
		 
		
	
		
		 
		 --In case of Gen allocation exists
		SET @sql2 = 'UPDATE sdd set sdd.deal_volume = a.volume FROM
		(
		SELECT max(tmp.volume) volume, (sdd.source_deal_header_id) source_deal_header_id FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		LEFT JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		LEFT JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh3.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
			AND ISNULL(rga.counterparty_id, sc.source_counterparty_id) = sc.source_counterparty_id 
		CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
			
			) tmp 
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
		--			 FROM  source_deal_header sdh2 
		--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
		--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
		--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
		--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		--) a ON a.code = tmp.generator
		--	AND a.term_start  = tmp.[monthly term]
		--	AND a.gis_certificate_number_from = tmp.[cert from]
		CROSS JOIN ( 
				SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt 
				) s
		
		WHERE 1=1 
		AND sdh.assignment_type_value_id IS NULL 
		AND sdd.deal_volume <> 0
		AND(1=1
	 AND (
	 SUBSTRING(ISNULL([cert from],''-1''),0,CHARINDEX(''-'',ISNULL([cert from],''-1'')))+''-''+''s.state''+''-''+ SUBSTRING(SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))),CHARINDEX(''-'',SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))))+1,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'') )))
	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1)
	 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		)
	 OR (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		
		)
		)
		  GROUP BY sdd.source_deal_header_id
		   HAVING MAX(tmp.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tmp.volume))
		 ) a
		  INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		'
		--AND a.code IS NOT NULL
	-- logic that checks that certificate falls within the given range
	
		  
		 EXEC spa_print @sql
		 EXEC spa_print @sql2
		 EXEC(@sql2)
		 
		 
		
		 
		 
		IF EXISTS(SELECT 1 FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		INNER JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
		INNER JOIN #tmp_dff3 tmp ON tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		)
		BEGIN
		 
			SET @sql2 = 'UPDATE sdd set sdd.volume_left = sdd.deal_volume - new_volume FROM (
			SELECT  (MAX(volume) * SUM(auto_assignment_per)) new_volume, a.source_deal_header_id FROM
			(
			SELECT MAX(tmp.volume) volume, MAX(rga.auto_assignment_per) auto_assignment_per, MAX(sdd.source_deal_header_id) source_deal_header_id, MAX(sdd3.source_deal_detail_id) assigned_source_deal_header_id 
			FROM source_deal_header sdh 
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			LEFT JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
			LEFT JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
			LEFT JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id 
			LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh3.counterparty_id
			INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
			LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
				AND ISNULL(rga.counterparty_id, sc.source_counterparty_id) = sc.source_counterparty_id
			CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
			
			) tmp  
			LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
			--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
			--			 FROM  source_deal_header sdh2 
			--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
			--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
			--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
			--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
			--) a ON a.code = tmp.generator
			--	AND a.term_start  = tmp.[monthly term]
			--	AND a.gis_certificate_number_from = tmp.[cert from]
			CROSS JOIN ( 
					SELECT distinct [state] FROM
						(select ' + @name + ' from #tmp_dff3) p
						UNPIVOT
						([state] for #tmp_dff3 IN (' + @name + ')
						) AS unpvt 
					) s
			
			WHERE 1=1 
			AND sdh.assignment_type_value_id IS NULL
			AND sdd.deal_volume <> 0
			AND(1=1
	AND ( 
	 SUBSTRING(ISNULL([cert from],''-1''),0,CHARINDEX(''-'',ISNULL([cert from],''-1'')))+''-''+''s.state''+''-''+ SUBSTRING(SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))),CHARINDEX(''-'',SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))))+1,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'') )))
	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1)
	 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		)
	 OR (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				AND sdh.assignment_type_value_id IS NULL
		
		)
		)
			  GROUP BY sdd.source_deal_header_id, rga.generator_assignment_id
			  HAVING MAX(tmp.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tmp.volume))
			  ) a  GROUP BY a.source_deal_header_id
				) b
				INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = b.source_deal_header_id
			  INNER JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd.source_deal_detail_id
			--AND a.code IS NOT NULL
		-- logic that checks that certificate falls within the given range
	'
	
			  
			  
			 EXEC spa_print @sql
			 EXEC spa_print @sql2
			 EXEC(@sql2)
			 
		END
		 
		  
		 --select * from #tmp_dff3
		 --COMMIT RETURN
		
		IF OBJECT_ID('tempdb..#assignment_source_deal_header') IS NOT NULL
			DROP TABLE #assignment_source_deal_header
		
		SELECT * INTO #assignment_source_deal_header FROM source_deal_header where assignment_type_value_id IS NOT NULL
		 
		 
		 --Updating assigned deal volume
		 
		SET @sql = 'UPDATE sdd set sdd.deal_volume = a.new_volume FROM
		(
		SELECT   MAX(sdd3.source_deal_header_id) source_deal_header_id, (MAX(rga.auto_assignment_per) * MAX(tmp.volume)) new_volume 
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		INNER JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		INNER JOIN #assignment_source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id 
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh3.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		INNER JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
			AND ISNULL(rga.counterparty_id, sc.source_counterparty_id) = sc.source_counterparty_id
			AND sdh3.assignment_type_value_id = rga.auto_assignment_type
		CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
			
			) tmp 
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
		--			 FROM  source_deal_header sdh2 
		--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
		--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
		--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
		--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		--) a ON a.code = tmp.generator
		--	AND a.term_start  = tmp.[monthly term]
		--	AND a.gis_certificate_number_from = tmp.[cert from]
		CROSS JOIN ( 
				SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt 
				) s
		
		WHERE 1=1 
		--AND a.code IS NOT NULL
		-- logic that checks that certificate falls within the given range
	AND (
	 SUBSTRING(ISNULL([cert from],''-1''),0,CHARINDEX(''-'',ISNULL([cert from],''-1'')))+''-''+''s.state''+''-''+ SUBSTRING(SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))),CHARINDEX(''-'',SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))))+1,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'') )))
	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1)
	 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				
		)
	 OR (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				
		
		)
		  GROUP BY  sdd3.source_deal_header_id, rga.generator_assignment_id
		  HAVING MAX(tmp.volume) >= MAX(aa2.assigned_volume)
		 ) a
		  INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		  '
		  
		  
		 EXEC spa_print @sql
		 EXEC(@sql)
		 
		
		 
		 SET @sql = 'UPDATE aa set aa.assigned_volume = a.new_volume FROM
		(
		SELECT   MAX(sdd3.source_deal_detail_id) source_deal_header_id, (MAX(rga.auto_assignment_per) * MAX(tmp.volume)) new_volume 
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		INNER JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		INNER JOIN #assignment_source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh3.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		INNER JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
			AND ISNULL(rga.counterparty_id, sc.source_counterparty_id) = sc.source_counterparty_id 
			AND sdh3.assignment_type_value_id = rga.auto_assignment_type
		CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
			
			) tmp 
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
		--			 FROM  source_deal_header sdh2 
		--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
		--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
		--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
		--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		--) a ON a.code = tmp.generator
		--	AND a.term_start  = tmp.[monthly term]
		--	AND a.gis_certificate_number_from = tmp.[cert from]
		CROSS JOIN ( 
				SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt 
				) s
		
		WHERE 1=1 
		--AND a.code IS NOT NULL
		AND (
	 SUBSTRING(ISNULL([cert from],''-1''),0,CHARINDEX(''-'',ISNULL([cert from],''-1'')))+''-''+''s.state''+''-''+ SUBSTRING(SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))),CHARINDEX(''-'',SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))))+1,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'') )))
	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1)
	 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				
		)
	 OR (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				
		
		)
		  GROUP BY  sdd3.source_deal_header_id, rga.generator_assignment_id
		  HAVING MAX(tmp.volume) >= MAX(aa2.assigned_volume)
		 ) a
		  INNER JOIN assignment_audit aa ON aa.source_deal_header_id = a.source_deal_header_id
		  '
		  
		  
		 EXEC spa_print @sql
		 EXEC(@sql)
		 
		
		--select * from #tmp_dff3
		
		--select * from #update_source_deal_header_id
		
		--inserting source_deal_header_id of assigned deal that is updated
		SET @sql = 'INSERT INTO #update_assigned_source_deal_header_id(source_deal_header_id_from, source_deal_header_id, row_order, row_no)
		SELECT sdh.source_deal_header_id, sdh3.source_deal_header_id, ROW_NUMBER() OVER(ORDER BY sdh3.source_deal_header_id)
		, MAX(tmp.row_no) FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
			
			) tmp 
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
		--			 FROM  source_deal_header sdh2 
		--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
		--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
		--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
		--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		--) a ON a.code = tmp.generator
		--	AND a.term_start  = tmp.[monthly term]
		--	AND ISNULL(a.gis_certificate_number_from, tmp.[cert from]) = tmp.[cert from]
		CROSS JOIN ( 
				SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt 
				) s
		INNER JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		INNER JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		INNER JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id 
		WHERE 1=1 
			--AND a.code IS NULL
		AND (
	 SUBSTRING(ISNULL([cert from],''-1''),0,CHARINDEX(''-'',ISNULL([cert from],''-1'')))+''-''+''s.state''+''-''+ SUBSTRING(SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))),CHARINDEX(''-'',SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))))+1,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'') )))
	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1)
	 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				
		)
	 OR (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				
		
		)
		GROUP BY sdh.source_deal_header_id, sdh3.source_deal_header_id
		HAVING MAX(tmp.volume) >= MAX(aa2.assigned_volume)
		'
		
		EXEC spa_print @sql
		exec(@sql)
		
		--select * from #tmp_dff3


		--select * from #tmp_dff3 where [monthly term] = '2011/5/1'
		--select * from #update_source_deal_header_id where row_no = '__farrms__101'
		
		--source_deal_header_id of updated deals  
		SET @sql = 'INSERT INTO #update_source_deal_header_id(source_deal_header_id, row_no)
		SELECT sdh.source_deal_header_id, MAX(tmp.row_no)  FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		CROSS APPLY(SELECT  * FROM #tmp_dff3 tmp WHERE tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
			
			) tmp 
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
		--			 FROM  source_deal_header sdh2 
		--				INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
		--				INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
		--				INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
		--				INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		--) a ON a.code = tmp.generator
		--	AND a.term_start  = tmp.[monthly term]
		--	AND ISNULL(a.gis_certificate_number_from, tmp.[cert from]) = tmp.[cert from]
		CROSS JOIN ( 
				SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt 
				) s
		LEFT JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		WHERE 1=1 
		AND sdh.assignment_type_value_id IS NULL
		AND sdd.deal_volume <> 0
			--AND a.code IS NULL
		AND(1=1
		AND (
	 SUBSTRING(ISNULL([cert from],''-1''),0,CHARINDEX(''-'',ISNULL([cert from],''-1'')))+''-''+''s.state''+''-''+ SUBSTRING(SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))),CHARINDEX(''-'',SUBSTRING(ISNULL([cert from],''-1''),CHARINDEX(''-'',ISNULL([cert from],''-1''))+1,LEN(ISNULL([cert from],''-1''))))+1,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'') )))
	 = SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1)
	 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
				
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
			AND sdh.assignment_type_value_id IS NULL
		)
	 OR (
			SUBSTRING(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''),0,LEN(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))-(CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1''))))+1 )
			= SUBSTRING(ISNULL([cert from],''-1''),0,LEN(ISNULL([cert from],''-1''))-(CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1''))))+1 )
			 AND	(
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) BETWEEN 
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT)
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT)
				
					AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc2.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
					CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
				)
				
		AND sdh.assignment_type_value_id IS NULL
		)
		)
		GROUP BY sdh.source_deal_header_id
		HAVING MAX(tmp.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tmp.volume))
		'
		
		EXEC spa_print @sql
		exec(@sql)
		
		--return
		--commit return
		
		--select * from #update_source_deal_header_id
			
--		--select * from #inserted_source_deal_header_id
	END
	ELSE IF EXISTS(SELECT 1 from #flag where flag = 'o')
	BEGIN
		UPDATE sdd SET sdd.deal_volume = b.volume FROM
		(SELECT SUM(CAST(a.volume AS FLOAT)) volume, a.source_deal_header_id source_deal_header_id FROM
		(select max(tmp.volume) volume,sdd.source_deal_header_id
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		INNER JOIN #tmp_dff3 tmp ON tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
		LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
					 FROM  source_deal_header sdh2 
						INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
						INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
						INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
						INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		) a ON a.code = tmp.generator
			AND a.term_start  = tmp.[monthly term]
			AND a.gis_certificate_number_from = tmp.[cert from]
		WHERE 1=1 
		AND a.code IS NULL
		AND gc2.gis_certificate_number_from IS NULL
		GROUP BY tmp.row_no, sdd.source_deal_header_id
		) a  group by a.source_deal_header_id
		) b INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id = b.source_deal_header_id
		  
		INSERT INTO #update_source_deal_header_id2(source_deal_header_id, row_no)
		SELECT sdh.source_deal_header_id, tmp.row_no FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		LEFT JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		INNER JOIN #tmp_dff3 tmp ON tmp.generator = rg.code
			AND (tmp.[monthly term]) = sdd.term_start
		LEFT JOIN (SELECT rg2.code, sdd2.term_start, gc2.gis_certificate_number_from
					 FROM  source_deal_header sdh2 
						INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
						INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd2.source_deal_detail_id
						INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
						INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
		) a ON a.code = tmp.generator
			AND a.term_start  = tmp.[monthly term]
			AND a.gis_certificate_number_from = tmp.[cert from]
		WHERE 1=1 
			AND a.code IS NULL
			AND gc2.gis_certificate_number_from IS NULL
			AND (CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) -
			CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) + 1) = volume
		GROUP BY sdh.source_deal_header_id, tmp.row_no
			
--		--select * from #inserted_source_deal_header_id
	END
	IF EXISTS(SELECT 1 from #flag where flag = 'i')
	BEGIN
			
			--select * from #tmp_dff3
			
			--SELECT * FROM #temp_dff3
			--select * from #tmp_dff3
			--select * from #state2
			
			--UPDATE #tmp_dff3 set state = 'CA'
			--select * from #tmp_dff3
			--select * from #update_source_deal_header_id
			--commit
			--return

		--	SELECT 
		
		
			INSERT INTO source_deal_header (deal_id, physical_financial_flag, option_flag, option_type, 
			 description1, description2, description3, header_buy_sell_flag, source_deal_type_id, 
			deal_sub_type_type_id,   internal_deal_type_value_id, internal_deal_subtype_value_id, 
			deal_status, deal_category_value_id, 
			legal_entity, commodity_id, internal_portfolio_id, product_id, internal_desk_id, block_type, block_define_id, 
			granularity_id, Pricing,  
			contract_id, counterparty_id, deal_rules, confirm_rule, trader_id, 
			source_system_id, deal_date, ext_deal_id, structured_deal_id, 
			entire_term_start, entire_term_end, option_excercise_type, broker_id, generator_id, status_value_id, 
			status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, 
			generation_source, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, 
			rolling_avg, reference, deal_locked, close_reference_id, deal_reference_type_id, unit_fixed_flag, 
			broker_unit_fees, broker_fixed_cost, broker_currency_id, term_frequency, option_settlement_date, 
			verified_by, verified_date, risk_sign_off_by, risk_sign_off_date, back_office_sign_off_by, 
			back_office_sign_off_date, book_transfer_id, confirm_status_type, source_system_book_id1,
			source_system_book_id2, source_system_book_id3, source_system_book_id4,template_id)

			OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id
			INTO #inserted_source_deal_header_id(source_deal_header_id, row_no)
			SELECT 
			--'__farrms__' + CAST( ROW_NUMBER() OVER( ORDER BY td.row_no) AS VARCHAR), 
			td.row_no,
			physical_financial_flag, option_flag, option_type, 
			description1, description2, description3, header_buy_sell_flag, source_deal_type_id, 
			deal_sub_type_type_id, internal_deal_type_value_id, internal_deal_subtype_value_id, 
			5605, deal_category_value_id, 
			legal_entity, commodity_id, internal_portfolio_id, product_id, internal_desk_id, block_type, block_define_id, 
			granularity_id, Pricing,  
			isnull(rg.ppa_contract_id,contract_id), isnull(rg.ppa_counterparty_id,counterparty_id), deal_rules, confirm_rule, trader_id, 
			source_system_id, CASE WHEN dbo.fnastddate(dbo.fnadateformat(td.[monthly term])) <= GETDATE() THEN dbo.fnastddate(dbo.fnadateformat(td.[monthly term])) ELSE GETDATE() END deal_date, ext_deal_id, structured_deal_id, 
			dbo.fnastddate(dbo.fnadateformat(td.[monthly term])) entire_term_start,  CAST (cast(YEAR(td.[monthly term]) AS VARCHAR)+ '-' +  cast(MONTH(td.[monthly term]) AS VARCHAR)+ '-' + CAST(dbo.FNALastDayInMonth(td.[monthly term]) AS VARCHAR) AS DATETIME) entire_term_end, option_excercise_type, broker_id, rg.generator_id, status_value_id, 
			status_date, assignment_type_value_id, compliance_year, sdht.state_value_id, assigned_date, assigned_by, 
			generation_source, sdht.aggregate_environment, sdht.aggregate_envrionment_comment, sdht.rec_price, sdht.rec_formula_id, 
			rolling_avg, reference, deal_locked, close_reference_id, deal_reference_type_id, unit_fixed_flag, 
			broker_unit_fees, broker_fixed_cost, broker_currency_id, term_frequency, option_settlement_date, 
			verified_by, verified_date, risk_sign_off_by, risk_sign_off_date, back_office_sign_off_by, 
			back_office_sign_off_date, book_transfer_id, confirm_status_type, ssbm.source_system_book_id1,
			ssbm.source_system_book_id2, ssbm.source_system_book_id3, ssbm.source_system_book_id4,  @template_id
			--select rg.name,td.*
			FROM source_deal_header_template sdht
			CROSS JOIN #tmp_dff3 td 
			LEFT JOIN #update_source_deal_header_id usd ON usd.row_no = td.row_no
			LEFT JOIN #already_assigned aa ON aa.row_no = td.row_no
			INNER JOIN rec_generator rg ON rg.code = td.generator
			CROSS APPLY (SELECT COUNT(ssbm.logical_name) cnt FROM source_system_book_map ssbm
			WHERE ssbm.fas_book_id = rg.fas_book_id
			) ssbm2 
			CROSS APPLY (SELECT * FROM source_system_book_map ssbm
				WHERE ssbm.fas_book_id = rg.fas_book_id
					AND ssbm.fas_deal_type_value_id = 400
				) ssbm3 
			INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = rg.fas_book_id 
			LEFT JOIN (SELECT rg2.code, sdd.term_start, gc.gis_certificate_number_from
						 FROM  source_deal_header sdh 
							INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
							INNER JOIN #gis_certificate2 gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
							INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh.generator_id
							--INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd.source_deal_detail_id
			) a ON a.code = td.generator
				AND a.term_start = td.[monthly term]
				AND a.gis_certificate_number_from = td.[cert from]	
			WHERE 1=1 
			AND a.code IS NULL 
			AND aa.row_no IS NULL
			AND usd.row_no IS NULL
			AND CASE WHEN td.[cert to] IS NOT NULL THEN (CAST(REVERSE(SUBSTRING(REVERSE( td.[cert to]),0,CHARINDEX('-',REVERSE( td.[cert to]),0))) AS INT) -
			CAST(REVERSE(SUBSTRING(REVERSE( td.[cert from]),0,CHARINDEX('-',REVERSE( td.[cert from]),0))) AS INT) + 1) ELSE  CAST(td.volume AS FLOAT) END =  CAST(td.volume AS FLOAT)
			AND sdht.template_id = @template_id 
			AND CASE WHEN ssbm2.cnt > 1 THEN ssbm.logical_name ELSE 
			'%' + td.[state] + '%' END LIKE '%'+ td.[state] + '%'
			AND ssbm.book_deal_type_map_id = CASE WHEN ssbm2.cnt > 1 THEN ssbm3.book_deal_type_map_id ELSE ssbm.book_deal_type_map_id END
			--CONCAT ('%',CONCAT((td.[state]),'%')) END LIKE CONCAT ('%',CONCAT((td.[state]),'%'))
			
			--rollback return
			
	
				INSERT INTO source_deal_header (deal_id, physical_financial_flag, option_flag, option_type, 
				description1, description2, description3, header_buy_sell_flag, source_deal_type_id, 
				deal_sub_type_type_id,   internal_deal_type_value_id, internal_deal_subtype_value_id, 
				deal_status, deal_category_value_id, 
				legal_entity, commodity_id, internal_portfolio_id, product_id, internal_desk_id, block_type, block_define_id, 
				granularity_id, Pricing,  
				contract_id, counterparty_id, deal_rules, confirm_rule, trader_id, 
				source_system_id, deal_date, ext_deal_id, structured_deal_id, 
				entire_term_start, entire_term_end, option_excercise_type, broker_id, generator_id, status_value_id, 
				status_date, assignment_type_value_id, compliance_year, state_value_id, assigned_date, assigned_by, 
				generation_source, aggregate_environment, aggregate_envrionment_comment, rec_price, rec_formula_id, 
				rolling_avg, reference, deal_locked, close_reference_id, deal_reference_type_id, unit_fixed_flag, 
				broker_unit_fees, broker_fixed_cost, broker_currency_id, term_frequency, option_settlement_date, 
				verified_by, verified_date, risk_sign_off_by, risk_sign_off_date, back_office_sign_off_by, 
				back_office_sign_off_date, book_transfer_id, confirm_status_type, source_system_book_id1,
				source_system_book_id2, source_system_book_id3, source_system_book_id4,template_id)

				OUTPUT INSERTED.source_deal_header_id, INSERTED.deal_id
				INTO #inserted_source_deal_header_id(source_deal_header_id, row_no)
				
				SELECT 
				--'__farrms__' + CAST( ROW_NUMBER() OVER( ORDER BY td.row_no) AS VARCHAR), 
				MAX(td.row_no),
				MAX(physical_financial_flag), MAX(option_flag), MAX(option_type), 
				MAX(description1), MAX(description2), MAX(description3), MAX(header_buy_sell_flag), MAX(source_deal_type_id), 
				MAX(deal_sub_type_type_id), MAX(internal_deal_type_value_id), MAX(internal_deal_subtype_value_id), 
				5605, MAX(deal_category_value_id), 
				MAX(legal_entity), MAX(commodity_id), MAX(internal_portfolio_id), MAX(product_id), MAX(internal_desk_id), MAX(block_type), MAX(block_define_id), 
				MAX(granularity_id), MAX(Pricing),  
				isnull(MAX(rg.ppa_contract_id),MAX(contract_id)), isnull(MAX(rg.ppa_counterparty_id),MAX(counterparty_id)), MAX(deal_rules), MAX(confirm_rule), MAX(trader_id), 
				MAX(source_system_id), CASE WHEN dbo.fnastddate(dbo.fnadateformat(MAX(td.[monthly term]))) <= GETDATE() THEN dbo.fnastddate(dbo.fnadateformat(MAX(td.[monthly term]))) ELSE GETDATE() END deal_date, MAX(ext_deal_id), MAX(structured_deal_id), 
				dbo.fnastddate(dbo.fnadateformat(MAX(td.[monthly term]))) entire_term_start,  CAST (cast(YEAR(MAX(td.[monthly term])) AS VARCHAR)+ '-' +  cast(MONTH(MAX(td.[monthly term])) AS VARCHAR)+ '-' + CAST(dbo.FNALastDayInMonth(MAX(td.[monthly term])) AS VARCHAR) AS DATETIME) entire_term_end, MAX(option_excercise_type), MAX(broker_id), MAX(rg.generator_id), MAX(status_value_id), 
				MAX(status_date), MAX(assignment_type_value_id), MAX(compliance_year), MAX(sdht.state_value_id), MAX(assigned_date), MAX(assigned_by), 
				MAX(generation_source), MAX(sdht.aggregate_environment), MAX(sdht.aggregate_envrionment_comment), MAX(sdht.rec_price), MAX(sdht.rec_formula_id), 
				MAX(rolling_avg), MAX(reference), MAX(deal_locked), MAX(close_reference_id), MAX(deal_reference_type_id), MAX(unit_fixed_flag), 
				MAX(broker_unit_fees), MAX(broker_fixed_cost), MAX(broker_currency_id), MAX(term_frequency), MAX(option_settlement_date), 
				MAX(verified_by), MAX(verified_date), MAX(risk_sign_off_by), MAX(risk_sign_off_date), MAX(back_office_sign_off_by), 
				MAX(back_office_sign_off_date), MAX(book_transfer_id), MAX(confirm_status_type), MAX(ssbm.source_system_book_id1),
				MAX(ssbm.source_system_book_id2), MAX(ssbm.source_system_book_id3), MAX(ssbm.source_system_book_id4),  @template_id
				--select rg.name,td.*
				FROM source_deal_header_template sdht
				CROSS JOIN #tmp_dff3 td 
				LEFT JOIN #inserted_source_deal_header_id isdh ON isdh.row_no = td.row_no
				LEFT JOIN #update_source_deal_header_id usd ON usd.row_no = td.row_no
				LEFT JOIN #already_assigned aa ON aa.row_no = td.row_no
				INNER JOIN rec_generator rg ON rg.code = td.generator
				CROSS APPLY (SELECT COUNT(ssbm.logical_name) cnt FROM source_system_book_map ssbm
				WHERE ssbm.fas_book_id = rg.fas_book_id
				) ssbm2 
				CROSS APPLY (SELECT * FROM source_system_book_map ssbm
				WHERE ssbm.fas_book_id = rg.fas_book_id
					AND ssbm.fas_deal_type_value_id = 400
				) ssbm3 
				INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = rg.fas_book_id 
				LEFT JOIN (SELECT rg2.code, sdd.term_start, gc.gis_certificate_number_from
							 FROM  source_deal_header sdh 
								INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
								INNER JOIN #gis_certificate2 gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
								INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh.generator_id
								--INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd.source_deal_detail_id
				) a ON a.code = td.generator
					AND a.term_start = td.[monthly term]
					AND a.gis_certificate_number_from = td.[cert from]	
				WHERE 1=1 
				AND a.code IS NULL 
				AND aa.row_no IS NULL
				AND usd.row_no IS NULL
				AND isdh.row_no IS NULL
				AND CASE WHEN td.[cert to] IS NOT NULL THEN (CAST(REVERSE(SUBSTRING(REVERSE( td.[cert to]),0,CHARINDEX('-',REVERSE( td.[cert to]),0))) AS INT) -
				CAST(REVERSE(SUBSTRING(REVERSE( td.[cert from]),0,CHARINDEX('-',REVERSE( td.[cert from]),0))) AS INT) + 1) ELSE  CAST(td.volume AS FLOAT) END =  CAST(td.volume AS FLOAT)
				AND sdht.template_id = @template_id 
				AND ssbm.book_deal_type_map_id = CASE WHEN ssbm2.cnt > 1 THEN ssbm3.book_deal_type_map_id ELSE ssbm.book_deal_type_map_id END
				GROUP BY td.row_no
				
			
				

			UPDATE sdh SET sdh.deal_id = cast(isdh.source_deal_header_id AS VARCHAR) + '-farrms' 
			FROM source_deal_header sdh
			INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
			 
			insert into source_deal_detail (source_deal_header_id,leg, fixed_float_leg, buy_sell_flag, curve_id, deal_volume_frequency,
			deal_volume_uom_id,  block_description,   
			day_count_id, physical_financial_flag, location_id, meter_id, pay_opposite, 
			settlement_currency, standard_yearly_volume, price_uom_id, category, profile_code, pv_party,
			adder_currency_id, booked, deal_detail_description, fixed_cost,
			fixed_cost_currency_id, formula_currency_id, formula_curve_id, formula_id, multiplier,
			option_strike_price, price_adder, price_adder_currency2, price_adder2, price_multiplier,
			process_deal_status, settlement_date, settlement_uom, settlement_volume, 
			volume_left, volume_multiplier2, term_start, term_end, contract_expiration_date, 
			fixed_price_currency_id, deal_volume)

			SELECT isdh.source_deal_header_id, leg, fixed_float_leg, buy_sell_flag, isnull(rg.source_curve_def_id, curve_id), deal_volume_frequency,
			deal_volume_uom_id, block_description,  
			 day_count_id, sddt.physical_financial_flag, sddt.location_id, meter_id, pay_opposite, 
			settlement_currency, standard_yearly_volume, price_uom_id, category, profile_code, pv_party,
			adder_currency_id, booked, deal_detail_description, fixed_cost,
			fixed_cost_currency_id, formula_currency_id, formula_curve_id, formula_id, multiplier,
			option_strike_price, price_adder, price_adder_currency2, price_adder2, price_multiplier,
			process_deal_status, settlement_date, settlement_uom, settlement_volume, 
			volume_left, volume_multiplier2, dbo.fnastddate(dbo.fnadateformat(td.[monthly term])) term_start, CAST (cast(YEAR(td.[monthly term]) AS VARCHAR)+ '-' +  cast(MONTH(td.[monthly term]) AS VARCHAR)+ '-' + CAST(dbo.FNALastDayInMonth(td.[monthly term]) AS VARCHAR) AS DATETIME) term_end, CAST (cast(YEAR(td.[monthly term]) AS VARCHAR)+ '-' +  cast(MONTH(td.[monthly term]) AS VARCHAR)+ '-' + CAST(1 AS VARCHAR) AS DATETIME) contract_expiration_date, 
			fixed_price_currency_id, td.volume
			FROM source_deal_detail_template sddt 
			INNER JOIN source_deal_header_template sdht ON sddt.template_id = sdht.template_id
			CROSS JOIN #tmp_dff3 td 
			INNER JOIN rec_generator rg ON rg.code = td.generator
			--INNER JOIN source_deal_header sdh ON sdh.template_id = sdht.template_id
			INNER JOIN #inserted_source_deal_header_id isdh ON isdh.row_no = td.row_no
			WHERE sddt.template_id = @template_id 
			
		--	if object_id('tempdb..#tmp_update') IS NOT NULL
		--		DROP table #tmp_update

		--		--select * from #tmp_dff3
		--		--select * from #tmp_update
			
		-- SELECT tmp.generator,max(tmp.volume) volume, tmp.[monthly term], max(tmp.row_no) row_no, max(tmp.[cert from]) [cert from], max(tmp.[cert to]) [cert to]
		-- INTO #tmp_update
		--  FROM source_deal_header sdh 
		--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		--INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		--INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
		--INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--CROSS APPLY(SELECT  tmp.volume, tmp.row_no, tmp.generator, tmp.[monthly term], tmp.[cert from], tmp.[cert to] FROM #tmp_dff3 tmp 
		--	LEFT JOIN #inserted_source_deal_header_id isdhi ON isdhi.row_no = tmp.row_no
		--	WHERE tmp.generator = rg.code
		--	AND (tmp.[monthly term]) = sdd.term_start
		--	AND tmp.[cert from] = gc2.gis_certificate_number_from
		--	and gc2.gis_certificate_number_to = tmp.[cert to]
		--	AND isdhi.row_no IS NULL
		--	) tmp 
		
		--LEFT JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		--LEFT JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		--LEFT JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id 
		----WHERE gc2.gis_certificate_number_from IS NULL
		--	--AND ISNULL(sdd.[status],-1) = 25001
		--GROUP BY  tmp.generator, tmp.[monthly term] 
		--  HAVING MAX(tmp.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tmp.volume))
		--  AND COUNT(sdd.source_deal_header_id) > 1

		--  UPDATE sdd SET sdd.deal_volume = a.volume FROM
		--  (
		-- select max(tu.volume) volume, sdd.source_deal_header_id FROM source_deal_header sdh 
		--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		--INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		--INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
		--INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--INNER JOIN #tmp_update tu ON tu.generator = rg.code
		--	AND (tu.[monthly term]) = sdd.term_start
		--	AND gc2.gis_certificate_number_from = tu.[cert from]
		--	and gc2.gis_certificate_number_to = tu.[cert to]
		
		--LEFT JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		--LEFT JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		--LEFT JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id 
		----WHERE gc2.gis_certificate_number_from IS NULL
		--	--AND ISNULL(sdd.[status],-1) = 25001
		--GROUP BY  sdd.source_deal_header_id
		--  HAVING MAX(tu.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tu.volume))
		--  ) a 
		--  INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = a.source_deal_header_id
		  
		--  INSERT INTO #update_source_deal_header_id(source_deal_header_id, row_no)
		--  select  sdd.source_deal_header_id, max(tu.row_no) row_no FROM source_deal_header sdh 
		--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		--INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
		--INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
		--LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
		--INNER JOIN #gis_certificate2 gc2 ON gc2.source_deal_header_id = sdd.source_deal_detail_id
		--INNER JOIN #tmp_update tu ON tu.generator = rg.code
		--	AND (tu.[monthly term]) = sdd.term_start
		--	AND gc2.gis_certificate_number_from = tu.[cert from]
		--	and gc2.gis_certificate_number_to = tu.[cert to]
		
		--LEFT JOIN assignment_audit aa2 ON aa2.source_deal_header_id_from = sdd.source_deal_detail_id
		--LEFT JOIN source_deal_detail sdd3 ON sdd3.source_deal_detail_id = aa2.source_deal_header_id
		--LEFT JOIN source_deal_header sdh3 ON sdh3.source_deal_header_id = sdd3.source_deal_header_id 
		----WHERE gc2.gis_certificate_number_from IS NULL
		--	--AND ISNULL(sdd.[status],-1) = 25001
		--GROUP BY  sdd.source_deal_header_id
		--  HAVING MAX(tu.volume) >= ISNULL(MAX(aa2.assigned_volume), MAX(tu.volume))
		  
		 --EXEC spa_print @sql
		 --EXEC(@sql)
		 --select * from #tmp_dff3
		 --select * from #inserted_source_deal_header_id

		

			DECLARE @report_position_deals VARCHAR(300), @process_id3 VARCHAR(300)
			SET @process_id3 = REPLACE(newid(),'-','_')
			SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id3)

			--exec('IF OBJECT_ID(' + @report_position_deals + ') is not null
			--DROP TABLE ' + @report_position_deals )
			EXEC ('CREATE TABLE ' + @report_position_deals + '( source_deal_header_id INT, action CHAR(1))')

			SET @sql = 'INSERT INTO ' + @report_position_deals + '(source_deal_header_id,action) 
			SELECT source_deal_header_id,''i'' from #inserted_source_deal_header_id'
			EXEC(@sql)

			IF OBJECT_ID('tempdb..#report_position_deals') IS NOT NULL
			DROP TABLE #report_position_deals

			CREATE TABLE #report_position_deals(source_deal_header_id INT, ACTION VARCHAR(100) COLLATE DATABASE_DEFAULT )

			IF OBJECT_ID('tempdb..#deal_header') IS NOT NULL
			DROP TABLE #deal_header

				
		CREATE TABLE #deal_header([source_system_id] [INT] ,[deal_id] [VARCHAR](50) COLLATE DATABASE_DEFAULT 
			, [deal_date] [DATETIME] 
			, [physical_financial_flag] [CHAR](10) COLLATE DATABASE_DEFAULT  
			, [counterparty_id] [INT] ,[entire_term_start] [DATETIME] ,[entire_term_end] [DATETIME] ,[source_deal_type_id] [INT] 
			, [deal_sub_type_type_id] [INT]
			, [option_flag] [CHAR](1) COLLATE DATABASE_DEFAULT  
			, [option_type] [CHAR](1) COLLATE DATABASE_DEFAULT 
			, [option_excercise_type] [CHAR](1) COLLATE DATABASE_DEFAULT 
			, [source_system_book_id1] [INT]
			, [source_system_book_id2] [INT]
			, [source_system_book_id3] [INT]
			, [source_system_book_id4] [INT]
			, [description1] [VARCHAR](100) COLLATE DATABASE_DEFAULT 
			, [description2] [VARCHAR](50) COLLATE DATABASE_DEFAULT  
			, [description3] [VARCHAR](50) COLLATE DATABASE_DEFAULT 
			, [deal_category_value_id] [INT] ,[trader_id] [INT] ,[internal_deal_type_value_id] [INT],[internal_deal_subtype_value_id] [INT],[template_id] [INT]
			, [header_buy_sell_flag] [VARCHAR](1) COLLATE DATABASE_DEFAULT 
			, [generator_id] [INT],[assignment_type_value_id] [INT],[compliance_year] [INT],[state_value_id] [INT]
			, [assigned_date] [DATETIME]
			, [assigned_by] [VARCHAR](50) COLLATE DATABASE_DEFAULT 
			, ssb_offset1 [INT],ssb_offset2 [INT],ssb_offset3 [INT],ssb_offset4 [INT]
			, source_deal_header_id INT,structured_deal_id VARCHAR(100) COLLATE DATABASE_DEFAULT 
			, close_reference_id [INT]						
			)

			

			IF OBJECT_ID('tempdb..#deal_detail') IS NOT NULL
			DROP TABLE #deal_detail

			CREATE TABLE #deal_detail([source_deal_header_id] [INT],[term_start] [DATETIME],[term_end] [DATETIME],[leg] [INT]
				, [contract_expiration_date] [DATETIME]
				, [fixed_float_leg] [CHAR](1) COLLATE DATABASE_DEFAULT 
				, [buy_sell_flag] [CHAR](1) COLLATE DATABASE_DEFAULT 
				, [curve_id] [INT],[fixed_price] [FLOAT],[fixed_cost] [FLOAT]
				, [fixed_price_currency_id] [INT]
				, [option_strike_price] [FLOAT]
				, [deal_volume] NUMERIC(38,20)
				, [deal_volume_frequency] [CHAR](1) COLLATE DATABASE_DEFAULT  
				, [deal_volume_uom_id] [INT]
				, [block_description] [VARCHAR](100) COLLATE DATABASE_DEFAULT 
				, [deal_detail_description] [VARCHAR](100) COLLATE DATABASE_DEFAULT 
				, [formula_id] [INT],[settlement_volume] NUMERIC(38,20)
				, [settlement_uom] [INT],source_deal_detail_id INT, capacity INT
			)
						

						
			SET @sql = 'INSERT INTO #report_position_deals SELECT source_deal_header_id,''i'' from #inserted_source_deal_header_id'
			EXEC(@sql)
			
			--SELECT  sdh.source_system_id,
			--		CASE WHEN rga.auto_assignment_type IN (5146,5148) THEN 'Assigned-' +  cast(td.source_deal_header_id as varchar)  + '-' + cast(ISNULL(IDENT_CURRENT('source_deal_header')+(ROW_NUMBER() OVER(ORDER BY (td.source_deal_header_id))),1) as varchar)
			--		 WHEN rga.auto_assignment_type = 5181 THEN 'Offset-' +  cast(td.source_deal_header_id as varchar)  + '-' + cast(ISNULL(IDENT_CURRENT('source_deal_header')+(ROW_NUMBER() OVER(ORDER BY (td.source_deal_header_id))),1) as varchar)
			--		ELSE cast(ISNULL(IDENT_CURRENT('source_deal_header')+(ROW_NUMBER() OVER(ORDER BY (td.source_deal_header_id))),1) as varchar)+'-farrms' END, 
			--		deal_date,  physical_financial_flag, 
			--		ISNULL(rga.counterparty_id,sdh.counterparty_id),
			--		--25, -- greenco
			--		entire_term_start, entire_term_end, 
			--		sdh.source_deal_type_id, sdh.deal_sub_type_type_id, option_flag, option_type, option_excercise_type, 
			--		CASE WHEN rga.auto_assignment_type IN (5146,5148) then ssbm2.source_system_book_id1
			--		 ELSE isnull(ssbm1.source_system_book_id1,ssbm.source_system_book_id1) END,
			--		CASE WHEN rga.auto_assignment_type IN (5146,5148) then ssbm2.source_system_book_id2
			--		ELSE isnull(ssbm1.source_system_book_id2,ssbm.source_system_book_id2) END, 
			--		CASE WHEN rga.auto_assignment_type IN (5146,5148) then ssbm2.source_system_book_id3
			--		ELSE isnull(ssbm1.source_system_book_id3,ssbm.source_system_book_id3) END,
			--		CASE WHEN rga.auto_assignment_type IN (5146,5148) then ssbm2.source_system_book_id4
			--		ELSE isnull(ssbm1.source_system_book_id4,ssbm.source_system_book_id4) END,
			--		description1, description2, description3, sdh.deal_category_value_id, 
			--		ISNULL(rga.trader_id,sdh.trader_id),internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,'s',sdh.generator_id,
			--		ISNULL(rga.contract_id,sdh.contract_id), CAST(sdh.source_deal_header_id AS VARCHAR)+'-'+CAST(ISNULL(rga.generator_assignment_id,0) AS VARCHAR) org_deal_id,
			--		td.source_deal_header_id,'y',5605		
			--	FROM #report_position_deals td	 
			--		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = td.source_deal_header_id
			--		INNER JOIN rec_generator rg on rg.generator_id=sdh.generator_id 
			--		LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
			--		LEFT JOIN source_system_book_map ssbm1 ON ssbm1.book_deal_type_map_id = rga.source_book_map_offset	
			--		LEFT JOIN source_system_book_map ssbm2 ON ssbm2.book_deal_type_map_id = rga.source_book_map_id
			--		LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
			--			AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
			--			AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
			--			AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			--		--INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = 5
			--		LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = ISNULL(ssbm1.fas_book_id,ssbm.fas_book_id)
			--		LEFT JOIN portfolio_hierarchy ph1 ON ph1.entity_id = ph.parent_entity_id
			--		LEFT JOIN portfolio_hierarchy ph2 ON ph2.entity_id = ph1.parent_entity_id	
			--		LEFT JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = ph2.entity_id
			--	WHERE ISNULL(rga.auto_assignment_type,rg.auto_assignment_type) is NOT NULL
		DECLARE @convert_settlement_uom_id INT
		DECLARE @sett_uom VARCHAR(10)
		SET @sett_uom = 'KWh'
		SELECT @convert_settlement_uom_id = source_uom_id FROM source_uom WHERE uom_id = @sett_uom

				SET @sql='
		INSERT INTO source_deal_header
			(source_system_id, deal_id, deal_date,  physical_financial_flag, counterparty_id, entire_term_start, entire_term_end, 
			source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, 
			source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, 
			trader_id,internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,header_buy_sell_flag,generator_id,
			contract_id,structured_deal_id,close_reference_id,deal_locked,
			assignment_type_value_id,compliance_year,state_value_id,assigned_date,assigned_by
			)
		OUTPUT Inserted.source_system_id,Inserted.deal_id,Inserted.deal_date,Inserted.physical_financial_flag,Inserted.counterparty_id,Inserted.entire_term_start,Inserted.entire_term_end,Inserted.source_deal_type_id,Inserted.deal_sub_type_type_id,Inserted.option_flag,Inserted.option_type,Inserted.option_excercise_type,Inserted.source_system_book_id1,Inserted.source_system_book_id2,Inserted.source_system_book_id3,Inserted.source_system_book_id4,Inserted.description1,Inserted.description2,Inserted.description3,Inserted.deal_category_value_id,Inserted.trader_id,Inserted.internal_deal_type_value_id,Inserted.internal_deal_subtype_value_id,Inserted.template_id,Inserted.header_buy_sell_flag,Inserted.generator_id,Inserted.assignment_type_value_id,Inserted.compliance_year,Inserted.state_value_id,Inserted.assigned_date,Inserted.assigned_by,
		Inserted.source_system_book_id1,Inserted.source_system_book_id2,Inserted.source_system_book_id3,Inserted.source_system_book_id4,inserted.source_deal_header_id,inserted.structured_deal_id org_deal_id, inserted.close_reference_id
		INTO #deal_header
		SELECT  sdh.source_system_id,
			CASE WHEN rga.auto_assignment_type = 5181 THEN ''Offset-'' +  cast(td.source_deal_header_id as varchar)  + ''-'' + cast(ISNULL(IDENT_CURRENT(''source_deal_header'')+(ROW_NUMBER() OVER(ORDER BY (td.source_deal_header_id))),1) as varchar)
			ELSE cast(ISNULL(IDENT_CURRENT(''source_deal_header'')+(ROW_NUMBER() OVER(ORDER BY (td.source_deal_header_id))),1) as varchar)+''-farrms'' END, 
			deal_date,  physical_financial_flag, 
			ISNULL(rga.counterparty_id,sdh.counterparty_id),
			--25, -- greenco
			entire_term_start, entire_term_end, 
			sdh.source_deal_type_id, sdh.deal_sub_type_type_id, option_flag, option_type, option_excercise_type, 
			isnull(ssbm1.source_system_book_id1,ssbm.source_system_book_id1),
			isnull(ssbm1.source_system_book_id2,ssbm.source_system_book_id2), 
			isnull(ssbm1.source_system_book_id3,ssbm.source_system_book_id3),
			isnull(ssbm1.source_system_book_id4,ssbm.source_system_book_id4), description1, description2, description3, sdh.deal_category_value_id, 
			ISNULL(rga.trader_id,sdh.trader_id),internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,''s'',sdh.generator_id,
			ISNULL(rga.contract_id,sdh.contract_id), CAST(sdh.source_deal_header_id AS VARCHAR)+''-''+CAST(ISNULL(rga.generator_assignment_id,0) AS VARCHAR) org_deal_id,
			td.source_deal_header_id,''n'',
			ISNULL(rga.auto_assignment_type,rg.auto_assignment_type),YEAR(deal_date),rg.state_value_id,dbo.FNAGetSQLStandardDate(deal_date),'''+@user_login_id+'''				
		FROM #report_position_deals td	 
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = td.source_deal_header_id
			INNER JOIN rec_generator rg on rg.generator_id=sdh.generator_id 
			LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
			LEFT JOIN source_system_book_map ssbm1 ON ssbm1.book_deal_type_map_id = rga.source_book_map_offset	
			LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
				AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
				AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
				AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
			LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = ISNULL(ssbm1.fas_book_id,ssbm.fas_book_id)
			LEFT JOIN portfolio_hierarchy ph1 ON ph1.entity_id = ph.parent_entity_id
			LEFT JOIN portfolio_hierarchy ph2 ON ph2.entity_id = ph1.parent_entity_id	
			LEFT JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = ph2.entity_id
		WHERE ISNULL(rga.auto_assignment_type,rg.auto_assignment_type) is NOT NULL' 	
		
		EXEC(@sql)
		

				SET @sql='
					INSERT INTO source_deal_detail(
						source_deal_header_id,
						term_start,
						term_end,
						leg,
						contract_expiration_date,
						fixed_float_leg,
						buy_sell_flag,
						curve_id,
						fixed_price,
						fixed_cost,
						fixed_price_currency_id,
						option_strike_price,
						deal_volume,
						deal_volume_frequency,
						deal_volume_uom_id,
						block_description,
						deal_detail_description,
						formula_id,
						settlement_volume,
		                settlement_uom,
	 	                capacity,
	 	                physical_financial_flag
					)
			OUTPUT Inserted.source_deal_header_id,Inserted.term_start,Inserted.term_end,Inserted.leg,Inserted.contract_expiration_date,Inserted.fixed_float_leg,Inserted.buy_sell_flag,Inserted.curve_id,Inserted.fixed_price,Inserted.fixed_cost,Inserted.fixed_price_currency_id,Inserted.option_strike_price,Inserted.deal_volume,Inserted.deal_volume_frequency,Inserted.deal_volume_uom_id,Inserted.block_description,Inserted.deal_detail_description,Inserted.formula_id,Inserted.settlement_volume,Inserted.settlement_uom,inserted.source_deal_detail_id, inserted.capacity
					INTO #deal_detail
					select dh.source_deal_header_id,
						sdd.term_start,
						sdd.term_end,
						sdd.leg,
						sdd.term_start,
						sdd.fixed_float_leg,						
						''s'',
				        isnull(rg.source_curve_def_id,sdd.curve_id),
						isnull(sdd.fixed_price, rga.sold_price),
						sdd.fixed_cost,
						sdd.fixed_price_currency_id,
						sdd.option_strike_price,
						CEILING(sdd.deal_volume * CAST(COALESCE(rga.auto_assignment_per,rg.auto_assignment_per,1) AS NUMERIC(18,10))),
						sdd.deal_volume_frequency,
						sdd.deal_volume_uom_id deal_volume_uom_id,
						sdd.block_description,
						sdd.deal_detail_description,
						sdd.formula_id,
						sdd.deal_volume*CAST(conv.conversion_factor AS NUMERIC(18,10)),
		                '+cast(ISNULL(@convert_settlement_uom_id,'NULL') AS VARCHAR)+',
		                CASE WHEN ISNULL(rga.auto_assignment_type,rg.auto_assignment_type) = 5181 THEN sdd.capacity * CAST(COALESCE(rga.auto_assignment_per,rg.auto_assignment_per,1) AS NUMERIC(18,10))
		                ELSE sdd.capacity END,
		                sddt.physical_financial_flag				
			    FROM 
						#deal_header dh
						INNER JOIN rec_generator rg ON rg.generator_id = dh.generator_id
						LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
						INNER JOIN source_deal_header sdh ON CAST(sdh.source_deal_header_id AS VARCHAR)+''-''+CAST(ISNULL(rga.generator_assignment_id,0) AS VARCHAR) = dh.structured_deal_id
						INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN source_deal_detail_template sddt ON sddt.template_id = '+ cast(@template_id AS VARCHAR(20)) +'	
						LEFT JOIN rec_volume_unit_conversion Conv ON Conv.from_source_uom_id = sdd.deal_volume_uom_id   
							AND Conv.to_source_uom_id = '+ cast(@convert_settlement_uom_id AS VARCHAR(20)) +'	       
							And Conv.state_value_id IS NULL
							AND Conv.assignment_type_value_id is null
							AND Conv.curve_id is null 
					WHERE sdd.buy_sell_flag=''b''
						  AND ISNULL(rga.auto_assignment_type,rg.auto_assignment_type) IS NOT NULL'
				EXEC spa_print @sql
				EXEC(@sql)
			
	
						
			--DECLARE @auto_assignment_type INT, @deal_volume FLOAT, @source_deal_detail_id2 INT, @source_deal_detail_id_from INT, @deal_date VARCHAR(100),
			--@state_value_id INT, @assigned_date DATETIME, @cert_to FLOAT
			
			DECLARE @auto_assignment_type2 INT, @deal_volume2 NUMERIC(38,20), @source_deal_detail_id3 INT, @source_deal_detail_id_from2 INT, @deal_date2 VARCHAR(100),
			@state_value_id2 INT, @assigned_date2 DATETIME, @cert_to2 FLOAT
			
			--SELECT * FROM #deal_header
			DECLARE cur_status2 CURSOR LOCAL FOR
			SELECT 
				MAX(ISNULL(rga.auto_assignment_type,rg.auto_assignment_type)),
				MAX(CEILING(dd.deal_volume)),
				dd.source_deal_detail_id,
				sddExt.source_deal_detail_id,
				YEAR(MAX(dh.deal_date)),
				MAX(rg.state_value_id),
				dbo.FNAGetSQLStandardDate(MAX(dh.deal_date)),
				CEILING(MAX(CAST(dd.deal_volume AS VARCHAR)))
			FROM
				#deal_header dh
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id = dh.counterparty_id
				INNER JOIN #deal_detail dd ON dh.source_deal_header_id = dd.source_deal_header_id
				INNER JOIN rec_generator rg ON rg.generator_id = dh.generator_id
				LEFT JOIN rec_generator_assignment rga ON rga.generator_id = rg.generator_id
				--and rga.counterparty_id = sc.source_counterparty_id
				INNER JOIN source_deal_header sdhExt ON sdhExt.source_deal_header_id=CAST(SUBSTRING(dh.structured_deal_id,0,CHARINDEX('-',dh.structured_deal_id,0)) AS INT)
				INNER JOIN source_deal_detail sddExt ON sddExt.source_deal_header_id=sdhExt.source_deal_header_id
				AND sddExt.term_start=dd.term_start
				WHERE sddExt.buy_sell_flag='b'
				 --AND ISNULL(rga.auto_assignment_type,rg.auto_assignment_type) IN (5146,5148,5147)
				 AND ISNULL(rga.auto_assignment_type,rg.auto_assignment_type) is not null	
			GROUP BY dd.source_deal_detail_id,sddExt.source_deal_detail_id
			
			OPEN cur_status2;

			FETCH NEXT FROM cur_status2 INTO @auto_assignment_type2, @deal_volume2, @source_deal_detail_id3, @source_deal_detail_id_from2, @deal_date2,
			@state_value_id2, @assigned_date2, @cert_to2
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
					
		          INSERT INTO
			          assignment_audit(
			          assignment_type,
			          assigned_volume,
			          source_deal_header_id,
			          source_deal_header_id_from,
			          compliance_year,
			          state_value_id,
			          assigned_date,
			          assigned_by,
			          cert_from,
			          cert_to
		          )
		          SELECT @auto_assignment_type2, @deal_volume2, @source_deal_detail_id3, @source_deal_detail_id_from2, @deal_date2,
			          @state_value_id2, @assigned_date2,'Auto Assigned', 1, @cert_to2
	                  
                          FETCH NEXT FROM cur_status2 INTO @auto_assignment_type2, @deal_volume2, @source_deal_detail_id3, @source_deal_detail_id_from2, @deal_date2,
			  @state_value_id2, @assigned_date2, @cert_to2
			
			END;

			CLOSE cur_status2;
			DEALLOCATE cur_status2;	
			
					

		--		--#### if auto assignment then assigne certificate
				INSERT INTO gis_certificate
					( 
					  source_deal_header_id,
					  gis_certificate_number_from,
					  gis_certificate_number_to,
					  certificate_number_from_int,
					  certificate_number_to_int,
					  gis_cert_date	
					 )
				SELECT    
					DISTINCT 	 	  	
					   sdd.source_deal_detail_id,
					   dbo.FNACertificateRule(cr.cert_rule,rg.id,1,sdd.term_start),		   	 	
					   dbo.FNACertificateRule(cr.cert_rule,rg.id,sdd.deal_volume,sdd.term_start),		   	 	
					   1,
					   CEILING(deal_volume),
					   sdd.term_start
				FROM
						#deal_header sdh 
						INNER JOIN #deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id 
						INNER JOIN rec_generator rg ON sdh.generator_id = rg.generator_id     
						INNER JOIN certificate_rule cr ON rg.gis_value_id =cr.gis_id
				WHERE  rg.auto_certificate_number='y'
					   AND sdd.buy_sell_flag='s'
	
	
		
		
			-- Volume Left should be deducted from total volume
			UPDATE sdd
				SET sdd.volume_left = sdd.volume_left - ISNULL(CEILING(rs_tmp.[volume]), 0)
			FROM
				 source_deal_detail sdd
					CROSS APPLY (
						SELECT SUM(deal_volume) volume  
						FROM 
							#deal_detail tmp 
							INNER JOIN assignment_audit au ON au.source_deal_header_id = tmp.source_deal_detail_id
						WHERE source_deal_header_id_from = sdd.source_deal_detail_id
					) rs_tmp 
			WHERE 1 = 1 

			CREATE TABLE #offset_source_deal_header_id (source_deal_header_id INT)
		
		
			INSERT INTO source_deal_header(source_system_id, deal_id, deal_date,  physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end, 
					source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, 
					source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, 
					trader_id,internal_deal_type_value_id,internal_deal_subtype_value_id,template_id,header_buy_sell_flag,generator_id,
                    close_reference_id,contract_id, deal_locked,
					assignment_type_value_id,compliance_year,state_value_id,assigned_date,assigned_by
					)
			SELECT 

					dh.source_system_id,
					--'offset-'+CAST(dh.source_deal_header_id AS VARCHAR),
					CASE WHEN rga.auto_assignment_type = 5181 THEN 'Allocated-' + CAST(dh.source_deal_header_id AS VARCHAR) ELSE 'Offset-' + CAST(dh.source_deal_header_id AS VARCHAR) END,
					dh.deal_date,dh. physical_financial_flag,dh.structured_deal_id,
					ISNULL(fs.counterparty_id,dh.counterparty_id),dh.entire_term_start,dh.entire_term_end,
					dh.source_deal_type_id,dh.deal_sub_type_type_id,dh.option_flag,dh.option_type,dh.option_excercise_type,
					ISNULL(ssbm1.source_system_book_id1,sdh.source_system_book_id1),ISNULL(ssbm1.source_system_book_id2,sdh.source_system_book_id2),ISNULL(ssbm1.source_system_book_id3,sdh.source_system_book_id3),ISNULL(ssbm1.source_system_book_id4,sdh.source_system_book_id4),
					--sdh1.source_system_book_id1,sdh1.source_system_book_id2,sdh1.source_system_book_id3,sdh1.source_system_book_id4,
					dh.description1,dh.description2,dh.description3,dh.deal_category_value_id,dh.trader_id,dh.internal_deal_type_value_id,
					dh.internal_deal_subtype_value_id,dh.template_id,
					CASE WHEN sdh.header_buy_sell_flag = 'b' THEN 's' ELSE 'b' END,
					dh.generator_id,
					sdh.source_deal_header_id,sdh.contract_id, 'y',
					dh.assignment_type_value_id,dh.compliance_year,dh.state_value_id,dh.assigned_date,dh.assigned_by

			FROM
				#deal_header dh
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id=dh.source_deal_header_id
				INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id=CAST(SUBSTRING(dh.structured_deal_id,0,CHARINDEX('-',dh.structured_deal_id,0)) AS INT)
				LEFT JOIN source_deal_header sdh2 ON sdh2.source_deal_header_id = sdh.close_reference_id
				LEFT JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh1.source_system_book_id1
					AND ssbm.source_system_book_id2 = sdh1.source_system_book_id2
					AND ssbm.source_system_book_id3 = sdh1.source_system_book_id3
					AND ssbm.source_system_book_id4 = sdh1.source_system_book_id4
				LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = ssbm.fas_book_id
				LEFT JOIN portfolio_hierarchy ph1 ON ph1.entity_id = ph.parent_entity_id
				LEFT JOIN portfolio_hierarchy ph2 ON ph2.entity_id = ph1.parent_entity_id	
				LEFT JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = ph2.entity_id	
				INNER JOIN rec_generator_assignment rga ON rga.generator_id=dh.generator_id
					AND rga.generator_assignment_id = CAST(SUBSTRING(dh.structured_deal_id,CHARINDEX('-',dh.structured_deal_id,0)+1,LEN(dh.structured_deal_id)) AS INT)
				LEFT JOIN source_system_book_map ssbm1 ON ssbm1.book_deal_type_map_id = rga.source_book_map_id
                
			WHERE
				rga.source_book_map_id IS NOT NULL
			
			INSERT INTO source_deal_detail(source_deal_header_id,term_start,term_end,leg,contract_expiration_date,fixed_float_leg,buy_sell_flag,curve_id,fixed_price,
					fixed_cost,fixed_price_currency_id,option_strike_price,deal_volume,deal_volume_frequency,deal_volume_uom_id,block_description,
					deal_detail_description,formula_id,settlement_volume,settlement_uom, physical_financial_flag)
			SELECT
				sdh.source_deal_header_id,dd.term_start,dd.term_end,dd.leg,dd.contract_expiration_date,dd.fixed_float_leg,
				--CASE WHEN sdh.header_buy_sell_flag = 'b' THEN 'b' ELSE 's' END,dd.curve_id,
				CASE WHEN dd.buy_sell_flag = 'b' THEN 's' ELSE 'b' END, isnull(rg.source_curve_def_id,dd.curve_id),
				dd.fixed_price,
				dd.fixed_cost,dd.fixed_price_currency_id,dd.option_strike_price,dd.deal_volume,dd.deal_volume_frequency,dd.deal_volume_uom_id,dd.block_description,
				dd.deal_detail_description,dd.formula_id,dd.settlement_volume,dd.settlement_uom, sddt.physical_financial_flag	
			FROM
				#deal_detail dd
				INNER JOIN #deal_header dh ON dh.source_deal_header_id=dd.source_deal_header_id
				INNER JOIN source_deal_header sdh ON sdh.close_reference_id=dh.source_deal_header_id
				INNER JOIN rec_generator rg ON rg.generator_id = dh.generator_id
				INNER JOIN source_deal_detail_template sddt ON sddt.template_id = @template_id
				 --INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id=dd.close_reference_id	

			
			SET @sql = 'INSERT INTO #report_position_deals SELECT source_deal_header_id,''i'' from #deal_header'
			EXEC(@sql)
			
			SET @sql = 'INSERT INTO #report_position_deals SELECT source_deal_header_id,''i'' from #offset_source_deal_header_id'
			EXEC(@sql)
			
			
			
				
			
			EXEC spa_update_deal_total_volume NULL, @process_id3  ,0,NULL,@user_login_id,'y'
			
			END
			
			--Commit
			--return
			--select * from #inserted_source_deal_header_id
			
			--inserting certificate of newly created deal
			INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date, state_value_id)
			SELECT sdd.source_deal_detail_id, [cert from], [cert to], 
			CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0)))) 
				WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0)))
				ELSE 1
			END,
			CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))))
				WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0)))
				ELSE sdd.deal_volume
			END,
			GETDATE(),
			sdv.value_id
			FROM source_deal_header sdh
			INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #tmp_dff3 td ON td.row_no = isdh.row_no
			INNER JOIN (SELECT * FROM static_data_value where type_id = 10002) sdv on sdv.code = SUBSTRING([cert from],CHARINDEX('-',[cert from])+1,CHARINDEX('-',SUBSTRING([cert from],CHARINDEX('-',[cert from])+1,LEN([cert from])))-1)
			INNER JOIN (SELECT rg2.code, sdd2.term_start
						FROM  source_deal_header sdh2 
						INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
						INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
						GROUP BY rg2.code, sdd2.term_start
						--INNER JOIN assignment_audit aa on aa.source_deal_header_id = sdd2.source_deal_detail_id
			) a ON a.code = td.generator
			AND a.term_start  = td.[monthly term]
			WHERE NOT EXISTS(
				SELECT 1 FROM source_deal_header sdh
				INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN #tmp_dff3 td ON td.row_no = isdh.row_no
				INNER JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND [cert from] = gc.gis_certificate_number_from
			)
			
	  		--deleting certificate of updated deal
			IF EXISTS(SELECT 1 from #update_source_deal_header_id)
			BEGIN
				DELETE gc 
				from source_deal_header sdh
				INNER JOIN #update_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
			END
			
			--commit return
			
			IF OBJECT_ID('tempdb..#prev_gis_certificate') IS NOT NULL
				DROP TABLE #prev_gis_certificate
			
			CREATE TABLE #prev_gis_certificate(source_deal_header_id INT
				, cert_from VARCHAR(100) COLLATE DATABASE_DEFAULT 
				, cert_from_int INT, cert_to VARCHAR(100) COLLATE DATABASE_DEFAULT  
				, cert_to_int INT)
			
			--select * from #update_assigned_source_deal_header_id
			
			--select * from #update_assigned_source_deal_header_id
			
			--deleting previous certificate of assigned deal and inserting new certificate
			IF EXISTS(SELECT 1 FROM #update_assigned_source_deal_header_id)
			BEGIN
				--SELECT * FROM #prev_gis_certificate
				INSERT INTO #prev_gis_certificate(source_deal_header_id , cert_from, cert_from_int, cert_to, cert_to_int)
				SELECT sdd.source_deal_header_id,gc.gis_certificate_number_from, gc.certificate_number_from_int
				, gc.gis_certificate_number_to, gc.certificate_number_to_int from source_deal_header sdh
				INNER JOIN #update_assigned_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
			
				DELETE gc from source_deal_header sdh
				INNER JOIN #update_assigned_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN gis_certificate gc on gc.source_deal_header_id = sdd.source_deal_detail_id
				
				INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date, state_value_id)
				SELECT MAX(sdd.source_deal_detail_id), SUBSTRING(MAX([cert from]),0,LEN(MAX([cert from]))-(CHARINDEX('-',REVERSE(MAX([cert from]))))+1 ) + '-' + CAST(ISNULL(MAX(pgc.cert_from_int),1) AS VARCHAR),
				SUBSTRING(MAX([cert from]),0,LEN(MAX([cert from]))-(CHARINDEX('-',REVERSE(MAX([cert from]))))+1 ) + '-' + CAST(MAX(dbo.FNARemovetrailingzero(sdd.deal_volume)) AS VARCHAR),
				ISNULL(MAX(pgc.cert_from_int),1),
				MAX(dbo.FNARemovetrailingzero(sdd.deal_volume)),
				GETDATE(),
				MAX(sdv.value_id)
				--select *
				FROM source_deal_header sdh
				INNER JOIN #update_assigned_source_deal_header_id uasdhi ON uasdhi.source_deal_header_id = sdh.source_deal_header_id
				LEFT JOIN #prev_gis_certificate pgc ON pgc.source_deal_header_id = uasdhi.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN #tmp_dff3 td ON td.row_no = uasdhi.row_no
				INNER JOIN (SELECT * FROM static_data_value where type_id = 10002) sdv on sdv.code = SUBSTRING([cert from],CHARINDEX('-',[cert from])+1,CHARINDEX('-',SUBSTRING([cert from],CHARINDEX('-',[cert from])+1,LEN([cert from])))-1)
				INNER JOIN (SELECT rg2.code, sdd2.term_start
						 FROM  source_deal_header sdh2 
							INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
							INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
							GROUP BY rg2.code, sdd2.term_start
				) a ON a.code = td.generator
				AND a.term_start  = td.[monthly term]
				WHERE NOT EXISTS(
					SELECT 1 FROM source_deal_header sdh
					INNER JOIN #update_assigned_source_deal_header_id uasdhi ON uasdhi.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN #tmp_dff3 td ON td.row_no = uasdhi.row_no
					INNER JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND (
					SUBSTRING(COALESCE(gc.gis_certificate_number_from,[cert from],'-1'),0,LEN(COALESCE(gc.gis_certificate_number_from,[cert from],'-1'))-(CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1'))))+1 )
					= SUBSTRING(ISNULL([cert from],'-1'),0,LEN(ISNULL([cert from],'-1'))-(CHARINDEX('-',REVERSE(ISNULL([cert from],'-1'))))+1 )
					 AND	(
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) BETWEEN 
						CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
							AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
						OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT) BETWEEN
						CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
							AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
						
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0))) AS INT) BETWEEN
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
						OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0))) AS INT) BETWEEN
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
						)
					)
				)
				GROUP BY td.row_no, uasdhi.source_deal_header_id
				HAVING MIN(uasdhi.row_order) >= 1
				ORDER BY MAX(uasdhi.source_deal_header_id_from), MIN(uasdhi.row_order)
			END
			
			--IF OBJECT_ID('tempdb..#prev_volume') IS NOT NULL
			--select 1
			--select * from #prev_volume
			--select * from #update_source_deal_header_id
			IF OBJECT_ID('tempdb..#prev_volume') IS NOT NULL
			BEGIN
				INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date, state_value_id)
				SELECT sdd.source_deal_detail_id, SUBSTRING([cert from],0,LEN([cert from])-(CHARINDEX('-',REVERSE([cert from])))+1 ) + '-' +
				CASE WHEN sdd.volume_left = 0 THEN '0' ELSE
				CAST((CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))))
					WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0)))
					ELSE CAST(dbo.FNARemoveTrailingZero(sdd.deal_volume) AS FLOAT)
				END - CAST(dbo.FNARemoveTrailingZero(sdd.volume_left) AS FLOAT) + 1) AS VARCHAR) END,
				SUBSTRING([cert from],0,LEN([cert from])-(CHARINDEX('-',REVERSE([cert from])))+1 ) + '-' +
				CASE WHEN sdd.volume_left = 0 THEN '0' ELSE
				CAST((CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))))
					WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0)))
					ELSE CAST(dbo.FNARemoveTrailingZero(sdd.deal_volume) AS FLOAT) END) AS VARCHAR) END, 
				CASE WHEN sdd.volume_left = 0 THEN '0' ELSE
				CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))))
					WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0)))
					ELSE CAST(dbo.FNARemoveTrailingZero(sdd.deal_volume) AS FLOAT)
				END - CAST(dbo.FNARemoveTrailingZero(sdd.volume_left) AS FLOAT) + 1 END,
				CASE WHEN sdd.volume_left = 0 THEN '0' ELSE
				CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))))
					WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0)))
					ELSE CAST(dbo.FNARemoveTrailingZero(sdd.deal_volume) AS FLOAT)
				END END,
				GETDATE(),
				sdv.value_id
				--select *
				FROM source_deal_header sdh
				INNER JOIN #update_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN #tmp_dff3 td ON td.row_no = isdh.row_no
				INNER JOIN (SELECT * FROM static_data_value where type_id = 10002) sdv on sdv.code = SUBSTRING([cert from],CHARINDEX('-',[cert from])+1,CHARINDEX('-',SUBSTRING([cert from],CHARINDEX('-',[cert from])+1,LEN([cert from])))-1)
				INNER JOIN (SELECT rg2.code, sdd2.term_start
						 FROM  source_deal_header sdh2 
							INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
							INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
							GROUP BY rg2.code, sdd2.term_start
				) a ON a.code = td.generator
				AND a.term_start  = td.[monthly term]
				WHERE NOT EXISTS(
					SELECT 1 FROM source_deal_header sdh
					INNER JOIN #update_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN #tmp_dff3 td ON td.row_no = isdh.row_no
					INNER JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND (
					SUBSTRING(COALESCE(gc.gis_certificate_number_from,[cert from],'-1'),0,LEN(COALESCE(gc.gis_certificate_number_from,[cert from],'-1'))-(CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1'))))+1 )
					= SUBSTRING(ISNULL([cert from],'-1'),0,LEN(ISNULL([cert from],'-1'))-(CHARINDEX('-',REVERSE(ISNULL([cert from],'-1'))))+1 )
					 AND	(
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) BETWEEN 
						CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
							AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
						OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT) BETWEEN
						CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
							AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
						
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0))) AS INT) BETWEEN
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
						OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0))) AS INT) BETWEEN
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
						)
					)
				)
			END
			ELSE
			BEGIN
			--select * from gis_certificate where source_deal_header_id in (46348,46349)
			--select * from #update_source_deal_header_id
			
				--inserting certificate of updated deal
				INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date, state_value_id)
				SELECT sdd.source_deal_detail_id, [cert from], [cert to], 
				CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0)))) 
					WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0)))
					ELSE 1
				END,
				CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))))
					WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0)))
					ELSE sdd.deal_volume
				END,
				GETDATE(),
				sdv.value_id
				--select *
				FROM source_deal_header sdh
				INNER JOIN #update_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN #tmp_dff3 td ON td.row_no = isdh.row_no
				INNER JOIN (SELECT * FROM static_data_value where type_id = 10002) sdv on sdv.code = SUBSTRING([cert from],CHARINDEX('-',[cert from])+1,CHARINDEX('-',SUBSTRING([cert from],CHARINDEX('-',[cert from])+1,LEN([cert from])))-1)
				INNER JOIN (SELECT rg2.code, sdd2.term_start
						 FROM  source_deal_header sdh2 
							INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
							INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
							GROUP BY rg2.code, sdd2.term_start
				) a ON a.code = td.generator
				AND a.term_start  = td.[monthly term]
				--and a.term_start='2011-5-1'
				OUTER APPLY(
					SELECT sdh.source_deal_header_id
					FROM source_deal_header sdh
					INNER JOIN #update_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN #tmp_dff3 td2 ON td2.row_no = isdh.row_no
						and td2.row_no = td.row_no
					INNER JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND (
					SUBSTRING(COALESCE(gc.gis_certificate_number_from,[cert from],'-1'),0,LEN(COALESCE(gc.gis_certificate_number_from,[cert from],'-1'))-(CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1'))))+1 )
					= SUBSTRING(ISNULL([cert from],'-1'),0,LEN(ISNULL([cert from],'-1'))-(CHARINDEX('-',REVERSE(ISNULL([cert from],'-1'))))+1 )
					 AND	(
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) BETWEEN 
						CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
							AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
						OR CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT) BETWEEN
						CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0))) AS INT)
							AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0))) AS INT)
						
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],'-1')),0))) AS INT) BETWEEN
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
						OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0,CHARINDEX('-',REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],'-1')),0))) AS INT) BETWEEN
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert from],'-1')),0))) AS INT) AND
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],'-1')),0,CHARINDEX('-',REVERSE(ISNULL([cert to],'-1')),0))) AS INT)
						)
					)
					--and sdd.term_start='2011-5-1'
						
				) b
				where b.source_deal_header_id IS NULL
				
			END
			
			
			
			
			
			--select * from #update_source_deal_header_id2
			
			INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date, state_value_id)
			SELECT sdd.source_deal_detail_id, [cert from], [cert to], 
			CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0)))) 
				WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0)))
				ELSE 1
			END,
			CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))))
				WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0)))
				ELSE sdd.deal_volume
			END,
			GETDATE(),
			sdv.value_id
			--select *
			FROM source_deal_header sdh
			INNER JOIN #update_source_deal_header_id2 isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #tmp_dff3 td ON td.row_no = isdh.row_no
			INNER JOIN (SELECT * FROM static_data_value where type_id = 10002) sdv on sdv.code = SUBSTRING([cert from],CHARINDEX('-',[cert from])+1,CHARINDEX('-',SUBSTRING([cert from],CHARINDEX('-',[cert from])+1,LEN([cert from])))-1)
			INNER JOIN (SELECT rg2.code, sdd2.term_start
					 FROM  source_deal_header sdh2 
						INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
						INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
						GROUP BY rg2.code, sdd2.term_start
			) a ON a.code = td.generator
			AND a.term_start  = td.[monthly term]
			OUTER APPLY(
				SELECT sdh.source_deal_header_id FROM source_deal_header sdh
				INNER JOIN #update_source_deal_header_id2 isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN #tmp_dff3 td2 ON td.row_no = isdh.row_no
					AND td2.row_no = td.row_no
				INNER JOIN #gis_certificate2 gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
					AND [cert from] = gc.gis_certificate_number_from
			) b
			where b.source_deal_header_id is null
			
			
			--inserting multiple certificate of updated deal
			
			SET @sql = 'DECLARE @state VARCHAR(100)
			DECLARE state_status CURSOR LOCAL FOR
			SELECT distinct [state] FROM
					(select '+ @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt where [state] <> ''No''
				
			OPEN state_status;

			FETCH NEXT FROM state_status INTO @state
			WHILE @@FETCH_STATUS = 0
			BEGIN
					
			INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date, state_value_id)
			SELECT sdd.source_deal_detail_id,
			SUBSTRING([cert from],0,CHARINDEX(''-'',[cert from]))+''-''+@state+''-''+SUBSTRING(SUBSTRING([cert from],CHARINDEX(''-'',[cert from])+1,LEN([cert from])),CHARINDEX(''-'',SUBSTRING([cert from],CHARINDEX(''-'',[cert from])+1,LEN([cert from])))+1,LEN([cert from])),
			SUBSTRING([cert to],0,CHARINDEX(''-'',[cert to]))+''-''+@state+''-''+SUBSTRING(SUBSTRING([cert to],CHARINDEX(''-'',[cert to])+1,LEN([cert to])),CHARINDEX(''-'',SUBSTRING([cert to],CHARINDEX(''-'',[cert to])+1,LEN([cert to])))+1,LEN([cert to])),
			CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX(''-'',REVERSE([cert from]),0)))) 
				WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX(''-'',REVERSE([cert from]),0)))
				ELSE 1
			END,
			CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX(''-'',REVERSE([cert to]),0))))
				WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX(''-'',REVERSE([cert to]),0)))
				ELSE sdd.deal_volume
			END,
			GETDATE(),
			sdv.value_id
			FROM source_deal_header sdh
			INNER JOIN #update_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #tmp_dff3 td ON td.row_no = isdh.row_no
			INNER JOIN (SELECT rg2.code, sdd2.term_start
					 FROM  source_deal_header sdh2 
					 INNER JOIN #update_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh2.source_deal_header_id
						INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
						INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
						GROUP BY rg2.code, sdd2.term_start
			) a ON a.code = td.generator
			AND a.term_start  = td.[monthly term]
			AND (' + @temp_name + ')
			INNER JOIN (SELECT * FROM static_data_value where type_id = 10016) sdv on sdv.code = @state
			WHERE NOT EXISTS
			(
				SELECT 1 FROM source_deal_header sdh
				INNER JOIN #update_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN #gis_certificate2 gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				INNER JOIN #tmp_dff3 td ON td.row_no = isdh.row_no
					 AND 
				-- logic that checks that certificate falls within the given range
				 SUBSTRING([cert from],0,CHARINDEX(''-'',[cert from]))+''-''+@state+''-''+ SUBSTRING(SUBSTRING([cert from],CHARINDEX(''-'',[cert from])+1,LEN([cert from])),CHARINDEX(''-'',SUBSTRING([cert from],CHARINDEX(''-'',[cert from])+1,LEN([cert from])))+1,CHARINDEX(''-'',REVERSE([cert from] )))
				 = SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX(''-'',REVERSE(gc.gis_certificate_number_from)))+1)
				AND	(
						CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX(''-'',REVERSE([cert from]),0))) AS INT) BETWEEN 
						CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX(''-'',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
							AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX(''-'',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
						OR CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX(''-'',REVERSE([cert to]),0))) AS INT) BETWEEN
						CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_from),0,CHARINDEX(''-'',REVERSE(gc.gis_certificate_number_from),0))) AS INT)
							AND CAST(REVERSE(SUBSTRING(REVERSE(gc.gis_certificate_number_to),0,CHARINDEX(''-'',REVERSE(gc.gis_certificate_number_to),0))) AS INT)
					
						AND CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc.gis_certificate_number_from,[cert from],''-1'')),0))) AS INT) BETWEEN
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
						OR CAST(REVERSE(SUBSTRING(REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(COALESCE(gc.gis_certificate_number_to,[cert to],''-1'')),0))) AS INT) BETWEEN
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert from],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert from],''-1'')),0))) AS INT) AND
						CAST(REVERSE(SUBSTRING(REVERSE(ISNULL([cert to],''-1'')),0,CHARINDEX(''-'',REVERSE(ISNULL([cert to],''-1'')),0))) AS INT)
					)
				AND  (
							SUBSTRING(gc.gis_certificate_number_from,0,LEN(gc.gis_certificate_number_from)-(CHARINDEX(''-'',REVERSE(gc.gis_certificate_number_from)))+1 )
							= SUBSTRING([cert from],0,LEN([cert from])-(CHARINDEX(''-'',REVERSE([cert from])))+1 )
					)
			
			)
			
				FETCH NEXT FROM state_status INTO @state
			END;

			CLOSE state_status;
			DEALLOCATE state_status;	
			'
			
			EXEC spa_print @sql
			exec(@sql)
			
			SET @sql = 'DECLARE @state VARCHAR(100)
			DECLARE state_status2 CURSOR LOCAL FOR
			SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt where [state] <> ''No''
				
			OPEN state_status2;

			FETCH NEXT FROM state_status2 INTO @state
			WHILE @@FETCH_STATUS = 0
			BEGIN
					
			INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date, state_value_id)
			SELECT sdd.source_deal_detail_id,
			SUBSTRING([cert from],0,CHARINDEX(''-'',[cert from]))+''-''+@state+''-''+SUBSTRING(SUBSTRING([cert from],CHARINDEX(''-'',[cert from])+1,LEN([cert from])),CHARINDEX(''-'',SUBSTRING([cert from],CHARINDEX(''-'',[cert from])+1,LEN([cert from])))+1,LEN([cert from])),
			SUBSTRING([cert to],0,CHARINDEX(''-'',[cert to]))+''-''+@state+''-''+SUBSTRING(SUBSTRING([cert to],CHARINDEX(''-'',[cert to])+1,LEN([cert to])),CHARINDEX(''-'',SUBSTRING([cert to],CHARINDEX(''-'',[cert to])+1,LEN([cert to])))+1,LEN([cert to])),
			CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX(''-'',REVERSE([cert from]),0)))) 
				WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX(''-'',REVERSE([cert from]),0)))
				ELSE 1
			END,
			CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX(''-'',REVERSE([cert to]),0))))
				WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX(''-'',REVERSE([cert to]),0)))
				ELSE sdd.deal_volume
			END,
			GETDATE(),
			sdv.value_id
			  FROM source_deal_header sdh
			INNER JOIN #update_source_deal_header_id2 isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #tmp_dff3 td ON td.row_no = isdh.row_no
			INNER JOIN (SELECT rg2.code, sdd2.term_start
					 FROM  source_deal_header sdh2 
					 INNER JOIN #update_source_deal_header_id2 isdh ON isdh.source_deal_header_id = sdh2.source_deal_header_id
						INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
						INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
						GROUP BY rg2.code, sdd2.term_start
			) a ON a.code = td.generator
			AND a.term_start  = td.[monthly term]
			AND (' + @temp_name + ')
			INNER JOIN (SELECT * FROM static_data_value where type_id = 10016) sdv on sdv.code = @state
			WHERE NOT EXISTS(SELECT 1 FROM source_deal_header sdh
			INNER JOIN #update_source_deal_header_id2 isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #tmp_dff3 td ON td.row_no = isdh.row_no
			INNER JOIN #gis_certificate2 gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND SUBSTRING([cert from],0,CHARINDEX(''-'',[cert from]))+''-''+@state+''-''+SUBSTRING(SUBSTRING([cert from],CHARINDEX(''-'',[cert from])+1,LEN([cert from])),CHARINDEX(''-'',SUBSTRING([cert from],CHARINDEX(''-'',[cert from])+1,LEN([cert from])))+1,LEN([cert from]))
				 = gc.gis_certificate_number_from
			
			)
				FETCH NEXT FROM state_status2 INTO @state
			END;

			CLOSE state_status2;
			DEALLOCATE state_status2;
			'
			EXEC spa_print @sql
			EXEC(@sql)
			
			--select * from #tmp_dff2
			
			--inserting multiple certificate of inserted deal
			SET @sql ='DECLARE @state VARCHAR(100)
			DECLARE state_status3 CURSOR LOCAL FOR
			SELECT distinct [state] FROM
					(select ' + @name + ' from #tmp_dff3) p
					UNPIVOT
					([state] for #tmp_dff3 IN (' + @name + ')
					) AS unpvt where [state] <> ''No''
				
			OPEN state_status3;

			FETCH NEXT FROM state_status3 INTO @state
			WHILE @@FETCH_STATUS = 0
			BEGIN
					
			INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date, state_value_id)
			SELECT sdd.source_deal_detail_id,
			SUBSTRING([cert from],0,CHARINDEX(''-'',[cert from]))+''-''+@state+''-''+SUBSTRING(SUBSTRING([cert from],CHARINDEX(''-'',[cert from])+1,LEN([cert from])),CHARINDEX(''-'',SUBSTRING([cert from],CHARINDEX(''-'',[cert from])+1,LEN([cert from])))+1,LEN([cert from])),
			SUBSTRING([cert to],0,CHARINDEX(''-'',[cert to]))+''-''+@state+''-''+SUBSTRING(SUBSTRING([cert to],CHARINDEX(''-'',[cert to])+1,LEN([cert to])),CHARINDEX(''-'',SUBSTRING([cert to],CHARINDEX(''-'',[cert to])+1,LEN([cert to])))+1,LEN([cert to])),
			CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX(''-'',REVERSE([cert from]),0)))) 
				WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX(''-'',REVERSE([cert from]),0)))
				ELSE 1
			END,
			CASE ISNUMERIC(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX(''-'',REVERSE([cert to]),0))))
				WHEN 1 THEN REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX(''-'',REVERSE([cert to]),0)))
				ELSE sdd.deal_volume
			END,
			GETDATE(),
			sdv.value_id
			  FROM source_deal_header sdh
			INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #tmp_dff3 td ON td.row_no = isdh.row_no
			INNER JOIN (SELECT rg2.code, sdd2.term_start
					 FROM  source_deal_header sdh2 
					 INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh2.source_deal_header_id
						INNER JOIN source_deal_detail sdd2 ON sdd2.source_deal_header_id = sdh2.source_deal_header_id
						INNER JOIN rec_generator rg2 ON rg2.generator_id = sdh2.generator_id
						GROUP BY rg2.code, sdd2.term_start
			) a ON a.code = td.generator
			AND a.term_start  = td.[monthly term]
			AND (' + @temp_name + ')
			INNER JOIN (SELECT * FROM static_data_value where type_id = 10016) sdv on sdv.code = @state
			WHERE NOT EXISTS(SELECT 1 FROM source_deal_header sdh
			INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #tmp_dff3 td ON td.row_no = isdh.row_no
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN #gis_certificate2 gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
				AND SUBSTRING([cert from],0,CHARINDEX(''-'',[cert from]))+''-''+@state+''-''+SUBSTRING(SUBSTRING([cert from],CHARINDEX(''-'',[cert from])+1,LEN([cert from])),CHARINDEX(''-'',SUBSTRING([cert from],CHARINDEX(''-'',[cert from])+1,LEN([cert from])))+1,LEN([cert from]))
				 = gc.gis_certificate_number_from
			
			)
				FETCH NEXT FROM state_status3 INTO @state
			END;
			

			CLOSE state_status3;
			DEALLOCATE state_status3;	
			'
			
			EXEC spa_print @sql
			EXEC(@sql)
			
			UPDATE sdd SET sdd.[status] =  @certificate_id from source_deal_header sdh
			INNER JOIN #update_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			
			UPDATE sdd SET sdd.[status] = @certificate_id from source_deal_header sdh
			INNER JOIN #update_source_deal_header_id2 isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			
			UPDATE sdd SET sdd.[status] = @certificate_id from source_deal_header sdh
			INNER JOIN #inserted_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			
			UPDATE sdd SET sdd.[status] = @certificate_id from source_deal_header sdh
			INNER JOIN #update_assigned_source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			
			
			
	COMMIT 
	--ROLLBACK 
	--select * from #tmp_dff3
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
			SELECT DISTINCT 'WREGIS',
				@process_id,
				'Success',
				'Import WREGIS REC Upload',
				'Success',
				'WREGIS RECs for generator ' + a.generator + ' for term ' + a.[monthly term] + ', volume ' + CAST(SUM(CAST(a.volume AS FLOAT)) AS VARCHAR) + ' imported for File:',
				''
			FROM (
			select distinct td.*,aa.assigned_volume
			FROM #tmp_dff3 td  
			INNER JOIN rec_generator rg ON rg.code = td.generator
			INNER JOIN source_deal_header sdh ON sdh.generator_id = rg.generator_id
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
				AND sdd.term_start =td.[monthly term]
			LEFT JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd.source_deal_detail_id
			WHERE CASE WHEN [cert from] IS NULL THEN volume ELSE (CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS FLOAT) -
			CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS FLOAT) + 1) END = CAST(volume AS FLOAT)
			
			)a 
			GROUP BY a.generator,a.[monthly term]   
			HAVING MAX(CAST(a.volume AS FLOAT)) >= MAX(ISNULL(a.assigned_volume, CAST(a.volume AS FLOAT)))

			--SELECT * from #tmp_dff3 where generator is null
			
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
			SELECT DISTINCT 'WREGIS',
				@process_id,
				'Error',
				'Import WREGIS REC Upload',
				'Error',
				'WREGIS RECs for generator ' + td.generator + ' failed . Please check if generator is correct.',
				''
			FROM #tmp_dff3 td  
			LEFT JOIN rec_generator rg ON rg.code = td.generator
			WHERE rg.name IS NULL
			GROUP BY td.generator,td.[monthly term] 
			
			IF EXISTS(SELECT 1 FROM #tmp_dff3 td  
			LEFT JOIN rec_generator rg ON rg.code = td.generator
			WHERE rg.name IS NULL
			GROUP BY td.generator,td.[monthly term] )
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
				SELECT 'Non-Existing Generators List',
				@process_id,
				'Error',
				'Import WREGIS REC Upload',
				'Error',
				'List of Non-Existing Generators Import Format',
				''
				
			SET @sql = 'INSERT INTO source_system_data_import_status_generator_detail
    	      (
    	        [source],
    	        process_id,
    	        [type],
    	        book, 
    	        facility_name, 
    	        facility_id, 
    	        unit_name, 
    	        unit_id, 
    	        juridiction, 
    	        facility_owner, 
    	        [start_date], 
    	        [fuel_type], 
    	        technology
    	      )
    			SELECT ''Non-Existing Generators List'',
    				  ''' + @process_id + ''',
    				   ''List of incorrect Generators'',
    				   Null,
    				   NULL,
    				   NULL,
    				   REPLACE(REPLACE(LTRIM(RTRIM(MAX(td.[generator_plant_unit_name]))),'','',''''),'''''''',''''),
    				   LTRIM(RTRIM(td.[wregis_gu_id])),
    				   LTRIM(RTRIM(MAX(td.[State]))),
    				   NULL,
    				   NULL,
    				   LTRIM(RTRIM(MAX(td.[fuel_type]))),
    				   LTRIM(RTRIM(MAX(td.[fuel_type])))
    			FROM ' + @temp_table_name + ' td  
				LEFT JOIN rec_generator rg ON rg.code = td.[wregis_gu_id]
				WHERE rg.name IS NULL
				GROUP BY td.[wregis_gu_id]'
				
			EXEC spa_print @sql
			EXEC(@sql)
				--GROUP BY td.[wregis_gu_id]
			END
			
		
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
			SELECT DISTINCT 'WREGIS',
				@process_id,
				'Error',
				'Import WREGIS REC Upload',
				'Error',
				'WREGIS RECs for generator ' + td.generator + ' and term ' + td.[monthly term] + ' failed . Certificate should match volume.',
				''
			FROM #tmp_dff3 td  
			WHERE (CAST(REVERSE(SUBSTRING(REVERSE([cert to]),0,CHARINDEX('-',REVERSE([cert to]),0))) AS INT) -
			CAST(REVERSE(SUBSTRING(REVERSE([cert from]),0,CHARINDEX('-',REVERSE([cert from]),0))) AS INT) + 1) <> CAST(volume AS FLOAT)
			
			SET @sql = 'DECLARE @name_state VARCHAR(MAX)
			select  @name_state  =  ISNULL(@name_state,'''') + CASE WHEN @name_state is null THEN '''' ELSE '','' END + name from 
			tempdb.sys.columns t
			inner join #tmp_dff td ON '+@name_state_no + ' where object_id =
			object_id(''tempdb..#tmp_dff'') and name not in (''generator'',''monthly term'',''volume'',''cert from'',''cert to'',''temp_id'',''state'')
			IF OBJECT_ID(''tempdb..##global_name_state'') IS NOT NULL
			DROP TABLE ##global_name_state
			CREATE TABLE ##global_name_state(state VARCHAR(3) COLLATE DATABASE_DEFAULT)
			INSERT INTO ##global_name_state SELECT item from dbo.splitcommaseperatedvalues(@name_state)'
			
			EXEC spa_print @sql
			EXEC(@sql)

			--select * from #tmp_dff
			--select * from ##global_name_state

			DECLARE @failed_states VARCHAR(1000)
			SELECT @failed_states = ISNULL(@failed_states,'') + CASE WHEN @failed_states IS NULL THEN '' ELSE ',' END +  scsv.[state]  
			FROM ##global_name_state scsv
			LEFT JOIN (SELECT * FROM static_data_value where type_id = 10016) sdv ON scsv.[state] = sdv.code
			WHERE sdv.code IS NULL
			
			DROP TABLE ##global_name_state
			
			IF @failed_states IS NOT NULL
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
				SELECT 'Non-Existing States List',
				 @process_id ,
				'Error',
				'Import WREGIS REC Upload',
				'Error',
				'WREGIS RECs upload for states '+ @failed_states + ' failed. Check if the states exist.',
				''
    	    END
		
SELECT @url = './dev/spa_html.php?__user_name__=' + @user_login_id +
       '&spa=exec spa_get_import_process_status ''' + @process_id + ''',''' + @user_login_id 
       + ''''
      
 SET @elapsed_sec = DATEDIFF(second, @start_ts, GETDATE())

IF EXISTS(SELECT 1 FROM source_system_data_import_status where process_id = @process_id and code IN ('Error'))
AND EXISTS(SELECT 1 FROM source_system_data_import_status where process_id = @process_id and code IN ('Success')) 
BEGIN
	SET @error_code = 'e'
	SELECT @desc = '<a target="_blank" href="' + @url + '">' +
       '<font color=''red''>WREGIS RECs uploaded successfully with some errors</font>' +'</a>'+ ' '+
       '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(1000)) + ' sec </a>' 
END  
ELSE IF EXISTS(SELECT 1 FROM source_system_data_import_status where process_id = @process_id and code = 'Error') 
BEGIN
	SET @error_code = 'e'
	SELECT @desc = '<a target="_blank" href="' + @url + '">' +
       '<font color=''red''>WREGIS RECs upload failed</font>' +'</a>'+ ' '+
       '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(1000)) + ' sec </a>' 
END
ELSE
BEGIN
	SET @error_code ='s'
	SELECT @desc = '<a target="_blank" href="' + @url + '">' +
       'WREGIS RECs uploaded Successfully' +'</a>'+ ' '+
       '.Elapsed time:' + CAST(@elapsed_sec AS VARCHAR(1000)) + ' sec </a>' 
END	      
	
END TRY
BEGIN CATCH

	SET @error_msg  = 'error' + ERROR_MESSAGE()
	EXEC spa_print @error_msg
	SET @error_code = 'e'
	SET @desc ='Unable to complete WREGIS REC Upload'
	ROLLBACK 
END CATCH 

-- messaging is handled by Data Import Export module itself.
--EXEC spa_NotificationUserByRole 2, @process_id, 'WREGIS RECs Upload', @desc , @error_code, @job_name, 1

--updating using flag 'e' which automatically calculate the estimated time.
EXEC spa_import_data_files_audit
     @flag = 'e',
     @process_id = @process_id,
     @status = @error_code
	
	
END
