/***************
Alter Table Power_outage
**************/
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'Power_outage' and column_name = 'outage')
	ALTER TABLE Power_outage add outage FLOAT
