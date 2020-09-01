IF OBJECT_ID(N'[dbo].[spa_mdq_available]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_mdq_available
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
/**
	Contract volume MDQ related operations
	Parameters
	@flag : P - returns unpivoted data
			v - Returns unformatted data
	@contract_ids : Contract Ids
	@flow_date_start : Flow Date Start
	@flow_date_end : Flow Date End
	@uom_id : Uom Id
	@for_pivot : Flag for pivot call
	@pipeline : Pipeline cunterparty
	@path_ids : Path ids
*/
CREATE PROCEDURE [dbo].spa_mdq_available
    @flag CHAR(1),
	@contract_ids VARCHAR(MAX) = NULL,
	@flow_date_start DATETIME,
	@flow_date_end DATETIME,
	@uom_id INT = NULL,
	@for_pivot CHAR(1) = 'n',
	@pipeline VARCHAR(MAX) = NULL,
	@path_ids VARCHAR(MAX) = NULL
AS
SET NOCOUNT ON


/*	--EXEC  spa_mdq_available @flag='s',@contract_ids='9104,9108',@flow_date_start='2017-11-13',@flow_date_end='2017-11-30',@uom_id='6',@pipeline=''

EXEC dbo.spa_drop_all_temp_table

DECLARE @run_user VARBINARY(128) = CONVERT(VARBINARY(128), 'sligal')
SET CONTEXT_INFO @run_user

DECLARE @flag CHAR(1),
	@contract_ids VARCHAR(MAX) = NULL,
	@flow_date_start DATETIME,
	@flow_date_end DATETIME,
	@uom_id INT = '',
	@for_pivot CHAR(1) = 'n',
	@pipeline VARCHAR(MAX) = NULL,
	@path_ids VARCHAR(MAX) = NULL

--Sets session DB users 
	EXEC sys.sp_set_session_context @key = N'DB_USER', @value = 'dmanandhar'

	--Sets contextinfo to debug mode so that spa_print will prints data
	DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
	SET CONTEXT_INFO @contextinfo

	EXEC spa_print 'Use spa_print instead of PRINT statement in debug mode.'
		
	--Drops all temp tables created in this scope.
	EXEC [spa_drop_all_temp_table] 
	
	-- SPA parameter values
	SELECT @flag = 'h', @contract_ids = '', @flow_date_start = '2027-08-01', @flow_date_end = '2027-08-01', @uom_id = '', @pipeline = '', @path_ids = '159'

--*/

IF @pipeline <> ''
BEGIN
	IF @contract_ids = ''
	BEGIN
		SELECT @contract_ids = STUFF((SELECT DISTINCT ',' + CAST(ccrs.contract_id AS VARCHAR)
										FROM dbo.FNASplit(@pipeline, ',') a  
										INNER JOIN delivery_path dp On dp.counterParty = a.item
										--INNER JOIN contract_group cg ON cg.contract_id = cca.contract_id AND cg.contract_type_def_id = 38402 
										--	AND cg.contract_type = 'f'
										LEFT JOIN counterparty_contract_rate_schedule ccrs ON ccrs.path_id = dp.path_id 
										FOR XML PATH (''))
										, 1, 1, '')
	END
	ELSE
	BEGIN
		SELECT @contract_ids = STUFF((SELECT DISTINCT ',' + CAST(ccrs.contract_id AS VARCHAR)
										FROM dbo.FNASplit(@pipeline, ',') a   
										INNER JOIN delivery_path dp On dp.counterParty = a.item
										LEFT JOIN counterparty_contract_rate_schedule ccrs ON ccrs.path_id = dp.path_id
										INNER JOIN FNASplit(@contract_ids, ',') b ON ccrs.contract_id = b.item
										--INNER JOIN contract_group cg ON cg.contract_id = cca.contract_id 
										--	AND cg.contract_type_def_id = 38402 AND cg.contract_type = 'f'
										FOR XML PATH (''))
										, 1, 1, '')
	END
END

IF @pipeline = '' AND @contract_ids = ''
BEGIN 
	SELECT @contract_ids = STUFF((SELECT DISTINCT ',' + CAST(cca.contract_id AS VARCHAR)
										FROM counterparty_contract_address cca
										INNER JOIN contract_group cg ON cg.contract_id = cca.contract_id AND cg.contract_type_def_id = 38402 AND cg.contract_type = 'f'
										FOR XML PATH (''))
										, 1, 1, '')
END 

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
	IF OBJECT_ID('tempdb..#term_breakdown_org') IS NOT NULL
		DROP TABLE #term_breakdown_org

	SELECT a.day_date effective_date, b.item contract_id 
		INTO #term_breakdown_org
	FROM dbo.FNAGetDayWiseDate(@flow_date_start, @flow_date_end) a
	CROSS APPLY dbo.FNASplit(@contract_ids, ',') b

	IF OBJECT_ID('tempdb..#mdq_volume') IS NOT NULL
		DROP TABLE #mdq_volume

	IF OBJECT_ID('tempdb..#term_breakdown_par') IS NOT NULL
		DROP TABLE #term_breakdown_par

	IF OBJECT_ID('tempdb..#all_deal_coll') IS NOT NULL
		DROP TABLE #all_deal_coll

	IF OBJECT_ID('tempdb..#all_deal_coll') IS NOT NULL
		DROP TABLE #all_deal_coll

	IF OBJECT_ID('tempdb..#collect_delivery_path') IS NOT NULL
		DROP TABLE #collect_delivery_path

	SELECT a.day_date effective_date, b.item parent_id, cg.contract_id contract_id
		INTO #term_breakdown_par
	FROM dbo.FNAGetDayWiseDate(@flow_date_start, @flow_date_end) a
	CROSS APPLY dbo.FNASplit(@contract_ids, ',') b
	INNER JOIN contract_group cg ON b.item = cg.grouping_contract
		AND capacity_release = 'y'

	IF OBJECT_ID('tempdb..#quantity_conversion') IS NOT NULL
		DROP TABLE #quantity_conversion
	
	CREATE TABLE #quantity_conversion(from_source_uom_id INT, to_source_uom_id INT, conversion_factor NUMERIC(38,18))
	--quantity_conversion
	INSERT INTO #quantity_conversion
	SELECT from_source_uom_id,to_source_uom_id,  MAX(conversion_factor) conversion_factor
	FROM (SELECT from_source_uom_id,to_source_uom_id, conversion_factor
		FROM rec_volume_unit_conversion
		WHERE to_source_uom_id = @uom_id
		UNION ALL
		SELECT to_source_uom_id from_source_uom_id, from_source_uom_id to_source_uom_id,  1/conversion_factor conversion_factor
		FROM rec_volume_unit_conversion
		WHERE from_source_uom_id = @uom_id
	) a
	GROUP BY from_source_uom_id,to_source_uom_id
	
	CREATE TABLE #mdq_volume(contract_id INT
						, [contract_name] VARCHAR(MAX) COLLATE DATABASE_DEFAULT
						, [path] VARCHAR(MAX) COLLATE DATABASE_DEFAULT
						, effective_date DATETIME
						, total_mdq	NUMERIC(38, 18)			
						, release_mdq NUMERIC(38, 18)	
						, mdq_volume NUMERIC(38, 18)
						)
	--IF @contract_path = 'c'
	--BEGIN
		--collect by contract

		IF OBJECT_ID('tempdb..#tmp_mdq') IS NOT NULL
		DROP TABLE #tmp_mdq
	
		SELECT ISNULL(rs_mdq.org_contract_id,tb.contract_id) contract_id
				, ISNULL(rs_mdq.[contract_name],cg.[contract_name]) [contract_name]
				, NULL [path]
				, tb.effective_date
				, ISNULL(mdq.mdq, 0) total_mdq
				--, mdq.effective_date
				, COALESCE(parent.total_mdq,rs_mdq.mdq, 0) release_mdq
				, ISNULL(mdq.mdq, 0) - COALESCE(parent.total_mdq,rs_mdq.mdq, 0) mdq_volume
			INTO #tmp_mdq	
		FROM #term_breakdown_org tb
		OUTER APPLY(
			SELECT sdh_org.contract_id org_contract_id, cg_org.[contract_name], deal_volume mdq
			FROM source_deal_header sdh
			INNER JOIN contract_group cg ON cg.contract_id = sdh.contract_id AND cg.contract_id = tb.contract_id
				AND cg.capacity_release='y' 
				AND sdh.internal_deal_type_value_id = 11 
				AND sdh.close_reference_id IS NOT NULL
			INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id 
				AND sdht.template_name IN ('Capacity NG')				
			INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id AND sdd.leg=1
				AND tb.effective_date between sdd.term_start and sdd.term_end
			LEFT JOIN source_deal_header sdh_org ON sdh_org.source_deal_header_id  = sdh.close_reference_id
				AND sdh_org.internal_deal_type_value_id = sdh.internal_deal_type_value_id 
			LEFT JOIN contract_group cg_org ON cg_org.contract_id = sdh_org.contract_id	
			WHERE 1 = 1 
		)  rs_mdq	
		OUTER APPLY (SELECT TOP 1 tcm.mdq * ISNULL(qc.conversion_factor, 1) mdq, effective_date 
					FROM transportation_contract_mdq tcm 
					INNER JOIN contract_group cg ON cg.contract_id = tcm.contract_id
					LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = cg.rec_uom
					WHERE tcm.contract_id = tb.contract_id AND tcm.effective_date <= tb.effective_date
					AND cg.capacity_release = 'n'
					) mdq	
		LEFT JOIN (
			SELECT tb.contract_id, tb.parent_id parent_contract_id, tb.effective_date, mdq.mdq total_mdq 
			FROM #term_breakdown_par tb
			OUTER APPLY (SELECT TOP 1 tcm.mdq * ISNULL(qc.conversion_factor, 1) * case WHEN cg.capacity_release='y' THEN -1 ELSE 1 END mdq, effective_date 
						FROM transportation_contract_mdq tcm 
						INNER JOIN contract_group cg ON cg.contract_id = tcm.contract_id
						LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = cg.rec_uom
						WHERE tcm.contract_id = tb.contract_id AND tcm.effective_date <= tb.effective_date
						) mdq
		) parent
		ON tb.contract_id = parent.parent_contract_id AND tb.effective_date = parent.effective_date
		INNER JOIN contract_group cg On cg.contract_id = tb.contract_id
		ORDER BY ISNULL(rs_mdq.org_contract_id, tb.contract_id) 

		INSERT INTO #mdq_volume
		SELECT contract_id,[contract_name],[path],effective_date, SUM(total_mdq),SUM(release_mdq),SUM(mdq_volume) 
		FROM #tmp_mdq
		WHERE mdq_volume <> 0	
		GROUP BY contract_id,[contract_name],effective_date,[path]

		--select * from #tmp_mdq
		--select * from #mdq_volume
		--return

	--END
	--ELSE 
	--BEGIN
	--select * from #mdq_volume
	 
	SELECT dp.path_id, ccrs.[contract_id] contract_id, ISNULL(dp.mdq, dpm.mdq) mdq, dpm.effective_date, dp.groupPath
		INTO #new_data_coll
	FROM delivery_path dp
	LEFT JOIN counterparty_contract_rate_schedule ccrs ON ccrs.path_id = dp.path_id
	LEFT JOIN delivery_path_mdq dpm ON dpm.path_id = dp.path_id

		--collect by path
	INSERT INTO #mdq_volume(contract_id  
							, [contract_name] 
							, [path]   
							, effective_date  
							, total_mdq	 		
							, release_mdq  
							, mdq_volume  
							)
	SELECT 
		DISTINCT tdo.contract_id, cg.contract_name, mdq.path_id, tdo.effective_date, mdq.mdq, ISNULL(deal_volume, 0) capacity_release, mdq.mdq + ISNULL(deal_volume, 0) mdq_volume
		--*,  tdo.effective_date, dp.path_id  
	FROM #term_breakdown_org tdo
		INNER JOIN #new_data_coll dp ON dp.contract_id = tdo.contract_id
		INNER JOIN contract_group cg ON cg.contract_id = tdo.contract_id
		INNER JOIN (SELECT CASE WHEN cg.capacity_release ='y' THEN -1 ELSE 1 END * dpm.mdq * ISNULL(qc.conversion_factor, 1) mdq, dpm.effective_date, dp.path_id 
							FROM #new_data_coll dpm 
							INNER JOIN #term_breakdown_org tdo_inner ON tdo_inner.contract_id = dpm.contract_id
							INNER JOIN delivery_path dp ON dp.[contract] = dpm.contract_id
								AND dp.path_id = dpm.path_id
							INNER JOIN contract_group cg ON cg.contract_id = dpm.contract_id
							LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = cg.rec_uom
							WHERE dp.path_id = dpm.path_id 
								AND dp.groupPath = 'n'
							) mdq ON ISNULL(mdq.effective_date, tdo.effective_date) <= tdo.effective_date AND dp.path_id = mdq.path_id
		

		LEFT JOIN (
					SELECT udddf.udf_value path_id, sdd.term_start, CASE WHEN sdd.buy_sell_flag='s' THEN -1 ELSE 1 END * sdd.deal_volume deal_volume, dp.CONTRACT contract_id
					FROM source_deal_header_template sdht 
					INNER JOIN source_deal_header sdh ON sdh.template_id = sdht.template_id
					INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id AND sdd.Leg=1
					INNER JOIN user_defined_deal_fields udddf ON udddf.source_deal_header_id = sdh.source_deal_header_id
					INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
						AND udddf.udf_template_id = uddft.udf_template_id
					INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id AND udft.Field_label = 'Delivery Path' 
					INNER JOIN delivery_path dp ON dp.path_id=CAST(udddf.udf_value AS float)
					WHERE  sdht.template_name = 'Capacity NG' --AND sdh.source_deal_header_id=56975
		) cr ON cr.path_id = mdq.path_id
			AND CONVERT(VARCHAR(7),cr.term_start,120) = CONVERT(VARCHAR(7),tdo.effective_date,120)
			AND cr.contract_id = tdo.contract_id						
		WHERE 1 = 1
		 AND dp.groupPath = 'n' 
		--AND tdo.effective_date <= '2017-11-02'
	--END
 --return 

 --select * from #term_breakdown_org
 --select * from #mdq_volume
 --return 

	
	SELECT  udddf.udf_value path_id, udddf.source_deal_header_id 
		INTO #collect_delivery_path
	FROM user_defined_deal_fields udddf   
	INNER JOIN source_deal_header sdh ON udddf.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
		AND udddf.udf_template_id = uddft.udf_template_id
	INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
	WHERE  udft.Field_label = 'Delivery Path'
	
 
	--select sdh.source_deal_header_id
	--FROM source_deal_header sdh
	--INNER JOIN dbo.FNASplit(@contract_ids, ',') b On b.item = sdh.contract_id
	--INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
	--INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	--LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = sdd.deal_volume_uom_id
	--LEFT JOIN #collect_delivery_path cdp ON cdp.source_deal_header_id = sdh.source_deal_header_id
	--LEFT JOIN delivery_path dp ON ISNULL(dp.path_id, 1) = ISNULL(cdp.path_id, 1)  

	CREATE TABLE #all_deal_coll( contract_id INT
									, term_start	DATETIME
									, deal_volume	NUMERIC(38, 18)								
									--, path_id VARCHAR(MAX) COLLATE DATABASE_DEFAULT
									, path_id INT
									)
 
	INSERT INTO #all_deal_coll(contract_id, term_start, deal_volume, path_id)
	SELECT sdh.contract_id, sdd.term_start, SUM(sdd.deal_volume * ISNULL(qc.conversion_factor, 1)) deal_volume, dp.path_id path_id 
	FROM source_deal_header sdh
	INNER JOIN dbo.FNASplit(@contract_ids, ',') b On b.item = sdh.contract_id
	INNER JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN #quantity_conversion qc ON qc.from_source_uom_id = sdd.deal_volume_uom_id
	LEFT JOIN #collect_delivery_path cdp ON cdp.source_deal_header_id = sdh.source_deal_header_id
	LEFT JOIN delivery_path dp ON ISNULL(dp.path_id, 1) = ISNULL(cdp.path_id, 1)  
	WHERE 1 =1 
		AND template_name = 'Transportation NG'
		AND sdd.leg = 2
	GROUP BY sdh.contract_id, sdd.term_start, dp.path_id
  
  --select * from #all_deal_coll

  --return 

	IF OBJECT_ID('tempdb..#final_table') IS NOT NULL
		DROP TABLE #final_table

	IF OBJECT_ID('tempdb..#final_table1') IS NOT NULL
		DROP TABLE #final_table1

	IF OBJECT_ID('tempdb..#final_pvt_table_vol') IS NOT NULL
		DROP TABLE #final_pvt_table_vol

	IF OBJECT_ID('tempdb..#final_pvt_table_avai') IS NOT NULL
		DROP TABLE #final_pvt_table_avai

	SELECT DISTINCT [contract_name]
			, ISNULL(dp.path_name,CASE WHEN @for_pivot = 'n' THEN 'aa_contract_level' ELSE '' END) [path]
			, CONVERT(date, mdq.effective_date, 120) [effective_date]
			, CAST(mdq.mdq_volume AS NUMERIC(20,2)) [mdq_volume]
			, CAST(mdq.mdq_volume - ISNULL(used_vol.deal_volume, 0) AS NUMERIC(20,2)) [mdq_available]
			, dp.path_id [path_id]
	INTO #final_table -- select * from #final_table  select * from #mdq_volume  select * from #all_deal_coll order by 2
	FROM #mdq_volume mdq 
	OUTER APPLY (
		SELECT SUM(adc.deal_volume) [deal_volume]
		FROM #all_deal_coll adc 
		WHERE adc.contract_id = mdq.contract_id 
			AND adc.term_start = mdq.effective_date
			AND adc.path_id = isnull(mdq.[path], adc.path_id)
	) used_vol
	--LEFT JOIN #all_deal_coll adc ON adc.contract_id = mdq.contract_id 
	--	AND adc.term_start = mdq.effective_date
	LEFT JOIN delivery_path dp ON dp.path_id = mdq.[path]
	--ORDER BY mdq.contract_id, effective_date, dp.path_id


 


	IF @for_pivot = 'n'
	BEGIN
		DECLARE @pvt_select VARCHAR(MAX)
		DECLARE @pvt_include VARCHAR(MAX)
		--DECLARE @sql VARCHAR(MAX)
		SELECT @pvt_include = STUFF((SELECT DISTINCT ',' + '[' + CAST(effective_date AS VARCHAR) + ']'
										FROM #final_table ft
										FOR XML PATH (''))
										, 1, 1, '') 

		SELECT @pvt_select = STUFF((SELECT DISTINCT ',' + 'a.[' + CAST(effective_date AS VARCHAR) + '] AS [' + CAST(effective_date AS VARCHAR) + '::mdq_volume]' + 
										',b.[' + CAST(effective_date AS VARCHAR) + ']  AS [' + CAST(effective_date AS VARCHAR) + '::mdq_available]'
										FROM #final_table ft
										FOR XML PATH (''))
										, 1, 1, '') 
		
		SELECT [contract_name],[path],effective_date,mdq_volume,path_id 
		INTO #final_table1
		FROM #final_table

		SET @sql = 'SELECT DISTINCT contract_name,path,path_id,' + @pvt_include + '
		INTO #final_pvt_table_vol
		FROM #final_table1
		PIVOT(SUM(mdq_volume) 
			  FOR effective_date IN (' + @pvt_include + ')) AS PVTTable
		--WHERE [' + CAST(CONVERT(date,@flow_date_start,120) AS VARCHAR) + '] IS NOT NULL
		'


		SET @sql = @sql + '		
		UPDATE #final_table
		SET mdq_volume = 0
				
		SELECT contract_name,path,' + @pvt_include + '
		INTO #final_pvt_table_avai
		FROM #final_table
		PIVOT(SUM(mdq_available) 
			  FOR effective_date IN (' + @pvt_include + ')) AS PVTTable
		'
		--EXEC (@sql)

		SET @sql = @sql + '
		SELECT a.contract_name,
		CASE WHEN a.path = ''aa_contract_level'' THEN a.path ELSE ''<a href="#" onclick="open_nom_schedule_window(''''' + CAST(CONVERT(date,@flow_date_start,120) AS VARCHAR) + ''''',''''' + CAST(CONVERT(date,@flow_date_end,120) AS VARCHAR) + ''''','' + CAST(floc.source_minor_location_id AS VARCHAR) + '','' + CAST(tloc.source_minor_location_id AS VARCHAR) + '')">'' + a.path + ''</a>'' END [path],
		uom.uom_id uom,
		' + @pvt_select + '
		FROM #final_pvt_table_vol a
		INNER JOIN #final_pvt_table_avai b ON a.contract_name = b.contract_name AND a.path = b.path
		LEFT JOIN delivery_path dp ON dp.path_id = a.path_id
		LEFT JOIN source_minor_location floc ON floc.source_minor_location_id = dp.from_location
		LEFT JOIN source_minor_location tloc ON tloc.source_minor_location_id = dp.to_location
		LEFT JOIN contract_group cg ON cg.contract_name = a.contract_name
		LEFT JOIN source_uom uom ON uom.source_uom_id = ' + CASE WHEN ISNULL(@uom_id,0) = 0 THEN ' cg.volume_uom ' ELSE CAST(@uom_id AS VARCHAR(20)) END + '
		'
		EXEC spa_print @sql
		EXEC(@sql)
		
	END
	ELSE IF @for_pivot = 'y'
	BEGIN
		SELECT  [contract_name],
				[path],
				effective_date [Effective Date],
				mdq_volume [MDQ Volume],
				mdq_available [MDQ Available]
		FROM #final_table WHERE [path] <> '' AND [path] IS NOT NULL
	END

END
ELSE IF @flag IN( 'h' , 'v')
BEGIN
	DROP TABLE IF EXISTS #temp_path_list

	CREATE TABLE #temp_path_list(path_id INT)

	IF NULLIF(@path_ids, '') IS NOT NULL
	BEGIN
		INSERT INTO #temp_path_list(path_id)
		SELECT s.item FROM dbo.SplitCommaSeperatedValues(@path_ids) s
	END
	ELSE
	BEGIN
		INSERT INTO #temp_path_list(path_id)
		SELECT dp.path_id
		FROM dbo.SplitCommaSeperatedValues(@contract_ids) c
		INNER JOIN delivery_path dp ON dp.[contract] = c.item
	END

	SELECT mdq.term_start [effective_date], mdq.contract_id, mdq.path_id, dp.path_name, mdq.hour [hr], mdq.mdq [total_volume], mdq.rmdq [available_volume]
	INTO #final_total_available_mdq
	FROM #temp_path_list path_list
	INNER JOIN delivery_path dp ON dp.path_id = path_list.path_id
	CROSS APPLY (
		SELECT * FROM [dbo].[FNAGetPathMDQHourly] (dp.path_id, @flow_date_start, ISNULL(@flow_date_end, @flow_date_start), 'path_term_hour')
	) mdq



	SELECT @pvt_include = STUFF((SELECT DISTINCT ',' + '[' + CAST(hr AS VARCHAR) + ']'
									FROM #final_total_available_mdq ft
									FOR XML PATH (''))
									, 1, 1, '') 
	
	SELECT @pvt_select = STUFF((SELECT  ',' + 'a.[' + CAST(hr AS VARCHAR) + '] AS [' + CAST(CONVERT(DATE, effective_date, 120) AS VARCHAR) + '::'  + CAST(hr AS VARCHAR) + '::mdq_volume]' + 
									',b.[' + CAST(hr AS VARCHAR) + ']  AS [' + CAST(CONVERT(DATE, effective_date, 120) AS VARCHAR) + '::' + CAST(hr AS VARCHAR) + '::mdq_available]'
									FROM #final_total_available_mdq ft
									GROUP BY effective_date, hr
									FOR XML PATH (''))
									, 1, 1, '')
	IF @flag = 'v'
	BEGIN
		SELECT * FROM #final_total_available_mdq

		RETURN;
	END
	
	SET @sql = '
		SELECT path_id, ' + @pvt_include + ' 
		INTO #a
		FROM 
		(
			SELECT path_id, hr, total_volume from #final_total_available_mdq
		) t 
		PIVOT(
			MAX(total_volume)
			FOR hr IN (' + @pvt_include + ')
		) AS a

		SELECT path_id, ' + @pvt_include + ' 
		INTO #b
		FROM 
		(
			SELECT path_id, hr, available_volume from #final_total_available_mdq
		) t 
		PIVOT(
			MAX(available_volume)
			FOR hr IN (' + @pvt_include + ')
		) AS b
		
		SELECT cg.contract_name, ''<a href="#" onclick="open_nom_schedule_window(''''' + CAST(CONVERT(DATE, @flow_date_start, 120) AS VARCHAR) + ''''',''''' + CAST(CONVERT(DATE, @flow_date_end, 120) AS VARCHAR) + ''''','' + CAST(floc.source_minor_location_id AS VARCHAR) + '','' + CAST(tloc.source_minor_location_id AS VARCHAR) + '','' + CAST(dp.path_id AS VARCHAR) + '')">'' + dp.path_name + ''</a>'' [path], uom.uom_name [uom], ' + @pvt_select + '
		FROM #a a
		INNER JOIN #b b ON a.path_id = b.path_id
		INNER JOIN delivery_path dp ON dp.path_id = b.path_id
		INNER JOIN contract_group cg ON cg.contract_id = dp.[contract]
		LEFT JOIN source_minor_location floc ON floc.source_minor_location_id = dp.from_location
		LEFT JOIN source_minor_location tloc ON tloc.source_minor_location_id = dp.to_location
		LEFT JOIN source_uom uom ON uom.source_uom_id = CASE WHEN ISNULL(' + CAST(@uom_id AS VARCHAR(20)) + ', 0) = 0 THEN cg.volume_uom ELSE ' + CAST(@uom_id AS VARCHAR(20)) + '  END
	'

	EXEC(@sql)
END