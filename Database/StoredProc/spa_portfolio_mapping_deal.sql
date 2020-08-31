-- =============================================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Create date: 2015-08-24
-- Description: Generic SP for insert/update values in the table portfolio_mapping_deal
 
-- Params:
-- @flag CHAR(1)        -  flag 
--						- 'i' - Insert Data 
--						- 'd' - delete data
-- @portfolio_mapping_deal_id
-- @mapping_source_value_id
-- @portfolio_mapping_source_id
-- @mapping_source_usage_id
-- @deal_id
-- @grid_xmlstring - xml string
-- =============================================================================================================================
IF OBJECT_ID(N'[dbo].[spa_portfolio_mapping_deal]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_portfolio_mapping_deal]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_portfolio_mapping_deal]
    @flag CHAR(1),
    @portfolio_mapping_deal_id VARCHAR(100) = NULL,
    @mapping_source_value_id INT = NULL,
	@portfolio_mapping_source_id INT = NULL,
    @mapping_source_usage_id INT = NULL,
    @deal_id VARCHAR(500) = NULL,
	@grid_xmlstring VARCHAR(MAX) = NULL
AS
	SET NOCOUNT ON
	DECLARE @sql VARCHAR(MAX),
	@idoc INT

IF @flag = 's'
BEGIN
    SELECT pmd.portfolio_mapping_deal_id [ID],
           dbo.FNAHyperLinkText(10131010, pmd.deal_id, pmd.deal_id) AS [Deal ID],
		   sdh.deal_id AS [Reference ID],
		   dbo.FNADateFormat(sdh.deal_date) AS [Deal Date],
		   CASE WHEN sdh.physical_financial_flag = 'p' THEN 'Physical' ELSE 'Financial' END [Physical/Financial],
		   sc.counterparty_name AS [Counterparty Name],
		   dbo.FNADateFormat(sdh.entire_term_start) AS [Term Start],
		   dbo.FNADateFormat(sdh.entire_term_end) AS [Term End]
    FROM portfolio_mapping_deal pmd
    INNER JOIN portfolio_mapping_source pms ON pms.portfolio_mapping_source_id = pmd.portfolio_mapping_source_id
    LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = pmd.deal_id
	LEFT JOIN source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
    WHERE pms.mapping_source_value_id = @mapping_source_value_id AND pms.mapping_source_usage_id = @mapping_source_usage_id
END
ELSE IF @flag = 'x' -- Show deal grid in maintain limit UI
BEGIN
	SELECT sdh.deal_id [Ref ID],
	pmd.deal_id AS [Deal ID],
	dbo.FNADateFormat(sdh.deal_date) [Deal Date],
	dbo.FNADateFormat(sdh.entire_term_start) AS [Term Start],
	dbo.FNADateFormat(sdh.entire_term_end) AS [Term End],
	sml.Location_Name [Index],
	sdht.template_name [Template],
	sc2.currency_name [Currency],
	sdt.source_deal_type_name [Deal Type],
	sdd.deal_volume [Deal Volume],
	su.uom_name [deal_volume_uom_id]
	FROM   portfolio_mapping_deal pmd
	LEFT JOIN source_deal_header sdh ON  sdh.source_deal_header_id = pmd.deal_id
	OUTER APPLY(SELECT MAX(sdd.fixed_price_currency_id) fixed_price_currency_id, 
					   MAX(sdd.location_id) location_id, 
					   MAX(sdd.deal_volume) deal_volume,
					   MAX(sdd.deal_volume_uom_id) deal_volume_uom_id 
	FROM source_deal_detail sdd
	WHERE sdd.source_deal_header_id = sdh.source_deal_header_id 
	GROUP BY sdd.source_deal_header_id) sdd
	LEFT JOIN source_counterparty sc ON  sdh.counterparty_id = sc.source_counterparty_id
	LEFT JOIN source_minor_location sml ON sdd.location_id = sml.source_minor_location_id
	LEFT JOIN source_deal_header_template sdht ON sdht.template_id = sdh.template_id
	LEFT JOIN source_currency sc2 ON sc2.source_currency_id = sdd.fixed_price_currency_id
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	LEFT JOIN source_uom su ON su.source_uom_id = sdd.deal_volume_uom_id
	WHERE  pmd.portfolio_mapping_source_id = (SELECT portfolio_mapping_source_id 
											  FROM portfolio_mapping_source pms 
											  WHERE pms.mapping_source_usage_id = @mapping_source_usage_id  AND pms.mapping_source_value_id = @mapping_source_value_id)
END
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
	INSERT INTO portfolio_mapping_deal(portfolio_mapping_source_id, deal_id)
	SELECT  pms.portfolio_mapping_source_id, scsv.item
	FROM portfolio_mapping_source pms
	CROSS APPLY dbo.SplitCommaSeperatedValues(@deal_id) scsv  
	WHERE pms.mapping_source_value_id = @mapping_source_value_id AND pms.mapping_source_usage_id = @mapping_source_usage_id
    
	--SET @sql = IDENT_CURRENT('portfolio_mapping_deal')
	EXEC spa_ErrorHandler 0
		, 'portfolio_mapping_deal'
		, 'spa_portfolio_mapping_deal'
		, 'Success'
		, 'Insert portfolio_mapping_deal new record success.'
		, ''
	END TRY
	BEGIN CATCH
	EXEC spa_ErrorHandler -1
		, 'portfolio_mapping_deal'
		, 'spa_portfolio_mapping_deal'
		, 'Failed'
		, 'Insert portfolio_mapping_deal new record failed.'
		, ''
	END CATCH
END
ELSE IF @flag = 'j' --Insert deals in Maintain Limit deal template UI.
BEGIN
	BEGIN TRY
	SET @portfolio_mapping_source_id = (SELECT  pms.portfolio_mapping_source_id
										FROM portfolio_mapping_source pms
										WHERE pms.mapping_source_value_id = @mapping_source_value_id AND pms.mapping_source_usage_id = @mapping_source_usage_id)
	--IF NOT EXISTS (SELECT 1 FROM portfolio_mapping_deal pmd 
	--			   INNER JOIN dbo.SplitCommaSeperatedValues(@deal_id) scsv ON pmd.deal_id=scsv.item
	--			   WHERE pmd.portfolio_mapping_source_id = @portfolio_mapping_source_id)
	--BEGIN
		INSERT INTO portfolio_mapping_deal(portfolio_mapping_source_id, deal_id)
		SELECT  @portfolio_mapping_source_id, scsv.item
		FROM dbo.SplitCommaSeperatedValues(@deal_id) scsv
		--CROSS APPLY dbo.SplitCommaSeperatedValues(@deal_id) scsv    
		WHERE NOT EXISTS (SELECT 1 FROM portfolio_mapping_deal pmd WHERE pmd.deal_id = scsv.item AND pmd.portfolio_mapping_source_id = @portfolio_mapping_source_id)
		--WHERE NOT EXISTS (SELECT deal_id FROM portfolio_mapping_deal pmd 
		--	WHERE pmd.deal_id = scsv.item AND pmd.portfolio_mapping_source_id NOT IN (SELECT pms.portfolio_mapping_source_id FROM portfolio_mapping_source pms 
		--		WHERE pms.mapping_source_usage_id = @mapping_source_usage_id))
		--INSERT INTO portfolio_mapping_deal(portfolio_mapping_source_id, deal_id)
		--SELECT  pms.portfolio_mapping_source_id, scsv.item
		--FROM portfolio_mapping_source pms
		--CROSS APPLY dbo.SplitCommaSeperatedValues(@deal_id) scsv  
		--WHERE pms.mapping_source_value_id = @mapping_source_value_id AND pms.mapping_source_usage_id = @mapping_source_usage_id
	--END
	END TRY
	BEGIN CATCH
	EXEC spa_ErrorHandler -1
		, 'portfolio_mapping_deal'
		, 'spa_portfolio_mapping_deal'
		, 'Failed'
		, 'Insert portfolio_mapping_deal new record failed.'
		, ''
	END CATCH 
END
ELSE IF @flag = 'r' --Removes deal ids
BEGIN 
	BEGIN TRY
	SET @sql = 'DELETE FROM portfolio_mapping_deal 
		WHERE deal_id IN (' + CAST (@deal_id AS VARCHAR)+ ')
		AND portfolio_mapping_source_id IN (SELECT portfolio_mapping_source_id FROM portfolio_mapping_source
		WHERE mapping_source_usage_id = ' + CAST (@mapping_source_usage_id AS VARCHAR) + '
		AND mapping_source_value_id =' + CAST (@mapping_source_value_id AS VARCHAR) +')'
	EXEC(@sql)
	END TRY 
	BEGIN CATCH
	EXEC spa_ErrorHandler -1
		, 'portfolio_mapping_deal'
		, 'spa_portfolio_mapping_deal'
		, 'Failed'
		, 'Delete portfolio_mapping_deal record failed.'
		, ''
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
	SET @sql = 'DELETE pmd
		FROM portfolio_mapping_deal pmd
		WHERE pmd.portfolio_mapping_deal_id IN ( ' + CAST ( @portfolio_mapping_deal_id AS VARCHAR) + ' )'
	
	EXEC(@sql)
    
	EXEC spa_ErrorHandler 0
		, 'portfolio_mapping_deal'
		, 'spa_portfolio_mapping_deal'
		, 'Success'
		, 'Delete portfolio_mapping_deal record success.'
		, @portfolio_mapping_deal_id
	END TRY
	BEGIN CATCH
	EXEC spa_ErrorHandler -1
	, 'portfolio_mapping_deal'
	, 'spa_portfolio_mapping_deal'
	, 'Failed'
	, 'Delete portfolio_mapping_deal record failed.'
	, ''
	END CATCH
END

