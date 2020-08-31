IF OBJECT_ID(N'tempdb..#tmp_counterparty_contacts') IS NOT NULL
	DROP TABLE #tmp_counterparty_contacts
	
SELECT counterparty_id,counterparty_contact_id,contact_type
INTO #tmp_counterparty_contacts
FROM counterparty_contacts
 

UPDATE sc 
SET
	sc.payables = t1.counterparty_contact_id,
	sc.receivables = t2.counterparty_contact_id
FROM source_counterparty AS sc
LEFT JOIN #tmp_counterparty_contacts t1 ON t1.counterparty_id = sc.source_counterparty_id AND t1.contact_type = -32202 --payable
LEFT JOIN #tmp_counterparty_contacts t2 ON t2.counterparty_id = sc.source_counterparty_id AND t2.contact_type = -32203 --receivable



 