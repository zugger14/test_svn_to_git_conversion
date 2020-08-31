SELECT 
sc.counterparty_id [Counterparty Name] ,
cci.Last_review_date [Last Review Date],
cci.Next_review_date [Next Review Date],
DATEDIFF(DAY,CURRENT_TIMESTAMP,cci.Next_review_date) [Days Remaining for Review],
'Please review credit file.' [Recommendation]
--INTO staging_table.credit_file_process_id_cf
FROM counterparty_credit_info cci 
INNER JOIN source_counterparty sc ON sc.source_counterparty_id = cci.counterparty_id
WHERE DATEDIFF(DAY,cci.Next_review_date,CURRENT_TIMESTAMP) < = 5

IF EXISTS (SELECT 1 FROM staging_table.credit_file_process_id_cf)
BEGIN
	EXEC spa_insert_alert_output_status var_alert_sql_id, 'process_id', NULL, NULL, NULL
END


