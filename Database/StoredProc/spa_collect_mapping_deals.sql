/*
* Owner : sbohara@pioneersolutionsglobal.com
* Description : Retrieve deals individual and from book using new deal/book saving method
* Date: 2016-Feb-24     
*/

IF OBJECT_ID(N'[dbo].[spa_collect_mapping_deals]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_collect_mapping_deals]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_collect_mapping_deals]
	@as_of_date DATE,
    @mapping_source_value_id 	INT,
    @mapping_source_usage_id 	INT,
    @deal_table					VARCHAR(500) = NULL
AS
BEGIN
	DECLARE @sql VARCHAR(MAX),
		@portfolio_mapping_source_value_id INT = 23202 --Collect deals from portfolio which is mapped to the criteria
		
	IF OBJECT_ID(@deal_table) IS NOT NULL
	    EXEC ('DROP TABLE ' + @deal_table)
	    
	EXEC ('CREATE TABLE ' + @deal_table + '(source_deal_header_id INT, real_deal VARCHAR(1))')
	
	IF OBJECT_ID('tempdb..#tmp_final_deals') IS NOT NULL
		DROP table #tmp_final_deals
		
	IF OBJECT_ID('tempdb..#tmp_criteria_filters') IS NOT NULL
		DROP table #tmp_criteria_filters
		
	IF OBJECT_ID('tempdb..#tmp_portfolio_filters') IS NOT NULL
		DROP table #tmp_portfolio_filters
		
	CREATE TABLE #tmp_final_deals(deal_id INT NULL, deal_date DATETIME)
	
	--Criteria Book Filter
	SELECT DISTINCT pmt.trader_id,
		pmc.commodity_id,
		pmdt.deal_type_id,
		pmco.counterparty_id
	INTO #tmp_criteria_filters	
	FROM portfolio_mapping_source pms
	LEFT JOIN portfolio_mapping_trader pmt ON pmt.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
	LEFT JOIN portfolio_mapping_commodity pmc ON pmc.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
	LEFT JOIN portfolio_mapping_deal_type pmdt ON pmdt.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
	LEFT JOIN portfolio_mapping_counterparty pmco ON pmco.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
	WHERE pms.mapping_source_value_id = @mapping_source_value_id
	AND pms.mapping_source_usage_id = @mapping_source_usage_id
	
	CREATE NONCLUSTERED INDEX indx_criteria_book_filter ON #tmp_criteria_filters (trader_id, commodity_id, deal_type_id, counterparty_id)--, term_start, term_end)

	--Portfolio Book Filter
	SELECT DISTINCT pmt.trader_id,
		pmc.commodity_id,
		pmdt.deal_type_id,
		pmco.counterparty_id
	INTO #tmp_portfolio_filters	
	FROM portfolio_mapping_source pms
	LEFT JOIN portfolio_mapping_trader pmt ON pmt.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
	LEFT JOIN portfolio_mapping_commodity pmc ON pmc.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
	LEFT JOIN portfolio_mapping_deal_type pmdt ON pmdt.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
	LEFT JOIN portfolio_mapping_counterparty pmco ON pmco.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
	WHERE pms.mapping_source_value_id = @portfolio_mapping_source_value_id
	AND pms.mapping_source_usage_id = (SELECT portfolio_group_id FROM portfolio_mapping_source WHERE mapping_source_value_id = @mapping_source_value_id AND mapping_source_usage_id = @mapping_source_usage_id)
	
	CREATE NONCLUSTERED INDEX indx_portfolio_book_filter ON #tmp_portfolio_filters (trader_id, commodity_id, deal_type_id, counterparty_id)--, term_start, term_end)
				
	--Criteria Mapping deal
	INSERT INTO #tmp_final_deals(deal_id, deal_date)
	SELECT DISTINCT pmd.deal_id, sdh.deal_date
	FROM portfolio_mapping_source pms
	INNER JOIN  portfolio_mapping_deal pmd ON pmd.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = pmd.deal_id
		AND sdh.deal_status <> 5607
	WHERE pms.mapping_source_value_id = @mapping_source_value_id AND pms.mapping_source_usage_id = @mapping_source_usage_id
	UNION
	--Criteria Mapping book
	SELECT DISTINCT sdh.source_deal_header_id, sdh.deal_date
	FROM portfolio_mapping_source pms
	INNER JOIN portfolio_mapping_book pmb ON pmb.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
	INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = pmb.entity_id
	INNER JOIN source_deal_header sdh ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
		AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
		AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
		AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		AND sdh.deal_status <> 5607
	INNER JOIN #tmp_criteria_filters tf ON ISNULL(tf.trader_id, sdh.trader_id) = sdh.trader_id
		AND coalesce(tf.commodity_id, sdh.commodity_id,'') = ISNULL(sdh.commodity_id,'')
		AND coalesce(tf.deal_type_id, sdh.source_deal_type_id,'') =ISNULL( sdh.source_deal_type_id,'')
		AND ISNULL(tf.counterparty_id, sdh.counterparty_id) = sdh.counterparty_id
	WHERE pms.mapping_source_value_id = @mapping_source_value_id AND pms.mapping_source_usage_id = @mapping_source_usage_id	
	UNION
	--Portfolio Mapping Deal
	SELECT DISTINCT pmd.deal_id, sdh.deal_date
	FROM portfolio_mapping_source pms
	INNER JOIN  portfolio_mapping_deal pmd ON pmd.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
	INNER JOIN (SELECT 
					portfolio_group_id 
				FROM portfolio_mapping_source pms 
				WHERE pms.mapping_source_value_id = @mapping_source_value_id AND pms.mapping_source_usage_id = @mapping_source_usage_id) msui ON msui.portfolio_group_id = pms.mapping_source_usage_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = pmd.deal_id
		AND sdh.deal_status <> 5607
	WHERE pms.mapping_source_value_id = @portfolio_mapping_source_value_id
	UNION
	--Portfolio Mapping Book
	SELECT DISTINCT sdh.source_deal_header_id, sdh.deal_date
	FROM portfolio_mapping_source pms
	INNER JOIN portfolio_mapping_book pmb ON pmb.portfolio_mapping_source_id = pms.portfolio_mapping_source_id
	INNER JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = pmb.entity_id
	INNER JOIN source_deal_header sdh ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
		AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
		AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
		AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
		AND sdh.deal_status <> 5607
	INNER JOIN (SELECT 
					portfolio_group_id 
				FROM portfolio_mapping_source pms 
				WHERE pms.mapping_source_value_id = @mapping_source_value_id AND pms.mapping_source_usage_id = @mapping_source_usage_id) msui ON msui.portfolio_group_id = pms.mapping_source_usage_id
	INNER JOIN #tmp_portfolio_filters tf ON ISNULL(tf.trader_id, sdh.trader_id) = sdh.trader_id
		AND coalesce(tf.commodity_id, sdh.commodity_id,'') = ISNULL(sdh.commodity_id,'')
		AND coalesce(tf.deal_type_id, sdh.source_deal_type_id,'') =ISNULL( sdh.source_deal_type_id,'')
		AND ISNULL(tf.counterparty_id, sdh.counterparty_id) = sdh.counterparty_id
	WHERE pms.mapping_source_value_id = @portfolio_mapping_source_value_id
	
	SET @sql = '
	INSERT INTO ' + @deal_table + ' (source_deal_header_id, real_deal)
	SELECT deal_id, ''y'' FROM #tmp_final_deals
	WHERE 1 = 1 ' +

	CASE WHEN @as_of_date IS NOT NULL THEN ' AND deal_date <= ''' + CAST(@as_of_date AS VARCHAR) + '''' ELSE '' END
	
	EXEC(@sql)
END