DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_source_counterparty_template'

-- Update Mandatory
UPDATE ic 
SET ic.is_required = 1 
FROM ixp_columns ic 
WHERE ixp_table_id = @ixp_table_id
       AND ic.ixp_columns_name IN (
	     'counterparty_id'
	)

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = 2 and ic.ixp_columns_name LIKE 'analyst') 
BEGIN 
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, seq, datatype, is_required) 
	VALUES (@ixp_table_id,'analyst', 0, 70, NULL, 0) 
END
 
IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = 2 and ic.ixp_columns_name LIKE 'counterparty_status') 
BEGIN 
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, seq, datatype, is_required) 
	VALUES (@ixp_table_id,'counterparty_status', 0, 80, NULL, 0) 
END 

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = 2 and ic.ixp_columns_name LIKE 'is_active') 
BEGIN 
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, seq, datatype, is_required) 
	VALUES (@ixp_table_id,'is_active', 0, 90, NULL, 0) 
END 

IF NOT EXISTS(SELECT 1 FROM ixp_columns AS ic WHERE ic.ixp_table_id = 2 and ic.ixp_columns_name LIKE 'counterparty_contact_notes') 
BEGIN 
	INSERT INTO ixp_columns (ixp_table_id, ixp_columns_name, is_major, seq, datatype, is_required) 
	VALUES (@ixp_table_id,'counterparty_contact_notes', 0, 100, NULL, 0) 
END 