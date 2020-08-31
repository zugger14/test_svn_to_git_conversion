/*
ALTER TABLE TO ADD COLUMN Derate Mw and Derate Percent
DATE: 2015-11-4
sabin@pioneersolutionsglobal.com
*/
IF COL_LENGTH(N'power_outage', 'derate_mw') IS NULL
BEGIN
	ALTER TABLE power_outage ADD derate_mw INT  
	PRINT 'Column added.'
END
ELSE
	PRINT 'Column already exists.'

IF COL_LENGTH(N'power_outage', 'derate_percent') IS NULL
BEGIN
	ALTER TABLE power_outage ADD derate_percent float  
	PRINT 'Column added.'
END
ELSE
	PRINT 'Column already exists.'
	
IF COL_LENGTH(N'power_outage', 'type_name') IS NULL
BEGIN
	ALTER TABLE power_outage ADD [type_name] varchar  
	PRINT 'Column added.'
END
ELSE
	PRINT 'Column already exists.'