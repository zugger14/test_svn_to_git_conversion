IF COL_LENGTH('application_ui_template_definition', 'open_ui_function_id') IS NULL
BEGIN
	ALTER TABLE application_ui_template_definition
	/**
	Columns 
	open_ui_function_id: UI function id to open
	*/
	ADD [open_ui_function_id] INT

	PRINT 'Column ''open_ui_function_id'' is added.'
END
ELSE
BEGIN
	PRINT 'Column ''open_ui_function_id'' already exists.'
END

GO