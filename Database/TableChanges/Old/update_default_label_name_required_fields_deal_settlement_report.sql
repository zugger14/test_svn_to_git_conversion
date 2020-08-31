UPDATE application_ui_template_definition SET default_label = 'As of Date' WHERE farrms_field_id = 'as_of_date' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Settlement Date From' WHERE farrms_field_id = 'settlement_date_from' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Settlement Date To' WHERE farrms_field_id = 'settlement_date_to' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Term Start' WHERE farrms_field_id = 'term_start' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Term End' WHERE farrms_field_id = 'term_end' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Detail Report' WHERE farrms_field_id = 'detail_option' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Summary Report Options' WHERE farrms_field_id = 'summary_option' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Deal Id' WHERE farrms_field_id = 'deal_id_from' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Reference Id' WHERE farrms_field_id = 'deal_id' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Deal Filter' WHERE farrms_field_id = 'deal_filter' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Round By Values' WHERE farrms_field_id = 'round_value' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Convert (UOM)' WHERE farrms_field_id = 'convert_uom' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Book Structure' WHERE farrms_field_id = 'book_structure' AND application_function_id = 10222300

UPDATE application_ui_template_definition SET default_label = 'Deal Date From' WHERE farrms_field_id = 'deal_date_from' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Deal Date To' WHERE farrms_field_id = 'deal_date_to' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Deal Type' WHERE farrms_field_id = 'deal_type_id' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Trader' WHERE farrms_field_id = 'trader_id' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Physical / Financial' WHERE farrms_field_id = 'phy_fin' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Group 1' WHERE farrms_field_id = 'source_system_book_id1' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Group 2' WHERE farrms_field_id = 'source_system_book_id2' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Group 3' WHERE farrms_field_id = 'source_system_book_id3' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Group 4' WHERE farrms_field_id = 'source_system_book_id4' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Parent Counterparty' WHERE farrms_field_id = 'parent_counterparty' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Entity Type' WHERE farrms_field_id = 'entity_type' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Counterparty Type' WHERE farrms_field_id = 'counterparty' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Curve Source' WHERE farrms_field_id = 'curve_source_id' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Counterparty' WHERE farrms_field_id = 'counterparty_id' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Contract' WHERE farrms_field_id = 'contract_ids' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Deal Status' WHERE farrms_field_id = 'deal_status' AND application_function_id = 10222300

UPDATE application_ui_template_definition SET insert_required = 'n' WHERE farrms_field_id IN ('settlement_date_from', 'settlement_date_to', 'term_start', 'term_end', 'deal_date_from', 'deal_date_to') AND application_function_id = 10222300
UPDATE application_ui_template_definition SET blank_option = 'n' WHERE farrms_field_id = 'detail_option' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET sql_string = 'SELECT su.source_uom_id, su.uom_name FROM source_uom su ORDER BY su.uom_name' WHERE farrms_field_id = 'convert_uom' AND application_function_id = 10222300

DECLARE @application_ui_field_id INT, @application_ui_template_id INT, @application_group_id INT, @grid_id INT

SELECT @application_ui_field_id = application_ui_field_id FROM application_ui_template_definition WHERE farrms_field_id = 'deal_id_from' AND application_function_id = 10222300
UPDATE application_ui_template_fields SET validation_message = 'Deal ID should be numeric.' WHERE application_ui_field_id = @application_ui_field_id

UPDATE application_ui_template_definition SET default_label = 'Deal ID' WHERE farrms_field_id = 'deal_id_from' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Reference ID' WHERE farrms_field_id = 'deal_id' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET data_type = 'varchar' WHERE farrms_field_id = 'detail_option' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET data_type = 'date' WHERE farrms_field_id IN('settlement_date_from', 'settlement_date_to', 'term_start', 'term_end', 'deal_date_from', 'deal_date_to', 'as_of_date') AND application_function_id = 10222300
UPDATE application_ui_template_definition SET data_type = 'boolean' WHERE farrms_field_id IN('official_status', 'enable_paging') AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_value = NULL WHERE farrms_field_id IN('settlement_date_from', 'settlement_date_to', 'term_start', 'term_end', 'deal_date_from', 'deal_date_to') AND application_function_id = 10222300
UPDATE application_ui_template_definition SET insert_required = 'y', field_size = 220, data_type = 'varchar' WHERE farrms_field_id = 'book_structure' AND application_function_id = 10222300

--Changed Deal filter to browse
SELECT @grid_id = grid_id from adiha_grid_definition WHERE grid_name = 'deal_filter'

UPDATE application_ui_template_definition SET field_type = 'browser' WHERE farrms_field_id = 'deal_filter' AND application_function_id = 10222300
SELECT @application_ui_field_id = application_ui_field_id FROM application_ui_template_definition WHERE farrms_field_id = 'deal_filter' AND application_function_id = 10222300
UPDATE application_ui_template_fields SET field_type = 'browser', grid_id = @grid_id WHERE application_ui_field_id = @application_ui_field_id

UPDATE application_ui_template_definition SET default_label = 'Report Type' WHERE farrms_field_id = 'detail_option' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Summarise By' WHERE farrms_field_id = 'summary_option' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Round Value' WHERE farrms_field_id = 'round_value' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_label = 'Convert UOM' WHERE farrms_field_id = 'convert_uom' AND application_function_id = 10222300

---- Moved Counterparty to General Tab
SELECT @application_group_id = application_group_id FROM application_ui_template_group 
WHERE application_ui_template_id = (SELECT application_ui_template_id FROM application_ui_template WHERE template_description = 'deal settlement report')
AND group_name = 'General'

UPDATE a
SET 
a.application_group_id = @application_group_id
FROM application_ui_template_fields a 
INNER JOIN application_ui_template_definition b ON b.application_ui_field_id = a.application_ui_field_id  
AND b.application_function_id = 10222300 AND b.farrms_field_id = 'counterparty_id'

---- Moved Contract to General Tab
UPDATE a
SET 
a.application_group_id = @application_group_id
FROM application_ui_template_fields a 
INNER JOIN application_ui_template_definition b ON b.application_ui_field_id = a.application_ui_field_id  
AND b.application_function_id = 10222300 AND b.farrms_field_id = 'contract_ids'

UPDATE application_ui_template_fields SET sequence = 1 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'book_structure')
UPDATE application_ui_template_fields SET sequence = 2 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'as_of_date')
UPDATE application_ui_template_fields SET sequence = 3 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'detail_option')
UPDATE application_ui_template_fields SET sequence = 4 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'summary_option')
UPDATE application_ui_template_fields SET sequence = 5 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'counterparty_id')
UPDATE application_ui_template_fields SET sequence = 6 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'contract_ids')
UPDATE application_ui_template_fields SET sequence = 7 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'deal_id_from')
UPDATE application_ui_template_fields SET sequence = 8 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'deal_id')
UPDATE application_ui_template_fields SET sequence = 9 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'deal_filter')
UPDATE application_ui_template_fields SET sequence = 10 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'round_value')
UPDATE application_ui_template_fields SET sequence = 11 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'convert_uom')
UPDATE application_ui_template_fields SET sequence = 12 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'term_start')
UPDATE application_ui_template_fields SET sequence = 13 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'term_end')
UPDATE application_ui_template_fields SET sequence = 14 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'settlement_date_from')
UPDATE application_ui_template_fields SET sequence = 15 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'settlement_date_to')
UPDATE application_ui_template_fields SET sequence = 16 WHERE application_group_id = @application_group_id AND application_ui_field_id = (SELECT application_ui_field_id FROM application_ui_template_definition WHERE application_function_id = 10222300 AND farrms_field_id = 'enable_paging')

---- Changed Counterparty and Contract into Browse from Combo
UPDATE application_ui_template_definition SET field_type = 'browser', default_value = NULL, sql_string = NULL WHERE farrms_field_id = 'counterparty_id' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET field_type = 'browser', default_value = NULL, sql_string = NULL WHERE farrms_field_id = 'contract_ids' AND application_function_id = 10222300

SELECT @grid_id = grid_id from adiha_grid_definition WHERE grid_name = 'browse_counterparty'
SELECT @application_ui_field_id = application_ui_field_id FROM application_ui_template_definition WHERE farrms_field_id = 'counterparty_id' AND application_function_id = 10222300
UPDATE application_ui_template_fields SET field_type = 'browser', grid_id = @grid_id WHERE application_ui_field_id = @application_ui_field_id

SELECT @grid_id = grid_id from adiha_grid_definition WHERE grid_name = 'browse_contract_counterparty'
SELECT @application_ui_field_id = application_ui_field_id FROM application_ui_template_definition WHERE farrms_field_id = 'contract_ids' AND application_function_id = 10222300
UPDATE application_ui_template_fields SET field_type = 'browser', grid_id = @grid_id WHERE application_ui_field_id = @application_ui_field_id

UPDATE application_ui_template_definition SET sql_string = 'SELECT * FROM (SELECT ''1'' AS [Value], ''1'' AS [Label] UNION ALL SELECT ''2'' AS [Value], ''2'' AS [Label] UNION ALL SELECT ''3'' AS [Value], ''3'' AS [Label] UNION ALL SELECT ''4'' AS [Value], ''4'' AS [Label] UNION ALL SELECT ''5'' AS [Value], ''5'' AS [Label] UNION ALL SELECT ''6'' AS [Value], ''6'' AS [Label] ) a' WHERE farrms_field_id = 'round_value' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_value = 'b', blank_option = 'n', data_type = 'char' WHERE farrms_field_id = 'phy_fin' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_value = 'y' WHERE farrms_field_id = 'official_status' AND application_function_id = 10222300
UPDATE application_ui_template_definition SET default_value = 'e', blank_option = 'n', data_type = 'char' WHERE farrms_field_id = 'counterparty' AND application_function_id = 10222300

DELETE FROM adiha_grid_definition WHERE grid_name = 'deal_status'
-- Changed Deal Status to browser
UPDATE application_ui_template_definition SET field_type = 'browser', data_type = 'varchar', default_value = NULL, sql_string = NULL WHERE farrms_field_id = 'deal_status' AND application_function_id = 10222300

SELECT @grid_id = grid_id from adiha_grid_definition WHERE grid_name = 'browse_deal_status'
SELECT @application_ui_field_id = application_ui_field_id FROM application_ui_template_definition WHERE farrms_field_id = 'deal_status' AND application_function_id = 10222300
UPDATE application_ui_template_fields SET field_type = 'browser', grid_id = @grid_id WHERE application_ui_field_id = @application_ui_field_id



