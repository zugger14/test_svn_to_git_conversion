IF COL_LENGTH('alert_columns_definition', 'column_alias') IS NULL
BEGIN
    ALTER TABLE alert_columns_definition ADD column_alias VARCHAR(200)
END
GO

