/*********************
ALter table rec_generator
******************/
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'rec_generator' and column_name = 'location_id')
	ALTER TABLE [dbo].rec_generator ADD location_id INT NULL
