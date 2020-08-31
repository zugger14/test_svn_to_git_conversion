IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'forward_value_report' AND COLUMN_NAME = 'qtr')
BEGIN
	ALTER TABLE forward_value_report alter column  qtr datetime
END
GO
IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'forward_value_report' AND COLUMN_NAME = 'qtr')
BEGIN
	ALTER TABLE forward_value_report alter column  qtr date
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'forward_value_report' AND COLUMN_NAME = 'source_system_book_id1')
BEGIN
	ALTER TABLE forward_value_report ADD source_system_book_id1 INT
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'forward_value_report' AND COLUMN_NAME = 'source_system_book_id2')
BEGIN
	ALTER TABLE forward_value_report ADD source_system_book_id2 INT
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'forward_value_report' AND COLUMN_NAME = 'source_system_book_id3')
BEGIN
	ALTER TABLE forward_value_report ADD source_system_book_id3 INT
END

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'forward_value_report' AND COLUMN_NAME = 'source_system_book_id4')
BEGIN
	ALTER TABLE forward_value_report ADD source_system_book_id4 INT
END
