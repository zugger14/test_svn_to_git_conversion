

IF OBJECT_ID('[dbo].[spa_source_deal_detail_hour]', 'p') IS NOT NULL
    DROP PROC [dbo].[spa_source_deal_detail_hour]
GO 

CREATE PROC [dbo].[spa_source_deal_detail_hour] 
	@flag CHAR(1),
	@source_deal_header_id VARCHAR(MAX) = NULL,
	@source_deal_detail_id VARCHAR(MAX) = NULL,
	@term_start DATETIME = NULL, 
	@term_end DATETIME = NULL ,
	@xml VARCHAR(MAX) = NULL ,
	@hr_from INT = NULL,
	@hr_to INT = NULL, 
	@process_id VARCHAR(100) = NULL,
	@show_select CHAR(1) = NULL,
	@leg VARCHAR(10) = NULL,
	@volume_price CHAR(1) = NULL
AS 
SET NOCOUNT ON 
DECLARE @sql                    VARCHAR(MAX)
DECLARE @user_login_id          VARCHAR(100)
DECLARE @spa                    VARCHAR(8000)
DECLARE @job_name               VARCHAR(100)
DECLARE @vol_frequency          CHAR(1)
DECLARE @deal_volume            NUMERIC(38, 20)
DECLARE @report_position_deals  VARCHAR(300)
DECLARE @data_exists            CHAR(1)
DECLARE @sql_hr                 VARCHAR(8000)
DECLARE @granularity            INT 

SET @user_login_id = dbo.FNADBUser()
DECLARE @idoc INT 


IF OBJECT_ID('temp..#unpivot_updated_value') IS NOT NULL
	DROP TABLE #unpivot_updated_value

IF OBJECT_ID('temp..#temp_deal_collection') IS NOT NULL
	DROP TABLE #temp_deal_collection

CREATE TABLE #temp_deal_collection(source_deal_header_id INT, source_deal_detail_id INT, deal_volume_frequency CHAR(1) COLLATE DATABASE_DEFAULT , granularity INT)

IF @source_deal_header_id <> 'NULL'
BEGIN 
	INSERT INTO #temp_deal_collection(source_deal_header_id, source_deal_detail_id, deal_volume_frequency)
	SELECT sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.deal_volume_frequency
	FROM dbo.FNASplit(@source_deal_header_id, ',') t
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = t.item
END 

IF @source_deal_detail_id <> 'NULL' --@source_deal_detail_id
BEGIN 
	INSERT INTO #temp_deal_collection(source_deal_header_id, source_deal_detail_id, deal_volume_frequency)	
	SELECT sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.deal_volume_frequency
	FROM dbo.FNASplit(@source_deal_detail_id, ',') t
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = t.item
END 

--SELECT @source_deal_header_id = source_deal_header_id,
--       @vol_frequency = deal_volume_frequency
--FROM   source_deal_detail
--WHERE  source_deal_detail_id = @source_deal_detail_id

--PRINT @vol_frequency

SET @data_exists = 'n'		
DECLARE @columns_names VARCHAR(MAX)

DECLARE @baseload_block_type       VARCHAR(10),
        @baseload_block_define_id  VARCHAR(10)
		
SET @baseload_block_type = '12000'	-- Internal Static Data

SELECT @baseload_block_define_id = CAST(value_id AS VARCHAR(10))
FROM   static_data_value
WHERE  [type_id] = 10018
       AND code LIKE 'Base Load' -- External Static Data

CREATE TABLE #minute_table (hr_time varchar(2) COLLATE DATABASE_DEFAULT )
DECLARE @check_dst INT

/*
995	978	5MIn
994	978	10MIn
987	978	15Min	15Min
989	978	30Min	30Min
990	978	Weekly	Weekly
991	978	Quaterly	Quaterly
992	978	Semi-Annually	Semi-Annually
993	978	Annually	Annually
980	978	Monthly	Monthly
981	978	Daily	Daily
982	978	Hourly	Hourly

*/

UPDATE tdc
SET granularity = ISNULL(sdht.hourly_position_breakdown, 982)
FROM   source_deal_detail sdd
INNER JOIN #temp_deal_collection tdc ON tdc.source_deal_detail_id = sdd.source_deal_detail_id
INNER JOIN source_deal_header sdh ON  sdh.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN source_deal_header_template sdht ON  sdh.template_id = sdht.template_id
		
SELECT DISTINCT @granularity = granularity FROM #temp_deal_collection

IF @granularity = 995
	INSERT INTO #minute_table (hr_time) VALUES ('00'),('05'),('10'),('15'),('20'),('25'),('30'),('35'),('40'),('45'),('50'),('55')
ELSE IF @granularity = 994
	INSERT INTO #minute_table (hr_time) VALUES ('00'),('10'),('20'),('30'),('40'),('50')
ELSE IF @granularity = 987
	INSERT INTO #minute_table (hr_time) VALUES ('00'),('15'),('30'),('45')
ELSE IF @granularity = 989
	INSERT INTO #minute_table (hr_time) VALUES ('00'),('30')
ELSE 
	INSERT INTO #minute_table (hr_time) VALUES ('00')
		
SET @hr_from = ISNULL(@hr_from, 0)
SET @hr_to = ISNULL(@hr_to, 25)

DECLARE @column_lists_table VARCHAR(1000)

IF @flag in ('s', 'e')   -- e=uses for exporting hourly data.
BEGIN
    IF EXISTS( SELECT 'x' FROM   source_deal_detail_hour sddh
				INNER JOIN #temp_deal_collection tdc ON  tdc.source_deal_detail_id = sddh.source_deal_detail_id 
					--AND sddh.granularity = @granularity
			)
	BEGIN
		SET @data_exists = 'y'
	END 
	
	SELECT source_deal_detail_id,term_date,volume,
			CASE REPLACE(hr, 'hr', '')
				WHEN 25 THEN volume
				WHEN [DST_hour] THEN NULL
				ELSE REPLACE(hr, 'hr', '')
			END [Hours],
			CASE REPLACE(hr, 'hr', '')
				WHEN 25 THEN 1
				ELSE 0
			END DST, 
			hour_volume, 
			commodity_id, 
			leg
				INTO #tmp_cte
	FROM   (
			SELECT sdd.source_deal_detail_id,  hbt.term_date,
					sdd.term_start term_start,
					CAST(CONVERT(VARCHAR(10), term_date, 120) + ' ' + '23:59:00:000' AS DATETIME ) term_end,
					--CASE 
					--	WHEN @vol_frequency = 'h' THEN case @granularity when 987 then sdd.deal_volume * .25 when 989 then sdd.deal_volume * .5 when 982 then sdd.deal_volume when 981 then sdd.deal_volume*24 else sdd.deal_volume end
					--	WHEN @vol_frequency = 'y' THEN case @granularity when 987 then sdd.deal_volume * .5 when 989 then sdd.deal_volume  when 982 then sdd.deal_volume*2 when 981 then sdd.deal_volume*24*2 else sdd.deal_volume*2 end
					--	WHEN @vol_frequency = 'x' THEN case @granularity when 987 then sdd.deal_volume  when 989 then sdd.deal_volume*2  when 982 then sdd.deal_volume*4 when 981 then sdd.deal_volume*24*4 else sdd.deal_volume*4 end
					--	ELSE CAST((sdd.deal_volume / hb_term.term_hours) * case @granularity when 987 then .25 when 989 then .5 when 982 then 1 when 981 then 24 else 1 end   AS NUMERIC(38, 20))
					--END hour_volume,
					NULL hour_volume,
					hbt.hr1,hbt.hr2,hbt.hr3,hbt.hr4,hbt.hr5,hbt.hr6,hbt.hr7,hbt.hr8,
					hbt.hr9,hbt.hr10,hbt.hr11,hbt.hr12,hbt.hr13,hbt.hr14,hbt.hr15,hbt.hr16,
					hbt.hr17,hbt.hr18,hbt.hr19,hbt.hr20,hbt.hr21,hbt.hr22,hbt.hr23,hbt.hr24,
					mv.[hour] [hr25], mv1.Hour [DST_hour], spcd.commodity_id,
					sdd.leg
			FROM  source_deal_header sdh
			INNER JOIN #temp_deal_collection tdc ON tdc.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail sdd ON  sdd.source_deal_detail_id = tdc.source_deal_detail_id
			LEFT JOIN source_price_curve_def spcd ON  spcd.source_curve_def_id = sdd.curve_id
			LEFT JOIN hour_block_term hbt ON  hbt.block_define_id = COALESCE(spcd.block_define_id,sdh.block_define_id,  @baseload_block_define_id)
				AND hbt.block_type = COALESCE(spcd.block_type, sdh.block_type, @baseload_block_type)
				AND hbt.term_date BETWEEN sdd.term_start AND sdd.term_end
			LEFT JOIN mv90_DST mv ON  (hbt.term_date) = (mv.date)
				AND mv.insert_delete = 'i'
				AND hbt.dst_applies = 'y'
			LEFT JOIN mv90_DST mv1 ON  (hbt.term_date) = (mv1.date)
				AND mv1.insert_delete = 'd'
				AND hbt.dst_applies = 'y'
			OUTER APPLY(
					   SELECT SUM(volume_mult) term_hours
					   FROM   hour_block_term(NOLOCK)
					   WHERE  term_date BETWEEN sdd.term_start AND sdd.term_end
							  AND block_type = COALESCE(spcd.block_type, sdh.block_type, @baseload_block_type)
							  AND block_define_id = COALESCE(spcd.block_define_id,sdh.block_define_id,	@baseload_block_define_id)
					   ) hb_term
					INNER JOIN #temp_deal_collection tdc_1 ON tdc_1.source_deal_header_id = sdd.source_deal_header_id
			) AS p
			UNPIVOT(
				volume FOR hr IN ([hr1], [hr2], [hr3], [hr4], [hr5], [hr6], [hr7], [hr8], [hr9], [hr10], [hr11], [hr12], 
								[hr13], [hr14], [hr15], [hr16], [hr17], [hr18], [hr19], [hr20], [hr21], [hr22], 
								[hr23], [hr24], [hr25])
			) unpvt 
			--WHERE term_date BETWEEN @term_start AND @term_end



	CREATE TABLE #data_before_pivot(column_display_order INT, source_deal_header_id INT, source_deal_detail_id INT, term_start VARCHAR(1000) COLLATE DATABASE_DEFAULT , hour VARCHAR(100) COLLATE DATABASE_DEFAULT , dst INT, volume NUMERIC(38,10),
									 price FLOAT, formula VARCHAR(1000) COLLATE DATABASE_DEFAULT , term_start_Hour INT, act_term_start VARCHAR(1000) COLLATE DATABASE_DEFAULT , leg INT)

	SET @sql = CASE WHEN @flag = 's' THEN 'INSERT INTO #data_before_pivot( source_deal_header_id, source_deal_detail_id, term_start, hour, dst, volume, price, formula, term_start_Hour, act_term_start, leg)' 
				ELSE 'INSERT INTO #data_before_pivot(source_deal_header_id, source_deal_detail_id, term_start, hour, dst, volume, price, formula, leg)' END +
				' SELECT DISTINCT
					tdc.source_deal_header_id, cte.source_deal_detail_id, 
					CONVERT(VARCHAR(10), cte.term_date, 120) [Term Start], ' +
					CASE WHEN @granularity = 981 THEN '''00:00''' ELSE 'CASE WHEN cte.dst = 1 THEN CAST(24 AS VARCHAR) + '':'' + mt.hr_time ELSE RIGHT(''0'' + CAST((cte.[Hours] - 1) AS VARCHAR), 2) + '':'' + mt.hr_time END' END + ' [Hour],
					cte.dst [DST], '
					+ CASE @data_exists WHEN 'y' THEN  'sddh.volume' ELSE 'dbo.FNARemoveTrailingZero(hour_volume)' END + ' [Volume],
					sddh.price [Price],
					sddh.formula_id [Formula]'
					+ CASE WHEN @flag='s' THEN 
						', cte.[Hours] - 1 term_start_Hour,
						CAST(CONVERT(VARCHAR(10), cte.term_date, 120) + '' '' +  ISNULL(CAST(CAST(REPLACE([Hours], ''hr'', '''') AS INT) -1 AS VARCHAR), ''00'') + '':00:00:000'' AS DATETIME) act_term_start'
						ELSE ''
					END + ', cte.leg
				FROM #tmp_cte cte
				INNER JOIN #temp_deal_collection tdc ON tdc.source_deal_detail_id = cte.source_deal_detail_id
				CROSS JOIN #minute_table mt
				LEFT JOIN source_deal_detail_hour sddh ON cte.source_deal_detail_id = sddh.source_deal_detail_id
					AND cte.term_date = sddh.term_date
					AND CASE WHEN cte.dst = 1 THEN CAST(24 AS VARCHAR) + '':'' + mt.hr_time ELSE RIGHT(''0'' + CAST((cte.[Hours]) AS VARCHAR), 2) + '':'' + mt.hr_time END = sddh.[hr]
					AND cte.dst = sddh.[is_dst]
				WHERE 1 = 1   ' + CASE WHEN @granularity = 981 THEN ' AND cte.[Hours] = ''1'''  ELSE '' END 
						+ ' AND cte.[Hours] IS NOT NULL
							AND RIGHT(''0''  + CAST(cte.[Hours] AS VARCHAR) ,2) + '':''  + mt.hr_time BETWEEN ''' + RIGHT('0' + CAST(@hr_from AS VARCHAR), 2) + ':00'' 
								AND ''' + RIGHT('0' + CAST(@hr_to AS VARCHAR), 2) + ':99''
				'

	--PRINT ISNULL(@sql, '@sql is null')
	EXEC(@sql)


	/* update dst volume */
	--select * 
	UPDATE cte
	SET volume = sddh.volume,
		price = sddh.price 
	FROM #data_before_pivot cte
	INNER JOIN source_deal_detail_hour sddh ON cte.source_deal_detail_id = sddh.source_deal_detail_id
		AND cte.term_start = sddh.term_date
		AND cte.dst = sddh.[is_dst]
		AND sddh.[hr] = CASE WHEN cte.[Hour] = '24:00' THEN '03:00'
						 WHEN cte.[Hour] = '24:15' THEN '03:15'
						 WHEN cte.[Hour] = '24:30' THEN '03:30'
						 WHEN cte.[Hour] = '24:45' THEN '03:45' ELSE '' END
	WHERE cte.dst = 1 
	
	DECLARE @process_id_select VARCHAR(500) = ''
	DECLARE @column_lists_coll VARCHAR(MAX)
	DECLARE @column_lists_table_volume VARCHAR(MAX)
	DECLARE @column_lists_table_price VARCHAR(MAX)

	SELECT @column_lists_coll = STUFF((SELECT  DISTINCT ', [' + CAST(hour AS VARCHAR(5)) + ']'
									FROM #data_before_pivot
									ORDER BY ', [' + CAST(hour AS VARCHAR(5)) + ']'
									FOR XML PATH('')), 1, 1, '')

	IF @process_id IS NULL
	BEGIN 
		SET @process_id_select = dbo.FNAGetNewID() 
		SET @column_lists_table = dbo.FNAProcessTableName('column_lists', dbo.FNADBUser(), @process_id_select)
		SET @column_lists_table_volume = dbo.FNAProcessTableName('column_lists_volume', dbo.FNADBUser(), @process_id_select)
		SET @column_lists_table_price = dbo.FNAProcessTableName('column_lists_price', dbo.FNADBUser(), @process_id_select)			


		SET @sql = 'SELECT DISTINCT source_deal_header_id [Deal ID], CONVERT(DATETIME, term_start, 121) [Term Start], leg, ''Volume'' [price/volume], ''n'' [is_updated], 0 DST, ' + CAST(@granularity AS VARCHAR(100)) +  ' granularity, ''' + @process_id_select + ''' process_id, source_deal_detail_id, ' + @column_lists_coll + '
					INTO ' +  @column_lists_table_volume + ' 
					FROM (
					SELECT source_deal_header_id, source_deal_detail_id, term_start, volume, [hour], leg
					FROM #data_before_pivot) up
					PIVOT (SUM(volume) FOR hour IN (' + @column_lists_coll + ')) AS pvt
					'

		--PRINT ISNULL(@sql, '@sql is null')
		EXEC(@sql)
	
		SET @sql = 'SELECT source_deal_header_id [Deal ID], CONVERT(DATETIME, term_start, 121) [Term Start], leg, ''Price'' [price/volume], ''n'' [is_updated], 0 DST, ' 
					+ CAST(@granularity AS VARCHAR(100)) +  ' granularity, ''' + @process_id_select + ''' process_id, source_deal_detail_id, ' + @column_lists_coll + '
					INTO ' +  @column_lists_table_price + ' 
					FROM (
						SELECT source_deal_header_id, source_deal_detail_id, term_start, [hour], leg, price
						FROM #data_before_pivot) up
						PIVOT (SUM(price) FOR hour IN (' + @column_lists_coll + ')
						) AS pvt
					ORDER BY source_deal_detail_id, term_start' 
		--PRINT ISNULL(@sql, '@sql is null')
		EXEC(@sql)


		SET @sql = 'SELECT * 
					INTO ' + @column_lists_table + '
					FROM (SELECT * FROM ' + @column_lists_table_volume
					+ ' UNION ALL '
					+ 'SELECT * FROM ' + @column_lists_table_price + ') a'

		--PRINT ISNULL(@sql, '@sql is null')
		EXEC(@sql)
	END
	

	--check if dst applies for filter month
	SELECT @check_dst = MAX(dst) FROM  #data_before_pivot 
	WHERE term_start BETWEEN  @term_start AND @term_end
		AND dst = 1

	IF @check_dst IS NULL
	BEGIN 
		SELECT @column_lists_coll =   REPLACE(@column_lists_coll, ', [24:00]', '')
	END
	SET @column_lists_coll = '[Deal ID]
									, [Term Start]	
									, [Leg]	
									, [Price/Volume]	
									, [is_updated]	
									, [DST]	
									, [granularity]	
									, [process_id]	
									, [source_deal_detail_id],' + @column_lists_coll

	SET @column_lists_coll = REPLACE(@column_lists_coll, '[', '''')
	SET @column_lists_coll = REPLACE(@column_lists_coll, ']', '''')
	

	SET @sql = 'SELECT ' + @column_lists_coll + ',''' + CASE WHEN @process_id IS NULL THEN @process_id_select ELSE  @process_id END + ''''
	--PRINT(@sql)
	EXEC (@sql)
END
ELSE IF @flag = 'u'
BEGIN
    BEGIN TRY
    	BEGIN TRAN 

		EXEC spa_source_deal_detail_hour @flag='r', @process_id = @process_id, @xml = @xml, @show_select = 1
		
		SET @column_lists_table = dbo.FNAProcessTableName('column_lists', dbo.FNADBUser(), @process_id)
		--print @column_lists_table
		IF OBJECT_ID('tempdb..##test') IS NOT NULL
			DROP TABLE ##test


		SET @sql_hr = 'SELECT * INTO ##test FROM ' + @column_lists_table + ' WHERE is_updated = ''y'''
		EXEC(@sql_hr)
		
		SET @sql_hr = 'INSERT INTO ##test 
						SELECT * FROM ' + @column_lists_table + ' WHERE [Term Start] IN (select [Term Start] from ##test) AND is_updated = ''n'''
		EXEC(@sql_hr)

		
		--EXEC('SELECT  * FROM ' + @column_lists_table)
		SELECT @columns_names = STUFF((SELECT DISTINCT ', [' + name + ']' 
								FROM tempdb.sys.columns WITH(NOLOCK)
								WHERE OBJECT_ID = OBJECT_ID('tempdb..##test')
									AND name NOT IN (
									'Deal ID'
									, 'Term Start'
									, 'price/volume'
									, 'leg'
									, 'is_updated'
									, 'granularity'
									, 'process_id'
									, 'source_deal_detail_id'
									, 'dst')
								FOR XML PATH('')), 1, 1, '')


		CREATE TABLE #unpivot_updated_value(source_deal_detail_id INT, term_start DATETIME, price_volume VARCHAR(100) COLLATE DATABASE_DEFAULT , volume FLOAT, hr VARCHAR(500) COLLATE DATABASE_DEFAULT , dst INT)
		SET @sql = 'INSERT INTO #unpivot_updated_value
					SELECT source_deal_detail_id
						, [Term Start]
						, u.[price/volume] 
						, u.volume
						, u.hr
						, u.dst
					from ##test
					unpivot
		(volume
		  for hr IN (' + @columns_names + ')
		) u'

		--PRINT @sql 
		EXEC(@sql)
		--select * from #unpivot_updated_value

		SELECT source_deal_detail_id, term_start, 
				CASE WHEN [hr] = '24:00' THEN '03:00'
					 WHEN [hr] = '24:15' THEN '03:15'
					 WHEN [hr] = '24:30' THEN '03:30'
				     WHEN [hr] = '24:45' THEN '03:45'
					 WHEN [hr] = '23:00' THEN '24:00'
					 WHEN [hr] = '23:15' THEN '24:15'
					 WHEN [hr] = '23:30' THEN '24:30'
				     WHEN [hr] = '23:45' THEN '24:45'
				ELSE  RIGHT('0' + CAST(DATEPART(hh, DATEADD(hour, 1, hr)) AS VARCHAR(10)) +  RIGHT([hr], 3), 5) END hr
			, [Volume] [Volume]
			, [Price] [Price]
			, CASE	 WHEN [hr] = '24:00' OR 
					 [hr] = '24:15' OR 
					 [hr] = '24:30' OR 
				     [hr] = '24:45'   THEN 1 ELSE 0 END dst
			--, 'i' delete_insert	
			INTO #final_updated_value
		FROM (SELECT source_deal_detail_id
				, term_start
				, hr, volume AS volume_a, price_volume,dst
		FROM #unpivot_updated_value) fuv
		PIVOT (SUM(volume_a) FOR price_volume IN ([Volume],[Price])) as pvt	
	
	--SELECT * FROM #final_updated_value fuv
	--LEFT JOIN source_deal_detail_hour sddh ON  sddh.source_deal_detail_id = fuv.source_deal_detail_id
 --   	    AND sddh.term_date = fuv.term_start
 --   	    AND (sddh.hr = fuv.hr OR REPLACE(fuv.hr, ':00', '') = (right('0' + cast(sddh.hr as varchar), 5)) OR REPLACE(fuv.hr, ':00', '') = sddh.hr)
 --   	    AND ISNULL(sddh.is_dst, 0) = fuv.dst 
 --   WHERE sddh.sddh
	--return

		MERGE source_deal_detail_hour AS T
		USING #final_updated_value AS S
		ON (T.source_deal_detail_id = S.source_deal_detail_id
	  		AND T.term_date = S.term_start
	  		--AND (T.hr = s.hr OR REPLACE(s.hr, ':00', '') = (RIGHT('0' + cast(T.hr as varchar), 5)) OR CAST(REPLACE(s.hr, ':00', '') AS INT) = t.hr)
	  		AND ISNULL(T.hr, 0) = s.hr 
			AND ISNULL(t.is_dst, 0) = s.dst 
			) 
		WHEN NOT MATCHED BY TARGET
			THEN 
			INSERT(source_deal_detail_id, term_date, hr, is_dst, volume, price, formula_id, granularity) 
			VALUES(S.source_deal_detail_id, S.term_start, s.hr, s.dst, S.volume, S.price, NULL, @granularity)
		WHEN MATCHED 
			THEN UPDATE SET T.volume = s.volume, 
							T.price = s.price;



		--/*
		--SELECT term_start, hr, price_volume, volume, source_deal_detail_id 
		--FROM #unpivot_updated_value
		DECLARE @source_deal_detail_1 VARCHAR(50)
		DECLARE @term_start_1 VARCHAR(100)
		DECLARE @hr_1 VARCHAR(100)
		DECLARE @volume_price_1 VARCHAR(100) 
		DECLARE @volume_1 VARCHAR(100) 
		/*
		DECLARE cur_new_1 CURSOR FOR
		SELECT term_start, hr, price_volume, volume, source_deal_detail_id 
		FROM #unpivot_updated_value
		WHERE volume = 0
		OPEN cur_new_1
		FETCH NEXT
		FROM cur_new_1 INTO @term_start_1, @hr_1, @volume_price_1, @volume_1,  @source_deal_detail_1
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @sql = '--SELECT * 
						UPDATE a SET [' + @hr_1 + '] = NULL 
						FROM ' + @column_lists_table + ' a WHERE [Term Start] =''' + @term_start_1 
						+ ''' AND source_deal_detail_id=' + @source_deal_detail_1 
						+ ' AND [price/volume]= ''' + @volume_price_1 + ''''
			--PRINT ISNULL(@sql, 'sql is null')
			EXEC(@sql)
		FETCH NEXT
		FROM cur_new_1 INTO  @term_start_1, @hr_1, @volume_price_1, @volume_1,  @source_deal_detail_1
		END
		CLOSE cur_new_1
		DEALLOCATE cur_new_1
		--PRINT('SELECT * FROM ' + @column_lists_table)
		--EXEC('SELECT  * FROM ' + @column_lists_table)
		*/
		 

    	SET @process_id = REPLACE(NEWID(), '-', '_')
    	SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)

    	EXEC ('CREATE TABLE ' + @report_position_deals + 
    	         '(source_deal_header_id INT, action CHAR(1))')
    	
    	SET @sql = 'INSERT INTO ' + @report_position_deals 
					+ '(source_deal_header_id, action) 
						SELECT DISTINCT sdd.source_deal_header_id, ''u'' 
						FROM  #final_updated_value fuv 
						INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = fuv.source_deal_detail_id'
    	EXEC (@sql)
    	
    	--IF @vol_frequency in('h','x','y')
    	--BEGIN
    	--    SELECT @deal_volume = AVG(volume)
    	--    FROM   source_deal_detail_hour
    	--    WHERE  source_deal_detail_id = @source_deal_detail_id
    	--END
    	--ELSE
    	--BEGIN
		
    	    SELECT SUM(sddh.volume) deal_volume, SUM(sddh.price * sddh.volume)/NULLIF(SUM(sddh.volume),0) price, sddh.source_deal_detail_id
			INTO #to_update_values
    	    FROM source_deal_detail_hour sddh
			INNER JOIN #final_updated_value ts 
				ON ts.source_deal_detail_id = sddh.source_deal_detail_id
				AND ts.hr = sddh.hr
			GROUP BY sddh.source_deal_detail_id

			INSERT INTO #to_update_values
			SELECT SUM(sddh.volume) deal_volume, SUM(sddh.price * sddh.volume) / NULLIF(SUM(sddh.volume),0) price, sddh.source_deal_detail_id
			FROM dbo.FNAsplit(@source_deal_header_id, ',') ts 
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = ts.item
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN source_deal_detail_hour sddh ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
			GROUP BY sddh.source_deal_detail_id
    	   -- WHERE  source_deal_detail_id = @source_deal_detail_id
    	--END
    
    	--DECLARE @price NUMERIC(38, 20)
    	
    	--SELECT @price = SUM(price*volume)/SUM(volume)
    	--FROM   source_deal_detail_hour
    	--WHERE  source_deal_detail_id = @source_deal_detail_id
    	
    	--UPDATE source_deal_detail
    	--SET    deal_volume = ISNULL(@deal_volume, 0),
    	--       fixed_price = @price, deal_volume_frequency = 't'
    	--WHERE  source_deal_detail_id = @source_deal_detail_id	
    	

		--SELECT * 
		UPDATE sdd
		SET deal_volume = ISNULL(ts.deal_volume, 0),
			fixed_price = ts.price,
			deal_volume_frequency = 't'
		FROM source_deal_detail sdd
		INNER JOIN #to_update_values ts ON ts.source_deal_detail_id = sdd.source_deal_detail_id

    	SET @spa = 'spa_update_deal_total_volume NULL,''' + CAST(@process_id AS VARCHAR(50)) + ''''
    	
    	SET @job_name = 'spa_update_deal_total_volume_' + @process_id 
    	EXEC spa_run_sp_as_job @job_name,
    	     @spa,
    	     'spa_update_deal_total_volume',
    	     @user_login_id 
    	
    	-- */
    	COMMIT TRAN
    	
    	EXEC spa_ErrorHandler 0,
    	     'source_deal_detail_hour table',
    	     'spa_update_source_deal_detail_hour',
    	     'Success',
    	     'Data Successfully Updated.',
    	     ''
    END TRY
    BEGIN CATCH
    	ROLLBACK TRAN	
    	DECLARE @err_msg VARCHAR(200)
    	SET @err_msg = ERROR_MESSAGE()
    	EXEC spa_ErrorHandler -1,
    	     'source_deal_detail_hour table',
    	     'spa_update_source_deal_detail_hour',
    	     'DB Error',
    	     'Failed Updating Data.',
    	     @err_msg
    END CATCH
END
ELSE IF @flag = 'r' --refresh and save data in prcess table
BEGIN 
	SET @column_lists_table = dbo.FNAProcessTableName('column_lists', dbo.FNADBUser(), @process_id)

	IF @xml = 'NULL'  
		SET @xml = NULL

	IF @xml IS NOT NULL 
	BEGIN 
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

    	SELECT term_date AS term_date,
    	       hr,
    	       NULLIF(volume, '') volume,
			   deal_id,
			   source_deal_detail_id,
			   price_volume
			INTO #tmp_process_sddh
    	FROM   OPENXML(@idoc, '/gridXml/GridRow', 2)
    	       WITH (
    	           term_date VARCHAR(50) '@term_start',
    	           hr VARCHAR(10) '@hr',
    	           volume VARCHAR(50) '@volume',
				   deal_id VARCHAR(50) '@deal_id',
				   source_deal_detail_id VARCHAR(50) '@source_deal_detail',
				   price_volume VARCHAR(50) '@price_volume',
				   dst VARCHAR(50) '@dst'
		)
		
		DECLARE @source_deal_detail VARCHAR(50)
		DECLARE @term_date VARCHAR(100)
		DECLARE @hr VARCHAR(100)
		DECLARE @price_volume VARCHAR(100) 
		DECLARE @volume VARCHAR(100) 

		DECLARE cur_new CURSOR FOR
		SELECT term_date, hr, volume, source_deal_detail_id, price_volume
		FROM #tmp_process_sddh
		OPEN cur_new
		FETCH NEXT
		FROM cur_new INTO @term_date, @hr, @volume, @source_deal_detail_id, @price_volume
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @sql = 'UPDATE clt
						 SET [' + @hr + '] = ' + ISNULL(@volume, '''''') + ',
						 is_updated = ''y''
						 FROM '  + @column_lists_table 
						+ ' clt WHERE source_deal_detail_id = ' + @source_deal_detail_id 
						+ ' AND [Price/Volume] = ''' + @price_volume + ''''
						+ ' AND [Term Start] = dbo.FNAStdDate(''' + @term_date  + ''')'
			--PRINT @sql
			EXEC(@sql)
		FETCH NEXT
		FROM cur_new INTO @term_date, @hr, @volume, @source_deal_detail_id, @price_volume
		END
		CLOSE cur_new
		DEALLOCATE cur_new
		--PRINT('SELECT * FROM ' + @column_lists_table)
		--EXEC('SELECT  * FROM ' + @column_lists_table)
	END 


	IF @show_select IS NULL
	BEGIN
		IF OBJECT_ID('tempdb..##test_1') IS NOT NULL
			DROP TABLE ##test_1

		SET @sql_hr = 'SELECT * INTO ##test_1 FROM ' + @column_lists_table + ' WHERE is_updated = ''y'''
		EXEC(@sql_hr)

		SELECT @columns_names = STUFF((SELECT DISTINCT ', [' + name + ']' 
								FROM tempdb.sys.columns WITH(NOLOCK)
								WHERE OBJECT_ID = OBJECT_ID('tempdb..##test_1')
									AND name NOT IN (
									'Deal ID'
									, 'Term Start'
									, 'price/volume'
									, 'leg'
									, 'is_updated'
									, 'granularity'
									, 'process_id'
									, 'source_deal_detail_id'
									, 'dst')
								FOR XML PATH('')), 1, 1, '')
		--select @columns_names
		SET @sql = 'SELECT [Deal ID], dbo.FNADateFormat([Term Start]) [Term Start],	[Leg], [Price/Volume], [is_updated], [DST], [granularity], [process_id], [source_deal_detail_id], 
					' + @columns_names + ' FROM '  + 
					+ @column_lists_table 
					+ ' WHERE dbo.FNACovertToSTDDate([Term Start]) >= ''' + dbo.FNACovertToSTDDate(@term_start) + ''' AND dbo.FNACovertToSTDDate([Term Start]) <= ''' + dbo.FNACovertToSTDDate(@term_end) + ''''

		IF @leg IS NOT NULL AND  @leg <> 'NULL'
		BEGIN
			SET @sql = @sql + ' AND leg = ' +  CAST(@leg AS VARCHAR(100))
		END
		
		IF @volume_price <> ''
		BEGIN
			SET @sql = @sql + ' AND [price/volume] = ''' +  CASE WHEN @volume_price = 'v' THEN  'Volume' ELSE 'Price' END + ''''
		END

		SET @sql = @sql + ' ORDER BY  [Term Start] ASC, leg, [price/volume] DESC'
		--PRINT  (@sql)
		EXEC(@sql)
	END 
END


