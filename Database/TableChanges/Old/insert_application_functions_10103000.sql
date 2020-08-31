IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10103000)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10103000,'Define Meter IDs','Define Meter IDs','10100000','','windowDefineMeterID')

	PRINT ' 10103000 INSERTED'
END

IF NOT EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10103010)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10103010,'Meter ID IU','Meter ID IU','10103000','','windowDefineMeterIDIU')

	PRINT ' 10103010 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10103011)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10103011,'Delete Meter ID','Delete Meter ID','10103000','','')

	PRINT ' 10103011 INSERTED'
END

IF NOT EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10103012)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10103012,'Meter ID Allocation IU','Meter ID Allocation IU','10103000','','windowDefineMeterIDallocation')

	PRINT ' 10103012 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10103013)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10103013,'Delete Meter ID Allocation','Delete Meter ID Allocation','10103000','','')

	PRINT ' 10103013 INSERTED'
END

IF NOT EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10103014)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10103014,'Define Meter Channel','Define Meter Channel','10103000','','windowDefineChannel')

	PRINT ' 10103014 INSERTED'
END


IF NOT EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10103015)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10103015,'Meter IDs Properties','Meter IDs Properties','10103000','','windowDefineMeterIDProperties')

	PRINT ' 10103015 INSERTED'
END

IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10221500)
UPDATE application_functional_users SET function_id = 10103000 WHERE function_id = 10221500

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10221500)
DELETE FROM application_functions WHERE function_id = 10221500

IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10221510)
UPDATE application_functional_users SET function_id = 10103010 WHERE function_id = 10221510

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10221510)
DELETE FROM application_functions WHERE function_id = 10221510

IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10221511)
UPDATE application_functional_users SET function_id = 10103011 WHERE function_id = 10221511

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10221511)
DELETE FROM application_functions WHERE function_id = 10221511

IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10221512)
UPDATE application_functional_users SET function_id = 10103012 WHERE function_id = 10221512

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10221512)
DELETE FROM application_functions WHERE function_id = 10221512

IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10221513)
UPDATE application_functional_users SET function_id = 10103013 WHERE function_id = 10221513

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10221513)
DELETE FROM application_functions WHERE function_id = 10221513

IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10221514)
UPDATE application_functional_users SET function_id = 10103014 WHERE function_id = 10221514

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10221514)
DELETE FROM application_functions WHERE function_id = 10221514

IF EXISTS(SELECT  'x' fROM    application_functional_users WHERE function_id = 10221515)
UPDATE application_functional_users SET function_id = 10103015 WHERE function_id = 10221515

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10221515)
DELETE FROM application_functions WHERE function_id = 10221515