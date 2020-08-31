IF NOT EXISTS (SELECT 'x' FROM static_data_value WHERE value_id = 731)
BEGIN
	SET IDENTITY_INSERT dbo.static_data_value ON

	INSERT INTO dbo.static_data_value (value_id,
		[type_id],
		code,
		description
		
	) VALUES ( 
	731,725,'Pending Mitigation','The primary Status for the Mitigation Plan Required Activity'
		 ) 

	SET IDENTITY_INSERT dbo.static_data_value OFF	
END
ELSE
	SELECT 'VALUE ID ALREADY EXISTS'
	 