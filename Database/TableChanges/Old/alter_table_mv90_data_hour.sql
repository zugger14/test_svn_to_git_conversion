IF COL_LENGTH('mv90_data_hour', 'Hr25') IS NULL
BEGIN
	ALTER TABLE mv90_data_hour ADD Hr25 FLOAT
	PRINT 'Column mv90_data_hour.Hr25 added.'
END
ELSE
BEGIN
	PRINT 'Column mv90_data_hour.Hr25 already exists.'
END
GO 

