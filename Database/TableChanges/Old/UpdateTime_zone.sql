/*select * from time_zones
update time zone
*/
update time_zones set OFFSET_MI=45 where timezone_id=23
update time_zones set OFFSET_MI=30 where timezone_id=22
update time_zones set DST_OFFSET_HR=OFFSET_HR,DST_OFFSET_MI=OFFSET_MI

update time_zones set DST_OFFSET_HR=OFFSET_HR+1 where timezone_id in(5,6,7,8)

update time_zones set eff_dt='2000-01-01'

--(GMT-12:00) International Date Line West ----Kwajalein
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Etc/GMT+12' WHERE TIMEZONE_ID=1
--(GMT-11:00) Midway Island 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Pacific/Midway' WHERE TIMEZONE_ID=2
--(GMT-10:00) Hawaii 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Pacific/Honolulu' WHERE TIMEZONE_ID=3
--(GMT-09:00) Alaska 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='America/Anchorage' WHERE TIMEZONE_ID=4
--(GMT-08:00) Pacific Time (US & Canada) 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='America/Los_Angeles' WHERE TIMEZONE_ID=5
--(GMT-07:00) Mountain Time (US & Canada) 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='America/Denver' WHERE TIMEZONE_ID=6
--(GMT-06:00) Central Time (US & Canada) 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='America/Chicago' WHERE TIMEZONE_ID=7
--(GMT-05:00) Eastern Time (US & Canada) 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='America/New_York' WHERE TIMEZONE_ID=8
--(GMT-04:00) Atlantic Time (Canada) 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='America/Halifax' WHERE TIMEZONE_ID=9
--(GMT-03:00) Georgetown 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='America/Argentina/Buenos_Aires' WHERE TIMEZONE_ID=10
--(GMT-03:30) Newfoundland 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='America/St_Johns' WHERE TIMEZONE_ID=11
--(GMT-02:00) Mid-Atlantic 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Atlantic/South_Georgia' WHERE TIMEZONE_ID=12
--(GMT-01:00) Cape Verde Is. 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Atlantic/Cape_Verde' WHERE TIMEZONE_ID=13
--(GMT) London 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Europe/London' WHERE TIMEZONE_ID=14
--(GMT+01:00) Madrid 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Europe/Madrid' WHERE TIMEZONE_ID=15
--(GMT+02:00) Cairo 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Africa/Cairo' WHERE TIMEZONE_ID=16
--(GMT+03:00) Riyadh 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Asia/Riyadh' WHERE TIMEZONE_ID=17
--(GMT+03:30) Tehran 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Asia/Tehran' WHERE TIMEZONE_ID=18
--(GMT+04:00) Muscat 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Asia/Muscat' WHERE TIMEZONE_ID=19
--(GMT+04:30) Kabul 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Asia/Kabul' WHERE TIMEZONE_ID=20
--(GMT+05:00) Tashkent 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Asia/Tashkent' WHERE TIMEZONE_ID=21
--(GMT+05:30) Calcutta 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Asia/Kolkata' WHERE TIMEZONE_ID=22
--(GMT+05:45) Kathmandu 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Asia/Katmandu' WHERE TIMEZONE_ID=23
--(GMT+06:00) Dhaka 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Asia/Dhaka' WHERE TIMEZONE_ID=24
--(GMT+07:00) Bangkok 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Asia/Bangkok' WHERE TIMEZONE_ID=25
--(GMT+08:00) Beijing 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Asia/Brunei' WHERE TIMEZONE_ID=26
--(GMT+09:00) Tokyo 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Asia/Tokyo' WHERE TIMEZONE_ID=27
--(GMT+09:30) Darwin 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Australia/Darwin' WHERE TIMEZONE_ID=28
--(GMT+10:00) Vladivostok 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Asia/Vladivostok' WHERE TIMEZONE_ID=29
--(GMT+11:00) Magadan 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Asia/Magadan' WHERE TIMEZONE_ID=30
--(GMT+12:00) Fiji 
UPDATE time_zones SET TIMEZONE_NAME_FOR_PHP ='Pacific/Fiji' WHERE TIMEZONE_ID=31

----Added by Monish Manandhar---
IF EXISTS(SELECT 'x' FROM time_zones  WHERE TIMEZONE_ID = 15)
UPDATE time_zones SET DST_OFFSET_HR = 2 WHERE TIMEZONE_ID = 15
