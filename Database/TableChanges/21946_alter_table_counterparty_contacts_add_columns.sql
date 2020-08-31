IF COL_LENGTH (N'counterparty_contacts', N'last_name') IS NULL
BEGIN
	ALTER TABLE counterparty_contacts ADD last_name VARCHAR(250)
END

IF COL_LENGTH (N'counterparty_contacts', N'date_of_birth') IS NULL
BEGIN
	ALTER TABLE counterparty_contacts ADD date_of_birth VARCHAR(250)
END

IF COL_LENGTH (N'counterparty_contacts', N'national_id') IS NULL
BEGIN
	ALTER TABLE counterparty_contacts ADD national_id VARCHAR(200)
END