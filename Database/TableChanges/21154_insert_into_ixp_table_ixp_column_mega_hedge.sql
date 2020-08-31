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

IF @ixp_mega_hedge_id IS NOT NULL
BEGIN
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'subsidiary' AND ixp_table_id = @ixp_mega_hedge_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
		SELECT @ixp_mega_hedge_id, 'subsidiary', 0 
	END
	
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'strategy' AND ixp_table_id = @ixp_mega_hedge_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
		SELECT @ixp_mega_hedge_id, 'strategy', 0 
	END
	
	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'book' AND ixp_table_id = @ixp_mega_hedge_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
		SELECT @ixp_mega_hedge_id, 'book', 0 
	END

	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'reference_id' AND ixp_table_id = @ixp_mega_hedge_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
		SELECT @ixp_mega_hedge_id, 'reference_id', 0 
	END

	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'transaction_type' AND ixp_table_id = @ixp_mega_hedge_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
		SELECT @ixp_mega_hedge_id, 'transaction_type', 0 
	END

	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'perfect_hedge' AND ixp_table_id = @ixp_mega_hedge_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
		SELECT @ixp_mega_hedge_id, 'perfect_hedge', 0 
	END

	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'fully_dedesignated' AND ixp_table_id = @ixp_mega_hedge_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
		SELECT @ixp_mega_hedge_id, 'fully_dedesignated', 0 
	END

	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'link_description' AND ixp_table_id = @ixp_mega_hedge_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
		SELECT @ixp_mega_hedge_id, 'link_description', 0 
	END

	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'hedging_relationship_type' AND ixp_table_id = @ixp_mega_hedge_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
		SELECT @ixp_mega_hedge_id, 'hedging_relationship_type', 0 
	END

	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'hedging_relationship_type_id' AND ixp_table_id = @ixp_mega_hedge_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
		SELECT @ixp_mega_hedge_id, 'hedging_relationship_type_id', 0 
	END

	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'link_effective_date' AND ixp_table_id = @ixp_mega_hedge_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
		SELECT @ixp_mega_hedge_id, 'link_effective_date', 0 
	END

	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'link_type_value' AND ixp_table_id = @ixp_mega_hedge_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
		SELECT @ixp_mega_hedge_id, 'link_type_value', 0 
	END

	IF NOT EXISTS (SELECT * FROM ixp_columns WHERE ixp_columns_name = 'link_active' AND ixp_table_id = @ixp_mega_hedge_id) 
	BEGIN 
		INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major) 
		SELECT @ixp_mega_hedge_id, 'link_active', 0 
	END
END

