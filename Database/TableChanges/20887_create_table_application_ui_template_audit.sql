SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[application_ui_template_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[application_ui_template_audit]
	(
		application_ui_template_audit_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		application_ui_template_id  INT,
		application_function_id INT NOT NULL,
		template_name VARCHAR(100),
		template_description VARCHAR(200),
		active_flag CHAR(1),
		default_flag CHAR(1),
		create_user VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		create_ts DATETIME NULL DEFAULT GETDATE(),
		update_user VARCHAR(50) NULL,
		update_ts DATETIME NULL,
		table_name VARCHAR(200),
		is_report CHAR(1),
		edit_permission VARCHAR(100),
		delete_permission VARCHAR(100),
		remarks VARCHAR(250)
	)
END
ELSE
BEGIN
	PRINT 'Table application_ui_template_audit EXISTS'
END

