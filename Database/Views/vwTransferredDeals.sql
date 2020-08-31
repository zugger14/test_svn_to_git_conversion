IF EXISTS (
    SELECT *
    FROM   sys.views
    WHERE object_id = OBJECT_ID(N'[dbo].[vwTransferredDeals]')
)
    DROP VIEW [dbo].vwTransferredDeals
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW vwTransferredDeals 
AS 

SELECT sdh.source_deal_header_id,
       sdh.deal_id,
       sdh_transfer.source_deal_header_id [transfer_deal_id],
       sdh_transfer.deal_id [transfer_ref_id],
       sc.source_counterparty_id,
       sc.counterparty_name,
       cg.contract_id,
       cg.contract_name,
       st.source_trader_id,
       st.trader_name,
       dbo.FNARemoveTrailingZeroes(sdd_transfer.total_volume) [transfer_total_volume],
	   CASE WHEN sdd_transfer.deal_volume IS NOT NULL THEN dbo.FNARemoveTrailingZeroes(sdd_transfer.deal_volume) ELSE sdd_transfer.vol_only END [transfer_deal_volume],
	   CASE WHEN sdd_transfer.volume_multiplier2 IS NOT NULL THEN ROUND(dbo.FNARemoveTrailingZeroes(ISNULL(sdd_transfer.volume_multiplier2, 0) * 100), 4) ELSE (sdd_transfer.vol_only/sdd_original.deal_volume) * 100 END [transfer_percentage],
	   ssbm.logical_name [sub_book_name],
	   ssbm.book_deal_type_map_id [sub_book_id]
FROM source_deal_header sdh
LEFT JOIN source_deal_header sdh_offset ON sdh_offset.close_reference_id = sdh.source_deal_header_id AND sdh_offset.deal_reference_type_id = 12500 
LEFT JOIN source_deal_header sdh_transfer ON sdh_transfer.close_reference_id = ISNULL(sdh_offset.source_deal_header_id, sdh.source_deal_header_id) AND sdh_transfer.deal_reference_type_id = 12503
LEFT JOIN source_system_book_map ssbm
	ON ssbm.source_system_book_id1 = sdh_transfer.source_system_book_id1
	AND ssbm.source_system_book_id2 = sdh_transfer.source_system_book_id2
	AND ssbm.source_system_book_id3 = sdh_transfer.source_system_book_id3
	AND ssbm.source_system_book_id4 = sdh_transfer.source_system_book_id4
OUTER APPLY (
	SELECT SUM(total_volume) total_volume, MAX(volume_multiplier2) volume_multiplier2, MAX(deal_volume)*MAX(volume_multiplier2) deal_volume, MAX(deal_volume) vol_only
	FROM source_deal_detail sdd_transfer 
	WHERE sdd_transfer.source_deal_header_id = sdh_transfer.source_deal_header_id
) sdd_transfer
OUTER APPLY (
	SELECT MAX(deal_volume) deal_volume
	FROM source_deal_detail sdd 
	WHERE sdd.source_deal_header_id = sdh.source_deal_header_id
) sdd_original
INNER JOIN source_counterparty sc ON sc.source_counterparty_id = sdh_transfer.counterparty_id
INNER JOIN source_traders st ON st.source_trader_id = sdh_transfer.trader_id
LEFT JOIN contract_group cg ON cg.contract_id = sdh_transfer.contract_id
WHERE sdh.source_deal_header_id <> sdh_transfer.source_deal_header_id
AND sdh_transfer.source_deal_header_id IS NOT NULL
AND sdh_offset.source_deal_header_id <> sdh.source_deal_header_id