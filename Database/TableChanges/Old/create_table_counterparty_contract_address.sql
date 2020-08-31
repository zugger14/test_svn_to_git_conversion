SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[counterparty_contract_address]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[counterparty_contract_address]
    (
    	[counterparty_contract_address_id]  INT IDENTITY(1, 1) NOT NULL,
    	[counterparty_id]                   VARCHAR(200) NULL,
    	[counterparty_description]          VARCHAR(200) NULL,
    	[address1]                          VARCHAR(100) NULL,
    	[address2]                          VARCHAR(100) NULL,
    	[address3]                          VARCHAR(100) NULL,
    	[address4]                          VARCHAR(100) NULL,
    	[contract_id]                       INT NULL,
    	[email]                             VARCHAR(100) NULL,
    	[fax]                               VARCHAR(50) NULL,
    	[telephone]                         VARCHAR(20) NULL,
    	[parent_counterparty_id]			INT NULL,
    	[create_user]                       VARCHAR(50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                         DATETIME NULL DEFAULT GETDATE(),
    	[update_user]                       VARCHAR(50) NULL,
    	[update_ts]                         DATETIME NULL,
    	[user_action]                       VARCHAR(50)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    PRINT 'Table counterparty_contract_address EXISTS'
END

GO   

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_counterparty_contract_address]'))
    DROP TRIGGER [dbo].[TRGUPD_counterparty_contract_address]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_counterparty_contract_address]
ON [dbo].[counterparty_contract_address]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE counterparty_contract_address
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM counterparty_contract_address cca
        INNER JOIN DELETED d ON d.counterparty_contract_address_id = cca.counterparty_contract_address_id
    END
END
GO