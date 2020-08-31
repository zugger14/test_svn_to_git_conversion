IF NOT EXISTS(Select 1 from adiha_default_codes Where default_code_id = 85)
BEGIN 
	INSERT INTO adiha_default_codes(default_code_id,default_code,code_description,code_def,instances)
	SELECT  85,'PNL_Explain','PNL Explain','PNL explain',2
END
ELSE 
PRINT 'default code ID:85 already exists'


IF NOT EXISTS(Select 1 FROM adiha_default_codes_values_possible WHERE default_code_id = 85)
BEGIN
	INSERT INTO adiha_default_codes_values_possible(default_code_id,var_value,description)
	SELECT 85,0,'not included'
	UNION 
	SELECT 85,1,'included'
	UNION 
	SELECT 85,2,'both'
END
ELSE 
	PRINT 'Default code ID:already exists'


IF NOT EXISTS(Select 1 FROM adiha_default_codes_params WHERE default_code_id = 85)
BEGIN
INSERT into adiha_default_codes_params(seq_no,default_code_id,var_name,type_id,var_length,value_type)
Select '1',85,'Not Included',3,NULL,'h'
UNION
SELECT '2',85,'Included',3,NULL,'h'
UNION
SELECT '3',85,'BOTH',3,NULL,'h'
END
ELSE 
	PRINT 'Default code ID:already exists'

IF NOT EXISTS(Select 1 FROM adiha_default_codes_values WHERE default_code_id = 85)
BEGIN
	INSERT INTO adiha_default_codes_values
	SELECT 1,85,1,2,'both'
	
END
ELSE 
	PRINT 'Default code ID:already exists'


	
	