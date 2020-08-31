IF COL_LENGTH('alert_sql', 'alert_type') IS NULL
BEGIN
    ALTER TABLE alert_sql ADD alert_type CHAR(1)
END
GO

UPDATE alert_sql SET alert_type = 's' WHERE alert_type IS NULL


IF COL_LENGTH('alert_table_where_clause', 'table_id') IS NULL
BEGIN
    ALTER TABLE alert_table_where_clause ADD table_id INT
END
GO