IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 43200)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts, is_active)
	VALUES (43200, 'Commodity Attribute', 0, 'Commodity Attribute', 'farrms_admin', GETDATE(), 1)
	PRINT 'Inserted static data type 43200 - Commodity Attribute.'
END
ELSE
BEGIN
	PRINT 'Static data type 43200 - Commodity Attribute already EXISTS.'
END