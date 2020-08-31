IF EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
        AND tc.Table_Name = 'state_properties_details'
		AND	tc.CONSTRAINT_NAME = 'UNQ_tier_tech_techSub_pricInd'
)
BEGIN
	ALTER TABLE [dbo].state_properties_details
	DROP CONSTRAINT [UNQ_tier_tech_techSub_pricInd]
	PRINT 'Unique constraint deleted'
END
ELSE
BEGIN
	PRINT 'Already Deleted'
END

IF NOT EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
        AND tc.Table_Name = 'state_properties_details'
		AND	tc.CONSTRAINT_NAME = 'UNQ_tier_tech_techSub_pricInd'
)
BEGIN
	ALTER TABLE [dbo].state_properties_details WITH NOCHECK 
	ADD CONSTRAINT UNQ_tier_tech_techSub_pricInd UNIQUE (
		state_value_id
		, tier_id
		, technology_id			
		, technology_subtype_id				
		, price_index			
	)
	PRINT 'Unique constraint added'
END
ELSE
BEGIN
	PRINT 'Already Added'
END

GO