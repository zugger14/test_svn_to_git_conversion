SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 

 
IF OBJECT_ID(N'[dbo].[workflow_icons]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].workflow_icons
    (
    [workflow_icons_id]     INT IDENTITY(1, 1) NOT NULL,
	workflow_menu_id		INT NULL,
    image_id				INT NULL,
	workflow_user			VARCHAR(50) NULL,
    [create_user]			VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    [create_ts]				DATETIME NULL DEFAULT GETDATE(),
    [update_user]			VARCHAR(50) NULL,
    [update_ts]				DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table workflow_icons EXISTS'
END
GO

IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                    AND   tc.Table_Name = 'workflow_icons' 
                    AND ccu.COLUMN_NAME = 'workflow_icons_id')
ALTER TABLE [dbo].workflow_icons WITH NOCHECK ADD CONSTRAINT pk_workflow_icons_id PRIMARY KEY(workflow_icons_id)
GO

IF OBJECT_ID('[dbo].[TRGUPD_workflow_icons]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_workflow_icons]
GO

CREATE TRIGGER [dbo].[TRGUPD_workflow_icons]
ON [dbo].workflow_icons
FOR UPDATE
AS
    UPDATE workflow_icons
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM workflow_icons t
     INNER JOIN DELETED u ON t.workflow_icons_id = u.workflow_icons_id
GO 
