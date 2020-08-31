IF OBJECT_ID(N'application_functions', N'U') IS NOT NULL AND COL_LENGTH('application_functions', 'file_path') IS NOT NULL
BEGIN
	UPDATE application_functions 
		SET file_path = '_setup/maintain_static_data/certification.systems.php'
	WHERE function_id = 10101025
END