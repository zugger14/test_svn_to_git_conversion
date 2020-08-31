DECLARE @ixp_source_price_curve_template_id INT 
SELECT @ixp_source_price_curve_template_id = it.ixp_tables_id FROM   ixp_tables it WHERE  it.ixp_tables_name = 'ixp_source_price_curve_template'

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_source_price_curve_template_id and ic.ixp_columns_name LIKE 'hour')
  BEGIN
   INSERT INTO ixp_columns
  (
   ixp_table_id,
   ixp_columns_name,
   column_datatype,
   is_major
  )
  VALUES
  (
   @ixp_source_price_curve_template_id,
   'hour',
   'VARCHAR(600)',
   '0'
  )
END