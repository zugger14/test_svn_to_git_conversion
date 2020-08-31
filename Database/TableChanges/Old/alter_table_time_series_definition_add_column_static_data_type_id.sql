IF COL_LENGTH('time_series_definition', 'static_data_type_id') IS NULL
BEGIN
    ALTER TABLE time_series_definition ADD static_data_type_id INT 
END
GO