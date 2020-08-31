IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'rec_generator' and COLUMN_NAME = 'reporting_fax')
BEGIN
	ALTER TABLE rec_generator ADD reporting_fax VARCHAR(100)
END

IF NOT EXISTS(SELECT * FROM information_schema.columnS WHERE table_name = 'rec_generator' AND column_name = 'fac_address_2')
BEGIN
	ALTER TABLE rec_generator ADD fac_address_2 VARCHAR(2500)
END

IF NOT EXISTS(SELECT 1 FROM information_schema.columnS WHERE table_name = 'rec_generator' AND column_name = 'fac_city')
BEGIN
	ALTER TABLE rec_generator ADD fac_city VARCHAR(500)
END

IF NOT EXISTS(SELECT 1 FROM information_schema.columnS WHERE table_name = 'rec_generator' AND column_name = 'fa_zip')
BEGIN
	ALTER TABLE rec_generator ADD fa_zip VARCHAR(500)
END

IF NOT EXISTS(SELECT 1 FROM information_schema.columnS WHERE table_name = 'rec_generator' AND column_name = 'fac_zip')
BEGIN
	ALTER TABLE rec_generator ADD fac_zip VARCHAR(500)
END

IF NOT EXISTS(SELECT 1 FROM information_schema.columnS WHERE table_name = 'rec_generator' AND column_name = 'fac_state')
BEGIN
	ALTER TABLE rec_generator ADD fac_state VARCHAR(500)
END