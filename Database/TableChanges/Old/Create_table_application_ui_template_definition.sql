SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'[dbo].[application_ui_template_definition]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[application_ui_template_definition]
	(
		application_ui_field_id  INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		application_function_id INT NOT NULL FOREIGN KEY REFERENCES application_Functions(function_id),
		field_id  VARCHAR(100),
		farrms_field_id VARCHAR(100),
		default_label VARCHAR(100),
		field_type VARCHAR(100),
		data_type VARCHAR(100),
		header_detail CHAR(1),
		system_required CHAR(1) ,
		sql_string VARCHAR(5000),
		field_size INT,
		is_disable CHAR(1) ,
		is_hidden CHAR(1) ,
		default_value VARCHAR(200),
		insert_required CHAR(1),
		data_flag CHAR(1),
		update_required CHAR(1) ,
		has_round_option CHAR(1),
		create_user Varchar(50)  NULL DEFAULT dbo.FNADBUser(),
		create_ts Datetime NULL Default GETDATE(),
		update_user varchar(50) NULL,
		update_ts datetime NULL
	)
END
ELSE
BEGIN
	PRINT 'Table application_ui_template_definition EXISTS'
END

