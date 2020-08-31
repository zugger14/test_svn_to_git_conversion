IF COL_LENGTH('connection_string','otp_expiry_days') IS NULL
BEGIN
	ALTER TABLE connection_string
	ADD otp_expiry_days INT
END