
IF OBJECT_ID(N'spa_update_wellhead_volume', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_update_wellhead_volume]
GO 

CREATE PROCEDURE [dbo].[spa_update_wellhead_volume]
	@flag CHAR(1),
	@meter_ids VARCHAR(1000) = NULL,
	@channel INT = NULL,
	@term_start DATE = NULL,
	@term_end DATE = NULL,
	@xml varchar(4000) = NULL
AS

SET NOCOUNT ON
--DECLARE @meter_ids VARCHAR(1000)
--DECLARE @channel INT
--DECLARE @term_start DATE
--DECLARE @term_end DATE

--SET @meter_ids = '2,3'
--SET @channel = 1
--SET @term_start = '2014-01-01'
--SET @term_end = '2014-01-04'
DECLARE @date_range VARCHAR(1000)
DECLARE @sql VARCHAR(MAX)

IF @flag = 'g'
BEGIN

	SELECT @date_range = ISNULL(@date_range + ',', '' )  + '[' + CAST(DATEADD(DAY, n - 1, @term_start)  AS VARCHAR(10)) + ']' 
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)

	--SELECT 
	--		mi.meter_id,
	--		mi.recorderid,
	--		'' [bom], 
	--		mdh.prod_date, 
	--		hr1 
	--INTO #temp_wellhead_volume
	--FROM mv90_data md 
	--INNER JOIN mv90_data_hour mdh ON md.meter_data_id = mdh.meter_data_id
	--INNER JOIN dbo.SplitCommaSeperatedValues(@meter_ids) s ON s.item = md.meter_id
	--INNER JOIN meter_id mi ON mi.meter_id = md.meter_id
	--WHERE channel = @channel AND mdh.prod_date between @term_start and @term_end

	DECLARE @dayindex INT 
	IF OBJECT_ID('tempdb..#temp_wellhead_volume') IS NOT NULL
		DROP TABLE #temp_wellhead_volume

	CREATE TABLE #temp_wellhead_volume
	(
		meter_id INT,
		recorderid VARCHAR(1000) COLLATE DATABASE_DEFAULT,
		[bom] INT,
		prod_date DATE,
		hr1 INT
	)

	DECLARE @meter_id INT 
	DECLARE meter_cur CURSOR FOR
		SELECT s.item FROM dbo.SplitCommaSeperatedValues(@meter_ids) s
	OPEN meter_cur
	FETCH NEXT FROM meter_cur INTO @meter_id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @dayindex = 0
		
		WHILE @term_start <> dateadd(day, 1, @term_end)
		BEGIN
			DECLARE @recorderid VARCHAR(500), @hr1 INT

			SELECT @recorderid = m.recorderid, @hr1 = h.Hr1 FROM meter_id m
			OUTER APPLY (
				SELECT md.meter_data_id, mdh.Hr1 FROM mv90_data md
				LEFT JOIN mv90_data_hour mdh ON md.meter_data_id = mdh.meter_data_id
				WHERE md.meter_id = m.meter_id AND mdh.prod_date = @term_start AND channel = @channel 
			) h
			WHERE m.meter_id = @meter_id

			INSERT INTO #temp_wellhead_volume(meter_id, recorderid, [bom], prod_date,hr1) VALUES (@meter_id, @recorderid, '', @term_start, @hr1)
			
			SET @dayindex += 1
			SET @term_start = DATEADD(day, 1, @term_start)
		END
		SET @term_start = DATEADD(day, -@dayindex, @term_start)
		FETCH NEXT FROM meter_cur INTO @meter_id
	END
	CLOSE meter_cur
	DEALLOCATE meter_cur

	SET @sql = '
			SELECT *
			FROM
			(
				SELECT twv.meter_id, twv.recorderid + '' - '' + mi.description AS recorderid, twv.bom, twv.prod_date, twv.hr1 
				FROM #temp_wellhead_volume twv
				LEFT JOIN meter_id mi ON mi.meter_id = twv.meter_id
			) AS aa
			PIVOT (
				SUM(hr1)
				FOR prod_date 
				IN (' +  @date_range + ')
			) AS well_head '

	EXEC(@sql)
END
ELSE IF @flag = 'h'
BEGIN
	DECLARE @header_name VARCHAR(5000)
	DECLARE @column_type VARCHAR(5000)
	DECLARE @header_id VARCHAR(5000)
	DECLARE @column_width VARCHAR(5000)
	DECLARE @column_visibility VARCHAR(5000)


	SET @header_name = 'Meter ID,Wellhead,Update BOM'
	SELECT @header_name = ISNULL(@header_name + ',', '' )  + dbo.FNADateFormat(CAST(DATEADD(DAY, n - 1, @term_start)  AS VARCHAR(10)))
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)

	SET @column_type = 'ro,ro,ch'
	SELECT @column_type = ISNULL(@column_type + ',', '' )  + 'ed_v'
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)

	SET @column_width = '100,200,100'
	SELECT @column_width = ISNULL(@column_width + ',', '' )  + '80'
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)

	SET @header_id = 'meter_id,recorderid,bom'
	SELECT @header_id = ISNULL(@header_id + ',', '' )  + CAST(DATEADD(DAY, n - 1, @term_start)  AS VARCHAR(10))
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)

	SET @column_visibility = 'true,false,false'
	SELECT @column_visibility = ISNULL(@column_visibility + ',', '' )  + 'false'
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)

	SELECT @header_name [header_name], @header_id [header_id], @column_type [column_type], @column_width [column_width], @column_visibility [column_visibility]
END
ELSE IF @flag = 'u'
BEGIN
	DECLARE @idoc  INT
	DECLARE @xml_cols VARCHAR(1000)
	DECLARE @unpivot_cols VARCHAR(1000) 

	SET @xml_cols = '[meter_id] INT, bom INT'

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
	IF OBJECT_ID('tempdb..#temp_xml_columns') IS NOT NULL
		DROP TABLE #temp_xml_columns

	SELECT @term_start = term_start, @term_end = term_end, @channel = channel
	FROM OPENXML(@idoc, '/Grid', 1)
	WITH ( 
		term_start DATE,
		term_end DATE,
		channel INT
	)

	SELECT @unpivot_cols = ISNULL(@unpivot_cols + ',', '' )  + '[_' + CAST(DATEADD(DAY, n - 1, @term_start)  AS VARCHAR(10)) + ']' 
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)
	
	SELECT @xml_cols = ISNULL(@xml_cols + ',', '' )  + '[_' + CAST(DATEADD(DAY, n - 1, @term_start)  AS VARCHAR(10)) + '] INT' 
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)

	SET @sql = CAST('' AS VARCHAR(MAX)) + '
		DECLARE @idoc  INT

		DECLARE @xml xml =''' + @xml + '''
		DECLARE @channel INT =' + CAST(@channel AS VARCHAR(10)) + '
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		SELECT *
		INTO #temp_xml_columns
		FROM OPENXML(@idoc, ''/Grid/GridRow'', 1)
		WITH ( '
			+ @xml_cols +
		')
			
		SELECT meter_id, bom, NULLIF(hr1, -1) hr1, RIGHT(unpvt.prod_date, len(unpvt.prod_date) - 1) prod_date
		INTO #temp_unpvt
		FROM 
			(SELECT meter_id, bom, ' + @unpivot_cols + '
			FROM #temp_xml_columns) p
		UNPIVOT
			(hr1 FOR prod_date IN 
				(' + @unpivot_cols + ')
		) AS unpvt
		
		IF DATEDIFF ( MONTH , ''' + CAST(@term_start AS VARCHAR(10)) + ''', ''' + CAST(@term_end AS VARCHAR(10)) + ''' ) = 1
		BEGIN
		
			INSERT INTO mv90_data(meter_id,	gen_date, from_date,	to_date, channel)
			SELECT  tu.meter_id,  CAST(tu.prod_date as varchar(7)) + ''-01'',  
				CAST(tu.prod_date as varchar(7)) + ''-01'', 
				 dbo.FNALastDayInDate(CAST(tu.prod_date as varchar(7)) + ''-01''), 
				' + CAST(@channel AS VARCHAR(10))+'
			FROM  #temp_unpvt tu 
			LEFT JOIN mv90_data md
				ON tu.meter_id = md.meter_id
				AND md.channel = ' +  CAST(@channel AS VARCHAR(10)) + '
				and md.from_date =''' + CAST(@term_start AS VARCHAR(8)) + '01' + '''				
			WHERE md.meter_data_id IS NULL		
				AND CAST(tu.prod_date AS VARCHAR(7)) <> ''' +  CAST(@term_end AS VARCHAR(7)) + '''	
			GROUP BY tu.meter_id,  CAST(tu.prod_date as varchar(7))
			UNION ALL 
			SELECT  tu.meter_id,  CAST(tu.prod_date as varchar(7)) + ''-01'',  
				CAST(tu.prod_date as varchar(7)) + ''-01'', 
				 dbo.FNALastDayInDate(CAST(tu.prod_date as varchar(7)) + ''-01''), 
				' + CAST(@channel AS VARCHAR(10))+'
			FROM  #temp_unpvt tu 
			LEFT JOIN mv90_data md
				ON tu.meter_id = md.meter_id
				AND md.channel = ' +  CAST(@channel AS VARCHAR(10)) + '
				and md.from_date =''' + CAST(@term_end AS VARCHAR(8)) + '01' + '''
			WHERE md.meter_data_id IS NULL  
				AND CAST(tu.prod_date AS VARCHAR(7)) <> ''' +  CAST(@term_start AS VARCHAR(7)) + '''
			GROUP BY tu.meter_id,  CAST(tu.prod_date as varchar(7))
		END
		ELSE IF DATEDIFF ( MONTH , ''' + CAST(@term_start AS VARCHAR(10)) + ''', ''' + CAST(@term_end AS VARCHAR(10)) + ''' ) = 0
		BEGIN
			INSERT INTO mv90_data(meter_id,	gen_date, from_date,	to_date, channel)
			SELECT  tu.meter_id,  CAST(tu.prod_date as varchar(7)) + ''-01'',  
				CAST(tu.prod_date as varchar(7)) + ''-01'', 
				 dbo.FNALastDayInDate(CAST(tu.prod_date as varchar(7)) + ''-01''), 
				' + CAST(@channel AS VARCHAR(10))+'
			FROM  #temp_unpvt tu 
			LEFT JOIN mv90_data md
				ON tu.meter_id = md.meter_id
				AND md.channel = ' +  CAST(@channel AS VARCHAR(10)) + '
				and md.from_date =''' + CAST(@term_start AS VARCHAR(8)) + '01' + '''				
			WHERE md.meter_data_id IS NULL		
				
			GROUP BY tu.meter_id,  CAST(tu.prod_date as varchar(7))
		END
			
		UPDATE mdh SET mdh.hr1 = unpvt.hr1
		--SELECT mdh.hr1, unpvt.hr1, *
		FROM #temp_unpvt unpvt
		LEFT JOIN mv90_data md ON unpvt.meter_id = md.meter_id
			AND CAST(unpvt.prod_date AS VARCHAR(7)) = cast([dbo].[FNAGetSQLStandardDate](md.from_date) AS VARCHAR(7))
			AND md.channel = ' +  CAST(@channel AS VARCHAR(10)) + '
		INNER JOIN mv90_data_hour mdh ON md.meter_data_id = mdh.meter_data_id
			AND mdh.prod_date = unpvt.prod_date
		
		SELECT md.meter_data_id, tu.prod_date, tu.hr1, md.channel INTO #temp_avail_date 
		FROM #temp_unpvt tu INNER JOIN 
			(
				SELECT  max(unpvt.prod_date) prod_date, meter_id
				FROM #temp_unpvt unpvt
				WHERE unpvt.bom = 1 AND hr1 IS NOT NULL
					GROUP BY meter_id, CAST(unpvt.prod_date as varchar(7))
			 ) sub
			ON tu.prod_date = sub.prod_date
			AND tu.meter_id = sub.meter_id
		INNER JOIN mv90_data md ON tu.meter_id = md.meter_id
			AND CAST(tu.prod_date AS VARCHAR(7)) = CAST([dbo].[FNAGetSQLStandardDate](md.from_date) AS VARCHAR(7))
			AND md.channel = ' +  CAST(@channel AS VARCHAR(10)) + '
 	
 		SELECT tad.meter_data_id, DATEADD(DAY, n, tad.prod_date) prod_date,  tad.hr1 
			INTO #temp_miss_date
		FROM #temp_avail_date tad  
			CROSS JOIN seq 
		WHERE  
		DATEADD(DAY, n, tad.prod_date) <= dbo.FNALastDayInDate(tad.prod_date) AND n < 64
		UNION ALL
		SELECT md.meter_data_id, unpvt.prod_date,unpvt.hr1
		FROM #temp_unpvt unpvt
			INNER JOIN mv90_data md ON unpvt.meter_id = md.meter_id
				AND CAST(unpvt.prod_date AS VARCHAR(7)) = cast([dbo].[FNAGetSQLStandardDate](md.from_date) AS VARCHAr(7))
				AND md.channel = ' +  CAST(@channel AS VARCHAR(10)) + '
			LEFT JOIN mv90_data_hour mdh ON md.meter_data_id = mdh.meter_data_id
				AND mdh.prod_date = unpvt.prod_date
		WHERE mdh.meter_data_id IS NULL
			AND unpvt.hr1 IS NOT NULL

		 UPDATE mdh
		 SET mdh.hr1 = tmd.hr1
		 --SELECT mdh.*
		 FROM mv90_data_hour mdh 
			 INNER JOIN #temp_miss_date tmd
				ON mdh.meter_data_id = tmd.meter_data_id 
				AND mdh.prod_date = tmd.prod_date
		
		INSERT INTO mv90_data_hour( meter_data_id,	prod_date,	Hr1)
		SELECT tmd.meter_data_id, tmd.prod_date, tmd.Hr1
			 FROM #temp_miss_date tmd 
		 LEFT JOIN mv90_data_hour mdh 
			ON mdh.meter_data_id = tmd.meter_data_id 
			AND mdh.prod_date = tmd.prod_date
		WHERE mdh.meter_data_id IS NULL
		
		
		IF (CAST(@xml AS VARCHAR(MAX)) <> '''')
		BEGIN
			DECLARE @process_id VARCHAR(200), @tempTable VARCHAR(300), @sqlStmt VARCHAR(5000), @user_login_id VARCHAR(50)

			SET @process_id = dbo.FNAGetNewID()
			SET @user_login_id = dbo.FNADBUser()

			SET @tempTable = dbo.FNAProcessTableName(''temp_wellhead'', @user_login_id, @process_id)
			
			EXEC(''SELECT smlm.source_minor_location_id, MIN(prod_date) date 
			INTO '' + @tempTable + ''
			FROM #temp_unpvt tun
			INNER JOIN source_minor_location_meter smlm ON tun.meter_id = smlm.meter_id
			GROUP BY source_minor_location_id'')
			
			EXEC spa_check_conflicting_volume_split_nom @tempTable, ''w''
		END
	'
	
	EXEC (@sql)

	EXEC spa_ErrorHandler 0, 
		'Update Wellhead Volume', 
		'spa_wellhead_volume', 
		'Success', 
		'Changes have been saved successfully.',
		''
END
ELSE IF @flag = 's' 
BEGIN
	EXEC
	('SELECT recorderid FROM meter_id 
	WHERE meter_id IN (' + @meter_ids + ')')
END

