IF OBJECT_ID('dbo.transportation_contract_mdq') IS NULL
BEGIN
	CREATE TABLE dbo.transportation_contract_mdq
	(
		transportation_contract_mdq_id	INT IDENTITY(1,1),
		contract_id				INT REFERENCES dbo.contract_group(contract_id),
		effective_date			DATETIME,
		mdq						NUMERIC(36,20) NULL,
		[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME DEFAULT GETDATE(),
		[update_user]			VARCHAR(100) NULL,
		[update_ts]				DATETIME NULL
	 )
END
ELSE
	PRINT 'Table transportation_contract_mdq already Exists.'