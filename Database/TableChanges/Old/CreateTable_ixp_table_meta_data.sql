SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_table_meta_data]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_table_meta_data] (
    	[ixp_table_meta_data_table_id]  INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[ipx_tables_id]                 INT REFERENCES ixp_tables(ixp_tables_id) NOT NULL,
    	[table_name]                    VARCHAR(100) NULL,
    	[identity_column]               VARCHAR(100) NULL,
    	[unique_columns]                VARCHAR(5000) NULL,
    	[create_user]                   VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                     DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                   VARCHAR(50) NULL,
    	[update_ts]                     DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_table_meta_data EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_table_meta_data]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_table_meta_data]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_table_meta_data]
ON [dbo].[ixp_table_meta_data]
FOR UPDATE
AS
    UPDATE ixp_table_meta_data
    SET    update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM   ixp_table_meta_data t
    INNER JOIN DELETED u ON  t.ixp_table_meta_data_table_id = u.ixp_table_meta_data_table_id
GO