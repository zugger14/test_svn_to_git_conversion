SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[application_ui_layout_grid]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[application_ui_layout_grid]
	(
		application_ui_layout_grid_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		group_id INT NOT NULL FOREIGN KEY REFERENCES application_ui_template_group(application_group_id) ,
		layout_cell VARCHAR(10) NULL,
		grid_id VARCHAR(100) NULL,
		sequence INT NULL 
	)
END
ELSE 
BEGIN
	PRINT 'Table application_ui_layout_grid EXISTS'
END

