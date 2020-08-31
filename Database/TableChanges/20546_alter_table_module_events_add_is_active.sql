IF COL_LENGTH('module_events', 'is_active') IS NULL
BEGIN
    ALTER TABLE module_events ADD is_active CHAR(1)
END
GO