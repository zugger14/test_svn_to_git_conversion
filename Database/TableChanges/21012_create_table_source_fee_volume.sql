IF OBJECT_ID('dbo.source_fee_volume') IS NULL
BEGIN
	CREATE TABLE dbo.source_fee_volume
	(
		volume_id		INT IDENTITY(1,1),
		source_fee_id	INT REFERENCES dbo.source_fee(source_fee_id),
		effective_date	DATETIME,
		tenor_from		DATETIME,
		tenor_to		DATETIME,
		[type]			INT,
		from_volume 	FLOAT,
		to_volume		FLOAT,
		[value]			INT,
		minimum_value	INT,
		maximum_value	INT,
		uom				INT,
		currency		INT,
		[create_user]	VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]		DATETIME DEFAULT GETDATE(),
		[update_user]	VARCHAR(100) NULL,
		[update_ts]		DATETIME NULL

		CONSTRAINT FK_source_fee_volume_source_fee_id FOREIGN KEY (source_fee_id) REFERENCES dbo.source_fee(source_fee_id) ON DELETE CASCADE
	 )
END
ELSE
	PRINT 'Table source_fee_volume already Exists.'
	
	
	 