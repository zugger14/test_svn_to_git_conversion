SET IDENTITY_INSERT  source_book ON
IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_book_id = -1)
BEGIN
	INSERT INTO source_book (source_book_id, source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc, source_parent_book_id, source_parent_type)
	SELECT -1, 2, -1, 50, 'None', 'None', NULL, NULL
END
ELSE
BEGIN
	UPDATE source_book
	SET source_book_name = 'None',
	source_book_desc = 'None',
	source_system_book_id = -1
	WHERE source_book_id = -1
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_book_id = -2)
BEGIN
	INSERT INTO source_book (source_book_id, source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc, source_parent_book_id, source_parent_type)
	SELECT -2, 2, -2, 51, 'None', 'None', NULL, NULL
END
ELSE
BEGIN
	UPDATE source_book
	SET source_book_name = 'None',
	source_book_desc = 'None',
	source_system_book_id = -2
	WHERE source_book_id = -2
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_book_id = -3)
BEGIN
	INSERT INTO source_book (source_book_id, source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc, source_parent_book_id, source_parent_type)
	SELECT -3, 2, -3, 52, 'None', 'None', NULL, NULL
END
ELSE
BEGIN
	UPDATE source_book
	SET source_book_name = 'None',
	source_book_desc = 'None',
	source_system_book_id = -3
	WHERE source_book_id = -3
END

IF NOT EXISTS (SELECT 1 FROM source_book WHERE source_book_id = -4)
BEGIN
	INSERT INTO source_book (source_book_id, source_system_id, source_system_book_id, source_system_book_type_value_id, source_book_name, source_book_desc, source_parent_book_id, source_parent_type)
	SELECT -4, 2, -4, 53, 'None', 'None', NULL, NULL
END
ELSE
BEGIN
	UPDATE source_book
	SET source_book_name = 'None',
	source_book_desc = 'None',
	source_system_book_id = -4
	WHERE source_book_id = -4
END
SET IDENTITY_INSERT  source_book OFF
