IF EXISTS (SELECT * FROM adiha_process.sys.tables WHERE [name] = 'alert_counterparty_process_id_ac')
BEGIN
	SELECT 
	CASE WHEN ISNULL(temp_cci.debt_rating, '') <> ISNULL(sdv.code, '') THEN 'Debt rating for counterparty <b>' + temp_cci.counterparty_name + '</b> changed from <b>' + ISNULL(temp_cci.debt_rating, 'NULL') + '</b> to <b>' + ISNULL(sdv.code, 'NULL') + '</b>. ' ELSE '' END + 
	CASE WHEN ISNULL(CAST(temp_cci.credit_limit AS VARCHAR), '') <> ISNULL(CAST(cci.credit_limit AS VARCHAR), '') THEN ' Credit Limit for counterparty <b>' + temp_cci.counterparty_name + '</b> changed from <b>' + ISNULL(CAST(CAST(temp_cci.credit_limit AS BIGINT) AS VARCHAR), 'NULL')+ '</b> to <b>'+ ISNULL(CAST(CAST(cci.credit_limit AS BIGINT) AS VARCHAR), 'NULL') + '</b>. ' ELSE '' END [Message]
	INTO staging_table.counterparty_credit_info_process_id_cci
	FROM   counterparty_credit_info cci
	INNER JOIN staging_table.alert_counterparty_process_id_ac temp_cci ON  temp_cci.counterparty_id = cci.Counterparty_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = cci.Debt_rating
	WHERE 1=1

	IF EXISTS (SELECT 1 FROM staging_table.counterparty_credit_info_process_id_cci)
	BEGIN
	EXEC spa_insert_alert_output_status var_alert_sql_id, 'process_id', NULL, NULL, NULL
	END
END