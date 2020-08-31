
IF OBJECT_ID(N'spa_update_demand_volume', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_update_demand_volume]
GO 

/**
	Update demand volume operations
	Parameters
	@flag : Opertion Flag
	@deal_ref_ids : Deal Reference ID
	@location_ids : Location ID
	@term_start : Term Start
	@term_end : Term END
	@xml : XML data for operations.
	@filter_value : Filter Data. 
*/

CREATE PROCEDURE [dbo].[spa_update_demand_volume]
	@flag CHAR(1),
	@deal_ref_ids VARCHAR(1000) = NULL,
	@location_ids VARCHAR(1000) = NULL,
	@term_start DATE = NULL,
	@term_end DATE = NULL,
	@xml VARCHAR(4000) = NULL,
	@volume_type INT = NULL,
	@filter_value VARCHAR(1000) = NULL
AS
/***************************************
DECLARE @flag CHAR(1),
		@deal_ref_ids VARCHAR(1000) = NULL,
		@location_ids VARCHAR(1000) = NULL,
		@term_start DATE = NULL,
		@term_end DATE = NULL,
		@xml varchar(4000) = NULL,
		@volume_type INT = NULL

SET @flag='p'
--SET @deal_ref_ids='366332' 
--SET @term_start='2016-04-28' 
--SET @term_end='2016-05-05'
--SET @volume_type = 10131019
--SET @xml='<Grid term_start="2016-05-08" term_end="2016-05-16"><GridRow  deal_ref_id="367340" location_id="27186" deal_ref="TESTkl" location="Glad Hill Draw 1-13" leg="1" Volume="Actual Volume" bom="0" _2016-05-08="-1" _2016-05-09="-1" _2016-05-10="-1" _2016-05-11="-1" _2016-05-12="-1" _2016-05-13="-1" _2016-05-14="-1" _2016-05-15="555" _2016-05-16="-1" ></GridRow> </Grid>'
--*/
SET NOCOUNT ON

DECLARE @date_range VARCHAR(1000)
DECLARE @sql VARCHAR(MAX)
DECLARE @app_admin_role_check INT,
		@sql_Select VARCHAR(MAX)

SET @sql = CAST('' AS VARCHAR(MAX)) + @sql
SET @app_admin_role_check = dbo.FNAAppAdminRoleCheck(dbo.FNADBUser())

IF @flag = 'g'
BEGIN
	IF OBJECT_ID('tempdb..#temp_dempand_vol') IS NOT NULL
		DROP TABLE #temp_dempand_vol

	SELECT @date_range = ISNULL(@date_range + ',', '' )  + '[' + CAST(DATEADD(DAY, n - 1, @term_start)  AS VARCHAR(10)) + ']' 
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)
	
	IF OBJECT_ID('tempdb..#temp_privilege') IS NOT NULL
	DROP TABLE #temp_privilege

	CREATE TABLE #temp_privilege(function_name VARCHAR(100) COLLATE DATABASE_DEFAULT )
	
	INSERT INTO #temp_privilege
	SELECT DISTINCT af.function_name 
	FROM application_functions af
		LEFT JOIN application_functional_users afu
			ON af.function_id = afu.function_id
		LEFT JOIN application_users au 
			ON afu.login_id = au.user_login_id		
	WHERE ((user_login_id = dbo.FNADBUser() AND  @app_admin_role_check = 0 AND af.function_id IN (10131031, 10131032, 10131033))
	OR (@app_admin_role_check = 1 AND af.function_id IN (10131031, 10131032, 10131033)))
	AND (af.function_id = @volume_type OR NULLIF(@volume_type, '') IS NULL)

	SELECT sdd.term_start, 
		   sdh.source_deal_header_id, 
		   sdd.source_deal_detail_id, 
		   sdh.deal_id, 
		   sdd.location_id,
		   sdd.leg, 
		   sml.location_name, '' [bom], 
		   CAST(dbo.FNARemoveTrailingZero(sdd.deal_volume) AS INT) deal_volume,
		   CAST(dbo.FNARemoveTrailingZero(sdd.schedule_volume) AS INT) schedule_volume,
		   CAST(dbo.FNARemoveTrailingZero(sdd.actual_volume) AS INT) actual_volume
	INTO #temp_dempand_vol
	FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd 
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN dbo.SplitCommaSeperatedValues(@deal_ref_ids) AS d
			ON d.item = sdh.source_deal_header_id
		INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
	WHERE sdh.term_frequency='d'
	--AND sdd.term_start BETWEEN @term_start AND @term_end
	
	SET @sql = '
			SELECT *
			FROM
			(
				SELECT term_start, source_deal_header_id,location_id, deal_id, location_name, leg, ''Deal Volume'' Volume, bom, deal_volume FROM #temp_dempand_vol 
			) AS aa
			PIVOT (
				SUM(deal_volume)
				FOR term_start 
				IN (' +  @date_range + ')
			) AS demand_vol
			INNER JOIN #temp_privilege tp on tp.function_name = ''Update '' + demand_vol.volume
			UNION ALL
			SELECT *
			FROM
			(
				SELECT term_start, source_deal_header_id,location_id, deal_id, location_name, leg, ''Schedule Volume'' Volume, bom, schedule_volume FROM #temp_dempand_vol 
			) AS aa
			PIVOT (
				SUM(schedule_volume)
				FOR term_start 
				IN (' +  @date_range + ')
			) AS schedule_volume
			INNER JOIN #temp_privilege tp on tp.function_name = ''Update '' + schedule_volume.volume
			UNION ALL
			SELECT *
			FROM
			(
				SELECT term_start, source_deal_header_id,location_id, deal_id, location_name, leg, ''Actual Volume'' Volume, bom, actual_volume FROM #temp_dempand_vol 
			) AS aa
			PIVOT (
				SUM(actual_volume)
				FOR term_start 
				IN (' +  @date_range + ')
			) AS actual_volume
			INNER JOIN #temp_privilege tp on tp.function_name = ''Update '' + actual_volume.volume
			ORDER BY volume, leg
			'

	EXEC(@sql)
END
ELSE IF @flag = 'h'
BEGIN
	DECLARE @header_name VARCHAR(5000)
	DECLARE @column_type VARCHAR(5000)
	DECLARE @header_id VARCHAR(5000)
	DECLARE @column_width VARCHAR(5000)
	DECLARE @column_visibility VARCHAR(5000)
	DECLARE @column_sorting VARCHAR(5000)

	SET @header_name = 'Deal Ref ID,Location ID,Deal Ref,Location,Leg,Volume Type,Update BOM'
	SELECT @header_name = ISNULL(@header_name + ',', '' )  + dbo.FNADateFormat(CAST(DATEADD(DAY, n - 1, @term_start)  AS VARCHAR(10)))
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)

	SET @column_type = 'ro,ro,ro,ro,ro,ro,ch'
	SELECT @column_type = ISNULL(@column_type + ',', '' )  + 'ed_no'
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)

	SET @column_width = '50,50,142,142,50,142,60'
	SELECT @column_width = ISNULL(@column_width + ',', '' )  + '80'
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)

	SET @header_id = 'deal_ref_id,location_id,deal_ref,location,leg,Volume,bom'
	SELECT @header_id = ISNULL(@header_id + ',', '' )  + CAST(DATEADD(DAY, n - 1, @term_start)  AS VARCHAR(10))
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)

	SET @column_visibility = 'true,true,false,false,false,false,false'
	SELECT @column_visibility = ISNULL(@column_visibility + ',', '' )  + 'false'
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)

	SET @column_sorting = 'str,str,str,str,str,str,str'
	SELECT @column_sorting = ISNULL(@column_sorting + ',', '' )  + 'str'
	FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)

	SELECT @header_name [header_name], @header_id [header_id], @column_type [column_type], @column_width [column_width], @column_visibility [column_visibility], @column_sorting [Column_Sorting]
END
ELSE IF @flag = 'u'
BEGIN
	IF @xml <> ''
	BEGIN
		DECLARE @idoc  INT
		DECLARE @xml_cols VARCHAR(1000)
		DECLARE @unpivot_cols VARCHAR(1000) 
	
		
		IF OBJECT_ID('tempdb..#temp_xml_columns') IS NOT NULL
			DROP TABLE #temp_xml_columns

		SET @xml_cols = 'deal_ref VARCHAR(100), [location_id] INT, leg INT, Volume VARCHAR(100),	bom INT'

		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml


		SELECT @term_start = term_start, @term_end = term_end
		FROM OPENXML(@idoc, '/Grid', 1)
		WITH ( 
			term_start DATE,
			term_end DATE
		)

		SELECT @unpivot_cols = ISNULL(@unpivot_cols + ',', '' )  + '[_' + CAST(DATEADD(DAY, n - 1, @term_start)  AS VARCHAR(10)) + ']' 
		FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)
	
		SELECT @xml_cols = ISNULL(@xml_cols + ',', '' )  + '[_' + CAST(DATEADD(DAY, n - 1, @term_start)  AS VARCHAR(10)) + '] INT' 
		FROM seq WHERE n <= (SELECT DATEDIFF(DAY, @term_start, @term_end) + 1)
		
		SET @sql = CAST('' AS VARCHAR(MAX)) + '
			DECLARE @idoc  INT
			DECLARE @msg VARCHAR(1000)
			DECLARE @xml xml =''' + @xml + '''
			
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

			--store data from xml to temp table
			SELECT *
			INTO #temp_xml_columns
			FROM OPENXML(@idoc, ''/Grid/GridRow'', 1)
			WITH ( '
				+ @xml_cols +
			')
			

			--unpivot data over term_start
			SELECT deal_ref, location_id, leg, volume, bom, NULLIF(deal_volume, -1) deal_volume, RIGHT(unpvt.term_start, len(unpvt.term_start) - 1) term_start
			INTO #temp_unpvt
			FROM 
				(SELECT deal_ref, location_id, leg, volume ,bom, ' + @unpivot_cols + '
				FROM #temp_xml_columns) p
			UNPIVOT
				(deal_volume FOR term_start IN 
					(' + @unpivot_cols + ')
			) AS unpvt


			SELECT DISTINCT  tu.deal_ref, tu.location_id, tu.leg
				INTO #term_not_found_deal_vol 
				FROM #temp_unpvt tu
				LEFT JOIN source_deal_header sdh
					ON tu.deal_ref = sdh.deal_id
				LEFT JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.location_id = tu.location_id
					AND sdd.term_start = tu.term_start
					AND sdd.leg = tu.leg
			WHERE sdd.term_start IS NULL AND tu.volume = ''Deal Volume''
			
			SELECT DISTINCT  tu.deal_ref, tu.location_id, tu.leg
				INTO #term_not_found_sch_vol 
				FROM #temp_unpvt tu
				LEFT JOIN source_deal_header sdh
					ON tu.deal_ref = sdh.deal_id
				LEFT JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.location_id = tu.location_id
					AND sdd.term_start = tu.term_start
					AND sdd.leg = tu.leg
			WHERE sdd.term_start IS NULL AND tu.volume = ''Schedule Volume''
			
			SELECT DISTINCT  tu.deal_ref, tu.location_id, tu.leg
				INTO #term_not_found_act_vol
				FROM #temp_unpvt tu
				LEFT JOIN source_deal_header sdh
					ON tu.deal_ref = sdh.deal_id
				LEFT JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.location_id = tu.location_id
					AND sdd.term_start = tu.term_start
					AND sdd.leg = tu.leg
			WHERE sdd.term_start IS NULL AND tu.volume = ''Actual Volume''

			IF EXISTS(
				SELECT 1
				FROM #temp_unpvt tu
				LEFT JOIN source_deal_header sdh
				  ON sdh.deal_id = tu.deal_ref
				LEFT JOIN source_deal_detail sdd
				  ON sdh.source_deal_header_id = sdd.source_deal_header_id
				  AND sdd.term_start = tu.term_start
				WHERE sdd.source_deal_detail_id IS NULL
				AND tu.deal_volume IS NOT NULL
			)
			BEGIN
				SET @msg = ''Volume cannot be updated for the selected term.''
			
				EXEC spa_ErrorHandler -1, 
				''Update Demand Volume'', 
				''spa_demand_volume'', 
				''Error'', 
				@msg,
				''''
				RETURN
			END
						
			IF EXISTS (SELECT 1 FROM #temp_unpvt WHERE bom = 0)
			BEGIN
				UPDATE sdd
				SET sdd.cycle = 41000
				FROM #temp_unpvt tu
					INNER JOIN source_deal_header sdh
						ON tu.deal_ref = sdh.deal_id
					INNER JOIN source_deal_detail sdd
						ON sdd.source_deal_header_id = sdh.source_deal_header_id
						AND sdd.location_id = tu.location_id
						AND sdd.term_start = tu.term_start
						AND sdd.leg = tu.leg
				WHERE 1 = 1 
					AND (volume = ''Deal Volume'' AND ISNULL(tu.deal_volume, 1) <> ISNULL(sdd.deal_volume, 1))
					OR (volume = ''Schedule Volume'' AND ISNULL(tu.deal_volume, 1) <> ISNULL(sdd.schedule_volume, 1))
					OR (volume = ''Actual Volume'' AND ISNULL(tu.deal_volume, 1) <> ISNULL(sdd.actual_volume, 1))
			END	

			--update deal_volume according to xml data for deal_volume in case of bom = 0 and volume type is nom volume
			UPDATE sdd
			SET sdd.deal_volume = tu.deal_volume
			FROM #temp_unpvt tu
				INNER JOIN source_deal_header sdh
					ON tu.deal_ref = sdh.deal_id
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.location_id = tu.location_id
					AND sdd.term_start = tu.term_start
					AND sdd.leg = tu.leg
					AND tu.volume = ''Deal Volume''
			
			--update deal_volume according to xml data for deal_volume in case of bom = 0 and volume type is schedule volume
			UPDATE sdd
			SET sdd.schedule_volume = tu.deal_volume
			FROM #temp_unpvt tu
				INNER JOIN source_deal_header sdh
					ON tu.deal_ref = sdh.deal_id
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.location_id = tu.location_id
					AND sdd.term_start = tu.term_start
					AND sdd.leg = tu.leg
					AND tu.volume = ''Schedule Volume''
			
			--update deal_volume according to xml data for deal_volume in case of bom = 0 and volume type is option volume
			UPDATE sdd
			SET sdd.actual_volume = tu.deal_volume
			FROM #temp_unpvt tu
				INNER JOIN source_deal_header sdh
					ON tu.deal_ref = sdh.deal_id
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.location_id = tu.location_id
					AND sdd.term_start = tu.term_start
					AND sdd.leg = tu.leg
					AND tu.volume = ''Actual Volume''
			
			------------------------------------------------------------------bom=1---------------------------------------------------------------
			--get all available date in case of bom = 1
			
			SELECT unpvt.deal_ref, unpvt.location_id, unpvt.leg, unpvt.term_start, unpvt.deal_volume
			INTO #temp_avail_date_deal_vol
			FROM #temp_unpvt unpvt
			INNER JOIN (
				SELECT deal_ref, location_id, leg, max(term_start) term_start 
				FROM #temp_unpvt 
				where bom = 1 AND deal_volume IS NOT NULL AND volume = ''Deal Volume''
				GROUP BY deal_ref, location_id, leg, CAST(term_start AS VARCHAR(7))
			) unpvt1
			ON unpvt.term_start = unpvt1.term_start
			AND unpvt.deal_ref = unpvt1.deal_ref
			AND unpvt.location_id = unpvt1.location_id
			AND unpvt.leg = unpvt1.leg
			AND unpvt.volume = ''Deal Volume''
			


			SELECT unpvt.deal_ref, unpvt.location_id, unpvt.leg, unpvt.term_start, unpvt.deal_volume
			INTO #temp_avail_date_sch_vol
			FROM #temp_unpvt unpvt
			INNER JOIN (
				SELECT deal_ref, location_id, leg, max(term_start) term_start 
				FROM #temp_unpvt 
				where bom = 1 AND deal_volume IS NOT NULL AND volume = ''Schedule Volume''
				GROUP BY deal_ref, location_id, leg, CAST(term_start AS VARCHAR(7))
			) unpvt1
			ON unpvt.term_start = unpvt1.term_start
			AND unpvt.deal_ref = unpvt1.deal_ref
			AND unpvt.location_id = unpvt1.location_id
			AND unpvt.leg = unpvt1.leg
			AND unpvt.volume = ''Schedule Volume''

			SELECT unpvt.deal_ref, unpvt.location_id, unpvt.leg, unpvt.term_start, unpvt.deal_volume
			INTO #temp_avail_date_act_vol
			FROM #temp_unpvt unpvt
			INNER JOIN (
				SELECT deal_ref, location_id, leg, max(term_start) term_start 
				FROM #temp_unpvt 
				where bom = 1 AND deal_volume IS NOT NULL AND volume = ''Actual Volume''
				GROUP BY deal_ref, location_id, leg, CAST(term_start AS VARCHAR(7))
			) unpvt1
			ON unpvt.term_start = unpvt1.term_start
			AND unpvt.deal_ref = unpvt1.deal_ref
			AND unpvt.location_id = unpvt1.location_id
			AND unpvt.leg = unpvt1.leg
			AND unpvt.volume = ''Actual Volume''
			
			--get all missing date in case of bom = 1
			SELECT tad.deal_ref, location_id, leg, [dbo].[FNAGetSQLStandardDate](DATEADD(DAY, n, tad.term_start)) term_start
				INTO #temp_miss_date_deal_vol
			FROM #temp_avail_date_deal_vol tad  
				CROSS JOIN seq 
			WHERE  
				DATEADD(DAY, n, tad.term_start) <= dbo.FNALastDayInDate(tad.term_start)			
				AND n < 64	
			
			SELECT tad.deal_ref, location_id, leg, [dbo].[FNAGetSQLStandardDate](DATEADD(DAY, n, tad.term_start)) term_start
				INTO #temp_miss_date_sch_vol
			FROM #temp_avail_date_sch_vol tad  
				CROSS JOIN seq 
			WHERE  
				DATEADD(DAY, n, tad.term_start) <= dbo.FNALastDayInDate(tad.term_start)			
				AND n < 64

			SELECT tad.deal_ref, location_id, leg, [dbo].[FNAGetSQLStandardDate](DATEADD(DAY, n, tad.term_start)) term_start
				INTO #temp_miss_date_act_vol
			FROM #temp_avail_date_act_vol tad  
				CROSS JOIN seq 
			WHERE  
				DATEADD(DAY, n, tad.term_start) <= dbo.FNALastDayInDate(tad.term_start)			
				AND n < 64

			INSERT INTO #term_not_found_deal_vol (deal_ref, location_id, leg)
			SELECT DISTINCT tmd.deal_ref, tmd.location_id, tmd.leg
			FROM #temp_miss_date_deal_vol tmd
				LEFT JOIN #temp_avail_date_deal_vol tad
					ON tmd.deal_ref = tad.deal_ref
					AND tmd.location_id = tad.location_id
					AND CAST(tmd.term_start AS VARCHAR(7)) = CAST(tad.term_start AS VARCHAR(7))	
				INNER JOIN source_deal_header sdh
					ON sdh.deal_id = tmd.deal_ref
				LEFT JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.location_id = tmd.location_id
					AND sdd.leg = tmd.leg
					AND sdd.term_start = tmd.term_start
			WHERE sdd.term_start IS NULL
			
			INSERT INTO #term_not_found_sch_vol (deal_ref, location_id, leg)
			SELECT DISTINCT tmd.deal_ref, tmd.location_id, tmd.leg
			FROM #temp_miss_date_sch_vol tmd
				LEFT JOIN #temp_avail_date_sch_vol tad
					ON tmd.deal_ref = tad.deal_ref
					AND tmd.location_id = tad.location_id
					AND CAST(tmd.term_start AS VARCHAR(7)) = CAST(tad.term_start AS VARCHAR(7))	
				INNER JOIN source_deal_header sdh
					ON sdh.deal_id = tmd.deal_ref
				LEFT JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.location_id = tmd.location_id
					AND sdd.leg = tmd.leg
					AND sdd.term_start = tmd.term_start
			WHERE sdd.term_start IS NULL

			INSERT INTO #term_not_found_act_vol (deal_ref, location_id, leg)
			SELECT DISTINCT tmd.deal_ref, tmd.location_id, tmd.leg
			FROM #temp_miss_date_act_vol tmd
				LEFT JOIN #temp_avail_date_act_vol tad
					ON tmd.deal_ref = tad.deal_ref
					AND tmd.location_id = tad.location_id
					AND CAST(tmd.term_start AS VARCHAR(7)) = CAST(tad.term_start AS VARCHAR(7))	
				INNER JOIN source_deal_header sdh
					ON sdh.deal_id = tmd.deal_ref
				LEFT JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.location_id = tmd.location_id
					AND sdd.leg = tmd.leg
					AND sdd.term_start = tmd.term_start
			WHERE sdd.term_start IS NULL
			
			
			--update sdd deal_volume by lastest available date from xml
			IF EXISTS (SELECT 1 FROM #temp_unpvt WHERE bom = 1)
			BEGIN
				UPDATE sdd
				SET sdd.cycle = 41000	
				FROM #temp_unpvt tu
				INNER join source_deal_header sdh 
					ON tu.deal_ref = sdh.deal_id
				INNER join source_deal_detail sdd 
					ON sdh.source_deal_header_id = sdd.source_deal_header_id
					AND sdd.term_start = tu.term_start
					AND sdd.leg = tu.leg
			END
			
			UPDATE sdd 
			SET  sdd.deal_volume = tad.deal_volume
			FROM #temp_miss_date_deal_vol tmd
				LEFT JOIN #temp_avail_date_deal_vol tad
					ON tmd.deal_ref = tad.deal_ref
					AND tmd.location_id = tad.location_id
					AND CAST(tmd.term_start AS VARCHAR(7)) = CAST(tad.term_start AS VARCHAR(7))
	
				INNER JOIN source_deal_header sdh
					ON sdh.deal_id = tmd.deal_ref
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.location_id = tmd.location_id
					AND sdd.leg = tmd.leg
					AND sdd.term_start = tmd.term_start
			
			UPDATE sdd 
			SET  sdd.schedule_volume = tad.deal_volume
			FROM #temp_miss_date_sch_vol tmd
				LEFT JOIN #temp_avail_date_sch_vol tad
					ON tmd.deal_ref = tad.deal_ref
					AND tmd.location_id = tad.location_id
					AND CAST(tmd.term_start AS VARCHAR(7)) = CAST(tad.term_start AS VARCHAR(7))
	
				INNER JOIN source_deal_header sdh
					ON sdh.deal_id = tmd.deal_ref
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.location_id = tmd.location_id
					AND sdd.leg = tmd.leg
					AND sdd.term_start = tmd.term_start	
					
			UPDATE sdd 
			SET  sdd.actual_volume = tad.deal_volume
			FROM #temp_miss_date_act_vol tmd
				LEFT JOIN #temp_avail_date_act_vol tad
					ON tmd.deal_ref = tad.deal_ref
					AND tmd.location_id = tad.location_id
					AND CAST(tmd.term_start AS VARCHAR(7)) = CAST(tad.term_start AS VARCHAR(7))
	
				INNER JOIN source_deal_header sdh
					ON sdh.deal_id = tmd.deal_ref
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.location_id = tmd.location_id
					AND sdd.leg = tmd.leg
					AND sdd.term_start = tmd.term_start					
			------------------------------------------------------------------bom=1---------------------------------------------------------------

			DECLARE @job_name       VARCHAR(150),
					@user_login_id  VARCHAR(30),
					@effected_deals VARCHAR(150),
					@st				VARCHAR(max),
					@process_id		VARCHAR(100),
					@call_from		VARCHAR(20) = NULL

			SET @process_id = dbo.FNAGetNewID()
			SET @user_login_id = dbo.FNADBUser()
			SET @effected_deals = dbo.FNAProcessTableName(''report_position'', @user_login_id, @process_id)
			SET @job_name = ''calc_deal_position_breakdown'' + @process_id
			SET @st = ''CREATE TABLE '' + @effected_deals + '' (source_deal_header_id INT, [action] varchar(1))''
			
			EXEC(@st)

			SET @st = ''INSERT INTO '' + @effected_deals  + ''
						SELECT DISTINCT sdh.source_deal_header_id source_deal_header_id, ''''i'''' [action] 
						FROM #temp_unpvt tu
						INNER JOIN source_deal_header sdh
							ON tu.deal_ref = sdh.deal_id''
			
			EXEC(@st)
			
			SET @st = ''spa_update_deal_total_volume NULL,'''''' + @process_id + '''''',0,1,'''''' + @user_login_id + '''''',NULL, NULL, '' + ISNULL('''''''' + @call_from + '''''''' , ''NULL'') + ''''
			
			EXEC spa_run_sp_as_job @job_name,  @st, ''generating_report_table'', @user_login_id

			--Update Audit Log
			DECLARE @affected_deals VARCHAR(MAX)
			
			SELECT @affected_deals = COALESCE(@affected_deals + '','', '''') + CAST(sdh.source_deal_header_id AS VARCHAR(10))
			FROM #temp_unpvt tu
				INNER JOIN source_deal_header sdh
					ON tu.deal_ref = sdh.deal_id
			GROUP BY sdh.source_deal_header_id
			
			SET @st = ''spa_insert_update_audit ''''u'''','''''' + @affected_deals + '''''',''''Updated from deal volume.''''''
			SET @job_name = ''spa_insert_update_audit_affected_'' + @process_id
 	
			EXEC spa_run_sp_as_job @job_name, @st, ''spa_insert_update_audit_affected'', @user_login_id

			EXEC spa_ErrorHandler 0, 
			''Update Demand Volume'', 
			''spa_demand_volume'', 
			''Success'', 
			''Changes have been saved successfully.'',
			''''
		'
	
		EXEC(@sql)
	END
	ELSE
	BEGIN
		EXEC spa_ErrorHandler 0, 
			'Update Demand Volume', 
			'spa_demand_volume', 
			'Success', 
			'Changes have been saved successfully.',
			''
	END
END
ELSE IF @flag = 'l'
BEGIN
	SET @sql_Select = 'SELECT DISTINCT sdd.location_id,sml.location_name FROM source_deal_detail sdd
	LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
	'	
	IF @filter_value IS NOT NULL AND @filter_value <> '-1'
	BEGIN
		SET @sql_Select += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = sdd.location_id'
	END
	SET @sql_Select += 'WHERE sdh.source_deal_header_id IN (' + @deal_ref_ids + ') AND sdd.location_id IS NOT NULL'
	EXEC (@sql_Select)
END
ELSE IF @flag = 's'
BEGIN
	EXEC ('SELECT deal_id FROM source_deal_header 
	WHERE source_deal_header_id IN (' + @deal_ref_ids + ')')
END
ELSE IF @flag = 'a'
BEGIN
	EXEC ('SELECT location_name FROM source_minor_location 
	WHERE source_minor_location_id IN (' + @location_ids + ')')
END
ELSE IF @flag = 'p'
BEGIN
	SELECT DISTINCT af.function_id,
		   REPLACE(af.function_name, 'Update ', '') func_name
	FROM application_functions af
	LEFT JOIN application_functional_users afu
		ON af.function_id = afu.function_id
	LEFT JOIN application_users au
		ON afu.login_id = au.user_login_id
	LEFT JOIN application_security_role asr
		ON afu.role_id = asr.role_id
	LEFT JOIN application_role_user aru
		ON aru.role_id = asr.role_id
	WHERE (
			(
				au.user_login_id = dbo.FNADBUser()
				OR aru.user_login_id = dbo.FNADBUser()
				AND @app_admin_role_check = 0
				)
			OR @app_admin_role_check = 1
			)
		AND af.function_id IN (10131031, 10131032, 10131033)

END
