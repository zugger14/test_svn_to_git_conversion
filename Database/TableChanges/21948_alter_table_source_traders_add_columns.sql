IF COL_LENGTH('source_traders', 'country_id') IS NULL
BEGIN
    ALTER TABLE source_traders ADD country_id INT
END
GO

IF COL_LENGTH('source_traders', 'date_of_birth') IS NULL
BEGIN
    ALTER TABLE source_traders ADD date_of_birth DATETIME
END
GO

IF COL_LENGTH('source_traders', 'last_name') IS NULL
BEGIN
    ALTER TABLE source_traders ADD last_name varchar(100)
END
GO

IF COL_LENGTH('source_traders', 'national_id') IS NULL
BEGIN	
	ALTER TABLE source_traders ADD national_id VARCHAR(200)
END