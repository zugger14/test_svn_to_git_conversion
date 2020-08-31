/* Vishwas Khanal || 30.March.2009 */
/* Description : Compliance Reports */

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 531)
	print 'Function Id 531 already Exists'
ELSE
	INSERT INTO application_functions (function_id,function_name,function_desc,function_call)
		VALUES (531,'Run Compliance Activity Audit Report','Run Compliance Activity Audit Report','windowPositionGas')

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 532)
	print 'Function Id 532 already Exists'
ELSE
	INSERT INTO application_functions (function_id,function_name,function_desc,function_call)
		VALUES (532,'Run Compliance Trend Report','Run Compliance Trend Report','windowPositionGas')

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 533)
	print 'Function Id 533 already Exists'
ELSE
	INSERT INTO application_functions (function_id,function_name,function_desc,function_call)
		VALUES (533,'Run Compliance Graph Report','Run Compliance Graph Report','windowPositionGas')

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 534)
	print 'Function Id 534 already Exists'
ELSE
	INSERT INTO application_functions (function_id,function_name,function_desc,function_call)
		VALUES (534,'Run Compliance Status Graph Report','Run Compliance Status Graph Report','windowPositionGas')

/* Vishwas Khanal || 20.March.2009 */
/* Description : Position Report Development for Gas/Oil/Electricity */


IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 418)
	print 'Function Id 418 already Exists'
ELSE
	INSERT INTO application_functions (function_id,function_name,function_desc,function_call)
		VALUES (418,'Run Position Report','Position Report for Gas,Oil and Electricity','windowPositionGas')

/*Prakash Poudel || 29th April 2009*/
/*Description: Maintain Compliance Activity Dependency*/
if exists(select 'X' from application_functions where function_id=526)
	print '526 exist'
else
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
		values(526,'Maintain Compliance Activity Dependency','Maintain Compliance Activity Dependency',null,null)
if exists(select 'X' from application_functions where function_id=527)
	print '527 exist'
else
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(527,'Insert Compliance Activity Dependency','Insert Compliance Activity Dependency',526,'WindowCompActivityDependencyGrid')
if exists(select 'X' from application_functions where function_id=528)
	print '528 exist'
else
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(528,'Update Compliance Activity Dependency','Update Compliance Activity Dependency',526,null)
if exists(select 'X' from application_functions where function_id=529)
	print '529 exist'
else
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(529,'Delete Compliance Activity Dependency','Delete Compliance Activity Dependency',526,null)
if exists(select 'X' from application_functions where function_id=530)
	print '530 exist'
else
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call)values(530,'View Status on Compliance Activities','View Status on Compliance Activities',null,null)

