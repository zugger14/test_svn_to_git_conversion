SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[application_ui_template]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[application_ui_template]
	(
		application_ui_template_id  INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		application_function_id INT NOT NULL FOREIGN KEY REFERENCES application_Functions(function_id) ,
		template_name VARCHAR(100),
		template_description VARCHAR(200),
		active_flag CHAR(1),
		default_flag CHAR(1),
		create_user Varchar(50)  NULL DEFAULT dbo.FNADBUser(),
		create_ts Datetime NULL Default GETDATE(),
		update_user varchar(50) NULL,
		update_ts datetime NULL
	)
END
ELSE
BEGIN
	PRINT 'Table application_ui_template EXISTS'
END

