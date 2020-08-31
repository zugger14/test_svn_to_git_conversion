IF EXISTS(SELECT 1 FROM user_defined_tables WHERE udt_name = 'customer_deals_header_info')
BEGIN
	DECLARE @udt_id INT
	SELECT @udt_id = udt_id 
	FROM user_defined_tables 
	WHERE udt_name = 'customer_deals_header_info'

	IF EXISTS(SELECT 1 FROM user_defined_tables_metadata WHERE column_name = 'hub' AND udt_id = @udt_id)
	BEGIN
	   UPDATE user_defined_tables_metadata 
	   SET column_nullable = 1 
	   WHERE column_name = 'hub' 
		   AND udt_id = @udt_id
	END
END