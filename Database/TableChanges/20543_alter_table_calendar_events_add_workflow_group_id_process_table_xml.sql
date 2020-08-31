IF COL_LENGTH('calendar_events', 'workflow_group_id') IS NULL
BEGIN
    ALTER TABLE calendar_events ADD workflow_group_id INT
END
GO

IF COL_LENGTH('calendar_events', 'process_table_xml') IS NULL
BEGIN
    ALTER TABLE calendar_events ADD process_table_xml VARCHAR(1000)
END
GO

IF COL_LENGTH('calendar_events', 'process_table_xml') IS NOT NULL
BEGIN
    ALTER TABLE calendar_events ALTER COLUMN process_table_xml VARCHAR(1000)
END
GO

IF COL_LENGTH('calendar_events', 'source_id') IS NULL
BEGIN
    ALTER TABLE calendar_events ADD source_id INT
END
GO