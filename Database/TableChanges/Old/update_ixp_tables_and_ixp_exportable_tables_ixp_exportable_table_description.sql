
--Update ixp_table_description on ixp_tables
UPDATE it SET ixp_tables_description = 'Curve Correlations' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_curve_correlation_template'
UPDATE it SET ixp_tables_description = 'Counterparty Credit Information' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_credit_info_template' 
UPDATE it SET ixp_tables_description = 'Workflow Definition' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_process_risk_controls' 
UPDATE it SET ixp_tables_description = 'Alert Definition' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_sql' 
UPDATE it SET ixp_tables_description = 'Alert Table' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_table_definition' 
UPDATE it SET ixp_tables_description = 'Alert Columns' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_alert_columns_definition' 
UPDATE it SET ixp_tables_description = 'Deal Template (Detail)' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_deal_detail_template' 
UPDATE it SET ixp_tables_description = 'Deal Template (Header)' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_deal_header_template' 
UPDATE it SET ixp_tables_description = 'UDF Template' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_user_defined_fields_template' 
UPDATE it SET ixp_tables_description = 'Field Template (Detail)' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_maintain_field_template_detail_template' 
UPDATE it SET ixp_tables_description = 'Counterparty Contract Address' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_contract_address_template' 
UPDATE it SET ixp_tables_description = 'Counterparty EPA Account' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_epa_account_template' 
UPDATE it SET ixp_tables_description = 'Bank Information' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_bank_info_template' 
UPDATE it SET ixp_tables_description = 'Credit Enhancement' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_credit_enhancements_template' 
UPDATE it SET ixp_tables_description = 'Counterparty Credit Block' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_credit_block_trading_template' 
UPDATE it SET ixp_tables_description = 'Counterparty Limit Result' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_limit_calc_result_template' 
UPDATE it SET ixp_tables_description = 'Counterparty Limits' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_limits_template' 
UPDATE it SET ixp_tables_description = 'Field Template (Header)' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_maintain_field_template' 
UPDATE it SET ixp_tables_description = 'Field Template Group' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_maintain_field_template_group_template' 
UPDATE it SET ixp_tables_description = 'Deal Fields' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_maintain_field_deal_template' 
UPDATE it SET ixp_tables_description = 'Counterparty Confirm Info' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_confirm_info_template' 
UPDATE it SET ixp_tables_description = 'Invoice Information' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_invoice_info_template' 
UPDATE it SET ixp_tables_description = 'Deal Settlement Breakdown' FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_source_deal_settlement_breakdown_template' 


--Update ixp_exportable_table_description on ixp_exportable_table
UPDATE it SET  ixp_exportable_table_description = 'Deal Template (Header)' FROM ixp_exportable_table it WHERE it.ixp_exportable_table_name = 'source_deal_header_template'  
UPDATE it SET  ixp_exportable_table_description = 'Workflow Definition' FROM ixp_exportable_table it WHERE it.ixp_exportable_table_name = 'process_risk_controls'  
UPDATE it SET  ixp_exportable_table_description = 'Alert Definition' FROM ixp_exportable_table it WHERE it.ixp_exportable_table_name = 'alert_sql'  
UPDATE it SET  ixp_exportable_table_description = 'Alert Table' FROM ixp_exportable_table it WHERE it.ixp_exportable_table_name = 'alert_table_definition'  
UPDATE it SET  ixp_exportable_table_description = 'Alert Columns ' FROM ixp_exportable_table it WHERE it.ixp_exportable_table_name = 'alert_columns_definition'  
UPDATE it SET  ixp_exportable_table_description = 'Deal Template (Detail)' FROM ixp_exportable_table it WHERE it.ixp_exportable_table_name = 'source_deal_detail_template'  
UPDATE it SET  ixp_exportable_table_description = 'UDF Template ' FROM ixp_exportable_table it WHERE it.ixp_exportable_table_name = 'user_defined_fields_template'  
UPDATE it SET  ixp_exportable_table_description = 'Field Template (Header)' FROM ixp_exportable_table it WHERE it.ixp_exportable_table_name = 'maintain_field_template'  
UPDATE it SET  ixp_exportable_table_description = 'Field Template Group' FROM ixp_exportable_table it WHERE it.ixp_exportable_table_name = 'maintain_field_template_group'  
UPDATE it SET  ixp_exportable_table_description = 'Counterparty Contract Address' FROM ixp_exportable_table it WHERE it.ixp_exportable_table_name = 'counterparty_contract_address'  
UPDATE it SET  ixp_exportable_table_description = 'Counterparty Confirm Info' FROM ixp_exportable_table it WHERE it.ixp_exportable_table_name = 'counterparty_confirm_info'  
UPDATE it SET  ixp_exportable_table_description = 'Invoice Information' FROM ixp_exportable_table it WHERE it.ixp_exportable_table_name = 'counterparty_invoice_info'  


-- Delete Unnecessary from  ixp_depent_table
DELETE idt FROM ixp_dependent_table idt INNER JOIN ixp_tables it ON it.ixp_tables_id = idt.table_id WHERE it.ixp_tables_name = 'ixp_limit_available_template' 
DELETE idt FROM ixp_dependent_table idt INNER JOIN ixp_tables it ON it.ixp_tables_id = idt.table_id WHERE it.ixp_tables_name = 'ixp_process_requirement_revision' 

-- Delete Unnecessary from  ixp_table_meta_data
DELETE itmd FROM  ixp_table_meta_data itmd INNER JOIN ixp_tables it ON it.ixp_tables_id = itmd.ixp_tables_id WHERE itmd.table_name = 'ixp_limit_available_template' 
DELETE itmd FROM  ixp_table_meta_data itmd INNER JOIN ixp_tables it ON it.ixp_tables_id = itmd.ixp_tables_id WHERE itmd.table_name = 'ixp_process_requirement_revision' 

-- Delete Unnecessary from  ixp_exportable_table_name
DELETE  it FROM ixp_exportable_table it WHERE it.ixp_exportable_table_name = 'limit_available' 
DELETE  it FROM ixp_exportable_table it WHERE ixp_exportable_table_name = 'process_requirement_revision' 

-- Delete Unnecessary from  ixp_columns
DELETE ic FROM  ixp_columns ic INNER JOIN ixp_tables it ON it.ixp_tables_id = ic.ixp_table_id WHERE it.ixp_tables_name = 'ixp_limit_available_template' 
DELETE ic FROM  ixp_columns ic INNER JOIN ixp_tables it ON it.ixp_tables_id = ic.ixp_table_id WHERE it.ixp_tables_name = 'ixp_process_requirement_revision' 

-- Delete Unnecessary from ixp_tables_name
DELETE it FROM  ixp_tables it where it.ixp_tables_name = 'ixp_limit_available_template' 
DELETE it FROM  ixp_tables it where it.ixp_tables_name = 'ixp_process_requirement_revision' 

