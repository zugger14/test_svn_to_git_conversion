DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id 
FROM ixp_tables WHERE ixp_tables_name = 'ixp_cash_apply'

UPDATE ixp_columns
SET column_datatype = 'NVARCHAR(600)'
WHERE ixp_table_id = @ixp_table_id
AND ixp_columns_name = 'Counterparty'

