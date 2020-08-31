IF NOT EXISTS(SELECT 1 FROM ixp_tables WHERE ixp_tables_name = 'ixp_subsidiary_template')
BEGIN
		INSERT INTO ixp_tables(ixp_tables_name,ixp_tables_description,import_export_flag)
		VALUES('ixp_subsidiary_template','Subsidiary','i')

END
ELSE 
	PRINT 'Table already exists'


DECLARE @ixp_tables_id INT

SELECT @ixp_tables_id = ixp_tables_id
FROM ixp_tables
WHERE ixp_tables_name = 'ixp_subsidiary_template'

IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'name')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'name', 'VARCHAR(600)', 0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'functional_currency')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'functional_currency', 'VARCHAR(600)', 0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'primary_counterparty')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'primary_counterparty', 'VARCHAR(600)', 0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'fx_conversion_market')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'fx_conversion_market', 'VARCHAR(600)', 0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'entity_type')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'entity_type', 'VARCHAR(600)', 0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'source_discount_values')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'source_discount_values', 'VARCHAR(600)', 0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'discount_type')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'discount_type', 'VARCHAR(600)', 0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'risk_free_interest_rate_curve')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'risk_free_interest_rate_curve', 'VARCHAR(600)', 0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'discount_rate')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'discount_rate', 'VARCHAR(600)', 0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'discount_param')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'discount_param', 'VARCHAR(600)', 0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'long_term_months')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'long_term_months', 'VARCHAR(600)', 0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'tax_percentage')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'tax_percentage', 'VARCHAR(600)', 0)
END
IF NOT EXISTS (SELECT 1 FROM ixp_columns WHERE ixp_table_id = @ixp_tables_id AND ixp_columns_name = 'timezone')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@ixp_tables_id, 'timezone', 'VARCHAR(600)', 0)
END


INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, column_datatype)
SELECT (
           SELECT it.ixp_tables_id
           FROM   ixp_tables it
           WHERE  it.ixp_tables_name = 'ixp_subsidiary_template'
       ) table_id,
       c.name,
       0,
	   'VARCHAR(600)'
FROM   sys.columns c
INNER JOIN sys.objects o ON  c.object_id = o.object_id
LEFT JOIN ixp_columns ic
    ON  ic.ixp_columns_name = c.name
    AND ic.ixp_table_id = (
            SELECT it.ixp_tables_id
            FROM   ixp_tables it
            WHERE  it.ixp_tables_name = 'ixp_subsidiary_template'
        )
WHERE  o.[name] = 'fas_subsidiaries' AND ic.ixp_columns_id IS NULL
