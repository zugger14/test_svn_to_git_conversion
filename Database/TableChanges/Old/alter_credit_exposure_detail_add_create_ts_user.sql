IF COL_LENGTH('credit_exposure_detail', 'create_user') IS NULL
BEGIN
	ALTER TABLE credit_exposure_detail ADD create_user VARCHAR(50) NULL DEFAULT dbo.FNADBUser()	
END

IF COL_LENGTH('credit_exposure_detail', 'create_ts') IS NULL
BEGIN
	ALTER TABLE credit_exposure_detail ADD create_ts DATETIME NULL DEFAULT GETDATE()
END