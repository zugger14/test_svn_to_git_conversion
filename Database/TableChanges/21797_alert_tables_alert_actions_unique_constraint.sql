	IF EXISTS( 
	SELECT 1
	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
		AND tc.Constraint_name = ccu.Constraint_name    
        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
        AND tc.Table_Name = 'alert_actions'
		AND	tc.CONSTRAINT_NAME = 'uc_alert_actions'
)
BEGIN
	ALTER TABLE [dbo].alert_actions
	DROP CONSTRAINT [uc_alert_actions]
	PRINT 'Unique constraint deleted'
END
ELSE
BEGIN
	PRINT 'Already Deleted'
END

--IF NOT EXISTS( 
--	SELECT 1
--	FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
--	INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu ON tc.TABLE_NAME = ccu.TABLE_NAME
--		AND tc.Constraint_name = ccu.Constraint_name    
--        AND tc.CONSTRAINT_TYPE = 'UNIQUE'
--        AND tc.Table_Name = 'alert_actions'
--		AND	tc.CONSTRAINT_NAME = 'uc_alert_actions'
--)
--BEGIN
--	ALTER TABLE [dbo].alert_actions WITH NOCHECK 
--	ADD CONSTRAINT [uc_alert_actions] UNIQUE (alert_id, table_id, column_id, condition_id, data_source_column_id)
--	PRINT 'Unique constraint added'
--END
--ELSE
--BEGIN
--	PRINT 'Already Added'
--END

--GO