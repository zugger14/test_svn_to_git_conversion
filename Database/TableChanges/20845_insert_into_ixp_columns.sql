DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_deal_template'
 
-- insert into ixp_columns
IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'counterparty_id2')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'counterparty_id2', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'trader_id2')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'trader_id2', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'actual_volume')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'actual_volume', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'schedule_volume')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'schedule_volume', 0 )
END
