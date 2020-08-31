SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[application_ui_template_fields]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[application_ui_template_fields]
	(
		appliction_field_id  INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		application_group_id  INT NOT NULL FOREIGN KEY REFERENCES application_ui_template_group(appliction_group_id) ,
		application_ui_field_id INT NOT NULL FOREIGN KEY REFERENCES application_ui_template_definition(application_ui_field_id) ,
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
		create_user Varchar(50)  NULL DEFAULT dbo.FNADBUser(),
		create_ts Datetime NULL Default GETDATE(),
		update_user varchar(50) NULL,
		update_ts datetime NULL
	)
END
ELSE
BEGIN
	PRINT 'Table application_ui_template_fields EXISTS'
END


