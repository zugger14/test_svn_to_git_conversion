SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[ticket_match]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].ticket_match (
    	[ticket_match_id]			INT IDENTITY(1, 1) PRIMARY KEY NOT NULL,    	
    	[match_group_header_id]     INT NOT NULL,
		[ticket_detail_id]			INT NOT NULL,
    	[create_user]               VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                 DATETIME NULL DEFAULT GETDATE(),
    	[update_user]               VARCHAR(50) NULL,
    	[update_ts]                 DATETIME NULL
    )
END
ELSE
BEGIN
    PRINT 'Table ticket_match EXISTS'
END

GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID('[dbo].[TRGUPD_ticket_match]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_ticket_match]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_ticket_match]
ON [dbo].[ticket_match]
FOR UPDATE
AS
    UPDATE ticket_match
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM ticket_match t
      INNER JOIN DELETED u ON t.[ticket_match_id] = u.[ticket_match_id]
GO


IF COL_LENGTH('ticket_match', 'match_group_detail_id') IS NULL
BEGIN
    ALTER TABLE ticket_match ADD match_group_detail_id INT
END
GO