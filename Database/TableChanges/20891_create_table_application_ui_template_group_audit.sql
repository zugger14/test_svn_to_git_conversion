SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[application_ui_template_group_audit]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[application_ui_template_group_audit]
	(
		application_ui_template_group_audit_id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		application_ui_template_audit_id INT FOREIGN KEY REFERENCES application_ui_template_audit(application_ui_template_audit_id),
		application_group_id INT,
		application_ui_template_id  INT NOT NULL,
		group_name VARCHAR(100),
		group_description VARCHAR(200),
		active_flag CHAR(1),
		default_flag CHAR(1),
		sequence INT,
		inputWidth INT,
		create_user VARCHAR(50)  NULL DEFAULT dbo.FNADBUser(),
		create_ts DATETIME NULL DEFAULT GETDATE(),
		update_user VARCHAR(50) NULL,
		update_ts DATETIME NULL,
		field_layout VARCHAR(10) NULL DEFAULT '1C',
		application_grid_id INT NULL
	)
END
ELSE
BEGIN
	PRINT 'Table application_ui_template_group_audit EXISTS'
END

