/* --- added All function _id for Reporting FX-----
--DELETE FROM application_functions  WHERE function_id in (10201610,10201611,10201612,10201600)
--Rabindra giri
-- */

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201600)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201600, 'Report Manager', 'Report Manager', 10200000, 'windowReportManager')
 	PRINT ' Inserted 10201600 - Report Manager.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201600 - Report Manager already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201610)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201610, 'Report Manager IU', 'Report Manager IU', 10201600, 'windowReportMaker')
 	PRINT ' Inserted 10201610 - Report Manager IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201610 - Report Manager IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201611)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201611, 'Report Manager Delete', 'Report Manager Delete', 10201600, NULL)
 	PRINT ' Inserted 10201611 - Report Manager Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201611 - Report Manager Delete already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201612)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201612, 'Report Manager Privilege', 'Report Manager Privilege', 10201600, NULL)
 	PRINT ' Inserted 10201612 - Report Manager Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201612 - Report Manager Privilege already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201613)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201613, 'Report Manager Export Type', 'Report Manager Export Type', 10201600, NULL)
 	PRINT ' Inserted 10201613 - Report Manager Export Type.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201613 - Report Manager Export Type already EXISTS.'
END

-----report maker----
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201614)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201614, 'Report Maker Insert', 'Report Maker Insert', 10201610, NULL)
 	PRINT ' Inserted 10201614 - Report Maker Insert.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201614 - Report Maker Insert already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201615)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201615, 'Report Maker Dataset IU', 'Report Maker Dataset IU', 10201610, 'windowReportDatasetIU')
 	PRINT ' Inserted 10201615 - Report Maker Dataset IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201615 - Report Maker Dataset IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201616)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201616, 'Report Maker Dataset Delete', 'Report Maker Dataset Delete', 10201610, NULL)
 	PRINT ' Inserted 10201616 - Report Maker Dataset Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201616 - Report Maker Dataset Delete already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201617)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201617, 'Report Maker page IU', 'Report Maker page IU', 10201610, 'windowReportpageIU')
 	PRINT ' Inserted 10201617 - Report Maker page IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201617 - Report Maker page IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201618)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201618, 'Report Maker page Delete', 'Report Maker page Delete', 10201610, NULL)
 	PRINT ' Inserted 10201618 - Report Maker page Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201618 - Report Maker page Delete already EXISTS.'
END
--dataset iu --
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201619)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201619, 'Report Dataset IU save', 'Report Dataset IU save', 10201615, NULL)
 	PRINT ' Inserted 10201619 - Report Dataset IU save.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201619 - Report Dataset IU save already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201620)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201620, 'Report Dataset IU IU', 'Report Dataset IU IU', 10201615, NULL)
 	PRINT ' Inserted 10201620 - Report Dataset IU IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201620 - Report Dataset IU IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201621)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201621, 'Report Dataset IU Delete', 'Report Dataset IU Delete', 10201615, NULL)
 	PRINT ' Inserted 10201621 - Report Dataset IU Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201621 - Report Dataset IU Delete already EXISTS.'
END
--page iu--
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201622)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201622, 'Report page Parameterset IU', 'Report page Parameterset IU', 10201617, 'windowReportParamset')
 	PRINT ' Inserted 10201622 - Report page Parameterset IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201622 - Report page Parameterset IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201623)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201623, 'Report page Parameterset Delete', 'Report page Parameterset Delete', 10201617, NULL)
 	PRINT ' Inserted 10201623 - Report page Parameterset Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201623 - Report page Parameterset Delete already EXISTS.'
END
/**
* inserting function ID for report manager view and report manager view IU.
* 8/29/2012
* sangam ligal.
**/
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201633)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201633, 'Report Manager View', 'Report Manager View', 10201000, NULL)
 	PRINT ' Inserted 10201633 - Report Manager View.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201633 - Report Manager View already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201634)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201634, 'Report Manager View IU', 'Report Manager View IU', 10201000, NULL)
 	PRINT ' Inserted 10201634 - Report Manager View IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201634 - Report Manager View IU already EXISTS.'
END


/** inserting function ID for report manager datasource list 
* sligal
* 9/18/2012**/
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201624)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201624, 'Report Manager Datasource List', 'Report Manager Datasource List', 10201600, 'windowReportManagerDatasourceList')
 	PRINT ' Inserted 10201624 - Report Manager Datasource List.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201624 - Report Manager Datasource List already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201625)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201625, 'Report Manager Datasource List IU', 'Report Manager Datasource Form IU', 10201624, 'windowReportManagerDatasourceListIU')
 	PRINT ' Inserted 10201625 - Report Manager Datasource List IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201625 - Report Manager Datasource List IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201626)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201626, 'Report Manager Datasource List Del', 'Report Manager Datasource List Del', 10201624, 'windowReportManagerDatasourceListDel')
 	PRINT ' Inserted 10201626 - Report Manager Datasource List Del.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201626 - Report Manager Datasource List Del already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201627)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201627, 'Report Manager Datasource Form Columns', 'Report Manager Datasource Form Columns', 10201625, 'windowReportManagerDatasourceFormColumns')
 	PRINT ' Inserted 10201627 - Report Manager Datasource Form Columns.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201627 - Report Manager Datasource Form Columns already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201628)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201628, 'Report Dataset IU Relationship', 'Report Dataset IU Relationship', 10201615, 'windowReportDatasetRelationshipIU')
 	PRINT ' Inserted 10201628 - Report Dataset IU Relationship.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201628 - Report Dataset IU Relationship already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201629)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201629, 'Report Page Chart IU', 'Report Page Chart IU', 10201617, 'windowReportPageChart')
 	PRINT ' Inserted 10201629 - Report Page Chart IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201629 - Report Page Chart IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201630)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201630, 'Report Page Chart Delete', 'Report Page Chart Delete', 10201617, NULL)
 	PRINT ' Inserted 10201630 - Report Page Chart Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201630 - Report Page Chart Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201631)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201631, 'Report Page Tablix IU', 'Report Page Tablix IU', 10201617, 'windowReportPageTablix')
 	PRINT ' Inserted 10201631 - Report Page Tablix IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201631 - Report Page Tablix IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201632)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201632, 'Report Page Tablix Delete', 'Report Page Tablix Delete', 10201617, NULL)
 	PRINT ' Inserted 10201632 - Report Page Tablix Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201632 - Report Page Tablix Delete already EXISTS.'
END

/**
* sligal
* add application function id for 'Report Paramset Privilege' for new Reporting.
* 6/4/2013
**/
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201638)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201638, 'Report Paramset Privilege', 'Report Paramset Privilege', 10201600, 'windowReportManagerParamsetPrivileges')
 	PRINT ' Inserted 10201638 - Report Paramset Privilege.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201638 - Report Paramset Privilege already EXISTS.'
END
/**
* sligal
* add application function id for 'Report Manager Privilege Detail' for new Reporting.
* 24 feb 2014
**/
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201639)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10201639, 'Report Manager Privilege Detail', 'Report Manager Privilege Detail', 10201600, 'windowReportManagerPrivilegeDetail')
 	PRINT ' Inserted 10201639 - Report Manager Privilege Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10201639 - Report Manager Privilege Detail already EXISTS.'
END






