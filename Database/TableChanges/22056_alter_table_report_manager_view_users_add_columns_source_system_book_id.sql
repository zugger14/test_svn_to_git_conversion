IF COL_LENGTH('report_manager_view_users', 'source_system_book_id1') IS NULL
BEGIN
	ALTER TABLE report_manager_view_users ADD source_system_book_id1 VARCHAR(MAX)
	PRINT 'Column source_system_book_id1 is added.'
END
ELSE
BEGIN
	PRINT 'Column source_system_book_id1 already exists.'
END

IF COL_LENGTH('report_manager_view_users', 'source_system_book_id2') IS NULL
BEGIN
	ALTER TABLE report_manager_view_users ADD source_system_book_id2 VARCHAR(MAX)
	PRINT 'Column source_system_book_id2 is added.'
END
ELSE
BEGIN
	PRINT 'Column source_system_book_id2 already exists.'
END

IF COL_LENGTH('report_manager_view_users', 'source_system_book_id3') IS NULL
BEGIN
	ALTER TABLE report_manager_view_users ADD source_system_book_id3 VARCHAR(MAX)
	PRINT 'Column source_system_book_id3 is added.'
END
ELSE
BEGIN
	PRINT 'Column source_system_book_id3 already exists.'
END

IF COL_LENGTH('report_manager_view_users', 'source_system_book_id4') IS NULL
BEGIN
	ALTER TABLE report_manager_view_users ADD source_system_book_id4 VARCHAR(MAX)
	PRINT 'Column source_system_book_id4 is added.'
END
ELSE
BEGIN
	PRINT 'Column source_system_book_id4 already exists.'
END