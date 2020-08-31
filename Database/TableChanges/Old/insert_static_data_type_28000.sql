IF NOT EXISTS (SELECT 1 FROM static_data_type AS sdt WHERE sdt.[type_id] = 28000)
BEGIN
	INSERT INTO static_data_type
	(
		[type_id],
		[type_name],
		internal,
		[description]
	)
	VALUES
	(
		28000,
		'Compliance Group',
		0,
		'Compliance Group'
	)
END
ELSE
	BEGIN
		PRINT 'Compliance Group already exists.'
	END