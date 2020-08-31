DECLARE @ixp_table_id INT

SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_contract_template'

UPDATE ixp_columns
SET datatype = NULL
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'settlement_date'

UPDATE ixp_columns
SET datatype = NULL
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name = 'invoice_due_date'

GO