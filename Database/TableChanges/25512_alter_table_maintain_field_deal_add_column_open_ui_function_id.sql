IF COL_LENGTH('maintain_field_deal', 'open_ui_function_id') IS NULL
BEGIN
	ALTER TABLE maintain_field_deal
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