IF COL_LENGTH('module_events', 'rule_table_id') IS NULL
BEGIN
    ALTER TABLE module_events ADD rule_table_id INT
END
GO

