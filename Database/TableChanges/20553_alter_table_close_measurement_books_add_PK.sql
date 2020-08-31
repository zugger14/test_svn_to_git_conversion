IF COL_LENGTH('dbo.close_measurement_books', 'close_measurement_books_id') IS NULL
BEGIN
	ALTER TABLE dbo.close_measurement_books
	ADD close_measurement_books_id INT IDENTITY

	ALTER TABLE dbo.close_measurement_books
	ADD CONSTRAINT PK_close_measurement_books
	PRIMARY KEY(close_measurement_books_id)
END
GO