DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables where ixp_tables_name = 'ixp_source_deal_template'

UPDATE ixp_columns SET seq = 451 
WHERE 1 = 1
	AND ixp_columns_name = 'formula_currency_id'
	AND ixp_table_id = @ixp_table_id

UPDATE ixp_columns SET seq = 401 
WHERE 1 = 1
	AND ixp_columns_name = 'fixed_cost_currency_id'
	AND ixp_table_id = @ixp_table_id
	
UPDATE ixp_columns SET datatype = '[datetime]' 
WHERE 1 = 1
	AND ixp_columns_name IN ('term_start','term_end')
	AND ixp_table_id = @ixp_table_id
