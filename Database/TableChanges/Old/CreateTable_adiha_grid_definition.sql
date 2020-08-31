SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[adiha_grid_definition]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[adiha_grid_definition] (
    	[grid_id]					INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[grid_name]					VARCHAR(100) NULL,
    	[fk_table]					VARCHAR(500) NULL,
    	[fk_column]					VARCHAR(500) NULL,
    	[create_user]				VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]					DATETIME NULL DEFAULT GETDATE(),
    	[update_user]				VARCHAR(50) NULL,
    	[update_ts]					DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table adiha_grid_definition EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_adiha_grid_definition]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_adiha_grid_definition]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_adiha_grid_definition]
ON [dbo].[adiha_grid_definition]
FOR UPDATE
AS
    UPDATE t
    SET    update_user     = dbo.FNADBUser(),
           update_ts       = GETDATE()
    FROM   adiha_grid_definition t
    INNER JOIN DELETED u ON  t.[grid_id] = u.[grid_id]
GO