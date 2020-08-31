SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[counterparty_contacts]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[counterparty_contacts]
    (
    	[counterparty_contact_id]	INT IDENTITY(1, 1) NOT NULL,
    	[counterparty_id]			INT NULL FOREIGN KEY REFERENCES source_counterparty(source_counterparty_id),
    	[contact_type]				INT NULL,
    	[title]						VARCHAR(200) NULL,
    	[name]						VARCHAR(100) NULL,
    	[id]						VARCHAR(100) NULL,
    	[address1]                  VARCHAR(100) NULL,
    	[address2]                  VARCHAR(100) NULL,
    	[city]						VARCHAR(100) NULL,
    	[state]                     INT NULL,
    	[zip]                       VARCHAR(100) NULL,
    	[telephone]                 VARCHAR(20) NULL,
    	[fax]                       VARCHAR(50) NULL,
    	[email]						VARCHAR(50) NULL,
    	[country]					INT NULL,
    	[region]					INT NULL,
    	[comment]					VARCHAR(500) NULL,
    	[is_active]					CHAR(1) NULL,
    	[is_primary]				CHAR(1) NULL,
    	[create_user]               VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                 DATETIME NULL DEFAULT GETDATE(),
    	[update_user]               VARCHAR(50) NULL,
    	[update_ts]                 DATETIME NULL
    ) 
END
ELSE
BEGIN
    PRINT 'Table counterparty_contacts EXISTS'
END

GO   

IF EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_counterparty_contacts]'))
    DROP TRIGGER [dbo].[TRGUPD_counterparty_contacts]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_counterparty_contacts]
ON [dbo].[counterparty_contacts]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE counterparty_contacts
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM counterparty_contacts cca
        INNER JOIN DELETED d ON d.counterparty_contact_id = cca.counterparty_contact_id
    END
END
GO