IF EXISTS (SELECT 1 FROM time_zones WHERE timezone_id=36)
BEGIN
	UPDATE time_zones
	SET TIMEZONE_NAME = '(GMT +3:00) Turkey Time',
		TIMEZONE_NAME_FOR_PHP = 'Europe/Istanbul'
	WHERE TIMEZONE_ID = 36
END
