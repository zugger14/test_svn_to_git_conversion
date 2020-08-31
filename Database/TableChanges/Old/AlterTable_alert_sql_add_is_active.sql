IF COL_LENGTH('alert_sql', 'is_active') IS NULL
BEGIN
    ALTER TABLE alert_sql ADD is_active CHAR(1)   
END
GO
UPDATE alert_sql SET is_active = 'y' WHERE is_active IS NULL
GO
