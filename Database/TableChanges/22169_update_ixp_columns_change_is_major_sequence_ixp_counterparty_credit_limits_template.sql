DECLARE @ixp_tables_id INT

SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_counterparty_credit_limits_template'

UPDATE ixp_columns 
SET is_major = 0, is_required = 0
WHERE ixp_table_id = @ixp_tables_id

UPDATE ixp_columns 
SET is_major = 1, is_required = 1
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name IN ('counterparty_id', 'effective_Date')

UPDATE ixp_columns 
SET is_required = 1
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name IN ('credit_limit', 'currency_id')

UPDATE ixp_columns 
SET is_major = 1
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name IN ('contract_id', 'internal_counterparty_id')

/* Sequence Update */
UPDATE ixp_columns
SET seq = 10
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'counterparty_id'

UPDATE ixp_columns
SET seq = 20
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'contract_id'

UPDATE ixp_columns
SET seq = 30
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'internal_counterparty_id'

UPDATE ixp_columns
SET seq = 40
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'limit_status'

UPDATE ixp_columns
SET seq = 50
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'effective_Date'

UPDATE ixp_columns
SET seq = 60
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'credit_limit'

UPDATE ixp_columns
SET seq = 70
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'credit_limit_to_us'

UPDATE ixp_columns
SET seq = 80
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'currency_id'

UPDATE ixp_columns
SET seq = 90
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'max_threshold'

UPDATE ixp_columns
SET seq = 100
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'min_threshold'

UPDATE ixp_columns
SET seq = 110
WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'tenor_limit'

GO