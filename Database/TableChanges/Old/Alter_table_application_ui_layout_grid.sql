IF COL_LENGTH('application_ui_layout_grid', 'num_column') IS NULL
BEGIN
    ALTER TABLE application_ui_layout_grid ADD num_column INT
END
GO


