-- Drop foreign key constraint
IF EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
        AND tc.Table_Name = 'shipper_code_mapping'
		AND	tc.CONSTRAINT_NAME = 'FK_shipper_code_mapping_location_id'
)
BEGIN
	ALTER TABLE 
	/**
	 Drop constraint FK_shipper_code_mapping_location_id not used
	*/
	shipper_code_mapping
	DROP CONSTRAINT FK_shipper_code_mapping_location_id
	PRINT 'Unique constraint deleted'
END
ELSE
BEGIN
	PRINT 'Already Deleted'
END

GO

-- Drop unique constraint (counterparty_id, location_id)
IF EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
        AND tc.Table_Name = 'shipper_code_mapping'
		AND	tc.CONSTRAINT_NAME = 'UC_shipper_code_mapping'
)
BEGIN
	ALTER TABLE 
	/**
	 Drop constraint UC_shipper_code_mapping not used
	*/
	shipper_code_mapping
	DROP CONSTRAINT UC_shipper_code_mapping
	PRINT 'Unique constraint deleted'
END
ELSE
BEGIN
	PRINT 'Already Deleted'
END

--Add unique constraint (counterparty_id)
IF NOT EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
        AND tc.Table_Name = 'shipper_code_mapping'
		AND	tc.CONSTRAINT_NAME = 'UC_shipper_code_mapping'
)
BEGIN
	ALTER TABLE
	/**
	 Add constraint UC_shipper_code_mapping
	*/
	shipper_code_mapping WITH NOCHECK 
	ADD CONSTRAINT UC_shipper_code_mapping UNIQUE (counterparty_id)
	PRINT 'Unique constraint added'
END
ELSE
BEGIN
	PRINT 'Already Added'
END

GO

--Drop column location_id
IF COL_LENGTH('shipper_code_mapping', 'location_id') IS NOT NULL
BEGIN
   ALTER TABLE 
   /**
	 Drop column location_id not used
	*/
   shipper_code_mapping DROP COLUMN location_id

END
GO