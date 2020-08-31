/*
* insert static data type 'Counterparty Debt Rating' (23000) used for 'Credit Value Adjustment' on At risk module.
* 2013/04/01
* sligal 
*/
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 23000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (23000, 'Counterparty Debt Rating', 1, 'Counterparty Debt Rating', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 23000 - Counterparty Debt Rating.'
END
ELSE
BEGIN
	PRINT 'Static data type 23000 - Counterparty Debt Rating already EXISTS.'
END
