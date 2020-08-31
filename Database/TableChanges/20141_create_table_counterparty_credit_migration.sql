SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[counterparty_credit_migration]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].counterparty_credit_migration(
		counterparty_credit_migration_id	INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
		counterparty_credit_info_id			INT FOREIGN KEY REFERENCES counterparty_credit_info (counterparty_credit_info_id),
		effective_date						DATE,
		counterparty						INT,
		internal_counterparty				INT,
		[contract]							INT,
		rating								INT,
		credit_limit						INT,
		credit_limit_to_us					INT,
		[create_user]						VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]							DATETIME NULL DEFAULT GETDATE(),
    	[update_user]						VARCHAR(50) NULL,
    	[update_ts]							DATETIME NULL,
    	
    	CONSTRAINT AK_Unique_fields UNIQUE(effective_date, counterparty, internal_counterparty, [contract])
	)
END
ELSE
BEGIN
    PRINT 'Table [dbo].counterparty_credit_migration EXISTS'
END

GO

IF OBJECT_ID('[dbo].[TRGUPD_counterparty_credit_migration]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_counterparty_credit_migration]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_counterparty_credit_migration]
ON [dbo].[counterparty_credit_migration]
FOR UPDATE
AS
    UPDATE counterparty_credit_migration
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM counterparty_credit_migration ccm
      INNER JOIN DELETED d ON ccm.counterparty_credit_migration_id = d.counterparty_credit_migration_id
GO