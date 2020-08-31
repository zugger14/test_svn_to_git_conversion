SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[adiha_grid_definition_audit]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[adiha_grid_definition_audit] (
    	adiha_grid_definition_audit_id		INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
		application_ui_template_audit_id	INT FOREIGN KEY REFERENCES application_ui_template_audit(application_ui_template_audit_id),
		grid_id								INT,
    	grid_name							VARCHAR(100) NULL,
    	fk_table							VARCHAR(500) NULL,
    	fk_column							VARCHAR(500) NULL,
    	create_user							VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	create_ts							DATETIME NULL DEFAULT GETDATE(),
    	update_user							VARCHAR(50) NULL,
    	update_ts							DATETIME NULL,
		load_sql							VARCHAR(5000),
		grid_label							VARCHAR(500),
		grid_type							CHAR(1),
		grouping_column						VARCHAR(500),
		edit_permission						VARCHAR(100),
		delete_permission					VARCHAR(100),
		split_at							INT NULL
    )
END
ELSE
BEGIN
    PRINT 'Table adiha_grid_definition_audit EXISTS'
END