SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[application_ui_template_fieldsets]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[application_ui_template_fieldsets]
	(
		application_fieldset_id  INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		application_group_id  INT NOT NULL FOREIGN KEY REFERENCES application_ui_template_group(application_group_id) ,
		fieldset_name varchar(50) NULL,
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
		create_user Varchar(50)  NULL DEFAULT dbo.FNADBUser(),
		create_ts Datetime NULL Default GETDATE(),
		update_user varchar(50) NULL,
		update_ts datetime NULL
	)
END
ELSE 
BEGIN
	PRINT 'Table application_ui_template_fieldsets EXISTS'
END