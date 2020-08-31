SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'dbo.source_counterparty_history',N'U') IS NULL
BEGIN
    CREATE TABLE dbo.source_counterparty_history
    (
    source_counterparty_history_id  INT IDENTITY(1, 1) PRIMARY KEY,    
	source_counterparty_id INT FOREIGN KEY REFERENCES dbo.source_counterparty(source_counterparty_id) ON DELETE CASCADE,           
	counterparty_name	NVARCHAR(220) NULL,	
	counterparty_id NVARCHAR(220) NULL,
	effective_date		DATETIME NULL,	
	counterparty_desc NVARCHAR(220) NULL,
	parent_counterparty INT,
	create_user				VARCHAR(50)  DEFAULT  dbo.FNADBUser(),	
    create_ts				DATETIME DEFAULT GETDATE() NULL,
    update_user				VARCHAR(50) NULL,
    update_ts				DATETIME NULL
    )   
END
ELSE
BEGIN
    PRINT 'Table source_counterparty_history EXISTS'
END
 
GO


IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_source_counterparty_history]'))
    DROP TRIGGER [dbo].[TRGUPD_source_counterparty_history]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE TRIGGER [dbo].[TRGUPD_source_counterparty_history]
ON [dbo].[source_counterparty_history]
FOR UPDATE
AS
BEGIN
    --this check is required to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE source_counterparty_history
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM source_counterparty_history ah
        INNER JOIN DELETED d ON d.source_counterparty_history_id = ah.source_counterparty_history_id
    END
END

GO


