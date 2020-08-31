-- =============================================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Create date: 2015-08-24
-- Description: Generic SP for insert/update values in the table portfolio_group_book
 
-- Params:
-- @flag CHAR(1)        -  flag 
--						- 'i' - Insert Data 
--						- 'd' - delete data
-- @xml  VARCHAR(MAX) - @xml string of the Data to be inserted/updated
-- =============================================================================================================================
IF OBJECT_ID(N'[dbo].[spa_portfolio_group_book]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_portfolio_group_book]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_portfolio_group_book]
    @flag CHAR(1),
    @portfolio_group_book_id VARCHAR(500) = NULL,
    @portfolio_group_id INT = NULL,
    @book_name VARCHAR(500) = NULL,
    @book_description VARCHAR(1000) = NULL,
    @book_parameter VARCHAR(5000) = NULL,
	--added for new fx
	@xml VARCHAR(MAX) = NULL,
	@mapping_source_usage_id VARCHAR(MAX) = NULL,
	@mapping_source_value_id INT = 23200
AS
SET NOCOUNT ON
DECLARE @sql VARCHAR(MAX), @idoc INT,
	@sub_book_id VARCHAR(MAX) = NULL
 
IF @flag = 's'
BEGIN 
	SELECT pmt1.trader_id,
		   pmc2.commodity_id,
		   pmdt.deal_type_id,
		   pmc1.counterparty_id,
		   --pmt2.term_start,
		   --pmt2.term_end,
		   dbo.FNAGetSQLStandardDate(pmt2.term_start) term_start,
		   dbo.FNAGetSQLStandardDate(pmt2.term_end) term_end,
		   pmt2.starting_month,
		   pmt2.no_of_month,
		   pmb.entity_id,
		   pmt2.fixed_term,
		   pmt2.relative_term,
		   pms.portfolio_group_id
	FROM  portfolio_mapping_source pms
	LEFT JOIN portfolio_mapping_trader pmt1 ON pms.portfolio_mapping_source_id = pmt1.portfolio_mapping_source_id
	LEFT JOIN portfolio_mapping_counterparty pmc1 ON pms.portfolio_mapping_source_id = pmc1.portfolio_mapping_source_id
	LEFT JOIN portfolio_mapping_commodity pmc2 ON pms.portfolio_mapping_source_id = pmc2.portfolio_mapping_source_id
	LEFT JOIN portfolio_mapping_tenor pmt2 ON pms.portfolio_mapping_source_id = pmt2.portfolio_mapping_source_id
	LEFT JOIN portfolio_mapping_book pmb ON pms.portfolio_mapping_source_id = pmb.portfolio_mapping_source_id
	LEFT JOIN portfolio_mapping_deal_type pmdt ON pms.portfolio_mapping_source_id = pmdt.portfolio_mapping_source_id
	WHERE pms.mapping_source_usage_id = @mapping_source_usage_id
		AND pms.mapping_source_value_id = @mapping_source_value_id
END
ELSE IF @flag = 'a'
BEGIN
    SELECT pgb.portfolio_group_book_id,
           pgb.portfolio_group_id,
           pgb.book_name,
           pgb.book_description,
           pgb.book_parameter
    FROM   portfolio_group_book pgb
    WHERE  pgb.portfolio_group_book_id = @portfolio_group_book_id
END

ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
    EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	IF OBJECT_ID('tempdb..#temp_portfolio_group_book') IS NOT NULL
		DROP TABLE #temp_portfolio_group_book
	SELECT
		trader,
		commodity_id,
		deal_type,
		counterparty,
		term_start,
		term_end,
		starting_month,
		no_of_month,
		limit_id
		INTO #temp_portfolio_group_book
	FROM OPENXML(@idoc, '/Root/FormXML', 1)
	WITH (
		trader INT,
		commodity_id INT,
		deal_type INT,
		counterparty INT,
		term_start DATE,
		term_end DATE,
		starting_month DATE,
		no_of_month INT,
		limit_id INT
	)
	UPDATE pgb
		SET trader = t.trader,
			commodity_id = t.commodity_id,
			deal_type = t.deal_type,
			counterparty = t.counterparty,
			term_start = t.term_start,
			term_end = t.term_end,
			starting_month = t.starting_month,
			no_of_month = t.no_of_month
	FROM #temp_portfolio_group_book AS t
	INNER JOIN portfolio_group_book pgb ON pgb.limit_id = @mapping_source_usage_id

	EXEC spa_ErrorHandler 0, 
		'Portfolio Book Filter', 
		'spa_portfolio_group_book', 
		'Success', 
		'Data updated successfully.',
		''
	END TRY
	BEGIN CATCH
	EXEC spa_ErrorHandler -1,
			'Portfolio Book Filter',
			'spa_portfolio_group_book',
			'Failed',
			'Data saving failed.',
			''
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY 
	SET @sql = '
	DELETE FROM portfolio_group_book
	WHERE portfolio_group_book_id IN (' + @portfolio_group_book_id + ')'
	
	exec spa_print @sql
	EXEC(@sql)
	
	EXEC spa_ErrorHandler 0,
			'portfolio_group_deal',
			'spa_portfolio_group_deal',
			'Success',
			'Delete portfolio_group_deal record success.',
			''
	END TRY
	BEGIN CATCH
	EXEC spa_ErrorHandler -1,
			'portfolio_group_book',
			'spa_portfolio_group_book',
			'Failed',
			'Delete portfolio_group_book record failed.',
			''
	END CATCH
END

ELSE IF @flag = 'f'
BEGIN
	SET @sub_book_id = ''
	IF OBJECT_ID('tempdb..#temp_sub_book_ids') IS NOT NULL
		DROP TABLE #temp_sub_book_ids

	SELECT [entity_id] INTO #temp_sub_book_ids
	FROM portfolio_mapping_source pms
		INNER JOIN portfolio_mapping_book pmb ON pms.portfolio_mapping_source_id = pmb.portfolio_mapping_source_id
	WHERE pms.mapping_source_usage_id = @mapping_source_usage_id
		AND pms.mapping_source_value_id = @mapping_source_value_id

	SELECT @sub_book_id = COALESCE(
			   CASE 
					WHEN @sub_book_id = '' THEN CAST([entity_id] AS VARCHAR(10))
					ELSE @sub_book_id + ',' + CAST([entity_id] AS VARCHAR(10))
			   END,
			   ''
		   )
	FROM #temp_sub_book_ids

	SELECT @sub_book_id sub_book_ids
END