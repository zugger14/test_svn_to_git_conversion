IF COL_LENGTH('time_series_data', 'time_series_data_id') IS NULL
BEGIN
    ALTER TABLE time_series_data ADD time_series_data_id INT IDENTITY(1,1) 
END
GO
