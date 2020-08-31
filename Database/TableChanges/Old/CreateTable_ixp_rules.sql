SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_rules]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_rules] (
    	[ixp_rules_id]                   INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[ixp_rules_name]                 VARCHAR(100) NULL,
    	[individuals_script_per_ojbect]  CHAR(1) NULL,
    	[limit_rows_to]                  INT NULL,
    	[before_insert_trigger]          VARCHAR(8000) NULL,
    	[after_insert_trigger]           VARCHAR(8000) NULL,
    	[create_user]                    VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                      DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                    VARCHAR(50) NULL,
    	[update_ts]                      DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_rules EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_rules]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_rules]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_rules]
ON [dbo].[ixp_rules]
FOR UPDATE
AS
    UPDATE ixp_rules
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_rules t
      INNER JOIN DELETED u ON t.ixp_rules_id = u.ixp_rules_id
GO