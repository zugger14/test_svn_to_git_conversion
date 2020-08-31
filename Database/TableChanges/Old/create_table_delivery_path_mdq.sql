IF OBJECT_ID('dbo.delivery_path_mdq') IS NULL
BEGIN
	CREATE TABLE dbo.delivery_path_mdq
	(
		delivery_path_mdq_id	INT IDENTITY(1,1),
		path_id					INT REFERENCES dbo.delivery_path(path_id),
		effective_date			DATETIME,
		mdq						NUMERIC(36,20) NULL,
		contract_id				INT REFERENCES dbo.contract_group(contract_id),
		rec_del					CHAR(1),
		[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME DEFAULT GETDATE(),
		[update_user]			VARCHAR(100) NULL,
		[update_ts]				DATETIME NULL
	 )
END
ELSE
	PRINT 'Table delivery_path_mdq already Exists.'