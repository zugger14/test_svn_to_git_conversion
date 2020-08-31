
DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_deal_template'
 
-- insert into ixp_columns
IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'fx_conversion_market')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'fx_conversion_market', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'fx_rounding')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'fx_rounding', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'fx_option')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'fx_option', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'fx_conversion_rate')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'fx_conversion_rate', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'upstream_contract')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'upstream_contract', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'upstream_counterparty')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'upstream_counterparty', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'strike_granularity')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'strike_granularity', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'no_of_strikes')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'no_of_strikes', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'payment_date')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'payment_date', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'counterparty2_trader')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'counterparty2_trader', 0 )
END