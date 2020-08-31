IF EXISTS (SELECT 1 FROM time_zones WHERE timezone_id=14)
UPDATE time_zones SET DST_OFFSET_HR = 1 WHERE timezone_id = 14