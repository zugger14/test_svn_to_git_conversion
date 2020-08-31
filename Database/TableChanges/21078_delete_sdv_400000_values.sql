-- removed static values that are not pre-exists under 40000 for weather data
IF EXISTS(SELECT 1 FROM static_data_value WHERE type_id = 40000 AND code IN ('source_curve_def_id','source_counterparty_id','meter_id','value_id'))
BEGIN
	DELETE FROM static_data_value where type_id = 40000 AND code IN ('source_curve_def_id','source_counterparty_id','meter_id','value_id')
END
GO