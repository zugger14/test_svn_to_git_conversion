DECLARE @dependent_table TABLE(ixp_table_name VARCHAR(400), related_table VARCHAR(600))

INSERT INTO @dependent_table
SELECT 'ixp_source_counterparty_template', 'source_counterparty' UNION ALL
SELECT 'ixp_location_template', 'source_minor_location' UNION ALL
SELECT 'ixp_contract_template', 'contract_group' UNION ALL
SELECT 'ixp_source_book_template', 'source_book' UNION ALL
SELECT 'ixp_source_commodity_template', 'source_commodity' UNION ALL
SELECT 'ixp_source_currency_template', 'source_currency' UNION ALL
SELECT 'ixp_source_deal_type_template', 'source_deal_type' UNION ALL
SELECT 'ixp_source_trader_template', 'source_traders' UNION ALL
SELECT 'ixp_source_price_curve_def_template', 'source_price_curve_def' UNION ALL
SELECT 'ixp_source_uom_template', 'source_uom' UNION ALL
SELECT 'ixp_index_fees_breakdown_settlement_template', 'index_fees_breakdown_settlement' UNION ALL
SELECT 'ixp_source_deal_settlement_template', 'source_deal_settlement' UNION ALL
SELECT 'ixp_source_price_curve_template', 'source_price_curve' UNION ALL
SELECT 'ixp_holiday_calendar', 'holiday_group' UNION ALL
SELECT 'ixp_contract_detail_template', 'contract_group_detail' UNION ALL
SELECT 'ixp_source_deal_detail_hour_template', 'source_deal_detail_hour' UNION ALL
SELECT 'ixp_source_deal_detail_15min_template', 'source_deal_detail_hour' UNION ALL
SELECT 'ixp_curve_volatility_template', 'curve_volatility' UNION ALL
SELECT 'ixp_curve_correlation_template', 'curve_correlation' UNION ALL
SELECT 'ixp_static_data_value_template', 'static_data_value' UNION ALL
SELECT 'ixp_counterparty_credit_info_template', 'counterparty_credit_info' UNION ALL
SELECT 'ixp_delivery_path', 'delivery_path' UNION ALL
SELECT 'ixp_process_risk_controls', 'process_risk_controls' UNION ALL
SELECT 'ixp_alert_sql', 'alert_sql' UNION ALL
SELECT 'ixp_alert_rule_table', 'alert_rule_table' UNION ALL
SELECT 'ixp_alert_table_relation', 'alert_table_relation' UNION ALL
SELECT 'ixp_alert_table_where_clause', 'alert_table_where_clause' UNION ALL
SELECT 'ixp_alert_conditions', 'alert_conditions' UNION ALL
SELECT 'ixp_alert_actions', 'alert_actions' UNION ALL
SELECT 'ixp_alert_actions_events', 'alert_actions_events' UNION ALL
SELECT 'ixp_alert_workflows', 'alert_workflows' UNION ALL
SELECT 'ixp_alert_reports', 'alert_reports' UNION ALL
SELECT 'ixp_alert_users', 'alert_users' UNION ALL
SELECT 'ixp_portfolio_hierarchy', 'portfolio_hierarchy' UNION ALL
SELECT 'ixp_alert_table_definition', 'alert_table_definition' UNION ALL
SELECT 'ixp_alert_columns_definition', 'alert_columns_definition' UNION ALL
SELECT 'ixp_user_defined_fields_template', 'user_defined_fields_template' UNION ALL
SELECT 'ixp_maintain_field_template_detail_template', 'maintain_field_template_detail' UNION ALL
SELECT 'ixp_maintain_field_template', 'maintain_field_template' UNION ALL
SELECT 'ixp_maintain_field_template_group_template', 'maintain_field_template_group' UNION ALL
SELECT 'ixp_maintain_field_deal_template', 'maintain_field_deal' UNION ALL
SELECT 'ixp_application_users', 'application_users' UNION ALL
SELECT 'ixp_source_deal_detail_template', 'source_deal_detail' UNION ALL
SELECT 'ixp_time_zones', 'time_zones' UNION ALL
SELECT 'ixp_region', 'region' UNION ALL
SELECT 'ixp_source_deal_header_template', 'source_deal_header' UNION ALL
SELECT 'ixp_counterparty_contract_address_template', 'counterparty_contract_address' UNION ALL
SELECT 'ixp_counterparty_epa_account_template', 'counterparty_epa_account' UNION ALL
SELECT 'ixp_counterparty_bank_info_template', 'counterparty_bank_info' UNION ALL
SELECT 'ixp_counterparty_credit_enhancements_template', 'counterparty_credit_enhancements' UNION ALL
SELECT 'ixp_counterparty_credit_block_trading_template', 'counterparty_credit_block_trading' UNION ALL
SELECT 'ixp_counterparty_limit_calc_result_template', 'counterparty_limit_calc_result' UNION ALL
SELECT 'ixp_counterparty_limits_template', 'counterparty_limits' UNION ALL
SELECT 'ixp_source_deal_settlement_breakdown_template', 'source_deal_settlement_breakdown' UNION ALL
SELECT 'ixp_counterparty_confirm_info_template', 'counterparty_confirm_info' UNION ALL
SELECT 'ixp_counterparty_invoice_info_template', 'counterparty_invoice_info'


UPDATE ic
SET is_major = 1
--SELECT  dep.ixp_table_name, ic.ixp_columns_name 
FROM 
@dependent_table dep 
INNER JOIN sys.columns c ON  c.object_id = OBJECT_ID(dep.related_table)
INNER JOIN ixp_columns AS ic ON ic.ixp_columns_name = c.name
INNER JOIN ixp_tables AS it ON it.ixp_tables_name = dep.ixp_table_name AND it.ixp_tables_id = ic.ixp_table_id
WHERE c.is_nullable = 0 AND c.is_identity = 0 AND c.name <> 'source_system_id'

UPDATE ic
SET is_major = 1
--SELECT   ic.ixp_columns_name 
FROM ixp_tables AS it 
INNER JOIN ixp_columns AS ic ON ic.ixp_table_id = it.ixp_tables_id
WHERE it.ixp_tables_name IN ('ixp_hourly_allocation_data_template',
'ixp_15mins_allocation_data_template',
'ixp_10mins_allocation_data_template',
'ixp_monthly_allocation_data_template')
AND ic.ixp_columns_name IN ('meter_id','date')

UPDATE ic
SET is_major = 1
--SELECT  it.ixp_tables_id,  ic.ixp_columns_name 
FROM ixp_tables AS it 
INNER JOIN ixp_columns AS ic ON ic.ixp_table_id = it.ixp_tables_id
WHERE it.ixp_tables_name IN ('ixp_source_deal_template',
'ixp_voided_deals_template')
AND ic.ixp_columns_name IN (
'deal_id',
'deal_date',
'physical_financial_flag',
'counterparty_id',
'entire_term_start',
'entire_term_end',
'source_deal_type_id',
'option_flag',
'source_system_book_id1',
'deal_category_value_id',
'trader_id','term_start',
'term_end',
'Leg',
'contract_expiration_date',
'fixed_float_leg',
'buy_sell_flag',
'deal_volume_frequency',
'deal_volume_uom_id')
