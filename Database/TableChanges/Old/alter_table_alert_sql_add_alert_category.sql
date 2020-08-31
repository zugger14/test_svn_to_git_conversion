IF COL_LENGTH('alert_sql', 'alert_category') IS NULL
BEGIN
    ALTER TABLE alert_sql ADD alert_category CHAR(1)
END
GO