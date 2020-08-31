IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WHERE [name] = 'alert_assign_transaction_process_id_aat')
BEGIN
	IF EXISTS(SELECT 1 FROM staging_table.alert_assign_transaction_process_id_aat WHERE assignment_type IN( 5173,5146))
	BEGIN
		EXEC spa_insert_alert_output_status var_alert_sql_id, 'process_id', NULL, NULL, NULL
	END
END