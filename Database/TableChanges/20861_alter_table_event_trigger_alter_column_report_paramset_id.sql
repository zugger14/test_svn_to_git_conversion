IF COL_LENGTH('event_trigger', 'report_paramset_id') IS NOT NULL
BEGIN
    ALTER TABLE event_trigger 
    ALTER COLUMN report_paramset_id VARCHAR(MAX)
END
GO