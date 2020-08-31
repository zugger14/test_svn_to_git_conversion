--This adds contraint that confirms unique limit.
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='dbo' AND CONSTRAINT_NAME='unique_limit' AND TABLE_NAME='counterparty_limits')
IF EXISTS(SELECT DISTINCT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'counterparty_limits' AND COLUMN_NAME IN ('limit_type'))
	BEGIN 
	
		ALTER TABLE counterparty_limits
		ADD CONSTRAINT unique_limit
		UNIQUE (limit_type, applies_to, volume_limit_type, counterparty_id,internal_rating_id,bucket_detail_id) 

		print 'Contstraint unique_limit added.'

	END