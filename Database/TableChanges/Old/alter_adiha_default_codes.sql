/*
	Author : Vishwas Khanal 
	Dated	 : 23.March.2009
	CR		 : 19March2009
	RCN		 : 10
*/
IF NOT EXISTS(SELECT 'x' FROM dbo.adiha_default_codes WHERE  default_code_id = 26)
BEGIN

	INSERT INTO dbo.adiha_default_codes
	(
		default_code_id	,	default_code	  ,
		code_description,	code_def		  ,
		instances
	)
	VALUES
	(
		26				,	'system_formula'  ,
		'System Formula',	'System Formula'				  ,
		1
	)
END

GO

IF NOT EXISTS (SELECT 'x' FROM dbo.adiha_default_codes_params WHERE default_code_id = 26)
BEGIN
	INSERT INTO dbo.adiha_default_codes_params 
	(
		seq_no			,	default_code_id	  ,
		var_name		,	type_id			  ,
		var_length		,	value_type
	)
	VALUES
	(
		1				,	26				  ,
		'System Formula',	3				  ,
		NULL			,  'h'
	)
END

GO

IF NOT EXISTS (SELECT 'x' FROM dbo.adiha_default_codes_values WHERE default_code_id = 26)
BEGIN
	INSERT INTO dbo.adiha_default_codes_values 
	(
		instance_no		,	default_code_id	  ,
		seq_no			,	var_value		  ,
		description
	)
	VALUES
	(
		1				,	26				  ,
		1				,	1				  ,
		'System Formula'
	)
END
