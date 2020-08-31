IF NOT EXISTS (
       SELECT 1
       FROM   ixp_tables it
       WHERE  it.ixp_tables_name = 'ixp_mega_hedge'
   )
BEGIN
    INSERT INTO ixp_tables
      (
        ixp_tables_name,
        ixp_tables_description,
        import_export_flag
      )
    SELECT 'ixp_mega_hedge',
           'Mega Hedge',
           'i'
END

DECLARE @ixp_mega_hedge_id INT	
SELECT @ixp_mega_hedge_id = it.ixp_tables_id FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_mega_hedge'

IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'percentage_included' AND ixp_table_id = @ixp_mega_hedge_id) 
BEGIN 
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
	SELECT @ixp_mega_hedge_id, 'percentage_included', 0 
END