IF COL_LENGTH('source_deal_header_template', 'holiday_calendar') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD holiday_calendar INT
END
GO

IF COL_LENGTH('source_deal_header', 'holiday_calendar') IS NULL
BEGIN
    ALTER TABLE source_deal_header ADD holiday_calendar INT REFERENCES static_data_value(value_id)
END
GO

IF COL_LENGTH('delete_source_deal_header', 'holiday_calendar') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_header ADD holiday_calendar INT
END
GO

IF COL_LENGTH('source_deal_header_audit', 'holiday_calendar') IS NULL
BEGIN
    ALTER TABLE source_deal_header_audit ADD holiday_calendar INT
END
GO