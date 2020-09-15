IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_storage_position_report]') AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_storage_position_report]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/**
	Generates storage report for Report Manager
	Parameters:
	@sub_entity_id  		: subsidiary filter
	@strategy_entity_id  	: straregy filter
	@book_entity_id 		: book filter
	@commodity_id 			: commodity filter
	@curve_id  				: price curve filter 
	@contract_id 			: contract filter
	@location_id  			: location filter
	@term_start  			: term start filter
	@term_end  				: term end filter
	@uom  					: Conversion UOM
	@drill_location  		: grouping level by location
	@drill_term 			: group level by term
	@drill_type				: i=injection,w=withdraw 
	@drill_contract_id		: grouping level by contract
	@deal_type 				: deal type
	@call_from 				: call from flag
	@batch_process_id  		: batch unique id
	@batch_report_param 	: batch parameters
	@enable_paging  		: '1' = enable, '0' = disable
	@page_size  			: page size
	@page_no  				: page no
	@is_pivot  				: pivot flag
	@volume_conversion 		: volume conversion
	@counterparty_id		: counterparty flag
	@sub_book_id			: Sub book filter
**/
CREATE PROC [dbo].[spa_storage_position_report]
	@sub_entity_id VARCHAR(MAX) = NULL, 
	@strategy_entity_id VARCHAR(MAX) = NULL, 
	@book_entity_id VARCHAR(MAX) = NULL, 
	@commodity_id INT = NULL,
	@curve_id INT = NULL,
	@contract_id INT = NULL,
	@location_id VARCHAR(MAX) = NULL,
	@term_start DATE,
	@term_end DATE,
	@uom INT = NULL,
	@drill_location INT = NULL,
	@drill_term VARCHAR(20)= NULL,
	@drill_type VARCHAR(1)= NULL, ---i=injection,w=withdraw 
	@drill_contract_id INT = NULL, ---i=injection,w=withdraw
	@deal_type VARCHAR(MAX) = NULL,
	@call_from VARCHAR(50) = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL,
	@is_pivot char = NULL,
	@volume_conversion INT = NULL,
	@counterparty_id VARCHAR(5000) = NULL,
	@sub_book_id VARCHAR(MAX) = NULL
	
AS
SET NOCOUNT ON
/* 
  
	declare 
	@sub_entity_id VARCHAR(MAX) = NULL, 
	@strategy_entity_id VARCHAR(MAX) = NULL, 
	@book_entity_id VARCHAR(MAX) = NULL, 
	@commodity_id INT = NULL,
	@curve_id INT = NULL,
	@contract_id INT = NULL,
	@location_id VARCHAR(MAX) = NULL,
	@term_start DATE,
	@term_end DATE,
	@uom INT = NULL,
	@drill_location INT = NULL,
	@drill_term VARCHAR(20)= NULL,
	@drill_type VARCHAR(1)= NULL, ---i=injection,w=withdraw 
	@drill_contract_id INT = NULL, ---i=injection,w=withdraw
	@deal_type VARCHAR(MAX) = NULL,
	@call_from VARCHAR(50) = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL,
	@is_pivot char = NULL,
	@volume_conversion INT = NULL,
	@counterparty_id VARCHAR(5000) = NULL,
	@sub_book_id VARCHAR(MAX) = NULL

	/* for link reports within std report */
	--select @commodity_id=50, @drill_location=2794, @term_start='2018-07-01', @term_end='2018-07-31' ,@drill_term='2018-07-24',@drill_type='NULL',@drill_contract_id=10317,@deal_type='w'

	/* for main std report */
	select @commodity_id=NULL
	,@location_id='2892'
	,@term_start='2025-07-01'
	,@term_end='2025-07-01'
	,@uom=1158
	,@drill_location=null
	,@drill_term=null
	,@drill_contract_id=null
	,@deal_type=NULL
	,@call_from='Optimization'
	
	-- 2892, '2025-07-01', '2025-07-01',1158,NULL,NULL,NULL,NULL,NULL,'Optimization'
	--select @commodity_id=50,@location_id=2842,@term_start='2018-02-01', @term_end='2018-02-01',@uom=6,@call_from = 'Optimization'
	
	IF OBJECT_ID('tempdb..#books') IS NOT NULL
	DROP TABLE #books
	IF OBJECT_ID('tempdb..#temp') IS NOT NULL
	DROP TABLE #temp
	IF OBJECT_ID('tempdb..#tmp_rpt_data') IS NOT NULL
	DROP TABLE #tmp_rpt_data
	IF OBJECT_ID('tempdb..#tmp_rpt_data1') IS NOT NULL
	DROP TABLE #tmp_rpt_data1

	declare @s varbinary(128) = cast('debug_mode_on' as varbinary(128)) set context_info @s

   --*/

   --EXEC spa_storage_position_report NULL,NULL,NULL,50,NULL,NULL,'2842','2018-02-01','2018-02-01',6,2842,'2018-02-01','NULL',12434,NULL,NULL

  
/*******************************************1st Paging Batch START**********************************************/
 
DECLARE @str_batch_table VARCHAR(8000) 
DECLARE @user_login_id VARCHAR(50) 
DECLARE @sql_paging VARCHAR(8000)
 
DECLARE @is_batch BIT 
SET @str_batch_table = '' 
SET @user_login_id = dbo.FNADBUser()  
SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 
 
IF @is_batch = 1 
BEGIN 
	SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id) 
END
 
IF @enable_paging = 1 --paging processing 
BEGIN
 	IF @batch_process_id IS NULL 
	BEGIN 
		SET @batch_process_id = dbo.FNAGetNewID() 
		SET @str_batch_table = dbo.FNAPagingProcess ('p', @batch_process_id, @page_size, @page_no) 
	END 
	--retrieve data FROM paging table instead of main table
 
	IF @page_no IS NOT NULL  
	BEGIN 
		SET @sql_paging = dbo.FNAPagingProcess ('s', @batch_process_id, @page_size, @page_no)  
		
		EXEC (@sql_paging) 		
		RETURN  
	END
 
END
 
/*******************************************1st Paging Batch END**********************************************/

DECLARE @spa VARCHAR(MAX), 
		@font_tag_start VARCHAR(1000), 
		@font_tag_end VARCHAR(1000)
DECLARE @fields VARCHAR(1000)

SET @font_tag_start = '<font color=#0000ff><b><i>'
SET @font_tag_end = '</b></i></font>'

--DECLARE @INTernal_deal_subtype_value_id VARCHAR(30)
--SET @INTernal_deal_subtype_value_id='Transportation'

SET @spa = 'EXEC spa_storage_position_report '
    + CASE WHEN @sub_entity_id IS NULL THEN 'NULL' ELSE '''' + @sub_entity_id + '''' END + ',' 
    + CASE WHEN @strategy_entity_id IS NULL THEN 'NULL' ELSE '''' + @strategy_entity_id + '''' END + ',' 
    + CASE WHEN @book_entity_id IS NULL THEN 'NULL' ELSE '''' + @book_entity_id + '''' END + ','
    + CASE WHEN @commodity_id IS NULL THEN 'NULL' ELSE CAST(@commodity_id AS VARCHAR(30)) END + ',' 
    + CASE WHEN @curve_id IS NULL THEN 'NULL' ELSE CAST(@curve_id AS VARCHAR(30)) END + ',' 
    + CASE WHEN @contract_id IS NULL THEN 'NULL' ELSE CAST(@contract_id AS VARCHAR(30)) END + ',' 
    + CASE WHEN @location_id IS NULL THEN 'NULL' ELSE '''' + @location_id + '''' END + ',' 
    --+ CASE WHEN @term_start IS NULL THEN 'NULL' ELSE '''' + CONVERT(VARCHAR(10), @term_start, 120) + '''' END + ',' 
	+ CASE WHEN @term_start IS NULL THEN 'NULL' WHEN @call_from = 'optimization' THEN '''<#TERM_START#>''' ELSE '''' + CONVERT(VARCHAR(10), @term_start, 120) + '''' END + ',' 
    + CASE WHEN @term_end IS NULL THEN 'NULL' WHEN @call_from='optimization' THEN '''<#TERM_END#>''' ELSE '''' + CONVERT(VARCHAR(10), @term_end, 120) + '''' END + ',' 
    + CASE WHEN @uom IS NULL THEN 'NULL' ELSE  CAST(@uom AS VARCHAR(30)) END + ','

	
BEGIN
	---###########Declare Variables
	DECLARE @Sql_SELECT VARCHAR(8000)
	DECLARE @location_group VARCHAR(30)
			--,@exclude_INT_deal_sub_types VARCHAR(30)
			,@deal_type_storage VARCHAR(30)	
			--,@include_deal_sub_types VARCHAR(30)
			,@location_group_id INT

	--set @volume_conversion if @uom is passed
	set @volume_conversion = coalesce(@volume_conversion,@uom)

	SET @location_group	= 'Storage'


	SELECT @location_group_id = source_major_location_id  
	FROM source_major_location 
	WHERE location_name = 'storage'
	
	SELECT @deal_type_storage = d.source_deal_type_id 
	FROM source_deal_type d 
	WHERE d.source_deal_type_name = 'Storage'

	DECLARE @template_id_transportation_ng INT
	SELECT @template_id_transportation_ng = template_id 
	FROM source_deal_header_template  
	WHERE template_name = 'Transportation NG'

	DECLARE @deal_template_excludes varchar(1000)
	SELECT @deal_template_excludes = STUFF(
		(SELECT ','  + cast(template_id AS varchar)
		FROM source_deal_header_template 
		WHERE template_name in ('Transportation NG','Actual Storage Inventory','Forward Storage Inventory') --add here to exclude deal templates
		FOR XML PATH(''))
	, 1, 1, '')

	DECLARE @deal_template_includes varchar(1000)
	SELECT @deal_template_includes = STUFF(
		(SELECT ','  + cast(template_id AS varchar)
		FROM source_deal_header_template 
		WHERE template_name in ('Actual Storage Inventory','Forward Storage Inventory') --add here to include deal templates
		FOR XML PATH(''))
	, 1, 1, '')

	DECLARE @imb_actualization VARCHAR(200)
	SELECT @imb_actualization = STUFF(
		(SELECT ','  + cast(template_id AS varchar)
		FROM source_deal_header_template 
		WHERE template_name in ('Imb Actualization') --add here to include for no storage i.e. imbalance
		FOR XML PATH(''))
	, 1, 1, '')
	
	DECLARE @block_define_id_base_load INT
	SELECT @block_define_id_base_load = value_id 
	FROM static_data_value  
	WHERE code = 'Base Load'

	DECLARE @storage_inj_template_id VARCHAR(200), @storage_with_template_id VARCHAR(200)

	SELECT @storage_inj_template_id = template_id
	FROM source_deal_header_template 
	WHERE template_name = 'Storage Injection'

	SELECT @storage_with_template_id = template_id
	FROM source_deal_header_template 
	WHERE template_name = 'Storage Withdrawal'

	
	--####### create temporary tables for SELECTed hierarchy
	CREATE TABLE #books (fas_book_id INT) 

	SET @Sql_SELECT =        
		'INSERT INTO  #books
		 SELECT distinct 
					book.entity_id fas_book_id 
		 FROM portfolio_hierarchy book (nolock)
		INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id           
		LEFT OUTER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id
		 WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) 
		'   
		+ CASE WHEN @sub_entity_id IS NOT NULL THEN ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') ' ELSE '' END
		+ CASE WHEN @strategy_entity_id IS NOT NULL THEN ' AND stra.entity_id IN  ( ' + @strategy_entity_id + ') ' ELSE '' END
		+ CASE WHEN @book_entity_id IS NOT NULL THEN ' AND book.entity_id IN  ( ' + @book_entity_id + ') ' ELSE '' END
		+ CASE WHEN @sub_book_id IS NOT NULL THEN ' AND ssbm.book_deal_type_map_id IN  ( ' + @sub_book_id + ') ' ELSE '' END

	EXEC(@Sql_SELECT)

	----######## Get the require output
	--PRIOR BALANCE
	--print 'temp1 start: ' + convert(VARCHAR(50),getdate() ,21)
	CREATE TABLE #temp (
		counterparty_id VARCHAR(250) COLLATE DATABASE_DEFAULT,
		location_id INT,
		curve_id INT,
		[Counterparty] VARCHAR(250) COLLATE DATABASE_DEFAULT,
		[Location]  VARCHAR(250) COLLATE DATABASE_DEFAULT,
		[Index]  VARCHAR(250) COLLATE DATABASE_DEFAULT,
		[Date] DATETIME,
		[Injection] FLOAT,
		[Withdrawal] FLOAT,
		[Daily Average Balance] FLOAT,
		[UOM]  VARCHAR(250) COLLATE DATABASE_DEFAULT,
		source_deal_header_id INT,
		contract_id INT,	
		[contract_name] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[Injection_amt] FLOAT,
		[Withdrawal_amt] FLOAT,
		row_id INT IDENTITY(1, 1)	
		,fixed_price 	FLOAT 
		,conversion_factor FLOAT
	)
	--internal_deal_type_value_id
	SET @Sql_SELECT='
	INSERT INTO #temp (
		counterparty_id,
		sdd.location_id,
		sdd.curve_id,
		[Counterparty],
		[Location],
		[Index],
		[Date],
		[Injection],
		[Withdrawal],
		[Daily Average Balance],
		[UOM] ' + CASE WHEN @drill_location IS NULL THEN '' ELSE ', source_deal_header_id' END + ',
		contract_id,
		contract_name,
		[Injection_amt],
		[Withdrawal_amt]
		,conversion_factor
	)
	SELECT
			MAX(sc.counterparty_id) counterparty_id,
			sdd.location_id,
			MAX(sdd.curve_id) curve_id,
			MAX(sc.counterparty_name) [Counterparty],
			ml.location_name [Location],
			MAX(spcd.curve_name) [Index],
			''1900-01-01'' AS [Date],
			SUM(CASE 
					WHEN ((buy_sell_flag=''b'' and isnull(gaivs.injection_as_long,''n'') = ''y'') or (buy_sell_flag=''s'' and isnull(gaivs.injection_as_long,''n'') = ''n'')) 
						THEN (IIF(sdh.internal_desk_id = 17302, sddh.[hourly_vol], sdd.deal_volume) * 
							CASE  
								WHEN sdd.deal_volume_frequency = ''h'' AND sdh.internal_desk_id <> 17302 THEN hbt.volume_mult 
								WHEN sdd.deal_volume_frequency = ''m'' AND sdh.internal_desk_id <> 17302 THEN 1.0/DAY(EOMONTH(sdd.term_start)) 
								ELSE 1 
							END
							) 
					ELSE 0 
				END) AS [Injection],
			SUM(CASE 
					WHEN ((buy_sell_flag=''b'' and isnull(gaivs.injection_as_long,''n'') = ''n'') or (buy_sell_flag=''s'' and isnull(gaivs.injection_as_long,''n'') = ''y'')) 
						THEN (IIF(sdh.internal_desk_id = 17302, sddh.[hourly_vol], sdd.deal_volume) * 
							CASE  
								WHEN sdd.deal_volume_frequency = ''h'' AND sdh.internal_desk_id <> 17302 THEN hbt.volume_mult 
								WHEN sdd.deal_volume_frequency = ''m'' AND sdh.internal_desk_id <> 17302 THEN 1.0/DAY(EOMONTH(sdd.term_start)) 
								ELSE 1 
							END
							) 
					ELSE 0 
				END) AS [Withdrawal],
			SUM(CASE WHEN buy_sell_flag = ''b'' THEN -1 ELSE 1 END * ISNULL(actual_volume, deal_volume)) AS [Daily Average Balance],
			MAX(su.uom_name) [UOM] ' + CASE WHEN @drill_location IS NULL THEN '' ELSE ', sdh.source_deal_header_id' END	+ ',
			MAX(sdh.contract_id) contract_id,ISNULL(cg.contract_name,''''),
			SUM(CASE WHEN sdd.buy_sell_flag = ''s'' THEN sds.SETtlement_amount ELSE 0 END) [Injection_amt],
			SUM(CASE WHEN sdd.buy_sell_flag = ''b'' THEN sds.SETtlement_amount ELSE 0 END) [Withdrawal_amt]
			,' + IIF(@volume_conversion IS NULL,'1','max(ISNULL(rvuc.conversion_factor, 1))') + ' conversion_factor
	FROM #books b 
	INNER JOIN source_system_book_map ssbm 
		ON ssbm.fas_book_id = b.fas_book_id
	INNER JOIN source_deal_header sdh 
		ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
		AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
		AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
		AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
	INNER JOIN source_deal_detail sdd 
		ON sdd.source_deal_header_id=sdh.source_deal_header_id
	INNER JOIN source_counterparty sc 
		ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN source_minor_location ml 
		ON ml.source_minor_location_id=sdd.location_id
		--AND ml.source_major_location_id = ' + CAST(@location_group_id AS VARCHAR(10)) + '
	LEFT JOIN general_assest_info_virtual_storage gaivs on gaivs.storage_location = sdd.location_id
		and gaivs.agreement = sdh.contract_id 
		and gaivs.source_counterparty_id = sdh.counterparty_id
	OUTER APPLY
	( SELECT MAX(as_of_date) as_of_date FROM source_deal_settlement WHERE source_deal_header_id=sdh.source_deal_header_id 
		AND term_start=sdd.term_start AND leg=sdd.leg ) mx
	LEFT JOIN   source_deal_settlement sds ON sds.source_deal_header_id=sdh.source_deal_header_id 
		AND sds.term_start=sdd.term_start AND sds.leg=sdd.leg	AND sds.as_of_date=mx.as_of_date
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=sdd.curve_id
	LEFT JOIN source_uom su ON su.source_uom_id=sdd.deal_volume_uom_id
	LEFT JOIN contract_group  cg ON cg.contract_id=sdh.contract_id
	outer apply (
		select tb.term_start
		--from dbo.FNATermBreakdown(''d'', sdd.term_start, dbo.FNAGetFirstLastDayOfMonth(sdd.term_start,''l'')) tb
		from dbo.FNATermBreakdown(''d'', sdd.term_start, sdd.term_end) tb
		where sdh.term_frequency = ''m''
	) term_bk
	inner join dbo.vwDealTimezone tz on sdd.source_deal_header_id=tz.source_deal_header_id
		and tz.curve_id=isnull(sdd.curve_id,-1)  and tz.location_id=isnull(sdd.location_id,-1)
	left join hour_block_term hbt with (nolock) on hbt.term_date = isnull(term_bk.term_start,sdd.term_start)
		AND hbt.block_define_id = COALESCE(spcd.block_define_id, sdh.block_define_id, ' + cast(@block_define_id_base_load as varchar(10)) + ')
		and hbt.dst_group_value_id = tz.dst_group_value_id
	LEFT JOIN rec_volume_unit_conversion rvuc 
		ON rvuc.to_source_uom_id = ' + IIF(@volume_conversion IS NULL,'rvuc.to_source_uom_id',CAST(@volume_conversion AS VARCHAR(10))) + ' AND rvuc.from_source_uom_id = sdd.deal_volume_uom_id
	OUTER APPLY (
		SELECT SUM(sddh1.volume) [hourly_vol]
		FROM source_deal_detail_hour sddh1 
		WHERE sddh1.source_deal_detail_id = sdd.source_deal_detail_id
	) sddh
	'
	SET @Sql_SELECT += CASE WHEN NULLIF(@counterparty_id,'') IS NOT NULL THEN '
			INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') tc
				ON tc.item = sdh.counterparty_id
			' ELSE ' ' END 				
	SET @Sql_SELECT += 'WHERE 1=1 '
		+ ' AND ISNULL(term_bk.term_start, sdd.term_start) < ''' + CAST(@term_start AS VARCHAR(30)) + ''''	
		+ ' AND sdh.template_id = CASE WHEN ml.source_major_location_id = ' + CAST(@location_group_id AS VARCHAR(10)) + ' THEN sdh.template_id ELSE ' + ISNULL(@imb_actualization, '-1') + ' END'
		+ case @deal_type 
			when 'a' then ' AND sdh.template_id IN ( ' + @deal_template_includes + ')' --term link report, storage inventory deals
			when 'i' then ' AND ((buy_sell_flag=''b'' and isnull(gaivs.injection_as_long,''y'') = ''y'') or (buy_sell_flag=''s'' and isnull(gaivs.injection_as_long,''n'') = ''n''))'
				+ ' AND sdh.template_id = ' + @storage_inj_template_id --injection volume link report, injection deals
			when 'W' then ' AND ((buy_sell_flag=''b'' and isnull(gaivs.injection_as_long,''n'') = ''n'') or (buy_sell_flag=''s'' and isnull(gaivs.injection_as_long,''y'') = ''y''))'
				+ ' AND sdh.template_id = ' + @storage_with_template_id --withdrawal volume link report, withdrawal deals
			else ' AND sdh.template_id NOT IN ( ' + @deal_template_excludes + ')' 
		  end + 
		+ CASE WHEN @commodity_id IS NOT NULL THEN ' AND spcd.commodity_id=' + CAST(@commodity_id AS VARCHAR(30)) ELSE '' END
		+ CASE WHEN @curve_id IS NOT NULL THEN ' AND sdd.curve_id=' + CAST(@curve_id AS VARCHAR(30)) ELSE '' END
		+ CASE WHEN @contract_id IS NOT NULL THEN ' AND sdh.contract_id=' + CAST(@contract_id AS VARCHAR(30)) ELSE '' END
		--+ CASE WHEN @location_id IS NOT NULL THEN ' AND ((sdd.location_id IN (' + @location_id + ') AND ml.source_major_location_id = ' + CAST(@location_group_id AS VARCHAR(10)) + '))' ELSE '' END
		+ CASE WHEN @location_id IS NOT NULL THEN '
			AND (
				sdd.location_id IN (' + @location_id + ')' + 
				IIF(@call_from = 'STORAGE_GRID'
					, ' OR sdh.template_id = ' + ISNULL(@imb_actualization, '-1')
					, ' AND ml.source_major_location_id = ' + CAST(@location_group_id AS VARCHAR(10))
				) 
			+ ')' ELSE '' 
		END
		+ CASE WHEN ISNULL(@drill_location,'') <>'' THEN ' AND sdh.contract_id' 
		+ CASE WHEN ISNULL(@drill_contract_id, '') = '' THEN ' IS NULL ' ELSE '=' + CAST(@drill_contract_id AS VARCHAR(30)) END ELSE '' END		
		+ ' AND isnull(sdh.source_deal_type_id, -1) = iif(isnull(nullif(gaivs.include_non_standard_deals, ''''), ''n'') = ''n'',' + @deal_type_storage + ', isnull(sdh.source_deal_type_id, -1))'

		+ ' GROUP BY ml.location_name,ISNULL(cg.contract_name,'''') ,sdd.location_id' 
		+ CASE WHEN @drill_location IS NULL THEN '' ELSE ', sdh.source_deal_header_id' END
	
	exec spa_print @Sql_SELECT
	EXEC(@Sql_SELECT)


	--print 'temp1 end: ' + convert(VARCHAR(50),getdate() ,21)
	

	--CURRENT PERIOD								  
	SET @Sql_SELECT='
	INSERT INTO #temp (
		counterparty_id,
		sdd.location_id,
		sdd.curve_id,
		[Counterparty],
		[Location],
		[Index],
		[Date],
		[Injection],
		[Withdrawal],
		[Daily Average Balance], 
		[UOM] ' + CASE WHEN @drill_location IS NULL THEN '' ELSE ',
		source_deal_header_id' END + ',
		contract_id,
		contract_name,
		[Injection_amt],
		[Withdrawal_amt],fixed_price
		,conversion_factor
	)
	SELECT
		MAX(sc.counterparty_id) counterparty_id,
		sdd.location_id,
		MAX(sdd.curve_id) curve_id,
		MAX(sc.counterparty_name) [Counterparty],
		ml.location_name [Location],
		MAX(spcd.curve_name) [Index],
		isnull(term_bk.term_start,sdd.term_start) AS [Date],
		SUM(CASE 
				WHEN ((buy_sell_flag=''b'' and isnull(gaivs.injection_as_long,''n'') = ''y'') or (buy_sell_flag=''s'' and isnull(gaivs.injection_as_long,''n'') = ''n'')) 
					THEN (
						IIF((sdd.term_start = term_bk.term_start OR sdh.term_frequency = ''m'')
							,IIF(sdh.internal_desk_id = 17302, sddh.[hourly_vol], sdd.deal_volume)
							,0) * 
						CASE  
							WHEN sdd.deal_volume_frequency = ''h'' AND sdh.internal_desk_id <> 17302 THEN hbt.volume_mult 
							WHEN sdd.deal_volume_frequency = ''m'' AND sdh.internal_desk_id <> 17302 THEN 1.0/DAY(EOMONTH(sdd.term_start)) 
							ELSE 1 
						END
						) 
				ELSE 0 
			END) AS [Injection],
		SUM(CASE 
				WHEN ((buy_sell_flag=''b'' and isnull(gaivs.injection_as_long,''n'') = ''n'') or (buy_sell_flag=''s'' and isnull(gaivs.injection_as_long,''n'') = ''y'')) 
					THEN (
						IIF((sdd.term_start = term_bk.term_start OR sdh.term_frequency = ''m'')
							,IIF(sdh.internal_desk_id = 17302, sddh.[hourly_vol], sdd.deal_volume)
							,0) * 
						CASE  
							WHEN sdd.deal_volume_frequency = ''h'' AND sdh.internal_desk_id <> 17302 THEN hbt.volume_mult 
							WHEN sdd.deal_volume_frequency = ''m'' AND sdh.internal_desk_id <> 17302 THEN 1.0/DAY(EOMONTH(sdd.term_start)) 
							ELSE 1 
						END
						) 
				ELSE 0 
			END) AS [Withdrawal],
		--' + CASE WHEN @drill_location IS NULL THEN 'NULL' ELSE 'MAX(CASE WHEN buy_sell_flag=''b'' THEN -1 ELSE 1 END * coalesce(sdd.ending_balance,actual_volume, total_volume,sdd.deal_volume))' END + ' [Daily Average Balance],
		NULL [Daily Average Balance],
		MAX(su.uom_name) [UOM]  ' + CASE WHEN @drill_location IS NULL THEN '' ELSE ',sdh.source_deal_header_id' END + ',
		MAX(sdh.contract_id) contract_id, 
		ISNULL(cg.contract_name,''''), 
		SUM(CASE WHEN sdd.buy_sell_flag=''s'' THEN sds.SETtlement_amount ELSE 0 END) [Injection_amt],
		SUM(CASE WHEN sdd.buy_sell_flag=''b'' THEN sds.SETtlement_amount ELSE 0 END) [Withdrawal_amt],
		MAX(sdd.fixed_price) deal_price	
		--,MAX(sdh.internal_deal_subtype_value_id)
		,' + IIF(@volume_conversion IS NULL,'1','max(ISNULL(rvuc.conversion_factor, 1))') + ' conversion_factor
	FROM #books b 
	INNER JOIN source_system_book_map ssbm 
		ON ssbm.fas_book_id = b.fas_book_id
	INNER JOIN source_deal_header sdh 
		ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
		AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
		AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
		AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	INNER JOIN source_minor_location ml ON ml.source_minor_location_id = sdd.location_id
		--AND ml.source_major_location_id = ' + CAST(@location_group_id AS VARCHAR(10)) + '
	inner join source_deal_header_template sdht on sdht.template_id = sdh.template_id
	LEFT JOIN general_assest_info_virtual_storage gaivs on gaivs.storage_location = sdd.location_id
		and gaivs.agreement = sdh.contract_id and gaivs.source_counterparty_id = sdh.counterparty_id
	OUTER APPLY( 
		SELECT MAX(as_of_date) as_of_date 
		FROM source_deal_settlement 
		WHERE source_deal_header_id = sdh.source_deal_header_id 
			AND term_start = sdd.term_start 
			AND leg = sdd.leg
	) mx
	LEFT JOIN source_deal_settlement sds ON sds.source_deal_header_id = sdh.source_deal_header_id 
		AND sds.term_start = sdd.term_start 
		AND sds.leg = sdd.leg	
		AND sds.as_of_date = mx.as_of_date		
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id
	LEFT JOIN source_uom su	ON su.source_uom_id = ISNULL(sdd.position_uom, sdd.deal_volume_uom_id)
	LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
	outer apply (
		select tb.term_start
		from dbo.FNATermBreakdown(''d'', iif(sdd.term_start>= ''' + CAST(@term_start AS VARCHAR(30)) + ''', sdd.term_start, ''' + CAST(@term_start AS VARCHAR(30)) + '''), ''' + cast(@term_end as varchar(50)) + ''') tb
		--from dbo.FNATermBreakdown(''d'',  sdd.term_start, ''' + cast(@term_end as varchar(50)) + ''') tb

				--where sdh.term_frequency = ''m''
	) term_bk
	inner join dbo.vwDealTimezone tz on sdd.source_deal_header_id=tz.source_deal_header_id
		and tz.curve_id=isnull(sdd.curve_id,-1)  and tz.location_id=isnull(sdd.location_id,-1)
	left join hour_block_term hbt with (nolock) on hbt.term_date = isnull(term_bk.term_start,sdd.term_start)
		AND hbt.block_define_id = COALESCE(spcd.block_define_id, sdh.block_define_id, ' + cast(@block_define_id_base_load as varchar(10)) + ')
		and hbt.dst_group_value_id = tz.dst_group_value_id
	LEFT JOIN rec_volume_unit_conversion rvuc 
		ON rvuc.to_source_uom_id = ' + IIF(@volume_conversion IS NULL,'rvuc.to_source_uom_id',CAST(@volume_conversion AS VARCHAR(10))) + ' AND rvuc.from_source_uom_id = sdd.deal_volume_uom_id
	OUTER APPLY (
		SELECT SUM(sddh1.volume) [hourly_vol]
		FROM source_deal_detail_hour sddh1 
		WHERE sddh1.source_deal_detail_id = sdd.source_deal_detail_id
	) sddh
	'
	SET @Sql_SELECT += CASE WHEN NULLIF(@counterparty_id,'') IS NOT NULL THEN '
			INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') tc
				ON tc.item = sdh.counterparty_id
			' ELSE ' ' END 				
	SET @Sql_SELECT += '
	WHERE 1 = 1'
		+ ' AND ISNULL(term_bk.term_start, sdd.term_start) BETWEEN ''' + CAST(@term_start AS VARCHAR(30)) + ''' AND ''' + CAST(@term_end AS VARCHAR(30)) + ''''				 
		+ ' AND sdh.template_id = CASE WHEN ml.source_major_location_id = ' + CAST(@location_group_id AS VARCHAR(10)) + ' THEN sdh.template_id ELSE ' + ISNULL(@imb_actualization, '-1') + ' END'
		+ case @deal_type 
			when 'a' then ' AND sdht.template_id IN ( ' + @deal_template_includes + ')' --term link report, storage inventory deals
			when 'i' then ' AND ((buy_sell_flag=''b'' and isnull(gaivs.injection_as_long,''y'') = ''y'') or (buy_sell_flag=''s'' and isnull(gaivs.injection_as_long,''n'') = ''n''))' 
				+ ' AND sdht.template_id = ' + @storage_inj_template_id --injection volume link report, injection deals
			when 'W' then ' AND ((buy_sell_flag=''b'' and isnull(gaivs.injection_as_long,''n'') = ''n'') or (buy_sell_flag=''s'' and isnull(gaivs.injection_as_long,''y'') = ''y''))'
				+ ' AND sdht.template_id = ' + @storage_with_template_id --withdrawal volume link report, withdrawal deals
			else ' AND sdht.template_id NOT IN ( ' + @deal_template_excludes + ')' 
		  end +  
		+ CASE WHEN @commodity_id IS NOT NULL THEN ' AND ISNULL(sdh.commodity_id, spcd.commodity_id) = ' + CAST(@commodity_id AS VARCHAR(30)) ELSE '' END
		+ CASE WHEN @curve_id IS NOT NULL THEN ' AND sdd.curve_id=' + CAST(@curve_id AS VARCHAR(30)) ELSE '' END
		+ CASE WHEN @contract_id IS NOT NULL THEN ' AND sdh.contract_id=' + CAST(@contract_id AS VARCHAR(30)) ELSE '' END
		--+ CASE WHEN @location_id IS NOT NULL THEN ' AND ( (sdd.location_id IN (' + @location_id + ') AND ml.source_major_location_id = ' + CAST(@location_group_id AS VARCHAR(10)) + '))' ELSE '' END
		+ CASE WHEN @location_id IS NOT NULL THEN '
			AND (
				sdd.location_id IN (' + @location_id + ')' + 
				IIF(@call_from = 'STORAGE_GRID'
					, ' OR sdh.template_id = ' + ISNULL(@imb_actualization, '-1')
					, ' AND ml.source_major_location_id = ' + CAST(@location_group_id AS VARCHAR(10))
				) 
			+ ')' ELSE '' 
		END
		+ CASE WHEN ISNULL(@drill_location,'') <>'' THEN ' AND sdh.contract_id' 
		+ CASE WHEN ISNULL(@drill_contract_id, '') = '' THEN ' IS NULL ' ELSE '=' + CAST(@drill_contract_id AS VARCHAR(30)) END ELSE '' END
		+ ' AND isnull(sdh.source_deal_type_id, -1) = iif(isnull(nullif(gaivs.include_non_standard_deals, ''''), ''n'') = ''n'',' + @deal_type_storage + ', isnull(sdh.source_deal_type_id, -1))'

		+ ' 
		GROUP BY ml.location_name, ISNULL(cg.contract_name, ''''), isnull(term_bk.term_start,sdd.term_start), sdd.location_id' 
		+ CASE WHEN @drill_location IS NULL THEN '' ELSE ', sdh.source_deal_header_id' END
		--+' ORDER BY ml.location_name, ISNULL(cg.contract_name, ''''), term_bk.term_start' 
		--+ CASE WHEN @drill_location IS NULL THEN '' ELSE ', sdh.source_deal_header_id' END


	exec spa_print @Sql_SELECT
	EXEC(@Sql_SELECT)
	--print 'temp2 start: ' + convert(VARCHAR(50),getdate() ,21)
	
	--- Now out the result showing the rolling SUM
	--collect udfs
	IF OBJECT_ID('tempdb..#udf_values') IS NOT NULL 
		DROP TABLE #udf_values
	IF @call_from = 'Optimization' or @call_from = 'STORAGE_GRID'
	BEGIN 
		CREATE TABLE #tmp_rpt_data(
				[Location] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
				[Contract] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
				[Term]	   VARCHAR(5000) COLLATE DATABASE_DEFAULT ,
				[Injection] NUMERIC(30, 2) ,
				InjectionAmount NUMERIC(30, 2) ,
				[Withdrawal] NUMERIC(30, 2) ,
				[WithdrawalAmount] NUMERIC(30, 2) ,
				[WACOG] NUMERIC(30, 2) , 
				[Balance] NUMERIC(30, 2),
				[BalanceAmount] NUMERIC(30, 2),
				[UOM]  VARCHAR(250) COLLATE DATABASE_DEFAULT ,
				rowid INT IDENTITY(1,1),
				location_id INT,
				contract_id INT,
				term_date DATETIME,
				conversion_factor FLOAT
			)

		INSERT INTO #tmp_rpt_data([Location],[Contract],[Term],[Injection],InjectionAmount,[Withdrawal],[WithdrawalAmount],[WACOG],[Balance],[BalanceAmount],[UOM],location_id,term_date,conversion_factor)
		SELECT 
			CASE WHEN GROUPING(a.[Date]) = 1 THEN 
				@font_tag_start + 'Total:' + @font_tag_end 
			ELSE a.[Location] 
			END [Location],
			CASE WHEN GROUPING(a.[Date]) = 1 THEN 
				'' 
			ELSE a.[contract_name] 
			END [Contract],
			CASE WHEN @is_pivot IS NULL THEN 
			[dbo].[FNAHyperHTML](
			IIF(a.[Date] = '1900-01-01'
				,REPLACE(REPLACE(@spa, '<#TERM_START#>', '1900-01-01'), '<#TERM_END#>', CONVERT(VARCHAR(10), DATEADD(DAY, -1, @term_start), 120))
				,REPLACE(REPLACE(@spa,'<#TERM_START#>',CONVERT(VARCHAR(10), @term_start, 120)), '<#TERM_END#>', CONVERT(VARCHAR(10), @term_end, 120))
			) 
			+ CAST(MAX(a.location_id) AS VARCHAR(30)) + ','''
				+ CASE WHEN a.[Date] = '1900-01-01' 
						THEN CONVERT(VARCHAR(10), @term_start, 120) 
					WHEN a.[Date] <= @term_end AND @call_from = 'STORAGE_GRID'	
						THEN  CONVERT(VARCHAR(10), @term_end, 120) 
					ELSE 
				  		CONVERT(VARCHAR(10), a.[Date], 120) 
					END
				+ ''',''NULL'',' + ISNULL(CAST(MAX(a.contract_id) AS VARCHAR(30)), 'NULL')+ ',NULL,NULL',
				CASE WHEN a.[Date] = '1900-01-01' 
					THEN '<' +dbo.fnadateformat(@term_start) 
				WHEN a.[Date] <= @term_end AND @call_from = 'STORAGE_GRID'	
					THEN '<' +dbo.fnadateformat(@term_end) 
				ELSE 
					dbo.fnadateformat(a.[Date]) 
				END , 
				IIF(@call_from = 'STORAGE_GRID', '../../../../adiha.php.scripts/dev/spa_html.php',NULL)
			) ELSE 
				CASE WHEN a.[Date] = '1900-01-01' 
					THEN CONVERT(VARCHAR(10), @term_start, 120) 
				ELSE 
					CONVERT(VARCHAR(10), a.[Date], 120) 
				END 
			END Term,  
			ROUND(SUM(a.[Injection]), 2) [Injection],
			ROUND(SUM(a.injection_amt), 2)  InjectionAmount,
			ROUND(SUM(a.[Withdrawal]), 2) [Withdrawal],
			ROUND(SUM(a.[Withdrawal_amt]), 2) [WithdrawalAmount],
			null  WACOG,
			SUM(a.[Daily Average Balance]) [Balance],
			CAST(SUM(a.[Withdrawal_amt] + a.injection_amt) AS NUMERIC(30, 2)) [BalanceAmount] ,
			MAX(a.[UOM]) [UOM], 
			MAX(a.location_id) location_id 
			,MAX(a.[Date])  term_date
			,MAX(a.[conversion_factor]) conversion_factor
		FROM #temp a 
		--OUTER APPLY (
		--		SELECT top(1) term 
		--		FROM dbo.calcprocess_storage_wacog 
		--		WHERE location_id = a.location_id 
		--			AND term < @term_start 
		--			AND ISNULL(contract_id,-1) = ISNULL(a.contract_id ,-1) 
		--			AND a.[Date] = '1900-01-01'
		--			ORDER BY term DESC
		--) tm
		--LEFT JOIN dbo.calcprocess_storage_wacog wa
		--	ON wa.location_id = a.location_id 
		--	AND wa.term = ISNULL(tm.term, a.[date]) 
		--	AND ISNULL(wa.contract_id, -1) = ISNULL(a.contract_id, -1) 
		GROUP BY a.[Location], a.[contract_name], a.[Date]
		ORDER BY a.[Location], a.[contract_name], ISNULL(a.[Date], '9999-01-01')
	END 

	IF @call_from = 'Optimization'
	BEGIN
		SET @fields = '[Location],
							[Contract],
							Term, 
							[Injection] [Inj Vol],
							[InjectionAmount] [Inj Amt],
							[Withdrawal] [With Vol],
							[WithdrawalAmount] [With Amt],
							WACOG,
							ROUND(b.[Balance], 2) [Daily Balance], 
							ROUND(b.[BalanceAmount], 2) [Inventory Value],
							[UOM]
							'

		SET @Sql_SELECT = '
		SELECT  DISTINCT ' + @fields + @str_batch_table + ' 
		FROM #tmp_rpt_data	 a
		OUTER APPLY(
			SELECT MIN(rowid) from_id, MAX(rowid) to_id 
			FROM #tmp_rpt_data 
			WHERE Location = a.Location 
				AND ISNULL([Contract], '''') = ISNULL(a.[Contract], '''')
		) rg
		OUTER APPLY(
			SELECT SUM([Injection] - [Withdrawal]) [Balance],
				ROUND(SUM(BalanceAmount), 2) BalanceAmount 
			FROM #tmp_rpt_data 
			WHERE rowid <= a.rowid 
				AND rowid BETWEEN rg.from_id 
				AND rg.to_id
		)  b '
		--print(@Sql_SELECT)			
		EXEC(@Sql_SELECT)
		--print 'final data end: ' + convert(VARCHAR(50),getdate() ,21)
	END
	ELSE
	BEGIN

		IF 	@drill_location IS NULL OR @deal_type IS NULL
		BEGIN
			
			CREATE TABLE #tmp_rpt_data1(
				[Location] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
				[Contract] VARCHAR(250) COLLATE DATABASE_DEFAULT ,
				[Term]	   VARCHAR(2000) COLLATE DATABASE_DEFAULT ,
				[Injection]	VARCHAR(2000) COLLATE DATABASE_DEFAULT ,
				InjectionAmount NUMERIC(30, 2) ,
				[Withdrawal] VARCHAR(2000) COLLATE DATABASE_DEFAULT ,
				[WithdrawalAmount] NUMERIC(30, 2) ,
				[WACOG] NUMERIC(30, 2) , 
				[Balance] NUMERIC(30, 2),
				[BalanceAmount] NUMERIC(30, 2),
				[UOM]  VARCHAR(250) COLLATE DATABASE_DEFAULT ,
				rowid INT IDENTITY(1,1),
				location_id INT,
				contract_id INT,
				term_date DATETIME,
				conversion_factor FLOAT
			)	

			SELECT CASE WHEN @drill_location IS NULL THEN '' ELSE sdd.source_deal_header_id END source_deal_header_id 
			, sdd.term_start, sdd.fixed_price, CAST(ISNULL(Injection, 0) AS FLOAT) Injection, CAST(ISNULL(Withdrawal, 0) AS FLOAT) Withdrawal
			, sdh.contract_id
			, sdd.location_id
			, ISNULL(ISNULL(NULLIF(sdd.actual_volume, 0), sdd.deal_volume) * CASE WHEN sdd.buy_sell_flag = 'b' THEN 1  ELSE -1 END, 0) deal_volume
			, sdd.source_deal_header_id  ttt
			INTO #udf_values  --- select * from #udf_values where term_start between '2017-04-01' and '2017-04-30' order by 2
			FROM source_deal_detail sdd
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
				and sdh.deal_id not like 'StrgXfer%'
			LEFT JOIN (
				SELECT source_deal_detail_id,  [Injection Amount] Injection, [Withdrawal Amount] Withdrawal 
				FROM (
						SELECT udddf.udf_value, sdh.template_id, sdh.source_deal_header_id, sdd.source_deal_detail_id, udft.Field_label 
						FROM user_defined_deal_detail_fields udddf
						INNER JOIN source_deal_detail sdd ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
						INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
							AND udddf.udf_template_id = uddft.udf_template_id 
						INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
						WHERE  1 = 1
							AND udft.Field_label IN ('Injection Amount', 'Withdrawal Amount')
					
				) up
			PIVOT (MAX(udf_value) FOR Field_label IN ([Injection Amount], [Withdrawal Amount])) AS pvt) a ON a.source_deal_detail_id = sdd.source_deal_detail_id
			WHERE  sdh.template_id = @template_id_transportation_ng		
		
			INSERT INTO #tmp_rpt_data1([Location],[Contract],[Term],[Injection],InjectionAmount,[Withdrawal],[WithdrawalAmount],[WACOG],[Balance],[BalanceAmount],[UOM],location_id,contract_id,term_date,conversion_factor)
			SELECT 
				CASE WHEN GROUPING(a.[Date]) = 1 THEN 
					@font_tag_start + 'Total:' + @font_tag_end 
				ELSE a.[Location] 
				END [Location],
				CASE WHEN GROUPING(a.[Date]) = 1 THEN 
					'' 
				ELSE a.[contract_name] 
				END [Contract],
				[dbo].[FNAHyperHTML](
					IIF(
						(@call_from = 'STORAGE_GRID' AND MAX(mjr.location_name) <> 'Storage')
						, 'EXEC spa_create_imbalance_report @summary_option=''d'', @term_start=''' + CONVERT(VARCHAR(10), dbo.FNAGetFirstLastDayofMonth(@term_start, 'f'), 120) + ''', @term_end=''' + CONVERT(VARCHAR(10), @term_end, 120) + ''', @drill_location=''' + CAST(MAX(a.location_id) AS VARCHAR(30)) + ''''
						, @spa + CAST(MAX(a.location_id) AS VARCHAR(30)) + ','''
							+ CASE	WHEN a.[Date] = '1900-01-01' 
									THEN '<' + CONVERT(VARCHAR(10), @term_start, 120) 
									ELSE CONVERT(VARCHAR(10), a.[Date], 120)
								END
							+ ''',''NULL'',' + ISNULL(CAST(MAX(a.contract_id) AS VARCHAR(30)), 'NULL') + ',NULL,NULL'
					)
					, CASE WHEN a.[Date] = '1900-01-01' THEN '<' + dbo.fnadateformat(@term_start) 
							ELSE dbo.fnadateformat(a.[Date]) 
						END 
					, IIF(@call_from = 'STORAGE_GRID', '../../../../adiha.php.scripts/dev/spa_html.php', NULL)
				)  [Term],  
				[dbo].[FNAHyperHTML](@spa + CAST(MAX(a.location_id) AS VARCHAR(30)) + ','''
					+ CASE WHEN a.[Date] = '1900-01-01' THEN '<' + CONVERT(VARCHAR(10), @term_start, 120) ELSE CONVERT(VARCHAR(10), a.[Date], 120) END
					+ ''',''NULL'',' + ISNULL(CAST(MAX(a.contract_id) AS VARCHAR(30)), 'NULL') + ',''i'',NULL',
					ROUND(CONVERT(NUMERIC(38,2), SUM(a.[Injection]) ), 2) , NULL)  
				  [Injection],
				ROUND(SUM(uv.Injection), 2)  InjectionAmount,
				[dbo].[FNAHyperHTML](@spa + CAST(MAX(a.location_id) AS VARCHAR(30)) + ','''
					+ CASE WHEN a.[Date] = '1900-01-01' THEN '<' + CONVERT(VARCHAR(10), @term_start, 120) ELSE CONVERT(VARCHAR(10), a.[Date], 120) END
					+ ''',''NULL'',' + ISNULL(CAST(MAX(a.contract_id) AS VARCHAR(30)), 'NULL') + ',''w'',NULL',
					CONVERT(NUMERIC(38,2), SUM(a.[Withdrawal])) , NULL) [Withdrawal],
				ROUND(SUM(uv.Withdrawal), 2) [WithdrawalAmount],
				ROUND(AVG(uv.fixed_price), 4) WACOG,--ROUND(SUM(wa.wacog), 4)  WACOG,
				--SUM(a.[Daily Average Balance]) [Balance],
				--CASE WHEN SUM(ISNULL(deal_volume, 0)) = 0 THEN NULL ELSE SUM(ISNULL(deal_volume, 0)) END [Balance],
				ROUND(CONVERT(NUMERIC(38,2), ABS(SUM(a.[Injection])) - ABS(SUM(a.[Withdrawal]))), 2) [Balance],
				--CAST(SUM(a.[Withdrawal_amt] + a.injection_amt) AS NUMERIC(30, 2)) [BalanceAmount] ,
				CASE WHEN SUM(deal_volume * ISNULL(uv.fixed_price, 1)) = 0 THEN NULL ELSE SUM(deal_volume * ISNULL(uv.fixed_price, 1)) END BalanceAmount,
				MAX(a.[UOM]) [UOM]
				, MAX(a.location_id) location_id
				, MAX(ISNULL(a.contract_id ,-1)) contract_id
				, a.[Date]
				--    select * from #temp  select * from #tmp_rpt_data1
				,MAX(a.[conversion_factor]) conversion_factor

				--,MAX(mjr.location_name) 
			FROM #temp a 
			LEFT JOIN #udf_values uv ON uv.location_id = a.location_id
				AND uv.contract_id = a.contract_id
				AND uv.term_start = a.[date]
			LEFT JOIN source_minor_location sml
				ON sml.source_minor_location_id = a.location_id
			LEFT JOIN source_major_location mjr ON mjr.source_major_location_id = sml.source_major_location_id
			WHERE a.[Date] <> '1900-01-01'
			GROUP BY a.[Location], a.[contract_name], a.[Date]
			ORDER BY a.[Location], a.[contract_name], cast(ISNULL(a.[Date], '9999-01-01') as datetime)
			--return
			IF @call_from = 'STORAGE_GRID'
			BEGIN
				SET @fields = '
							  CASE WHEN MAX(location_group) = ''Storage'' THEN ''Storage'' ELSE ''Imbalance'' END location_group,
							  [Location],
							  [Contract],
							  MAX(Term) Term,
							  MAX(a.conversion_factor) * MAX(ROUND(b.[Balance], 2)) [Daily Balance], 
							  MAX([UOM]) UOM,
							  MAX([Location_id]) Location_id

							  '
		
			END
			ELSE 
			BEGIN
				SET @fields = '[Location],
							  [Contract],
							  Term, 
							  [Injection] [Inj Vol],
							  [InjectionAmount] [Inj Amt],
							  [Withdrawal] [With Vol],
							  [WithdrawalAmount] [With Amt],
							  WACOG,
							  ROUND(b.[Balance], 2) [Daily Balance], 
							  ROUND(b.[BalanceAmount], 2) [Inventory Value],
							  [UOM]
							  '
			END
				SET @Sql_SELECT = 'SELECT  DISTINCT ' + @fields + @str_batch_table + ' 
							FROM #tmp_rpt_data1	 a
								OUTER APPLY (
									SELECT sml2.location_name location_group
									FROM source_minor_location sml
									INNER JOIN source_major_location sml2 ON sml2.source_major_location_id = sml.source_major_location_id
									WHERE  sml.source_minor_location_id = a.location_id
								) sml2
								
								OUTER APPLY(
									SELECT MIN(rowid) from_id, MAX(rowid) to_id 
									FROM #tmp_rpt_data1
									WHERE Location = a.Location 
										AND ISNULL([Contract], '''') = ISNULL(a.[Contract], '''')
								) rg
								OUTER APPLY(
									SELECT SUM(balance) [Balance],
										ROUND(SUM(BalanceAmount), 2) BalanceAmount 
									FROM #tmp_rpt_data1
									WHERE rowid <= a.rowid 
										AND rowid BETWEEN rg.from_id 
										AND rg.to_id
								)  b ' + case when  @call_from = 'STORAGE_GRID' then 
								' group by location, contract, year(a.term_date) + ''-'' + month(a.term_date)
								  UNION
									 SELECT 
									 ' + CASE WHEN @call_from = 'STORAGE_GRID' THEN 'CASE WHEN sml2.location_name = ''Storage'' THEN ''Storage'' ELSE ''Imbalance'' END location_name,' ELSE '' END + '
									 sml.location_name,NULL,'''+CAST(dbo.fnadateformat(@term_start) AS VARCHAR(10))+''',0,tbl.uom_id,t.item
									 
									FROM dbo.splitCommaSeperatedValues('''+ @location_id + ''') t
									INNER JOIN source_minor_location sml
										ON sml.source_minor_location_id = t.item
									INNER JOIN source_major_location sml2 ON sml2.source_major_location_id = sml.source_major_location_id
									LEFT JOIN #tmp_rpt_data1 a 
										ON a.location_id =  sml.source_minor_location_id
									OUTER APPLY(
										SELECT uom_id
										FROM source_uom
										WHERE source_uom_id = ''' + CAST(ISNULL(@uom,'') AS VARCHAR(20)) + ''' 
									) tbl
									WHERE a.location_id IS NULL
								 '
								 else ''
								 end 


			EXEC(@Sql_SELECT)
		END
		ELSE
		BEGIN	
			SET @Sql_SELECT = '
			 SELECT 
				--sdh.source_deal_header_id ,
				dbo.FNATRMWinHyperlink(''a'', 10131010, sdh.source_deal_header_id, ABS(sdh.source_deal_header_id),''n'',null,null,null,null,null,null,null,null,null,null,0) [Deal ID],
				--dbo.FNAHyperLinkText(10131010, sdh.deal_id, sdh.source_deal_header_id) ReferenceID,
				sdh.deal_id [Reference ID],
				a.[Location],
				dbo.fnadateformat(ISNULL(NULLif(a.[Date], ''''), sdh.entire_term_start)) [Date]  ,
				a.Counterparty
				,ROUND(' + CASE @deal_type WHEN 'a' THEN ' udf_val.[Ending Balance] * -1' when 'i' then ' a.[Injection]' when 'w' then ' a.[Withdrawal]' END + ', 2) Volume,
				ROUND(' + CASE @deal_type WHEN 'i' then 'wa.deal_price' when 'a' then  'a.fixed_price' else 'tm.wacog' end+',4) Price
				, a.[UOM]
				' + @str_batch_table + '
			FROM #temp a
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = a.source_deal_header_id 
			INNER join source_deal_detail sdd on sdd.source_deal_header_id = sdh.source_deal_header_id
				and sdd.term_start = a.[Date] 
			left JOIN (
				SELECT source_deal_detail_id,  cast([Ending Balance] as numeric(30,2)) [Ending Balance]
				FROM (
						SELECT udddf.udf_value, sdh.template_id, sdh.source_deal_header_id, sdd.source_deal_detail_id, udft.Field_label 
						FROM user_defined_deal_detail_fields udddf
						INNER JOIN source_deal_detail sdd ON udddf.source_deal_detail_id = sdd.source_deal_detail_id
						INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
						INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id = sdh.template_id
							AND udddf.udf_template_id = uddft.udf_template_id 
						INNER JOIN user_defined_fields_template udft ON udft.field_id = uddft.field_id
						WHERE  1 = 1
							AND udft.Field_label IN (''Ending Balance'')
					
				) up
				PIVOT (MAX(udf_value) FOR Field_label IN ([Ending Balance])) AS pvt
			) udf_val ON udf_val.source_deal_detail_id = sdd.source_deal_detail_id
			LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id AND sdt.sub_type = ''n''
			LEFT JOIN source_deal_type sub ON sub.source_deal_type_id = sdh.deal_sub_type_type_id AND sub.sub_type = ''y''
			LEFT JOIN internal_deal_type_subtype_types sdtst ON sdh.internal_deal_type_value_id = sdtst.internal_deal_type_subtype_id
			OUTER APPLY (
				SELECT top(1) * 
				FROM dbo.calcprocess_storage_wacog 
				WHERE location_id = a.location_id 
					AND term < a.[date] 
					AND ISNULL(contract_id,-1) = ISNULL(a.contract_id ,-1) 
					ORDER BY term DESC
			) tm
			LEFT JOIN dbo.calcprocess_storage_wacog wa ON wa.location_id = a.location_id 
				AND wa.term = a.[date]
				AND ISNULL(wa.contract_id, -1) = ISNULL(a.contract_id, -1) 
			WHERE 1 = 1
				AND ISNULL(a.[Date],''1900-01-01'' ) ' + CASE WHEN CHARINDEX('<', @drill_term) > 0 THEN '<''' + REPLACE(@drill_term, '<', '') + '''' ELSE '=''' + @drill_term + '''' END + '
				' + iif(@deal_type = 'a', ' and udf_val.[Ending Balance] is not null', '') + '
			ORDER BY sdh.source_deal_header_id	  '

			exec spa_print @Sql_SELECT
			EXEC(@Sql_SELECT)

			-------------------------------------------
			
			-----------------------------------
		END			
	END
END
IF @is_batch = 1 
BEGIN 
	SELECT @str_batch_table = dbo.FNABatchProcess ('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
	EXEC (@str_batch_table)
 
	SELECT @str_batch_table = dbo.FNABatchProcess ('c', @batch_process_id, @batch_report_param, 
				   GETDATE(), 'spa_storage_position_report', 'Gas Storage Position Report') --TODO: modify sp AND report name
 
	EXEC (@str_batch_table) 
	RETURN 
END
  
IF @enable_paging = 1 AND @page_no IS NULL 
BEGIN 
	SET @sql_paging = dbo.FNAPagingProcess ('t', @batch_process_id, @page_size, @page_no) 
	EXEC (@sql_paging) 
END
 
/*******************************************2nd Paging Batch END**********************************************/
 
GO