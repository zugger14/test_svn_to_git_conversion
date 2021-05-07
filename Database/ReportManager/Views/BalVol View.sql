BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'BalVol'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'BalVol' and name <> 'BalVol')
	begin
		select top 1 @new_ds_alias = 'BalVol' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'BalVol' + cast(s.n as varchar(5))
		where ds.data_source_id is null
			and s.n < 10

		--RAISERROR ('Datasource alias already exists on system.', 16, 1);
	end

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL
	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'BalVol'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'BalVol' AND '106501' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'BalVol' AS [name], @new_ds_alias AS ALIAS, '' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'0' AS [system_defined]
			,'106501' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = ''
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE @_source_deal_header_id VARCHAR(100) 

DECLARE @_st VARCHAR(MAX)

DECLARE @_template_id INT

DECLARE @_subbook_id INT=NULL

Declare @_sql varchar(max) 

----System Paramer:

	,@_calc_type varchar(10) --= ''m'' --''s''

	,@_as_of_date varchar(10)

	,@_fcpt varchar(250)

 


SET @_fcpt = nullif(isnull(@_fcpt, nullif(''@farrms_calc_process_table'', replace(''@_fcpt'', ''@_'', ''@''))), ''null'')

SET @_calc_type = nullif(isnull(@_calc_type, nullif(''@calc_type'', replace(''@_calc_type'', ''@_'', ''@''))), ''null'')

SET @_as_of_date = nullif(isnull(@_as_of_date, nullif(''@as_of_date'', replace(''@_as_of_date'', ''@_'', ''@''))), ''null'')

SET @_source_deal_header_id = nullif(isnull(@_source_deal_header_id, nullif(''@source_deal_header_id'', replace(''@_source_deal_header_id'', ''@_'', ''@''))), ''null'')

 

IF OBJECT_ID(@_fcpt) is null 

BEGIN 

	SELECT 1 source_deal_header_id INTO #a 

	From seq WHERE n=1

END 

ELSE 

BEGIN

	SELECT @_template_id = template_id FROM source_deal_header_template WHERE template_name = ''Transportation NG''

	IF OBJECT_ID(''tempdb..#location_id'') IS NOT NULL DROP TABLE #location_id 


	CREATE TABLE #location_id (location_id int, location_name varchar(1000) COLLATE DATABASE_DEFAULT, granularity INT, term_start datetime, term_end datetime)


	set @_st = ''INSERT INTO #location_id  

				SELECT  sdd.location_id, sml.location_name , s.granularity, MIN(s.prod_date) term_start, MAX(s.prod_date) term_end

				FROM ''+ @_fcpt +'' s 

				INNER JOIN source_deal_detail sdd on sdd.source_deal_detail_id = s.source_deal_detail_id

				INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id

				GROUP BY  sdd.location_id, sml.location_name , s.granularity

	''

	EXEC spa_print @_st

	EXEC(@_st)


	IF OBJECT_ID(''tempdb..#temp_pen_tran_buy_deals'') IS NOT NULL

		DROP TABLE #temp_pen_tran_buy_deals


	CREATE TABLE #temp_pen_tran_buy_deals (location_id	INT

											, transport_deal_id	 INT

											, buy_deal_id	INT

											, location_name	VARCHAR(1000)

											, term_start DATETIME	

											, term_end	 DATETIME	

											, leg	 INT

											, buy_sell_flag	 CHAR(1)

											, granularity	 INT 

											, deal_volume NUMERIC(38, 18))


	SET @_st = ''INSERT INTO #temp_pen_tran_buy_deals

				SELECT DISTINCT sml.location_id,

					sdh.source_deal_header_id transport_deal_id

					--od.source_deal_header_id buy_deal_id

					, NULL buy_deal_id

					, sml.location_name

					,sdd.term_start,sdd.term_end

					, sdd.leg

					, buy_sell_flag   

					, granularity

					, sdd.deal_volume

				FROM source_deal_header sdh

				INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id 

				INNER JOIN #location_id sml on sml.location_id = sdd.location_id 

				INNER JOIN optimizer_detail od ON od.transport_deal_id = sdh.source_deal_header_id  

				INNER JOIN source_system_book_map ssbm on ssbm.source_system_book_id1=sdh.source_system_book_id1

					AND ssbm.source_system_book_id2 = sdh.source_system_book_id2

					AND ssbm.source_system_book_id3 = sdh.source_system_book_id3

					AND ssbm.source_system_book_id4 = sdh.source_system_book_id4 ''

					+ CASE WHEN @_subbook_id  IS NOT NULL THEN '' AND book_deal_type_map_id = ISNULL('' + CAST(@_subbook_id AS VARCHAR(1000)) + '', book_deal_type_map_id)'' ELSE '''' END 

					+ ''  INNER JOIN source_deal_type sdt ON sdh.source_deal_type_id = sdt.source_deal_type_id

				WHERE  sdt.deal_type_id = ''''Transportation''''

					AND sdd.term_start >= sml.term_start

					AND sdd.term_end <= sml.term_end ''


	EXEC spa_print @_st

	EXEC(@_st)

  


	IF OBJECT_ID(''tempdb..#final_trans_deals_coll'') IS NOT NULL

	DROP TABLE #final_trans_deals_coll


	SELECT location_id	

		, transport_deal_id	

		, buy_deal_id	

		, location_name	

		, term_start	

		, term_end	 

		, granularity 

	INTO #final_trans_deals_coll

	FROM (

		SELECT DISTINCT location_id	

		, transport_deal_id	

		, buy_deal_id	

		, location_name	

		, term_start	

		, term_end	

		, granularity

		FROM #temp_pen_tran_buy_deals 

		INTERSECT

		SELECT DISTINCT t.location_id	

		, t.transport_deal_id	

		, t.buy_deal_id	

		, t.location_name	

		, t.term_start	

		, t.term_end	

		, t.granularity

		--, sml.location_id

		FROM #temp_pen_tran_buy_deals t

		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = t.transport_deal_id

			--AND sdd.leg = CASE WHEN t.leg = 1 THEN 2 ELSE 1 END

		INNER JOIN source_minor_location sml ON sml.Location_Name = CASE WHEN t.location_name = ''NCGL'' THEN ''NCGH'' ELSE ''GPLH'' END 

			AND sdd.location_id = sml.source_minor_location_id

	) z 


	IF OBJECT_ID(''tempdb..#position'') IS NOT NULL

	DROP TABLE #position


	SELECT t1.location_id,rhpd.term_start

	--,  rhpd.hr1

	--,  rhpd.curve_id , sdd01.curve_id

		, SUM(rhpd.hr1) hr1 

		, SUM(rhpd.hr2) hr2 

		, SUM(rhpd.hr3) hr3 

		, SUM(rhpd.hr4) hr4 

		, SUM(rhpd.hr5) hr5 

		, SUM(rhpd.hr6) hr6 

		, SUM(rhpd.hr7) hr7 

		, SUM(rhpd.hr8) hr8 

		, SUM(rhpd.hr9 ) hr9 

		, SUM(rhpd.hr10) hr10

		, SUM(rhpd.hr11) hr11

		, SUM(rhpd.hr12) hr12

		, SUM(rhpd.hr13) hr13

		, SUM(rhpd.hr14) hr14

		, SUM(rhpd.hr15) hr15

		, SUM(rhpd.hr16) hr16

		, SUM(rhpd.hr17) hr17

		, SUM(rhpd.hr18) hr18

		, SUM(rhpd.hr19) hr19

		, SUM(rhpd.hr20) hr20

		, SUM(rhpd.hr21) hr21

		, SUM(rhpd.hr22) hr22

		, SUM(rhpd.hr23) hr23

		, SUM(rhpd.hr24) hr24

	INTO #position

	FROM #final_trans_deals_coll t1  

	INNER JOIN source_deal_detail sdd01 ON sdd01.source_deal_header_id = t1.transport_deal_id

	INNER JOIN report_hourly_position_deal rhpd on rhpd.source_deal_header_id = t1.transport_deal_id

		AND rhpd.location_id = t1.location_id 

		AND rhpd.term_start = t1.term_start 

		AND rhpd.curve_id = sdd01.curve_id

		AND rhpd.term_start BETWEEN sdd01.term_start AND sdd01.term_end

	GROUP BY t1.location_id,rhpd.term_start;

	--select * from #position

	----select * from report_hourly_position_deal where source_deal_header_id IN ( 7402, 7403)

	--return 

	IF OBJECT_ID(''tempdb..#position_unpvt'') IS NOT NULL

	DROP TABLE #position_unpvt

	SELECT unpvt.location_id,unpvt.term_start,unpvt.[hour],unpvt.[value]

	INTO #position_unpvt

	FROM

	(

	SELECT location_id,term_start,hr1 [1],hr2 [2],hr3 [3],hr4 [4],hr5 [5],hr6 [6]

	,hr7 [7],hr8 [8],hr9 [9],hr10 [10],hr11 [11],hr12 [12],hr13 [13],hr14 [14]

	,hr15 [15],hr16 [16],hr17 [17],hr18 [18],hr19 [19],hr20 [20],hr21 [21],hr22 [22],hr23 [23],hr24 [24]	

	FROM #position 

	) P

	UNPIVOT (value for hour IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13]

	,[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24])

	) as unpvt;



	--select * from #position 

	--return 


	IF OBJECT_ID(''tempdb..#check_positive_negetive'')  IS NOT NULL

		DROP TABLE #check_positive_negetive


	SELECT location_id

		, term_start

		, SUM(value) [value]

	INTO #check_positive_negetive

	FROM #position_unpvt 

	GROUP BY term_start, location_id

	HAVING SUM(value) <= 0

 

	UPDATE pu 

	SET pu.value = 0 

	FROM #check_positive_negetive cpn 

	INNER JOIN #position_unpvt  pu ON pu.term_start = cpn.term_start

		AND pu.location_id = cpn.location_id


	SET @_sql = ''select p.func_rowid,  u.*

				INTO #func_output_value

				from #position_unpvt u 

				INNER JOIN '' + @_fcpt + '' p ON u.term_start = p.prod_date

					and p.Hour = u.hour


				''


	-- Final Evaluation in process table

	set @_sql=@_sql+''

		update p set temp_eval_value=CAST(fov.value AS NUMERIC(38, 18))

		FROM ''+ @_fcpt+'' p

			inner join #func_output_value fov on fov.func_rowid=p.func_rowid 

	''	

	exec spa_print @_sql

	exec(@_sql)

END	

--Select user input parameters only

	select @_source_deal_header_id source_deal_header_id

--[__batch_report__]

From seq WHERE n=1

 

 ', report_id = @report_id_data_source_dest,
	system_defined = '0'
	,category = '106501' 
	WHERE [name] = 'BalVol'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'BalVol'
	            AND dsc.name =  'source_deal_header_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'BalVol'
			AND dsc.name =  'source_deal_header_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_id' AS [name], 'Deal ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'BalVol'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'BalVol'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	