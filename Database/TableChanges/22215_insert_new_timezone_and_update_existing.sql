IF NOT EXISTS(SELECT 1 FROM time_zones WHERE TIMEZONE_NAME = '(GMT +3:00) Eastern European Time')
BEGIN
	INSERT INTO time_zones(TIMEZONE_NAME,OFFSET_HR,OFFSET_MI,DST_OFFSET_HR,DST_OFFSET_MI,DST_EFF_DT,DST_END_DT,EFF_DT,END_DT,TIMEZONE_NAME_FOR_PHP,apply_dst,dst_group_value_id,weekend_first_day,weekend_second_day)
	SELECT '(GMT +3:00) Eastern European Time',2,0,3,0,'03L10200','10L10300','2000-01-01 00:00:00.000','9999-12-31 00:00:00.000','Europe/Helsinki','y',102201,NULL,NULL
END

UPDATE time_zones
	SET DST_EFF_DT = '03L10200',
		DST_END_DT = '10L10300'
WHERE TIMEZONE_NAME = '(GMT +1:00 hour) Brussels, Copenhagen, Madrid, Paris'
