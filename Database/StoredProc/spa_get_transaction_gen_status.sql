IF OBJECT_ID(N'spa_get_transaction_gen_status', N'P') IS NOT NULL
	DROP PROCEDURE spa_get_transaction_gen_status
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
This SP is used to get the relationships made.
	Parameters: 
	@gen_hedge_group_id : Hegde Group ids
	@individual 		: Individual Yes/No
	@process_id 		: Unique Identifier
	@match_type 		: Perfect/Auto match
	@as_of_date			: Date to run
*/

CREATE PROCEDURE [dbo].[spa_get_transaction_gen_status] 
	@gen_hedge_group_id VARCHAR(MAX),  
	@individual VARCHAR(1) = NULL,
	@process_id VARCHAR(100) = NULL,
	@match_type VARCHAR(1) = 'p',
	@as_of_date DATETIME = NULL

AS

SET NOCOUNT ON
-- 
-- DECLARE @gen_hedge_group_id int
-- SET @gen_hedge_group_id = 19
-- 
DECLARE @sql_stmt VARCHAR(8000)
DECLARE @sql_stmt1 VARCHAR(8000)
--DECLARE @individual varchar(1)

CREATE TABLE #temp (gen_hedge_group_id INT)

IF @gen_hedge_group_id IS NULL OR @gen_hedge_group_id = ''
	SET @gen_hedge_group_id = -1

EXEC ('INSERT INTO #temp  SELECT gen_hedge_group_id FROM gen_transaction_status WHERE gen_hedge_group_id IN (' + @gen_hedge_group_id + ')')

--select count(*) from #temp
-- If (select count(*) from #temp) > 1 
-- 	SET @individual = 'n'
-- ELSE
-- 	SET @individual = 'y'

--select @individual

IF ISNULL(@individual, 'n') = 'y' 
BEGIN
	CREATE TABLE #relationship_created (
	RelId INT NULL, 
	HedgeItem VARCHAR(10) COLLATE DATABASE_DEFAULT  NULL, 
	GenDealID INT,
	PercInc VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL, 
	TermStart VARCHAR(20) COLLATE DATABASE_DEFAULT  NULL, 
	TermEnd VARCHAR(20) COLLATE DATABASE_DEFAULT  NULL, 
	Leg INT NULL, 
	FixedFloat VARCHAR(10) COLLATE DATABASE_DEFAULT  NULL, 
	BuySell VARCHAR(10) COLLATE DATABASE_DEFAULT  NULL, 
	CurveIndex VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL, 
	Price FLOAT NULL, 
	[Price Adder] FLOAT NULL, 
	[Price Multiplier] FLOAT NULL, 
	Volume FLOAT NULL, 
	UOM VARCHAR(20) COLLATE DATABASE_DEFAULT  NULL, 
	Frequency VARCHAR(20) COLLATE DATABASE_DEFAULT  NULL, 
	CreatedBy VARCHAR(50) COLLATE DATABASE_DEFAULT  NULL, 
	CreatedTS VARCHAR(20) COLLATE DATABASE_DEFAULT 
	)
		
	SET @sql_stmt  = '
	INSERT INTO #relationship_created
	SELECT	
		gen_fas_link_detail.gen_link_id AS RelId, 
		CASE gen_fas_link_detail.hedge_or_item  WHEN ''h'' THEN ''Hedge'' ELSE ''Item'' End AS HedgeItem, 
		gen_fas_link_detail.deal_number GenDealID,
		dbo.FNARemoveTrailingZeroes(ROUND(gen_fas_link_detail.percentage_included,2)) AS PercInc, 
		dbo.FNADateFormat(gen_deal_detail.term_start) AS TermStart, 
		dbo.FNADateFormat(gen_deal_detail.term_end) AS TermEnd, 
		gen_deal_detail.Leg AS Leg, 
	    CASE gen_deal_detail.fixed_float_leg WHEN ''f'' THEN ''Fixed'' ELSE ''Float'' End AS FixedFloat, 
		CASE gen_deal_detail.buy_sell_flag WHEN ''b'' THEN ''Buy (Rec)'' ELSE ''Sell (Pay)'' End AS BuySell, 
		ISNULL(source_price_curve_def.curve_name, '' '') AS [CurveIndex], 
	    ROUND(gen_deal_detail.fixed_price, 4) AS Price, 
	    ROUND(gen_deal_detail.price_adder, 4) AS [Price Adder], 
	    ROUND(gen_deal_detail.price_multiplier, 4) AS [Price Multiplier], 
		CAST(ROUND(gen_deal_detail.deal_volume, 2) as varchar) AS Volume, 
		source_uom.uom_name AS UOM, 
	        CASE gen_deal_detail.deal_volume_frequency  WHEN ''m'' THEN ''Monthly'' ELSE ''Daily'' End AS Frequency, 
		gen_deal_detail.create_user AS CreatedBy, 
		dbo.FNADateFormat(gen_deal_detail.create_ts) AS CreatedTS
	FROM    gen_fas_link_header INNER JOIN
	        gen_fas_link_detail ON gen_fas_link_header.gen_link_id = gen_fas_link_detail.gen_link_id INNER JOIN
	        gen_deal_detail ON gen_fas_link_detail.deal_number = gen_deal_detail.gen_deal_header_id INNER JOIN
	        source_uom ON gen_deal_detail.deal_volume_uom_id = source_uom.source_uom_id LEFT OUTER JOIN
			source_price_curve_def ON source_price_curve_def.source_curve_def_id = gen_deal_detail.curve_id
	WHERE    gen_fas_link_detail.hedge_or_item = ''i'' AND gen_fas_link_header.gen_hedge_group_id IN 
		(' + @gen_hedge_group_id + ' )
	
	UNION 
	
	SELECT	
		gen_fas_link_detail.gen_link_id AS RelId, 
		CASE gen_fas_link_detail.hedge_or_item  WHEN ''h'' THEN ''Hedge'' ELSE ''Item'' End AS HedgeItem, 
		gen_fas_link_detail.deal_number GenDealID,
		dbo.FNARemoveTrailingZeroes(ROUND(gen_fas_link_detail.percentage_included,2)) AS PercInc, 
		dbo.FNADateFormat(source_deal_detail.term_start) AS TermStart, 
		dbo.FNADateFormat(source_deal_detail.term_end) AS TermEnd, 
		source_deal_detail.Leg AS Leg, 
	    CASE source_deal_detail.fixed_float_leg WHEN ''f'' THEN ''Fixed'' ELSE ''Float'' End AS FixedFloat, 
		CASE source_deal_detail.buy_sell_flag WHEN ''b'' THEN ''Buy (Rec)'' ELSE ''Sell (Pay)'' End AS BuySell, 
		ISNULL(source_price_curve_def.curve_name, '' '') AS [CurveIndex], 
	    ROUND(source_deal_detail.fixed_price, 4) AS Price, 
	    ROUND(source_deal_detail.price_adder, 4) AS [Price Adder], 
	    ROUND(source_deal_detail.price_multiplier, 4) AS [Price Multiplier], 
		CAST(ROUND(source_deal_detail.deal_volume, 2) as varchar) AS Volume, 
		source_uom.uom_name AS UOM, 
	        CASE source_deal_detail.deal_volume_frequency  WHEN ''m'' THEN ''Monthly'' ELSE ''Daily'' End AS Frequency, 
		source_deal_detail.create_user AS CreatedBy, 
		dbo.FNADateFormat(source_deal_detail.create_ts) AS CreatedTS
	--INTO #relationship_created
	FROM    gen_fas_link_header INNER JOIN
	        gen_fas_link_detail ON gen_fas_link_header.gen_link_id = gen_fas_link_detail.gen_link_id INNER JOIN
	        source_deal_detail ON gen_fas_link_detail.deal_number = source_deal_detail.source_deal_header_id INNER JOIN
	        source_uom ON source_deal_detail.deal_volume_uom_id = source_uom.source_uom_id LEFT OUTER JOIN
		source_price_curve_def ON source_price_curve_def.source_curve_def_id = source_deal_detail.curve_id
	WHERE   gen_fas_link_detail.hedge_or_item = ''h'' AND gen_fas_link_header.gen_hedge_group_id IN
					(' + @gen_hedge_group_id  + ')'
	
	--drop table #relationship_created
	--select * from #relationship_created
	EXEC (@sql_stmt)
	
	--select * from #relationship_created
	DECLARE @tot_relationship_created INT
	SET @tot_relationship_created = 0
	SELECT @tot_relationship_created = COUNT(*) FROM #relationship_created

	IF @tot_relationship_created = 0
	BEGIN
		SELECT	gts.gen_hedge_group_id HedgeGroupID, gts.error_code [Code], 
			gts.message MESSAGE, gts.recommendation Recommendataion,
			gts.error_module [MODULE], gts.area [Area], gts.status [Status]
		FROM    gen_transaction_status gts INNER JOIN
		        (SELECT  gen_hedge_group_id, MAX(process_id) process_id, MAX(create_ts) create_ts
		        FROM     gen_transaction_status
				GROUP BY gen_hedge_group_id) recent_row 
				ON recent_row.process_id = gts.process_id AND recent_row.gen_hedge_group_id= gts.gen_hedge_group_id
		INNER JOIN dbo.FNASplit(@gen_hedge_group_id, ',') f ON f.item = gts.gen_hedge_group_id 
		--WHERE gts.gen_hedge_group_id IN (@gen_hedge_group_id)
	END	
	ELSE
	BEGIN
		SELECT * FROM #relationship_created ORDER  BY RelID, HedgeItem, GenDealID, Leg, CAST(dbo.FNACovertToSTDDate(TermStart) AS DATETIME)
	END
END
ELSE
BEGIN
	DECLARE @dril_msg VARCHAR(1000)
	DECLARE @module VARCHAR(1000)
	SET @dril_msg = 'No matching deals were found as of ' + dbo.FNADateFormat(@as_of_date)
	
	IF @match_type = 'p'
	BEGIN
		SET @module = 'Perfect Hedge'
	END
	ELSE 
	BEGIN
		SET @module = 'Automatic Matching '
	END 

	SELECT 'Error' AS [Code]
			, 'Auto.Matching' [Module]
			, @module [Source]
			, 'Application Error' [Type]
			, @dril_msg [Description] 
			, 'Please make sure.' [Next Steps]
			, @process_id [Process ID]

	
	/*previous code 
	--SELECT	gts.gen_hedge_group_id HedgeGroupID, gts.error_code [Code],   
	
	--		gts.message Message,   
	--		'<a target="_blank" href="' + './spa_html.php?spa=EXEC spa_get_transaction_gen_status ' +    
	--		CAST(gts.gen_hedge_group_id as varchar) + ', ''y''">' + ' See detail...' + '.</a>'  as Recommendation,  
	--		gts.error_module [Module], gts.area [Area], gts.status [Status]  
	--FROM    gen_transaction_status gts 
	--INNER JOIN (SELECT  gen_hedge_group_id, MAX(process_id) process_id, MAX(create_ts) create_ts  
	--			FROM     gen_transaction_status  
	--			GROUP BY gen_hedge_group_id) recent_row ON recent_row.process_id = gts.process_id 
	--	AND recent_row.gen_hedge_group_id= gts.gen_hedge_group_id  
	--WHERE gts.gen_hedge_group_id IN (select gen_hedge_group_id from #temp) 
	--	AND gts.process_id = ISNULL(@process_id, gts.process_id)  
	*/
END

GO
















