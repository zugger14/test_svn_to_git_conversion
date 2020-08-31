IF NOT EXISTS(SELECT 1 FROM delivery_path WHERE path_id = -99)
BEGIN
	SET IDENTITY_INSERT dbo.delivery_path ON;

	INSERT INTO delivery_path( 
				path_id
				,path_code
				,path_name
				,isactive
				,groupPath
		)
	SELECT 
		-99 path_id
		, 'Bookout Path' path_code
		, 'Bookout Path' path_name
		, 'n' isactive
		,'n' groupPath

	SET IDENTITY_INSERT dbo.delivery_path OFF;

END

DELETE contract_group where contract_id = -99

