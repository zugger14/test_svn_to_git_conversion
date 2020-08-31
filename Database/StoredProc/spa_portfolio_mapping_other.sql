IF OBJECT_ID(N'[dbo].[spa_portfolio_mapping_other]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_portfolio_mapping_other]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Create date: 6/29/2012
-- Description: CRUD Operations for table portfolio_mapping_other

-- Params:
-- @flag						CHAR(1) - Operation flag
-- @portfolio_mapping_other_id	INT
-- @portfolio_group_id 			INT
-- @criteria_id 				INT
-- @counterparty 				INT
-- @buy 						CHAR(1)
-- @sell 						CHAR(1)
-- @buy_index 					INT
-- @buy_price 					NUMERIC(20, 10)
-- @buy_currency 				INT
-- @buy_volume 					NUMERIC(20, 10)
-- @buy_uom 					INT
-- @buy_term_start 				DATETIME
-- @buy_term_end 				DATETIME
-- @sell_index 					INT
-- @sell_price 					NUMERIC(20, 10)
-- @sell_currency 				INT
-- @sell_volume 				NUMERIC(20, 10)
-- @sell_uom 					INT
-- @sell_term_start 			DATETIME
-- @sell_term_end 				DATETIME
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_portfolio_mapping_other]
    @flag CHAR(1)
    , @portfolio_mapping_other_id VARCHAR(50) = NULL
    , @mapping_source_value_id INT = NULL
    , @mapping_source_usage_id INT = NULL
    , @counterparty INT = NULL
    , @buy CHAR(1) = NULL
    , @sell CHAR(1) = NULL
    , @buy_index INT = NULL		
	, @buy_price NUMERIC(20, 10) = NULL	
	, @buy_currency INT = NULL --updated	
	, @buy_volume NUMERIC(20, 10) = NULL	
	, @buy_uom INT = NULL	
	, @buy_term_start DATETIME = NULL
	, @buy_term_end DATETIME = NULL	
	, @sell_index INT = NULL	
	, @sell_price NUMERIC(20, 10) = NULL
	, @sell_currency INT = NULL --updated	
	, @sell_volume NUMERIC(20, 10) = NULL	
	, @sell_uom INT = NULL		
	, @sell_term_start DATETIME = NULL
	, @sell_term_end DATETIME = NULL
	
AS	   	

DECLARE @sql VARCHAR(MAX)
DECLARE @user_login_id VARCHAR(500)
SELECT @user_login_id = dbo.FNADBUser()

IF @flag = 's'
BEGIN
    --SELECT ALL ROWS FROM THE TABLE
    SELECT pmo.portfolio_mapping_other_id,
		   dbo.FNAHyperLinkText(10183413, pmo.portfolio_mapping_other_id, pmo.portfolio_mapping_other_id) AS [Other ID],
           sc.counterparty_name AS [Counterparty],
           buy AS [Buy],
           sell AS [Sell],
           CASE 
                WHEN pmo.buy = 'n' THEN NULL
                ELSE spcd.curve_name
           END AS [Buy Index],
           --CASE buy_price WHEN 0 THEN '0' ELSE CAST(dbo.FNARemoveTrailingZeroes( ROUND(buy_price, 6)) as varchar(50)) END AS [Buy Price],
           dbo.FNARemoveTrailingZeroes(ROUND(buy_price, 6)) [Buy Price],
           scb.currency_name AS [Buy Currency],
           dbo.FNARemoveTrailingZeroes(ROUND(buy_volume, 6)) AS [Buy Volume],
           su.uom_name AS [Buy UOM],
           dbo.FNAUserDateFormat(buy_term_start, @user_login_id) AS 
           [Buy Term Start],
           dbo.FNAUserDateFormat(buy_term_end, @user_login_id) AS [Buy Term End],
           CASE 
                WHEN pmo.sell = 'n' THEN NULL
                ELSE spcd2.curve_name
           END AS [Sell Index],
           dbo.FNARemoveTrailingZeroes(ROUND(sell_price, 6)) AS [Sell Price],
           scs.currency_name AS [Sell Currency],
           dbo.FNARemoveTrailingZeroes(ROUND(sell_volume, 6)) AS [Sell Volume],
           su2.uom_name AS [Sell UOM],
           dbo.FNAUserDateFormat(sell_term_start, @user_login_id) AS 
           [Sell Term Start],
           dbo.FNAUserDateFormat(sell_term_end, @user_login_id) AS 
           [Sell Term End]
    FROM   portfolio_mapping_other pmo
           INNER JOIN portfolio_mapping_source pms
                ON  pms.portfolio_mapping_source_id = pmo.portfolio_mapping_source_id
           LEFT JOIN source_price_curve_def spcd
                ON  spcd.source_curve_def_id = pmo.buy_index
           LEFT JOIN source_price_curve_def spcd2
                ON  spcd2.source_curve_def_id = pmo.sell_index
           LEFT JOIN source_uom su
                ON  su.source_uom_id = pmo.buy_uom
           LEFT JOIN source_uom su2
                ON  su2.source_uom_id = pmo.sell_uom
           LEFT JOIN source_counterparty sc
                ON  sc.source_counterparty_id = pmo.counterparty
           LEFT JOIN source_currency scb
                ON  scb.source_currency_id = pmo.buy_currency
           LEFT JOIN source_currency scs
                ON  scs.source_currency_id = pmo.sell_currency
    WHERE  pms.mapping_source_value_id = @mapping_source_value_id
           AND pms.mapping_source_usage_id = @mapping_source_usage_id
END
ELSE IF @flag = 'g' --for export
BEGIN
    --SELECT ALL ROWS FROM THE TABLE
    SELECT dbo.FNAHyperLinkText(10183413, pmo.portfolio_mapping_other_id, pmo.portfolio_mapping_other_id) AS [Other ID],
           sc.counterparty_name AS [Counterparty],
           buy AS [Buy],
           sell AS [Sell],
           CASE 
                WHEN pmo.buy = 'n' THEN NULL
                ELSE spcd.curve_name
           END AS [Buy Index],
           --CASE buy_price WHEN 0 THEN '0' ELSE CAST(dbo.FNARemoveTrailingZeroes( ROUND(buy_price, 6)) as varchar(50)) END AS [Buy Price],
           dbo.FNARemoveTrailingZeroes(ROUND(buy_price, 6)) [Buy Price],
           scb.currency_name AS [Buy Currency],
           dbo.FNARemoveTrailingZeroes(ROUND(buy_volume, 6)) AS [Buy Volume],
           su.uom_name AS [Buy UOM],
           dbo.FNAUserDateFormat(buy_term_start, @user_login_id) AS 
           [Buy Term Start],
           dbo.FNAUserDateFormat(buy_term_end, @user_login_id) AS [Buy Term End],
           CASE 
                WHEN pmo.sell = 'n' THEN NULL
                ELSE spcd2.curve_name
           END AS [Sell Index],
           dbo.FNARemoveTrailingZeroes(ROUND(sell_price, 6)) AS [Sell Price],
           scs.currency_name AS [Sell Currency],
           dbo.FNARemoveTrailingZeroes(ROUND(sell_volume, 6)) AS [Sell Volume],
           su2.uom_name AS [Sell UOM],
           dbo.FNAUserDateFormat(sell_term_start, @user_login_id) AS 
           [Sell Term Start],
           dbo.FNAUserDateFormat(sell_term_end, @user_login_id) AS 
           [Sell Term End]
    FROM   portfolio_mapping_other pmo
           INNER JOIN portfolio_mapping_source pms
                ON  pms.portfolio_mapping_source_id = pmo.portfolio_mapping_source_id
           LEFT JOIN source_price_curve_def spcd
                ON  spcd.source_curve_def_id = pmo.buy_index
           LEFT JOIN source_price_curve_def spcd2
                ON  spcd2.source_curve_def_id = pmo.sell_index
           LEFT JOIN source_uom su
                ON  su.source_uom_id = pmo.buy_uom
           LEFT JOIN source_uom su2
                ON  su2.source_uom_id = pmo.sell_uom
           LEFT JOIN source_counterparty sc
                ON  sc.source_counterparty_id = pmo.counterparty
           LEFT JOIN source_currency scb
                ON  scb.source_currency_id = pmo.buy_currency
           LEFT JOIN source_currency scs
                ON  scs.source_currency_id = pmo.sell_currency
    WHERE  pms.mapping_source_value_id = @mapping_source_value_id
           AND pms.mapping_source_usage_id = @mapping_source_usage_id
END
ELSE IF @flag = 'a'
BEGIN
    --SELECT A MATCHED ROW FROM THE TABLE
    SELECT portfolio_mapping_other_id,
           counterparty,
           buy,
           sell,
           buy_index,
           buy_price,
           buy_currency,
           buy_volume,
           buy_uom,
           buy_term_start,
           buy_term_end,
           sell_index,
           sell_price,
           sell_currency,
           sell_volume,
           sell_uom,
           sell_term_start,
           sell_term_end
    FROM   portfolio_mapping_other
    WHERE  portfolio_mapping_other_id = @portfolio_mapping_other_id
   
END
ELSE IF @flag = 'i'
BEGIN TRY
	INSERT INTO portfolio_mapping_other
	  (
	    portfolio_mapping_source_id,
	    counterparty,
	    buy,
	    sell,
	    buy_index,
	    buy_price,
	    buy_currency,
	    buy_volume,
	    buy_uom,
	    buy_term_start,
	    buy_term_end,
	    sell_index,
	    sell_price,
	    sell_currency,
	    sell_volume,
	    sell_uom,
	    sell_term_start,
	    sell_term_end
	  )
	SELECT pms.portfolio_mapping_source_id,
	       @counterparty,
	       @buy,
	       @sell,
	       @buy_index,
	       @buy_price,
	       @buy_currency,
	       @buy_volume,
	       @buy_uom,
	       @buy_term_start,
	       @buy_term_end,
	       @sell_index,
	       @sell_price,
	       @sell_currency,
	       @sell_volume,
	       @sell_uom,
	       @sell_term_start,
	       @sell_term_end
	FROM   portfolio_mapping_source pms
	WHERE  pms.mapping_source_value_id = @mapping_source_value_id
	       AND pms.mapping_source_usage_id = @mapping_source_usage_id
	
	EXEC spa_ErrorHandler 0
		, 'portfolio_mapping_other'
		, 'portfolio_mapping_other'
		, 'Success'
		, 'Insert portfolio_mapping_other new record success.'
		, ''
END TRY
BEGIN CATCH
	EXEC spa_ErrorHandler -1
		, 'portfolio_mapping_other'
		, 'portfolio_mapping_other'
		, 'Failed'
		, 'Insert portfolio_mapping_other new record failed.'
		, ''
END CATCH


ELSE IF @flag = 'u'
BEGIN
    --UPDATE STATEMENT GOES HERE
    BEGIN TRY
    	UPDATE portfolio_mapping_other
    	SET    counterparty = @counterparty,
    	       buy = @buy,
    	       sell = @sell,
    	       buy_index = @buy_index,
    	       buy_price = @buy_price,
    	       buy_currency = @buy_currency,
    	       buy_volume = @buy_volume,
    	       buy_uom = @buy_uom,
    	       buy_term_start = @buy_term_start,
    	       buy_term_end = @buy_term_end,
    	       sell_index = @sell_index,
    	       sell_price = @sell_price,
    	       sell_currency = @sell_currency,
    	       sell_volume = @sell_volume,
    	       sell_uom = @sell_uom,
    	       sell_term_start = @sell_term_start,
    	       sell_term_end = @sell_term_end
    	WHERE  portfolio_mapping_other_id = @portfolio_mapping_other_id
    		
    	EXEC spa_ErrorHandler 0
			, 'portfolio_mapping_other'
			, 'portfolio_mapping_other'
			, 'Success'
			, 'Update portfolio_mapping_other record success.'
			, ''
    END try
    BEGIN CATCH
    	EXEC spa_ErrorHandler -1
			, 'portfolio_mapping_other'
			, 'portfolio_mapping_other'
			, 'Failed'
			, 'Update portfolio_mapping_other record failed.'
			, ''
    END CATCH
END
ELSE IF @flag = 'd'
BEGIN TRY 
    --DELETE STATEMENT GOES HERE
    SET @sql = '
    DELETE FROM portfolio_mapping_other
    WHERE portfolio_mapping_other_id IN (' + @portfolio_mapping_other_id + ')'
    exec spa_print @sql
    EXEC(@sql)
    
    EXEC spa_ErrorHandler 0
			, 'portfolio_mapping_other'
			, 'portfolio_mapping_other'
			, 'Success'
			, 'Delete portfolio_mapping_other record success.'
			, ''
END TRY
BEGIN CATCH
	EXEC spa_ErrorHandler -1
			, 'portfolio_mapping_other'
			, 'portfolio_mapping_other'
			, 'Failed'
			, 'Delete portfolio_mapping_other record failed.'
			, ''
END CATCH
