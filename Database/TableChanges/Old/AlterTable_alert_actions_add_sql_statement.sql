IF COL_LENGTH('alert_actions', 'sql_statement') IS NULL
BEGIN
    ALTER TABLE alert_actions ADD sql_statement VARCHAR(MAX)
END
GO

ALTER TABLE alert_actions ALTER COLUMN table_id INT NULL
ALTER TABLE alert_actions ALTER COLUMN column_id INT NULL