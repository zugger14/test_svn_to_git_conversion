DECLARE @ixp_tables_id INT

SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_contract_template'

UPDATE ixp_columns 
SET is_major = 0, is_required = 0
WHERE ixp_table_id = @ixp_tables_id

UPDATE ixp_columns 
SET is_major = 1, is_required = 1
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name IN ('source_contract_id')

UPDATE ixp_columns 
SET is_required = 1
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name IN ('contract_name','contract_type_def_id', 'currency', 'volume_uom', 'commodity', 'volume_granularity', 'settlement_date', 'settlement_days', 'invoice_due_date', 'payment_days', 'netting_statement', 'invoice_report_template', 'contract_report_template', 'netting_template', 'contract_email_template')
GO