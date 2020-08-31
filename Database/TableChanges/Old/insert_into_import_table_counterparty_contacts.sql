IF NOT EXISTS (SELECT 1 FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_contacts') BEGIN INSERT INTO ixp_tables (ixp_tables_name, ixp_tables_description, import_export_flag) SELECT 'ixp_counterparty_contacts', 'Counterparty Contacts', 'i' END
   
--TABLE: ixp_counterparty_contacts 
     
DECLARE @temp_ixp_tables_id INT

SET @temp_ixp_tables_id = (SELECT it.ixp_tables_id FROM ixp_tables it WHERE it.ixp_tables_name = 'ixp_counterparty_contacts')
     
--COLUMN: counterparty_id
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'counterparty_id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'counterparty_id', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:counterparty_id ALREADY EXISTS.'
END
--COLUMN: contact_type
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'contact_type' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'contact_type', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:contact_type ALREADY EXISTS.'
END
--COLUMN: title
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'title' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'title', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:title ALREADY EXISTS.'
END
--COLUMN: name
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'name' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'name', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:name ALREADY EXISTS.'
END
--COLUMN: id
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'id' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'id', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:id ALREADY EXISTS.'
END
--COLUMN: address1
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'address1' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'address1', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:address1 ALREADY EXISTS.'
END
--COLUMN: address2
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'address2' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'address2', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:address2 ALREADY EXISTS.'
END
--COLUMN: city
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'city' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'city', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:city ALREADY EXISTS.'
END
--COLUMN: state
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'state' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'state', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:state ALREADY EXISTS.'
END
--COLUMN: zip
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'zip' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'zip', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:zip ALREADY EXISTS.'
END
--COLUMN: telephone
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'telephone' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'telephone', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:telephone ALREADY EXISTS.'
END
--COLUMN: fax
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'fax' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'fax', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:fax ALREADY EXISTS.'
END
--COLUMN: email
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'email' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'email', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:email ALREADY EXISTS.'
END
--COLUMN: country
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'country' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'country', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:country ALREADY EXISTS.'
END
--COLUMN: region
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'region' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'region', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:region ALREADY EXISTS.'
END
--COLUMN: comment
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'comment' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'comment', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:comment ALREADY EXISTS.'
END
--COLUMN: is_active
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'is_active' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'is_active', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:is_active ALREADY EXISTS.'
END
--COLUMN: is_primary
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'is_primary' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'is_primary', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:is_primary ALREADY EXISTS.'
END
--COLUMN: create_user
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'create_user' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'create_user', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:create_user ALREADY EXISTS.'
END
--COLUMN: create_ts
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'create_ts' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'create_ts', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:create_ts ALREADY EXISTS.'
END
--COLUMN: update_user
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'update_user' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'update_user', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:update_user ALREADY EXISTS.'
END
--COLUMN: update_ts
IF NOT EXISTS(SELECT 1 FROM ixp_columns WHERE ixp_columns_name = 'update_ts' AND ixp_table_id = @temp_ixp_tables_id)
BEGIN
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, column_datatype, is_major)
	VALUES (@temp_ixp_tables_id, 'update_ts', 'VARCHAR(500)', 0)
END
ELSE
BEGIN
	PRINT 'COLUMN:update_ts ALREADY EXISTS.'
END
