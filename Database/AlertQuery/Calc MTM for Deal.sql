DECLARE @term_start DATETIME
DECLARE @term_end DATETIME
SELECT @term_start = sdh.entire_term_start
                , @term_end = sdh.entire_term_end
FROM staging_table.alert_deal_process_id_ad st
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = st.source_deal_header_id
INNER JOIN generic_mapping_header AS gmh ON gmh.mapping_name = 'Valid Templates'
INNER JOIN generic_mapping_definition gmd ON gmd.mapping_table_id = gmh.mapping_table_id
INNER JOIN generic_mapping_values AS gmv ON gmv.mapping_table_id = gmh.mapping_table_id
	AND gmv.clm1_value = CAST(sdh.template_id AS VARCHAR(10))
 
IF DATEDIFF(dd, @term_start, @term_end) > 7 AND @term_start IS NOT NULL AND @term_end IS NOT NULL
BEGIN
    EXEC spa_run_mtm_from_alert 'staging_table.alert_deal_process_id_ad'
 
    DECLARE @new_alert_id INT
    SELECT @new_alert_id = as1.alert_sql_id FROM alert_sql as1 WHERE as1.alert_sql_name = 'Deal Capture (first)'
 
    IF @new_alert_id IS NOT NULL
    BEGIN
    EXEC spa_run_alert_sql @new_alert_id, 'new_process_id', 'staging_table.alert_deal_process_id_ad', NULL, NULL
    END
END