SELECT sdh.source_deal_header_id [Deal ID], sdh.deal_id [Ref ID], sc.counterparty_name [Counterparty], dbo.FNADateFormat(sdd.delivery_date) [Delivery Date], dbo.FNADateFormat(sdd.term_start) [Vintage Start], dbo.FNADateFormat(sdd.term_end) [Vintage End], dbo.FNARemoveTrailingZero(sdd.deal_volume) [Best Available Volume],
  dbo.FNARemoveTrailingZero(sdd.volume_left) [Volume Left]
INTO adiha_process.dbo.deal_delivery_date_process_id_ddd
FROM source_deal_header sdh 
INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id
INNER JOIN source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
LEFT JOIN source_commodity scom ON scom.source_commodity_id = sdh.commodity_id
WHERE CAST(sdd.delivery_date AS DATE) BETWEEN CAST(GETDATE() AS DATE) AND CAST(DATEADD(DAY,5,GETDATE()) AS DATE)   
AND sdh.header_buy_sell_flag = 's' AND sdh.is_environmental = 'y' ORDER BY sdd.delivery_date DESC

IF NOT EXISTS (SELECT 1 FROM adiha_process.dbo.deal_delivery_date_process_id_ddd)
BEGIN
RETURN
END