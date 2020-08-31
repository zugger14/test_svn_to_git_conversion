IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19100)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19100, 'Counterparty Dynamic Limit Type', 1, 'Counterparty Dynamic Limit Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19100 - Counterparty Dynamic Limit Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 19100 - Counterparty Dynamic Limit Type already EXISTS.'
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19101)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19101, 19100, '20227', '20227', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19101 - 20227.'
END
ELSE
BEGIN
	PRINT 'Static data value 19101 - 20227 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
