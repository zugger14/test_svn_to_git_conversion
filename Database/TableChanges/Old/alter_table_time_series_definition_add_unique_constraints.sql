
IF EXISTS (SELECT name FROM sys.indexes
            WHERE name = N'IX_unique_time_series_data_index') 
BEGIN
	ALTER TABLE time_series_data DROP CONSTRAINT IX_unique_time_series_data_index
END	 
GO

ALTER TABLE time_series_data
ADD CONSTRAINT IX_unique_time_series_data_index UNIQUE (time_series_definition_id, effective_date, maturity, is_dst, curve_source_value_id,time_series_group)
