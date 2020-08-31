IF COL_LENGTH('application_ui_template_fields', 'load_child_without_parent') IS NULL
BEGIN
    ALTER TABLE application_ui_template_fields ADD load_child_without_parent BIT
END
GO