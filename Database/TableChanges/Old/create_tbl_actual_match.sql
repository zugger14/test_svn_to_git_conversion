SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[actual_match]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].actual_match (
    	[actual_match_id]			INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,
    	[split_deal_actuals_id]     INT NOT NULL,
    	[deal_volume_split_id]         INT NOT NULL,
    	[create_user]               VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                 DATETIME NULL DEFAULT GETDATE(),
    	[update_user]               VARCHAR(50) NULL,
    	[update_ts]                 DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table actual_match EXISTS'
END

GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_actual_match]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_actual_match]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_actual_match]
ON [dbo].[actual_match]
FOR UPDATE
AS
    UPDATE actual_match
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM actual_match t
      INNER JOIN DELETED u ON t.[actual_match_id] = u.[actual_match_id]
GO