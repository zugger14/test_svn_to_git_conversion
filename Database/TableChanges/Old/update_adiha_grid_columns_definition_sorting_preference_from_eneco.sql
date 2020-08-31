UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'credit_volume_multiplier' AND agd.grid_name = 'adjustment_default_gl_codes_detail'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'debit_volume_multiplier' AND agd.grid_name = 'adjustment_default_gl_codes_detail'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'detail_id' AND agd.grid_name = 'adjustment_default_gl_codes_detail'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'default_gl_id' AND agd.grid_name = 'adjustment_default_gl_codes_detail'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'term_end' AND agd.grid_name = 'adjustment_default_gl_codes_detail'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'term_start' AND agd.grid_name = 'adjustment_default_gl_codes_detail'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'role_id' AND agd.grid_name = 'application_security_role'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'application_users_id' AND agd.grid_name = 'application_users'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'effective_date' AND agd.grid_name = 'assign_priority_to_nomination_group'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'effective_date' AND agd.grid_name = 'broker_fees'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'source_curve_def_id' AND agd.grid_name = 'browse_curve'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'source_minor_location_id' AND agd.grid_name = 'BrowseDealLocation'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'meter_id' AND agd.grid_name = 'BrowseMeter'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'contract_id' AND agd.grid_name = 'contract_charge_type'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'flat_fee' AND agd.grid_name = 'contract_charge_type_detail'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'flat_fee' AND agd.grid_name = 'contract_component'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'contract_component_mapping_id' AND agd.grid_name = 'contract_component_mapping'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'create_ts' AND agd.grid_name = 'contract_group'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'payment_days' AND agd.grid_name = 'contract_group'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'settlement_days' AND agd.grid_name = 'contract_group'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'contract_id_show' AND agd.grid_name = 'contract_group'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'update_ts' AND agd.grid_name = 'contract_group'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'external_type_id' AND agd.grid_name = 'counterparty_epa_account'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'ixp_rules_id' AND agd.grid_name = 'data_export_import'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'adder_discount' AND agd.grid_name = 'deal_efp'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'term_end' AND agd.grid_name = 'deal_efp'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'term_start' AND agd.grid_name = 'deal_efp'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'volume' AND agd.grid_name = 'deal_efp'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'source_deal_header_id' AND agd.grid_name = 'deal_filter'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'Deal ID' AND agd.grid_name = 'deal_search'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'term_end' AND agd.grid_name = 'deal_triggers'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'term_start' AND agd.grid_name = 'deal_triggers'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'post_date' AND agd.grid_name = 'deal_triggers'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'fixed_price' AND agd.grid_name = 'deal_triggers'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'volume' AND agd.grid_name = 'deal_triggers'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'default_id' AND agd.grid_name = 'default_glcode'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'rec_volume_unit_conversion_id' AND agd.grid_name = 'define_uom_conversion'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'formula_id' AND agd.grid_name = 'formula_editor'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'gl_account_number' AND agd.grid_name = 'gl_system_mapping'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'gl_code3_value_id' AND agd.grid_name = 'gl_system_mapping'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'gl_number_id' AND agd.grid_name = 'gl_system_mapping'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'bank_id' AND agd.grid_name = 'grid_bank_info'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'contract_id' AND agd.grid_name = 'grid_contract_mapping'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'contract_end_date' AND agd.grid_name = 'grid_contract_mapping'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'contract_start_date' AND agd.grid_name = 'grid_contract_mapping'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'source_counterparty_id' AND agd.grid_name = 'grid_setup_counterparty'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'id' AND agd.grid_name = 'grid_setup_workflow'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'application_function_id' AND agd.grid_name = 'grid_static_data'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'value_id' AND agd.grid_name = 'grid_static_data'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'type_id' AND agd.grid_name = 'grid_static_data'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'default_gl_id' AND agd.grid_name = 'invoice_glcode'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'credit_volume_multiplier' AND agd.grid_name = 'invoice_glcode_detail'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'debit_volume_multiplier' AND agd.grid_name = 'invoice_glcode_detail'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'default_gl_id' AND agd.grid_name = 'invoice_glcode_detail'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'detail_id' AND agd.grid_name = 'invoice_glcode_detail'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'term_end' AND agd.grid_name = 'invoice_glcode_detail'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'term_start' AND agd.grid_name = 'invoice_glcode_detail'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'role_id' AND agd.grid_name = 'maintain_role_grid'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'meter_id' AND agd.grid_name = 'meter_filter'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'allocation_id' AND agd.grid_name = 'meter_id_allocation'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'meter_id' AND agd.grid_name = 'meter_id_allocation'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'production_month' AND agd.grid_name = 'meter_id_allocation'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'gre_per' AND agd.grid_name = 'meter_id_allocation'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'gre_volume' AND agd.grid_name = 'meter_id_allocation'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'recorder_property_id' AND agd.grid_name = 'recorder_properties'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'meter_id' AND agd.grid_name = 'recorder_properties'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'mult_factor' AND agd.grid_name = 'recorder_properties'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'report_id' AND agd.grid_name = 'report_ui'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'report_type' AND agd.grid_name = 'report_ui'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'source_counterparty_id' AND agd.grid_name = 'run_deal_settlement_counterparty'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'function_id' AND agd.grid_name = 'security_privilleges'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'role_id' AND agd.grid_name = 'security_roles'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'deal_price' AND agd.grid_name = 'setup_deals'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'deal_value' AND agd.grid_name = 'setup_deals'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'deal_volume' AND agd.grid_name = 'setup_deals'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'source_curve_def_id' AND agd.grid_name = 'setup_price_curve'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'application_function_id' AND agd.grid_name = 'SetupStaticData'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'value_id' AND agd.grid_name = 'SetupStaticData'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'type_id' AND agd.grid_name = 'SetupStaticData'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'rownumber' AND agd.grid_name = 'SetupStaticData'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'source_minor_location_id' AND agd.grid_name = 'source_minor_location'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'id' AND agd.grid_name = 'source_price_curve_def_privilege'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'source_minor_location_id' AND agd.grid_name = 'SourceMinorLocation'
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'type_id' AND agd.grid_name = 'static_data_type'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'date_created' AND agd.grid_name = 'view_scheduled_job'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'date_modified' AND agd.grid_name = 'view_scheduled_job'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'last_exectued_step_date' AND agd.grid_name = 'view_scheduled_job'
UPDATE agcd
SET sorting_preference = 'date'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'next_scheduled_run_date' AND agd.grid_name = 'view_scheduled_job'