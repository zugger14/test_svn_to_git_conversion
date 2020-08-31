/* Added By Pawan Adhikari, 03/24/2011 */ 
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102811)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102811,'Delete Setup Profile','Delete Setup Profile',10102800,'')
	PRINT '10102811 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102511)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102511,'Delete Setup Location','Delete Setup Location',10102500,'')
	PRINT '10102511 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102512)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102512,'Meter Data IU','Meter Data IU',10102510,'')
	PRINT '10102512 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102513)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102513,'Delete Meter Data','Delete Meter Data',10102510,'')
	PRINT '10102513 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102611)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102611,'Delete Setup Price Curves','Delete Setup Price Curves',10102600,'')
	PRINT '10102611 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102612)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102612,'Source Curve Def Privileges IU','Source Curve Def Privileges IU',10102610,'')
	PRINT '10102612 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102613)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102613,'Delete Source Curve Def Privileges IU','Delete Source Curve Def Privileges IU',10102610,'')
	PRINT '10102613 INSERTED'
END


IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102614)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102614,'Source Curve Time Bucket Mapping IU','Source Curve Time Bucket Mapping IU',10102610,'')
	PRINT '10102614 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102615)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102615,'Delete Source Curve Time Bucket Mapping','Delete Source Curve Time Bucket Mapping',10102610,'')
	PRINT '10102615 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102616)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102616,'Source Curve Fair Value Reporting IU','Source Curve Fair Value Reporting IU',10102610,'')
	PRINT '10102616 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102617)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102617,'Delete Source Curve Fair Value Reporting IU','Delete Source Curve Fair Value Reporting IU',10102610,'')
	PRINT '10102617 INSERTED'
END
/* By Pawan Adhikari END */


/* Delete the Previous FunctionIDS */
IF EXISTS(SELECT 'x' fROM application_functional_users WHERE function_id = 10101139)
BEGIN
	UPDATE application_functional_users	SET function_id = 10102510 WHERE  function_id = 10101139	
END

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101139)
	DELETE FROM application_functions WHERE function_id = 10101139

IF EXISTS(SELECT 'x' fROM application_functional_users WHERE function_id = 10101169)
BEGIN
	UPDATE application_functional_users SET function_id = 10102511 WHERE  function_id = 10101169	
END

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101169)
	DELETE FROM application_functions WHERE function_id = 10101169

IF EXISTS(SELECT 'x' fROM application_functional_users WHERE function_id = 10101140)
BEGIN
	UPDATE application_functional_users SET function_id = 10102512 WHERE  function_id = 10101140	
END

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101140)
	DELETE FROM application_functions WHERE function_id = 10101140

IF EXISTS(SELECT 'x' fROM application_functional_users WHERE function_id = 10101141)
BEGIN
	UPDATE application_functional_users SET function_id = 10102513 WHERE  function_id = 10101141	
END

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101141)
	DELETE FROM application_functions WHERE function_id = 10101141

IF EXISTS(SELECT 'x' fROM application_functional_users WHERE function_id = 10101130)
BEGIN
	UPDATE application_functional_users SET function_id = 10102610 WHERE  function_id = 10101130	
END

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101130)
	DELETE FROM application_functions WHERE function_id = 10101130

IF EXISTS(SELECT 'x' fROM application_functional_users WHERE function_id = 10101164)
BEGIN
	UPDATE application_functional_users SET function_id = 10102611 WHERE  function_id = 10101164	
END

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101164)
	DELETE FROM application_functions WHERE function_id = 10101164

IF EXISTS(SELECT 'x' fROM application_functional_users WHERE function_id = 10101131)
BEGIN
	UPDATE application_functional_users SET function_id = 10102612 WHERE  function_id = 10101131	
END

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101131)
	DELETE FROM application_functions WHERE function_id = 10101131

IF EXISTS(SELECT 'x' fROM application_functional_users WHERE function_id = 10101132)
BEGIN
	UPDATE application_functional_users SET function_id = 10102613 WHERE  function_id = 10101132	
END

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101132)
	DELETE FROM application_functions WHERE function_id = 10101132

IF EXISTS(SELECT 'x' fROM application_functional_users WHERE function_id = 10101133)
BEGIN
	UPDATE application_functional_users SET function_id = 10102614 WHERE  function_id = 10101133
END

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101133)
	DELETE FROM application_functions WHERE function_id = 10101133

IF EXISTS(SELECT 'x' fROM application_functional_users WHERE function_id = 10101134)
BEGIN
	UPDATE application_functional_users SET function_id = 10102615 WHERE  function_id = 10101134
END

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101134)
	DELETE FROM application_functions WHERE function_id = 10101134

IF EXISTS(SELECT 'x' fROM application_functional_users WHERE function_id = 10101153)
BEGIN
	UPDATE application_functional_users SET function_id = 10102616 WHERE  function_id = 10101153
END

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101153)
	DELETE FROM application_functions WHERE function_id = 10101153

IF EXISTS(SELECT 'x' fROM application_functional_users WHERE function_id = 10101154)
BEGIN
	UPDATE application_functional_users SET function_id = 10102617 WHERE  function_id = 10101154
END

IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101154)
	DELETE FROM application_functions WHERE function_id = 10101154


