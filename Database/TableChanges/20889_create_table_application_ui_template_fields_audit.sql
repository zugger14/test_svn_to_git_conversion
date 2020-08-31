SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[application_ui_template_fields_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[application_ui_template_fields_audit]
	(
		application_ui_template_fields_audit_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		application_ui_template_audit_id INT FOREIGN KEY REFERENCES application_ui_template_audit(application_ui_template_audit_id),
		application_field_id  INT,
		application_group_id  INT NOT NULL,
		application_ui_field_id INT NULL,
		application_fieldset_id INT NULL,
		field_alias VARCHAR(100),
		Default_value VARCHAR(200),
		default_format VARCHAR(200),
		validation_flag CHAR(1),
		hidden CHAR(1),
		field_size INT,
		field_type VARCHAR(200),
		field_id VARCHAR(200),
		sequence INT,
		create_user VARCHAR(50)  NULL DEFAULT dbo.FNADBUser(),
		create_ts DATETIME NULL DEFAULT GETDATE(),
		update_user VARCHAR(50) NULL,
		update_ts DATETIME NULL,
		inputHeight INT,
		udf_template_id INT NULL,
		position VARCHAR(200),
		dependent_field VARCHAR(200),
		dependent_query VARCHAR(200),
		grid_id VARCHAR(100) NULL,
		validation_message VARCHAR(200)
	)
END
ELSE
BEGIN
	PRINT 'Table application_ui_template_fields_audit EXISTS'
END


