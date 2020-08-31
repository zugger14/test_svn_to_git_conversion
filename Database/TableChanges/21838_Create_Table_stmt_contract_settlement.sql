SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
IF OBJECT_ID(N'[dbo].[stmt_contract_settlement]', N'U') IS  NULL
BEGIN
CREATE TABLE [dbo].stmt_contract_settlement
    (
    	[stmt_contract_settlement_id]   INT IDENTITY(1, 1) NOT NULL,
    	as_of_date				   DATETIME,
		counterparty_id			   INT,
		contract_id				   INT,
		charge_type_id			   INT,
		term_start				   DATETIME,
		term_end				   DATETIME,
		volume					   NUMERIC(38,20),
		value					   NUMERIC(38,20),	
		volume_uom_id			   INT,
		currency_id				   INT,		
    	[create_user]			   VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts]                DATETIME DEFAULT GETDATE(),
    	[update_user]              VARCHAR(100) NULL,
    	[update_ts]                DATETIME NULL,
    	CONSTRAINT [pk_stmt_contract_settlement_id] PRIMARY KEY CLUSTERED([stmt_contract_settlement_id] ASC)     
    ) ON [PRIMARY]
    PRINT 'Table Successfully Created'
END
ELSE
BEGIN
    PRINT 'Table stmt_contract_settlement EXISTS'
END
GO

--Update Trigger
IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_stmt_contract_settlement]'))
    DROP TRIGGER  [dbo].[TRGUPD_stmt_contract_settlement]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_stmt_contract_settlement]
ON [dbo].[stmt_contract_settlement]
FOR UPDATE
AS
BEGIN
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [dbo].[stmt_contract_settlement]
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM [dbo].[stmt_contract_settlement] fr
        INNER JOIN DELETED d ON d.stmt_contract_settlement_id = fr.stmt_contract_settlement_id
    END
END
GO

