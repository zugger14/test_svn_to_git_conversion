IF OBJECT_ID('dbo.spa_update_rowid_position') IS NOT NULL
	DROP PROCEDURE dbo.spa_update_rowid_position
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

 /**
	Update position filter group rowid in all position table.

	Parameters :
	@sub_ids : Subsidiary filter for deals to process
	@stra_ids : Strategy filter for deals to process
	@book_ids : Book filter for deals to process
	@deal_header_ids : Deal filter to process
	@deal_detail_ids : Deal detail filter to process
*/

CREATE PROCEDURE dbo.spa_update_rowid_position
	@sub_ids VARCHAR(MAX) = NULL, -- TODO: apply filter by Subsidiary
	@stra_ids VARCHAR(MAX) = NULL, -- TODO: apply filter by Strategy
	@book_ids VARCHAR(MAX)	= NULL, -- TODO: apply filter by Book
	@deal_header_ids VARCHAR(MAX) = NULL,
	@deal_detail_ids VARCHAR(MAX) = NULL
AS

/*** Debug Section ***
DECLARE @sub_ids VARCHAR(MAX) = NULL,
	@stra_ids VARCHAR(MAX) = NULL,
	@book_ids VARCHAR(MAX)	= NULL,
	@deal_header_ids VARCHAR(MAX) = NULL,
	@deal_detail_ids VARCHAR(MAX) = NULL

--*/

/********************************************************
Columns that do not depend on position value.
sdh.deal_status
sdh.source_deal_type_id
sdh.pricing_type
sdh.internal_portfolio_id
sdd.physical_financial_flag
sdh.counterparty_id
sdh.trader_id
sdh.contract_id
ssbm.book_deal_type_map_id
********************************************************/

DECLARE @sql VARCHAR(MAX)

--Taking all the deals need to be recalculated
CREATE TABLE #map_header_deal_id (source_deal_detail_id INT)

SET @sql = '
	INSERT INTO #map_header_deal_id (source_deal_detail_id)
	SELECT sdd.source_deal_detail_id
	FROM source_deal_header sdh
	INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
	INNER JOIN source_system_book_map ssbm ON ssbm.source_system_book_id1 = sdh.source_system_book_id1
		AND ssbm.source_system_book_id2 = sdh.source_system_book_id2
		AND ssbm.source_system_book_id3 = sdh.source_system_book_id3
		AND ssbm.source_system_book_id4 = sdh.source_system_book_id4
	INNER JOIN portfolio_hierarchy book (NOLOCK) ON ssbm.fas_book_id = book.entity_id
	INNER JOIN Portfolio_hierarchy stra (NOLOCK) ON book.parent_entity_id = stra.entity_id
	WHERE 1 = 1
	' +
	CASE WHEN @sub_ids IS NOT NULL THEN ' AND stra.parent_entity_id IN (' + @sub_ids + ')' ELSE '' END +
	CASE WHEN @stra_ids IS NOT NULL THEN ' AND stra.entity_id IN (' + @stra_ids + ')' ELSE '' END +
	CASE WHEN @book_ids IS NOT NULL THEN ' AND book.entity_id IN (' + @book_ids + ')' ELSE '' END +
	CASE WHEN @deal_header_ids IS NOT NULL THEN ' AND sdh.source_deal_header_id IN (' + @deal_header_ids + ')' ELSE '' END +
	CASE WHEN @deal_detail_ids IS NOT NULL THEN ' AND sdd.source_deal_detail_id IN (' + @deal_detail_ids + ')' ELSE '' END


EXEC spa_print @sql
EXEC(@sql)

IF OBJECT_ID('tempdb..#position_report_group_map') IS NOT NULL
	DROP TABLE #position_report_group_map

SELECT sdd.source_deal_detail_id,
	ISNULL(sdd.curve_id, -1) curve_id,
	ISNULL(sdd.location_id, -1) location_id,
	COALESCE(spcd.commodity_id, sdh.commodity_id, -1) commodity_id,
	ISNULL(sdh.counterparty_id, -1) counterparty_id,
	ISNULL(sdh.trader_id, -1) trader_id,
	ISNULL(sdh.contract_id,-1) contract_id,
	ssbm.book_deal_type_map_id subbook_id,
	COALESCE(sdd.position_uom, spcd.display_uom_id, spcd.uom_id, -1) deal_volume_uom_id,
	ISNULL(sdh.deal_status, -1) deal_status_id,
	ISNULL(sdh.source_deal_type_id, -1) deal_type,
	ISNULL(sdh.pricing_type, -1) pricing_type,
	ISNULL(sdh.internal_portfolio_id, -1) internal_portfolio_id,
	ISNULL(sdd.physical_financial_flag, 'p') physical_financial_flag,
	rowid = CAST(0 AS INT)
INTO #position_report_group_map
FROM  source_deal_header sdh
INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN #map_header_deal_id thdi ON sdd.source_deal_detail_id = thdi.source_deal_detail_id
INNER JOIN source_system_book_map ssbm ON sdh.source_system_book_id1 = ssbm.source_system_book_id1
	AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
	AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
	AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sdd.curve_id

INSERT INTO dbo.position_report_group_map (
	curve_id,
	location_id,
	commodity_id,
	counterparty_id,
	trader_id,
	contract_id,
	subbook_id,
	-- deal_volume_uom_id,
	deal_status_id,
	deal_type,
	pricing_type,
	internal_portfolio_id,
	physical_financial_flag
)
SELECT DISTINCT ISNULL(s.curve_id, -1),
	ISNULL(s.location_id, -1),
	ISNULL(s.commodity_id, -1),
	ISNULL(s.counterparty_id, -1),
	ISNULL(s.trader_id, -1),
	ISNULL(s.contract_id, -1),
	ISNULL(s.subbook_id, -1),
	-- s.deal_volume_uom_id,
	ISNULL(s.deal_status_id, -1),
	ISNULL(s.deal_type, -1),
	ISNULL(s.pricing_type, -1),
	ISNULL(s.internal_portfolio_id, -1),
	ISNULL(s.physical_financial_flag, 'p')
FROM #position_report_group_map s
LEFT JOIN position_report_group_map d ON s.curve_id = d.curve_id
	AND s.location_id = d.location_id
	AND s.commodity_id = d.commodity_id
	AND s.counterparty_id = d.counterparty_id
	AND s.trader_id = d.trader_id
	AND s.contract_id = d.contract_id
	AND s.subbook_id = d.subbook_id
	-- AND s.deal_volume_uom_id = d.deal_volume_uom_id
	AND s.deal_status_id = d.deal_status_id
	AND s.deal_type = d.deal_type
	AND s.pricing_type = d.pricing_type
	AND s.internal_portfolio_id = d.internal_portfolio_id
	AND s.physical_financial_flag = d.physical_financial_flag
WHERE d.rowid IS NULL

UPDATE s
SET rowid = d.rowid
FROM #position_report_group_map s
INNER JOIN position_report_group_map d ON s.curve_id=d.curve_id
	AND s.location_id = d.location_id
	AND s.commodity_id = d.commodity_id
	AND s.counterparty_id = d.counterparty_id
	AND s.trader_id = d.trader_id
	AND s.contract_id = d.contract_id
	AND s.subbook_id = d.subbook_id
	AND s.deal_status_id = d.deal_status_id
	AND s.deal_type = d.deal_type
	AND s.pricing_type = d.pricing_type
	AND s.internal_portfolio_id = d.internal_portfolio_id
	AND s.physical_financial_flag = d.physical_financial_flag

IF @@ROWCOUNT > 0
BEGIN
	UPDATE p
	SET rowid = t.rowid
	FROM #position_report_group_map t
	INNER JOIN report_hourly_position_deal_main p ON t.source_deal_detail_id = p.source_deal_detail_id

	UPDATE p
	SET rowid = t.rowid
	FROM #position_report_group_map t
	INNER JOIN report_hourly_position_profile_main p ON t.source_deal_detail_id = p.source_deal_detail_id

	UPDATE p
	SET rowid = t.rowid
	FROM #position_report_group_map t
	INNER JOIN report_hourly_position_breakdown_main p ON t.source_deal_detail_id = p.source_deal_detail_id

	UPDATE p
	SET rowid = t.rowid
	FROM #position_report_group_map t
	INNER JOIN report_hourly_position_financial_main p ON t.source_deal_detail_id = p.source_deal_detail_id

	UPDATE p
	SET rowid = t.rowid
	FROM #position_report_group_map t
	INNER JOIN report_hourly_position_fixed_main p ON t.source_deal_detail_id = p.source_deal_detail_id

	UPDATE p
	SET rowid = t.rowid
	FROM #position_report_group_map t
	INNER JOIN delta_report_hourly_position_main p ON t.source_deal_detail_id = p.source_deal_detail_id

	UPDATE p
	SET rowid = t.rowid
	FROM #position_report_group_map t
	INNER JOIN delta_report_hourly_position_breakdown_main p ON t.source_deal_detail_id = p.source_deal_detail_id

	UPDATE p
	SET rowid = t.rowid
	FROM #position_report_group_map t
	INNER JOIN delta_report_hourly_position_financial_main p ON t.source_deal_detail_id = p.source_deal_detail_id
END

GO