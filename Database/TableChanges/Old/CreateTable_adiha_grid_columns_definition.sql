SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[adiha_grid_columns_definition]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[adiha_grid_columns_definition] (
    	[column_id]					INT IDENTITY(1, 1)  PRIMARY KEY NOT NULL,
		[grid_id]					INT REFERENCES adiha_grid_definition(grid_id) NOT NULL,
    	[column_name]				VARCHAR(100) NULL,
    	[column_label]				VARCHAR(500) NULL,
    	[field_type]				VARCHAR(500) NULL,
		[sql_string]				VARCHAR(200) NULL,
		[is_editable]				CHAR(1) NULL,
		[is_required]				CHAR(1) NULL,
    	[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]					DATETIME NULL DEFAULT GETDATE(),
    	[update_user]				VARCHAR(50) NULL,
    	[update_ts]					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table adiha_grid_columns_definition EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_adiha_grid_columns_definition]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_adiha_grid_columns_definition]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_adiha_grid_columns_definition]
ON [dbo].[adiha_grid_columns_definition]
FOR UPDATE
AS
    UPDATE t
    SET    update_user     = dbo.FNADBUser(),
           update_ts       = GETDATE()
    FROM   adiha_grid_columns_definition t
    INNER JOIN DELETED u ON  t.[column_id] = u.[column_id]
GO