IF OBJECT_ID(N'spa_GetAllDealsbySourceBookId', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_GetAllDealsbySourceBookId]
GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec spa_GetAllDealsbySourceBookId '400','2005-01-01','2008-01-23'

--DROP PROC spa_GetAllDealsbySourceBookId 
-- EXEC spa_GetAllDealsbySourceBookId '8', '1/1/2003', '1/1/2004'
-- EXEC spa_GetAllDealsbySourceBookId '25', '1/1/2003', '1/1/2004'

--===========================================================================================
--This Procedure returns all source book mapping entries along with the source book id
--Input Parameters:
-- book_id Int
--===========================================================================================


CREATE PROCEDURE [dbo].[spa_GetAllDealsbySourceBookId]
	@book_deal_type_map_id VARCHAR(MAX) = NULL,
	@as_of_date_from VARCHAR(20),
	@as_of_date_to VARCHAR(20),
	@book_id VARCHAR(MAX) = NULL,
	@sub_book_ids VARCHAR(MAX) = NULL
AS
SET NOCOUNT ON
-- 
-- DECLARE @book_deal_type_map_id varchar(100)
-- DECLARE @as_of_date_from varchar(20)
-- DECLARE @as_of_date_to varchar(20)
-- SET @book_deal_type_map_id = '8'
-- SET @as_of_date_from = '1/1/2002'
-- SET @as_of_date_to = '12/1/2003'



--########### Group Label
DECLARE @group1 VARCHAR(100),@group2 VARCHAR(100),@group3 VARCHAR(100),@group4 VARCHAR(100)
IF EXISTS(SELECT group1,group2,group3,group4 from source_book_mapping_clm)
BEGIN	
	SELECT @group1=group1,@group2=group2,@group3=group3,@group4=group4 FROM source_book_mapping_clm
END
ELSE
BEGIN
	SET @group1 = 'Group1'
	SET @group2 = 'Group2'
	SET @group3 = 'Group3'
	SET @group4 = 'Group4'
END

DECLARE @sql_Stmt VARCHAR(8000)
 
IF @book_id IS NOT NULL AND @sub_book_ids IS NOT NULL AND @book_deal_type_map_id IS NULL
BEGIN
	SELECT @book_deal_type_map_id =  COALESCE(@book_deal_type_map_id + ', ', '') +  CAST(ssbm.book_deal_type_map_id AS VARCHAR(8))
	FROM source_system_book_map ssbm
	INNER JOIN dbo.SplitCommaSeperatedValues(@book_id) i ON i.item = ssbm.fas_book_id
	WHERE 1 = 1
		AND ssbm.fas_deal_type_value_id = 400
END
BEGIN
	SET @sql_stmt = 
		'SELECT '''' hedging_relationship_type
			, dbo.FNAGetSQLStandardDate(CASE WHEN (MAX(flh.link_end_date) IS NOT NULL AND MAX(flh.link_end_date) > MAX(dh.deal_date)) THEN MAX(flh.link_end_date) ELSE MAX(dh.deal_date) END) AS effective_date
			, ''No'' perfect_hedge 
			, CAST (round((1 - isnull(sum(case when '''+@as_of_date_from+'''>=ISNULL(flh.link_end_date,''9999-01-01'') THEN 0 ELSE ISNULL(fld.percentage_included,0) END), 0) -	ISNULL(MAX(outstanding.percentage_use), 0)), 2) AS VARCHAR) AS percentage_available
			, dh.source_deal_header_id 
			, dbo.FNATRMWinHyperlink(''a'', 10131010, dh.deal_id, ABS(dh.source_deal_header_id),null,null,null,null,null,null,null,null,null,null,null,0) AS [deal_id]
			, dbo.FNAdateformat(dh.deal_date) AS deal_date
			, dbo.FNAdateformat(dh.entire_term_start) AS term_start
			, dbo.FNAdateformat(dh.entire_term_end) AS term_end
			--, source_deal_type.source_deal_type_name AS [Deal Type] 
			--, source_deal_type_1.source_deal_type_name AS [Deal Sub Type] 
			, CASE WHEN(MAX(dh.header_buy_sell_flag) = ''b'') THEN ''Buy'' ELSE ''Sell'' END buy_sell
			, cast(dbo.FNARemoveTrailingZeroes(MAX(deal_volume_info.deal_volume)) AS varchar) AS average_volume
			, max(suom.uom_name) AS UOM
		FROM source_deal_header dh 
		INNER JOIN source_system_book_map sbmp ON dh.source_system_book_id1 = sbmp.source_system_book_id1 
			AND dh.source_system_book_id2 = sbmp.source_system_book_id2 AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
			AND dh.source_system_book_id4 = sbmp.source_system_book_id4'
	IF @book_id IS NOT NULL
		SET @sql_stmt += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @book_id + ''') i ON i.item = sbmp.fas_book_id '	 

	SET @sql_stmt += ' INNER JOIN source_counterparty ON dh.counterparty_id = source_counterparty.source_counterparty_id 
		INNER JOIN (select source_deal_header_id, max(deal_volume_uom_id) deal_volume_uom_id, 
			MAX(deal_volume_frequency) deal_volume_frequency, AVG(deal_volume) deal_volume
			FROM source_deal_detail
			GROUP BY source_deal_header_id) deal_volume_info ON  deal_volume_info.source_deal_header_id = dh.source_deal_header_id 
		INNER JOIN source_uom suom ON suom.source_uom_id = deal_volume_info.deal_volume_uom_id 
		INNER JOIN source_deal_type ON dh.source_deal_type_id = source_deal_type.source_deal_type_id 
		INNER JOIN source_book ON dh.source_system_book_id1 = source_book.source_book_id 
		INNER JOIN source_book source_book_1 ON dh.source_system_book_id2 = source_book_1.source_book_id 
		INNER JOIN source_book source_book_2 ON dh.source_system_book_id3 = source_book_2.source_book_id 
		INNER JOIN source_book source_book_3 ON dh.source_system_book_id4 = source_book_3.source_book_id 
		LEFT OUTER JOIN source_deal_type source_deal_type_1 ON dh.deal_sub_type_type_id = source_deal_type_1.source_deal_type_id 
		LEFT OUTER JOIN fas_link_detail fld ON fld.source_deal_header_id = dh.source_deal_header_id 
		LEFT OUTER JOIN fas_link_header flh ON fld.link_id=flh.link_id 
		LEFT OUTER JOIN (SELECT ghgd.source_deal_header_id, SUM(ghgd.percentage_use) AS percentage_use
							 FROM source_deal_header dh 
							 INNER JOIN gen_hedge_group_detail ghgd ON ghgd.source_deal_header_id = dh.source_deal_header_id 
							 LEFT OUTER JOIN gen_fas_link_header ghg ON ghg.gen_hedge_group_id = ghgd.gen_hedge_group_id 
							 LEFT OUTER JOIN source_system_book_map sbmp ON (dh.source_system_book_id1 = sbmp.source_system_book_id1 
																		 AND dh.source_system_book_id2 = sbmp.source_system_book_id2 
																		 AND dh.source_system_book_id3 = sbmp.source_system_book_id3 
																		 AND dh.source_system_book_id4 = sbmp.source_system_book_id4)' 
				IF @book_id IS NOT NULL
					SET @sql_stmt += ' LEFT JOIN dbo.SplitCommaSeperatedValues(''' + @book_id + ''') i ON i.item = sbmp.fas_book_id'

				SET @sql_stmt += ' WHERE (ghg.gen_status IS NULL  OR ghg.gen_status = ''a'') 
						AND ISNULL(dh.fas_deal_type_value_id, sbmp.fas_deal_type_value_id) = 400 
						GROUP BY ghgd.source_deal_header_id)  outstanding ON outstanding.source_deal_header_id = dh.source_deal_header_id
		WHERE ISNULL(dh.fas_deal_type_value_id, sbmp.fas_deal_type_value_id) = 400'

		IF @sub_book_ids != ''
			SET @sql_stmt +='AND sbmp.book_deal_type_map_id IN (' + @sub_book_ids + ') '

		SET @sql_stmt +='AND dh.deal_date  <= ''' + @as_of_date_to + '''
		GROUP BY dh.source_deal_header_id, dh.deal_id, dh.deal_date, dh.deal_date, dh.physical_financial_flag, source_counterparty.counterparty_name, 
				   dh.entire_term_start, dh.entire_term_end, source_deal_type.source_deal_type_name, source_deal_type_1.source_deal_type_name, 
				   dh.option_flag, dh.option_type, dh.option_excercise_type, source_book.source_book_name, source_book_1.source_book_name, 
				   source_book_2.source_book_name, 
				   source_book_3.source_book_name HAVING (1 - ISNULL(SUM(CASE WHEN '''+@as_of_date_from+'''>=ISNULL(flh.link_end_date,''9999-01-01'') 
				   THEN 0 ELSE ISNULL(fld.percentage_included, 0) END), 0) - ISNULL(MAX(outstanding.percentage_use), 0)) >= 0.01'
	EXEC (@sql_Stmt)

      If @@ERROR <> 0
	  BEGIN
		Exec spa_ErrorHandler @@ERROR, 
				'Deals by Source Systems ids', 
				'spa_GetAllDealsbySourceBookId', 
				'DB Error', 
				'Failed to select the Deals for a book source mapping.', 
				''
      END
END

GO