IF OBJECT_ID('dbo.source_fee_product') IS NULL
BEGIN
	CREATE TABLE dbo.source_fee_product
	(
		product_id			INT IDENTITY(1,1),
		source_fee_id				INT REFERENCES dbo.source_fee(source_fee_id),
		Commodity					INT, 
		deal_type					INT,
		location					INT,
		[index]						INT,
		--[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		--[create_ts]				DATETIME DEFAULT GETDATE(),
		--[update_user]			VARCHAR(100) NULL,
		--[update_ts]				DATETIME NULL, 
		CONSTRAINT FK_source_fee_product_source_fee_id FOREIGN KEY (source_fee_id) REFERENCES dbo.source_fee(source_fee_id) ON DELETE CASCADE
	 )
END
ELSE
	PRINT 'Table source_fee_product already Exists.'
	
	
