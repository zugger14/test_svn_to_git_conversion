IF OBJECT_ID(N'[dbo].[spa_deal_group]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_group]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	Runs while creating the deal header grouping for structure deal id concept

	Parameters
	@flag : Operational Flag
		i -> To create a structural deal grouping
		l -> To list all the grouping of structural deal grouping
		m -> To list all the grouping of structural deal grouping in Grid
	@source_deal_header_id : List of deal ids
	@structure_deal_id : grouping id / primary deal id
*/
 
CREATE PROCEDURE [dbo].[spa_deal_group]
    @flag NCHAR(1),
    @source_deal_header_id NVARCHAR(MAX) = NULL,
    @structure_deal_id INT = NULL
AS
SET NOCOUNT ON;
DECLARE @sql NVARCHAR(MAX)
DECLARE @desc NVARCHAR(500)
DECLARE @err_no INT
 
IF @flag = 'l'
BEGIN
    SELECT source_deal_header_id, deal_id + ' (' + CAST(source_deal_header_id AS NVARCHAR(20)) + ')' [deal_id]
	FROM source_deal_header sdh
	INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv ON sdh.source_deal_header_id = scsv.item 
END

IF @flag = 'm'
BEGIN
	IF OBJECT_ID('tempdb..#temp_group_deals') IS NOT NULL
		DROP TABLE #temp_group_deals

	CREATE TABLE #temp_group_deals (deal_id INT)

	-- selected deals
	INSERT INTO #temp_group_deals (deal_id)
	SELECT scsv.item 
	FROM dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv 

	-- deals that were grouped using structured deal id of any selected deals
	INSERT INTO #temp_group_deals (deal_id)
	SELECT sdh_struct.source_deal_header_id
	FROM #temp_group_deals scsv
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = scsv.deal_id
	INNER JOIN source_deal_header sdh_struct ON CAST(sdh_struct.source_deal_header_id AS NVARCHAR(50)) = sdh.structured_deal_id

	-- deals that were grouped using selected deals
	INSERT INTO #temp_group_deals (deal_id)
	SELECT sdh.source_deal_header_id
	FROM  #temp_group_deals scsv 
	INNER JOIN source_deal_header sdh ON sdh.structured_deal_id = CAST(scsv.deal_id AS NVARCHAR(50))

    SELECT sdh.source_deal_header_id,
		   sdh_struct.deal_id + ' (' + CAST(sdh_struct.source_deal_header_id AS NVARCHAR(20))  + ')' [group_id],		   
		   CASE WHEN sdh.source_deal_header_id = sdh_struct.source_deal_header_id THEN 'Yes' WHEN sdh_struct.source_deal_header_id IS NOT NULL THEN 'No' ELSE NULL END [is_primary],
		   sdh.deal_id + ' (' + CAST(sdh.source_deal_header_id AS NVARCHAR(20)) + ')' [deal_id],
		   sc.counterparty_name,
		   cg.contract_name,
		   st.trader_name,
		   CASE WHEN sdh.header_buy_sell_flag = 'b' THEN 'Buy' ELSE 'Sell' END [buy_sell],
		   sdt.source_deal_type_name
	FROM   source_deal_header sdh
	INNER JOIN (SELECT DISTINCT deal_id FROM #temp_group_deals) temp ON  sdh.source_deal_header_id = temp.deal_id
	LEFT JOIN source_deal_header sdh_struct ON  sdh.structured_deal_id = CAST(sdh_struct.source_deal_header_id AS NVARCHAR(50))
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = sdh.counterparty_id
	LEFT JOIN contract_group cg ON cg.contract_id = sdh.contract_id
	LEFT JOIN source_traders st ON st.source_trader_id = sdh.trader_id
	LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = sdh.source_deal_type_id
	ORDER BY sdh_struct.deal_id + ' (' + CAST(sdh_struct.source_deal_header_id AS NVARCHAR(20))  + ')' ASC, CASE WHEN sdh.source_deal_header_id = sdh_struct.source_deal_header_id THEN 'Yes' ELSE 'No' END DESC 
END

IF @flag = 'i'
BEGIN
	BEGIN TRY
		-- update structure deal id of deals to NULL if it's structure_deal_id match any of the selected deals but @structure_deal_id
		UPDATE sdh
		SET structured_deal_id = NULL
		FROM dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv
		INNER JOIN source_deal_header sdh ON sdh.structured_deal_id = CAST(scsv.item AS NVARCHAR(20))
		WHERE sdh.structured_deal_id <> CAST(@structure_deal_id AS NVARCHAR(100))
		
		-- update structure deal id of selected deal with the primary deal id
		UPDATE sdh
		SET structured_deal_id = @structure_deal_id
		FROM source_deal_header sdh
		INNER JOIN dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv ON sdh.source_deal_header_id = scsv.item 
	
	
		EXEC spa_ErrorHandler 0
			, 'Deal Group'
			, 'spa_deal_group'
			, 'Success' 
			, 'Successfully saved data.'
			, ''
	END TRY
	BEGIN CATCH
 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to group deals. ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'Deal Group'
		   , 'spa_deal_group'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
		-- update structure deal id of deals to NULL if it's structure_deal_id match any of the selected deals but @structure_deal_id
		UPDATE sdh
		SET structured_deal_id = NULL
		FROM dbo.SplitCommaSeperatedValues(@source_deal_header_id) scsv
		INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = scsv.item
		WHERE structured_deal_id IS NOT NULL
		
		EXEC spa_ErrorHandler 0
			, 'Deal Group'
			, 'spa_deal_group'
			, 'Success' 
			, 'Successfully saved data.'
			, ''
	END TRY
	BEGIN CATCH
 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		SET @DESC = 'Fail to remove deals from group. ( Errr Description:' + ERROR_MESSAGE() + ').'
 
		SELECT @err_no = ERROR_NUMBER()
 
		EXEC spa_ErrorHandler @err_no
		   , 'Deal Group'
		   , 'spa_deal_group'
		   , 'Error'
		   , @desc
		   , ''
	END CATCH
END