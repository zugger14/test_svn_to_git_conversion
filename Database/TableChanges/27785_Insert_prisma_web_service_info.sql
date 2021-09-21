--IF NOT EXISTS (
--		SELECT 1
--		FROM INFORMATION_SCHEMA.COLUMNS
--		WHERE TABLE_NAME = 'import_web_service'
--			AND COLUMN_NAME = 'password'
--		) 
--BEGIN
   ALTER TABLE import_web_service ALTER COLUMN [password] varbinary (1000) 
--END

/**
 Setup script for Prisma import from CLR.
*/
--script 1
IF NOT EXISTS (SELECT 1 FROM ixp_clr_functions where ixp_clr_functions_name = 'Prisma')
BEGIN
	INSERT INTO ixp_clr_functions (ixp_clr_functions_name, method_name, description)
	SELECT 'Prisma', 'PrismaImporter', 'Prisma Shipper Importer Method'
END 
ELSE 
BEGIN
	UPDATE ixf
	SET ixf.ixp_clr_functions_name = 'Prisma'
		, ixf.method_name = 'PrismaImporter'
		, ixf.description = 'Prisma Shipper Importer Method'
	FROM ixp_clr_functions ixf
	WHERE ixp_clr_functions_name = 'Prisma'
END


--Script 2
IF NOT EXISTS (
		SELECT 1
		FROM import_web_service iws
		INNER JOIN ixp_clr_functions icf
			ON iws.clr_function_id = icf.ixp_clr_functions_id
		WHERE icf.ixp_clr_functions_name = 'Prisma'
		)
BEGIN
	INSERT INTO import_web_service (
		  ws_name
		, web_service_url
		, [user_name]
		, [password]
		, clr_function_id
		)
	SELECT 'Prisma'
		, 'https://platform.prisma-capacity.eu/api/v2/auction-booking'
		, 'PrismaApi'
		, dbo.FNAEncrypt('eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIzMjc3NDAyOTM4MSIsImF1ZCI6InNoaXBwZXItYXBpIiwibnVtYmVyIjoiMSIsImNyZWF0ZWQiOjE2MjQ1Mjc4MDgyMDMsInJvbGVzIjpbIlJPTEVfU0hJUFBFUl9BUElfVVNFUiJdfQ.JaeecDJ87Ke7noo0UdagGnbEGYLQeRNks1l7LuPCul96lpheZNvjdoaN3ZbpHk30-C1H3Ch2BXBG_8qzhususQ')
 	    , icf.ixp_clr_functions_id
	FROM ixp_clr_functions icf
	WHERE icf.ixp_clr_functions_name = 'Prisma'
END
ELSE
BEGIN
	UPDATE iws
	SET iws.ws_name = 'Prisma'
		, iws.web_service_url =  'https://platform.prisma-capacity.eu/api/v2/auction-booking'
		, iws.[user_name] =  'RestApi'
		, iws.[password] = dbo.FNAEncrypt('eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIzMjc3NDAyOTM4MSIsImF1ZCI6InNoaXBwZXItYXBpIiwibnVtYmVyIjoiMSIsImNyZWF0ZWQiOjE2MjQ1Mjc4MDgyMDMsInJvbGVzIjpbIlJPTEVfU0hJUFBFUl9BUElfVVNFUiJdfQ.JaeecDJ87Ke7noo0UdagGnbEGYLQeRNks1l7LuPCul96lpheZNvjdoaN3ZbpHk30-C1H3Ch2BXBG_8qzhususQ')
		FROM import_web_service iws
	WHERE ws_name = 'PrismaApi'
END
	
