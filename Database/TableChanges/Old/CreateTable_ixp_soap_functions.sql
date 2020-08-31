SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_soap_functions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_soap_functions] (
    	[ixp_soap_functions_id]    INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[ixp_soap_functions_name]  VARCHAR(100) NULL,
    	[ixp_soap_xml]             XML NULL,
    	[create_user]              VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                DATETIME NULL DEFAULT GETDATE(),
    	[update_user]              VARCHAR(50) NULL,
    	[update_ts]                DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_soap_functions EXISTS'
END
 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_soap_functions]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_soap_functions]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_soap_functions]
ON [dbo].[ixp_soap_functions]
FOR UPDATE
AS
    UPDATE ixp_soap_functions
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_soap_functions t
      INNER JOIN DELETED u ON t.[ixp_soap_functions_id] = u.[ixp_soap_functions_id]
GO


IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'ixp_soap_functions'
                    AND ccu.COLUMN_NAME IN ('ixp_soap_functions_name')
)
BEGIN
	ALTER TABLE [dbo].[ixp_soap_functions] WITH NOCHECK ADD CONSTRAINT [UC_ixp_soap_functions] UNIQUE(ixp_soap_functions_name)
	PRINT 'Unique Constraints added on ixp_soap_functions.'	
END
ELSE
BEGIN
	PRINT 'Unique Constraints on ixp_soap_functions already exists.'
END	