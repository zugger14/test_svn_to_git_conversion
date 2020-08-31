DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables where ixp_tables_name = 'ixp_source_price_curve_template'

SELECT @ixp_table_id

UPDATE ixp_columns SET is_major = 1 
WHERE 1 = 1
	AND ixp_columns_name IN ('source_curve_def_id','as_of_date','Assessment_curve_type_value_id','curve_source_value_id','maturity_date','curve_value')
	AND ixp_table_id = @ixp_table_id
	
UPDATE ixp_columns SET datatype = '[datetime]' 
WHERE 1 = 1
	AND ixp_columns_name IN ('as_of_date','maturity_date')
	AND ixp_table_id = @ixp_table_id
