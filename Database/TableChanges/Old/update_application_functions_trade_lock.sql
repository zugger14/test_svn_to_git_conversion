IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101900)
UPDATE application_functions SET function_name ='Setup Logical Trade Lock',function_desc = 'Setup Logical Trade Lock' 
WHERE function_id = 10101900 

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101910)
UPDATE application_functions SET function_name ='Logical Trade Lock IU',function_desc = 'Logical Trade Lock IU' 
WHERE function_id = 10101910 

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101911)
UPDATE application_functions SET function_name ='Delete Logical Trade Lock',function_desc = 'Delete Logical Trade Lock' 
WHERE function_id = 10101911

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10131300)
UPDATE application_functions SET function_name ='Import Data',function_desc = 'Import Data' 
WHERE function_id = 10131300


IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131600)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10131600,'Transfer Book Position','Transfer Book Position','10130000','','')

	PRINT ' 10131600 INSERTED'
END


IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10141800)
UPDATE application_functional_users SET function_id = 10131600 WHERE function_id = 10141800

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10141800)
DELETE FROM application_functions WHERE function_id = 10141800
 
 
 
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10142000)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10142000,'Run Power Position Report','Run Power Position Report','10140000','','')

	PRINT ' 10142000 INSERTED'
END

IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10161900)
UPDATE application_functional_users SET function_id = 10142000 WHERE function_id = 10161900

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10161900)
DELETE FROM application_functions WHERE function_id = 10161900

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10182300)
UPDATE application_functions SET function_name ='Financial Forecast Model',function_desc = 'Financial Forecast Model' 
WHERE function_id = 10182300

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10182310)
UPDATE application_functions SET function_name ='Financial Forecast Model Header IU',function_desc = 'Financial Forecast Model Header IU' 
WHERE function_id = 10182310

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10182311)
UPDATE application_functions SET function_name ='Delete Financial Forecast Model Header',function_desc = 'Delete Financial Forecast Model Header' 
WHERE function_id = 10182311

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10182312)
UPDATE application_functions SET function_name ='Financial Forecast Model Detail IU',function_desc = 'Financial Forecast Model Detail IU' 
WHERE function_id = 10182312

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10182313)
UPDATE application_functions SET function_name ='Delete Financial Forecast Model Detail',function_desc = 'Delete Financial Forecast Model Detail' 
WHERE function_id = 10182313

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10182400)
UPDATE application_functions SET function_name ='Run Financial Forecast Report',function_desc = 'Run Financial Forecast Report' 
WHERE function_id = 10182400

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10182510)
UPDATE application_functions SET func_ref_id = 10182600 
WHERE function_id = 10182510

IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10182500)
UPDATE application_functional_users SET function_id = 10182600 WHERE function_id = 10182500

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10182500)
DELETE FROM application_functions WHERE function_id = 10182500
