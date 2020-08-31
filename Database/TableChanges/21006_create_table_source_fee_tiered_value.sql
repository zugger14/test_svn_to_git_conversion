IF OBJECT_ID('dbo.source_fee_tiered_value') IS NULL
BEGIN
	CREATE TABLE dbo.source_fee_tiered_value
	(
		tiered_value_id			INT IDENTITY(1,1),
		source_fee_id			INT REFERENCES dbo.source_fee(source_fee_id),
		from_volume				INT,
		to_value				INT,
		[value]					INT,
		--[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		--[create_ts]				DATETIME DEFAULT GETDATE(),
		--[update_user]			VARCHAR(100) NULL,
		--[update_ts]				DATETIME NULL, 
		CONSTRAINT FK_source_fee_tiered_value_source_fee_id FOREIGN KEY (source_fee_id) REFERENCES dbo.source_fee(source_fee_id) ON DELETE CASCADE
	 )
END
ELSE
	PRINT 'Table source_fee_tiered_value already Exists.'
	
