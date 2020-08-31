--update
----- Pacific Time to Pacific Prevailing Time dst(y)
--- Mountain Time to Mountain Standard Time dst(n)
--- Central Time to Central Standard Time dst(n)
--- Eastern Time to Eastern Prevailing Time dst(y)

IF COL_LENGTH('TIME_ZONES', 'TIMEZONE_NAME') IS NOT NULL
BEGIN
    ALTER TABLE [TIME_ZONES] ALTER COLUMN TIMEZONE_NAME VARCHAR(500)
END
GO


UPDATE [TIME_ZONES]
SET TIMEZONE_NAME =  '(GMT -8:00) Pacific Prevailing Time (US & Canada)' 
WHERE TIMEZONE_NAME = '(GMT -8:00) Pacific Time (US & Canada)'

UPDATE [TIME_ZONES]
SET TIMEZONE_NAME =  '(GMT -7:00) Mountain Standard Time (US & Canada)' 
WHERE TIMEZONE_NAME = '(GMT -7:00) Mountain Time (US & Canada)'

UPDATE [TIME_ZONES]
SET TIMEZONE_NAME =  '(GMT -6:00) Central Standard Time (US & Canada), Mexico City' 
WHERE TIMEZONE_NAME = '(GMT -6:00) Central Time (US & Canada), Mexico City'

UPDATE [TIME_ZONES]
SET TIMEZONE_NAME =  '(GMT -5:00) Eastern Prevailing Time (US & Canada), Bogota, Lima' 
	, apply_dst = 'y'
WHERE TIMEZONE_NAME = '(GMT -5:00) Eastern Time (US & Canada), Bogota, Lima'



--add
--- Pacific Time to Pacific Standard Time dst(n)
--- Mountain Time to Mountain Prevailing Time dst(y)
--- Central Time to Central Prevailing Time dst(y)
--- Eastern Time to Eastern Standard Time dst(n)
IF NOT EXISTS (SELECT 1 FROM time_zones tz WHERE tz.TIMEZONE_NAME = '(GMT -8:00) Pacific Standard Time (US & Canada)')
BEGIN
	INSERT INTO time_zones (TIMEZONE_NAME, OFFSET_HR, OFFSET_MI, DST_OFFSET_HR,	DST_OFFSET_MI, DST_EFF_DT, DST_END_DT, EFF_DT, END_DT, TIMEZONE_NAME_FOR_PHP, apply_dst)
	VALUES('(GMT -8:00) Pacific Standard Time (US & Canada)', -8, 0, -7, 0, 03210200, 11110200, '2000-01-01 00:00:00.000', '9999-12-31 00:00:00.000', 'America/Los_Angeles', 'n')
END

IF NOT EXISTS (SELECT 1 FROM time_zones tz WHERE tz.TIMEZONE_NAME = '(GMT -7:00) Mountain Prevailing Time (US & Canada)')
BEGIN
	INSERT INTO time_zones (TIMEZONE_NAME, OFFSET_HR, OFFSET_MI, DST_OFFSET_HR,	DST_OFFSET_MI, DST_EFF_DT, DST_END_DT, EFF_DT, END_DT, TIMEZONE_NAME_FOR_PHP, apply_dst)
	VALUES('(GMT -7:00) Mountain Prevailing Time (US & Canada)', -7, 0, -6, 0, 03210200, 11110200, '2000-01-01 00:00:00.000', '9999-12-31 00:00:00.000', 'America/Denver', 'y')
END

IF NOT EXISTS (SELECT 1 FROM time_zones tz WHERE tz.TIMEZONE_NAME = '(GMT -6:00) Central Prevailing Time (US & Canada), Mexico City')
BEGIN
	INSERT INTO time_zones (TIMEZONE_NAME, OFFSET_HR, OFFSET_MI, DST_OFFSET_HR,	DST_OFFSET_MI, DST_EFF_DT, DST_END_DT, EFF_DT, END_DT, TIMEZONE_NAME_FOR_PHP, apply_dst)
	VALUES('(GMT -6:00) Central Prevailing Time (US & Canada), Mexico City', -6, 0, -5, 0, 03210200, 11110200, '2000-01-01 00:00:00.000', '9999-12-31 00:00:00.000', 'America/Chicago', 'y')
END

IF NOT EXISTS (SELECT 1 FROM time_zones tz WHERE tz.TIMEZONE_NAME = '(GMT -5:00) Eastern Standard Time (US & Canada), Bogota, Lima')
BEGIN
	INSERT INTO time_zones (TIMEZONE_NAME, OFFSET_HR, OFFSET_MI, DST_OFFSET_HR,	DST_OFFSET_MI, DST_EFF_DT, DST_END_DT, EFF_DT, END_DT, TIMEZONE_NAME_FOR_PHP, apply_dst)
	VALUES('(GMT -5:00) Eastern Standard Time (US & Canada), Bogota, Lima', -5, 0, -4, 0, 03210200, 11110200, '2000-01-01 00:00:00.000', '9999-12-31 00:00:00.000', 'America/New_York', 'n')
END

/*
SELECT * FROM [TIME_ZONES]
WHERE TIMEZONE_NAME LIKE '%Pacific %'
OR TIMEZONE_NAME LIKE '%Mountain %'
OR TIMEZONE_NAME LIKE '%Central %'
OR TIMEZONE_NAME LIKE '%Eastern %'
ORDER BY TIMEZONE_NAME


UPDATE [TIME_ZONES]
SET TIMEZONE_NAME = '(GMT -8:00) Pacific Prevailing Time (US & Canada)'
WHERE TIMEZONE_NAME =  '(GMT -8:00) Pacific Prevailing Time dst(y) (US & Canada)' 

UPDATE [TIME_ZONES]
SET TIMEZONE_NAME =  '(GMT -7:00) Mountain Standard Time (US & Canada)' 
WHERE TIMEZONE_NAME = '(GMT -7:00) Mountain Standard Time dst(n) (US & Canada)'

UPDATE [TIME_ZONES]
SET TIMEZONE_NAME =  '(GMT -6:00) Central Standard Time (US & Canada), Mexico City' 
WHERE TIMEZONE_NAME = '(GMT -6:00) Central Standard Time dst(n) (US & Canada), Mexico City'

UPDATE [TIME_ZONES]
SET TIMEZONE_NAME =  '(GMT -5:00) Eastern Prevailing Time (US & Canada), Bogota, Lima' 
, apply_dst = 'y'
WHERE TIMEZONE_NAME = '(GMT -5:00) Eastern Prevailing Time (US & Canada), Bogota, Lima'


*/

