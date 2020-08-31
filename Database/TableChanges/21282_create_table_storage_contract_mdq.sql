IF OBJECT_ID('dbo.storage_contract_mdq') IS NULL
BEGIN
	CREATE TABLE [dbo].[storage_contract_mdq](
		[storage_contract_mdq_id] INT IDENTITY(1,1) NOT NULL,
		[contract_id] INT FOREIGN KEY REFERENCES [dbo].[contract_group] ([contract_id]) ON DELETE CASCADE,
		[effective_date] DATETIME NULL,
		[mdq] FLOAT NULL,
		[create_user] VARCHAR(100)  DEFAULT ([dbo].[FNADBUser]()),
		[create_ts] DATETIME DEFAULT (getdate()),
		[update_user] VARCHAR(100) NULL,
		[update_ts] DATETIME NULL
	)
END
ELSE
	PRINT 'Table storage_contract_mdq already Exists.'