IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WHERE [name] = 'alert_power_outage_process_id_apo')
BEGIN
IF EXISTS (SELECT 1 FROM adiha_process.sys.tables WHERE [name] = 'alert_po_output_process_id_apo')
BEGIN
DROP TABLE staging_table.alert_po_output_process_id_apo
END

CREATE TABLE staging_table.alert_po_output_process_id_apo (
Generator VARCHAR(400) NULL,
[Term Start] DATETIME NULL,
[Term End] DATETIME NULL,
[Action] VARCHAR(1000)
)

DECLARE @source_deal_header_ids VARCHAR(4000)

INSERT INTO staging_table.alert_po_output_process_id_apo
SELECT rg.id, a.term_start, a.term_end, 'Inserted'
FROM staging_table.alert_power_outage_process_id_apo a
INNER JOIN rec_generator rg ON rg.generator_id = a.generator_id
WHERE [action] = 'i'

INSERT INTO staging_table.alert_po_output_process_id_apo
SELECT rg.id, a.term_start, a.term_end, 'Updated'
FROM staging_table.alert_power_outage_process_id_apo a
INNER JOIN rec_generator rg ON rg.generator_id = a.generator_id
WHERE [action] = 'u'

INSERT INTO staging_table.alert_po_output_process_id_apo
SELECT rg.id, a.term_start, a.term_end, 'Deleted'
FROM staging_table.alert_power_outage_process_id_apo a
INNER JOIN rec_generator rg ON rg.generator_id = a.generator_id
WHERE [action] = 'd'

EXEC spa_insert_alert_output_status var_alert_sql_id, 'process_id', NULL, NULL, NULL
END