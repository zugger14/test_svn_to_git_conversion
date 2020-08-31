IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102900)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10102900,'Manage Documents','Manage Documents','10100000','','windowManageDocuments')

	PRINT ' 10102900 INSERTED'
END

IF NOT EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10102910)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10102910,'Manage Documents IU','Manage Documents IU','10102900','','windowManageDocumentsIU')

	PRINT ' 10102910 INSERTED'
END

IF NOT EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10102911)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10102911,'Delete Documents','Delete Documents','10102900','','')

	PRINT ' 10102911 INSERTED'
END

IF NOT EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10102912)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10102912,'Manage Documents - Email','Manage Documents - Email','10102900','','windowEmail')

	PRINT ' 10102912 INSERTED'
END

IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10232200)
UPDATE application_functional_users SET function_id = 10102900 WHERE function_id = 10232200

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10232200)
DELETE FROM application_functions WHERE function_id = 10232200

IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10232210)
UPDATE application_functional_users SET function_id = 10102910 WHERE function_id = 10232210

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10232210)
DELETE FROM application_functions WHERE function_id = 10232210

IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10232211)
UPDATE application_functional_users SET function_id = 10102911 WHERE function_id = 10232211

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10232211)
DELETE FROM application_functions WHERE function_id = 10232211

IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10232212)
UPDATE application_functional_users SET function_id = 10102912 WHERE function_id = 10232212

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10232212)
DELETE FROM application_functions WHERE function_id = 10232212