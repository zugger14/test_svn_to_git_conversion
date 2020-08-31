IF OBJECT_ID('spa_book_out') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_book_out]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Runaj Khatiwada>
-- Create date: <2016-10-18>
-- Description:	<Book Out Operation>

-- =============================================
/*
flags:
a - retreive values for header level grid
b - retreive values for buy detail grid
s - retreive values for sell detail grid
o - Process for bookout
i - exract info for buy AND sell detail before bookout
*/
CREATE PROCEDURE [dbo].[spa_book_out]
	@flag CHAR(1),
	@counterparty_id VARCHAR(1000) = NULL,
	@location_id INT = NULL,
	@term_start_date DATETIME = NULL,
	@term_end_date DATETIME = NULL,
	@process_id VARCHAR(40) = NULL,
	@commodity INT = NULL,
	@rec_vol NUMERIC(30,10) = NULL,
	@del_vol NUMERIC(30,10) = NULL,
	@contract INT = NULL,
	@buy_deal_id VARCHAR(2000) = NULL,
	@sell_deal_id VARCHAR(2000) = NULL,
	@as_of_date DATETIME = NULL,
	@call_from varchar(200) = NULL,
	@location_ids VARCHAR(1000) = NULL
AS

/***************************************************
	DECLARE @flag CHAR(1),
	@counterparty_id VARCHAR(1000) = NULL,
	@location_id INT = NULL,
	@term_start_date DATETIME = NULL,
	@term_end_date DATETIME = NULL,
	@process_id VARCHAR(40) = NULL,
	@commodity INT = NULL,
	@rec_vol NUMERIC(30,10) = NULL,
	@del_vol NUMERIC(30,10) = NULL,
	@contract INT = NULL,
	@buy_deal_id VARCHAR(2000) = NULL,
	@sell_deal_id VARCHAR(2000) = NULL,
	@as_of_date DATETIME = NULL,
	@call_from varchar(200) = NULL,
	@location_ids VARCHAR(1000) = NULL


--EXEC spa_book_out @flag='b',@counterparty_id='4260',@location_id='1352',@term_start_date='2016-09-01',@term_end_date='2016-09-30',@process_id='3C93D8AC_26C5_4EFB_8CF4_6955B5DDCA8F'
	
--EXEC spa_book_out @flag='s',@counterparty_id='4260',@location_id='1352',@term_start_date='2016-09-01',@term_end_date='2016-09-30',@process_id='3C93D8AC_26C5_4EFB_8CF4_6955B5DDCA8F'
	
--SET nocount off	
--DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
--SET CONTEXT_INFO @contextinfo

select @flag='a'
,@counterparty_id=''
,@location_ids='3128,3132,3131'
,@term_start_date='2019-11-11'
,@term_end_date='2019-11-11'
,@commodity=''
,@as_of_date='2019-11-11'
,@call_from='b2b'

--*************************************************/

BEGIN
	SET NOCOUNT ON

	--STORE HEADER DEAL DETAIL UDF FIELD VALUES START
	IF OBJECT_ID('tempdb..#deal_detail_udf') IS NOT NULL 
		DROP TABLE #deal_detail_udf
	SELECT distinct sdd.source_deal_detail_id,sdd.term_start, sdd.Leg, sdd.source_deal_header_id, uddft_pri.field_label, udddf.udf_value
	INTO #deal_detail_udf
	FROM  user_defined_deal_fields_template uddft_pri			
	LEFT JOIN user_defined_deal_detail_fields udddf
		ON uddft_pri.udf_template_id = udddf.udf_template_id	
	INNER JOIN source_deal_detail sdd 
		ON sdd.source_deal_detail_id = udddf.source_deal_detail_id
	WHERE uddft_pri.field_label IN ('priority') 
		AND uddft_pri.field_name IN	(309152) --AND udddf.source_deal_detail_id=376127--priority
		AND sdd.term_start >= @term_start_date
		AND sdd.term_end <= @term_end_date
	--STORE HEADER DEAL DETAIL UDF FIELD VALUES END

	DECLARE @sql_string VARCHAR(MAX)
	DECLARE @user_login_id VARCHAR(100) = dbo.FNADBUser()
	SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())

	DECLARE @bookout_detail_deals VARCHAR(1000) = dbo.FNAProcessTableName('bookout_detail_deals', @user_login_id, @process_id)
	DECLARE @contractwise_detail_mdq VARCHAR(1000) = dbo.FNAProcessTableName('contractwise_detail_mdq', @user_login_id, @process_id)
	DECLARE @opt_deal_detail_pos VARCHAR(1000) = dbo.FNAProcessTableName('opt_deal_detail_pos', @user_login_id, @process_id)
	DECLARE @buy_deal_info VARCHAR(1000) = dbo.FNAProcessTableName('buy_deal_info', @user_login_id, @process_id)
	DECLARE @sell_deal_info VARCHAR(1000) = dbo.FNAProcessTableName('sell_deal_info', @user_login_id, @process_id)
		
	

	IF @flag = 'a'
	BEGIN

		--IF OBJECT_ID('tempdb..#deal_term_breakdown') IS NOT NULL
		--	DROP TABLE #deal_term_breakdown

		--SELECT * 
		--	INTO #deal_term_breakdown --- SELECT * FROM #deal_term_breakdown
		--FROM 
		--(
		--	SELECT source_deal_detail_id, tm.term_start, tm.term_end
		--	FROM source_deal_detail dd
		--	CROSS APPLY [dbo].[FNATermBreakdown](deal_volume_frequency,dd.term_start ,dd.term_end) tm
		--	WHERE dd.deal_volume_frequency='d' 
		--		AND dd.term_start <> dd.term_end
		--		AND tm.term_start BETWEEN @term_start_date AND ISNULL(@term_end_date, @term_start_date)
		--	UNION ALL
		--	SELECT source_deal_detail_id, dd.term_start, dd.term_end
		--	FROM source_deal_detail dd
		--	WHERE dd.deal_volume_frequency = 'd' 
		--		AND dd.term_start = dd.term_end
		--		AND dd.term_start BETWEEN @term_start_date 
		--		AND ISNULL(@term_end_date,@term_start_date)
		--) a

		SET @sql_string = '
			IF OBJECT_ID(''' + @bookout_detail_deals + ''') IS NOT NULL
				DROP TABLE ' + @bookout_detail_deals + '
			
			SELECT 
				sml.Location_Name,
				' + iif(@call_from = 'b2b', 'NULL', 'sc.counterparty_name') + ' [counterparty_name],
				sdd.term_start term_start,
				sdd.term_end term_end,
				' + isnull(CAST(@rec_vol AS VARCHAR(2000)),'case when sdd.buy_sell_flag = ''b'' THEN sdd.deal_volume ELSE NULL END')+ ' buy_volume,
				' + isnull(CAST(@del_vol AS VARCHAR(2000)),'case when sdd.buy_sell_flag = ''s'' THEN sdd.deal_volume ELSE NULL END')+ ' sell_volume,
				' + iif(@call_from = 'b2b', 'NULL', 'sdh.counterparty_id') + ' [counterparty_id],
				sdd.location_id,
				sdh.source_deal_header_id,
				sdd.source_deal_detail_id,
				sdh.header_buy_sell_flag,
				sdd.buy_sell_flag detail_buy_sell_flag
				
			INTO ' + @bookout_detail_deals + '
			FROM source_deal_header sdh
			INNER JOIN source_deal_detail sdd
				ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN source_counterparty sc
				ON sc.source_counterparty_id = sdh.counterparty_id
			INNER JOIN source_minor_location sml
				ON sml.source_minor_location_id = sdd.location_id
			INNER JOIN source_deal_header_template sdht
				ON sdht.template_id = sdh.template_id
			WHERE sdd.term_start >= ''' + CONVERT(VARCHAR(10), @as_of_date, 21) + ''' AND sdht.template_name <> ''Transportation NG''
		'
		
		IF NULLIF(@counterparty_id, '') IS NOT NULL and @call_from <> 'b2b'
		BEGIN
			SET @sql_string = @sql_string + ' AND sdh.counterparty_id = ' + @counterparty_id 
		END
			
		IF NULLIF(@term_start_date, '') IS NOT NULL 
		BEGIN
			SET @sql_string = @sql_string + ' AND sdd.term_start >= ''' + CONVERT(VARCHAR(10), @term_start_date, 21) + ''''
		END

		IF NULLIF(@term_end_date, '') IS NOT NULL 
		BEGIN
			SET @sql_string = @sql_string + ' AND sdd.term_start <= ''' +CONVERT(VARCHAR(10), @term_end_date, 21) + ''''
		END	

		IF NULLIF(@location_id, '') IS NOT NULL
		BEGIN
			SET @sql_string = @sql_string + ' AND sdd.location_id = ' + CAST(@location_id AS VARCHAR(10))
		END

		IF NULLIF(@location_ids, '') IS NOT NULL
		BEGIN
			SET @sql_string = @sql_string + ' AND sdd.location_id IN (' + CAST(@location_ids AS VARCHAR(1000)) + ')'
		END

		IF NULLIF(@commodity, '') IS NOT NULL
		BEGIN
			SET @sql_string = @sql_string + ' AND sdh.commodity_id = ' + CAST(@commodity AS VARCHAR(10))
		END

		SET @sql_string = @sql_string + '
		
		SELECT
			dli.Location_Name,
			dli.counterparty_name,			
			MIN(dli.term_start) term_start,
			MAX(dli.term_end) term_end,
			CAST(SUM(dli.buy_volume) - ISNULL(MAX(buy_side.volume_used), 0) AS NUMERIC(10, 0)) buy_volume,
			CAST(SUM(dli.sell_volume) - ISNULL(MAX(sell_side.volume_used), 0) AS NUMERIC(10, 0)) sell_volume,
			
			''' + @process_id + ''' [process_id],
			dli.counterparty_id,
			dli.location_id
			--,MAX(buy_side.volume_used) [buy_volume_used]
			--,SUM(dli.buy_volume) - ISNULL(MAX(buy_side.volume_used), 0) [buy_volume_available]
			--,MAX(sell_side.volume_used) [sell_volume_used]
			--,SUM(dli.sell_volume) - ISNULL(MAX(sell_side.volume_used), 0) [sell_volume_available]
		FROM ' + @bookout_detail_deals + ' dli 
		outer apply (
			select sum(od.volume_used) volume_used
			from optimizer_detail od
			inner join source_deal_detail sdd on sdd.source_deal_header_id =  od.source_deal_header_id
				and sdd.term_start = od.flow_date
			where od.up_down_stream = ''u''
				and sdd.location_id = dli.location_id
				and od.flow_date = ''' + CONVERT(VARCHAR(10), @term_start_date, 21) + '''
			group by sdd.location_id
		) buy_side
		outer apply (
			select sum(odd.deal_volume) volume_used
			from optimizer_detail_downstream odd
			inner join source_deal_detail sdd on sdd.source_deal_header_id =  odd.source_deal_header_id
				and sdd.term_start = odd.flow_date
			where sdd.location_id = dli.location_id
				and odd.flow_date = ''' + CONVERT(VARCHAR(10), @term_start_date, 21) + '''
			group by sdd.location_id
		) sell_side
		GROUP BY
			dli.counterparty_id,
			dli.location_id,
			dli.counterparty_name,
			dli.Location_Name
		HAVING ISNULL(SUM(dli.buy_volume), 0) > 0 
			AND ISNULL(SUM(dli.sell_volume), 0) > 0
			AND ISNULL((SUM(dli.buy_volume) - ISNULL(MAX(buy_side.volume_used), 0)), 0) > 0
			AND ISNULL((SUM(dli.sell_volume) - ISNULL(MAX(sell_side.volume_used), 0)), 0) > 0
		
		'
		--EXEC spa_print @sql_string
		--print @sql_string
		EXEC(@sql_string)
		
	END
    ELSE IF @flag IN ('b','s')
	BEGIN
		IF OBJECT_ID('tempdb..#tmp_av_vol') IS NOT NULL
			DROP TABLE #tmp_av_vol

		CREATE TABLE #tmp_av_vol(available_vol NUMERIC(20,6))


		SET @sql_string = '
		SELECT 
			max(sc.counterparty_name) [counterparty_name],
			MIN(bdd.term_start) term_start,
			MAX(bdd.term_end) term_end,
			bdd.source_deal_header_id deal_id,
			MAX(cg.[contract_name]) [contract_name],
			 SUM(sdd.deal_volume * (DATEDIFF ( DAY , bdd.term_start , bdd.term_end ) + 1) - ABS(ISNULL(sch.sch_vol, 0))) deal_volume,
			--CONVERT(DECIMAL(18,0), MAX(sdd.deal_volume) - ISNULL(MAX(sch_deal.available_vol), 0)) available_vol,
			 MIN(sdd.deal_volume- ABS(ISNULL(sch_max.avail_vol, 0)))  available_vol,
			MAX(su.uom_name) [uom_name],
			MAX(sdh.description1) [nom_group],
			COALESCE(MAX(sdv_d_pr.code), MAX(sdh.description2), 168) [priority]
			
		FROM ' + @bookout_detail_deals + ' bdd		
		INNER JOIN source_deal_detail sdd 
			ON sdd.source_deal_detail_id = bdd.source_deal_detail_id
		INNER JOIN source_deal_header sdh 
			ON sdh.source_deal_header_id = sdd.source_deal_header_id	
		INNER JOIN source_counterparty sc
			ON sc.source_counterparty_id = sdh.counterparty_id
		INNER JOIN source_minor_location sml
			ON sml.source_minor_location_id = sdd.location_id
		LEFT JOIN #deal_detail_udf detail_udf 
			ON detail_udf.source_deal_detail_id = sdd.source_deal_detail_id
		LEFT JOIN static_data_value sdv_d_pr 
			ON CAST(sdv_d_pr.value_id AS VARCHAR(10)) = detail_udf.udf_value
		LEFT JOIN source_major_location major
			ON major.source_major_location_ID = sml.source_major_location_ID
		LEFT JOIN contract_group cg
			ON cg.contract_id = sdh.contract_id
		LEFT JOIN source_uom su
			ON su.source_uom_id = sdd.deal_volume_uom_id
		' + 

		CASE WHEN @flag = 'b' THEN
			'		
			OUTER APPLY (
				SELECT SUM(volume_used) sch_vol
				from optimizer_detail 
				WHERE source_deal_header_id  = bdd.source_deal_header_id
				AND flow_date BETWEEN bdd.term_start AND bdd.term_end
					and up_down_stream = ''u''
			) sch
			OUTER APPLY (
				--SELECT MAX(avail_vol) avail_vol
				--FROM (
					SELECT MAX(volume_used) avail_vol
					FROM optimizer_detail
					WHERE source_deal_header_id = bdd.source_deal_header_id
						AND flow_date BETWEEN bdd.term_start AND bdd.term_end
						AND up_down_stream = ''u''
					GROUP BY source_deal_detail_id
				--)a
			) sch_max
			' 
		ELSE
			'		
				OUTER APPLY (
				SELECT SUM(volume_used) sch_vol
					from(
					SELECT DISTINCT od.* 
					from optimizer_detail od
					INNER JOIN optimizer_detail_downstream oy
						ON od.optimizer_header_id = oy.optimizer_header_id
						and od.flow_date = oy.flow_date

					WHERE oy.source_deal_header_id  = bdd.source_deal_header_id
					AND od.flow_date BETWEEN bdd.term_start AND bdd.term_end
						and up_down_stream = ''d'') a
				) sch
				OUTER APPLY (
					--SELECT MAX(avail_vol)  avail_vol
					--FROM (
							SELECT MAX(oy.deal_volume) avail_vol
							FROM optimizer_detail od
							INNER JOIN optimizer_detail_downstream oy
								ON od.optimizer_header_id = oy.optimizer_header_id
								and od.flow_date = oy.flow_date

							WHERE oy.source_deal_header_id  = bdd.source_deal_header_id
							AND od.flow_date BETWEEN bdd.term_start AND bdd.term_end
								and up_down_stream = ''d''
							GROUP BY oy.source_deal_detail_id
						--) a
				) sch_max
			' 


		END 
			+
			'
		WHERE bdd.header_buy_sell_flag ='''+ @flag+'''
			AND sdd.term_start >= ''' + CONVERT(VARCHAR(10), @term_start_date, 21) + '''
			AND sdd.term_end <= ''' + CONVERT(VARCHAR(10), @term_end_date, 21) + '''
			' + isnull(' AND sdh.counterparty_id IN (' + nullif(@counterparty_id,'') + ')','') + '
			' + isnull('AND sdd.location_id = ' + nullif(CAST(@location_id AS VARCHAR(8)),''),'') + '
			--AND sdd.deal_volume > ISNULL(sch_deal.available_vol,0)
		GROUP BY bdd.source_deal_header_id
		--HAVING MAX(sdd.deal_volume) > ISNULL(MAX(sch_deal.available_vol),0)

		'
		EXEC(@sql_string)

	
	END
	ELSE IF @flag = 'o' --bookout
	BEGIN TRY
		BEGIN TRAN
		
		DECLARE @path_id INT 
		
		IF NOT EXISTS(
			SELECT 1 FROM delivery_path 
			WHERE from_location = @location_id 
				AND to_location = @location_id
				AND counterparty = @counterparty_id 
				AND contract = @contract
		)
		BEGIN
			DECLARE @form_xml VARCHAR(MAX) 
			DECLARE @label_location VARCHAR(200)
			

			SELECT @label_location = location_name 
			FROM source_minor_location
			WHERE source_minor_location_id = @location_id
		
			SET @form_xml = '<FormXML  groupPath="n" rateSchedule="" path_id="" CONTRACT="' + CAST(@contract AS VARCHAR(10)) + '" counterParty="' + CAST(@counterparty_id AS VARCHAR(10)) + '" priority="-31400" from_location="' + CAST(@location_id AS VARCHAR(10)) + '" label_from_location="' + @label_location + '" to_location="' + CAST(@location_id AS VARCHAR(10)) + '" label_to_location="' + @label_location + '" path_name="" path_code="" mdq="0" logical_name="" isactive="y" deal_link=""></FormXML>'
						
			EXEC spa_setup_delivery_path  @flag='i',@form_xml=@form_xml,@rate_schedule_xml='<GridGroup></GridGroup>',@fuel_loss_xml='<GridGroup></GridGroup>',@group_path_xml=NULL,@mdq_grid_xml='<GridGroup></GridGroup>',@is_confirm='0', @is_bookout = 1
			
			SELECT @path_id = path_id  
			FROM delivery_path 
			WHERE from_location = @location_id 
				AND to_location = @location_id
				AND counterparty = @counterparty_id 
				AND contract = @contract
					
		END
		ELSE 
		BEGIN
			SELECT @path_id = path_id  
			FROM delivery_path 
			WHERE from_location = @location_id 
				AND to_location = @location_id
				AND counterparty = @counterparty_id 
				AND contract = @contract
		END
		
		SET @sql_string = '
		DECLARE @buy_deals VARCHAR(5000)
		SELECT @buy_deals = STUFF(
			(SELECT '',''  + CAST(b.source_deal_header_id AS VARCHAR(8))
			FROM ' + @buy_deal_info + ' b
			FOR XML PATH(''''))
		, 1, 1, '''')

		DECLARE @sell_deals VARCHAR(5000)
		SELECT @sell_deals = STUFF(
			(SELECT '',''  + CAST(s.source_deal_header_id AS VARCHAR(8))
			FROM ' + @sell_deal_info + ' s
			FOR XML PATH(''''))
		, 1, 1, '''')

		UPDATE cdm
		SET cdm.received = ' + CAST(@rec_vol AS VARCHAR(50)) + '
			, cdm.delivered = ' + CAST(ISNULL(@del_vol, @rec_vol) AS VARCHAR(50)) + '
			
			, cdm.match_term_start = ''' + CONVERT(VARCHAR(10), @term_start_date, 21) + '''
			, cdm.match_term_end = ''' + CONVERT(VARCHAR(10), @term_end_date, 21) + '''
			, cdm.receipt_deals = '''' + @buy_deals + ''''
			, cdm.delivery_deals = '''' + @sell_deals + ''''
			, cdm.path_id = ' + CAST(@path_id AS VARCHAR(10)) 
			+ CASE WHEN NULLIF(@contract,'') IS NOT NULL THEN ', cdm.contract_id = ' + CAST(@contract AS VARCHAR(8)) ELSE '' END + '
		
		FROM ' + @contractwise_detail_mdq + ' cdm
		'
		EXEC(@sql_string)
		
		COMMIT
		EXEC spa_ErrorHandler 0, 'Book Out', 'spa_book_out', 'Success', 'Updated process table successly.', ''
		
	END TRY
	BEGIN CATCH
		ROLLBACK
		PRINT ERROR_MESSAGE()
		EXEC spa_ErrorHandler 1, 'Book Out', 'spa_book_out', 'Error', 'Failed to UPDATE process table.', ''
	END CATCH
	ELSE IF @flag = 'i' --extract AND store info for buy AND sell detail for bookout
	BEGIN
		SET @sql_string = '
		IF OBJECT_ID(''' + @buy_deal_info + ''') IS NOT NULL
		DROP TABLE ' + @buy_deal_info + '

		SELECT bdd.source_deal_header_id, bdd.source_deal_detail_id, bdd.term_start, bdd.term_end, bdd.buy_volume
		INTO ' + @buy_deal_info + '
		FROM ' + @bookout_detail_deals + ' bdd
		WHERE bdd.source_deal_header_id IN (' + @buy_deal_id + ')
		'
		EXEC(@sql_string)

		SET @sql_string = '
		IF OBJECT_ID(''' + @sell_deal_info + ''') IS NOT NULL
		DROP TABLE ' + @sell_deal_info + '

		SELECT bdd.source_deal_header_id, bdd.source_deal_detail_id, bdd.term_start, bdd.term_end, bdd.sell_volume
		INTO ' + @sell_deal_info + '
		FROM ' + @bookout_detail_deals + ' bdd
		WHERE bdd.source_deal_header_id IN (' + @sell_deal_id + ')

		SELECT min(u.term_start) term_start, max(u.term_end) term_end, CONVERT(decimal(18, 0), MIN(u.volume)) volume
		FROM (
			SELECT b.term_start, b.term_end, b.buy_volume volume
			FROM ' + @buy_deal_info + ' b
			UNION ALL
			SELECT s.term_start, s.term_end, s.sell_volume volume
			FROM ' + @sell_deal_info + ' s
		) u
		'
		EXEC(@sql_string)
		--print @buy_deal_info
		--print @sell_deal_info

	END
END
GO
