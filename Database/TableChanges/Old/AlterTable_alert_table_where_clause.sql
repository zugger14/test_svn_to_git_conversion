IF COL_LENGTH('alert_table_where_clause', 'column_function') IS NULL
BEGIN
    ALTER TABLE alert_table_where_clause ADD column_function VARCHAR(1000)
END
GO

IF COL_LENGTH('alert_table_where_clause', 'condition_id') IS NULL
BEGIN
    ALTER TABLE alert_table_where_clause ADD condition_id INT,
    CONSTRAINT [FK_alert_conditions_alert_table_where_clause] FOREIGN KEY ([condition_id]) REFERENCES [alert_conditions];
END
GO
