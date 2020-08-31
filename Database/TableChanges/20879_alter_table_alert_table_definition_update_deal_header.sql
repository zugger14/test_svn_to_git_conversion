DECLARE @alert_table_definition_id INT

SELECT @alert_table_definition_id = alert_table_definition_id
FROM alert_table_definition
WHERE physical_table_name = 'source_deal_header'
 
UPDATE alert_table_definition
SET physical_table_name = 'vwSourceDealHeader'
WHERE alert_table_definition_id = @alert_table_definition_id