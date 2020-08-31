SELECT source_deal_header_id,
       6 [sql_id] -- to be changed. SQL id of Self 
INTO staging_table.deal_validation_new_process_id_dv
FROM   staging_table.alert_deal_process_id_ad

EXEC spa_insert_alert_output_status var_alert_sql_id, 'process_id', NULL, NULL, NULL

UPDATE alert_workflows
SET workflow_trigger = 'y'
WHERE alert_workflows_id = 3 -- to be changed. Should take workflow id defined in alert