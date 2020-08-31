IF OBJECT_ID ('vwIndexFeesBreakdownStmt', 'V') IS NOT NULL
	DROP VIEW vwIndexFeesBreakdownStmt;
GO

-- ===============================================================================================================
-- Author: bmaharjan@pioneersolutionsglobal.com
-- Create date: 2018-11-30
-- Description: View of index fees breakdown settlement and source deal settlement
-- ===============================================================================================================

CREATE VIEW vwIndexFeesBreakdownStmt
AS 
	SELECT	ifbs.index_fees_id,
		-1 [source_deal_settlement_id],
		-1 [stmt_adjustments_id],
		-1 [stmt_contract_settlement_id],
		-1 [source_deal_prepay_id],
		-1 [stmt_prepay_id],
		ifbs.as_of_date,
		ifbs.source_deal_header_id,
		ifbs.leg,
		ifbs.term_start,
		ifbs.term_end,
		ifbs.field_id,
		ifbs.field_name,
		ifbs.price,
		ifbs.volume,
		ifbs.value,
		ifbs.internal_type,
		ifbs.currency_id,
		sdd.source_deal_detail_id,
		NULL contract_id,
		NULL contract_charge_type_id,
		NULL is_adjustment,
		NULL counterparty_id,
		'Cost' [Type],
		ifbs.shipment_id,
		ifbs.ticket_detail_id,
		ifbs.match_info_id
	FROM index_fees_breakdown_settlement ifbs
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = ifbs.source_deal_header_id AND sdd.leg = ifbs.leg AND sdd.term_start = ifbs.term_start AND sdd.term_end = ifbs.term_end
	UNION ALL
	SELECT	-1 [index_fees_id],
		sds.source_deal_settlement_id [source_deal_settlement_id],
		-1 [stmt_adjustments_id],
		-1 [stmt_contract_settlement_id],
		-1 [source_deal_prepay_id],
		-1 [stmt_prepay_id],
		sds.as_of_date,
		sds.source_deal_header_id,
		sds.leg,
		sds.term_start,
		CASE WHEN ISNULL(sdh.is_environmental,'n') = 'y' THEN sds.settlement_date ELSE sds.term_end END [term_end],
		-5500 [field_id],
		'Commodity Charge' [field_name],
		sds.net_price,
		sds.volume,
		sds.settlement_amount,
		NULL [internal_type],
		sds.settlement_currency_id,
		sdd.source_deal_detail_id,
		NULL [contract_id],
		NULL [contract_charge_type_id],
		NULL [is_adjustment],
		NULL [counterparty_id],	
		'Commodity Charge',
		sds.shipment_id,
		sds.ticket_detail_id,
		sds.match_info_id
	FROM source_deal_settlement sds
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sds.source_deal_header_id AND sdd.leg = sds.leg AND sdd.term_start = sds.term_start AND sdd.term_end = sds.term_end
	LEFT JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id
	UNION ALL
	SELECT	-1 [index_fees_id],
		-1 [source_deal_settlement_id],
		sa.stmt_adjustments_id [stmt_adjustments_id],
		-1 [stmt_contract_settlement_id],
		-1 [source_deal_prepay_id],
		-1 [stmt_prepay_id],
		sa.as_of_date,
		sa.source_deal_header_id,
		sa.leg,
		sa.term_start,
		sa.term_end,
		sa.charge_type_id [field_id],
		'Adjustment' [field_name],
		sa.price,
		sa.volume,
		sa.settlement_amount,
		NULL [internal_type],
		NULL settlement_currency_id,
		sdd.source_deal_detail_id,
		NULL [contract_id],
		NULL [contract_charge_type_id],
		NULL [is_adjustment],
		NULL [counterparty_id],	
		'Adjustment',
		sa.shipment_id,
		sa.ticket_detail_id,
		sa.match_info_id
	FROM stmt_adjustments sa
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sa.source_deal_header_id AND sdd.leg = sa.leg AND sdd.term_start = sa.term_start AND sdd.term_end = sa.term_end
	UNION ALL
	SELECT	-1 [index_fees_id],
		-1 [source_deal_settlement_id],
		-1 [stmt_adjustments_id],
		sca.stmt_contract_settlement_id [stmt_contract_settlement_id],
		-1 [source_deal_prepay_id],
		-1 [stmt_prepay_id],
		sca.as_of_date,
		scad.source_deal_header_id source_deal_header_id,
		NULL leg,
		sca.term_start,
		sca.term_end,
		NULL [field_id],
		NULL [field_name],
		sca.value/ISNULL(sca.volume,1),
		sca.volume,
		sca.value,
		NULL [internal_type],
		sca.currency_id settlement_currency_id,
		scad.source_deal_detail_id source_deal_detail_id,
		sca.contract_id [contract_id],
		sca.charge_type_id [contract_charge_type_id],
		NULL [is_adjustment],
		sca.counterparty_id [counterparty_id],	
		'Complex Contract Charges',
		NULL [shipment_id],
		NULL [ticket_detail_id],
		NULL [match_info_id]
	FROM stmt_contract_settlement sca
	LEFT JOIN stmt_contract_settlement_detail scad ON sca.stmt_contract_settlement_id = scad.stmt_contract_settlement_id
	UNION ALL
	SELECT	
		-1 [index_fees_id],
		-1 [source_deal_settlement_id],
		-1 [stmt_adjustments_id],
		-1 [stmt_contract_settlement_id],
		-1 [source_deal_prepay_id],
		-1 [stmt_prepay_id],
		ifbs.as_of_date,
		ifbs.source_deal_header_id,
		ifbs.leg,
		ifbs.term_start,
		ifbs.term_end,
		-5500,
		'Fees',
		ifbs.price,
		ifbs.volume,
		ifbs.value,
		ifbs.internal_type,
		ifbs.currency_id,
		sdd.source_deal_detail_id,
		NULL contract_id,
		NULL contract_charge_type_id,
		NULL is_adjustment,
		NULL counterparty_id,
		'Fees Calc Flag' [Type],
		ifbs.shipment_id,
		ifbs.ticket_detail_id,
		ifbs.match_info_id
	FROM index_fees_breakdown_settlement ifbs
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = ifbs.source_deal_header_id AND sdd.leg = ifbs.leg AND sdd.term_start = ifbs.term_start AND sdd.term_end = ifbs.term_end
	WHERE ISNULL(ifbs.internal_type,-1) IN (18723)
	UNION ALL
	SELECT	-1 [index_fees_id],
		-1 [source_deal_settlement_id],
		-1 [stmt_adjustments_id],
		-1 [stmt_contract_settlement_id],
		sdp.source_deal_prepay_id [source_deal_prepay_id],
		-1 [stmt_prepay_id],
		eomonth(sdp.settlement_date) as_of_date,
		sdp.source_deal_header_id,
		1 leg,
		dbo.fnagetcontractmonth(sdp.settlement_date) term_start,
		eomonth(sdp.settlement_date) term_end,
		-6600,
		'Prepay',
		NULL price,
		NULL volume,
		CASE WHEN sdh.header_buy_sell_flag = 'b' THEN sdp.value * -1 ELSE sdp.value END value,
		NULL internal_type,
		NULL currency_id,
		-1 source_deal_detail_id,
		NULL contract_id,
		NULL contract_charge_type_id,
		NULL is_adjustment,
		NULL counterparty_id,
		'Prepay' [Type],
		NULL shipment_id,
		NULL ticket_detail_id,
		NULL match_info_id
	FROM source_deal_prepay sdp
	INNER JOIN source_deal_header sdh ON sdp.source_deal_header_id = sdh.source_deal_header_id
	UNION ALL
	SELECT	-1 [index_fees_id],
		-1 [source_deal_settlement_id],
		-1 [stmt_adjustments_id],
		-1 [stmt_contract_settlement_id],
		-1 [source_deal_prepay_id],
		CASE WHEN mt.[mult] = 0 THEN -2 ELSE -1 END [stmt_prepay_id],
		MAX(eomonth(sp.settlement_date)) as_of_date,
		sp.source_deal_header_id,
		1 leg,
		NULL term_start,
		NULL term_end,
		-6600,
		'Prepay_Apply',
		NULL price,
		NULL volume,
		SUM(sp.amount) * -1 * mt.[mult] value,
		NULL internal_type,
		NULL currency_id,
		-1 source_deal_detail_id,
		NULL contract_id,
		NULL contract_charge_type_id,
		NULL is_adjustment,
		NULL counterparty_id,
		'Prepay_Apply' [Type],
		NULL shipment_id,
		NULL ticket_detail_id,
		NULL match_info_id
	FROM [stmt_prepay] sp
	INNER JOIN stmt_invoice_detail stid ON sp.stmt_invoice_detail_id = stid.stmt_invoice_detail_id
	INNER JOIN source_deal_header sdh ON sp.Source_Deal_Header_ID = sdh.source_deal_header_id
	OUTER APPLY (SELECT 0 [mult] UNION ALL SELECT 1) mt
	GROUP BY sp.Source_Deal_Header_ID, [mult], sdh.header_buy_sell_flag
	HAVING SUM(sp.amount) <> 0 OR MIN(ISNULL(sp.stmt_invoice_detail_id,-111)) > -111
