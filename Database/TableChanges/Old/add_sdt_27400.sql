IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 27400)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (27400, 'Counterparty Trader', 0, 'Counterparty Trader', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 27400 - Counterparty Trader.'
END
ELSE
BEGIN
	PRINT 'Static data type 27400 - Counterparty Trader already EXISTS.'
END


