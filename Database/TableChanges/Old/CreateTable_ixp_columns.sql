SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[ixp_columns]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_columns] (
    	[ixp_columns_id]    INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[ixp_table_id]      INT REFERENCES ixp_tables(ixp_tables_id) NOT NULL,
    	[ixp_columns_name]  VARCHAR(100) NULL,
    	[column_datatype]   VARCHAR(50) NULL DEFAULT('VARCHAR(600)'),
    	[is_major]		    BIT NULL,
    	[header_detail]		CHAR(1) NULL,
    	[create_user]       VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]         DATETIME NULL DEFAULT GETDATE(),
    	[update_user]       VARCHAR(50) NULL,
    	[update_ts]         DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_columns EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_columns]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_columns]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_columns]
ON [dbo].[ixp_columns]
FOR UPDATE
AS
    UPDATE ixp_columns
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_columns t
      INNER JOIN DELETED u ON t.[ixp_columns_id] = u.[ixp_columns_id]
GO