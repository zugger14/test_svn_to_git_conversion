IF COL_LENGTH('application_ui_template_definition', 'is_unique') IS NOT NULL
BEGIN
   EXEC SP_RENAME 'application_ui_template_definition.[is_unique]' , 'is_identity', 'COLUMN'
END
GO

