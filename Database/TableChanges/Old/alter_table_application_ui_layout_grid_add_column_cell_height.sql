IF NOT EXISTS (SELECT 1 FROM sys.[columns] AS c WHERE c.name=N'cell_height' AND OBJECT_ID=OBJECT_ID(N'application_ui_layout_grid'))
BEGIN
	ALTER TABLE application_ui_layout_grid ADD cell_height INT NULL
END
ELSE
	BEGIN
		PRINT 'cell_height column already exists.'
	END
	
