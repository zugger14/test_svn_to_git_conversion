IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WHERE [name] = 'nested_alert_process_id_na')
BEGIN

SELECT sc.counterparty_id [Counterparty],
	   'Limit' [Changed Column],
       CONVERT(VARCHAR, CAST(ISNULL(temp.previous_credit_limit, 0) AS MONEY), 1) [Previous Value],
       CONVERT(VARCHAR, CAST(ISNULL(cci.credit_limit, 0) AS MONEY), 1) [Current Value]
INTO staging_table.alert_credit_limit_output_process_id_aclo       
FROM [output_table] temp
INNER JOIN counterparty_credit_limits cci ON cci.counterparty_credit_limit_id = temp.counterparty_credit_limit_id 
	AND cci.counterparty_id = temp.counterparty_id 
INNER JOIN source_counterparty sc ON cci.Counterparty_id = sc.source_counterparty_id
WHERE temp.credit_limit_compare = 0

UNION ALL

SELECT sc.counterparty_id [Counterparty],
	   'Limit To Us' [Changed Column],
       CONVERT(VARCHAR, CAST(ISNULL(temp.previous_credit_limit_to_us, 0) AS MONEY), 1) [Previous Value],
       CONVERT(VARCHAR, CAST(ISNULL(cci.credit_limit_to_us, 0) AS MONEY), 1) [Current Value]
FROM [output_table] temp
INNER JOIN counterparty_credit_limits cci ON cci.counterparty_credit_limit_id = temp.counterparty_credit_limit_id 
	AND cci.counterparty_id = temp.counterparty_id 
INNER JOIN source_counterparty sc ON cci.Counterparty_id = sc.source_counterparty_id
WHERE temp.credit_limit_compare = 0

END