IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 32800)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (32800, 'Counterparty Trigger', 0, 'Counterparty Trigger', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 32800 - Counterparty Trigger.'
END
ELSE
BEGIN
	PRINT 'Static data type 32800 - Counterparty Trigger already EXISTS.'
END