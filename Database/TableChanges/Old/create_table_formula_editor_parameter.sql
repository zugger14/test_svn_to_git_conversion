SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[formula_editor_parameter]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[formula_editor_parameter]
    (
		[formula_param_id]  INT IDENTITY(1, 1) NOT NULL,
		[formula_id]		INT NULL,
		[field_label]		VARCHAR(100) NULL,
		[field_type]		CHAR(1) NULL,
		[default_value]		VARCHAR(100) NULL,	
		[tooltip]			VARCHAR(500) NULL,
		[field_size]		INT NULL,
		[sql_string]		VARCHAR(500) NULL,
		[is_required]		CHAR(1)	NULL,
		[is_numeric]		CHAR(1) NULL,	
		[custom_validation]	VARCHAR(100) NULL,
		[sequence]			INT NULL,
		[create_user]		VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]			DATETIME NULL DEFAULT GETDATE(),
		[update_user]		VARCHAR(50) NULL,
		[update_ts]			DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table formula_editor_parameter EXISTS'
END
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_formula_editor_parameter]'))
    DROP TRIGGER [dbo].[TRGUPD_formula_editor_parameter]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_formula_editor_parameter]
ON [dbo].[formula_editor_parameter]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE formula_editor_parameter
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM formula_editor_parameter fep
        INNER JOIN DELETED d ON d.formula_param_id = fep.formula_param_id
    END
END
GO
