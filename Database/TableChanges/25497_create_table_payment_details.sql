IF OBJECT_ID('[dbo].[payment_details]') IS NULL
BEGIN
	CREATE TABLE [dbo].[payment_details] (
		/**
			payment details

			Columns
			payment_details_id	: Unique Identifier for table.
			payment_terms_id	: Reference key of table setup_paying_terms		
			[percentage]		: percentage		
			formula_id			: formula_id	
			fees				: fees
			settlement_date		: settlement date		
			settlement_rule		: settlement_rule		
			settlement_days		: settlement_days	
			payment_date		: payment_date		
			payment_rule		: payment_rule	
			payment_days		: payment_days	
			deal_level			: deal_level	
			create_user			: specifies the username who creates the column.	
			create_ts			: specifies the date when column was created.	
			update_user			: specifies the username who updated the column.
			update_ts			: specifies the date when column was updated.
			
		*/
		payment_details_id			INT IDENTITY(1,1),
		payment_terms_id			INT ,
		[percentage]				FLOAT,
		formula_id					INT,
		fees						INT,
		settlement_date				DATETIME,
		settlement_rule				INT,
		settlement_days				INT,
		payment_date				DATETIME,
		payment_rule				INT,
		payment_days				INT,
		deal_level					CHAR(1),
		create_user					NVARCHAR(255) DEFAULT dbo.FNADBUser(),
		create_ts					DATETIME DEFAULT GETDATE(),
		update_user					NVARCHAR(255),
		update_ts					DATETIME,
		CONSTRAINT fk_payment_terms_id FOREIGN KEY (payment_terms_id) REFERENCES setup_paying_terms(payment_terms_id)
	)

	PRINT 'Table [dbo].[payment_details] is created.'
END
ELSE
BEGIN
	PRINT 'Table [dbo].[payment_details] already exists.'
END

GO