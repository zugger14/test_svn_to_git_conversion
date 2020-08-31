INSERT INTO counterparty_credit_info (Counterparty_id)
SELECT 
 sc.source_counterparty_id 
FROM source_counterparty sc
WHERE NOT EXISTS (SELECT counterparty_id FROM counterparty_credit_info WHERE counterparty_id = sc.source_counterparty_id)