IF OBJECT_ID('dbo.source_fee') IS NULL
BEGIN
	CREATE TABLE dbo.source_fee
	(
		source_fee_id			INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
		fee_name				VARCHAR(100),
		counterparty			INT,
		[contract]				INT,
		effective_date			DATETIME,
		tenor_from				INT,
		tenor_to				INT,
		fees					INT,
		[type]					INT,
		[value]					INT,
		minimum_trade			INT,
		maximum_trade			INT,
		uom						INT,
		product					INT,
		currency				INT,
		[create_user]			VARCHAR(100) NULL DEFAULT dbo.FNADBUser(),
		[create_ts]				DATETIME DEFAULT GETDATE(),
		[update_user]			VARCHAR(100) NULL,
		[update_ts]				DATETIME NULL
	 )
END
ELSE
	PRINT 'Table source_fee already Exists.'
	

	

	