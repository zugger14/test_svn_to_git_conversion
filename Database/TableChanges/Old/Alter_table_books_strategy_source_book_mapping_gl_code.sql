IF COL_LENGTH('fas_books', 'gl_number_unhedged_der_st_asset') IS NULL
BEGIN
	ALTER TABLE fas_books ADD gl_number_unhedged_der_st_asset INT
	PRINT 'Column fas_books.gl_number_unhedged_der_st_asset added.'
END
ELSE
BEGIN
	PRINT 'Column fas_books.gl_number_unhedged_der_st_asset already exists.'
END
GO

IF COL_LENGTH('fas_books', 'gl_number_unhedged_der_lt_asset') IS NULL
BEGIN
	ALTER TABLE fas_books ADD gl_number_unhedged_der_lt_asset INT
	PRINT 'Column fas_books.gl_number_unhedged_der_lt_asset added.'
END
ELSE
BEGIN
	PRINT 'Column fas_books.gl_number_unhedged_der_lt_asset already exists.'
END
GO

IF COL_LENGTH('fas_books', 'gl_number_unhedged_der_st_liab') IS NULL
BEGIN
	ALTER TABLE fas_books ADD gl_number_unhedged_der_st_liab INT
	PRINT 'Column fas_books.gl_number_unhedged_der_st_liab added.'
END
ELSE
BEGIN
	PRINT 'Column fas_books.gl_number_unhedged_der_st_liab already exists.'
END
GO

IF COL_LENGTH('fas_books', 'gl_number_unhedged_der_lt_liab') IS NULL
BEGIN
	ALTER TABLE fas_books ADD gl_number_unhedged_der_lt_liab INT
	PRINT 'Column fas_books.gl_number_unhedged_der_lt_liab added.'
END
ELSE
BEGIN
	PRINT 'Column fas_books.gl_number_unhedged_der_lt_liab already exists.'
END
GO

IF COL_LENGTH('fas_strategy', 'gl_number_unhedged_der_st_asset') IS NULL
BEGIN
	ALTER TABLE fas_strategy ADD gl_number_unhedged_der_st_asset INT
	PRINT 'Column fas_strategy.gl_number_unhedged_der_st_asset added.'
END
ELSE
BEGIN
	PRINT 'Column fas_strategy.gl_number_unhedged_der_st_asset already exists.'
END
GO

IF COL_LENGTH('fas_strategy', 'gl_number_unhedged_der_lt_asset') IS NULL
BEGIN
	ALTER TABLE fas_strategy ADD gl_number_unhedged_der_lt_asset INT
	PRINT 'Column fas_strategy.gl_number_unhedged_der_lt_asset added.'
END
ELSE
BEGIN
	PRINT 'Column fas_strategy.gl_number_unhedged_der_lt_asset already exists.'
END
GO

IF COL_LENGTH('fas_strategy', 'gl_number_unhedged_der_st_liab') IS NULL
BEGIN
	ALTER TABLE fas_strategy ADD gl_number_unhedged_der_st_liab INT
	PRINT 'Column fas_strategy.gl_number_unhedged_der_st_liab added.'
END
ELSE
BEGIN
	PRINT 'Column fas_strategy.gl_number_unhedged_der_st_liab already exists.'
END
GO

IF COL_LENGTH('fas_strategy', 'gl_number_unhedged_der_lt_liab') IS NULL
BEGIN
	ALTER TABLE fas_strategy ADD gl_number_unhedged_der_lt_liab INT
	PRINT 'Column fas_strategy.gl_number_unhedged_der_lt_liab added.'
END
ELSE
BEGIN
	PRINT 'Column fas_strategy.gl_number_unhedged_der_lt_liab already exists.'
END
GO

IF COL_LENGTH('source_book_map_GL_codes', 'gl_number_unhedged_der_st_asset') IS NULL
BEGIN
	ALTER TABLE source_book_map_GL_codes ADD gl_number_unhedged_der_st_asset INT
	PRINT 'Column source_book_map_GL_codes.gl_number_unhedged_der_st_asset added.'
END
ELSE
BEGIN
	PRINT 'Column source_book_map_GL_codes.gl_number_unhedged_der_st_asset already exists.'
END
GO

IF COL_LENGTH('source_book_map_GL_codes', 'gl_number_unhedged_der_lt_asset') IS NULL
BEGIN
	ALTER TABLE source_book_map_GL_codes ADD gl_number_unhedged_der_lt_asset INT
	PRINT 'Column source_book_map_GL_codes.gl_number_unhedged_der_lt_asset added.'
END
ELSE
BEGIN
	PRINT 'Column source_book_map_GL_codes.gl_number_unhedged_der_lt_asset already exists.'
END
GO

IF COL_LENGTH('source_book_map_GL_codes', 'gl_number_unhedged_der_st_liab') IS NULL
BEGIN
	ALTER TABLE source_book_map_GL_codes ADD gl_number_unhedged_der_st_liab INT
	PRINT 'Column source_book_map_GL_codes.gl_number_unhedged_der_st_liab added.'
END
ELSE
BEGIN
	PRINT 'Column source_book_map_GL_codes.gl_number_unhedged_der_st_liab already exists.'
END
GO

IF COL_LENGTH('source_book_map_GL_codes', 'gl_number_unhedged_der_lt_liab') IS NULL
BEGIN
	ALTER TABLE source_book_map_GL_codes ADD gl_number_unhedged_der_lt_liab INT
	PRINT 'Column source_book_map_GL_codes.gl_number_unhedged_der_lt_liab added.'
END
ELSE
BEGIN
	PRINT 'Column source_book_map_GL_codes.gl_number_unhedged_der_lt_liab already exists.'
END
GO