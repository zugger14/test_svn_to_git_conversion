IF EXISTS (
		SELECT 1
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'import_web_service'
			AND COLUMN_NAME = 'password'
		) 
BEGIN
   ALTER TABLE import_web_service ALTER COLUMN [password] varbinary (1000) 
END

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
		, 'https://platform.prisma-capacity.eu/api/v2/auction-booking' -- TO Update API URL
		, 'PrismaApi'
		, dbo.FNAEncrypt('eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI5ODMxNSIsImF1ZCI6InNoaXBwZXItYXBpIiwibnVtYmVyIjoiNCIsImNyZWF0ZWQiOjE2MjczOTU1NjE4MTcsInJvbGVzIjpbIlJPTEVfU0hJUFBFUl9BUElfVVNFUiJdfQ.NLeONuLtnrUIQagcQjbylHanLGYVInHufAKFmQ18lz8vIXdyxUtk_v6UatOXfzC7Bo7jF0awk6wOtaxH6G-KJw') -- TO Update API PW
 	    , icf.ixp_clr_functions_id
	FROM ixp_clr_functions icf
	WHERE icf.ixp_clr_functions_name = 'Prisma'
END
ELSE
BEGIN
	UPDATE iws
	SET  iws.web_service_url =  'https://platform.prisma-capacity.eu/api/v2/auction-booking' --TO DO UPdate API URL
		, iws.[user_name] =  'PrismaApi'
		, iws.[password] = dbo.FNAEncrypt('eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiI5ODMxNSIsImF1ZCI6InNoaXBwZXItYXBpIiwibnVtYmVyIjoiNCIsImNyZWF0ZWQiOjE2MjczOTU1NjE4MTcsInJvbGVzIjpbIlJPTEVfU0hJUFBFUl9BUElfVVNFUiJdfQ.NLeONuLtnrUIQagcQjbylHanLGYVInHufAKFmQ18lz8vIXdyxUtk_v6UatOXfzC7Bo7jF0awk6wOtaxH6G-KJw') --TO DO Update API PW
		FROM import_web_service iws
	WHERE ws_name = 'Prisma'
END


DECLARE @ixp_clr_functions_id INT

SELECT @ixp_clr_functions_id = ixp_clr_functions_id 
FROM ixp_clr_functions 
WHERE method_name  = 'PrismaImporter'

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_auctionId' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value)
	SELECT 'PS_auctionId' --parameter_name
	, 'Auction Id' -- parameter_label
	, 1	 -- operator_id
	, 'input' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, NULL --validation_message
	, 'N' -- insert_required
	, NULL -- default_value

END

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_bookedAt' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value)
	SELECT 'PS_bookedAt' --parameter_name
	, 'Booked At' -- parameter_label
	, 1	 -- operator_id
	, 'calendar' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, NULL --validation_message
	, 'N' -- insert_required
	, NULL -- default_value

END

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_bookedSince' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value)
	SELECT 'PS_bookedSince' --parameter_name
	, 'Booked Since' -- parameter_label
	, 1	 -- operator_id
	, 'calendar' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, NULL --validation_message
	, 'N' -- insert_required
	, NULL -- default_value

END

IF NOT EXISTS(SELECT 1 FROM ixp_parameters where parameter_name = 'PS_bookedBefore' and clr_function_id = @ixp_clr_functions_id)
BEGIN
	INSERT INTO ixp_parameters(parameter_name, parameter_label, operator_id, field_type,  clr_function_id, validation_message, insert_required, default_value)
	SELECT 'PS_bookedBefore' --parameter_name
	, 'Booked Before' -- parameter_label
	, 1	 -- operator_id
	, 'calendar' -- field_type
	, @ixp_clr_functions_id -- clr_function_id
	, NULL --validation_message
	, 'N' -- insert_required
	, NULL -- default_value

END


	
