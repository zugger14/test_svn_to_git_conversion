IF NOT EXISTS (SELECT 1 FROM static_data_type WHERE [type_name] = 'Deal Detail Status')
BEGIN
	INSERT INTO static_data_type
	(	[type_id],
		[type_name],
		internal,
		[description]
	)
	VALUES
	(	25000,
		'Deal Detail Status',
		0,
		'Deal Detail Status'
	)
END

--SELECT * FROM static_data_type sdt 
--WHERE sdt.internal = 0 
--AND 
--sdt.[description] LIKE '%Deal Detail Status%'
--ORDER  BY sdt.[type_id] DESC

