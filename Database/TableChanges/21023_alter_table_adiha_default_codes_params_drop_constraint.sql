IF EXISTS(
	SELECT 1
    FROM sys.foreign_keys 
    WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FK_adiha_default_codes_params_adiha_data_type_name]')
		AND parent_object_id = OBJECT_ID(N'[dbo].[adiha_default_codes_params]')
)
BEGIN
	ALTER TABLE adiha_default_codes_params 
	DROP CONSTRAINT FK_adiha_default_codes_params_adiha_data_type_name
END 

IF EXISTS(
	SELECT 1
	FROM sys.foreign_keys
	WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FK_adiha_default_codes_values_adiha_default_codes_params]')
		AND parent_object_id = OBJECT_ID(N'[dbo].[adiha_default_codes_values]')
)			 
BEGIN
	ALTER TABLE adiha_default_codes_values 
	DROP CONSTRAINT FK_adiha_default_codes_values_adiha_default_codes_params
END

GO