SELECT sc.counterparty_id [Counter Party Name],
       sdv.code [Enhancement Type],
       sc_g.counterparty_id [Guarantee Counterparty],
       CONVERT(VARCHAR, CAST(dbo.FNARemoveTrailingZero(cce.amount) AS MONEY), 1) [Amount],
       sc2.currency_id [Currency Code],
       CONVERT(VARCHAR(12), cce.eff_date, 107)[Effective Date],
       CONVERT(VARCHAR(12), cce.expiration_date, 107) [Expiration date],
       cce.approved_by [Approved By],
       CASE WHEN cce.margin = 'y' THEN 'Recieve' ELSE 'Provide' END [Receive Type],
       DATEDIFF(DAY, CURRENT_TIMESTAMP, expiration_date) [Remaining Days],
       'Please review the date' [Recommandation]
INTO staging_table.collatral_voilation_process_id_cv
FROM counterparty_credit_enhancements cce 
INNER JOIN counterparty_credit_info cci on cce.counterparty_credit_info_id = cci.counterparty_credit_info_id 
INNER JOIN source_counterparty sc on sc.source_counterparty_id = cci.Counterparty_id
INNER JOIN static_data_value sdv ON sdv.value_id = cce.enhance_type
LEFT JOIN source_counterparty sc_g ON sc_g.source_counterparty_id = cce.guarantee_counterparty
LEFT JOIN source_currency sc2 ON sc2.source_currency_id = cce.currency_code
WHERE DATEDIFF(Day,CURRENT_TIMESTAMP,expiration_date) <=5

IF EXISTS (SELECT 1 FROM staging_table.collatral_voilation_process_id_cv)
BEGIN
	EXEC spa_insert_alert_output_status var_alert_sql_id, 'process_id', NULL, NULL, NULL
END