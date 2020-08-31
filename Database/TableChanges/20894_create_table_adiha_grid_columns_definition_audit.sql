SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[adiha_grid_columns_definition_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[adiha_grid_columns_definition_audit] (
		adiha_grid_columns_definition_audit_id	INT IDENTITY(1, 1)  PRIMARY KEY NOT NULL,
		application_ui_template_audit_id		INT FOREIGN KEY REFERENCES application_ui_template_audit(application_ui_template_audit_id),
    	column_id								INT,
		grid_id									INT,
    	column_name								VARCHAR(100) NULL,
    	column_label							VARCHAR(500) NULL,
    	field_type								VARCHAR(500) NULL,
		sql_string								VARCHAR(200) NULL,
		is_editable								CHAR(1) NULL,
		is_required								CHAR(1) NULL,
    	create_user								VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	create_ts								DATETIME NULL DEFAULT GETDATE(),
    	update_user								VARCHAR(50) NULL,
    	update_ts								DATETIME NULL,
		fk_table								VARCHAR(500),
		fk_column								VARCHAR(500),
		is_unique								CHAR(1),
		column_order							INT,
		is_hidden								CHAR(1),
		column_width							INT,
		sorting_preference						VARCHAR(20),
		validation_rule							VARCHAR(50),
		column_alignment						VARCHAR(20) NOT NULL DEFAULT 'left'
    )
END
ELSE
BEGIN
    PRINT 'Table adiha_grid_columns_definition_audit EXISTS'
END