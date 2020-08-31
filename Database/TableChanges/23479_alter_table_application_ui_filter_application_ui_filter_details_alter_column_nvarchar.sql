IF COL_LENGTH('application_ui_filter', 'application_ui_filter_name') IS NOT NULL
BEGIN
    ALTER TABLE application_ui_filter
	/**
	Columns 
	application_ui_filter_name: Filter name
	*/
	ALTER COLUMN application_ui_filter_name NVARCHAR(50)
END
GO

IF COL_LENGTH('application_ui_filter_details', 'field_value') IS NOT NULL
BEGIN
    ALTER TABLE application_ui_filter_details
	/**
	Columns 
	field_value: filter field value
	*/
	ALTER COLUMN field_value NVARCHAR(MAX)
END
GO