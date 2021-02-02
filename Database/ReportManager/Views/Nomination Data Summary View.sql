BEGIN TRY
		BEGIN TRAN
	
	declare @new_ds_alias varchar(10) = 'nmv'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'nmv' and name <> 'Nomination Data Summary View')
	begin
		select top 1 @new_ds_alias = 'nmv' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'nmv' + cast(s.n as varchar(5))
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
	           WHERE [name] = 'Nomination Data Summary View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'Nomination Data Summary View' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'Nomination Data Summary View' AS [name], @new_ds_alias AS ALIAS, '' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'0' AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = ''
	, [tsql] = CAST('' AS VARCHAR(MAX)) + '--DECLARE @_contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), ''DEBUG_MODE_ON'')

--SET CONTEXT_INFO @_contextinfo

SET NOCOUNT on

DECLARE 

	@_sub_id VARCHAR(MAX) = NULL,

	@_stra_id VARCHAR(MAX) = NULL,

	@_book_id VARCHAR(MAX) = null,

	@_subbook_id VARCHAR(MAX) = NULL,

	@_source_deal_header_ids NVARCHAR(1000)= NULL,--103969, --62976,--46363,--7264,  

	@_deal_id NVARCHAR(50)=NULL,  

	@_deal_detail_ids NVARCHAR(500),

	@_counterparty_ids NVARCHAR(500),

	@_deal_type_id NVARCHAR(20),

	@_physical_financial_flag NVARCHAR(20)=''p'',

	@_deal_status_id NVARCHAR(30),

	@_as_of_date  NVARCHAR(100)= NULL,--''2020-10-08'', -- ''2020-09-01'',--''2020-07-21'',

    @_term_start NVARCHAR(100)= NULL,--''2020-10-08'', -- ''2020-09-02'',--''2021-10-31'',--''2020-07-22'',

    @_term_END NVARCHAR(100)= NULL,

	@_location_ids NVARCHAR(500),

	@_shipper_code_ids1  NVARCHAR(500),

	@_shipper_code_ids2  NVARCHAR(500),

	@_system_timezone_id NVARCHAR(30) =null , --5,

	@_convert_timezone_id NVARCHAR(30)  = 14, --NULL,--14,--14, 

	@_position_hour_end NVARCHAR(1)=''n'',

	@_commodity_id NVARCHAR(20),

	@_external_id1 NVARCHAR(50)=NULL --94900871

IF OBJECT_ID(N''tempdb..#books'') IS NOT NULL

	DROP TABLE #books

IF OBJECT_ID(N''tempdb..#temp_deals'') IS NOT NULL

	DROP TABLE #temp_deals

IF OBJECT_ID(N''tempdb..#term_date'') IS NOT NULL

	DROP TABLE #term_date

IF OBJECT_ID(N''tempdb..#position_deal'') IS NOT NULL

	DROP TABLE #position_deal

IF OBJECT_ID(N''tempdb..#tmp_deal_position'') IS NOT NULL

	DROP TABLE #tmp_deal_position

IF OBJECT_ID(N''tempdb..#hour_pivot'') IS NOT NULL

	DROP TABLE #hour_pivot

IF OBJECT_ID(N''tempdb..#tmp_pos_detail'') IS NOT NULL

	DROP TABLE #tmp_pos_detail

IF OBJECT_ID(N''tempdb..#tmp_pos_detail_gas'') IS NOT NULL

	DROP TABLE #tmp_pos_detail_gas

IF OBJECT_ID(N''tempdb..#unpvt'') IS NOT NULL

	DROP TABLE #unpvt

IF OBJECT_ID(N''tempdb..#position_deal'') IS NOT NULL

	drop table #position_deal

SET @_sub_id = nullif(isnull(@_sub_id, nullif(''@sub_id'', replace(''@_sub_id'', ''@_'', ''@''))), ''null'')

SET @_stra_id = nullif(isnull(@_stra_id, nullif(''@stra_id'', replace(''@_stra_id'', ''@_'', ''@''))), ''null'')

SET @_book_id = nullif(isnull(@_book_id, nullif(''@book_id'', replace(''@_book_id'', ''@_'', ''@''))), ''null'')

SET @_subbook_id = nullif(isnull(@_subbook_id, nullif(''@subbook_id'', replace(''@_subbook_id'', ''@_'', ''@''))), ''null'')

SET @_source_deal_header_ids = nullif(isnull(@_source_deal_header_ids, nullif(''@source_deal_header_ids'', replace(''@_source_deal_header_ids'', ''@_'', ''@''))), ''null'')

SET @_deal_id = nullif(isnull(@_deal_id, nullif(''@deal_id'', replace(''@_deal_id'', ''@_'', ''@''))), ''null'')

SET @_deal_detail_ids = nullif(isnull(@_deal_detail_ids, nullif(''@deal_detail_ids'', replace(''@_deal_detail_ids'', ''@_'', ''@''))), ''null'')

SET @_counterparty_ids = nullif(isnull(@_counterparty_ids, nullif(''@counterparty_ids'', replace(''@_counterparty_ids'', ''@_'', ''@''))), ''null'')

SET @_deal_type_id = nullif(isnull(@_deal_type_id, nullif(''@deal_type_id'', replace(''@_deal_type_id'', ''@_'', ''@''))), ''null'')

SET @_physical_financial_flag = nullif(isnull(@_physical_financial_flag, nullif(''@physical_financial_flag'', replace(''@_physical_financial_flag'', ''@_'', ''@''))), ''null'')

SET @_deal_status_id = nullif(isnull(@_deal_status_id, nullif(''@deal_status_id'', replace(''@_deal_status_id'', ''@_'', ''@''))), ''null'')

SET @_as_of_date = nullif(isnull(@_as_of_date, nullif(''@as_of_date'', replace(''@_as_of_date'', ''@_'', ''@''))), ''null'')

SET @_term_end = nullif(isnull(@_term_end, nullif(''@term_end'', replace(''@_term_end'', ''@_'', ''@''))), ''null'')

SET @_term_start = nullif(isnull(@_term_start, nullif(''@term_start'', replace(''@_term_start'', ''@_'', ''@''))), ''null'')

SET @_location_ids = nullif(isnull(@_location_ids, nullif(''@location_ids'', replace(''@_location_ids'', ''@_'', ''@''))), ''null'')

SET @_shipper_code_ids2 = nullif(isnull(@_shipper_code_ids2, nullif(''@shipper_code_ids2'', replace(''@_shipper_code_ids2'', ''@_'', ''@''))), ''null'')

SET @_shipper_code_ids1 = nullif(isnull(@_shipper_code_ids1, nullif(''@shipper_code_ids1'', replace(''@_shipper_code_ids1'', ''@_'', ''@''))), ''null'')

SET @_system_timezone_id = nullif(isnull(@_system_timezone_id, nullif(''@system_timezone_id'', replace(''@_system_timezone_id'', ''@_'', ''@''))), ''null'')

SET @_convert_timezone_id = nullif(isnull(@_convert_timezone_id, nullif(''@convert_timezone_id'', replace(''@_convert_timezone_id'', ''@_'', ''@''))), ''null'')

SET @_position_hour_end = nullif(isnull(@_position_hour_end, nullif(''@position_hour_end'', replace(''@_position_hour_end'', ''@_'', ''@''))), ''null'')

SET @_commodity_id = nullif(isnull(@_commodity_id, nullif(''@commodity_id'', replace(''@_commodity_id'', ''@_'', ''@''))), ''null'')

SET @_external_id1 = nullif(isnull(@_external_id1, nullif(''@external_id1'', replace(''@_external_id1'', ''@_'', ''@''))), ''null'')

DECLARE @_Sql VARCHAR(MAX) ,@_Sql1 VARCHAR(MAX) ,@_Sql2 VARCHAR(MAX) 

DECLARE @_baseload_block_define_id VARCHAR(10),@_default_timezone_id int

CREATE TABLE  #temp_deals( 

	 source_deal_header_id INT		

	,source_deal_detail_id int		

	,shipper_code_id1 int

	,shipper_code_id2 int

	,term_start date

	,term_end date

	,curve_id int

	,location_id int,external_id  NVARCHAR(500) COLLATE DATABASE_DEFAULT

	,external_id2  NVARCHAR(100) COLLATE DATABASE_DEFAULT

)  

SELECT @_baseload_block_define_id = CAST(value_id AS VARCHAR(10)) FROM static_data_value WHERE [TYPE_ID] = 10018 AND code LIKE ''Base Load'' -- External Static Data

SELECT @_default_timezone_id=var_value  from dbo.adiha_default_codes_values (nolock) WHERE instance_no = 1 AND default_code_id = 36 AND seq_no = 1

SET @_as_of_date=isnull(@_as_of_date,''9999-01-01'')

SET @_system_timezone_id=isnull(@_system_timezone_id,@_default_timezone_id)

SET @_convert_timezone_id=isnull(@_convert_timezone_id,@_default_timezone_id)

IF @_baseload_block_define_id IS NULL 

	SET @_baseload_block_define_id = NULL

IF @_term_start IS NOT NULL AND @_term_END IS NULL              

	SET @_term_END = @_term_start              

IF @_term_start IS NULL AND @_term_END IS NOT NULL              

	SET @_term_start = @_term_END       	  

IF @_term_start IS NULL AND @_term_END IS NULL  

BEGIN            

	SET @_term_start = ''1900-01-01''   

	SET @_term_end = ''9999-01-01''     

END

CREATE TABLE #books ( 

	fas_book_id INT, source_system_book_id1 INT ,source_system_book_id2 INT

	,source_system_book_id3 INT,source_system_book_id4 INT,timezone_id INT

	, book_name NVARCHAR(150) COLLATE DATABASE_DEFAULT

	,strat_id INT,strategy NVARCHAR(100) COLLATE DATABASE_DEFAULT

	,sub_id INT,subsidiary NVARCHAR(150) COLLATE DATABASE_DEFAULT

	, sub_book_id int,

	sub_book NVARCHAR(150) COLLATE DATABASE_DEFAULT

	,counterparty_id int

 )   

SET @_Sql = 

''

	INSERT INTO  #books   

	SELECT distinct book.entity_id,ssbm.source_system_book_id1,ssbm.source_system_book_id2,ssbm.source_system_book_id3,ssbm.source_system_book_id4 fas_book_id

		,sub.timezone_id,book.entity_name [book],stra.entity_id [strat_id],stra.entity_name [strat]

		,subsi.entity_id [sub_id], subsi.entity_name [sub],ssbm.book_deal_type_map_id sub_book_id,

		 ssbm.logical_name sub_book,sub.counterparty_id

	FROM portfolio_hierarchy book (nolock) INNER JOIN   Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id

		INNER JOIN   Portfolio_hierarchy subsi (nolock) ON stra.parent_entity_id = subsi.entity_id 

		inner JOIN   source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id  

		inner join fas_subsidiaries sub on sub.fas_subsidiary_id=stra.parent_entity_id

	WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401)

	'' 

	+ISNULL('' AND stra.parent_entity_id IN ( '' + @_sub_id + '')''  ,'''')            

	+ISNULL('' AND stra.entity_id IN ('' + @_stra_id + '')''  ,'''')       

	+ISNULL('' AND book.entity_id IN ('' + @_book_id + '')''   ,'''')         

	+ISNULL('' AND ssbm.book_deal_type_map_id IN ('' + @_subbook_id + '')''  ,'''')  

exec spa_print @_Sql    

EXEC ( @_Sql)    

-- select * from #temp_deals

SELECT @_Sql ='' INSERT INTO #temp_deals(

						source_deal_header_id,					

						source_deal_detail_id,					

						shipper_code_id1,

						shipper_code_id2,

						term_start,

						term_end,

						curve_id,

						location_id,

						external_id

				)

				SELECT sdd.source_deal_header_id,					 

					   sdd.source_deal_detail_id,	

					   sdd.shipper_code1,

					   sdd.shipper_code2,

					   sdd.term_start,

					   sdd.term_end,

					   sdd.curve_id,

					   sdd.location_id,

					   scmd.external_id

''

			+ CASE WHEN ISNULL(@_source_deal_header_ids,'''')<>'''' THEN

					'' FROM dbo.SplitCommaSeperatedValues(''+@_source_deal_header_ids+'') f

					  INNER JOIN source_deal_header sdh ON f.item=sdh.source_deal_header_id

					  INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id

					''

				 WHEN  ISNULL(@_deal_id,'''')<>'''' THEN

					'' FROM source_deal_header sdh

					  INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id=sdd.source_deal_header_id 

					  WHERE deal_id =''''''+ @_deal_id+''''''''

			ELSE 

				''

				FROM source_deal_header sdh

				INNER JOIN #books ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1

					AND sdh.source_system_book_id2=ssbm.source_system_book_id2

					AND sdh.source_system_book_id3=ssbm.source_system_book_id3

					AND sdh.source_system_book_id4=ssbm.source_system_book_id4

				INNER JOIN source_deal_detail sdd on sdh.source_deal_header_id=sdd.source_deal_header_id

				''

			END + ''					

				LEFT JOIN shipper_code_mapping_detail scmd ON scmd.shipper_code_mapping_detail_id=sdd.shipper_code2

				WHERE sdd.shipper_code2 IS NOT NULL AND sdd.shipper_code1 IS NOT NULL 

					AND scmd.shipper_code is not null AND scmd.shipper_code1 IS NOT NULL AND scmd.external_id IS NOT NULL AND scmd.external_id<>''''''''

					''

				+ISNULL('' AND sdh.counterparty_id in ('' + @_counterparty_ids+'')'','''')

				+ISNULL('' AND sdh.source_deal_type_id=''+cast(@_deal_type_id as VARCHAR),'''')

				+ISNULL('' AND sdh.physical_financial_flag=''''''+@_physical_financial_flag+'''''''','''')

				+ISNULL('' AND sdh.deal_status=''+cast(@_deal_status_id as VARCHAR),'''')

				+ISNULL('' AND sdd.location_id in ('' + @_location_ids+'')'','''')

				+ISNULL('' AND sdd.shipper_code1 in ('' + @_shipper_code_ids1+'')'','''')

				+ISNULL('' AND sdd.shipper_code2 in ('' + @_shipper_code_ids2+'')'','''')

				+ISNULL('' AND sdd.source_deal_detail_id in ('' + @_deal_detail_ids+'')'','''')

				+ISNULL('' AND sdh.commodity_id='' + @_commodity_id,'''')

				+ISNULL('' AND scmd.external_id='' +@_external_id1,'''')

EXEC spa_print @_Sql

EXEC(@_Sql)

SELECT s.curve_id,s.location_id,s.term_start,s.Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag

	,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25

	,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2

	,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id,d.source_deal_detail_id ,granularity

INTO #position_deal  -- select * from #position_deal 

FROM report_hourly_position_deal s 

INNER JOIN #temp_deals d ON s.term_start between d.term_start and d.term_end and d.source_deal_header_id=s.source_deal_header_id

	AND s.location_id=isnull(d.location_id,-1) and s.curve_id=isnull(d.curve_id,-1)

WHERE --s.expiration_date>@_as_of_date AND s.term_start>@_as_of_date AND 

	s.term_start>=@_term_start 	AND s.term_start<=@_term_end 

	AND s.deal_date<=@_as_of_date

	 AND (@_commodity_id is null or s.commodity_id=@_commodity_id)

UNION ALL 

select s.curve_id,s.location_id,s.term_start,s.Period,s.deal_date,s.deal_volume_uom_id,s.physical_financial_flag

	,s.hr1,s.hr2,s.hr3,s.hr4,s.hr5,s.hr6,s.hr7,s.hr8,s.hr9,s.hr10,s.hr11,s.hr12,s.hr13,s.hr14,s.hr15,s.hr16,s.hr17,s.hr18,s.hr19,s.hr20,s.hr21,s.hr22,s.hr23,s.hr24,s.hr25,s.source_deal_header_id,s.commodity_id,s.counterparty_id,s.fas_book_id,s.source_system_book_id1,s.source_system_book_id2,s.source_system_book_id3,s.source_system_book_id4,s.expiration_date,''n'' AS is_fixedvolume,deal_status_id,d.source_deal_detail_id ,granularity

from report_hourly_position_profile s  

	inner join #temp_deals	d ON s.term_start between d.term_start and d.term_end and d.source_deal_header_id=s.source_deal_header_id

		and s.location_id=isnull(d.location_id,-1) and s.curve_id=isnull(d.curve_id,-1)

WHERE --s.expiration_date>@_as_of_date AND s.term_start>@_as_of_date AND

		s.term_start>=@_term_start AND s.term_start<=@_term_end AND s.deal_date<=@_as_of_date

		AND (@_commodity_id is null or s.commodity_id=@_commodity_id)

SELECT  vw.source_deal_header_id,max(isnull(spcd1.curve_name ,spcd.curve_name)) [Index],max(sml.location_name) [location],su.uom_name

	 ,isnull(spcd1.source_curve_def_id ,spcd.source_curve_def_id) curve_id,vw.location_id

	 ,CASE WHEN max(vw.physical_financial_flag) = ''f'' THEN ''Financial''  else ''Physical'' END [Physical/Financial]

	 ,vw.term_start [Term], cast(SUM(cast(vw.hr1 as numeric(16,8))) as numeric(38,20)) Hr1,

	 cast(SUM(cast(vw.hr2 as numeric(16,8))) as numeric(38,20)) Hr2,

	 cast(SUM(cast(vw.hr3 as numeric(16,8))) as numeric(38,20)) Hr3,

	 cast(SUM(cast(vw.hr4 as numeric(16,8))) as numeric(38,20)) Hr4,

	 cast(SUM(cast(vw.hr5 as numeric(16,8))) as numeric(38,20)) Hr5,

	 cast(SUM(cast(vw.hr6 as numeric(16,8))) as numeric(38,20)) Hr6,

	 cast(SUM(cast(vw.hr7 as numeric(16,8))) as numeric(38,20)) Hr7,

	 cast(SUM(cast(vw.hr8 as numeric(16,8))) as numeric(38,20)) Hr8,

	 cast(SUM(cast(vw.hr9 as numeric(16,8))) as numeric(38,20)) Hr9,

	 cast(SUM(cast(vw.hr10 as numeric(16,8))) as numeric(38,20)) Hr10,

	 cast(SUM(cast(vw.hr11 as numeric(16,8))) as numeric(38,20)) Hr11,

	 cast(SUM(cast(vw.hr12 as numeric(16,8))) as numeric(38,20)) Hr12,

	 cast(SUM(cast(vw.hr13 as numeric(16,8))) as numeric(38,20)) Hr13,

	 cast(SUM(cast(vw.hr14 as numeric(16,8))) as numeric(38,20)) Hr14,

	 cast(SUM(cast(vw.hr15 as numeric(16,8))) as numeric(38,20)) Hr15,

	 cast(SUM(cast(vw.hr16 as numeric(16,8))) as numeric(38,20)) Hr16,

	 cast(SUM(cast(vw.hr17 as numeric(16,8))) as numeric(38,20)) Hr17,

	 cast(SUM(cast(vw.hr18 as numeric(16,8))) as numeric(38,20)) Hr18,

	 cast(SUM(cast(vw.hr19 as numeric(16,8))) as numeric(38,20)) Hr19,

	 cast(SUM(cast(vw.hr20 as numeric(16,8))) as numeric(38,20)) Hr20,

	 cast(SUM(cast(vw.hr21 as numeric(16,8))) as numeric(38,20)) Hr21,

	 cast(SUM(cast(vw.hr22 as numeric(16,8))) as numeric(38,20)) Hr22,

	 cast(SUM(cast(vw.hr23 as numeric(16,8))) as numeric(38,20)) Hr23,

	 cast(SUM(cast(vw.hr24 as numeric(16,8))) as numeric(38,20)) Hr24,

	 cast(SUM(cast(vw.hr25 as numeric(16,8))) as numeric(38,20)) Hr25,

	 MAX(vw.commodity_id) commodity_id,su.source_uom_id

	  ,max(Coalesce(sdh.timezone_id, sml.time_zone, spcd.time_zone, ssbm.timezone_id,@_default_timezone_id)) timezone_id,

	  max(isnull(from_tz.apply_dst,''y'')) apply_dst,max(sdh.deal_id) deal_id,max(sdh.deal_date) deal_date,vw.Period,vw.source_deal_detail_id ,max(vw.granularity) granularity

INTO #hour_pivot 

FROM  #position_deal vw 

	INNER JOIN source_price_curve_def spcd (nolock) ON spcd.source_curve_def_id=vw.curve_id 

	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id=vw.source_deal_header_id

	INNER JOIN #books ssbm ON sdh.source_system_book_id1=ssbm.source_system_book_id1

		  AND  sdh.source_system_book_id2=ssbm.source_system_book_id2

		  AND  sdh.source_system_book_id3=ssbm.source_system_book_id3

		  AND  sdh.source_system_book_id4=ssbm.source_system_book_id4

	LEFT JOIN  source_price_curve_def spcd1 (nolock) ON  spcd1.source_curve_def_id=spcd.source_curve_def_id

	LEFT JOIN source_minor_location sml (nolock) ON sml.source_minor_location_id=vw.location_id

	LEFT JOIN source_uom su (nolock) on su.source_uom_id=ISNULL(spcd.display_uom_id,spcd.uom_id)   

	LEFT JOIN time_zones from_tz on from_tz.TIMEZONE_ID=Coalesce(sdh.timezone_id, sml.time_zone, spcd.time_zone, ssbm.timezone_id)

GROUP BY isnull(spcd1.source_curve_def_id ,spcd.source_curve_def_id),vw.source_deal_header_id

	,isnull(spcd1.source_curve_def_id ,spcd.source_curve_def_id) ,vw.location_id

	, vw.term_start,su.uom_name,su.source_uom_id,vw.Period,vw.source_deal_detail_id

	

SELECT s.source_deal_header_id,s.[physical/Financial],s.commodity_id,s.[Term],cast((s.hr25) AS NUMERIC(38,20)) dst_hr,

	CAST(s.hr1 AS NUMERIC(38,20)) [1],

	CAST(s.hr2 - CASE WHEN s.apply_dst=''y'' THEN  CASE WHEN hb.add_dst_hour=2 THEN isnull(s.hr25,0) ELSE 0 END ELSE 0 END  AS NUMERIC(38,20)) [2],

	CAST(s.hr3 - CASE WHEN s.apply_dst=''y'' THEN  CASE WHEN hb.add_dst_hour=3 THEN isnull(s.hr25,0) ELSE 0 END ELSE 0 END AS NUMERIC(38,20)) [3],

	CAST(s.hr4 AS NUMERIC(38,20)) [4],

	CAST(s.hr5 AS NUMERIC(38,20)) [5],

	CAST(s.hr6 AS NUMERIC(38,20)) [6],

	CAST(s.hr7 AS NUMERIC(38,20)) [7],

	CAST(s.hr8 AS NUMERIC(38,20)) [8],

	CAST(s.hr9 AS NUMERIC(38,20)) [9],

	CAST(s.hr10 AS NUMERIC(38,20)) [10],

	CAST(s.hr11 AS NUMERIC(38,20)) [11],

	CAST(s.hr12 AS NUMERIC(38,20)) [12],

	CAST(s.hr13 AS NUMERIC(38,20)) [13],

	CAST(s.hr14 AS NUMERIC(38,20)) [14],

	CAST(s.hr15 AS NUMERIC(38,20)) [15],

	CAST(s.hr16 AS NUMERIC(38,20)) [16],

	CAST(s.hr17 AS NUMERIC(38,20)) [17],

	CAST(s.hr18 AS NUMERIC(38,20)) [18],

	CAST(s.hr19 AS NUMERIC(38,20)) [19],

	CAST(s.hr20 AS NUMERIC(38,20)) [20],

	CAST(s.hr21 AS NUMERIC(38,20)) [21],

	CAST(s.hr22 AS NUMERIC(38,20)) [22],

	CAST(s.hr23 AS NUMERIC(38,20)) [23],

	CAST(s.hr24 AS NUMERIC(38,20)) [24],

	CAST(s.hr25 AS NUMERIC(38,20)) [25],hb.add_dst_hour,s.apply_dst,s.timezone_id,s.source_uom_id,

	s.uom_name,s.curve_id,s.location_id,s.[index],s.location,s.deal_id,s.deal_date,s.Period,s.source_deal_detail_id ,s.granularity

INTO #tmp_pos_detail 

FROM #hour_pivot s -- select * from #hour_pivot

	INNER JOIN source_price_curve_def spcd  on spcd.source_curve_def_id = s.curve_id 

	left join vwDealTimezone tz on tz.source_deal_header_id=s.source_deal_header_id

		and tz.curve_id=isnull(s.curve_id,-1) and tz.location_id=isnull(s.location_id,-1)

	INNER JOIN hour_block_term hb ON hb.term_date =s.[term] AND s.commodity_id<>-1 

		and hb.block_define_id = COALESCE(spcd.block_define_id,@_baseload_block_define_id) and  hb.block_type=12000

		AND hb.dst_group_value_id = tz.dst_group_value_id

		

SELECT s.source_deal_header_id,s.[physical/Financial],s.commodity_id,s.[Term],cast((s.hr25) AS NUMERIC(38,20)) dst_hr,

	CAST(s.hr19 AS NUMERIC(38,20)) [1],

	CAST(s.hr20- CASE WHEN s.apply_dst=''y'' THEN CASE WHEN hb.add_dst_hour=2 THEN isnull(s.hr25,0) ELSE 0 END ELSE 0 END  AS NUMERIC(38,20)) [2],

	CAST(s.hr21- CASE WHEN s.apply_dst=''y'' THEN CASE WHEN hb.add_dst_hour=3 THEN isnull(s.hr25,0) ELSE 0 END ELSE 0 END  AS NUMERIC(38,20)) [3],

	CAST(s.hr22 AS NUMERIC(38,20)) [4],

	CAST(s.hr23 AS NUMERIC(38,20)) [5],

	CAST(s.hr24 AS NUMERIC(38,20)) [6],

	CAST(s.hr1 AS NUMERIC(38,20)) [7],

	CAST(s.hr2 AS NUMERIC(38,20)) [8],

	CAST(s.hr3 AS NUMERIC(38,20)) [9],

	CAST(s.hr4 AS NUMERIC(38,20)) [10],

	CAST(s.hr5 AS NUMERIC(38,20)) [11],

	CAST(s.hr6 AS NUMERIC(38,20)) [12],

	CAST(s.hr7 AS NUMERIC(38,20)) [13],

	CAST(s.hr8 AS NUMERIC(38,20)) [14],

	CAST(s.hr9 AS NUMERIC(38,20)) [15],

	CAST(s.hr10 AS NUMERIC(38,20)) [16],

	CAST(s.hr11 AS NUMERIC(38,20)) [17],

	CAST(s.hr12 AS NUMERIC(38,20)) [18],

	CAST(s.hr13 AS NUMERIC(38,20)) [19],

	CAST(s.hr14 AS NUMERIC(38,20)) [20],

	CAST(s.hr15 AS NUMERIC(38,20)) [21],

	CAST(s.hr16 AS NUMERIC(38,20)) [22],

	CAST(s.hr17 AS NUMERIC(38,20)) [23],

	CAST(s.hr18 AS NUMERIC(38,20)) [24],

	CAST(s.hr25 AS NUMERIC(38,20)) [25],(hb.add_dst_hour) add_dst_hour,s.apply_dst,s.timezone_id,s.source_uom_id,

	s.uom_name,s.curve_id,s.location_id,s.[index],s.location,s.deal_id,s.deal_date,s.Period,s.source_deal_detail_id ,s.granularity

INTO #tmp_pos_detail_gas 

FROM #hour_pivot s  

inner JOIN source_price_curve_def spcd (nolock) on spcd.source_curve_def_id = s.curve_id

left join vwDealTimezone tz on tz.source_deal_header_id=s.source_deal_header_id

	and tz.curve_id=isnull(s.curve_id,-1) and tz.location_id=isnull(s.location_id,-1)

inner JOIN hour_block_term hb ON s.commodity_id=-1  and hb.term_date -1=s.[term] 

	AND hb.block_define_id =COALESCE(spcd.block_define_id,@_baseload_block_define_id) and  hb.block_type=12000 

	AND hb.dst_group_value_id = tz.dst_group_value_id

select *,CASE WHEN commodity_id=-1  AND  ([hours]<7 OR [hours]=25) THEN dateadd(DAY,1,[term]) ELSE [term] END [term_date]

into #unpvt 

from (

	SELECT * FROM #tmp_pos_detail

	union all 

	SELECT * FROM #tmp_pos_detail_gas

) p

UNPIVOT

	(Volume for Hours IN

		([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24],[25])

	) AS unpvt

WHERE NOT ([hours]=abs(isnull(add_dst_hour,0)) AND add_dst_hour<0 and apply_dst=''y'')  ;

CREATE INDEX index_unpvt1 ON #unpvt ([term_date],[hours],[Period]);

SELECT unp. source_deal_header_id,unp.[term_date],CASE WHEN mv.[date] IS NOT NULL AND unp.apply_dst=''y'' THEN mv.Hour ELSE unp.[Hours] END hr,

	CASE WHEN unp.[Hours] = 25 THEN 0 ELSE 	

		CASE WHEN CAST(convert(NVARCHAR(10),unp.[term_date],120)+'' ''+RIGHT(''00''+CAST(CASE WHEN mv.[date] IS NOT NULL THEN mv.Hour ELSE unp.[Hours] END -1 AS NVARCHAR),2)+'':00:000'' AS DATETIME) BETWEEN CAST(convert(NVARCHAR(10),mv2.[date],120)+'' ''+CAST(mv2.Hour-1 AS NVARCHAR)+'':00:00'' AS DATETIME) 

			AND CAST(convert(NVARCHAR(10),mv3.[date],120)+'' ''+CAST(mv3.Hour-1 AS NVARCHAR)+'':00:00'' AS DATETIME)

			 THEN 1 ELSE 0 END 

	END AS DST,	

	unp.Volume [Position],

	unp.timezone_id ,

	unp.uom_name,

	unp.[Physical/Financial],

	unp.location_id,

	unp.deal_id,

	unp.deal_date,

	unp.[term],

	unp.apply_dst,

	unp.Period,

	unp.source_deal_detail_id ,

	unp.granularity

INTO #tmp_deal_position -- select * from #tmp_deal_position

FROM	#unpvt unp

	left join vwDealTimezone tz on tz.source_deal_header_id=unp.source_deal_header_id

		and tz.curve_id=isnull(unp.curve_id,-1) and tz.location_id=isnull(unp.location_id,-1)

	LEFT JOIN mv90_DST mv (nolock) ON (unp.[term_date])=(mv.[date])

		  AND mv.insert_delete=''i''

		  AND unp.[Hours]=25

		  AND mv.dst_group_value_id = tz.dst_group_value_id

	LEFT JOIN mv90_DST mv1 (nolock) ON (unp.[term_date])=(mv1.[date])

		AND mv1.insert_delete=''d''

		AND mv1.Hour=unp.[Hours]	

		AND mv1.dst_group_value_id = tz.dst_group_value_id	

	LEFT JOIN mv90_DST mv2 (nolock) ON YEAR(unp.[term_date])=(mv2.[YEAR])

		AND mv2.insert_delete=''d''

		AND mv2.dst_group_value_id = tz.dst_group_value_id

	LEFT JOIN mv90_DST mv3 (nolock) ON YEAR(unp.[term_date])=(mv3.[YEAR])

		AND mv3.insert_delete=''i''

		AND mv3.dst_group_value_id = tz.dst_group_value_id

	WHERE  (((unp.[Hours]=25 AND mv.[date] IS NOT NULL AND unp.apply_dst=''y'') OR (unp.[Hours]<>25)) AND ((mv1.[date] IS NULL AND unp.apply_dst=''y'') OR (unp.apply_dst = ''n''))) 

--select * from #unpvt

SET @_Sql = ''

	SELECT actual_term_to_start, actual_term_to_end, SUM(position) position, MAX(position_uom)position_uom, 

	external_id

	 INTO #final_table

	 FROM

(		

SELECT 

	dateadd(minute,tdp.Period,to_dt.to_dt) actual_term_to_start

	,dateadd(minute,case when tdp.granularity=982 then 60  else 15 end,dateadd(minute,tdp.Period,to_dt.to_dt)) actual_term_to_end

	,tdp.position position

	,tdp.uom_name position_uom

	,ISNULL(scmdh.external_id, sdd.external_id ) external_id
''

SET @_Sql2 = ''

FROM #tmp_deal_position tdp 

	LEFT JOIN time_zones from_tz on from_tz.TIMEZONE_ID=tdp.timezone_id

	LEFT JOIN time_zones to_tz on to_tz.TIMEZONE_ID= '' + CAST(@_convert_timezone_id AS NVARCHAR(10)) + '' 

	OUTER APPLY 

	(

		SELECT 

			max(case when insert_delete=''''d'''' THEN  DATEADD(hour,[hour]-1,[date]) ELSE NULL END)  from_dst,

			max(case when insert_delete=''''i'''' THEN  DATEADD(hour,[hour]-1,[date]) ELSE NULL END)  to_dst

		from mv90_DST WHERE  [YEAR]=year(tdp.term_date) AND dst_group_value_id = COALESCE(from_tz.dst_group_value_id,to_tz.dst_group_value_id)

	) dst

	CROSS APPLY

	(

		SELECT	convert(NVARCHAR(10),term_date,120) +'''' '''' +right(''''0''''+cast(hr-1  AS NVARCHAR),2)+'''':00:00'''' org_term_from

	) org_term_from

	CROSS APPLY

	(

		SELECT	(to_tz.offset_hr-from_tz.offset_hr)

		  +CASE WHEN from_tz.APPLY_dst=''''y'''' THEN 

			CASE WHEN  cast(convert(NVARCHAR(10),term_date,120) +'''' '''' +right(''''0''''+cast(hr-1 AS NVARCHAR),2)+'''':00:00'''' AS DATETIME) BETWEEN from_dst AND to_dst AND dst=1 THEN --dst start

				-1   --CASE WHEN to_tz.offset_hr-from_tz.offset_hr<0 THEN -1 ELSE 1 END

			ELSE 0 END 

		  ELSE 0 END offset

	) offset

	CROSS APPLY

	(

		select DATEADD(hour,offset.offset,org_term_from.org_term_from) to_dt

	) to_dt --actual date

	CROSS APPLY

	(

		select DATEADD(hour,

		  CASE WHEN to_tz.APPLY_dst=''''y'''' THEN 

				CASE WHEN to_dt.to_dt BETWEEN dateadd(hour,''+case when isnull(@_position_hour_end,''n'')=''y'' then ''-1'' ELSE ''0'' END +'',from_dst)  AND dateadd(hour,''+case when isnull(@_position_hour_end,''n'')=''y'' then ''-2'' ELSE ''-1'' END +'' ,to_dst) THEN 1 ELSE 0 end

		  ELSE 0 END  , to_dt.to_dt) term_to

	) term_to  --- dst applied for to term

INNER JOIN #temp_deals sdd on sdd.source_deal_detail_id = tdp.source_deal_detail_id

OUTER APPLY (

		SELECT TOP 1 shipper_code1, shipper_code2, dds.effective_date

		FROM deal_detail_shipper_codes_history dds

		WHERE dds.source_deal_detail_id =  sdd.source_deal_detail_id

			AND cast(dds.effective_date as date)  >= tdp.[term]

		ORDER BY dds.effective_date ASC

	) h

LEFT JOIN shipper_code_mapping_detail scmdh on scmdh.shipper_code_mapping_detail_id=h.shipper_code2

) a

GROUP BY actual_term_to_start, actual_term_to_end,external_id

SELECT actual_term_to_start, actual_term_to_end, IIF('' + @_commodity_id + '' = 123 , Position * 4, Position) Position, position_uom [Position UOM], 

	external_id [External ID/Time Series ID],'''''' + @_as_of_date + '''''' as_of_date , '''''''' sub_id, '''''''' strat_id, '''''''' book_id, '''''''' subbook_id,	

	'''''''' [source_deal_header_ids], '''''''' [deal_id], NULL commodity_id,  NULL [deal_status_id],

	NULL [counterparty_ids], NULL [location_ids], NULL deal_type_id, NULL [convert_timezone_id],

	'''''''' [term_start], '''''''' [term_end] , NULL external_id1

--[__batch_report__]

FROM #final_table

ORDER BY actual_term_to_start,actual_term_to_end

''

exec spa_print @_Sql

exec spa_print @_Sql2

EXEC (@_Sql + @_Sql2)', report_id = @report_id_data_source_dest,
	system_defined = '0'
	,category = '106500' 
	WHERE [name] = 'Nomination Data Summary View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'actual_term_to_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Actual Term To End'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'actual_term_to_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'actual_term_to_end' AS [name], 'Actual Term To End' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'actual_term_to_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Actual Term To Start'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'actual_term_to_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'actual_term_to_start' AS [name], 'Actual Term To Start' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'External ID/Time Series ID'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'External Id/Time Series Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'External ID/Time Series ID'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'External ID/Time Series ID' AS [name], 'External Id/Time Series Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'Position'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Position'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'Position'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Position' AS [name], 'Position' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'Position UOM'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Position Uom'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'Position UOM'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'Position UOM' AS [name], 'Position Uom' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Book ID'
			   , reqd_param = NULL, widget_id = 5, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'Book ID' AS ALIAS, NULL AS reqd_param, 5 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'commodity_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Commodity Id'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 4, param_data_source = 'select source_commodity_id,commodity_name from source_commodity order by commodity_name', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'commodity_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'commodity_id' AS [name], 'Commodity Id' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'select source_commodity_id,commodity_name from source_commodity order by commodity_name' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'convert_timezone_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Convert Timezone Id'
			   , reqd_param = NULL, widget_id = 2, datatype_id = 4, param_data_source = 'select TIMEZONE_ID,timezone_name from time_zones order by 1 asc', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'convert_timezone_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'convert_timezone_id' AS [name], 'Convert Timezone Id' AS ALIAS, NULL AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'select TIMEZONE_ID,timezone_name from time_zones order by 1 asc' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'counterparty_ids'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Ids'
			   , reqd_param = NULL, widget_id = 7, datatype_id = 4, param_data_source = 'browse_counterparty', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'counterparty_ids'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_ids' AS [name], 'Counterparty Ids' AS ALIAS, NULL AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_counterparty' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'deal_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Reference ID'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'deal_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_id' AS [name], 'Reference ID' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'deal_status_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Status Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'deal_status_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_status_id' AS [name], 'Deal Status Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'deal_type_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Type Id'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'deal_type_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_type_id' AS [name], 'Deal Type Id' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'location_ids'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Location Ids'
			   , reqd_param = NULL, widget_id = 7, datatype_id = 4, param_data_source = 'browse_location', param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'location_ids'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location_ids' AS [name], 'Location Ids' AS ALIAS, NULL AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_location' AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'source_deal_header_ids'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Source Deal Header Ids'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 0, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'source_deal_header_ids'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'source_deal_header_ids' AS [name], 'Source Deal Header Ids' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'strat_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Strat Id'
			   , reqd_param = NULL, widget_id = 4, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'strat_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'strat_id' AS [name], 'Strat Id' AS ALIAS, NULL AS reqd_param, 4 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subsidiary ID'
			   , reqd_param = NULL, widget_id = 3, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'Subsidiary ID' AS ALIAS, NULL AS reqd_param, 3 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'subbook_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Subbook Id'
			   , reqd_param = NULL, widget_id = 8, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'subbook_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'subbook_id' AS [name], 'Subbook Id' AS ALIAS, NULL AS reqd_param, 8 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term End'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'Term End' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Term Start'
			   , reqd_param = NULL, widget_id = 6, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'Term Start' AS ALIAS, NULL AS reqd_param, 6 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Nomination Data Summary View'
	            AND dsc.name =  'external_id1'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'External Id1'
			   , reqd_param = NULL, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = NULL, tooltip = NULL, column_template = 2, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Nomination Data Summary View'
			AND dsc.name =  'external_id1'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'external_id1' AS [name], 'External Id1' AS ALIAS, NULL AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, NULL AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Nomination Data Summary View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	
	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Nomination Data Summary View'
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
