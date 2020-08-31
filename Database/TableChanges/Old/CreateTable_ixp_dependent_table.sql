SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_dependent_table]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_dependent_table] (
    	[ixp_dependent_table_id]  INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[table_id]                INT REFERENCES ixp_table_meta_data(ixp_table_meta_data_table_id) NOT NULL,
    	[parent_table_id]         INT REFERENCES ixp_table_meta_data(ixp_table_meta_data_table_id) NOT NULL,
    	[seq_number]              INT NOT NULL,
    	[create_user]             VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME NULL DEFAULT GETDATE(),
    	[update_user]             VARCHAR(50) NULL,
    	[update_ts]               DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_dependent_table EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_dependent_table]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_dependent_table]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_dependent_table]
ON [dbo].[ixp_dependent_table]
FOR UPDATE
AS
    UPDATE ixp_dependent_table
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_dependent_table t
      INNER JOIN DELETED u ON t.ixp_dependent_table_id = u.ixp_dependent_table_id
GO