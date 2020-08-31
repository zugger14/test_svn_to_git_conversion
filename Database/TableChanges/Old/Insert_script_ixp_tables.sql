IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_counterparty_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) SELECT 'ixp_source_counterparty_template'  , 'Counterparty', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_location_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_location_template'  , 'Location', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_contract_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_contract_template'  , 'Contract', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_book_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_book_template'  , 'Source Book', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_commodity_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_commodity_template'  , 'Commodity', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_currency_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_currency_template'  , 'Currency', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_deal_type_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_deal_type_template'  , 'Deal Type', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_trader_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_trader_template'  , 'Trader', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_price_curve_def_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_price_curve_def_template'  , 'Price Curve', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_uom_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_uom_template'  , 'UOM', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_index_fees_breakdown_settlement_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_index_fees_breakdown_settlement_template'  , 'Broker and Commission fees', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_deal_settlement_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_deal_settlement_template'  , 'Deal Settlement', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_deal_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_deal_template'  , 'Deal', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_voided_deals_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_voided_deals_template'  , 'Voided Deal', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_price_curve_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_price_curve_template'  , 'Price Curve Data', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_hourly_allocation_data_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_hourly_allocation_data_template'  , 'Allocation Data (Hourly)', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_15mins_allocation_data_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_15mins_allocation_data_template'  , 'Allocation Data (15mins)', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_holiday_calendar_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_holiday_calendar_template'  , 'Holiday Calendar', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_10mins_allocation_data_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_10mins_allocation_data_template'  , 'Allocation Data (10mins)', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_contract_detail_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_contract_detail_template'  , 'Contract Details', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_deal_detail_hour_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_deal_detail_hour_template'  , 'Shaped Deal Hourly Data', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_monthly_allocation_data_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_monthly_allocation_data_template'  , 'Allocation Data (Monthly)', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_deal_detail_15min_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_deal_detail_15min_template'  , 'Shaped Deal 15min Data', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_curve_volatility_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_curve_volatility_template'  , 'Curve Volatility', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_curve_correlation_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_curve_correlation_template'  , 'Curve Currelation', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_static_data_value_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_static_data_value_template'  , 'Static Data Value', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_counterparty_credit_info_template'  , 'Counterparty Credit Information', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_delivery_path_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_delivery_path_template'  , 'Delivery Path', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_process_risk_controls_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_process_risk_controls_template'  , 'Process Risk Controls', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_sql_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_alert_sql_template'  , 'Alert Sql', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_rule_table_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_alert_rule_table_template'  , 'Alert Rule Table', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_table_relation_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_alert_table_relation_template'  , 'Alert Table Relation', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_table_where_clause_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_alert_table_where_clause_template'  , 'Alert Table Where Clause', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_conditions_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_alert_conditions_template'  , 'Alert Conditions', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_actions_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_alert_actions_template'  , 'Alert Actions', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_actions_events_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_alert_actions_events_template'  , 'Alert Actions Events', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_workflows_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_alert_workflows_template'  , 'Alert Workflows', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_reports_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_alert_reports_template'  , 'Alert Reports', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_users_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_alert_users_template'  , 'Alert Users', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_portfolio_hierarchy_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_portfolio_hierarchy_template'  , 'Portfolio Hierarchy', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_process_requirement_revision_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_process_requirement_revision_template'  , 'Process Requirement Revision', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_table_definition_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_alert_table_definition_template'  , 'Alert Table Definition', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_columns_definition_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_alert_columns_definition_template'  , 'Alert Columns Definition', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_user_defined_fields_template_template'  , 'User Defined Fields Template', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_maintain_field_template_detail_template'  , 'Maintain Field Template Detail Template', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_maintain_field_template_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_maintain_field_template_template'  , 'Maintain Field Template', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_maintain_field_template_group_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_maintain_field_template_group_template'  , 'Maintain Field Template Group', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_maintain_field_template_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_maintain_field_template_template'  , 'Maintain Field Deal Template', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_application_users_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_application_users_template'  , 'Application Users', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_deal_detail_template_template'  , 'Deal Template (Detail)', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_time_zones_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_time_zones_template'  , 'Time Zones', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_region_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_region_template'  , 'Region', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_deal_header_template_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_deal_header_template_template'  , 'Deal Template (Header)', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_deal_settlement_breakdown_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_deal_settlement_breakdown_template'  , 'Source Deal Settlement Breakdown', 'i' END

IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_epa_account_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_counterparty_epa_account_template'  , 'counterparty_epa_account', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_counterparty_credit_info_template'  , 'counterparty_credit_info', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_counterparty_bank_info_template'  , 'counterparty_bank_info', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_counterparty_limits_template'  , 'counterparty_limits', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_counterparty_contract_address_template' , 'Counterparty Contract Address', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_confirm_info_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_counterparty_confirm_info_template'  , 'counterparty confirm info', 'e' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_counterparty_invoice_info_template'  , 'counterparty invoice info', 'e' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_counterparty_credit_enhancements_template'  , 'Credit Enhancement', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_formula_editor_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_formula_editor_template'  , 'Formula Editor', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_system_description_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_source_system_description_template'  , 'Source System', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_contract_report_template_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_contract_report_template_template'  , 'Contract Report Template', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_contract_charge_type_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_contract_charge_type_template'  , 'Contract Charge Type', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_contract_charge_type_detail_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_contract_charge_type_detail_template'  , 'Contract Charge Type Detail', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_adjustment_default_gl_codes_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_adjustment_default_gl_codes_template'  , 'Default GL Codes', 'i' END
IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_deal_detail_hour_template') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag)    SELECT 'ixp_deal_detail_hour_template'  , 'Forecast Data', 'i' END

-- insert data ixp_table_meta_data
INSERT INTO ixp_table_meta_data (ixp_tables_id, table_name)
SELECT it.ixp_tables_id,
       it.ixp_tables_name
FROM   ixp_tables it
LEFT JOIN ixp_table_meta_data itmd ON  itmd.ixp_tables_id = it.ixp_tables_id
WHERE  itmd.ixp_table_meta_data_table_id IS NULL

-- insert dependent tables for deals
INSERT INTO ixp_dependent_table (table_id, parent_table_id, seq_number)
SELECT itmd.ixp_table_meta_data_table_id,
       itmd2.ixp_table_meta_data_table_id,
       ROW_NUMBER() OVER(ORDER BY itmd.ixp_table_meta_data_table_id DESC)
FROM   ixp_table_meta_data itmd
INNER JOIN ixp_table_meta_data itmd2 ON  itmd2.table_name = 'ixp_source_deal_template'
LEFT JOIN ixp_dependent_table idt
    ON  idt.table_id = itmd.ixp_table_meta_data_table_id
    AND idt.parent_table_id = itmd2.ixp_table_meta_data_table_id
WHERE  idt.ixp_dependent_table_id IS NULL
       AND itmd.table_name IN ('ixp_source_counterparty_template', 
                               'ixp_contract_template', 
                               'ixp_source_book_template', 
                               'ixp_source_commodity_template', 
                               'ixp_source_currency_template', 
                               'ixp_source_deal_type_template', 
                               'ixp_source_trader_template', 
                               'ixp_source_price_curve_def_template', 
                               'ixp_source_uom_template', 
                               'ixp_location_template'
                               )

-- NEED TO UPDATE seq_number if new dependent table is inserted. 


-- insert dependent tables for maintain template
INSERT INTO ixp_dependent_table (table_id, parent_table_id, seq_number)
SELECT itmd.ixp_table_meta_data_table_id,
       itmd2.ixp_table_meta_data_table_id,
       ROW_NUMBER() OVER(ORDER BY itmd.ixp_table_meta_data_table_id DESC)
FROM   ixp_table_meta_data itmd
INNER JOIN ixp_table_meta_data itmd2 ON  itmd2.table_name = 'ixp_maintain_field_template_detail_template'
LEFT JOIN ixp_dependent_table idt
    ON  idt.table_id = itmd.ixp_table_meta_data_table_id
    AND idt.parent_table_id = itmd2.ixp_table_meta_data_table_id
WHERE  idt.ixp_dependent_table_id IS NULL
       AND itmd.table_name IN ('ixp_maintain_field_template', 
                               'ixp_maintain_field_template_group_template', 
                               'ixp_maintain_field_deal_template_template')

-- NEED TO UPDATE seq_number if new dependent table is inserted. 

