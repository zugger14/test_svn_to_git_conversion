IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_view_target_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_view_target_report]
GO
/*
/* SP Created By: Shushil Bohara 
 * sbohara@pioneersolutionsglobal.com
 * Created Dt: 20-August-2017
 * Description: Logic to display target
 * For: Target | Sales | Banked/Purchases | Assigned/Transfers
 */
 * */

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_view_target_report]
	@summary_option VARCHAR(100) = 's',
	@sub VARCHAR(MAX) = NULL,
	@stra VARCHAR(MAX) = NULL,
	@book VARCHAR(MAX) = NULL,
	@comp_yr_from INT = NULL,
	@comp_yr_to INT = NULL,
	@assignment_type_value_id INT = NULL,
	@assigned_state varchar(8000) = NULL,
	@report_type CHAR(1) = 'i',
	@priority_group_id INT = NULL,
	@target_type CHAR(1) = NULL,
	@tier_value_id VARCHAR(MAX) = NULL,
	@round INT = 2,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0,		--'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL
AS

SET NOCOUNT ON
/*
DECLARE
	@summary_option VARCHAR(100) = 'h', --t,p,g,h,e
	@sub VARCHAR(max) = '250',			  
	@stra VARCHAR(max) = '251',			  
	@book VARCHAR(max) = '252',			  
	@comp_yr_from INT = '5518',			  
	@comp_yr_to INT = '5536',
	@assignment_type_value_id INT = '5146',
	@assigned_state varchar(8000) = '5098',
	@report_type CHAR(1) = 'a',
	@priority_group_id INT = '12',
	@target_type CHAR(1) = 'r',
	@tier_value_id VARCHAR(MAX) = NULL,
	@round INT = 2,
	@batch_process_id VARCHAR(250) = NULL

	--EXEC spa_view_target_report 'p','250','251','252','5518','5536','5146','5098','i',NULL,'r',NULL,'2'
	--EXEC spa_view_target_report 'g','250','251','252','5518','5536','5146','5098','i',NULL,'r',NULL,'2'
--*/
	DECLARE @Sql_Select VARCHAR(MAX), @Sql_Where VARCHAR(max), @sql VARCHAR(MAX)
	SET @Sql_Where = ''

	IF @comp_yr_from IS NOT NULL 
		SELECT @comp_yr_from = code FROM static_data_value WHERE TYPE_ID = 10092 AND value_id = @comp_yr_from
	ELSE 
		SET @comp_yr_from = 1900

	IF @comp_yr_to IS NOT NULL 
		SELECT @comp_yr_to = code FROM static_data_value WHERE TYPE_ID = 10092 AND value_id = @comp_yr_to
	ELSE 
		SET @comp_yr_to = 5000

	IF OBJECT_ID('tempdb..#target_value') IS NOT NULL 
		DROP TABLE #target_value

	CREATE TABLE #target_value(
		id INT,
		compliance_year INT,
		state_value_id INT,
		tier_value_id INT,
		total_target INT
	)
		
	IF OBJECT_ID('tempdb..#ssbm') IS NOT NULL
		DROP TABLE #ssbm

	CREATE TABLE #ssbm(    
		source_system_book_id1 INT,              
		source_system_book_id2 INT,              
		source_system_book_id3 INT,              
		source_system_book_id4 INT,              
		fas_deal_type_value_id INT,              
		book_deal_type_map_id INT,              
		fas_book_id INT,              
		stra_book_id INT,              
		sub_entity_id INT              
	 )    
 
	SET @Sql_Select= 'INSERT INTO #ssbm              
	SELECT source_system_book_id1,
		source_system_book_id2,
		source_system_book_id3,  
		source_system_book_id4,
		fas_deal_type_value_id,              
		book_deal_type_map_id,
		book.entity_id fas_book_id,
		book.parent_entity_id stra_book_id,  
		stra.parent_entity_id sub_entity_id               
	FROM source_system_book_map ssbm               
	INNER JOIN portfolio_hierarchy book (nolock) ON ssbm.fas_book_id = book.entity_id               
	INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id               
	WHERE 1=1 '              

	IF @sub IS NOT NULL              
	SET @Sql_Where = @Sql_Where + ' AND stra.parent_entity_id IN  ( ' + @sub + ') ' 
              
	IF @stra IS NOT NULL              
	SET @Sql_Where = @Sql_Where + ' AND (stra.entity_id IN(' + @stra + ' ))'    
         
	IF @book IS NOT NULL              
	SET @Sql_Where = @Sql_Where + ' AND (book.entity_id IN(' + @book + ')) '         
     
	SET @Sql_Select = @Sql_Select + @Sql_Where   

	--PRINT @sql_select             
	EXEC (@Sql_Select)
 
	/*******************************************1st Paging Batch START**********************************************/
	DECLARE @str_batch_table VARCHAR(8000)
	DECLARE @user_login_id VARCHAR(50)
	DECLARE @sql_paging VARCHAR(8000)
	DECLARE @is_batch bit
			 
	SET @str_batch_table = ''
	SET @user_login_id = dbo.FNADBUser() 

	SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END		

	IF @is_batch = 1
		SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)

    IF @batch_process_id IS NULL
			SET @batch_process_id = dbo.FNAGetNewID()
			
	IF @enable_paging = 1 --paging processing
	BEGIN		
		SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

		--retrieve data from paging table instead of main table
		IF @page_no IS NOT NULL  
		BEGIN
			SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no)    
			EXEC (@sql_paging)  
			RETURN  
		END
	END
	/*******************************************1st Paging Batch END**********************************************/ 

	DECLARE @str_target_table VARCHAR(100), @compliance_year INT, @str_allocation_table VARCHAR(100), @allocation_detail VARCHAR(100)

	SET @str_target_table = dbo.FNAProcessTableName('target', @user_login_id, @batch_process_id)
	SET @str_allocation_table = dbo.FNAProcessTableName('allocation', @user_login_id, @batch_process_id)
	SET @allocation_detail = dbo.FNAProcessTableName('sales_rec_', @user_login_id, @batch_process_id)

	IF OBJECT_ID(@str_target_table) IS NOT NULL EXEC ('DROP TABLE ' + @str_target_table)
	IF OBJECT_ID(@str_allocation_table) IS NOT NULL EXEC ('DROP TABLE ' + @str_allocation_table)
	IF OBJECT_ID(@allocation_detail) IS NOT NULL EXEC ('DROP TABLE ' + @allocation_detail)

	SET @sql = '
		CREATE TABLE ' + @str_target_table + '(
			id INT IDENTITY(1,1) NOT NULL,
			compliance_year INT,
			state_value_id INT,
			tier_value_id INT,
			total_target INT)'

	EXEC(@sql)

	SET @sql = '
		CREATE TABLE ' + @str_allocation_table + '(
			id INT IDENTITY(1,1) NOT NULL,
			compliance_year INT,
			tier_value_id INT,
			total_target INT)'

	EXEC(@sql)

	SET @sql = '
		CREATE TABLE ' + @allocation_detail + '(
			[row_unique_id] [int] IDENTITY(1,1) NOT NULL,
			[rec_deal_id] [int] NULL,
			[rec_deal_detail_id] [int] NULL,
			[deal_date] [varchar](50) NULL,
			[vintage] [varchar](50) NULL,
			[jurisdiction] [varchar](500) NULL,
			[gen_state] [varchar](500) NULL,
			[generator] [varchar](250) NULL,
			[obligation] [varchar](100) NULL,
			[volume_left] [numeric](38, 20) NULL,
			[volume_assign] [numeric](38, 20) NULL,
			[total_volume] [numeric](38, 20) NULL,
			[compliance_year] [int] NULL,
			[gen_state_value_id] [int] NULL,
			[technology] [varchar](500) NULL,
			[jurisdiction_state_id] [int] NULL,
			[tier] [varchar](500) NULL,
			[tier_value_id] [int] NULL)'

		EXEC(@sql)

	DECLARE cur_get_target CURSOR LOCAL FOR
	SELECT code FROM static_data_value WHERE TYPE_ID = 10092 AND code >= @comp_yr_from AND code <= @comp_yr_to ORDER BY code ASC
	OPEN cur_get_target

	FETCH NEXT FROM cur_get_target INTO @compliance_year
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC spa_find_assign_transation
			@flag = 't',
			@fas_sub_id = @sub,
			@fas_strategy_id = @stra,
			@fas_book_id = @book,
			@req_assignment_type = @assignment_type_value_id,
			@req_assigned_state = @assigned_state,
			@req_assignment_priority = @priority_group_id,
			@req_compliance_year = @compliance_year,
			@req_volume_type = @target_type,
			@inv_subsidiary_id = @sub,
			@inv_strategy_id = @stra,
			@inv_book_id = @book,
			@batch_process_id = @batch_process_id

	FETCH NEXT FROM cur_get_target INTO @compliance_year
	END
	CLOSE cur_get_target
	DEALLOCATE cur_get_target

	SET @sql = 'INSERT INTO #target_value 
		SELECT stt.* 
		FROM ' + @str_target_table + ' stt
		WHERE 1 = 1 ' +
		CASE WHEN @tier_value_id IS NOT NULL THEN ' AND stt.tier_value_id IN (' + @tier_value_id + ')' ELSE '' END

	EXEC(@sql)
	
	----New Code for collecting tier wise target from Assignment Logic for each compliance_year, jurisdiction --END

	IF OBJECT_ID('tempdb..#target') IS NOT NULL
		DROP TABLE #target

	CREATE TABLE #target(id INT IDENTITY(1,1),
		[year] INT, 
		jurisdiction_value_id INT, 
		jurisdiction VARCHAR(100) COLLATE DATABASE_DEFAULT,
		technology VARCHAR(100) COLLATE DATABASE_DEFAULT,
		gen_state VARCHAR(100) COLLATE DATABASE_DEFAULT,
		generator VARCHAR(100) COLLATE DATABASE_DEFAULT,
		generator_group VARCHAR(100) COLLATE DATABASE_DEFAULT,
		env_product VARCHAR(100) COLLATE DATABASE_DEFAULT, 
		tier_value_id INT, 
		[tier] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		assigned FLOAT, 
		banked FLOAT,
		sales FLOAT,
		[target] FLOAT,
		net FLOAT,
		priority_order INT
		)

	INSERT INTO #target(
		year,
		jurisdiction_value_id,
		jurisdiction,
		technology,
		gen_state,
		generator,
		generator_group,
		env_product,
		tier_value_id,
		tier,
		assigned,
		banked,
		sales,
		target)
	SELECT 
		tv.compliance_year AS [year],
		tv.state_value_id AS state_value_id, 
		jur.code AS jurisdiction,
		NULL AS technology, 
		NULL AS gen_state,
		NULL AS generator,
		NULL AS generator_group,
		NULL AS env_product,  
		tv.tier_value_id, 
		tier.code AS [tier],
		NULL AS assigned,
		NULL AS banked,
		NULL AS sales,
		tv.total_target AS [target]
	FROM #target_value tv
	LEFT JOIN static_data_value tier ON tier.value_id = tv.tier_value_id
	LEFT JOIN static_data_value jur ON jur.value_id = tv.state_value_id

	UNION ALL ----Assigned/Transfer
	SELECT 
		tv.compliance_year AS [year],
		tv.state_value_id AS state_value_id, 
		jur.code AS jurisdiction,
		CASE WHEN @summary_option = 't' OR @summary_option = 'p' THEN tech.code ELSE NULL END AS technology,
		CASE WHEN @summary_option = 'p' THEN stat.code ELSE NULL END AS gen_state, 
		CASE WHEN @summary_option = 'g' THEN rg.name ELSE NULL END AS generator, 
		CASE WHEN @summary_option = 'h' THEN rgg.generator_group_name ELSE NULL END AS generator_group,
		CASE WHEN @summary_option = 'e' THEN spcd.curve_name ELSE NULL END AS env_product, 
		tv.tier_value_id, 
		tier.code AS [tier],
		au.assigned_volume AS assigned,
		NULL AS banked,
		NULL AS sales, 
		NULL AS [target] 
	FROM source_deal_header sdh
	INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	LEFT JOIN rec_generator_group rgg ON rgg.generator_group_id = rg.generator_group_name
	INNER JOIN assignment_audit au ON au.source_deal_header_id = sdd.source_deal_detail_id
	INNER JOIN #target_value tv ON tv.state_value_id = au.state_value_id 
		AND tv.compliance_year = au.compliance_year
		AND tv.tier_value_id = au.Tier
	LEFT JOIN static_data_value tier ON tier.value_id = tv.tier_value_id
	LEFT JOIN static_data_value jur ON jur.value_id = tv.state_value_id
	LEFT JOIN static_data_value stat ON stat.value_id = rg.gen_state_value_id
	LEFT JOIN static_data_value tech ON tech.value_id = rg.technology
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = rg.source_curve_def_id

	UNION ALL --Banked/Purchases
	SELECT
		tv.compliance_year AS [year],
		tv.state_value_id AS state_value_id, 
		jur.code AS jurisdiction,
		CASE WHEN @summary_option = 't' OR @summary_option = 'p' THEN tech.code ELSE NULL END AS technology,
		CASE WHEN @summary_option = 'p' THEN stat.code ELSE NULL END AS gen_state,
		CASE WHEN @summary_option = 'g' THEN rg.name ELSE NULL END AS generator, 
		CASE WHEN @summary_option = 'h' THEN rgg.generator_group_name ELSE NULL END AS generator_group,
		CASE WHEN @summary_option = 'e' THEN spcd.curve_name ELSE NULL END AS env_product,
		tv.tier_value_id AS tier_type, 
		tier.code AS [tier],
		NULL AS assigned,
		sdd.volume_left AS banked,
		NULL AS sales, 
		NULL AS [target]
	FROM source_deal_header sdh
	INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN rec_generator rg ON rg.generator_id = sdh.generator_id
	LEFT JOIN rec_generator_group rgg ON rgg.generator_group_id = rg.generator_group_name
	LEFT JOIN gis_certificate gc ON gc.source_deal_header_id = sdd.source_deal_detail_id
		AND gc.state_value_id IN (@assigned_state)
	INNER JOIN #target_value tv ON tv.state_value_id = COALESCE(sdh.state_value_id, rg.state_value_id, gc.state_value_id) 
		AND tv.compliance_year = YEAR(sdd.term_start)
		AND tv.tier_value_id = COALESCE(sdh.tier_value_id, rg.tier_type, gc.tier_type)
	LEFT JOIN static_data_value tier ON tier.value_id = tv.tier_value_id
	LEFT JOIN static_data_value jur ON jur.value_id = tv.state_value_id
	LEFT JOIN static_data_value stat ON stat.value_id = rg.gen_state_value_id
	LEFT JOIN static_data_value tech ON tech.value_id = rg.technology
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = rg.source_curve_def_id
	WHERE sdh.header_buy_sell_flag = 'b'

	UNION ALL --Sales
	SELECT
		tv.compliance_year AS [year], 
		tv.state_value_id AS state_value_id, 
		jur.code AS jurisdiction,
		NULL AS technology,  
		NULL AS gen_state,
		NULL AS generator,
		NULL AS generator_group,
		NULL AS env_product, 
		tv.tier_value_id AS tier_type, 
		tier.code AS [tier], 
		NULL AS assigned,
		NULL AS banked,
		sdd.volume_left AS sales,
		NULL AS [target]
	FROM source_deal_header sdh
	INNER JOIN #ssbm ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #target_value tv ON tv.state_value_id = sdh.state_value_id 
		AND tv.compliance_year = YEAR(sdd.term_start)
		AND tv.tier_value_id = sdh.tier_value_id
	LEFT JOIN static_data_value tier ON tier.value_id = tv.tier_value_id
	LEFT JOIN static_data_value jur ON jur.value_id = tv.state_value_id
	WHERE sdh.assignment_type_value_id IS NULL
		AND ssbm.fas_deal_type_value_id NOT IN (409,405)
		AND sdh.header_buy_sell_flag = 's'

	--Allocation Logic Starts Here
	IF @report_type = 'a'
	BEGIN
		IF OBJECT_ID('tempdb..#tmp_target_allocation') IS NOT NULL
			DROP TABLE #tmp_target_allocation

		SELECT [year], tier_value_id,  ((ISNULL(SUM(target), 0)+ISNULL(SUM(sales), 0))-ISNULL(SUM(assigned), 0)) targets
		INTO #tmp_target_allocation
		FROM #target
		GROUP BY [year], tier_value_id
	
		DECLARE cur_allocation CURSOR LOCAL FOR
		SELECT DISTINCT year FROM #tmp_target_allocation WHERE targets > 0 ORDER BY year ASC
		OPEN cur_allocation

		FETCH NEXT FROM cur_allocation INTO @compliance_year
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC('DELETE FROM ' + @str_allocation_table)

			SET @sql = ' INSERT INTO ' + @str_allocation_table + '(compliance_year, tier_value_id, total_target)
				SELECT year, 
					tier_value_id, 
					targets 
				FROM #tmp_target_allocation
				WHERE 1 = 1
					AND targets > 0
					AND year = ' + CAST(@compliance_year AS VARCHAR)

			EXEC(@sql)

			EXEC spa_find_assign_transation
				@flag = 'a',
				@fas_sub_id = @sub,
				@fas_strategy_id = @stra,
				@fas_book_id = @book,
				@req_assignment_type = @assignment_type_value_id,
				@req_assigned_state = @assigned_state,
				@req_assignment_priority = @priority_group_id,
				@req_compliance_year = @compliance_year,
				@req_volume_type = 't',
				@inv_subsidiary_id = @sub,
				@inv_strategy_id = @stra,
				@inv_book_id = @book,
				@batch_process_id = @batch_process_id

		FETCH NEXT FROM cur_allocation INTO @compliance_year
		END
		CLOSE cur_allocation
		DEALLOCATE cur_allocation

		SET @sql = 'DELETE FROM #target WHERE banked IS NOT NULL
		INSERT INTO #target(
			year,
			jurisdiction_value_id,
			jurisdiction,
			technology,
			gen_state,
			generator,
			generator_group,
			env_product,
			tier_value_id,
			tier,
			assigned,
			banked,
			sales,
			target) 
		SELECT 
			ad.compliance_year AS [year],
			ad.jurisdiction_state_id AS state_value_id, 
			ad.jurisdiction AS jurisdiction,
			CASE WHEN ''' + @summary_option + ''' = ''t'' OR ''' + @summary_option + ''' = ''p'' THEN ad.technology ELSE NULL END AS technology,
			CASE WHEN ''' + @summary_option + ''' = ''p'' THEN ad.[gen_state] ELSE NULL END AS gen_state,
			CASE WHEN ''' + @summary_option + ''' = ''g'' THEN ad.generator ELSE NULL END AS generator,
			CASE WHEN ''' + @summary_option + ''' = ''h'' THEN rgg.generator_group_name ELSE NULL END AS generator_group, 
			CASE WHEN ''' + @summary_option + ''' = ''e'' THEN ad.obligation ELSE NULL END AS env_product,
			ad.tier_value_id AS tier_type, 
			ad.tier AS [tier],
			NULL AS assigned,
			ad.[volume_assign] AS banked,
			NULL AS sales, 
			NULL AS [target]
		FROM ' + @allocation_detail + ' ad
		LEFT JOIN rec_generator rg ON rg.name = ad.generator 
		LEFT JOIN rec_generator_group rgg ON rgg.generator_group_id = rg.generator_group_name'

		EXEC(@sql)
	END
	--Allocation Logic Ends Here

	----------Continuing With Common Logic for All Report-Type------------------
	IF OBJECT_ID('tempdb..#tmp_grouped_net') IS NOT NULL
		DROP TABLE #tmp_grouped_net

	SELECT tier_value_id, year, assigned, banked, sales, target, ((assigned+ CASE WHEN @report_type IN ('i', 'a') THEN banked ELSE 0 END )-(target+sales)) net
	INTO #tmp_grouped_net
	FROM(
		SELECT tier_value_id, year, ISNULL(SUM(assigned), 0) AS assigned, ISNULL(SUM(banked), 0) AS banked, ISNULL(SUM(sales), 0) AS sales, ISNULL(SUM(target), 0) AS target 
		FROM #target
		GROUP BY tier_value_id, year) t

	IF OBJECT_ID('tempdb..#target_without_grouping') IS NOT NULL
		DROP TABLE #target_without_grouping

	SELECT year,
		jurisdiction_value_id,
		jurisdiction,
		technology,
		gen_state,
		generator,
		generator_group,
		env_product,
		tier_value_id,
		tier,
		assigned,
		banked,
		sales,
		target,
		net 
	INTO #target_without_grouping FROM #target WHERE 1 = 2

	INSERT INTO #target_without_grouping(
		year,
		jurisdiction_value_id,
		jurisdiction,
		tier_value_id,
		tier,
		assigned,
		banked,
		sales,
		target)
	SELECT	
		[Year],
		MAX(jurisdiction_value_id) jurisdiction_value_id, 
		MAX(jurisdiction) jurisdiction, 
		tier_value_id, 
		MAX([Tier]) [Tier],
		SUM(assigned) assigned, 
		SUM(banked) banked,
		SUM([sales]) [sales],  
		SUM([target]) [target]
	FROM #target
	GROUP BY tier_value_id, [Year]

	UPDATE twg SET twg.net = tgn.net
	FROM #target_without_grouping twg
	INNER JOIN #tmp_grouped_net tgn ON tgn.year = twg.year
		AND tgn.tier_value_id = twg.tier_value_id

	DECLARE @tiers VARCHAR(1000), 
		@tiers_with_isnull VARCHAR(8000)

	SELECT @tiers = STUFF((
						(SELECT  '],['  + CAST(Tier AS VARCHAR(MAX))  
						FROM #target GROUP BY tier ORDER BY ISNULL(MAX(priority_order),99999) FOR XML PATH(''), root('MyString'), type 
			 ).value('/MyString[1]','varchar(max)')
					), 1, 2, '')

	-- populate variable with tiers ordered by priority and containing ISNULL
	SELECT @tiers_with_isnull = STUFF((
						(SELECT  '],ISNULL([' + Tier + '],0) ['  +  CAST(Tier AS VARCHAR(MAX))  
						FROM #target GROUP BY tier ORDER BY ISNULL(MAX(priority_order),99999) FOR XML PATH(''), root('MyString'), type 
			 ).value('/MyString[1]','varchar(max)')
					), 1, 2, '')
	
	SET @tiers = ISNULL(@tiers, '[None')
	SET @tiers_with_isnull = ISNULL(@tiers_with_isnull, '[None')

	SET @sql = '
		SELECT 
			CASE ROW_NUMBER() OVER (PARTITION BY [Year2] ORDER BY [Year2],[order])
				WHEN 1 THEN [Year2] 
				ELSE NULL 
			END [Year], 
			Type ' + 
			CASE 
				WHEN ISNULL(@summary_option, 'a') IN ('t') THEN ', [Technology] AS [Technology]' 
				WHEN ISNULL(@summary_option, 'a') = 'p' THEN ',[Technology] AS [Technology], [gen_state] as [Gen State]'
				WHEN ISNULL(@summary_option, 'a') = 'g' THEN ',[generator] AS [Generator]' 
				WHEN ISNULL(@summary_option, 'a') = 'h' THEN ',[generator_group] AS [Generator Group]'
				WHEN ISNULL(@summary_option, 'a') = 'e' THEN ',[Env_product] AS [Env Product]' ELSE '' END + ', 
			 ' + @tiers + '], 
			 Total 
			 ' + @str_batch_table + '
		FROM(
			SELECT [Year] AS Year2, 
				Type , 
				NULL Technology, 
				NULL gen_state, 
				NULL generator, 
				NULL generator_group,
				NULL env_product, 
				' + @tiers_with_isnull + '], 
				total_target AS total, 
				1 [order] 
			FROM (SELECT [Year], 
					ROUND([Target], ' + CAST(@round AS VARCHAR) + ') AS Target, 
					''Target'' AS [Type], 
					Tier, 
					ROUND(ta.total_target, ' + CAST(@round AS VARCHAR) + ') AS total_target 
				FROM #target_without_grouping twg
				CROSS APPLY(SELECT ISNULL(t.total_target, 0) AS total_target FROM
							(
							SELECT SUM([target]) AS total_target, year FROM #target_without_grouping GROUP BY [year]
							) t WHERE t.year = twg.year) ta ) AS sourceTable
				PIVOT
				(SUM([Target]) FOR Tier IN ( ' + @tiers + ']))
			AS PIVOTTable

			UNION ALL
			SELECT [Year] AS Year2 , 
				Type , 
				NULL Technology, 
				NULL gen_state, 
				NULL generator, 
				NULL generator_group,
				NULL env_product, 
				' + @tiers_with_isnull + '],
				total_sales AS total, 
				2 [order] 
			FROM (SELECT [Year], 
					ROUND(Sales, ' + CAST(@round AS VARCHAR) + ') AS sales,
					''Sales'' AS [Type], 
					Tier, 
					ROUND(ta.total_sales, ' + CAST(@round AS VARCHAR) + ') AS total_sales 
				FROM #target_without_grouping twg
				CROSS APPLY(SELECT ISNULL(t.total_sales,0) AS total_sales FROM
							(
							SELECT SUM(sales) total_sales, year 
							FROM #target_without_grouping WHERE sales <> 0 GROUP BY [year]
							) t WHERE t.year = twg.year) ta) AS sourceTable
				PIVOT
				(SUM(sales) FOR Tier IN ( ' + @tiers + ']))
			AS PIVOTTableS

			UNION ALL 
			SELECT [Year] AS Year2, 
				Type, 
				Technology, 
				gen_state, 
				generator, 
				generator_group, 
				env_product,
				' + @tiers_with_isnull + '], 
				total, 
				3 AS [order] 
			FROM (SELECT [Year], 
					ROUND([Assigned], ' + CAST(@round AS VARCHAR) + ') AS assigned, 
					''Assigned/Transfer'' [Type], 
					Technology, 
					gen_state, 
					generator, 
					generator_group, 
					env_product,
					ROUND(ta.total, ' + CAST(@round AS VARCHAR) + ') AS total,
					Tier 
				FROM #target twg 
				CROSS APPLY(SELECT ISNULL(t.total,0) AS total FROM
						(
						SELECT [year], 
							ISNULL(technology, ''-1'') AS technology, 
							ISNULL(gen_state, ''-1'') AS gen_state, 
							ISNULL(generator, ''-1'') AS generator, 
							ISNULL(generator_group, ''-1'') AS generator_group, 
							ISNULL(env_product, ''-1'') AS env_product,
							SUM(assigned) AS total 
						FROM #target
						WHERE assigned <> 0 AND assigned IS NOT NULL 
						GROUP BY [year], technology, gen_state, generator, generator_group, env_product 
						) t WHERE t.[year] = twg.[year]	
							AND ISNULL(twg.technology, ''-1'') = t.technology
							AND ISNULL(twg.gen_state, ''-1'') = t.gen_state
							AND ISNULL(twg.generator, ''-1'') = t.generator
							AND ISNULL(twg.generator_group, ''-1'') = t.generator_group
							AND ISNULL(twg.env_product, ''-1'') = t.env_product
							) ta WHERE assigned <> 0 AND assigned IS NOT NULL
				) AS sourceTable2
				PIVOT (SUM([Assigned]) FOR Tier IN ( ' + @tiers + ']))
			AS PIVOTTable2 ' + CASE WHEN @report_type IN ('i', 'a') THEN '

			UNION ALL 
			SELECT [Year] AS Year2, 
				Type, 
				Technology, 
				gen_state, 
				generator, 
				generator_group, 
				env_product,
				' + @tiers_with_isnull + '], 
				total, 
				4 [order] 
			FROM (SELECT [Year], 
					ROUND([Banked], ' + CAST(@round AS VARCHAR) + ') AS [Banked], 
					''Banked/Purchases'' AS [Type], 
					Technology, 
					gen_state, 
					generator, 
					generator_group, 
					env_product,
					ROUND(ta.total, ' + CAST(@round AS VARCHAR) + ') AS total,
					Tier 
				FROM #target twg 
				CROSS APPLY(SELECT ISNULL(t.total,0) AS total FROM
						(
						SELECT [year], 
							ISNULL(technology, ''-1'') AS technology, 
							ISNULL(gen_state, ''-1'') AS gen_state, 
							ISNULL(generator, ''-1'') AS generator, 
							ISNULL(generator_group, ''-1'') AS generator_group, 
							ISNULL(env_product, ''-1'') AS env_product,
							SUM(banked) total 
						FROM #target
						WHERE Banked <> 0 AND Banked IS NOT NULL 
						GROUP BY [year], technology, gen_state, generator, generator_group, env_product 
						) t WHERE t.[year] = twg.[year]	
							AND ISNULL(twg.technology, ''-1'') = t.technology
							AND ISNULL(twg.gen_state, ''-1'') = t.gen_state
							AND ISNULL(twg.generator, ''-1'') = t.generator
							AND ISNULL(twg.generator_group, ''-1'') = t.generator_group
							AND ISNULL(twg.env_product, ''-1'') = t.env_product
							) ta WHERE Banked <> 0 AND Banked IS NOT NULL
				) AS sourceTable
				PIVOT
				(SUM([Banked]) FOR Tier IN ( ' + @tiers + ']))
			PIVOTTable2 ' ELSE '' END + '

			UNION ALL 
			SELECT  [Year] as Year2, 
				''<b>'' + Type + ''<b>'',  
				''<b>'' + Technology +  ''</b>'', 
				''<b>'' + gen_state + ''</b>'',
				''<b>'' + generator + ''</b>'', 
				''<b>'' + generator_group + ''</b>'', 
				''<b>'' + env_product + ''</b>'',
				' + @tiers_with_isnull + '], 
				total, 
				5 [order] 
			FROM(SELECT [Year], 
					ROUND([Net], ' + CAST(@round AS VARCHAR) + ') AS Net, 
					''Net'' [Type], 
					Technology, 
					gen_state, 
					generator, 
					generator_group,
					env_product, 
					Tier, 
					ROUND(ta.Net_total, ' + CAST(@round AS VARCHAR) + ') total 
				FROM #target_without_grouping twg
				CROSS APPLY(SELECT ISNULL(t.Net_total,0) AS Net_total FROM
						(
						SELECT SUM(net) AS Net_total, [year] FROM #target_without_grouping GROUP BY [year]
						) t WHERE t.year = twg.year	) ta ) AS sourceTable2
				PIVOT
				(MAX([Net]) FOR Tier IN ( ' + @tiers + ']))
			PIVOTTable2
		) a ORDER BY [Year2],[order]'

	--PRINT(@sql)
	EXEC(@sql)
	/*******************************************2nd Paging Batch START**********************************************/
	--update time spent and batch completion message in message board
	IF @is_batch = 1
	BEGIN
		SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)   
		EXEC(@str_batch_table)                   

		SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_view_target_report', 'Target Report')         
		EXEC(@str_batch_table)        
		RETURN
	END

	--if it is first call from paging, return total no. of rows and process id instead of actual data
	IF @enable_paging = 1 AND @page_no IS NULL
	BEGIN
		SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
		EXEC(@sql_paging)
	END
	/*******************************************2nd Paging Batch END**********************************************/	