IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[close_measurement_books]') AND name = N'indx_close_measurement_books')
BEGIN
	DROP INDEX close_measurement_books.indx_close_measurement_books
	PRINT 'Index indx_close_measurement_books has been dropped successfully.'
END
ELSE
	PRINT 'Index indx_close_measurement_books does not exists.'

IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[close_measurement_books]') AND name = N'IX_close_measurement_books')
BEGIN
	ALTER TABLE close_measurement_books DROP CONSTRAINT IX_close_measurement_books
	PRINT 'Constraint IX_close_measurement_books has been dropped successfully.'
END
ELSE
	PRINT 'Constraint IX_close_measurement_books  does not exists.'

IF NOT EXISTS(SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[close_measurement_books]') AND name = N'UQ_close_measurement_books')
BEGIN
	ALTER TABLE close_measurement_books
	ADD CONSTRAINT UQ_close_measurement_books
	UNIQUE (as_of_date, sub_id, archive_type_id)

	PRINT 'Constraint UQ_close_measurement_books has been added successfully.'
END
ELSE
	PRINT 'Constraint UQ_close_measurement_books already exists.'