SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[application_ui_layout_grid_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[application_ui_layout_grid_audit]
	(
		application_ui_layout_grid_audit_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		application_ui_template_audit_id INT FOREIGN KEY REFERENCES application_ui_template_audit(application_ui_template_audit_id),
		application_ui_layout_grid_id INT,
		group_id INT NOT NULL,
		layout_cell VARCHAR(10) NULL,
		grid_id VARCHAR(100) NULL,
		sequence INT NULL,
		num_column INT,
		cell_height INT NULL,
		grid_object_name VARCHAR(200),
		grid_object_unique_column VARCHAR(200)
	)
END
ELSE 
BEGIN
	PRINT 'Table application_ui_layout_grid_audit EXISTS'
END