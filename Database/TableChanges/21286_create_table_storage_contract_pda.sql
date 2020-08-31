IF OBJECT_ID('dbo.storage_contract_pda') IS NULL
BEGIN
	CREATE TABLE dbo.storage_contract_pda
	(
		storage_contract_pda_id	INT IDENTITY(1,1),
		contract_id						INT REFERENCES dbo.contract_group(contract_id),
		effective_date					DATETIME,
		pda_method						INT,
		[value]						    NUMERIC(36,20) NULL,
		--value_to						NUMERIC(36,20) NULL,
		[create_user]					VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]						DATETIME DEFAULT GETDATE(),
		[update_user]					VARCHAR(100) NULL,
		[update_ts]						DATETIME NULL
	 )
END
ELSE
	PRINT 'Table storage_contract_pda already Exists.'


IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_storage_contract_pda]'))
    DROP TRIGGER [dbo].[TRGUPD_storage_contract_pda]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_storage_contract_pda]
ON [dbo].[storage_contract_pda]
FOR UPDATE
AS
BEGIN
    -- used to prevent recursive trigger
    IF NOT UPDATE(create_ts)
    BEGIN
        UPDATE [storage_contract_pda]
        SET update_user = dbo.FNADBUser(), update_ts = GETDATE()
        FROM [storage_contract_pda] g
        INNER JOIN DELETED d ON d.storage_contract_pda_id = g.storage_contract_pda_id
    END
END
GO
