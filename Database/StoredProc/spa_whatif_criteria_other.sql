IF OBJECT_ID(N'[dbo].[spa_whatif_criteria_other]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_whatif_criteria_other]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: sligal@pioneersolutionsglobal.com
-- Create date: 6/29/2012
-- Description: CRUD Operations for table whatif_criteria_other

-- Params:
-- @flag						CHAR(1) - Operation flag
-- @whatif_criteria_other_id	INT
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
CREATE PROCEDURE [dbo].[spa_whatif_criteria_other]
    @flag CHAR(1)
    , @whatif_criteria_other_id INT = NULL
    , @portfolio_group_id INT = NULL
    , @criteria_id INT = NULL
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
    EXEC spa_print 'x'
END
ELSE IF @flag = 'a'
BEGIN
    --SELECT A MATCHED ROW FROM THE TABLE
    SELECT  whatif_criteria_other_id,
			portfolio_group_id,
			criteria_id,
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
    FROM   	whatif_criteria_other
    WHERE	whatif_criteria_other_id = @whatif_criteria_other_id
END
ELSE IF @flag = 'i'
BEGIN
    IF @criteria_id IS NOT NULL
	BEGIN
		SET @portfolio_group_id = NULL
	END
	BEGIN TRY
		INSERT INTO whatif_criteria_other
		(
			-- whatif_criteria_other_id -- this column value is auto-generated,
			portfolio_group_id,
			criteria_id,
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
		VALUES
		(
			@portfolio_group_id,
			@criteria_id,
			@counterparty,			@buy,			@sell,			@buy_index,			@buy_price,
			@buy_currency,			@buy_volume,			@buy_uom,			@buy_term_start,			@buy_term_end,			@sell_index,			@sell_price,
			@sell_currency,			@sell_volume,			@sell_uom,			@sell_term_start,			@sell_term_end
		)
		
		EXEC spa_ErrorHandler 0
			, 'whatif_criteria_other'
			, 'spa_whatif_criteria_other'
			, 'Success'
			, 'Insert whatif criteria other new record success.'
			, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'whatif_criteria_other'
			, 'spa_whatif_criteria_other'
			, 'DB ERROR'
			, 'Insert whatif criteria other new record failed.'
			, ''
	END CATCH
END

ELSE IF @flag = 'u'
BEGIN
    --UPDATE STATEMENT GOES HERE
    BEGIN TRY
    	UPDATE whatif_criteria_other
    	SET
    		-- whatif_criteria_other_id = ? -- this column value is auto-generated,
    		portfolio_group_id = @portfolio_group_id,
    		counterparty = @counterparty,
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
    	WHERE whatif_criteria_other_id = @whatif_criteria_other_id 
    		
    	EXEC spa_ErrorHandler 0
			, 'whatif_criteria_other'
			, 'spa_whatif_criteria_other'
			, 'Success'
			, 'Update whatif criteria other record success.'
			, ''
    END try
    BEGIN CATCH
    	EXEC spa_ErrorHandler -1
			, 'whatif_criteria_other'
			, 'spa_whatif_criteria_other'
			, 'DB ERROR'
			, 'Update whatif criteria other record failed.'
			, ''
    END CATCH
END
ELSE IF @flag = 'd'
BEGIN
    --DELETE STATEMENT GOES HERE
    DELETE FROM whatif_criteria_other
    WHERE whatif_criteria_other_id = @whatif_criteria_other_id
    
    EXEC spa_ErrorHandler 0
			, 'whatif_criteria_other'
			, 'spa_whatif_criteria_other'
			, 'Success'
			, 'Delete whatif criteria other record success.'
			, ''
END
ELSE IF @flag = 'x'
BEGIN
    --DISPLAY WHATIF CRITERIA OTHER GRID
    IF @portfolio_group_id IS NOT NULL
	BEGIN
		SELECT
			whatif_criteria_other_id AS [ID],
			portfolio_group_id AS [Portfolio Group ID],
			sc.counterparty_name AS [Counterparty],
			buy AS [Buy],
			sell AS [Sell],
			CASE
				WHEN wco.buy = 'n' THEN NULL
				ELSE spcd.curve_name
			END AS [Buy Index],
			buy_price AS [Buy Price],
			scb.currency_name AS [Buy Currency],
			buy_volume AS [Buy Volume],
			su.uom_name AS [Buy UOM],
			dbo.FNAUserDateFormat( buy_term_start, @user_login_id) AS [Buy Term Start],
			dbo.FNAUserDateFormat( buy_term_end, @user_login_id) AS [Buy Term End],
			CASE
				WHEN wco.sell = 'n' THEN NULL
				ELSE spcd2.curve_name
			END AS [Sell Index],
			sell_price AS [Sell Price],
			scs.currency_name AS [Sell Currency],
			sell_volume AS [Sell Volume],
			su2.uom_name AS [Sell UOM],
			dbo.FNAUserDateFormat( sell_term_start, @user_login_id) AS [Sell Term Start],
			dbo.FNAUserDateFormat( sell_term_end, @user_login_id) AS [Sell Term End]
		
		FROM whatif_criteria_other wco
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = wco.buy_index
		LEFT JOIN source_price_curve_def spcd2 ON spcd2.source_curve_def_id = wco.sell_index
		LEFT JOIN source_uom su ON su.source_uom_id = wco.buy_uom
		LEFT JOIN source_uom su2 ON su2.source_uom_id = wco.sell_uom
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = wco.counterparty 
		LEFT JOIN source_currency scb ON scb.source_currency_id = wco.buy_currency
		LEFT JOIN source_currency scs ON scs.source_currency_id = wco.sell_currency
		WHERE portfolio_group_id = @portfolio_group_id
			   
	END
    ELSE IF @criteria_id IS NOT NULL
	BEGIN
		SELECT
			whatif_criteria_other_id AS [ID],
			criteria_id AS [Criteria ID],
			sc.counterparty_name AS [Counterparty],
			buy AS [Buy],
			sell AS [Sell],
			CASE
				WHEN wco.buy = 'n' THEN NULL
				ELSE spcd.curve_name
			END AS [Buy Index],
			buy_price AS [Buy Price],
			scb.currency_name AS [Buy Currency],
			buy_volume AS [Buy Volume],
			su.uom_name AS [Buy UOM],
			dbo.FNAUserDateFormat( buy_term_start, @user_login_id) AS [Buy Term Start],
			dbo.FNAUserDateFormat( buy_term_end, @user_login_id) AS [Buy Term End],
			CASE
				WHEN wco.sell = 'n' THEN NULL
				ELSE spcd2.curve_name
			END AS [Sell Index],
			sell_price AS [Sell Price],
			scs.currency_name AS [Sell Currency],
			sell_volume AS [Sell Volume],
			su2.uom_name AS [Sell UOM],
			dbo.FNAUserDateFormat( sell_term_start, @user_login_id) AS [Sell Term Start],
			dbo.FNAUserDateFormat( sell_term_end, @user_login_id) AS [Sell Term End]
		
		FROM whatif_criteria_other wco
		LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = wco.buy_index
		LEFT JOIN source_price_curve_def spcd2 ON spcd2.source_curve_def_id = wco.sell_index
		LEFT JOIN source_uom su ON su.source_uom_id = wco.buy_uom
		LEFT JOIN source_uom su2 ON su2.source_uom_id = wco.sell_uom
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = wco.counterparty 
		LEFT JOIN source_currency scb ON scb.source_currency_id = wco.buy_currency
		LEFT JOIN source_currency scs ON scs.source_currency_id = wco.sell_currency
		WHERE criteria_id = @criteria_id
	END
END
ELSE IF @flag = 'p'
BEGIN
	-- UPDATE whatif_criteria_other FOR PORTFOLIO ID ONLY
	BEGIN TRY
		UPDATE whatif_criteria_other
		SET
			-- whatif_criteria_other_id = ? -- this column value is auto-generated,
			portfolio_group_id = @portfolio_group_id
		WHERE criteria_id = @criteria_id
		
		EXEC spa_ErrorHandler 0
			, 'whatif_criteria_other'
			, 'spa_whatif_criteria_other'
			, 'Success'
			, 'Update whatif criteria other record success.'
			, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'whatif_criteria_other'
			, 'spa_whatif_criteria_other'
			, 'DB ERROR'
			, 'Update whatif criteria other record failed.'
			, ''
	END CATCH
END