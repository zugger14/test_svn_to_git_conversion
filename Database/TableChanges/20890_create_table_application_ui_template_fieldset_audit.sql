SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[application_ui_template_fieldsets_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[application_ui_template_fieldsets_audit]
	(
		application_ui_template_fieldset_audit_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		application_ui_template_audit_id INT FOREIGN KEY REFERENCES application_ui_template_audit(application_ui_template_audit_id),
		application_fieldset_id  INT,
		application_group_id  INT NOT NULL,
		fieldset_name VARCHAR(50) NULL,
		className VARCHAR(50) NULL, 
		is_disable CHAR(1) NULL,
		is_hidden CHAR(1) NULL,
		inputLeft INT NULL,
		inputTop INT NULL,
		label VARCHAR(100) NULL,
		offsetLeft INT NULL,
		offsetTop INT NULL,
		position VARCHAR(100) NULL,
		width INT NULL,
		sequence INT NULL,
		create_user VARCHAR(50)  NULL DEFAULT dbo.FNADBUser(),
		create_ts DATETIME NULL DEFAULT GETDATE(),
		update_user VARCHAR(50) NULL,
		update_ts DATETIME NULL,
		num_column INT NULL DEFAULT 1
	)
END
ELSE 
BEGIN
	PRINT 'Table application_ui_template_fieldsets_audit EXISTS'
END