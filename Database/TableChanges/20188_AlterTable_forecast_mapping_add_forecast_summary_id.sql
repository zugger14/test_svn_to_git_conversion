IF COL_LENGTH('forecast_result', 'forecast_summary_id') IS NULL
BEGIN
    ALTER TABLE forecast_result ADD forecast_summary_id INT REFERENCES forecast_result_summary(forecast_result_summary_id) NOT NULL
END
GO
