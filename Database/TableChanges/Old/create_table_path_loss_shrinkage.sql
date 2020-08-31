SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[path_loss_shrinkage]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[path_loss_shrinkage]
    (
    	[path_loss_shrinkage_id]  INT IDENTITY(1, 1) NOT NULL,
    	[path_id]                 INT NOT NULL,
    	[loss_factor]			  NUMERIC(36,20) NULL,
    	[shrinkage_curve_id]      INT NULL,
		[is_receipt]			  CHAR(1) DEFAULT 'r',
    	[effective_date]          DATETIME NULL DEFAULT GETDATE(),
    	[create_user]             VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]               DATETIME NULL DEFAULT GETDATE(),
    	[update_user]             VARCHAR(50) NULL,
    	[update_ts]               DATETIME NULL
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table path_loss_shrinkage EXISTS'
END

GO   

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_path_loss_shrinkage]'))
    DROP TRIGGER [dbo].[TRGUPD_path_loss_shrinkage]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_path_loss_shrinkage]
ON [dbo].[path_loss_shrinkage]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE path_loss_shrinkage
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM path_loss_shrinkage cca
        INNER JOIN DELETED d ON d.path_loss_shrinkage_id = cca.path_loss_shrinkage_id
    END
END
GO