IF EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
        AND tc.Table_Name = 'calculate_wacog_group'
		AND	tc.CONSTRAINT_NAME = 'UC_calculate_wacoq'
)
BEGIN
	ALTER TABLE [dbo].calculate_wacog_group
	DROP CONSTRAINT [UC_calculate_wacoq]
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
        AND tc.Table_Name = 'calculate_wacog_group'
		AND	tc.CONSTRAINT_NAME = 'UC_calculate_wacoq'
)
BEGIN
	ALTER TABLE [dbo].calculate_wacog_group WITH NOCHECK 
	ADD CONSTRAINT UC_calculate_wacoq UNIQUE (
		wacog_group_id
		, as_of_date
		, term
		, jurisdiction
		, tier
		, default_jurisdiction
		, default_tier
		, vintage_year
	)
	PRINT 'Unique constraint added'
END
ELSE
BEGIN
	PRINT 'Already Added'
END

GO