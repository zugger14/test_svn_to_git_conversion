
DECLARE @ixp_tables_id INT
SELECT @ixp_tables_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_counterparty_contract_address_template'
 
-- insert into ixp_columns
IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'interest_rate')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'interest_rate', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'interest_method')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'interest_method', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'counterparty_trigger')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'counterparty_trigger', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'company_trigger')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'company_trigger', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'payment_rule')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'payment_rule', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'payment_days')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'payment_days', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'holiday_calendar_id')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'holiday_calendar_id', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'receivables')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'receivables', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'payables')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'payables', 0 )
END

IF NOT EXISTS(SELECT * FROM ixp_columns AS ic WHERE ic.ixp_table_id = @ixp_tables_id and ic.ixp_columns_name LIKE 'confirmation')
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major)
	VALUES
	(@ixp_tables_id,'confirmation', 0 )
END
