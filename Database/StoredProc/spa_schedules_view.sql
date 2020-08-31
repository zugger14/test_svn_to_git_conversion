IF OBJECT_ID(N'[dbo].[spa_schedules_view]', N'P') IS NOT NULL

/****** Object:  StoredProcedure [dbo].[spa_schedules_view]    Script Date: 10/20/2014 9:28:44 AM ******/
DROP PROCEDURE [dbo].[spa_schedules_view]
GO

/****** Object:  StoredProcedure [dbo].[spa_schedules_view]    Script Date: 10/20/2014 9:28:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/**
	Generic operations for View Nomination Schedules 
	Parameters
	@flag					: 'b' load schedules grid data on 'View Nomination Schedules' page.
							  'u' update schedule information of deal
							  'e'
							  'v'
							  'p' update delivery rank of schedule deal
							  'q' store grid data on process table
							  'c' save schedule values
							  'f'
							  'd' delete schedule deal
	@location				: Location IDs list
	@location_type			: Location Type IDs list
	@flow_date_from			: Flow Date From
	@flow_date_to			: Flow Date To
	@priority_id			: Priority ID
	@source_deal_header_id	: System Deal ID
	@scheduled_volume		: Scheduled Volume
	@delivery_volume		: Delivery Volume
	@rec_priority_id		: Receipt Priority ID
	@del_priority_id		: Delivery Priority ID
	@filter_pipeline		: Counterparty ID
	@filter_contract		: Contract ID
	@schedule_del_vol		: Scheduled Delivery Volume
	@schedule_rec_vol		: Scheduled Receipt Volume
	@actual_rec_vol			: Actual Delivery Volume
	@actual_del_vol			: Actual Receipt Volume
	@process_id				: Process ID
	@path_id				: Path IDs list
	@xml_data				: Nomination Grid data in XML format
	@deal_ids				: Deal IDs list
	@call_from				: Call From flag
	@transaction_type		: Transaction type
								'b' Buy/Sell only
								't' Transportation only
								'a' All

*/
CREATE PROCEDURE [dbo].[spa_schedules_view]
	@flag CHAR(1),
	@location VARCHAR(1000) = NULL,
	@location_type VARCHAR(1000) = NULL,
	@flow_date_from DATETIME = NULL,
	@flow_date_to DATETIME = NULL,
	@priority_id INT = NULL,
	@source_deal_header_id VARCHAR(MAX) = NULL,
	@scheduled_volume VARCHAR(100) = NULL,
	@delivery_volume VARCHAR(100) = NULL,
	@rec_priority_id INT = NULL,
	@del_priority_id INT = NULL,
	@filter_pipeline INT = NULL,
	@filter_contract INT = NULL,
	@schedule_del_vol VARCHAR(100) = NULL,
	@schedule_rec_vol VARCHAR(100) = NULL,
	@actual_rec_vol VARCHAR(100) = NULL,
	@actual_del_vol VARCHAR(100) = NULL,
	@process_id VARCHAR(200) = NULL,
	@path_id VARCHAR(1000) = NULL,
	@xml_data VARCHAR(MAX) = NULL,
	@deal_ids VARCHAR(1024) = NULL,
	@call_from VARCHAR(50) = NULL,
	@transaction_type CHAR(1) = 't'
AS
/*

declare 
@flag CHAR(1),
	@location VARCHAR(1000) = NULL,
	@location_type VARCHAR(1000) = NULL,
	@flow_date_from DATETIME = NULL,
	@flow_date_to DATETIME = NULL,
	@priority_id INT = NULL,
	@source_deal_header_id VARCHAR(MAX) = NULL,
	@scheduled_volume VARCHAR(100) = NULL,
	@delivery_volume VARCHAR(100) = NULL,
	@rec_priority_id INT = NULL,
	@del_priority_id INT = NULL,
	@filter_pipeline INT = NULL,
	@filter_contract INT = NULL,
	@schedule_del_vol VARCHAR(100) = NULL,
	@schedule_rec_vol VARCHAR(100) = NULL,
	@actual_rec_vol VARCHAR(100) = NULL,
	@actual_del_vol VARCHAR(100) = NULL,
	@process_id VARCHAR(200) = NULL,
	@path_id VARCHAR(1000) = NULL,
	@xml_data VARCHAR(MAX) = NULL,
	@call_from varchar(50) = NULL,
	@transaction_type CHAR(1) = 'a'

--	-----  downsteam (sell)
--	select  @flag='c',@xml_data='<GridXML><GridRow deal_id="35409" term_start="2018-01-01" nom_rec_vol="" nom_del_vol="2000" schedule_rec_vol="" schedule_del_vol="" actual_rec_vol="" actual_del_vol="" deal_type="3"></GridRow></GridXML>'

--------	 transportation
--	select   @flag='c',@xml_data='<GridXML><GridRow deal_id="35417" term_start="2018-01-01" nom_rec_vol="10000" nom_del_vol="" schedule_rec_vol="" schedule_del_vol="" actual_rec_vol="" actual_del_vol="" deal_type="1"></GridRow><GridRow deal_id="39770" term_start="2018-01-01" nom_rec_vol="12000" nom_del_vol="12000" schedule_rec_vol="" schedule_del_vol="" actual_rec_vol="" actual_del_vol="" deal_type="2"></GridRow></GridXML>'



--- view
--select	@flag='b',@flow_date_from='2018-01-01',@flow_date_to='2018-01-01',@priority_id='',@location_type='18,27',@location='6784,6789',@filter_pipeline='',@filter_contract='',@rec_priority_id='',@del_priority_id='',@process_id='qwwwwww',@path_id='4276'



--select  @flag='c',@xml_data='<GridXML><GridRow deal_id="40801" term_start="2017-05-25" nom_rec_vol="10000" nom_del_vol="9978" schedule_rec_vol="" schedule_del_vol="" actual_rec_vol="" actual_del_vol="" deal_type="2"></GridRow><GridRow deal_id="40802" term_start="2017-05-25" nom_rec_vol="9978" nom_del_vol="9978" schedule_rec_vol="" schedule_del_vol="" actual_rec_vol="" actual_del_vol="" deal_type="2"></GridRow><GridRow deal_id="19278" term_start="2017-05-25" nom_rec_vol="" nom_del_vol="70000" schedule_rec_vol="" schedule_del_vol="" actual_rec_vol="" actual_del_vol="" deal_type="3"></GridRow></GridXML>'


--select @flag='c',@xml_data='<GridXML><GridRow deal_id="46979" term_start="2017-05-24" nom_rec_vol="25000" nom_del_vol="24895" schedule_rec_vol="" schedule_del_vol="" actual_rec_vol="" actual_del_vol="" deal_type="2"></GridRow><GridRow deal_id="46980" term_start="2017-05-24" nom_rec_vol="4895" nom_del_vol="4797" schedule_rec_vol="" schedule_del_vol="" actual_rec_vol="" actual_del_vol="" deal_type="2"></GridRow><GridRow deal_id="40852" term_start="2017-05-24" nom_rec_vol="" nom_del_vol="10000" schedule_rec_vol="" schedule_del_vol="" actual_rec_vol="" actual_del_vol="" deal_type="3"></GridRow><GridRow deal_id="46979" term_start="2017-05-24" nom_rec_vol="25000" nom_del_vol="24895" schedule_rec_vol="" schedule_del_vol="" actual_rec_vol="" actual_del_vol="" deal_type="2"></GridRow><GridRow deal_id="46981" term_start="2017-05-24" nom_rec_vol="20000" nom_del_vol="19862" schedule_rec_vol="" schedule_del_vol="" actual_rec_vol="" actual_del_vol="" deal_type="2"></GridRow><GridRow deal_id="19264" term_start="2017-05-24" nom_rec_vol="" nom_del_vol="15000" schedule_rec_vol="" schedule_del_vol="" actual_rec_vol="" actual_del_vol="" deal_type="3"></GridRow></GridXML>'




--select @flag='c',@xml_data='<GridXML><GridRow deal_id="19298" term_start="2017-05-24" nom_rec_vol="518230" nom_del_vol="" schedule_rec_vol="50000" schedule_del_vol="" actual_rec_vol="" actual_del_vol="" deal_type="1" leg="1"></GridRow></GridXML>'

select @flag='b', @flow_date_from='2021-05-01'
,@flow_date_to='2021-05-01'
,@location_type='4,-10,-11,3'
,@location='12460,12511,12512,12513'
,@process_id='X1588228880212'
,@path_id='910,911,912,913'
,@call_from='flow_optimization'
,@priority_id=''
,@filter_pipeline='' 
,@filter_contract='' 
,@rec_priority_id='' 
,@del_priority_id='' 

--begin tran
--			rollback
--commit
--*/
SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)
DECLARE @sql1 VARCHAR(MAX)
DECLARE @sql2 VARCHAR(MAX)
DECLARE @sql3 VARCHAR(MAX)
DECLARE @default_location_type_name VARCHAR(100) = NULL
DECLARE @main_grid_process_table  VARCHAR(200)
DECLARE @final_grid_process_table  VARCHAR(200) 
DECLARE @user_name VARCHAR(100) = dbo.FNADBUser()  

IF @location=''
	SET @location=NULL
IF @location_type=''
BEGIN
	SET @location_type=NULL
	--SET @default_location_type_name = 'M2'
END
IF @priority_id=''
	SET @priority_id=NULL
IF @rec_priority_id = ''
	SET @rec_priority_id = NULL
IF @del_priority_id = ''
	SET @del_priority_id = NULL
IF @filter_pipeline = ''
	SET @filter_pipeline = NULL
IF @filter_contract = ''
	SET @filter_contract = NULL
IF @path_id = ''
	SET @path_id = NULL

DECLARE @where_clause VARCHAR(1028) = ''

IF @flag = 'b' -- load schedules grid data on 'View Nomination Schedules' page.
BEGIN
	IF @call_from <> 'deal_scheduling_match'
	BEGIN
		SET @path_id = ISNULL(@path_id + ',', '') + '-99'
	END

    SET @main_grid_process_table = dbo.FNAProcessTableName('main_grid_process_table', @user_name, @process_id)

	SET @sql1 = 'SELECT DISTINCT
			sdh.deal_id deal_id,
			ISNULL(sdh.description1, '''') nom_group,
			ISNULL(sdh.description2, '''') priority,
			ISNULL(sdv.code, '''') [priority_path],
			CASE WHEN sdd.leg = 1 THEN  CASE WHEN MAX(ISNULL(sml_rec.location_id, sml.location_id)) = MAX(ISNULL(sml_rec.location_name, sml.location_name)) THEN MAX(ISNULL(sml_rec.location_name, sml.location_name)) ELSE MAX(ISNULL(sml_rec.location_id, sml.location_id)) + '' - '' + MAX(ISNULL(sml_rec.location_name, sml.location_name)) END ELSE '''' END [Rec Location],
			ISNULL(MAX(sdv3.code), sdv1.code) delivery_priority,
			CASE WHEN sdd.leg = 2 THEN  CASE WHEN MAX(ISNULL(sml_del.location_id, sml.location_id)) = MAX(ISNULL(sml_del.location_name, sml.location_name)) THEN MAX(ISNULL(sml_del.location_name, sml.location_name)) ELSE MAX(ISNULL(sml_del.location_id, sml.location_id)) + '' - '' + MAX(ISNULL(sml_del.location_name, sml.location_name)) END ELSE '''' END [Delivery Location],
			ISNULL(MAX(plsa.loss_factor), ''0'') AS Shrinkage,
			CAST(SUM(CASE WHEN sdd.leg = 1 THEN sdd.deal_volume ELSE NULL END) AS INT) [Schedule Vol],
			CAST(SUM(CASE WHEN sdd.leg = 2 THEN sdd.deal_volume ELSE NULL END) AS INT) [delivery Vol],
			CAST(ROUND(CASE WHEN sdd.leg = 2 THEN sdd.schedule_volume ELSE NULL END, 3) AS INT) [schedule_del_vol],
			CAST(ROUND(CASE WHEN sdd.leg = 1 THEN sdd.schedule_volume ELSE NULL END, 3) AS INT) [schedule_rec_vol],
			CAST(ROUND(CASE WHEN sdd.leg = 1 THEN sdd.actual_volume ELSE NULL END, 3) AS INT) [actual_rec_vol],
			CAST(ROUND(CASE WHEN sdd.leg = 2 THEN sdd.actual_volume ELSE NULL END, 3) AS INT) [actual_del_vol],
			dp.path_name [path],
			ISNULL(cg.contract_name, '''') [contract],
			cg.contract_id [contract_id],
			sc.counterparty_name [pipeline],
			ISNULL(CAST(SUM(dp.mdq) AS int), '''') [Capacity],
			CASE WHEN sdd.leg = 2 THEN sml.source_minor_location_id ELSE '''' END  [rec_id],
			CASE WHEN sdd.leg = 1 THEN sml.source_minor_location_id ELSE '''' END  [del_id],
			CAST(sdd.term_start AS DATE) [flow_date],
			sdh.source_deal_header_id [source_deal_header_id],
			ISNULL(dp.path_id,-99) [path_id],
			--IIF(NULLIF(MAX(uddf1.udf_value), '''') IS NOT NULL, dpd.path_id, dp.path_id) [group_path_id],
			IIF(NULLIF(MAX(sdd.attribute1), '''') IS NOT NULL, dpd.path_id, ISNULL(dp.path_id,-99)) [group_path_id],
			--IIF(NULLIF(MAX(uddf1.udf_value), '''') IS NOT NULL, dp1.path_name, dp.path_name) [group_path_name],
			IIF(NULLIF(MAX(sdd.attribute1), '''') IS NOT NULL, dp1.path_name, dp.path_name) [group_path_name],
			MAX(su.uom_name) [uom],
			MAX(sc.source_counterparty_id) [counterpaty_id],
			--IIF(NULLIF(MAX(uddf1.udf_value), '''') IS NOT NULL, ''y'', ''n'') [is_group_path],
			IIF(NULLIF(MAX(sdd.attribute1), '''') IS NOT NULL, ''y'', ''n'') [is_group_path],
			max(dpd.delivery_path_detail_id) [delivery_path_detail_id]
		INTO  #temp_tbl --  select * from #temp_tbl
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd
			ON sdd.source_deal_header_id = sdh.source_deal_header_id
				AND sdd.term_start >= ''' + CAST(@flow_date_from AS VARCHAR) + '''
				AND sdd.term_start <= ''' + CAST(@flow_date_to AS VARCHAR) + '''
		INNER JOIN source_minor_location sml
			ON sdd.location_id = sml.source_minor_location_id
		INNER JOIN source_major_location smj
			ON smj.source_major_location_ID = sml.source_major_location_ID
		LEFT JOIN contract_group cg
			ON cg.contract_id = sdh.contract_id
		INNER JOIN source_counterparty sc
			ON sc.source_counterparty_id = sdh.counterparty_id
		LEFT JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id AND uddft.Field_label = ''Delivery Path''
		LEFT JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id AND uddf.source_deal_header_id = sdh.source_deal_header_id

		--LEFT JOIN user_defined_deal_fields_template uddft1 ON uddft1.template_id = sdh.template_id AND uddft1.Field_label = ''Path Detail ID''
		--LEFT JOIN user_defined_deal_fields uddf1 ON uddf1.udf_template_id = uddft1.udf_template_id AND uddf1.source_deal_header_id = sdh.source_deal_header_id

		LEFT JOIN delivery_path dp ON CAST(dp.path_id AS VARCHAR)= uddf.udf_value
		LEFT JOIN delivery_path_detail dpd ON dpd.path_name = dp.path_id
		LEFT JOIN delivery_path dp1 ON dp1.path_id = dpd.path_id
		LEFT JOIN static_data_value sdv
			ON sdv.value_id = dp.[priority] AND sdv.type_id = 31400
		LEFT JOIN static_data_value sdv1
			ON sdv1.code = sdh.description2 AND sdv.[type_id] = 32000
		LEFT JOIN static_data_value sdv3
			ON sdv3.code = sdh.description3 AND sdv.[type_id] = 32000
		LEFT JOIN source_deal_type sdt
			ON  sdh.source_deal_type_id = sdt.source_deal_type_id
		INNER JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
		CROSS APPLY(SELECT MAX(recorderid) recorderid FROM source_minor_location_meter smlm INNER JOIN meter_id mi ON smlm.meter_id = mi.meter_id WHERE smlm.source_minor_location_id = sml.source_minor_location_id) mi
		OUTER APPLY (
			SELECT TOP 1 IIF(pls.shrinkage_curve_id IS NULL, pls.loss_factor, tsd.[value]) [loss_factor]
			FROM path_loss_shrinkage pls 
			LEFT JOIN path_loss_shrinkage plss ON plss.path_loss_shrinkage_id = pls.path_loss_shrinkage_id
			LEFT JOIN time_series_data tsd ON pls.shrinkage_curve_id = tsd.time_series_definition_id
				AND tsd.effective_date <= sdd.term_start
			WHERE pls.path_id = dp.path_id  AND pls.effective_date <= sdd.term_start AND pls.contract_id = sdh.contract_id
			ORDER BY pls.effective_date DESC
		) plsa
		LEFT JOIN transportation_contract_location tcl_rec ON tcl_rec.contract_id = cg.contract_id AND tcl_rec.rec_del = 1
		LEFT JOIN source_minor_location sml_rec ON sml_rec.source_minor_location_id = tcl_rec.location_id
		LEFT JOIN transportation_contract_location tcl_del ON tcl_del.contract_id = cg.contract_id AND tcl_del.rec_del = 2
		LEFT JOIN source_minor_location sml_del ON sml_del.source_minor_location_id = tcl_del.location_id
		WHERE 1=1  AND sdt.source_deal_type_name = ''Transportation'' 
			--AND CASE WHEN sdd.leg = 2 THEN sdd.schedule_volume ELSE NULL END IS NOT NULL
			--AND CASE WHEN sdd.leg = 1 THEN sdd.schedule_volume ELSE NULL END IS NOT NULL 
    '
	
	IF @location_type IS NOT NULL AND @location IS NULL
    BEGIN
		SET @sql1 += ' AND smj.source_major_location_ID IN(' + @location_type + ')'
    END
	IF @priority_id IS NOT NULL
    BEGIN
		SET @sql1 += ' AND dp.[priority] = ''' + CAST(@priority_id AS varchar) + ''''
    END	
	IF @rec_priority_id IS NOT NULL
    BEGIN
		SET @sql1 += ' AND sdv1.value_id = ''' + CAST(@rec_priority_id AS varchar) + ''''
    END
	IF @del_priority_id IS NOT NULL
    BEGIN
		SET @sql1 += ' AND ISNULL(sdv3.value_id,sdv1.value_id) = ''' + CAST(@del_priority_id AS varchar) + ''''
    END

	
    SET @sql2= ' GROUP BY sdh.description2, sdh.deal_id, sdh.description1, sdv.code, sdv1.code, sdd.term_start, sml.source_minor_location_id,
		   dp.path_code, sdh.source_deal_header_id,  sdd.schedule_volume, sdd.actual_volume, cg.contract_name, cg.contract_id, dp.path_name, sc.counterparty_name, sdd.leg, dp.path_id, dpd.path_id, dp1.path_name
		   HAVING SUM(CASE WHEN sdd.leg = 1 THEN sdd.deal_volume ELSE NULL END) IS NOT NULL
				OR SUM(CASE WHEN sdd.leg = 2 THEN sdd.deal_volume ELSE NULL END) IS NOT NULL
		   ;
		   
			SELECT  deal_id [deal] 
				, MAX(nom_group) nom_group 
				, MAX([priority]) [priority]
				, MAX(priority_path) priority_path
				, MAX([Rec Location]) [Rec Location]
				, ISNULL(MAX(delivery_priority), '''') delivery_priority
				, MAX( [Delivery Location]) [Delivery Location]
				, MAX(Shrinkage) Shrinkage
				, ISNULL(CAST(MAX([Schedule Vol]) AS VARCHAR), '''') [Schedule Vol]
				, ISNULL(CAST(MAX([delivery Vol]) AS VARCHAR), '''') [delivery Vol]
				, ISNULL(CAST(MAX(schedule_del_vol) AS VARCHAR), '''') schedule_del_vol
				, ISNULL(CAST(MAX(schedule_rec_vol) AS VARCHAR), '''') schedule_rec_vol
				, ISNULL(CAST(MAX(actual_rec_vol) AS VARCHAR), '''') actual_rec_vol
				, ISNULL(CAST(MAX(actual_del_vol) AS VARCHAR), '''') actual_del_vol
				, IIF(MAX(group_path_id) = -99, MAX([Rec Location]) + ''-'' + MAX([Delivery Location]),MAX(path)) [path]
				, MAX(tt.[contract]) [contract]
				, MAX(tt.pipeline) pipeline
				, MAX(Capacity) Capacity
				, MAX(rec_id) rec_id
				, MAX(del_id) del_id
				, flow_date
				, MAX(source_deal_header_id) [deal_id]
				, MAX(path_id) [path_id]
				, MAX(group_path_id) [group_path_id]
				, MAX(tt.uom) [uom]
				, IIF(MAX(group_path_id) = -99, MAX([Rec Location]) + ''-'' + MAX([Delivery Location]),MAX(group_path_name)) [group_path_name]
				, ''2'' [type]
				, MAX(is_group_path) [is_group_path]
				, MAX(delivery_path_detail_id) [delivery_path_detail_id]
				, ROW_NUMBER() OVER (
					PARTITION BY MAX(group_path_name), MAX(path_id)
					ORDER BY MAX(deal_id)
				) row_num
		INTO #temp_main_grid_result		    
		FROM #temp_tbl tt
	'

	IF @filter_contract IS NOT NULL
	BEGIN
		SET @sql2 += '
			CROSS APPLY (
				SELECT DISTINCT t.group_path_id [group_path]
				FROM #temp_tbl t 
				LEFT JOIN contract_group cg ON cg.contract_id = t.contract_id
				WHERE cg.contract_id = ''' + CAST(@filter_contract AS VARCHAR) + '''
					AND t.group_path_id = tt.group_path_id
			) b
			'
	END
	IF @filter_pipeline IS NOT NULL
    BEGIN
		SET @sql2 += '
			CROSS APPLY (
				SELECT DISTINCT t.group_path_id [group_path]
				FROM #temp_tbl t 
				LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = t.counterpaty_id
				WHERE sc.source_counterparty_id = ''' + CAST(@filter_pipeline AS VARCHAR) + '''
					AND t.group_path_id = tt.group_path_id
			) c
			'
    END
	IF @location IS NOT NULL
	BEGIN
		SET @sql2 += '
			LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = tt.rec_id
			LEFT JOIN source_minor_location sml1 ON sml1.source_minor_location_id = tt.del_id'
		SET @where_clause += ' AND (tt.group_path_id <> -99 OR sml.source_minor_location_id IN (' + @location + ') OR sml1.source_minor_location_id IN (' + @location + '))'
	END
	
	IF @path_id IS NOT NULL
	BEGIN
		SET @sql2 += '
			CROSS APPLY(SELECT DISTINCT t.group_path_id [g_path_id] FROM #temp_tbl t WHERE (t.path_id IN(' + @path_id + ') OR t.group_path_id IN (' + @path_id + ')) AND t.group_path_id = tt.group_path_id) path'
	END

	SET @sql2 += '		OUTER APPLY(
				SELECT sdd.attribute1 [value] 
				FROM  source_deal_header sdh
				--LEFT JOIN user_defined_deal_fields_template uddft2 ON uddft2.template_id = sdh.template_id AND uddft2.Field_label = ''Path Detail ID''
				--LEFT JOIN user_defined_deal_fields uddf2 ON uddf2.udf_template_id = uddft2.udf_template_id AND uddf2.source_deal_header_id = sdh.source_deal_header_id
				INNER JOIN source_deal_detail sdd
					ON sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.term_start >= ''' + CAST(@flow_date_from AS VARCHAR) + '''
					AND sdd.term_start <= ''' + CAST(@flow_date_to AS VARCHAR) + '''
				WHERE sdd.attribute1 IS NOT NULL
			) abc'
		
		SET @where_clause += ' AND tt.group_path_id = IIF(tt.is_group_path = ''y'', abc.value, tt.group_path_id)'


	IF @where_clause <> ''
		SET @sql2 += ' WHERE 1 = 1 AND (ISNULL([Schedule Vol], -1) <> 0 AND ISNULL([delivery Vol], -1) <> 0)' + @where_clause

	SET @sql3 = CAST('' AS VARCHAR(MAX)) + ' GROUP BY deal_id, flow_date, group_path_id;
		
		--Delete orphan path of group path which are not scheduled and are common
		SELECT tt.group_path_id
		INTO #temp_delete_orphan_path
		FROM #temp_main_grid_result tt
		WHERE tt.is_group_path = ''y''
		GROUP BY tt.group_path_id
		HAVING COUNT(tt.group_path_id) <= 1

		DELETE tt
		FROM #temp_main_grid_result tt
		LEFT JOIN #temp_delete_orphan_path a ON a.group_path_id = tt.group_path_id
		WHERE a.group_path_id IS NOT NULL'

	IF @transaction_type IN ('t', 'a')
	BEGIN
	SET @sql3 += '
		SELECT DISTINCT deal, nom_group, [priority], priority_path, [Rec Location], delivery_priority, [Delivery Location], CAST(Shrinkage AS VARCHAR) [Shrinkage],
				[Schedule Vol], [delivery Vol], schedule_rec_vol, schedule_del_vol, actual_rec_vol, actual_del_vol,
				[path], [contract], pipeline, Capacity, rec_id, del_id, flow_date, deal_id, path_id, group_path_id, uom, group_path_name, [type], [is_group_path],[delivery_path_detail_id], '''' leg, row_num
		INTO #final_result
		FROM #temp_main_grid_result'
	END

	IF @transaction_type IN ('b', 'a')
	BEGIN
		IF @transaction_type = 'a'
			SET @sql3 += '
				UNION ALL'
	
		SET @sql3 += '
			SELECT DISTINCT
				pur_deal.deal_id [deal], '''' [nom_group], '''' [priority], '''' [priority_path]
				, ISNULL(pur_deal.location,'''') [Rec Location], '''' [delivery_priority], '''' [Delivery Location]
				, '''' [Shrinkage], ISNULL(CAST(pur_deal.[Schedule Vol] AS VARCHAR),'''') [Schedule Vol], '''' [delivery Vol]
				, ISNULL(CAST(pur_deal.schedule_rec_vol AS VARCHAR),'''') [schedule_rec_vol], '''' [schedule_del_vol]
				, ISNULL(CAST(pur_deal.actual_rec_vol AS VARCHAR),'''') [actual_rec_vol], '''' [actual_del_vol]
				, '''' [path], pur_deal.contract, pur_deal.pipeline, NULL [Capacity], NULL [rec_id], NULL [del_id], tt.flow_date
				, pur_deal.source_deal_header_id [deal_id], NULL [path_id], tt.group_path_id
				,pur_deal.uom,tt.group_path_name, pur_deal.[rank] [type], NULL [is_group_path], NULL [delivery_path_detail_id], pur_deal.leg, tt.row_num
			'
		IF @transaction_type = 'b'
			SET @sql3 += 'INTO #final_result'

		SET @sql3 += ' 
			FROM #temp_main_grid_result tt
			OUTER APPLY (
				SELECT sdh.deal_id, sdh.source_deal_header_id, sdd.term_start, sdd.location_id , ''1'' [rank], CAST(ROUND(ISNULL(pos_info.daily_pos,sdd.deal_volume), 0) AS INT) [Schedule Vol]
					, CAST(ROUND(IIF(sdh.term_frequency = ''d'', sdd.schedule_volume, sddh.schedule_volume), 0) AS INT) [schedule_rec_vol]
					, CAST(ROUND(IIF(sdh.term_frequency = ''d'', sdd.actual_volume, sddh.actual_volume), 0) AS INT) [actual_rec_vol]
					, cg.contract_name [contract], su.uom_name [uom], sc.counterparty_name [pipeline]
					, sml.location_name [location], sdd.leg
				FROM source_deal_detail sdd
				INNER JOIN source_deal_header sdh On sdh.source_deal_header_id = sdd.source_deal_header_id
				LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
				LEFT JOIN source_deal_detail_hour sddh ON sdd.source_deal_detail_id = sddh.source_deal_detail_id AND sddh.term_date = tt.flow_date
				INNER JOIN source_deal_header_template sdht on sdht.template_id = sdh.template_id
				INNER JOIN contract_group cg ON cg.contract_id = sdh.contract_id
				INNER JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
				INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
				CROSS APPLY (
					SELECT od.source_deal_header_id
					FROM optimizer_detail od
					OUTER APPLY (
						SELECT TOP 1 tt.deal_id, tt.is_group_path
						FROM delivery_path_detail dpd
						WHERE IIF(tt.group_path_id = -99, dpd.path_id, tt.group_path_id) = dpd.path_id
						ORDER BY dpd.delivery_path_detail_id ASC
					) aa
					WHERE od.transport_deal_id = IIF(tt.is_group_path = ''y'', aa.deal_id, tt.deal_id) AND od.up_down_stream = ''U''
				) bb
				LEFT JOIN source_minor_location sml_proxy ON sml_proxy.proxy_location_id = tt.del_id
				OUTER APPLY (
					SELECT ABS(hr1 + hr2 + hr3 + hr4 + hr5 + hr6 + hr7 + hr8 + hr9 + hr10 + hr11 + hr12 + hr13 + hr14 + hr15 + hr16 + hr17 + hr18 + hr19 + hr20 + hr21 + hr22 + hr23 + hr24 + hr25) [daily_pos]
					FROM report_hourly_position_deal rhpd
					WHERE rhpd.term_start between sdd.term_start and sdd.term_end and rhpd.source_deal_detail_id = sdd.source_deal_detail_id
					UNION ALL
					SELECT ABS(hr1 + hr2 + hr3 + hr4 + hr5 + hr6 + hr7 + hr8 + hr9 + hr10 + hr11 + hr12 + hr13 + hr14 + hr15 + hr16 + hr17 + hr18 + hr19 + hr20 + hr21 + hr22 + hr23 + hr24 + hr25) [daily_pos]
					FROM report_hourly_position_profile rhpp
					WHERE rhpp.term_start between sdd.term_start and sdd.term_end and rhpp.source_deal_detail_id = sdd.source_deal_detail_id
				) pos_info
				WHERE (sdd.location_id = tt.del_id OR sdd.location_id = sml_proxy.source_minor_location_id) AND buy_sell_flag = ''b''
					AND sdd.term_start BETWEEN IIF(sdh.term_frequency = ''d'', tt.flow_date, dbo.FNAGetFirstLastDayOfMonth(tt.flow_date,''f'')) 
						AND IIF(sdh.term_frequency = ''d'', tt.flow_date, dbo.FNAGetFirstLastDayOfMonth(tt.flow_date,''l''))
					AND bb.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.term_start BETWEEN IIF(sdh.term_frequency = ''d'', ''' + CAST(@flow_date_from AS VARCHAR) + ''', dbo.FNAGetFirstLastDayOfMonth(''' + CAST(@flow_date_from AS VARCHAR) + ''',''f'')) 
						AND IIF(sdh.term_frequency = ''d'', ''' + CAST(@flow_date_to AS VARCHAR) + ''', dbo.FNAGetFirstLastDayOfMonth(''' + CAST(@flow_date_to AS VARCHAR) + ''',''l''))
			) pur_deal
			WHERE pur_deal.deal_id IS NOT NULL
			UNION ALL
			SELECT DISTINCT
				sale_deal.deal_id, '''', '''', ''''
				, '''', '''', sale_deal.location
				, '''', '''', ISNULL(CAST(sale_deal.[delivery Vol] AS VARCHAR),'''')
				, '''', ISNULL(CAST(sale_deal.schedule_del_vol AS VARCHAR),'''')
				, '''', ISNULL(CAST(sale_deal.actual_del_vol AS VARCHAR),'''')
				,'''',sale_deal.contract,sale_deal.pipeline, NULL, NULL, NULL, tt.flow_date
				,sale_deal.source_deal_header_id, NULL,tt.group_path_id
				,sale_deal.uom, tt.group_path_name, sale_deal.[rank] [type], NULL, null, sale_deal.leg, tt.row_num
			FROM #temp_main_grid_result tt
			OUTER APPLY (
				SELECT sdh.deal_id, sdh.source_deal_header_id, sdd.term_start, sdd.location_id, ''3'' [rank], CAST(ROUND(ISNULL(pos_info.daily_pos,sdd.deal_volume), 0) AS INT) [delivery Vol]
					, CAST(ROUND(IIF(sdh.term_frequency = ''d'', sdd.schedule_volume, sddh.schedule_volume), 0) AS INT) [schedule_del_vol]
					, CAST(ROUND(IIF(sdh.term_frequency = ''d'', sdd.actual_volume, sddh.actual_volume), 0) AS INT) [actual_del_vol]
					, cg.contract_name [contract], su.uom_name [uom], sc.counterparty_name [pipeline]
					, sml.location_name [location], sdd.leg
				FROM source_deal_detail sdd
				INNER JOIN source_deal_header sdh On sdh.source_deal_header_id = sdd.source_deal_header_id
				LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
				LEFT JOIN source_deal_detail_hour sddh ON sdd.source_deal_detail_id = sddh.source_deal_detail_id AND sddh.term_date = tt.flow_date
				INNER JOIN source_deal_header_template sdht on sdht.template_id = sdh.template_id
				INNER JOIN contract_group cg ON cg.contract_id = sdh.contract_id
				INNER JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
				INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
				CROSS APPLY (
					SELECT odd.source_deal_header_id
					FROM optimizer_detail_downstream odd
					OUTER APPLY (
						SELECT TOP 1 tt.deal_id, tt.is_group_path
						FROM delivery_path_detail dpd
						WHERE IIF(tt.group_path_id = -99, dpd.path_id, tt.group_path_id) = dpd.path_id
						ORDER BY dpd.delivery_path_detail_id ASC
					) aa
					WHERE odd.transport_deal_id = IIF(tt.is_group_path = ''y'', aa.deal_id, tt.deal_id)
				) bb
				LEFT JOIN source_minor_location sml_proxy ON sml_proxy.proxy_location_id = tt.rec_id
				OUTER APPLY (
					SELECT ABS(hr1 + hr2 + hr3 + hr4 + hr5 + hr6 + hr7 + hr8 + hr9 + hr10 + hr11 + hr12 + hr13 + hr14 + hr15 + hr16 + hr17 + hr18 + hr19 + hr20 + hr21 + hr22 + hr23 + hr24 + hr25) [daily_pos]
					FROM report_hourly_position_deal rhpd
					WHERE rhpd.source_deal_header_id = sdd.source_deal_header_id
						AND rhpd.term_start = sdd.term_start
						AND rhpd.location_id = sdd.location_id
					UNION ALL
					SELECT ABS(hr1 + hr2 + hr3 + hr4 + hr5 + hr6 + hr7 + hr8 + hr9 + hr10 + hr11 + hr12 + hr13 + hr14 + hr15 + hr16 + hr17 + hr18 + hr19 + hr20 + hr21 + hr22 + hr23 + hr24 + hr25) [daily_pos]
					FROM report_hourly_position_profile rhpp
					WHERE rhpp.source_deal_header_id = sdd.source_deal_header_id
						AND rhpp.term_start = sdd.term_start
						AND rhpp.location_id = sdd.location_id
				) pos_info
				WHERE (sdd.location_id = tt.rec_id OR sdd.location_id = sml_proxy.source_minor_location_id) AND buy_sell_flag = ''s''
					AND sdd.term_start BETWEEN IIF(sdh.term_frequency = ''d'', tt.flow_date, dbo.FNAGetFirstLastDayOfMonth(tt.flow_date, ''f'')) 
						AND IIF(sdh.term_frequency = ''d'', tt.flow_date, dbo.FNAGetFirstLastDayOfMonth(tt.flow_date, ''l''))
					AND bb.source_deal_header_id = sdh.source_deal_header_id
					AND sdd.term_start BETWEEN IIF(sdh.term_frequency = ''d'', ''' + CAST(@flow_date_from AS VARCHAR) + ''', dbo.FNAGetFirstLastDayOfMonth(''' + CAST(@flow_date_from AS VARCHAR) + ''', ''f'')) 
						AND IIF(sdh.term_frequency = ''d'', ''' + CAST(@flow_date_to AS VARCHAR) + ''', dbo.FNAGetFirstLastDayOfMonth(''' + CAST(@flow_date_to AS VARCHAR) + ''', ''l''))
					AND sdht.template_name <> ''Transportation NG''
			) sale_deal
			WHERE sale_deal.deal_id IS NOT NULL'
	END

	SET @sql3 += '
		SELECT *, dbo.FNADateFormat(flow_date) + '' ('' + group_path_name + '')'' + IIF(row_num > 1, '' - '' + CAST(row_num AS VARCHAR(10)), '''') [group_column] FROM #final_result ORDER BY group_column, type
		SELECT * INTO ' + @main_grid_process_table + ' FROM #final_result
	'
	--print @sql1
	--print @sql2
	--print @sql3

	--select @sql1
	EXEC (@sql1+@sql2+@sql3)


END
ELSE IF @flag = 'u' -- update schedule information of deal
BEGIN
    UPDATE source_deal_detail
    SET deal_volume = @scheduled_volume
    WHERE buy_sell_flag = 's'
    AND source_deal_header_id = @source_deal_header_id
    UPDATE source_deal_detail
    SET deal_volume = @delivery_volume
    WHERE buy_sell_flag = 'b'
    AND source_deal_header_id = @source_deal_header_id

	UPDATE sdh 
	SET sdh.description3 = sdv.code
	FROM source_deal_header sdh
	LEFT JOIN static_data_value sdv ON sdv.value_id = @del_priority_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id

	--Logic to calculate position report for that updated deal.
	DECLARE @report_position_process_id VARCHAR(500)
	DECLARE @user_login_id VARCHAR(200)
	DECLARE @report_position_deals VARCHAR(500)

	SET @user_login_id = dbo.FNADBUser()
	SET @report_position_process_id = dbo.FNAGetNewID()
	SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @report_position_process_id)
	
	EXEC ('CREATE TABLE ' + @report_position_deals + '(source_deal_header_id INT, action CHAR(1))')   
	EXEC('INSERT INTO ' + @report_position_deals + '(source_deal_header_id, action)
		SELECT '+@source_deal_header_id+', ''u'''
		)
	EXEC dbo.spa_update_deal_total_volume NULL, @report_position_process_id
	IF @@ERROR <> 0
		BEGIN	
			EXEC spa_ErrorHandler @@ERROR, 
			'View Nom schedules', 
			'spa_schedules_view', 
			'DB Error',
			'Failed to update View Nom schedule.', 
			'Failed Updating View Nom schedule'
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 0, 
			'View Nom schedules', 
			'spa_schedules_view', 
			'Success', 
			'View Nom schedules successfully updated.', 
			''
			END
	--END of Logic to calculate position report for that updated deal.
  END
ELSE IF @flag = 'e'
BEGIN
	CREATE TABLE #temp_table1 (
      location_id varchar(100) COLLATE DATABASE_DEFAULT,
      Location varchar(100) COLLATE DATABASE_DEFAULT,
      [Type] varchar(100) COLLATE DATABASE_DEFAULT,
      [Flow Date] datetime,
      [Meter] varchar(100) COLLATE DATABASE_DEFAULT,
      Volume numeric(38, 20),
      [capacity] float,
      rec_del char(10) COLLATE DATABASE_DEFAULT
    )
    SET @sql = '	 
	INSERT INTO #temp_table1
	SELECT 	  
		sml.source_minor_location_id location_id,
		(sml.location_name) [Location],
		(smj.location_name) [TYPE],
		sdd.term_start [Flow Date],
		MAX(mi.recorderid) [Meter],
		SUM(CASE WHEN sdd.buy_sell_flag = ''b'' THEN 1 ELSE -1 END * sdd.deal_volume) [Volume],
		CAST(SUM(dp.mdq) AS FLOAT) [capacity],
		MAX(CASE WHEN sdd.leg=2 THEN ''d'' ELSE ''r'' END) rec_del
	FROM
		source_deal_header sdh 
		INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id AND uddft.Field_label =' + '''' + 'Delivery Path' + '''' + '
		INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id AND uddf.source_deal_header_id =sdh.source_deal_header_id
		INNER JOIN delivery_path dp ON CAST(dp.path_id AS VARCHAR) = uddf.udf_value
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		INNER JOIN source_minor_location sml ON sml.source_minor_location_id = sdd.location_id
		INNER JOIN source_major_location smj on smj.source_major_location_ID = sml.source_major_location_ID
		INNER JOIN static_data_value sdv
			ON sdv.value_id = dp.[priority]
			AND sdv.type_id = 31400
		CROSS APPLY(SELECT MAX(recorderid) recorderid FROM source_minor_location_meter smlm INNER JOIN meter_id mi ON smlm.meter_id = mi.meter_id WHERE smlm.source_minor_location_id = sml.source_minor_location_id) mi
	WHERE 1=1  '
    IF @location_type IS NOT NULL
    BEGIN
      SET @sql = @sql + 'AND smj.source_major_location_ID IN(' + @location_type + ')'
    END
	IF @location IS NOT NULL
    BEGIN
      SET @sql = @sql + 'AND sml.source_minor_location_ID IN(' + @location + ')'
    END
    IF @flow_date_from IS NOT NULL
    BEGIN
      SET @sql = @sql + 'AND sdd.term_start >= ''' + CAST(@flow_date_from AS varchar) + ''''
    END
    IF @flow_date_to IS NOT NULL
    BEGIN
      SET @sql = @sql + 'AND sdd.term_start <= ''' + CAST(@flow_date_to AS varchar) + ''''
    END
    IF @priority_id IS NOT NULL
    BEGIN
      SET @sql = @sql + 'AND dp.[priority] = ''' + CAST(@priority_id AS varchar) + ''''
    END
    --SET @sql =@sql+' AND sml.location_id = '+ ''''+'ALTAMONT MMM'+ ''''+''+' GROUP BY sdd.location_id,smj.location_name,sml.location_id ,term_start'
    SET @sql = @sql + ' GROUP BY smj.location_name,sml.location_name ,sdd.term_start, sml.source_minor_location_id'
    --PRINT @sql
    EXEC (@sql)
    CREATE TABLE #temp_table2 (
      [Priority] varchar(100) COLLATE DATABASE_DEFAULT,
      [Rec Location] varchar(100) COLLATE DATABASE_DEFAULT,
      [Delivery Location] varchar(100) COLLATE DATABASE_DEFAULT,
      Shrinkage varchar(100) COLLATE DATABASE_DEFAULT,
      [Schedule Vol] int,
      [delivery Vol] int,
      [capacity] float,
      rec_id int,
      del_id int,
      flow_date date,
      deal_id int
    )

    SET @sql1 = 'INSERT INTO #temp_table2
	  SELECT
      sdv.code [Priority],
      MAX(sml1.location_name) [Rec Location],
      MAX(sml.location_name) [Delivery Location],
      MAX(dp.loss_factor) AS Shrinkage,
      CAST(SUM(sdd1.deal_volume) AS int) [Schedule Vol],
      CAST(SUM(sdd.deal_volume) AS int) [delivery Vol],
      CAST(SUM(dp.mdq) AS int) [Capacity],
      (sml.source_minor_location_id) [rec_id],
      (sml1.source_minor_location_id) [del_id],
	  dbo.FNADateFormat(sdd.term_start) [flow_date],
	  sdh.source_deal_header_id [deal_id]
	FROM source_deal_header sdh
    INNER JOIN source_deal_detail sdd
      ON sdd.source_deal_header_id = sdh.source_deal_header_id
      AND sdd.Leg = 2
      AND sdd.buy_sell_flag = ' + '''' + 'b' + '''' + '
    INNER JOIN source_minor_location sml
      ON sdd.location_id = sml.source_minor_location_id
    INNER JOIN source_deal_detail sdd1
      ON sdd1.source_deal_header_id = sdh.source_deal_header_id
      AND sdd1.Leg = 1
      AND sdd1.buy_sell_flag = ' + '''' + 's' + '''' + '
    INNER JOIN source_minor_location sml1
      ON sdd1.location_id = sml1.source_minor_location_id
    INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id AND uddft.Field_label = ' + '''' + 'Delivery Path' + '''' + '
	INNER JOIN user_defined_deal_fields uddf ON uddf.udf_template_id = uddft.udf_template_id AND uddf.source_deal_header_id =sdh.source_deal_header_id
	INNER JOIN delivery_path dp ON CAST(dp.path_id AS VARCHAR)= uddf.udf_value
	INNER JOIN static_data_value sdv
      ON sdv.value_id = dp.[priority] AND sdv.type_id = 31400
    WHERE sdh.source_deal_type_id = 57'
    IF @priority_id IS NOT NULL
    BEGIN
      SET @sql1 = @sql1 + 'AND dp.[priority] =''' + CAST(@priority_id AS varchar) + ''''
    END
    --AND  sdd.term_start BETWEEN '2014-08-01' AND '2014-08-01'
    --AND (sml.location_id = 'ALTAMONT MMM'   OR sml1.location_id = 'ALTAMONT MMM')
    SET @sql1 = @sql1 + 'GROUP BY sdv.code,sdd.term_start,
             sml.source_minor_location_id,
             sml1.source_minor_location_id,dp.path_code,sdh.source_deal_header_id'
    --PRINT (@sql1)
    EXEC (@sql1)

    CREATE TABLE #temp_table3 (
      location_id varchar(100) COLLATE DATABASE_DEFAULT,
      location varchar(100) COLLATE DATABASE_DEFAULT,
      [Flow Date] date,
      [Priority] varchar(100) COLLATE DATABASE_DEFAULT,
      [Rec Location] varchar(100) COLLATE DATABASE_DEFAULT,
      [Delivery Location] varchar(100) COLLATE DATABASE_DEFAULT,
      Shrinkage varchar(100) COLLATE DATABASE_DEFAULT,
      [Schedule Vol] varchar(100) COLLATE DATABASE_DEFAULT,
      [delivery Vol] varchar(100) COLLATE DATABASE_DEFAULT,
      [capacity] varchar(100) COLLATE DATABASE_DEFAULT
    )
    INSERT INTO #temp_table3
      SELECT
        tt.location_id,
        tt.Location,
        tt.[Flow Date],
        tt2.[Priority],
        tt2.[Rec Location],
        tt2.[Delivery Location],
		tt2.Shrinkage,
        tt2.[Schedule Vol],
        tt2.[delivery Vol],
        tt2.Capacity

      FROM #temp_table2 tt2
      INNER JOIN #temp_table1 tt
        ON tt2.rec_id = tt.location_id
        AND tt2.flow_date = tt.[Flow Date]

    INSERT INTO #temp_table3
      SELECT
        tt0.location_id,
        tt0.Location,
        tt0.[Flow Date],
        tt2.[Priority],
        tt2.[Rec Location],
        tt2.[Delivery Location],
		tt2.Shrinkage,
        tt2.[Schedule Vol],
        tt2.[delivery Vol],
        tt2.Capacity
      FROM #temp_table2 tt2

      INNER JOIN #temp_table1 tt0
        ON tt2.del_id = tt0.location_id
        AND tt2.flow_date = tt0.[Flow Date]

    SELECT
      -- tt.location_id,
      tt.Location,
      tt.[Flow Date],
      tt.[Priority],
      tt.[Rec Location],
      tt.[Delivery Location],
      tt.[Schedule Vol],
      tt.Shrinkage,
      tt.[delivery Vol],
      tt.Capacity

    FROM #temp_table3 tt
    ORDER BY tt.location_id, tt.[Flow Date]
END
ELSE IF @flag = 'v'
BEGIN
	SELECT
		smal.location_name [Group],
		smil.location_name [Location],
		smal.source_major_location_ID,
		smil.source_minor_location_id
	FROM source_minor_location smil
	INNER JOIN source_major_location smal ON smil.source_major_location_ID=smal.source_major_location_ID
	ORDER BY smal.location_name,smil.location_name

END
ELSE IF @flag = 'p' -- update delivery rank of schedule deal
BEGIN
		SET @sql = 'UPDATE sdh 
			SET sdh.description3 = sdv.code
			FROM source_deal_header sdh
			LEFT JOIN static_data_value sdv ON sdv.value_id = ' + CAST(@del_priority_id AS VARCHAR(10)) + 
			' WHERE sdh.source_deal_header_id IN (' + @source_deal_header_id + ')'


		EXEC(@sql)

		IF @@ERROR <> 0
		BEGIN	
			EXEC spa_ErrorHandler @@ERROR, 
			'View Nom schedules', 
			'spa_schedules_view', 
			'DB Error',
			'Failed to update del Rank.', 
			'Failed Updating del Rank'
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler 0, 
			'View Nom schedules', 
			'spa_schedules_view', 
			'Success', 
			'Changes have been saved successfully.', 
			''
		END
	END
ELSE IF @flag = 'q' -- store grid data on process table
BEGIN
	SET @main_grid_process_table = dbo.FNAProcessTableName('main_grid_process_table', @user_name, @process_id) 
	SET @final_grid_process_table = dbo.FNAProcessTableName('final_grid_process_table', @user_name, @process_id) 
	
	SET @sql = 'SELECT
						p1.group_path_name,p1.flow_date,p1.path,p1.deal_id,
						p1.[schedule vol],p1.shrinkage,p1.[delivery vol],
						p1.schedule_del_vol,p1.schedule_rec_vol,p1.actual_rec_vol,p1.actual_del_vol,
						p1.[Rec location],p1.[Delivery Location],
						p1.contract,p1.pipeline,p1.nom_group,p1.priority_path,p1.priority,p1.delivery_priority,p1.uom
				INTO ' + @final_grid_process_table + '
				FROM ' + @main_grid_process_table + ' p1'

	EXEC(@sql)
	SELECT @final_grid_process_table [process_table]
END
ELSE IF @flag = 'c' -- save schedule values
BEGIN
	BEGIN TRY
		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		SELECT	deal_id,
				term_start,
				NULLIF(nom_rec_vol, '') nom_rec_vol,
				NULLIF(nom_del_vol, '') nom_del_vol,
				NULLIF(schedule_rec_vol, '') schedule_rec_vol,
				NULLIF(schedule_del_vol, '') schedule_del_vol,
				NULLIF(actual_rec_vol, '') actual_rec_vol,
				NULLIF(actual_del_vol, '') actual_del_vol,
				deal_type,
				NULLIF(leg, '') leg
		INTO #temp_grid_data		-- select * from #temp_grid_data	
		FROM   OPENXML (@idoc, '/GridXML/GridRow', 1)
				WITH ( 
					deal_id				VARCHAR(5000)	'@deal_id',						
					term_start			VARCHAR(5000)	'@term_start', 
					nom_rec_vol			VARCHAR(5000)	'@nom_rec_vol',
					nom_del_vol			VARCHAR(5000)	'@nom_del_vol',
					schedule_rec_vol	VARCHAR(5000)	'@schedule_rec_vol',
					schedule_del_vol	VARCHAR(5000)	'@schedule_del_vol',
					actual_rec_vol		VARCHAR(5000)	'@actual_rec_vol',
					actual_del_vol		VARCHAR(5000)	'@actual_del_vol',
					deal_type			VARCHAR(5000)	'@deal_type',
					leg					VARCHAR(5000)	'@leg'
					)
		EXEC sp_xml_removedocument @idoc





		UPDATE sdd
			SET sdd.deal_volume = tgd.nom_rec_vol,
				sdd.schedule_volume = tgd.schedule_rec_vol,
				sdd.actual_volume = tgd.actual_rec_vol
		FROM source_deal_detail sdd
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN #temp_grid_data tgd ON tgd.deal_id = sdd.source_deal_header_id
		WHERE sdd.buy_sell_flag = 's' AND tgd.deal_type = 2
			AND sdd.term_start BETWEEN IIF(sdh.term_frequency = 'd', tgd.term_start, dbo.FNAGetFirstLastDayOfMonth(tgd.term_start, 'f')) 
				AND IIF(sdh.term_frequency = 'd', tgd.term_start, dbo.FNAGetFirstLastDayOfMonth(tgd.term_start, 'l'))
		
		UPDATE sdd
			SET sdd.deal_volume = tgd.nom_del_vol,
				sdd.schedule_volume = tgd.schedule_del_vol,
				sdd.actual_volume = tgd.actual_del_vol
		FROM source_deal_detail sdd
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN #temp_grid_data tgd ON tgd.deal_id = sdd.source_deal_header_id
		WHERE sdd.buy_sell_flag = 'b' AND tgd.deal_type = 2
			AND sdd.term_start BETWEEN IIF(sdh.term_frequency = 'd', tgd.term_start, dbo.FNAGetFirstLastDayOfMonth(tgd.term_start, 'f')) 
				AND IIF(sdh.term_frequency = 'd', tgd.term_start, dbo.FNAGetFirstLastDayOfMonth(tgd.term_start, 'l'))
		


		
		--## Update source_deal_detail_hour for buy/sell deal if term_frequency is monthly
		IF EXISTS(
			SELECT 1
			FROM source_deal_detail_hour sddh
			INNER JOIN source_deal_detail sdd ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN #temp_grid_data tgd ON tgd.deal_id = sdh.source_deal_header_id
			WHERE sdh.term_frequency = 'm' AND tgd.deal_type <> 2 
				AND sddh.term_date = tgd.term_start
				AND sdd.leg = tgd.leg
		)
		BEGIN
			UPDATE sddh
				SET sddh.schedule_volume = COALESCE(tgd.schedule_rec_vol, tgd.schedule_del_vol),
					sddh.actual_volume = COALESCE(tgd.actual_rec_vol, tgd.actual_del_vol)
			FROM source_deal_detail_hour sddh
			INNER JOIN source_deal_detail sdd ON sddh.source_deal_detail_id = sdd.source_deal_detail_id
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN #temp_grid_data tgd ON tgd.deal_id = sdh.source_deal_header_id
			WHERE sdh.term_frequency = 'm' AND tgd.deal_type <> 2 
				AND sddh.term_date = tgd.term_start
				AND sdd.leg = tgd.leg
		END
		ELSE
		BEGIN
			INSERT INTO source_deal_detail_hour(source_deal_detail_id, term_date, hr, is_dst, actual_volume, schedule_volume)
			SELECT sdd.source_deal_detail_id, tgd.term_start, '01:00', 0, COALESCE(tgd.actual_rec_vol, tgd.actual_del_vol), COALESCE(tgd.schedule_rec_vol, tgd.schedule_del_vol)
			FROM #temp_grid_data tgd
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = tgd.deal_id
			INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
			WHERE sdh.term_frequency = 'm' AND tgd.deal_type <> 2 
				AND sdd.term_start BETWEEN IIF(sdh.term_frequency = 'd', tgd.term_start, dbo.FNAGetFirstLastDayOfMonth(tgd.term_start, 'f'))
					AND IIF(sdh.term_frequency = 'd', tgd.term_start, dbo.FNAGetFirstLastDayOfMonth(tgd.term_start, 'l'))
					AND sdd.leg = tgd.leg
		END

		UPDATE sdd
		SET sdd.deal_volume = COALESCE(tgd.nom_rec_vol, tgd.nom_del_vol),
			sdd.schedule_volume = COALESCE(tgd.schedule_rec_vol, tgd.schedule_del_vol),
			sdd.actual_volume = COALESCE(tgd.actual_rec_vol, tgd.actual_del_vol)
		FROM source_deal_detail sdd
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN #temp_grid_data tgd ON tgd.deal_id = sdd.source_deal_header_id
		WHERE tgd.deal_type <> 2
			AND sdd.term_start BETWEEN IIF(sdh.term_frequency = 'd', tgd.term_start, dbo.FNAGetFirstLastDayOfMonth(tgd.term_start, 'f')) 
			AND IIF(sdh.term_frequency = 'd', tgd.term_start, dbo.FNAGetFirstLastDayOfMonth(tgd.term_start, 'l'))
			AND sdd.leg = tgd.leg
		
		--## Update Deal Detail Actual/Schedule Volume with average if term frequency is monthly
		IF OBJECT_ID('tempdb..#temp_volume_details') IS NOT NULL
			DROP TABLE #temp_volume_details

		CREATE TABLE #temp_volume_details(
			actual_volume VARCHAR(100) COLLATE DATABASE_DEFAULT
			, schedule_volume VARCHAR(100) COLLATE DATABASE_DEFAULT
			, source_deal_detail_id INT
		)
		
		INSERT INTO #temp_volume_details
		SELECT AVG(sddh.actual_volume), AVG(sddh.schedule_volume), MAX(sdd.source_deal_detail_id)
		FROM source_deal_detail sdd
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN #temp_grid_data tgd ON tgd.deal_id = sdd.source_deal_header_id
			LEFT JOIN source_deal_detail_hour sddh ON sdd.source_deal_detail_id = sddh.source_deal_detail_id
		WHERE tgd.deal_type <> 2 AND sdh.term_frequency = 'm'
			AND sdd.term_start BETWEEN dbo.FNAGetFirstLastDayOfMonth(tgd.term_start, 'f')
				AND dbo.FNAGetFirstLastDayOfMonth(tgd.term_start, 'l')
			AND sdd.leg = tgd.leg
		GROUP BY sdd.source_deal_detail_id

		UPDATE sdd SET sdd.actual_volume = tvd.actual_volume,
				sdd.schedule_volume = tvd.schedule_volume
		FROM #temp_volume_details tvd
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = tvd.source_deal_detail_id
		
		-- added code to update optimizer_header and optimizer_detail
		IF OBJECT_ID('tempdb..#tmp_vol') IS NOT NULL
			DROP TABLE #tmp_vol

		IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
			DROP TABLE #tmp

		IF OBJECT_ID('tempdb..#tmp1') IS NOT NULL
			DROP TABLE #tmp1
		
		CREATE TABLE #tmp_vol(optimizer_header_id INT,transport_deal_id INT, old_vol FLOAT,new_vol FLOAT,flow_date DATETIME, old_vol_dw FLOAT,new_vol_dw FLOAT)
	
		UPDATE oh 
		SET oh.rec_nom_volume = tgd.nom_rec_vol, 
			oh.del_nom_volume = tgd.nom_del_vol,
			oh.sch_rec_volume= tgd.schedule_rec_vol,
			oh.sch_del_volume= tgd.schedule_del_vol,
			oh.actual_rec_volume= tgd.actual_rec_vol,
			oh.actual_del_volume= tgd.actual_del_vol
		OUTPUT 								inserted.optimizer_header_id,inserted.transport_deal_id,deleted.rec_nom_volume,inserted.rec_nom_volume,inserted.flow_date,deleted.del_nom_volume,inserted.del_nom_volume
		INTO #tmp_vol(optimizer_header_id,transport_deal_id,old_vol,new_vol,flow_date,old_vol_dw,new_vol_dw)
		FROM optimizer_header oh
		INNER JOIN #temp_grid_data tgd ON tgd.deal_id = oh.transport_deal_id
		WHERE oh.flow_date = tgd.term_start





		update od set
			sch_rec_volume= tgd.schedule_rec_vol,
			sch_del_volume= tgd.schedule_del_vol,
			actual_rec_volume= tgd.actual_rec_vol,
			actual_del_volume= tgd.actual_del_vol
		from optimizer_detail od
			inner join #temp_grid_data tgd on tgd.deal_id = od.source_deal_header_id
				and tgd.term_start=od.flow_date
		where 
			 tgd.deal_type <>2 -- not schedule/transport deal



		update od set
			sch_rec_volume= tgd.schedule_rec_vol,
			sch_del_volume= tgd.schedule_del_vol,
			actual_rec_volume= tgd.actual_rec_vol,
			actual_del_volume= tgd.actual_del_vol
		from optimizer_detail od
			inner join #temp_grid_data tgd on tgd.deal_id = od.transport_deal_id
				and tgd.term_start=od.flow_date
		where 
			 tgd.deal_type =2 --  schedule/transport deal





		--  select * from #tmp_vol

		--DECLARE @diff_tot FLOAT,@trans_deal_id INT, @flow_date DATETIME
		----------------------------------------------------------
		-- optimizer_detail
		--------------------------------
	--	SELECT @diff_tot = (old_vol - new_vol ),@trans_deal_id = transport_deal_id,@flow_date = flow_date FROM #tmp_vol
		
		SELECT row_number() OVER(partition by od.transport_deal_id,od.flow_date,od.up_down_stream ORDER BY od.optimizer_detail_id DESC) rowid,od.transport_deal_id,od.flow_date 
		,case when od.up_down_stream='U' then ( tv.old_vol - tv.new_vol ) else ( tv.old_vol_dw - tv.new_vol_dw ) end diff_tot, od.optimizer_detail_id, od.volume_used,od.up_down_stream
		INTO #tmp ---   select * from #tmp
		FROM optimizer_detail od 
			inner join #tmp_vol tv on od.transport_deal_id=tv.transport_deal_id and od.flow_date=tv.flow_date
				 --AND od.up_down_stream = 'U' 

		SELECT a.*,b.vol,a.diff_tot-b.vol rem,b.vol+a.diff_tot rem1
		INTO #tmp1 -- select * from #tmp1
		FROM #tmp a
		CROSS APPLY
		( SELECT sum(volume_used) vol
		   FROM #tmp 
		   WHERE rowid<=a.rowid and transport_deal_id=a.transport_deal_id and flow_date=a.flow_date
			and up_down_stream=a.up_down_stream
		) b

		UPDATE d 
			SET d.volume_used = tmp.volume_used+ABS(tmp.diff_tot) 
		FROM #tmp tmp 
			INNER JOIN optimizer_detail d ON d.optimizer_detail_id = tmp.optimizer_detail_id
		WHERE tmp.rowid=1 and tmp.diff_tot<0
		

		UPDATE d 
			SET d.volume_used = d.volume_used - CASE WHEN tmp1.rem<=0 THEN tmp1.volume_used+tmp1.rem ELSE tmp1.volume_used END
				--SET d.volume_used = CASE WHEN tmp1.rem<=0 THEN tmp1.volume_used+tmp1.rem ELSE tmp1.volume_used END
		FROM #tmp1 tmp1 
			INNER JOIN optimizer_detail d ON d.optimizer_detail_id = tmp1.optimizer_detail_id
		WHERE tmp1.vol-tmp1.volume_used<tmp1.diff_tot and tmp1.diff_tot>0


		update odd 
			set deal_volume=tgd.nom_del_vol
		from optimizer_detail_downstream odd
			inner join #temp_grid_data tgd on tgd.deal_id = odd.source_deal_header_id
				and tgd.term_start=odd.flow_date
		where isnull(tgd.nom_del_vol,0)<>0
			AND tgd.deal_type =3 -- downsteam


		if @@rowcount<1
		begin

			----------------------------------------------------------
			-- optimizer_detail_downstream
			--------------------------------
		--	return

		--select * from	#tmp_vol
		--select * from #tmp_dw
		--select * from #tmp1_dw

			--select * from optimizer_header where flow_date='2017-05-24'
	--select * from optimizer_detail where flow_date='2017-05-24' order by 3,4,5 desc
	--select * from  optimizer_detail_downstream  where flow_date='2017-05-24'


			SELECT row_number() OVER(partition by od.transport_deal_id,od.flow_date   ORDER BY od.optimizer_detail_downstream_id DESC) rowid,od.transport_deal_id,od.flow_date ,( tv.old_vol_dw - tv.new_vol_dw ) diff_tot, od.optimizer_detail_downstream_id, od.deal_volume volume_used
			INTO #tmp_dw ---   select * from #tmp_dw
			FROM optimizer_detail_downstream od 
				inner join #tmp_vol tv on od.transport_deal_id=tv.transport_deal_id and od.flow_date=tv.flow_date

			SELECT a.*,b.vol,a.diff_tot-b.vol rem,b.vol+a.diff_tot rem1
			INTO #tmp1_dw -- select * from #tmp1_dw
			FROM #tmp_dw a
			CROSS APPLY
			( 
				SELECT sum(volume_used) vol FROM #tmp_dw 
				WHERE rowid<=a.rowid and transport_deal_id=a.transport_deal_id 
					and flow_date=a.flow_date
			) b


			UPDATE d 
				SET d.deal_volume = tmp.volume_used+ABS(tmp.diff_tot) 
			FROM #tmp_dw tmp 
				INNER JOIN optimizer_detail_downstream d ON d.optimizer_detail_downstream_id = tmp.optimizer_detail_downstream_id
			WHERE tmp.rowid=1 and tmp.diff_tot<0
		

			UPDATE d 
				SET d.deal_volume = d.deal_volume - CASE WHEN tmp1.rem<=0 THEN tmp1.volume_used+tmp1.rem ELSE tmp1.volume_used END
	
		--select * from	#tmp_vol
		--select * from #tmp_dw
		--select * from #tmp1_dw

			FROM #tmp1_dw tmp1 
				INNER JOIN optimizer_detail_downstream d ON d.optimizer_detail_downstream_id = tmp1.optimizer_detail_downstream_id
			WHERE tmp1.vol-tmp1.volume_used<tmp1.diff_tot and tmp1.diff_tot>0
		
		end


		--Logic to calculate position report for that updated deal.
		SET @user_login_id = dbo.FNADBUser()
		SET @report_position_process_id = dbo.FNAGetNewID()
		SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @report_position_process_id)
	
		EXEC ('CREATE TABLE ' + @report_position_deals + '(source_deal_header_id INT, action CHAR(1))')   
		EXEC('INSERT INTO ' + @report_position_deals + '(source_deal_header_id, action)
			SELECT deal_id, ''u'' FROM #temp_grid_data'
			)
		EXEC dbo.spa_update_deal_total_volume NULL, @report_position_process_id
		--END of Logic to calculate position report for that updated deal.

		EXEC spa_ErrorHandler 0, 
			'View Nom schedules', 
			'spa_schedules_view', 
			'Success', 
			'View Nom schedules successfully updated.', 
			''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler @@ERROR, 
			'View Nom schedules', 
			'spa_schedules_view', 
			'DB Error',
			'Failed to update View Nom schedule.', 
			'Failed Updating View Nom schedule'
	END CATCH
END
ELSE IF @flag = 'f'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

		SELECT	deal_id,
			flow_date_from,
			flow_date_to,
			apply_to,
			rec_vol,
			del_vol
		INTO #temp_apply_to_data			
		FROM   OPENXML (@idoc, '/Root/DataRow', 1)
				WITH ( 
					deal_id				VARCHAR(5000)	'@deal_id',						
					flow_date_from		VARCHAR(5000)	'@flow_date_from',
					flow_date_to		VARCHAR(5000)	'@flow_date_to',
				apply_to			VARCHAR(5000)	'@apply_to',
				rec_vol				VARCHAR(100)	'@rec_vol',
				del_vol				VARCHAR(100)	'@del_vol'
					)
		EXEC sp_xml_removedocument @idoc

		DECLARE @apply_to VARCHAR(100)
		SELECT @apply_to = MAX(apply_to) FROM #temp_apply_to_data

		SET @sql = '
		UPDATE sdd
			SET sdd.' + @apply_to + ' = IIF(sdd.buy_sell_flag = ''s'', tad.rec_vol, tad.del_vol)
		FROM #temp_apply_to_data tad
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = tad.deal_id
		WHERE sdd.term_start >= tad.flow_date_from AND sdd.term_start <= tad.flow_date_to
			'
		EXEC(@sql)

		--Logic to calculate position report for that updated deal.
		SET @user_login_id = dbo.FNADBUser()
		SET @report_position_process_id = dbo.FNAGetNewID()
		SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @report_position_process_id)
	
		EXEC ('CREATE TABLE ' + @report_position_deals + '(source_deal_header_id INT, action CHAR(1))')   
		EXEC('INSERT INTO ' + @report_position_deals + '(source_deal_header_id, action)
		SELECT deal_id, ''u'' FROM #temp_apply_to_data'
			)
		EXEC dbo.spa_update_deal_total_volume NULL, @report_position_process_id
		--END of Logic to calculate position report for that updated deal.

		EXEC spa_ErrorHandler 0, 
			'View Nom schedules', 
			'spa_schedules_view', 
			'Success', 
			'View Nom schedules successfully updated.', 
			''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler @@ERROR, 
			'View Nom schedules', 
			'spa_schedules_view', 
			'DB Error',
			'Failed to update View Nom schedule.', 
			'Failed Updating View Nom schedule'
	END CATCH
END
ELSE IF @flag = 'd' -- delete schedule deal
BEGIN
	IF OBJECT_ID('tempdb..#temp_deal_term') IS NOT NULL
		DROP TABLE #temp_deal_term

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml_data

	SELECT	deal_id,
			flow_date_from,
			NULLIF(flow_date_to, '') flow_date_to
	INTO #temp_deal_term			
	FROM   OPENXML (@idoc, '/Root/DataRow', 1)
	WITH ( 
		deal_id				VARCHAR(5000)	'@deal_id',						
		flow_date_from		VARCHAR(5000)	'@flow_date_from',
		flow_date_to		VARCHAR(5000)	'@flow_date_to'
	)
	EXEC sp_xml_removedocument @idoc
	
	BEGIN TRY
		BEGIN TRAN

		--DELETE rhpd 
		--FROM report_hourly_position_deal_main rhpd
		--LEFT JOIN #temp_deal_term tdt ON tdt.deal_id = rhpd.source_deal_header_id
		--WHERE rhpd.term_start BETWEEN tdt.flow_date_from AND ISNULL(tdt.flow_date_to, tdt.flow_date_from)
		
		DELETE odd
		FROM optimizer_detail_downstream odd
		LEFT JOIN #temp_deal_term tdt ON tdt.deal_id = odd.transport_deal_id
		WHERE odd.flow_date BETWEEN tdt.flow_date_from AND ISNULL(tdt.flow_date_to, tdt.flow_date_from)
		
		DELETE od
		FROM optimizer_detail od
		LEFT JOIN #temp_deal_term tdt ON tdt.deal_id = od.transport_deal_id
		WHERE od.flow_date BETWEEN tdt.flow_date_from AND ISNULL(tdt.flow_date_to, tdt.flow_date_from)
		
		DELETE oh
		FROM optimizer_header oh
		LEFT JOIN #temp_deal_term tdt ON tdt.deal_id = oh.transport_deal_id
		WHERE oh.flow_date BETWEEN tdt.flow_date_from AND ISNULL(tdt.flow_date_to, tdt.flow_date_from)
		
		DELETE udddf
        FROM source_deal_detail sdd
        LEFT JOIN #temp_deal_term tdt 
			ON tdt.deal_id = sdd.source_deal_header_id
        INNER JOIN user_defined_deal_detail_fields udddf
			ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
        WHERE sdd.term_start BETWEEN tdt.flow_date_from AND ISNULL(tdt.flow_date_to, tdt.flow_date_from)

		DELETE sdd
		FROM source_deal_detail sdd
		LEFT JOIN #temp_deal_term tdt ON tdt.deal_id = sdd.source_deal_header_id
		WHERE sdd.term_start BETWEEN tdt.flow_date_from AND ISNULL(tdt.flow_date_to, tdt.flow_date_from)
		
		COMMIT TRAN

		--Logic to calculate position report for that updated deal.
		SET @user_login_id = dbo.FNADBUser()
		SET @report_position_process_id = dbo.FNAGetNewID()
		SET @report_position_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @report_position_process_id)
	
		EXEC ('CREATE TABLE ' + @report_position_deals + '(source_deal_header_id INT, action CHAR(1))')   
		EXEC('INSERT INTO ' + @report_position_deals + '(source_deal_header_id, action)
		SELECT deal_id, ''u'' FROM #temp_deal_term'
			)

		-- delete data from position
		exec dbo.spa_maintain_transaction_job @report_position_process_id,7,null,@user_login_id

		--EXEC dbo.spa_update_deal_total_volume NULL, @report_position_process_id
		--END of Logic to calculate position report for that updated deal.

		EXEC spa_ErrorHandler 0, 
			'View Nom schedules', 
			'spa_schedules_view', 
			'Success', 
			'View Nom schedules successfully updated.', 
			''
	END TRY
	BEGIN CATCH
		IF @@ERROR <> 0
			ROLLBACK

		EXEC spa_ErrorHandler @@ERROR, 
			'View Nom schedules', 
			'spa_schedules_view', 
			'DB Error',
			'Failed to delete deal term.', 
			''
	END CATCH
END
GO