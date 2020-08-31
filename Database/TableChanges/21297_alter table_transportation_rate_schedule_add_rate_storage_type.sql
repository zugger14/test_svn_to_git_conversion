IF COL_LENGTH('transportation_rate_schedule', 'rate_schedule_type') IS NULL
BEGIN
    ALTER TABLE transportation_rate_schedule ADD rate_schedule_type CHAR(1)
END
GO