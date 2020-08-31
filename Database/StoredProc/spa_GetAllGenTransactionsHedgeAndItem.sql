IF OBJECT_ID('[dbo].[spa_GetAllGenTransactionsHedgeAndItem]') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_GetAllGenTransactionsHedgeAndItem]
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	This SP is used to list all gen links
	Parameters: 
	@gen_link_id : Gen link ids

*/

CREATE PROCEDURE [dbo].[spa_GetAllGenTransactionsHedgeAndItem]
	@gen_link_id VARCHAR(MAX)
AS

SET NOCOUNT ON
BEGIN
	CREATE TABLE #GelRelID(id INT)
	
	INSERT INTO #GelRelID 
	SELECT glh.gen_link_id AS GelRelID FROM gen_fas_link_header glh
	WHERE  glh.gen_hedge_group_id IN (SELECT Item FROM [dbo].[SplitCommaSeperatedValues](@gen_link_id))
			
	SELECT     	
		flh.gen_hedge_group_id AS [Gen Group ID],
		fld.deal_number AS source_deal_header_id, 
		CASE WHEN MAX(gen_sdh.deal_id) IS NULL THEN MAX(sdh.deal_id) 
		ELSE 
		CAST(sdh.deal_id AS VARCHAR(50)) + '^javascript:open_deal_detail(' +  CAST(fld.deal_number AS VARCHAR(50)) + ')^' END   AS [Deal ID],
		dbo.FNARemoveTrailingZeroes(CAST(ROUND(fld.percentage_included, 2) AS VARCHAR)) AS [Percentage Included],
		dbo.FNADateFormat(MAX(flh.link_effective_date)) [Effective Date], 
		dbo.FNADateFormat(sdh.deal_date) AS [Deal Date], 
		CASE 
			WHEN fld.hedge_or_item = 'i' THEN 'Item'
			WHEN fld.hedge_or_item = 'h' THEN 'Hedge'
			ELSE '' 
		END AS [Hedge/Item],
		MAX(sdd.Leg) AS Leg, 
		dbo.FNADateFormat(MIN(isnull(fldd.term_start,sdd.term_start))) AS [Term Start], 
		dbo.FNADateFormat(MAX(isnull(fldd.term_start,sdd.term_end))) AS [Term End], 
		MAX((CASE sdd.fixed_float_leg WHEN 'f' THEN 'Fixed' ELSE 'Float' END)) AS fixed_float, 
		MAX(CASE sdh.header_buy_sell_flag WHEN 'b' THEN 'Buy (Receive)' ELSE 'Sell (Pay)' END) AS [Buy/Sell], 
		dbo.FNARemoveTrailingZero(CAST(SUM(sdd.deal_volume)/COUNT(sdd.Leg) AS NUMERIC(18, 2))) AS Volume,
		dbo.FNARemoveTrailingZero(CAST(fld.percentage_included * (SUM(sdd.deal_volume)/COUNT(sdd.Leg)) AS NUMERIC(18, 2))) matched_volume, 
		SUM(sdd.deal_volume)/COUNT(sdd.Leg) - (fld.percentage_included * (SUM(sdd.deal_volume)/COUNT(sdd.Leg))) available_volume,
		--MAX(CASE sdd.deal_volume_frequency WHEN 'm' THEN 'Monthly' ELSE 'Daily' END) AS Frequency, 
		MAX(source_uom.uom_name) AS uom, 
		MAX(source_price_curve_def.curve_name) AS [Index],
		ROUND(dbo.FNARemoveTrailingZeroes(AVG(CASE WHEN sdd.fixed_price=0 THEN NULL ELSE sdd.fixed_price END)), 4) Price, 
		--dbo.FNARemoveTrailingZeroes(AVG(sdd.option_strike_price)) [Strike Price],
		MAX(source_currency.currency_name) AS Currency  
		--,Book1.source_book_name AS [Internal Portfolio], 
		--Book2.source_book_name AS [Counterparty Group], 
		--Book3.source_book_name AS [Instrument Type], 
		--Book4.source_book_name AS [Proj. Index Group], 
		--CASE sdh.option_type WHEN 'c' THEN 'Call' WHEN 'p' THEN 'Put' ELSE '' END AS [Option Type], 
		--CASE sdh.option_excercise_type WHEN 'e' THEN 'European' WHEN 'a' THEN 'American' ELSE sdh.option_excercise_type END AS [Exercise Type]
	FROM gen_fas_link_detail fld 
	INNER JOIN #GelRelID g ON g.id = fld.gen_link_id
	INNER JOIN gen_fas_link_header flh ON fld.gen_link_id = flh.gen_link_id 
	INNER JOIN (SELECT source_deal_header_id, deal_date, deal_id,  header_buy_sell_flag, option_type, option_excercise_type,
					source_system_book_id1, source_system_book_id2, source_system_book_id3, source_system_book_id4
					,'s' src
	            FROM source_deal_header 
				UNION ALL
				SELECT gdh1.gen_deal_header_id, gdh1.deal_date, gdh1.deal_id, gdd1.buy_sell_flag, gdh1.option_type, gdh1.option_excercise_type,
					gdh1.source_system_book_id1, gdh1.source_system_book_id2, gdh1.source_system_book_id3, gdh1.source_system_book_id4,'f' src
				FROM gen_deal_header gdh1
				INNER JOIN gen_deal_detail gdd1 ON  gdd1.gen_deal_header_id = gdh1.gen_deal_header_id) sdh 
	           ON fld.deal_number = sdh.source_deal_header_id and sdh.src=isnull(fld.deal_id_source,'s')
				INNER JOIN source_book Book1 ON sdh.source_system_book_id1 = Book1.source_book_id 
				INNER JOIN source_book Book2 ON sdh.source_system_book_id2 = Book2.source_book_id 
				INNER JOIN source_book Book3 ON sdh.source_system_book_id3 = Book3.source_book_id 
				INNER JOIN source_book Book4 ON sdh.source_system_book_id4 = Book4.source_book_id 
				INNER JOIN (SELECT source_deal_header_id, option_strike_price, fixed_price, deal_volume_frequency, Leg, deal_volume,  
					fixed_float_leg, term_end, term_start, deal_volume_uom_id, curve_id, fixed_price_currency_id,'s' src
				FROM source_deal_detail 
				UNION ALL 
				SELECT gen_deal_header_id, option_strike_price, fixed_price, deal_volume_frequency, Leg, deal_volume,
					fixed_float_leg, term_end, term_start, deal_volume_uom_id, curve_id, fixed_price_currency_id,'f' src
				FROM gen_deal_detail
			) sdd 
				ON fld.deal_number = sdd.source_deal_header_id and sdd.src=isnull(fld.deal_id_source,'s')
	INNER JOIN source_uom ON sdd.deal_volume_uom_id = source_uom.source_uom_id 
	LEFT JOIN source_price_curve_def ON sdd.curve_id = source_price_curve_def.source_curve_def_id 
	LEFT JOIN source_currency ON source_currency.source_currency_id = sdd.fixed_price_currency_id
	left join gen_fas_link_detail_dicing fldd on  fld.gen_link_id = fldd.link_id -- and  fld.deal_number = fldd.source_deal_header_id
	LEFT JOIN source_deal_header gen_sdh ON gen_sdh.source_deal_header_id = fld.deal_number
	WHERE sdd.Leg = 1
	GROUP BY fld.deal_number,sdh.deal_id,fld.percentage_included,fld.gen_link_id,
				sdh.deal_date,Book1.source_book_name,Book2.source_book_name,
				Book3.source_book_name, Book4.source_book_name,sdh.option_type,sdh.option_excercise_type
				,flh.gen_hedge_group_id,fld.gen_link_id,fld.hedge_or_item
	ORDER BY flh.gen_hedge_group_id,fld.gen_link_id,fld.hedge_or_item
END

GO
