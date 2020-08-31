IF COL_LENGTH('time_zones', 'weekend_first_day') IS NULL
BEGIN
    ALTER TABLE time_zones ADD weekend_first_day tinyint;
END


IF COL_LENGTH('time_zones', 'weekend_second_day') IS NULL
BEGIN
	ALTER TABLE time_zones ADD weekend_second_day tinyint;
END