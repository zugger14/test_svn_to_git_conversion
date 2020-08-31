IF COL_LENGTH('archive_data_policy', 'tran_status') IS NULL
BEGIN    
	ALTER TABLE archive_data_policy 
	ADD  tran_status VARCHAR(1) DEFAULT 'C'
END
GO
