IF COL_LENGTH('alert_output_status','event_trigger_id') IS NULL 
	ALTER TABLE alert_output_status ADD event_trigger_id INT
GO
	