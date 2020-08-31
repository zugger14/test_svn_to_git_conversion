IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.[COLUMNS] c WHERE c.TABLE_NAME = 'setup_paying_terms'
				  AND c.COLUMN_NAME = 'payment_name')
BEGIN
	ALTER TABLE setup_paying_terms 
	/**
	Columns 
	payment_name: name of the payment terms
	*/
	ALTER COLUMN payment_name NVARCHAR(500);
END


IF NOT EXISTS(SELECT 1
              FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
              INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
                    AND tc.Constraint_name = ccu.Constraint_name    
                    AND   tc.CONSTRAINT_TYPE = 'UNIQUE'
                    AND   tc.Table_Name = 'setup_paying_terms'
                    AND ccu.COLUMN_NAME = 'payment_name'
)
BEGIN
	ALTER TABLE [dbo].[setup_paying_terms] 
	/**
	Columns 
	payment_name: name of the payment terms
	*/
	WITH NOCHECK ADD CONSTRAINT [UC_payment_name] UNIQUE(payment_name)
	PRINT 'Unique Constraints added on payment_name.'	
END
ELSE
BEGIN
	PRINT 'Unique Constraints on setup_paying_terms already exists.'
END


