
IF COL_LENGTH('connection_string', 'email_profile') IS NULL 
	ALTER TABLE connection_string ADD email_profile VARCHAR(150)
GO	
UPDATE connection_string SET email_profile = 'TRMTracker Mail'