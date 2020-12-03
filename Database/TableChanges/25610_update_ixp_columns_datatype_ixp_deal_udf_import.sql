DECLARE @ixp_tables_id INT 
SELECT @ixp_tables_id =  ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_deal_udf_import'

UPDATE
ixp_columns
SET datatype = NULL
WHERE ixp_table_id = @ixp_tables_id
AND ixp_columns_name = 'value'