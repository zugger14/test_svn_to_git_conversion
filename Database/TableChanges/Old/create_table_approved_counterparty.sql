SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[approved_counterparty]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].approved_counterparty(
		approved_counterparty_id		INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		counterparty_id					INT REFERENCES source_counterparty(source_counterparty_id) NOT NULL,
		approved_counterparty			INT REFERENCES source_counterparty(source_counterparty_id) NOT NULL,
		[create_user]					VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]						DATETIME NULL DEFAULT GETDATE(),
		[update_user]					VARCHAR(50) NULL,
		[update_ts]						DATETIME NULL
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].approved_counterparty EXISTS'
END


GO

IF OBJECT_ID('[dbo].[TRGUPD_approved_counterparty]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_approved_counterparty]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_approved_counterparty]
ON [dbo].[approved_counterparty]
FOR UPDATE
AS
    UPDATE approved_counterparty
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM approved_counterparty t
      INNER JOIN DELETED u ON t.approved_counterparty_id = u.approved_counterparty_id
GO