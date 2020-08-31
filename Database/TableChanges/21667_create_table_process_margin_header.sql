IF OBJECT_ID('[dbo].[process_margin_header]') IS NULL
BEGIN
	CREATE TABLE [dbo].[process_margin_header] (
		  [process_margin_header_id] INT IDENTITY(1,1) PRIMARY KEY
		, [counterparty_id] INT CONSTRAINT FK_process_margin_counterparty FOREIGN KEY (counterparty_id) REFERENCES source_counterparty (source_counterparty_id)  
		, [contract_id] INT CONSTRAINT FK_process_margin_contract FOREIGN KEY (contract_id) REFERENCES contract_group (contract_id)
		, [product_id] INT CONSTRAINT FK_process_margin_sdv FOREIGN KEY (product_id) REFERENCES static_data_value (value_id)
		, [create_user] VARCHAR(50) DEFAULT(dbo.FNADBUser())
		, [create_ts] DATETIME DEFAULT GETDATE()
		, [update_user] VARCHAR(50)
		, [update_ts]  DATETIME
		, CONSTRAINT UC_process_margin_header UNIQUE (counterparty_id, contract_id, product_id)
	)
END

ELSE 
	PRINT 'Table process_margin_header already exists.'
GO

IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_process_margin_header]'))
    DROP TRIGGER [dbo].[TRGUPD_process_margin_header]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_process_margin_header]
ON [dbo].[process_margin_header]
FOR UPDATE
AS
BEGIN
    -- used to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [process_margin_header]
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM [process_margin_header] g
        INNER JOIN DELETED d ON d.process_margin_header_id = g.process_margin_header_id
    END
END
GO
