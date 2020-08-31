SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ixp_clr_functions]', N'U') IS NULL
BEGIN

CREATE TABLE [dbo].[ixp_clr_functions] (
	[ixp_clr_functions_id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY ,
	[ixp_clr_functions_name] [varchar](250) NULL,
	[ixp_location] [varchar](500) NULL,
	[ixp_password] [varbinary](1) NULL,
	[create_user] [varchar](250) DEFAULT [dbo].[FNADBUSER](),
	[create_ts] [datetime]  DEFAULT (getdate()) ,
	[update_user] [varchar](250) NULL,
	[update_ts] [datetime] NULL,
	[method_name] [varchar](100) NOT NULL,
	[description] [varchar](100) NULL
	)

END 
IF COL_LENGTH('ixp_clr_functions', 'description') IS NULL
BEGIN
    ALTER TABLE ixp_clr_functions ADD description VARCHAR(100) NULL
END
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ixp_clr_functions]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ixp_clr_functions]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ixp_clr_functions]
ON [dbo].[ixp_clr_functions]
FOR UPDATE
AS
    UPDATE ixp_clr_functions
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ixp_clr_functions t
      INNER JOIN DELETED u ON t.[ixp_clr_functions_id] = u.[ixp_clr_functions_id]
GO

	IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'ixp_clr_functions'
                    AND ccu.COLUMN_NAME IN ('ixp_clr_functions_name')
)
BEGIN
	ALTER TABLE [dbo].[ixp_clr_functions] WITH NOCHECK ADD CONSTRAINT [UC_ixp_clr_functions] UNIQUE(ixp_clr_functions_name)
	PRINT 'Unique Constraints added on ixp_clr_functions.'	
END
ELSE
BEGIN
	PRINT 'Unique Constraints on functions already exists.'
END	

