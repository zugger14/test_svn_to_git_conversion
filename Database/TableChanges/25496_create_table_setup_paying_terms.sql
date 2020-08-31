
IF OBJECT_ID('[dbo].[setup_paying_terms]') IS NULL
BEGIN
	CREATE TABLE [dbo].[setup_paying_terms] (
		/**
			paying terms

			Columns:
			payment_terms_id: Unique identifier for the table
			payment_name: Name of the payment
			create_user : specifies the username who creates the column.
			create_ts : specifies the date when column was created.
			update_user : specifies the username who updated the column.
			update_ts : specifies the date when column was updated.
			
		*/
		payment_terms_id		INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
		payment_name			NVARCHAR(MAX) NOT NULL,
		create_user				NVARCHAR(255) NOT NULL DEFAULT dbo.FNADBUser(),
		create_ts				DATETIME  DEFAULT GETDATE(),
		update_user				NVARCHAR(255) NULL,
		update_ts				DATETIME NULL
	)

	PRINT 'Table [dbo].[setup_paying_terms] is created.'
END
ELSE
BEGIN
	PRINT 'Table [dbo].[setup_paying_terms] already exists.'
END

GO




