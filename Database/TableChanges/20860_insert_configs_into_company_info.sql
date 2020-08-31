IF NOT EXISTS(SELECT 1 FROM company_info)
BEGIN
	DECLARE @client_code VARCHAR(64)
	DECLARE @client_name VARCHAR(64)
	DECLARE @db_name VARCHAR(128) = DB_NAME()
	SELECT @client_code = UPPER(SUBSTRING(@db_name, 12, LEN(@db_name) - 11))
	SET @client_name = @client_code

	INSERT INTO company_info(company_name, company_code, country)
	SELECT @client_name, @client_code, 'US'
END