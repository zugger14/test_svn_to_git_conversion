IF OBJECT_ID(N'[dbo].[spa_Create_Available_Hedge_Capacity_Exception_Report_Manager]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_Create_Available_Hedge_Capacity_Exception_Report_Manager]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_Create_Available_Hedge_Capacity_Exception_Report_Manager]
	@as_of_date					VARCHAR(50),
	@subsidiary_id				VARCHAR(MAX),
	@strategy_id				VARCHAR(MAX) = NULL, 
	@book_id					VARCHAR(MAX) = NULL, 
	@report_type				VARCHAR(100),
	@summary_option				CHAR(1),
	@convert_unit_id			INT = NULL,
	@exception_flag				CHAR(1),
	@asset_type_id				INT = 402,
	@settlement_option			CHAR(1) = 'f',
	@include_gen_tranactions	CHAR(1) = 'b',
	@forecated_tran				CHAR(1) = 'n',
	@limit_bucketing			VARCHAR(3) ='UK',
	@round_value				CHAR(1) = 2

 AS
/*
SET NOCOUNT OFF
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
--round_value=2,report_type=c,settlement_option=NULL,summary_option=m,sub_id=59,stra_id=60,book_id=80!88,sub_book_id=31!32,limit_bucketing=NULL,include_gen_tran=NULL,asset_type=NULL,convert_unit_id=NULL,exception_flag=a,forecasted_tran=NULL,as_of_date=2019-03-31
DECLARE 
	@as_of_date					VARCHAR(50) = '2019-03-31',
	@subsidiary_id				VARCHAR(MAX) = '59',
	@strategy_id				VARCHAR(MAX) = '60', 
	@book_id					VARCHAR(MAX) = '80,88', 
	@report_type				CHAR(1) = 'c',  
	@summary_option				CHAR(1) = 'm',
	@convert_unit_id			INT = NULL,
	@exception_flag				CHAR(1) = 'a',
	@asset_type_id				INT = NULL,
	@settlement_option			CHAR(1) = NULL,
	@include_gen_tranactions	CHAR(1) = NULL,
	@forecated_tran				CHAR(1) = NULL,
	@limit_bucketing			VARCHAR(3) = NULL,
	@round_value				CHAR(1) = 2

EXEC spa_drop_all_temp_table
--*/
SET NOCOUNT ON

SET @as_of_date = dbo.FNAClientToSqlDate(@as_of_date)

SET @round_value = ISNULL(@round_value, 2)

IF @include_gen_tranactions IS NULL
	SET @include_gen_tranactions = 'b'

DECLARE @user_login_id VARCHAR(50)
DECLARE @Sql_Select VARCHAR(8000)
DECLARE @Sql_SelectS VARCHAR(8000)
DECLARE @Sql_SelectD VARCHAR(8000)
DECLARE @term_where_clause VARCHAR(1000)
DECLARE @summary_option_orginal VARCHAR(1)
DECLARE @Sql_Where VARCHAR(8000)
DECLARE @report_identifier VARCHAR(100)
DECLARE @tenor_name VARCHAR(100)

SET @tenor_name = 'Tenor Bucket ' + ISNULL(@limit_bucketing, 'UK')

SET @sql_Where = ''

SET @summary_option_orginal = @summary_option

IF @summary_option_orginal = 'l'
BEGIN
	SET @summary_option = 's'
END

IF @settlement_option = 'f'
BEGIN
	SET @term_where_clause = ' AND sdd.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)'
END
ELSE IF @settlement_option = 'c'
	SET @term_where_clause = ' AND sdd.term_start >=  CONVERT(DATETIME, ''' + cast(month(@as_of_date) as varchar) + '/1/' + cast(year(@as_of_date) as varchar) + ''' , 102)'
ELSE IF @settlement_option = 's'
	SET @term_where_clause = ' AND sdd.term_start <=  CONVERT(DATETIME, ''' + cast(month(@as_of_date) as varchar) + '/1/' + cast(year(@as_of_date) as varchar) + ''' , 102)'
ELSE
	SET @term_where_clause = ''

IF @report_type = 'c'
	SET @report_identifier = '150'
ELSE IF @report_type = 'f'
	SET @report_identifier = '151'
ELSE
	SET @report_identifier = '150,151'

DECLARE @link_deal_term_used_per VARCHAR(MAX)
DECLARE @process_id VARCHAR(150)

SELECT @process_id = dbo.FNAGetNewID(), @user_login_id = dbo.FNADBUser()

SET @link_deal_term_used_per = dbo.FNAProcessTableName('link_deal_term_used_per', @user_login_id, @process_id)

IF OBJECT_ID(@link_deal_term_used_per) IS NOT NULL
	EXEC('DROP TABLE ' + @link_deal_term_used_per)
	
EXEC [dbo].[spa_get_link_deal_term_used_per]
	@as_of_date = @as_of_date,
	@link_ids = null,
	@header_deal_id = null,
	@term_start = null,
	@no_include_link_id = NULL,
	@output_type =1,
	@include_gen_tranactions = @include_gen_tranactions,
	@process_table = @link_deal_term_used_per

CREATE TABLE #temp_per_used(
	source_deal_header_id INT,
	used_per VARCHAR(MAX) COLLATE DATABASE_DEFAULT
);

SET @sql_Select = '
	INSERT INTO #temp_per_used (source_deal_header_id, used_per)
	SELECT source_deal_header_id,
		AVG(percentage_used) percentage_used
	FROM (
		SELECT source_deal_header_id,
			term_start,
			SUM(ISNULL(percentage_used, 1)) percentage_used
		FROM ' + @link_deal_term_used_per + '
		GROUP BY source_deal_header_id, term_start
	) p
	GROUP BY source_deal_header_id '

EXEC spa_print @sql_Select
EXEC(@sql_Select)

CREATE TABLE [dbo].[#tempItems] (
	[fas_book_id] INT NOT NULL ,
	[deal_id] VARCHAR(50) NOT NULL ,
	[contract_expiration_date] DATETIME,
	[NetItemVol] FLOAT NULL,
	[deal_volume_frequency] VARCHAR(7) NOT NULL,
	[IndexName] VARCHAR(100)NOT NULL,
	[sui] INT NOT NULL,
	source_deal_header_id INT,
	curve_id INT
) ON [PRIMARY]

--Get all the Items first
SET @sql_Where = ''
SET @sql_Select = '
	INSERT INTO #tempItems
	SELECT flh.fas_book_id,
		sdh.deal_id,
		dbo.FNAGetContractMonth(sdd.term_start) AS contract_expiration_date,
		CASE
			WHEN(sdd.deal_volume_frequency = ''d'') THEN
				(CASE 
					WHEN (sdd.buy_sell_flag = ''s'') THEN -1 * sdd.total_volume * lp.percentage_used
					ELSE sdd.total_volume * lp.percentage_used 
				END) * (DATEDIFF(day, sdd.term_start, sdd.term_end) + 1)
			ELSE
				(CASE
					WHEN (sdd.buy_sell_flag = ''s'') THEN -1 * sdd.total_volume * lp.percentage_used
					ELSE sdd.total_volume * lp.percentage_used
				END)
			END	AS NetItemVol,
		''Monthly'' AS deal_volume_frequency,
		CASE
			WHEN(sdd.fixed_float_leg = ''f'') THEN ''Fixed''
			ELSE COALESCE(pspcd.curve_name, spcd.curve_name)
		END AS IndexName,
		sdd.deal_volume_uom_id,
		sdh.source_deal_header_id,
		CASE
			WHEN(sdd.fixed_float_leg = ''f'') THEN -1 
			ELSE ISNULL(pspcd.source_curve_def_id, spcd.source_curve_def_id)
		END curve_id
	FROM fas_link_header flh
	INNER JOIN fas_link_detail fld ON flh.link_id = fld.link_id
	INNER JOIN source_deal_header sdh ON fld.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN ' + @link_deal_term_used_per + ' lp ON lp.link_id = fld.link_id
		AND lp.source_deal_header_id = fld.source_deal_header_id
		AND lp.term_start = sdd.term_start
	INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
		AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
		AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
		AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		AND ISNULL(sdh.fas_deal_type_value_id, ssbm.fas_deal_type_value_id) = 401
		LEFT OUTER JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id
		LEFT OUTER JOIN source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id
		INNER JOIN portfolio_hierarchy book ON flh.fas_book_id = book.entity_id
		--WhatIf Changes
		INNER JOIN fas_books fb ON fb.fas_book_id = book.entity_id
		INNER JOIN portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id
		INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
		INNER JOIN fas_strategy fs ON stra.entity_id = fs.fas_strategy_id
	WHERE 1 = 1 ' +
	CASE
		WHEN @as_of_date IS NULL THEN '' 
		ELSE '
		AND flh.link_effective_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)
		AND (sdh.deal_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)) '
	END + '
		AND flh.link_type_value_id = 450
		AND (fld.hedge_or_item = ''i'')
		AND sdd.fixed_float_leg <> ''f''
		AND sdd.leg = 1
		--WhatIf Changes
		AND (fb.no_link IS NULL OR fb.no_link = ''n'')
		AND fs.hedge_type_value_id IN (' + @report_identifier + ')' +
	CASE
		WHEN @subsidiary_id IS NULL THEN '' 
		ELSE '
		AND sub.entity_id IN  (' + @subsidiary_id + ') '
	END	+ @term_where_clause
--' AND sdd.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)'
		
IF @strategy_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_id + ' ))'
IF @book_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_id + ')) '
	
EXEC spa_print @sql_Select, @sql_Where
EXEC (@sql_Select + @sql_Where)

--GET all perfect hedges opposite volume to represent hedged items
SET @sql_Where = ''
SET @sql_Select = '
	INSERT INTO #tempItems
	SELECT flh.fas_book_id,
		sdh.deal_id + ''-p'' as deal_id,
		dbo.FNAGetContractMonth(sdd.term_start) AS contract_expiration_date,
		CASE
			WHEN(sdd.deal_volume_frequency = ''d'') THEN
				(CASE 
					WHEN (sdd.buy_sell_flag = ''s'') THEN sdd.total_volume * lp.percentage_used
					ELSE -1 * sdd.total_volume * lp.percentage_used
				END) * (DATEDIFF(day, sdd.term_start, sdd.term_end) + 1)
			ELSE
				(CASE
					WHEN (sdd.buy_sell_flag = ''s'') THEN sdd.total_volume * lp.percentage_used
					ELSE -1 * sdd.total_volume * lp.percentage_used
				END)
		END AS NetItemVol,
		''Monthly'' AS deal_volume_frequency,
		CASE
			WHEN(sdd.fixed_float_leg = ''f'') THEN ''Fixed'' 
			ELSE COALESCE (pspcd.curve_name, spcd.curve_name)
		END AS IndexName,
		sdd.deal_volume_uom_id,
		sdh.source_deal_header_id,
		CASE
			WHEN(sdd.fixed_float_leg = ''f'') THEN -1
			ELSE ISNULL(pspcd.source_curve_def_id, spcd.source_curve_def_id)
		END [curve_id]
	FROM fas_link_header flh
	INNER JOIN fas_link_detail fld ON flh.link_id = fld.link_id
	INNER JOIN source_deal_header sdh ON fld.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN ' + @link_deal_term_used_per + ' lp ON lp.link_id=fld.link_id
		AND lp.source_deal_header_id = fld.source_deal_header_id
        AND lp.term_start= sdd.term_start
	INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
		AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
		AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
		AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		AND ISNULL(sdh.fas_deal_type_value_id, ssbm.fas_deal_type_value_id) = 400 '

SET @sql_Select = @sql_Select + '
	LEFT OUTER JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id
	LEFT OUTER JOIN source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id
	INNER JOIN portfolio_hierarchy book ON flh.fas_book_id = book.entity_id
	INNER JOIN fas_books fb ON fb.fas_book_id = book.entity_id
	INNER JOIN portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id
	INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
	INNER JOIN fas_strategy fs ON stra.entity_id = fs.fas_strategy_id
	WHERE 1 = 1 ' + 
		CASE 
			WHEN @as_of_date IS NULL THEN '' 
			ELSE ' AND (flh.link_effective_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)) AND (sdh.deal_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)) '
		END + '
		AND flh.link_type_value_id = 450
		AND (fld.hedge_or_item = ''h'')
		AND (flh.perfect_hedge = ''y'')
		AND sdd.fixed_float_leg <> ''f''
		AND sdd.leg = 1
		--WhatIf Changes
		AND (fb.no_link IS NULL OR fb.no_link = ''n'')
		AND fs.hedge_type_value_id IN (' + @report_identifier + ')' + 
		CASE
			WHEN @subsidiary_id IS NULL THEN ''
			ELSE ' AND sub.entity_id IN (' + @subsidiary_id + ') '
		END +
		ISNULL(@term_where_clause, '')
--' AND sdd.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)'
		
IF @strategy_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_id + '))'
IF @book_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_id + ')) '

EXEC spa_print @sql_Select, @sql_Where
EXEC (@sql_Select + @sql_Where)

--Get outstanding forecasted transactions
IF @include_gen_tranactions <> 'n'
BEGIN
	SET @sql_Select = '
		INSERT INTO #tempItems
		SELECT flh.fas_book_id,
			sdh.deal_id As deal_id,
			dbo.FNAGetContractMonth(sdd.term_start) AS contract_expiration_date,
			sdd.total_volume * isnull(lp.percentage_used,1) *
					CASE WHEN(sdd.deal_volume_frequency = ''d'') THEN (DATEDIFF(day,sdd.term_start,sdd.term_end)+1) ELSE 1 END
					*
					CASE WHEN (sdd.buy_sell_flag = ''s'') THEN  
						case when isnull(flh.[perfect_hedge],''n'')=''n'' then -1 else 1 end
					else
						case when isnull(flh.[perfect_hedge],''n'')=''n'' then 1 else -1 end
					end		 AS NetItemVol, 
					''Monthly'' as deal_volume_frequency, 
		                      CASE WHEN(sdd.fixed_float_leg = ''f'') THEN ''Fixed'' ELSE COALESCE (pspcd.curve_name, spcd.curve_name) END AS IndexName,  
					sdd.deal_volume_uom_id,
				sdh.[source_deal_header_id] source_deal_header_id , CASE WHEN(sdd.fixed_float_leg = ''f'') THEN -1 ELSE isnull(pspcd.source_curve_def_id,spcd.source_curve_def_id) END AS curve_id  
		FROM gen_fas_link_header flh
		INNER JOIN gen_fas_link_detail fld ON flh.gen_link_id = fld.gen_link_id 
		INNER JOIN [source_deal_header] sdh ON fld.deal_number= sdh.[source_deal_header_id]
		INNER JOIN [source_deal_detail] sdd ON sdh.[source_deal_header_id] = sdd.[source_deal_header_id]
		INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
			AND sdh.source_system_book_id2 = ssbm.source_system_book_id2 
			AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 
			AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
			AND ISNULL(sdh.fas_deal_type_value_id, ssbm.fas_deal_type_value_id) = [401]
		LEFT JOIN ' + @link_deal_term_used_per + ' lp ON lp.link_id = flh.gen_link_id
			AND lp.source_deal_header_id = sdd.[source_deal_header_id]
			AND lp.term_start = sdd.term_start '
				
	SET @sql_Select = @sql_Select + '
		LEFT OUTER JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id
		LEFT OUTER JOIN source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id
		INNER JOIN portfolio_hierarchy book ON flh.fas_book_id = book.entity_id 
		--WhatIf Changes
		INNER JOIN fas_books fb ON fb.fas_book_id = book.entity_id
		LEFT JOIN portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id 
		LEFT JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id 
		LEFT JOIN fas_strategy fs ON stra.entity_id = fs.fas_strategy_id
		WHERE 1 = 1 ' + 
		CASE
			WHEN @as_of_date IS NULL THEN ''
			ELSE ' AND (flh.link_effective_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)) AND (sdh.deal_date <= CONVERT(DATETIME, ''' + @as_of_date + ''' , 102))'
		END + '
			AND sdd.fixed_float_leg <> ''f''
			AND sdd.leg = 1
			--WhatIf Changes
			AND (fb.no_link IS NULL OR fb.no_link = ''n'')
			AND fs.hedge_type_value_id IN (' + @report_identifier + ')' + 
		CASE
			WHEN @subsidiary_id IS NULL THEN '' 
			ELSE ' AND sub.entity_id IN (' + @subsidiary_id + ') '
		END + ISNULL(@term_where_clause, '')
	--' AND sdd.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)'
			
	IF @strategy_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_id + '))'
	IF @book_id IS NOT NULL
		SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_id + ')) '
	IF @include_gen_tranactions = 'a'
		SET @Sql_Where = @Sql_Where + ' AND (flh.gen_status IN(''a'',''p'') AND flh.gen_approved = ''y'')'
	IF @include_gen_tranactions = 'u'
		SET @Sql_Where = @Sql_Where + ' AND (flh.gen_status IN(''a'',''p'')  AND flh.gen_approved = ''n'')'
	IF @include_gen_tranactions = 'b'
		SET @Sql_Where = @Sql_Where + ' AND (flh.gen_status IN(''a'',''p''))'

	DECLARE @sql_Select1 VARCHAR(MAX)

	SET @sql_Select1 = REPLACE(@sql_Select, '[401]', '401')

	--n means dont include, a means approved only, u means unapproved, b means both
	EXEC spa_print @sql_Select1, @sql_Where, ' AND ISNULL(flh.[perfect_hedge], ''n'') = ''n'' AND fld.[hedge_or_item] = ''i'' '
	EXEC (@sql_Select1 + @sql_Where + ' AND ISNULL(flh.[perfect_hedge], ''n'') = ''n'' AND fld.[hedge_or_item] = ''i''')

	IF ISNULL(@forecated_tran,'n') = 'y'
	BEGIN
		SET @sql_Select1 = REPLACE(@sql_Select, '[source_deal_header_id]', 'gen_deal_header_id')
		SET @sql_Select1 = REPLACE(@sql_Select1, '[source_deal_header]', 'gen_deal_header')
		SET @sql_Select1 = REPLACE(@sql_Select1, '[source_deal_detail]', 'gen_deal_detail')
		
		EXEC spa_print @sql_Select1, @sql_Where, ' AND ISNULL(flh.[perfect_hedge], ''n'') = ''n'' AND fld.[hedge_or_item] = ''i'' '
		EXEC(@sql_Select1 + @sql_Where + ' AND ISNULL(flh.[perfect_hedge], ''n'') = ''n'' AND fld.[hedge_or_item] = ''i'' ')
	END
	
	SET @sql_Select1 = REPLACE(@sql_Select, '[401]', '400')
	EXEC spa_print @sql_Select1, @sql_Where, ' AND ISNULL(flh.[perfect_hedge], ''n'') = ''y'' AND fld.[hedge_or_item] = ''h'' '
	EXEC (@sql_Select1 + @sql_Where + ' AND ISNULL(flh.[perfect_hedge], ''n'') = ''y'' AND fld.[hedge_or_item] = ''h'' ')
END

CREATE TABLE [dbo].[#tempAsset] (
	[fas_book_id] INT NOT NULL ,
	[deal_id] VARCHAR(50) NOT NULL ,
	[contract_expiration_date] datetime,
	[IndexName] VARCHAR(100) NOT NULL ,
	[deal_volume_frequency] VARCHAR(7) NOT NULL,
	[NetAssetVol] FLOAT NULL,
	[sui] INT NOT NULL,
	source_deal_header_id INT,
	curve_id INT
) ON [PRIMARY]

SET @sql_Select = '
	INSERT INTO #tempAsset
	SELECT ssbm.fas_book_id,
		sdh.deal_id,
		dbo.FNAGetContractMonth(sdd.term_start) AS contract_expiration_date,
		CASE
			WHEN(sdd.fixed_float_leg = ''f'') THEN ''Fixed''
			ELSE COALESCE (pspcd.curve_name, spcd.curve_name)
		END AS [IndexName],
		''Monthly'' AS deal_volume_frequency,
		-- sdd.term_start, sdd.term_end, sdd.deal_volume,DATEDIFF(day,sdd.term_start,sdd.term_end)+1 as days,
		CASE
			WHEN(sdd.deal_volume_frequency = ''d'') THEN
				(CASE 
					WHEN (sdd.buy_sell_flag = ''s'') THEN -1 * sdd.total_volume 
					ELSE sdd.total_volume
				END) * (DATEDIFF(day,sdd.term_start,sdd.term_end) + 1)
			ELSE
				(CASE
					WHEN (sdd.buy_sell_flag = ''s'') THEN -1 * sdd.total_volume
					ELSE sdd.total_volume
				END)
		END AS [NetAssesVol],
		sdd.deal_volume_uom_id AS sui,
		sdh.source_deal_header_id,
		ISNULL(pspcd.source_curve_def_id, spcd.source_curve_def_id) curve_id
	FROM source_deal_detail sdd
	INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
	LEFT OUTER JOIN source_price_curve_def spcd ON sdd.curve_id = spcd.source_curve_def_id
	LEFT OUTER JOIN source_price_curve_def pspcd ON spcd.proxy_source_curve_def_id = pspcd.source_curve_def_id
	INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
		AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
		AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
		AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
	INNER JOIN portfolio_hierarchy book ON ssbm.fas_book_id = book.entity_id
	--WhatIf Changes
	INNER JOIN fas_books fb ON fb.fas_book_id = book.entity_id
	INNER JOIN portfolio_hierarchy stra ON book.parent_entity_id = stra.entity_id
	INNER JOIN portfolio_hierarchy sub ON sub.entity_id = stra.parent_entity_id
	INNER JOIN fas_strategy fs ON stra.entity_id = fs.fas_strategy_id
	WHERE (ISNULL(sdh.fas_deal_type_value_id, ssbm.fas_deal_type_value_id) = ' + CAST(@asset_type_id AS VARCHAR) + ')
		AND (sdh.deal_date <= CONVERT(DATETIME, ''' + @as_of_date + ''', 102))
		AND fs.hedge_type_value_id IN (' + @report_identifier + ')
		--WhatIf Changes
		AND (fb.no_link IS NULL OR fb.no_link = ''n'')
		AND sdd.fixed_float_leg <> ''f''
		AND sdd.leg = 1
		AND sub.entity_id IN (' + @subsidiary_id + ') ' + @term_where_clause
--' AND sdd.term_start >  CONVERT(DATETIME, ''' + @as_of_date + ''' , 102)'

SET @sql_Where = ''

IF @strategy_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @strategy_id + ' ))'
IF @book_id IS NOT NULL
	SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book_id + ')) '

EXEC spa_print @sql_Select, @sql_Where
EXEC (@sql_Select + @sql_Where)

UPDATE #tempAsset
	SET NetAssetVol = NetAssetVol * conversion_factor,
	sui = vuc.to_source_uom_id
FROM #tempAsset tI
LEFT OUTER JOIN volume_unit_conversion vuc ON tI.sui = vuc.from_source_uom_id
WHERE vuc.to_source_uom_id = @convert_unit_id

--Supporting Granularity Type 's' means monthly, 'q' quarter, 's' semi-annual, 'a' annual
DECLARE @granularity_type VARCHAR(1)

IF @summary_option_orginal = 'l'
BEGIN
	SET @granularity_type ='t' --case when isnull(@limit_bucketing,'DE') ='DE' then 'm' else  't' end
END
ELSE
BEGIN
	SET @granularity_type = @summary_option
END

IF @summary_option <> 'd'
   SET @summary_option = 's'
   
CREATE TABLE #tmp_s(
	sub_id INT,
	stra_id INT,
	book_id INT,
	curve_id INT,
	Subsidiary VARCHAR(150) COLLATE DATABASE_DEFAULT,
	Strategy VARCHAR(150) COLLATE DATABASE_DEFAULT,
	yr INT,
	mnth INT,
	Book VARCHAR(150) COLLATE DATABASE_DEFAULT,
	IndexName VARCHAR(150) COLLATE DATABASE_DEFAULT,
	ContractMonth DATETIME,
	VolumeFrequency VARCHAR(50) COLLATE DATABASE_DEFAULT,
	VolumeUOM VARCHAR(150) COLLATE DATABASE_DEFAULT,
	[NetAssetVol(+Buy,-Sell)] NUMERIC(26,10),
	[NetItemVol(+Buy,-Sell)] NUMERIC(26,10),
	[AvailableCapacity(+Buy,-Sell)] NUMERIC(26,10),
	[OverHedged] VARCHAR(3) COLLATE DATABASE_DEFAULT
)
  
--SELECT CONVERT(VARCHAR(16),GETDATE(),107)
SET @sql_SelectS = '
	 INSERT INTO #tmp_s (
		sub_id,
		stra_id,
		book_id,
		curve_id,
		yr,
		mnth,
		Subsidiary,
		Strategy,
		Book,
		IndexName,
		ContractMonth,
		VolumeFrequency,
		VolumeUOM,
		[NetAssetVol(+Buy,-Sell)],
		[NetItemVol(+Buy,-Sell)],
		[AvailableCapacity(+Buy,-Sell)],
		[OverHedged]
	)   
	SELECT MAX(sub.entity_id) sub_id,
		MAX(stra.entity_id) stra_id,
		MAX(book.entity_id) book_id,
		MAX(a.curve_id) curve_id,
		YEAR(MAX(A.ContractMonth)) yr,
		MONTH(MAX(A.ContractMonth)) mnth,
		sub.entity_name AS Subsidiary,
		stra.entity_name AS Strategy,
		book.entity_name AS Book,
		A.IndexName,
		A.ContractMonth,
		A.VolumeFrequency,
		A.VolumeUOM,
        ROUND(SUM(A.[NetAssetVol]), 0) AS [NetAssetVol(+Buy,-Sell)],
		ROUND(SUM(A.[NetItemVol]), 0) AS [NetItemVol(+Buy,-Sell)], 
		ROUND(CASE
				WHEN ABS(ISNULL(SUM(A.NetAssetVol), 0)) < ABS(ISNULL(SUM(A.NetItemVol), 0)) THEN 0
				ELSE ABS(ISNULL(SUM(A.NetAssetVol), 0)) - ABS(ISNULL(SUM(A.NetItemVol), 0)) * CASE WHEN SUM(A.NetAssetVol) < 0 THEN -1 ELSE 1 END
			  END, 0) [AvailableCapacity(+Buy,-Sell)],
		--New Logic
		CASE
			WHEN ABS(ISNULL(SUM(A.NetAssetVol), 0)) < ABS(ISNULL(SUM(A.NetItemVol), 0)) THEN ''Yes''
			ELSE ''No''
		END AS [OverHedged]
	FROM portfolio_hierarchy sub
	INNER JOIN portfolio_hierarchy stra
		INNER JOIN (
				SELECT COALESCE (At.curve_id, it.curve_id) AS curve_id,
					COALESCE(At.fas_book_id, it.fas_book_id) AS fas_book_id,
					COALESCE (At.IndexName, it.IndexName) AS IndexName,
					COALESCE (At.ced, it.ced) AS ContractMonth,
					COALESCE (At.dvf, it.dvf) AS VolumeFrequency,
					COALESCE (AUOM.uom_name, IUOM.uom_name) AS VolumeUOM,
			        ISNULL(At.NetAssetVol, 0) AS NetAssetVol,
					ISNULL(it.NetItemVol, 0) AS NetItemVol
				FROM (
					SELECT fas_book_id,
						contract_expiration_date AS ced,
						IndexName,
						deal_volume_frequency AS dvf,
						SUM(NetAssetVol) AS NetAssetVol,
						sui,
						MAX(curve_id) curve_id
					FROM #tempAsset
					GROUP BY fas_book_id, contract_expiration_date, IndexName, deal_volume_frequency, sui
				) AT INNER JOIN source_uom AUOM ON At.sui = AUOM.source_uom_id
				FULL OUTER JOIN source_uom IUOM INNER JOIN (
					SELECT fas_book_id,
						contract_expiration_date AS ced,
						SUM(NetItemVol) AS NetItemVol,
						deal_volume_frequency AS dvf,
						IndexName,
						sui,
						MAX(curve_id) curve_id
					FROM #tempItems
					GROUP BY fas_book_id, contract_expiration_date, deal_volume_frequency, sui, IndexName
				) it ON IUOM.source_uom_id = it.sui ON At.fas_book_id = it.fas_book_id AND At.ced = it.ced AND At.IndexName = it.IndexName
			) A INNER JOIN portfolio_hierarchy book ON A.fas_book_id = book.entity_id
				ON stra.entity_id = book.parent_entity_id
				ON sub.entity_id = stra.parent_entity_id
			GROUP BY sub.entity_name, stra.entity_name, book.entity_name, A.IndexName,  A.ContractMonth,  A.VolumeFrequency, A.VolumeUOM
'

EXEC spa_print @sql_SelectS
EXEC(@sql_SelectS)

DECLARE @as_of_date_month VARCHAR(10)
DECLARE @sql_from VARCHAR(MAX)
DECLARE @fld_contract_month VARCHAR(2000)
DECLARE @sql_order_by VARCHAR(2000)

SET @as_of_date_month = CONVERT(VARCHAR(8), CAST(@as_of_date AS DATETIME), 120) + '01'

IF @summary_option = 's'
BEGIN
	IF @granularity_type = 't'
	BEGIN
		SET @sql_from = '
			FROM #tmp_s s
			INNER JOIN generic_mapping_values g ON g.clm1_value = s.curve_id
			INNER JOIN generic_mapping_header h ON g.mapping_table_id = h.mapping_table_id
				AND h.mapping_name = ''' + @tenor_name + '''
			INNER JOIN [dbo].[risk_tenor_bucket_detail] b ON CAST(b.bucket_header_id AS VARCHAR(100)) = g.clm2_value
				AND b.tenor_name = CONVERT(VARCHAR(3), CAST(''' + @as_of_date_month + ''' AS DATETIME), 107)
				AND s.ContractMonth BETWEEN CAST(YEAR(''' + @as_of_date_month + ''') + relative_year_from AS VARCHAR) + ''-'' + RIGHT(''0'' + CAST(tenor_from AS VARCHAR),2) + ''-01''
				AND CAST(YEAR(''' + @as_of_date_month + ''') + relative_year_to AS VARCHAR) + ''-'' + RIGHT(''0'' + CAST(tenor_to AS VARCHAR), 2) + ''-01''
		'

		SET @fld_contract_month = ',
			NULL [Contract Month],
			b.tenor_description [TenorBucket],
			dbo.FNAUserDateFormat(CAST(YEAR(''' + @as_of_date_month + ''') + relative_year_from AS VARCHAR) + ''-'' + RIGHT(''0'' + CAST(tenor_from AS VARCHAR), 2) + ''-01'', ''' + dbo.FNADBUser() + ''') [TenorStart],
			dbo.FNAUserDateFormat(CAST(year(''' + @as_of_date_month + ''') + relative_year_to AS VARCHAR) + ''-'' + RIGHT(''0'' + CAST(tenor_to AS VARCHAR), 2) + ''-01'', ''' + dbo.FNADBUser() + ''') [TenorEnd] '
		
		SET @sql_order_by = ''
		
		SET @sql_SelectS = '
			SELECT ' +
				CASE
					WHEN @summary_option_orginal = 'l' THEN '
						sub_id,
						stra_id,
						book_id,
						curve_id, ' 
					ELSE '
						NULL [sub_id],
						NULL [stra_id],
						NULL [book_id],
						NULL [curve_id], '
				END + '
				Subsidiary,
				Strategy,
				Book,
				IndexName,
				SUM([NetAssetVol(+Buy,-Sell)]) [NetAssetVol(+Buy,-Sell)],
				SUM([NetItemVol(+Buy,-Sell)]) [NetItemVol(+Buy,-Sell)],
				NULL [type],
				NULL [deal_id],
				MAX(VolumeFrequency) VolumeFrequency,
				MAX(VolumeUOM) VolumeUOM,
				NULL [volume],
				CASE
					WHEN ABS(SUM([NetAssetVol(+Buy,-Sell)])) < ABS(SUM([NetItemVol(+Buy,-Sell)])) THEN 0
					ELSE ABS(ABS(SUM([NetAssetVol(+Buy,-Sell)])) - ABS(SUM([NetItemVol(+Buy,-Sell)]))) *
					CASE
						WHEN SUM([NetAssetVol(+Buy,-Sell)]) < 0 THEN -1
						ELSE 1
					END
				END [AvailableCapacity(+Buy,-Sell)],
				CASE
					WHEN ABS(SUM([NetAssetVol(+Buy,-Sell)])) < ABS(SUM([NetItemVol(+Buy,-Sell)])) THEN ''Yes''
					ELSE ''No''
				END [OverHedged]
				' + @fld_contract_month + '
			' + @sql_from + '
			GROUP BY ' + 
			CASE
				WHEN @summary_option_orginal = 'l' THEN 
				'sub_id, stra_id, book_id, curve_id, ' 
				ELSE '' 
			END + '
			Subsidiary, Strategy, Book,IndexName, b.tenor_description,
			CAST(YEAR(''' + @as_of_date_month + ''') + relative_year_from AS VARCHAR) + ''-'' + RIGHT(''0'' + CAST(tenor_from AS VARCHAR), 2) + ''-01'',
			CAST(YEAR(''' + @as_of_date_month + ''') + relative_year_to AS VARCHAR) + ''-'' + RIGHT(''0'' + CAST(tenor_to AS VARCHAR), 2) + ''-01'' '
		
		IF @exception_Flag = 'e'
		BEGIN
			SET @sql_SelectS = '
				SELECT NULL [sub_id],
					NULL [stra_id],
					NULL [book_id],
					NULL [curve_id],
					Subsidiary, 
					Strategy,
					Book,
					IndexName,
					CAST(SUM([NetAssetVol(+Buy,-Sell)]) AS NUMERIC(38,' + @round_value + ')) [NetAssetVol(+Buy,-Sell)],
					CAST(SUM([NetItemVol(+Buy,-Sell)]) AS NUMERIC(38,' + @round_value + ')) [NetItemVol(+Buy,-Sell)]
					NULL [Type],
					NULL [Deal ID]
					MAX(VolumeFrequency) VolumeFrequency,
					MAX(VolumeUOM) VolumeUOM,
					NULL [Volume],
					NULL [Available Capacity],
					MAX([OverHedged]) [OverHedged]
					' + @fld_contract_month + '
				' + @sql_from + ' WHERE OverHedged = ''YES''
				GROUP BY Subsidiary, Strategy, Book, IndexName, b.tenor_description,
					CAST(YEAR(''' + @as_of_date_month + ''') + relative_year_from AS VARCHAR) + ''-'' + RIGHT(''0'' + CAST(tenor_from AS VARCHAR), 2) + ''-01'',
					CAST(YEAR(''' + @as_of_date_month + ''') + relative_year_to AS VARCHAR) + ''-'' + RIGHT(''0'' + CAST(tenor_to AS VARCHAR), 2) + ''-01'' '
		END

		SET @sql_SelectS = @sql_SelectS + '
			ORDER BY Subsidiary, Strategy, Book, IndexName, TenorStart, TenorEnd'
	END
	ELSE
	BEGIN
		SET @sql_from = '
			FROM #tmp_s s
		'
		SET @fld_contract_month = 
			CASE
				WHEN (@granularity_type IN ('m', 'd')) THEN ',
					dbo.FNAContractMonthFormat(s.ContractMonth) [Contract Month],
					NULL [TenorBucket],
					NULL [TenorStart],
					NULL [TenorEnd]'
				ELSE ',
					dbo.FNAGetTermGrouping(s.ContractMonth, ''' + @granularity_type + ''') [Contract Month],
					NULL [TenorBucket],
					NULL [TenorStart],
					NULL [TenorEnd]'
			END

		SET @sql_order_by = ''

		IF @summary_option_orginal = 'l'
		BEGIN
			SET @fld_contract_month = ',
				NULL [Contract Month]
				NULL TenorBucket,
				dbo.FNAUserDateFormat(CAST(yr AS VARCHAR) + ''-'' + RIGHT(''0'' + CAST(mnth AS VARCHAR), 2) + ''-01'', ''' + dbo.FNADBUser() + ''') TenorStart,
				dbo.FNAUserDateFormat(CONVERT(VARCHAR(10),DATEADD(MONTH, 1, CAST(CAST(yr AS VARCHAR) + ''-'' + RIGHT(''0'' + CAST(mnth AS VARCHAR), 2) + ''-01'' AS DATETIME))-1, 120), ''' + dbo.FNADBUser() + ''') TenorEnd'
		END
		ELSE
		BEGIN
			SET @fld_contract_month = ',
				dbo.FNAUserDateFormat(ContractMonth, ''' + dbo.FNADBUser() + ''') [Contract Month],
				NULL [TenorBucket],
				NULL [TenorStart],
				NULL [TenorEnd]'
		END

		SET @sql_SelectS = '
			SELECT ' +
				CASE
					WHEN @summary_option_orginal = 'l' THEN '
						sub_id,
						stra_id,
						book_id,
						curve_id, '
					ELSE '
						NULL [sub_id],
						NULL [stra_id],
						NULL [book_id],
						NULL [curve_id], '
				END + '
				Subsidiary,
				Strategy,
				Book,
				IndexName,
				[NetAssetVol(+Buy,-Sell)],
				[NetItemVol(+Buy,-Sell)],
				NULL [Type],
				NULL [Deal ID],
				VolumeFrequency,
				VolumeUOM,
				NULL [Volume],
				CASE
					WHEN ABS([NetAssetVol(+Buy,-Sell)]) < ABS([NetItemVol(+Buy,-Sell)]) THEN 0 
					ELSE 
						(ABS([NetAssetVol(+Buy,-Sell)]) - ABS([NetItemVol(+Buy,-Sell)])) * 
						CASE
							WHEN [NetAssetVol(+Buy,-Sell)] < 0 THEN -1 
							ELSE 1
						END
					END [AvailableCapacity(+Buy,-Sell)],
				CASE
					WHEN ABS([NetAssetVol(+Buy,-Sell)]) < ABS([NetItemVol(+Buy,-Sell)]) THEN ''Yes''
					ELSE ''No''
				END [OverHedged]
				' + @fld_contract_month + '
				' + @sql_from

		IF @exception_Flag = 'e'
		BEGIN
			SET @sql_SelectS = '
				SELECT NULL [sub_id],
					NULL [stra_id],
					NULL [book_id],
					NULL [curve_id],
					Subsidiary,
					Strategy,
					Book, 
					IndexName,
					CAST ([NetAssetVol(+Buy,-Sell)] AS NUMERIC(38,' + @round_value + ')) [NetAssetVol(+Buy,-Sell)],
					CAST ([NetItemVol(+Buy,-Sell)] AS NUMERIC(38,' + @round_value + ')) [NetItemVol(+Buy,-Sell)],
					NULL [Type],
					NULL [Deal ID],
					VolumeFrequency,
					VolumeUOM,
					NULL [volume],
					NULL [Available Capacity],
					[OverHedged]
				' + @fld_contract_month+'
				' + @sql_from + '
				WHERE OverHedged = ''YES'' '
		END
			
		IF @summary_option_orginal = 'l' AND @granularity_type = 'm'
		BEGIN
			SET @sql_SelectS = @sql_SelectS + '
				ORDER BY sub_id, stra_id, book_id, curve_id, yr, mnth '
		END
		ELSE
		BEGIN
			SET @sql_SelectS = @sql_SelectS + '
				ORDER BY Subsidiary, Strategy, Book, IndexName ' +
				CASE WHEN (@granularity_type IN ( 's', 'q') AND @exception_flag = 'e') THEN ', RIGHT(contractMonth, 4), LEFT(contractMonth, 1)'
					WHEN (@granularity_type IN ( 'm', 'd')) THEN ', CONVERT(DATETIME, REPLACE(ContractMonth, ''-'', ''-1-''), 102)' 
					WHEN (@granularity_type = 'a') THEN ', ContractMonth'
					ELSE ' , SUBSTRING(dbo.FNAGetTermGrouping(ContractMonth , ''' + @granularity_type + ''') , LEN(dbo.FNAGetTermGrouping(ContractMonth , ''' + @granularity_type + ''')) -3, 4),
						dbo.FNAGetTermGrouping(ContractMonth , ''' + @granularity_type + ''') '
				END
		END
	END

	EXEC spa_print '************************************8', @sql_SelectS, '************************************8'
	EXEC(@sql_SelectS)
END
ELSE
BEGIN
	 CREATE TABLE #tmp_d (
		book_id INT,
		curve_id INT,
		yr INT,
		mnth INT,
		ContractMonth DATETIME,
		[Type] VARCHAR(15) COLLATE DATABASE_DEFAULT,
		DealID  VARCHAR(150) COLLATE DATABASE_DEFAULT,
		VolumeFrequency  VARCHAR(50) COLLATE DATABASE_DEFAULT,
		VolumeUOM VARCHAR(50) COLLATE DATABASE_DEFAULT,
		[NetAssetVol(+Buy,-Sell)] NUMERIC(26,10),
		source_deal_header_id INT
	)

	SET @sql_SelectD = '
		INSERT INTO #tmp_d (
			book_id,
			curve_id,
			yr,
			mnth,
			ContractMonth,
			[Type],
			DealID,
			VolumeFrequency,
			VolumeUOM,
			[NetAssetVol(+Buy,-Sell)],
			source_deal_header_id
		)
		SELECT a.fas_book_id,
			A.curve_id,
			YEAR(A.ContractMonth) Yr,
			MONTH(A.ContractMonth) mnth,
			A.ContractMonth,
			Type,
			A.DealID,
			A.VolumeFrequency,
			A.VolumeUOM, 
			ROUND(A.[Vol], 0) AS [NetAssetVol(+Buy,-Sell)],
			A.source_deal_header_id
		FROM portfolio_hierarchy sub
		INNER JOIN portfolio_hierarchy stra
			INNER JOIN (
				SELECT fas_book_id,
					IndexName,
					contract_expiration_date AS ContractMonth,
					''Asset'' Type,
					deal_id DealID,
					deal_volume_frequency AS VolumeFrequency,
					SUM(NetAssetVol) AS Vol,
					MAX(uom_name) AS VolumeUOM,
					MAX(source_deal_header_id) source_deal_header_id,
					curve_id
				FROM  #tempAsset
				LEFT OUTER JOIN source_uom UOM ON sui = UOM.source_uom_id
				GROUP BY fas_book_id, IndexName, contract_expiration_date, deal_id, deal_volume_frequency, sui, curve_id
				UNION
				SELECT fas_book_id,
					IndexName,
					contract_expiration_date AS ContractMonth,
					''Items'' Type,
					deal_id DealID,
					deal_volume_frequency AS VolumeFrequency,
					SUM(NetItemVol) AS Vol,
					MAX(uom_name) AS VolumeUOM,
					MAX(source_deal_header_id) source_deal_header_id,
					curve_id
				FROM #tempItems
				LEFT OUTER JOIN source_uom UOM ON sui = UOM.source_uom_id
				GROUP BY fas_book_id, IndexName, contract_expiration_date, deal_id, deal_volume_frequency, sui, curve_id
			) A INNER JOIN portfolio_hierarchy book ON A.fas_book_id = book.entity_id 
				ON stra.entity_id = book.parent_entity_id
				ON sub.entity_id = stra.parent_entity_id '

	EXEC spa_print @sql_SelectD
	EXEC(@sql_SelectD)

	SET @sql_SelectD = '
		SELECT NULL [sub_id],
			NULL [stra_id],
			NULL [book_id],
			NULL [curve_id],
			SummaryA.Subsidiary,
			SummaryA.Strategy,
			SummaryA.Book,
			SummaryA.IndexName [Index Name],
			CAST(SummaryA.[NetAssetVol(+Buy,-Sell)] AS NUMERIC(38,' + @round_value + ')) [Net Asset Vol (+Buy,-Sell)],
			CAST(SummaryA.[NetItemVol(+Buy,-Sell)] AS NUMERIC(38,' + @round_value + ')) [Net Item Vol (+Buy,-Sell)],
			A.Type,
			dbo.FNATRMWinHyperlink(''a'', 10131010, A.DealId, ABS(A.source_deal_header_id),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0) AS [Deal ID],
			A.VolumeFrequency [Volume Frequency],
			A.VolumeUOM [Volume UOM],
			CAST(A.[NetAssetVol(+Buy,-Sell)] AS NUMERIC(38,' + @round_value + ')) Volume,
			NULL [Available Capacity],
			SummaryA.[OverHedged] [Over Hedged],
			dbo.FNADateFormat(SummaryA.ContractMonth) [Contract Month],
			NULL [TenorBucket],
			NULL [TenorStart],
			NULL [TenorEnd]
		FROM #tmp_d A
		INNER JOIN #tmp_s SummaryA ON A.book_id = SummaryA.book_id
			AND A.curve_id = SummaryA.curve_id
			AND A.yr = SummaryA.yr
			AND A.mnth = SummaryA.mnth
		ORDER BY SummaryA.Subsidiary, SummaryA.Strategy, SummaryA.Book, SummaryA.IndexName, CONVERT(DATETIME, REPLACE(A.ContractMonth, ''-'', ''-1-''), 102), A.Type, A.DealId'
				
	EXEC spa_print @sql_SelectD
	EXEC(@sql_SelectD)
END

GO