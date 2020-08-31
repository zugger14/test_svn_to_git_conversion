IF COL_LENGTH('variable_charge', 'rate_schedule_type') IS NULL
BEGIN
    ALTER TABLE variable_charge ADD rate_schedule_type CHAR(1)
END
GO