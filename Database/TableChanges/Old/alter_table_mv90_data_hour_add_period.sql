IF COL_LENGTH('mv90_data_hour','period') IS NULL 
	ALTER TABLE mv90_data_hour add period int
	
