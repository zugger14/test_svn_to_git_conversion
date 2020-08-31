IF COL_LENGTH('alert_table_where_clause', 'sequence_no') IS NULL
BEGIN
    ALTER TABLE alert_table_where_clause ADD sequence_no INT
END
GO