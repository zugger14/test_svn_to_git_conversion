--Drop unique constraint (shipper_code_id, effective_date, location_id)
IF EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
        AND tc.Table_Name = 'shipper_code_mapping_detail'
		AND	tc.CONSTRAINT_NAME = 'UC_shipper_code_mapping_detail'
)
BEGIN
	ALTER TABLE 
	/**
	 Drop constraint UC_shipper_code_mapping_detail not used
	*/
	shipper_code_mapping_detail
	DROP CONSTRAINT UC_shipper_code_mapping_detail
	PRINT 'Unique constraint deleted'
END
ELSE
BEGIN
	PRINT 'Already Deleted'
END

--Add unique constraint (shipper_code_id, effective_date, location_id, shipper_code, shipper_code1)
IF NOT EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
        AND tc.Table_Name = 'shipper_code_mapping_detail'
		AND	tc.CONSTRAINT_NAME = 'UC_shipper_code_mapping_detail'
)
BEGIN
	ALTER TABLE
	/**
	 Add constraint UC_shipper_code_mapping_detail
	*/
	shipper_code_mapping_detail WITH NOCHECK 
	ADD CONSTRAINT UC_shipper_code_mapping_detail UNIQUE (shipper_code_id, effective_date, location_id, shipper_code, shipper_code1)
	PRINT 'Unique constraint added'
END
ELSE
BEGIN
	PRINT 'Already Added'
END

GO