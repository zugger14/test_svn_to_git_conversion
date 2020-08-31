IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 40400)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (40400, 'Buyer/Seller Option', 1, 'Buyer/Seller Option', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 40400 - Buyer/Seller Option.'
END
ELSE
BEGIN
	PRINT 'Static data type 40400 - Buyer/Seller Option already EXISTS.'
END