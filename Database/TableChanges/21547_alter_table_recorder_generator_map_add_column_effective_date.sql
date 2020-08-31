--effective_date
IF COL_LENGTH('recorder_generator_map', 'effective_date') IS NULL
	ALTER TABLE recorder_generator_map ADD effective_date DATE
ELSE
	PRINT 'Column effective_date already Exists.'