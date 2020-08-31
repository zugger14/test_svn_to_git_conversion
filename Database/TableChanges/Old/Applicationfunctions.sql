
/*Prepared by : Vishwas 
  Dated : 25. May.2009
  Please add your script at the top of the all the scripts after SET NOCOUNT ON (i.e in the stack basis). 
  Check with the existence for every insertion.
***************************************************************
* Modified By :Mukesh Singh
* MOdified Date :11-Sept-2009
* Purpose : FUnction ID allocation for New screen "Tier Type Properties" 
*           in maintain Static Data
*
***************************************************************/
-- select * from application_functions where function_id = '10102000'
--update application_functions set function_call = 'windowSetupTenorGroupDataIU' where  function_id = '10102000'
--update application_functions set function_call = 'windowSetupTenorBucketDataIU' where  function_id = '10102012'
SET NOCOUNT ON

/* Added by Dewanand 11/10/2011*/
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103610)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103610, 'Delete Remove Report', 'Delete Remove Report', 10103600, NULL)
 	PRINT ' Inserted 10103610 - Delete Remove Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103610 - Delete Remove Report already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103600)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103600, 'Remove Data', 'Remove Data', 10100000, 'windowRemoveData')
 	PRINT ' Inserted 10103600 - Remove Data.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103600 - Remove Data already EXISTS.'
END
/* END */


/* Added by Dewanand 09/14/2011*/
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103200)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103200, 'Pratos Mapping', 'Pratos Mapping', 10100000, 'windowPratosMapping')
 	PRINT ' Inserted 10103200 - Pratos Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103200 - Pratos Mapping already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103210)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103210, 'Pratos Mapping index IU', 'Pratos Mapping index IU', 10103200, 'windowPratosMappingIndexIU')
 	PRINT ' Inserted 10103210 - Pratos Mapping index IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103210 - Pratos Mapping index IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103211)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103211, 'Delete Pratos Mapping index', 'Delete Pratos Mapping index', 10103200, NULL)
 	PRINT ' Inserted 10103211 - Delete Pratos Mapping index.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103211 - Delete Pratos Mapping index already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103220)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103220, 'Pratos Mapping Book IU', 'Pratos Mapping Book IU', 10103200, 'windowPratosMappingBookIU')
 	PRINT ' Inserted 10103220 - Pratos Mapping Book IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103220 - Pratos Mapping Book IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103221)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103221, 'Delete Pratos Mapping Book', 'Delete Pratos Mapping Book', 10103200, NULL)
 	PRINT ' Inserted 10103221 - Delete Pratos Mapping Book.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103221 - Delete Pratos Mapping Book already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103230)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103230, 'Pratos Mapping Formula IU', 'Pratos Mapping Formula IU', 10103200, 'windowPratosMappingFormulaIU')
 	PRINT ' Inserted 10103230 - Pratos Mapping Formula IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103230 - Pratos Mapping Formula IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10103231)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103231, 'Delete Pratos Mapping Formula', 'Delete Pratos Mapping Formula', 10103200, NULL)
 	PRINT ' Inserted 10103231 - Delete Pratos Mapping Formula.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10103231 - Delete Pratos Mapping Formula already EXISTS.'
END
/*End*/

/* Added by Pawan 08/30/2011 */
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182800)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182800, 'Run MTM Explain Report', 'Run MTM Explain Report', 10180000, 'windowRunMTMExplainReport')
 	PRINT ' Inserted 10182800 - Run MTM Explain Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182800 - Run MTM Explain Report already EXISTS.'
END	
/* End by Pawan */
/*Added by Dewanand Manandhar, 1 september 2011 */
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182514)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182514, 'Maintain What-If scenario Portfolio IU', 'Maintain What-If scenario Portfolio IU', 10182510, 'windowWhatIfScenarioPortfolio')
 	PRINT ' Inserted 10182514 - Maintain What-If scenario Portfolio IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182514 - Maintain What-If scenario Portfolio IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182515)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182515, 'Delete Maintain What-If scenario Portfolio', 'Delete Maintain What-If scenario Portfolio', 10182510, NULL)
 	PRINT ' Inserted 10182515 - Delete Maintain What-If scenario Portfolio.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182515 - Delete Maintain What-If scenario Portfolio already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182516)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182516, 'Maintain What-if Scenario Other Details IU', 'Maintain What-if Scenario Other Details IU', 10182510, 'windowWhatIfScenarioOther')
 	PRINT ' Inserted 10182516 - Maintain What-if Scenario Other Details IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182516 - Maintain What-if Scenario Other Details IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182517)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182517, 'Delete Maintain What-if Scenario Other Details', 'Delete Maintain What-if Scenario Other Details', 10182510, NULL)
 	PRINT ' Inserted 10182517 - Delete Maintain What-if Scenario Other Details.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182517 - Delete Maintain What-if Scenario Other Details already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182518)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182518, 'Maintain What-if scenario builder detail IU', 'Maintain What-if scenario builder detail IU', 10182512, 'windowWhatIfScenarioDetailBuilder')
 	PRINT ' Inserted 10182518 - Maintain What-if scenario builder detail IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182518 - Maintain What-if scenario builder detail IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182519)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182519, 'Delete Maintain What-if scenario builder detail', 'Delete Maintain What-if scenario builder detail', 10182512, NULL)
 	PRINT ' Inserted 10182519 - Delete Maintain What-if scenario builder detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182519 - Delete Maintain What-if scenario builder detail already EXISTS.'
END 

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182520)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182520, 'Delet Manintain Whate-if scenario Deal', 'Delet Manintain Whate-if scenario Deal', 10182510, NULL)
 	PRINT ' Inserted 10182520 - Delet Manintain Whate-if scenario Deal.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182520 - Delet Manintain Whate-if scenario Deal already EXISTS.'
END
 
/*End*/


/*Added by Rigesh Tuladhar, 26 August 2011*/
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162312)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162312, 'Insert Source Book Mapping', 'Insert Source Book Mapping', 10162310, NULL)
 	PRINT ' Inserted 10162312 - Insert Source Book Mapping.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162312 - Insert Source Book Mapping already EXISTS.'
END

/* Added By Dewanand Manandhar, 08/25/2011  */
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182500)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182500, 'Maintain What-If scenario', 'Maintain What-If scenario', 10180000, 'windowWhatIfScenario')
 	PRINT ' Inserted 10182500 - Maintain What-If scenario.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182500 - Maintain What-If scenario already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182510)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182510, 'Maintain What-If scenario Builder', 'Maintain What-If scenario Builder', 10182500, 'windowWhatIfScenarioDetail')
 	PRINT ' Inserted 10182510 - Maintain What-If scenario Builder.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182510 - Maintain What-If scenario Builder already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182511)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182511, 'Delete Maintain What-If scenario', 'Delete Maintain What-If scenario', 10182500, NULL)
 	PRINT ' Inserted 10182511 - Delete Maintain What-If scenario.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182511 - Delete Maintain What-If scenario already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182700)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182700, 'Run What-If Scenario Report', 'Run What-If Scenario Report', 10180000, 'windowWhatIfScenarioReport')
 	PRINT ' Inserted 10182700 - Run What-If Scenario Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182700 - Run What-If Scenario Report already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182512)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182512, 'Maintain What-If scenario Builder IU', 'Maintain What-If scenario Builder IU', 10182510, NULL)
 	PRINT ' Inserted 10182512 - Maintain What-If scenario Builder IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182512 - Maintain What-If scenario Builder IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182513)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182513, 'Delete Maintain What-If scenario Builder IU', 'Delete Maintain What-If scenario Builder IU', 10182510, NULL)
 	PRINT ' Inserted 10182513 - Delete Maintain What-If scenario Builder IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182513 - Delete Maintain What-If scenario Builder IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10181213)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10181213, 'VaR Measurement Criteria Detail IU', 'VaR Measurement Criteria Detail IU', 10181211, NULL)
 	PRINT ' Inserted 10181213 - VaR Measurement Criteria Detail IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10181213 - VaR Measurement Criteria Detail IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182610)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182610, 'Show Plot', 'Show Plot', 10182600, 'windowShowPlot')
 	PRINT ' Inserted 10182610 - Show Plot.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182610 - Show Plot already EXISTS.'
END


/* End */

/* Added by Pawan Adhikari 23/08/2011 */
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10142200)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10142200, 'Run Position Explain Report', 'Run Position Explain Report', 10140000, 'windowRunPositionExplainReport')
 	PRINT ' Inserted 10142200 - Run Position Explain Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10142200 - Run Position Explain Report already EXISTS.'
END	
/* End */

/* Added By Rigesh Tuladhar, 07/22/2011  */
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162301)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
    VALUES (10162301,'Virtual Gas Storage IU','Virtual Gas Storage IU',10162300
)
    PRINT '10162301 INSERTED.'
END
ELSE
BEGIN
    PRINT '10162301 ALREADY EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162311)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
    VALUES (10162311, 'Virtual Gas Storage Delete', 'Virtual Gas Storage Delete', 10162300
)
    PRINT '10162311 INSERTED.'
END
ELSE
BEGIN
    PRINT '10162311 ALREADY EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162310)
BEGIN
    INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
    VALUES (10162310, 'General Asset Information Insert', 'General Asset Information Insert', 10162300)
    PRINT '10162310 INSERTED.'
END
ELSE
BEGIN
    PRINT '10162310 ALREADY EXISTS.'
END

/* Added By Monish Manandhar, 07/22/2011  */

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10142100)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10142100, 'Run FX Exposure Report', 'Run FX Exposure Report', 10140000, 'windowRunFXExposureReport')
 	PRINT ' Inserted 10142100 - Run FX Exposure Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10142100 - Run FX Exposure Report already EXISTS.'
END


/* Added By Pawan Adhikari, 05/12/2011 START */

IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10103100)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103100,'Setup Trayport Term Mapping','Setup Trayport Term Mapping',10100000,'windowSetupTrayportTermMapping')
	PRINT '10103100 INSERTED'
END
ELSE
	PRINT '10103100 Already Exists'

IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10103110)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103110,'Setup Trayport Term Mapping IU','Setup Trayport Term Mapping IU',10103100,'windowSetupTrayportTermMappingIU')
	PRINT '10103110 INSERTED'
END
ELSE
	PRINT '10103110 Already Exists'

IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10103111)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10103111,'Delete Setup Trayport Term Mapping','Delete Setup Trayport Term Mapping',10103100,'')
	PRINT '10103111 INSERTED'
END
ELSE
	PRINT '10103111 Already Exists'
/* End by Pawan Adhikari */

/* Added By Pawan Adhikari, 03/24/2011 START */ 
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


/* Added by Monish[Mar 22 2011 (START) */
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


/* Added by Monish[Mar 21 2011 (START) */
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

/*Added by Poojan Shrestha, 07 Mar 2011*/
IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102800)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102800,'Setup Profile','Setup Profile',10100000,'windowSetupProfile')
	PRINT '10102800 INSERTED'
END

IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102810)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102810,'Setup Profile IU','Setup Profile IU',10102800,'windowSetupProfileIU')
	PRINT '10102810 INSERTED'
END


/*Added by Monish Manandhar, 16 Feb 2011*/
IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102700)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102700,'Archive Data','Archive Data',10100000,'windowSetupArchiveData')
	PRINT '10102700 INSERTED'
END

/*Added by Poojan Shrestha, 15 Feb 2011*/
IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102500)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102500,'Setup Location','Setup Location',10100000,'windowSetupLocation')
	PRINT '10102500 INSERTED'
END

IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102510)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102510,'Setup Location IU','Setup Location IU',10102500,'windowSetupLocationIU')
	PRINT '10102510 INSERTED'
END


--------------------------------------------------------------------------------------------------------

IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102600)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102600,'Setup Price Curves','Setup Price Curves',10100000,'windowSetupPriceCurves')
	PRINT '10102600 INSERTED'
END

IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102610)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102610,'Setup Price Curves IU','Setup Price Curves IU',10102600,'windowSetupPriceCurvesIU')
	PRINT '10102610 INSERTED'
END


/*Added by Monish Manandhar, 5 Jan 2011*/
IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10102400)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102400,'Formula Builder','Formula Builder',10100000,'windowFormulaBuilder')
	PRINT '10102400 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10182500)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10182500,'Calculate Financial Forecast', 'Calculate Financial Forecast', '10182300', 'windowCalculateFinancialForecast')
	PRINT '10182500 INSERTED'
END 

/*Added by Shyam Mishra, October 20 2010. */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 13121200)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(13121200,'Run Hedge Ineffectiveness Report', 'Run Hedge Ineffectiveness Report', '10160000', 'windowRunHedgeIneffectivenessReport')
	PRINT '13121200 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12132300)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(12132300,'Run Imbalance Report', 'Run Imbalance Report', '10160000', 'windowImbalance')
	PRINT '12132300 INSERTED'
END 
/*End by Shyam Mishra, October 20 2010. */

/*Added by Monish Manandhar, August 13 2010. */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 13160000)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(13160000,'Hedging Relationship Audit Report', 'Hedging Relationship Audit Report', '13120000', NULL)
	PRINT '13160000 INSERTED'
END 

/*Added by Shyam Mishra, August 17 2010. */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102211)
BEGIN
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES 
		(10102211, 'Delete Setup As of Date', 'Delete Setup As of Date', 10102200, NULL)
	PRINT '10102211 INSERTED'
END
/*End by Shyam Mishra, August 17 2010. */

/*Added by Shyam Mishra, July 1 2010. */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131025)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10131025,'Maintain Hourly Data', 'Maintain Hourly Data', '10131000', 'windowHourlyData')
	PRINT '10131025 INSERTED'
END 

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10231917) 
BEGIN 
	UPDATE application_functions SET function_call = 'windowTemplatefromRFP' WHERE function_id = 10231917
	PRINT '10231917 UPDATED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10121416)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10121416,'Maintain Process Map Activity', 'Maintain Process Map Activity', '10121400','windowSelectActivityProcessMap')
	PRINT '10121416 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10121417)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10121417,'Communication Details', 'Communication Details', '10121400', 'windowMaintainRiskContolsEmailIU')
	PRINT '10121417 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10211015)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10211015,'Nested Formula', 'Nested Formula', '10211000', 'windowFormulaNested')
	PRINT '10211015 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10211016)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10211016,'Nested Detail', 'Nested Detail', '10211000', 'windowFormulaNestedDetail')
	PRINT '10211016 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10211017)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10211017,'Formula Editor', 'Formula Editor', '10211000', 'windowFormulaEditor')
	PRINT '10211017 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10192010)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10192010,'Maintain Counterparty Volumetric Limit', 'Maintain Counterparty Volumetric Limit', '10192000', NULL)
	PRINT '10192010 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10201020)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10201020,'Run Batch Job', 'Run Batch Job', '10200000', 'adiha_CreateBatchProcess')
	PRINT '10201020 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10221023)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10221023,'Settlement Dispute', 'Settlement Dispute', '10221010', 'windowSettlementDispute')
	PRINT '10221023 INSERTED'
END  

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101153)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10101153,'Maintain Fair Value Reporting IU', 'Maintain Fair Value Reporting IU', '10101130', 'windowMaintainFairValueReportingGroupIU')
	PRINT '10101153 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101153)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10101153,'Maintain Fair Value Reporting IU', 'Maintain Fair Value Reporting IU', '10101130', 'windowMaintainFairValueReportingGroupIU')
	PRINT '10101153 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101154)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10101154,'Delete Maintain Fair Value Reporting', 'Delete Maintain Fair Value Reporting', '10101130', NULL)
	PRINT '10101154 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234910)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10234910,'Measurement Date', 'Measurement Date', '10234900', 'windowMeasurementDateFilter')
	PRINT '10234910 INSERTED'
END 

/*End July 1 2010. */

/*Added by Pawan, June 30 2010 
* Replaced	-> Maintain Definition Book IU 
* With		-> Maintain Definition Counterparty IU
*/
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101110)
BEGIN 
	UPDATE application_functions SET function_name = 'Maintain Definition Counterparty IU' WHERE function_id = 10101110 
	UPDATE application_functions SET function_desc = 'Maintain Definition Counterparty IU' WHERE function_id = 10101110
	PRINT '10101110 UPDATED'
END 


/*Added by tara, may 13 2010. */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102200)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
	VALUES 
	(10102200,'Setup As of Date', 'Setup As of Date', '10100000')
	PRINT '10102200 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102210)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id)
	VALUES 
	(10102210,'Setup As of Date IU', 'Setup As of Date IU', '10102200')
	PRINT '10102210 INSERTED'
END 

/* Added by Netra [Apr 16 2010] (START) */ 
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10192000)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10192000,'Maintain Counterparty Limit','Maintain Counterparty Limit','10190000','Transaction_Processing/maintain_transaction/maintain_transaction.htm','windowMaintainCounterpartyLimit')

	PRINT ' 10192000 INSERTED'
END
/* Added by Monish[Apr 21 2010 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10221023)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10221023,'Settlement Dispute','Settlement Dispute','10221010','','windowSettlementDispute')

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10237000)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10237000,'Maintain Manual Journal Entries', 'Maintain Manual Journal Entries', '10230000', 'windowMaintainManualJournalEntries')
	PRINT '10237000 INSERTED'
END 

	PRINT ' 10221023 INSERTED'
END
/* Added by Monish[Apr 27 2010 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10121415)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10121415,'Maintain Compliance Activity Detail','Maintain Compliance Activity Detail','10121400','','')

	PRINT ' 10121415 INSERTED'
END
/* Added by Monish[Apr 27 2010 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10121416)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10121416,'Maintain Process Map Activity','Maintain Process Map Activity','10121400','','')
	
	PRINT ' 10121416 INSERTED'
END
/* Added by Monish[Apr 27 2010 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10121417)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10121417,'Communication Details','Communication Details','10121400','','')
	
	PRINT ' 10121417 INSERTED'
END
/* Added by Monish[Apr 30 2010 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10192010)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10192010,'Maintain Counterparty Volumetric Limit','Maintain Counterparty Volumetric Limit','10192000','windowMaintainCounterpartyLimitIU','')
	
	PRINT ' 10192010 INSERTED'
END

/* Added by Monish[Apr 28 2010 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10211015)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10211015,'Nested Formula','Nested Formula','10211000','','windowFormulaNested')
	
	PRINT ' 10211015 INSERTED'
END

/* Added by Monish[Apr 28 2010 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10211016)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10211016,'Nested Detail','Nested Detail','10211000','','windowFormulaNestedDetail')
	
	PRINT ' 10211016 INSERTED'
END

/* Added by Monish[Apr 28 2010 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10211017)
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10237100)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10237100,'Maintain Inventory Cost Override', 'Maintain Inventory Cost Override', '10230000', 'windowInventoryCostOverride')
	PRINT '10237100 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10237200)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10237200,'Run Inventory Calc', 'Run Inventory Calc', '10230000', 'windowRunInventoryCalc')
	PRINT '10237200 INSERTED'
END


/*Added by Tara 2010/4/19*/
IF NOT EXISTs (select 'x' from application_functions WHERE function_id=10162000 and func_ref_id=10160000)
BEGIN
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES
	(10162000,'Maintain Transportation Rate Schedule','Maintain Transportation Rate Schedule',10160000,'windowMaintainTransRate')
	PRINT '10162000 INSERTED'
END

/*Added by Tara 2010/4/19*/
IF NOT EXISTs (select 'x' from application_functions WHERE function_id=10162010 and func_ref_id=10162000)
BEGIN
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES
	(10162010,'Maintain Transportation Rate Schedule IU','Maintain Transportation Rate Schedule IU',10162000,'windowMaintainTransRateIU')
	PRINT '10162010 INSERTED'
END

IF NOT EXISTs (select 'x' from application_functions WHERE function_id=10162011 and func_ref_id=10162000)
BEGIN
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id)
	VALUES
	(10162011,'Delete Transportation Rate Schedule','Delete Transportation Rate Schedule',10162000)
	PRINT '10162011 INSERTED'
END

/*Added by Tara 2010/4/19*/
IF NOT EXISTs (select 'x' from application_functions WHERE function_id=10101152 and func_ref_id=10101100)
BEGIN
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES
	(10101152,'Maintain Definition Transportation Rate Schedule IU','Maintain Definition Transportation Rate Schedule IU',10101100,'Hedge_Accounting_Strategy/Administration/maintain_definition.htm','windowMaintainDefinationTransRate')
	PRINT '10101152 INSERTED'
END

IF NOT EXISTs (select 'x' from application_functions WHERE function_id=10211017 and func_ref_id=10211000)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	( 10211017,'Formula Editor','Formula Editor','10211000','','windowFormulaEditor')
	
	PRINT ' 10211017 INSERTED'
END


/* Added by Shyam 01/02/2010 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131024)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10131024,'View Deal Detail', 'View Deal Detail', '10131000', NULL)
	PRINT '10131024 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131110)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10131110,'View Deal Detail Blotter', 'View Deal Detail Blotter', '10131100', NULL)
	PRINT '10131110 INSERTED'
END 

/* Added by Shyam 01/02/2010 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102000)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10102000,'Setup Tenor Bucket', 'Setup Tenor Bucket', '10100000', 'windowSetupTenorBucketData')
	PRINT '10102000 INSERTED'
END 

/* To make sure previous "setup as of date function id: 10102010" if any,  updated to "Setup Tenor Group IU" */ 
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102010)
BEGIN 
	Update application_functions set function_name='Setup Tenor Group IU', function_desc='Setup Tenor Group IU', func_ref_id='10102000', function_call='windowSetupTenorGroupDataUI'
	where function_id=10102010
	PRINT '10102010 Updated'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102010)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10102010,'Setup Tenor Group IU', 'Setup Tenor Group IU', '10102000', 'windowSetupTenorGroupDataUI')
	PRINT '10102010 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102011)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10102011,'Delete Setup Tenor Group', 'Delete Setup Tenor Group', '10102000', NULL)
	PRINT '10102011 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102012)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10102012,'Setup Tenor Bucket UI', 'Setup Tenor Bucket UI', '10102000', 'windowSetupTenorBucketDataUI')
	PRINT '10102012 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102013)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10102013,'Delete Setup Tenor Bucket', 'Delete Setup Tenor Bucket', '10102000', NULL)
	PRINT '10102013 INSERTED'
END 
/* Added by Shyam 01/02/2010 (END) */


/* Added by Shyam 19/1/2010 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10171018)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10171018,'Confirmation History Detail', 'Confirmation History Detail', '10171000', 'windowSaveConfirmationHistory')
	PRINT '10171018 INSERTED'
END 
/* Added by Shyam 19/1/2010 (END) */

/* Added by Shyam 15/1/2010 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10191900)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10191900,'Run Counterparty Credit Availability Report', 'Run Counterparty Credit Availability Report', '10190000', 'windowCounterpartyCreditAvailability')
	PRINT '10191900 INSERTED'
END 
/* Added by Shyam 15/1/2010 (END) */

/* Added by Shyam 12/31/2009 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10171017)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10171017,'Confirm Status', 'Confirm Status', '10171000', 'windowConfirmStatus')
	PRINT '10171017 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101161)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10101161,'Deal Confirmation Rule', 'Deal Confirmation Rule', '10101110', 'windowDealConfirmationRule')
	PRINT '10101161 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101162)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10101162,'Deal Confirmation Rule IU', 'Deal Confirmation Rule IU', '10101161', 'windowDealConfirmationRuleDetail')
	PRINT '10101162 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101163)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10101163,'Delete Deal Confirmation Rule', 'Delete Deal Confirmation Rule', '10101161', NULL)
	PRINT '10101163 INSERTED'
END 
/* Added by Shyam 12/31/2009 (END) */

/* Added by Shyam 12/30/2009 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10141700)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10141700,'Run Trader Position Report', 'Run Trader Position Report', '10141000', 'windowRunTraderPositionReport')
	PRINT '10141700 INSERTED'
END 
/* Added by Shyam 12/30/2009 (END) */

---Compliance Managment-Reports
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10122300) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10122300, 'Reports', 'Reports', 10120000, NULL)
	PRINT '10122300 INSERTED'
END 

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id IN (10121600,10121700,10122200,10121800,10121900,10122000,10122100)) 
BEGIN 
	UPDATE application_functions SET func_ref_id = 10122300 WHERE function_id IN (10121600,10121700,10122200,10121800,10121900,10122000,10122100)
	PRINT '10121600,10121700,10122200,10121800,10121900,10122000,10122100 UPDATED'
END 

------

--Maintain User Privilege
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111010)
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES(10111010, 'Maintain User Privilege', 'Maintain User Privilege',89, 'windowMaintainPrivileges') -- Hedge Accounting Strategy Main Menu : 10111000
	PRINT '10111010 INSERTED'
END

--Insert User Privilege
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111014)
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES(10111014, 'Insert User Privilege', 'Insert User Privilege',10111010, 'windowSelectPrivileges')
	PRINT '10111014 INSERTED'
END

--Delete User Privilege
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111015)
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES(10111015, 'Delete User Privilege', 'Delete User Privilege',10111010, NULL)
	PRINT '10111015 INSERTED'
END

--Maintain Roles IU
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111110)
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES(10111110, 'Maintain Roles IU', 'Maintain Roles IU',10111100, NULL)
	PRINT '10111110 INSERTED'
END

--Delete Role
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10111111)
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES(10111111, 'Delete Role', 'Delete Role',10111100, NULL)
	PRINT '10111111 INSERTED'
END

--Report Writer
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10201000)
BEGIN
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES(10201000, 'Report Writer', 'Report Writer',93, 'windowreportwriter') --Reporting Main Menu : 10200000

	PRINT '10201000 INSERTED'
END
ELSE
BEGIN
	UPDATE application_functions SET function_call = 'windowreportwriter' WHERE function_id = 10201000
	PRINT '10201000 UPDATED'
END
	
--Report Writer IU	
IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10201010)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10201010, 'Report Writer IU', 'Report Writer IU', '10201000', 'windowtargetreport')
	
	PRINT '10201010 INSERTED'
END 
ELSE
BEGIN
	UPDATE application_functions SET function_call = 'windowtargetreport' WHERE function_id = 10201010
	PRINT '10201010 UPDATED'
END

--Delete Report Writer
IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10201011) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id)
	VALUES (10201011,'Delete Report Writer','Delete Report Writer',10201000)
	PRINT '10201011 INSERTED'
END

--Report Writer View

--delete old Report Writer View Functions
IF EXISTS (SELECT 1 FROM application_functions WHERE function_id = 536) 
BEGIN
DELETE FROM application_functions WHERE function_id = 536
PRINT '536 DELETED'
END 
IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10201012) 
BEGIN 
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id)
	VALUES (10201012,'Report Writer View','Report Writer View',10201000)
	PRINT '10201012 INSERTED'
END

--Report Writer View IU
IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10201013)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10201013, 'Report Writer View IU', 'Report Writer View IU', '10201000', 'windowTableDetailIU')
	PRINT '10201013 INSERTED'
END

--Report Writer Column IU
IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10201014)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10201014, 'Report Writer Column IU', 'Report Writer Column IU', '10201000', 'windowReportWriterColumnIU')
	PRINT '10201014 INSERTED'
END

IF NOT EXISTs (select 1 from application_functions WHERE function_id=10101031)
BEGIN

	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
		VALUES (10101031,'Pricing','Pricing',10101012,'Administration/Setup/maintain_static_data.htm','windowStatePropertiesPricing')
END

IF NOT EXISTs (select 'x' from application_functions WHERE function_id=10101151 and func_ref_id=10101100)
BEGIN

INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
		VALUES (10101151,'Maintain Definition UOM conversion','Maintain Definition UOM conversion',10101100,'Hedge_Accounting_Strategy/Administration/maintain_definition.htm','windowMaintainDefinationRecVol')

END

/* Added by Shyam 01/05/2010 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234515)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10234515,'Hedge Relationship Type Detail', 'Hedge Relationship Type Detail', '10234500', 'windowSelectHedgeRelationMatch')
	PRINT '10234515 INSERTED'
END 

/* Added by Shyam 01/05/2010 (END) */

/* Added by Shyam 12/09/2009 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101900)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10101900,'Setup Deal Lock', 'Setup Deal Lock', '10100000', 'windowSetupDealLock')
	PRINT '10101900 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101910)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10101910,'Deal Lock IU', 'Deal Lock IU', '10101900', 'windowDealLockIU')
	PRINT '10101910 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101911)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10101911,'Delete Deal Lock', 'Delete Deal Lock', '10101900', NULL)
	PRINT '10101911 INSERTED'
END 

/* Added by Shyam 12/09/2009 (END) */


--pavan
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 11000001)
BEGIN 
	delete application_functions where function_id = 11000001
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 11000004)
BEGIN
	delete application_functions where function_id = 11000004
END


/* Added by Sishir 11/13/2009 (START) */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131200)
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,document_path,function_call)
	VALUES 
	(10131200,'Maintain Environmental Transactions','Maintain Environmental Transactions','10130000','Transaction_Processing/maintain_transaction/maintain_transaction.htm','windowMaintainRecDeals')
	
	PRINT '10131200 INSERTED'
END 




/* Added by Sishir 11/13/2009 (END) */

/* Added by Sishir 11/12/2009 (START) */

--Disable all constraints and Triggers
	EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
	EXEC sp_MSforeachtable 'ALTER TABLE ? DISABLE TRIGGER ALL'

IF EXISTS (SELECT 'x' FROM application_functional_users WHERE functional_users_id IN ('3353','5188','14306','13753','13205','12656','12109','9380','10470','9925','8130','7006','6461','7551','5914','4655')) 	
	UPDATE dbo.application_functional_users SET function_id = 10101028 WHERE functional_users_id IN ('3353','5188','14306','13753','13205','12656','12109','9380','10470','9925','8130','7006','6461','7551','5914','4655')
	
IF EXISTS (SELECT 'x' FROM application_functional_users WHERE functional_users_id IN ('3352','5187','14305','13752','13204','12655','12108','9379','10469','9924','8129','7005','6460','7550','4654','5913')) 	
	UPDATE dbo.application_functional_users SET function_id = 10101029 WHERE functional_users_id IN ('3352','5187','14305','13752','13204','12655','12108','9379','10469','9924','8129','7005','6460','7550','4654','5913')

IF EXISTS (SELECT 'x' FROM application_functional_users WHERE functional_users_id IN ('5186','4536','13751','13203','14304','12654','12107','9378','10468','9923','8128','7549','7004','6459','4653','5912')) 	
	UPDATE dbo.application_functional_users SET function_id = 10101030 WHERE functional_users_id IN ('5186','4536','13751','13203','14304','12654','12107','9378','10468','9923','8128','7549','7004','6459','4653','5912')

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 11000001) 
BEGIN 
	UPDATE application_functions SET function_id = 10101028 WHERE function_id = 11000001
	PRINT '10101028 INSERTED'
END 

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 11000002) 
BEGIN 
	UPDATE application_functions SET function_id = 10101029 WHERE function_id = 11000002
	PRINT '10101029 INSERTED'
END 
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 11000003) 
BEGIN 
	UPDATE application_functions SET function_id = 10101030 WHERE function_id = 11000003
	PRINT '10101030 INSERTED'
END 


IF EXISTS (SELECT 'x' FROM application_functional_users WHERE functional_users_id IN ('5185','4535','14303','13750','13202','12653','12106','9377','10467','9922','8127','7003','6458','7548','5911','4652')) 	
	UPDATE dbo.application_functional_users SET function_id = 10121024 WHERE functional_users_id IN ('5185','4535','14303','13750','13202','12653','12106','9377','10467','9922','8127','7003','6458','7548','5911','4652')

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 11000004) 
BEGIN 
	DELETE FROM application_functions WHERE function_id = 11000004
	PRINT '11000004 DELETED'
END 

--	Enable all constraints and Triggers
	EXEC sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL'
	EXEC sp_MSforeachtable 'ALTER TABLE ? ENABLE TRIGGER ALL'

/* Added by Sishir 11/12/2009 (END) */



IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12121310) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12121310,'Assign Rec Deals','Assign Rec Deals',12121300,'windowAssignRecFilter')
	PRINT '12121310 INSERTED'
END
SET NOCOUNT ON
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131500) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10131500,'Import EPA Allowance Data','Import EPA Allowance Data',10130000,'windowEPAAllowanceData')
	PRINT '10131500 INSERTED'
END
SET NOCOUNT ON
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12131800) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12131800,'Run REC Production Report','Run REC Production Report',12130000,'windowRecProductionReport')
	PRINT '12131800 INSERTED'
END
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12131900) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12131900,'Run Rec Generator Report','Run Rec Generator Report',12130000,'windowRecGeneratorReport')
	PRINT '12131900 INSERTED'
END
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12132000) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12132000,'Run Generator Info Report','Run Generator Info Report',12130000,'windowGeneratorInfoReport')
	PRINT '12132000 INSERTED'
END
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12132100) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12132100,'Run Gen/Credit Source Allocation Report','Run Gen/Credit Source Allocation Report',12130000,'windowRecGenAllocateReport')
	PRINT '12132100 INSERTED'
END
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10221800) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10221800,'Run Settlement Production Report','Run Settlement Production Report',10220000,'windowSettlementProductionReport')
	PRINT '10221800 INSERTED'
END
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12132200) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12132200,'Purchase Power Renewable Report','Purchase Power Renewable Report',12130000,'windowWindPurPowerReport')
	PRINT '12132200 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131019) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10131019,'Deal Exercise Detail','Deal Exercise Detail',10131010,'windowDealExerciseDetail')
	PRINT '10131019 INSERTED'
END


IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12131700) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12131700,'Allowance Reconciliation Report','Allowance Reconciliation Report',12130000,'windowRunAllowanceReconciliationReport')
	PRINT '12131700 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12131600) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12131600,'Allowance Transfer','Allowance Transfer',12130000,'windowAllowanceTransfer')
	PRINT '12131600 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101025) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) 
	VALUES 	(10101025,'Tier Type Properties','Tier Type Properties', 10101025, 'windowTierTypeProperty')
	PRINT '10101025 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101026) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) 
	VALUES 	(10101026,'Tier Type Properties Detail IU','Tier Type Properties Detail IU', 10101025, 'windowTierTypePropertyIU')
	PRINT '10101026 INSERTED'
END


IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101027) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) 
	VALUES 	(10101027,'Delete Tier Type Properties Detail','Delete Tier Type Properties Detail', 10101025, NULL)
	PRINT '10101027 INSERTED'
END

--Mukesh
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10221700) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10221700,	'Market Variance Report',	'Market Variance Report',	10220000,	'windowMarketVarienceReport')
	PRINT '10221700 INSERTED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101015 and func_ref_id = 10101012) 
BEGIN
	UPDATE application_functions SET function_name = 'REC Bonus IU' WHERE function_id = 10101015 and func_ref_id = 10101012
	PRINT '10101015 UPDATED'
END
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101016 and func_ref_id = 10101012) 
BEGIN
	UPDATE application_functions SET function_name = 'Delete REC Bonus ' WHERE function_id = 10101016 and func_ref_id = 10101012
	PRINT '10101016 UPDATED'
END

--added by Mukesh to change the func_ref_id  for Calendar Properties IU
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101022 and func_ref_id = 10101000) 
BEGIN
	UPDATE application_functions SET func_ref_id = 10101021 WHERE function_id = 10101022 AND func_ref_id = 10101000
	PRINT '10101022 UPDATED'
END

-- Bikash, 12 June 2009
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161900) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10161900,	'Run Power Position Report',	'Run Power Position Report',	10160000,	'windowRunPowerPositionReport')
	PRINT '10161900 INSERTED'
END
-- Poojan, 05 June 2009
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101414) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10101414,	'Deal Transfer Mapping IU',	'Deal Transfer Mapping IU',	10101410,	'windowDealTransferMapping')
	PRINT '10101414 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101415) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10101415,	'Delete Deal Transfer Mapping',	'Delete Deal Transfer Mapping',	10101410,	NULL)
	PRINT '10101415 INSERTED'
END


-- Mukesh Singh, 04 Jun 2009, Added for Maintain Configuration Parameter.
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101700) 
BEGIN 	
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call,module_type) 
	VALUES 	(10101700,	'Maintain Configuration Parameter',	'Maintain Configuration Parameter',	10100000,	'windowMaintainConfigData','c')
	PRINT '10101700 INSERTED'
END


-- Vishwas Khanal, 04 Jun 2009
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10121210) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	
	(10121210,'Perform Dependency Activities','Perform Dependency Activities',10121200,'windowMaintainComplianceDependency')
	PRINT '10121210 INSERTED'
END


-- Vishwas Khanal, 02 Jun 2009, Added on request of Mukesh.
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101020 and function_name = 'Delete REC Requirement') 
BEGIN
	UPDATE application_functions SET function_desc = 'Delete REC Compliance', function_name = 'Delete REC Compliance' WHERE function_id = 10101020
	PRINT '10101020 UPDATED'
END
-- Bikash Subba, 2nd  June 2009
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131018) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	
	(10131018,'Lagging Month Volume','Lagging Month Volume',10131010,'windowLaggingVolumeMonth')
	PRINT '10131018 INSERTED'
END

-- Vishwas Khanal, 02 Jun 2009, Corrected the Script written by Anal.
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10211110 and function_call = 'windowContractChargeType') 
BEGIN
	UPDATE application_functions SET function_call = 'windowContractChargeTypeDetail' WHERE function_id = 10211110
	PRINT '10211110 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10211111 and function_call = 'windowContractChargeType') 
BEGIN 	
	UPDATE application_functions SET function_call = NULL WHERE function_id = 10211111
	PRINT '10211111 UPDATED'
END
ELSE IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10211111)
BEGIN
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	
	(10211111,'Delete Contract Charge Type Templates','Delete Contract Components Templates',10211100,NULL)
	PRINT '10211111 INSERTED'
END	

-- Vishwas Khanal, 02 Jun 2009
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131300 and function_call = 'windowImportData') 
BEGIN 	
	UPDATE application_functions SET function_call = 'windowImportDataDeal' WHERE function_id  = 10131300
	PRINT '10131300 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10151100 and function_call = 'windowImportData') 
BEGIN 	
	UPDATE application_functions SET function_call = 'windowImportDataPrice' WHERE function_id  = 10151100
	PRINT '10151100 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10191100 and function_call = 'windowImportData') 
BEGIN 	
	UPDATE application_functions SET function_call = 'windowImportDataCredit' WHERE function_id  = 10191100
	PRINT '10191100 UPDATED'
END

-- Anal Shrestha 06/02/2009
-- Added for Contract Component Templates

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10211100) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	
	(10211100,'Setup Contract Charge Type Templates','Setup Contract Components Templates',10210000,'windowContractChargeType')
	PRINT '10211100 INSERTED'
END
	

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10211110) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	
	(10211110,'Contract Charge Type Templates IU','Contract Components Templates IU',10211100,'windowContractChargeType')
	PRINT '10211110 INSERTED'
END
	
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10211111) 
BEGIN 
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	
	(10211111,'Delete Contract Charge Type Templates','Delete Contract Components Templates',10211100,'windowContractChargeType')
	PRINT '10211111 INSERTED'
END


-- Sishir
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101212) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	
	(10101212,'Source Book Mapping','Source Book Mapping',10101200,'windowSourceBookMapping')
	PRINT '10101212 INSERTED'
END
	

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101213) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	
	(10101213,'Source Book Mapping IU','Source Book Mapping IU',10101212,'windowSourceBookMappingDetail')
	PRINT '10101213 INSERTED'
END
	

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101214) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id) VALUES 	
	(10101214,'Delete Source Book Mapping','Delete Source Book Mapping',10101212)
	PRINT '10101214 INSERTED'
END
	

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101215) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	
	(10101215,'Transfer Source Book Mapping','Transfer Source Book Mapping',10101212,'windowSourceBookMappingTransfer')
	PRINT '10101215 INSERTED'
END
	

-- Sishir

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161312) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	
	(10161312,'Maintain Delivery Status','Maintain Delivery Status',10161300,'windowRunDeliveryStatus')
	PRINT '10161312 INSERTED'
END
	


-- Bikash Subba, 29 May 2009
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161710 and func_ref_id <> 10161700 ) 
BEGIN 	
	UPDATE application_functions SET func_ref_id = 10161700 WHERE function_id  = 10161710
	PRINT '10161710 Updated'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161711 AND func_ref_id <> 10161700) 
BEGIN 	
	UPDATE application_functions SET func_ref_id = 10161700 WHERE function_id  = 10161711
	PRINT '10161711 Updated'
END


-- Vishwas Khanal, 28 May 2009
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10121412 and function_call = 'windowMaintainComplianceRisksIU' ) 
BEGIN 	
	UPDATE application_functions SET function_call = 'windowActivityProcessMapIU' WHERE function_id  = 10121412
	PRINT '10121412 Updated'
END

-- Bikash Subba, 27 May 2009
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10221315) 
BEGIN 	
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10221315,	'Shadow Calc Delete',	'Shadow Calc Delete',	10221300,	NULL)
	PRINT '10171215 INSERTED'
END
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10221314) 
BEGIN 	
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10221314,	'Shadow Calc Detail',	'Shadow Calc Detail',	10221300,	NULL)
	PRINT '10171214 INSERTED'
END
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10171210) 
BEGIN 	
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10171210,	'Lock/Unlock Deal Lock',	'Lock/Unlock Deal Lock',	10171200,	'windowLockUnlockDeal')
	PRINT '10171210 INSERTED'
END
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10171211) 
BEGIN 	
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10171211,	'Lock/Unlock Deal Unlock',	'Lock/Unlock Deal Unlock',	10171200,	'windowLockUnlockDeal')
	PRINT '10171211 INSERTED'
END

-- Vishwas Khanal, 26 May 2009
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161210) 
BEGIN 	
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10161210,	'Schedule And Delivery Post Detail',	'Schedule And Delivery Post Detail',	10161200,	NULL)
	PRINT '10161210 INSERTED'
END

-- Bikash Subba, 26 May 2009
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161510) 
BEGIN 	
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10161510,	'Maintain Source Generator IU',	'Maintain Source Generator IU',	10161500,	'windowMaintainSourceGenerator')
	PRINT '10161510 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161511) 
BEGIN 	
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10161511,	'Maintain Source Generator Delete',	'Maintain Source Generator Delete',	10161500,	'windowMaintainSourceGeneratorIU')
	PRINT '10161511 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161810) 
BEGIN 	
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10161810,	'Power Outage IU',	'Power Outage IU',	10161800,	'windowMaintainPowerOutageIU')
	PRINT '10161810 INSERTED'
END
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161811) 
BEGIN 	
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10161811,	'Power Outage Delete',	'Power Outage Delete',	10161800,	NULL)
	PRINT '10161811 INSERTED'
END

-- Mukesh, 25.May.2009
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161611) 
BEGIN 	
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10161611,	'Location Price Index Delete',	'Location Price Index Delete',	10161000,	NULL)
	PRINT '10161611 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161710) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10161710,	'Bid Offer Formulator Header IU',	'Bid Offer Formulator Header IU',	10161100,	'windowBidOfferFormulatorHeaderIU')
	PRINT '10161710 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161711) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10161711,	'Bid Offer Formulator Header', 'Delete	Bid Offer Formulator Header Delete',	10161100,	NULL)
	PRINT '10161711 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161712)
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10161712,	'Bid Offer Formulator Detail IU',	'Bid Offer Formulator Detail IU',	10160000,	'windowBidOfferFormulatorDetailIU')
	PRINT '10161712 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161713) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10161713,	'Bid Offer Formulator Detail', 'Delete	Bid Offer Formulator Detail Delete',10160000,NULL)	
	PRINT '10161713 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10161610) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10161610,	'Location Price Index IU',	'Location Price Index IU',	10161000,	'windowLocationPriceIndexDetail')
	PRINT '10161714 INSERTED'
END


IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10141500) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10141500,	'Run Units Availability Report',	'Run Units Availability Report',	10141000,	'windowRunUnitsAvailabilityReport')
	PRINT '10141500 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10141600) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call) VALUES 	(10141600,	'Run Bid Offer Report',	'Run Bid Offer Report',	10141000,	'windowRunBidOfferReport')
	PRINT '10141600 INSERTED'
END


-- Added by Sishir [10/06/2009] for fasmodule menu item.
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101800) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10101800, 'Configure Interface Timeout Parameter', 'Configure Interface Timeout Parameter', 10100000, 'windowConfigInterfaceTimeout')
	PRINT '10101800 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101149) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10101149, 'Counterparty EPA Account IU', 'Counterparty EPA Account IU', 10101115, 'windowCounterpartyEpaAccount')
	PRINT '10101149 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101150) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id)
	VALUES (10101150, 'Delete Counterparty EPA Account', 'Delete Counterparty EPA Account', 10101115)
	PRINT '10101150 INSERTED'
END 


--- Added for "Run Settlement Report" in Valuation and Risk Analysis Menu.

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10182100) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182100, 'Run Settlement Report', 'Run Settlement Report', 10180000,'windowSettlementReport')
	PRINT '10182100 INSERTED'
END 
---

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10232410) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10232410, 'Assesment Result IU', 'Assesment Result IU', 10232400,'windowViewAssessmentResultsIU')
	PRINT '10232410 INSERTED'
END 

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101000 and func_ref_id = 10100000) 
BEGIN
	update application_functions 
	set document_path='Hedge_Accounting_Strategy/Administration/maintain_static_data.htm' 
	where function_id = 10101000 and func_ref_id = 10100000
	PRINT '10101000 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10232800 and func_ref_id = 10230000) 
BEGIN
	update application_functions 
	set document_path='Deal_capture_or_risk_system/Run_Import_Audit_Report/Run_Import_Audit_Report.htm' 
	where function_id = 10232800 and func_ref_id = 10230000
	PRINT '10232800 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10232500 and func_ref_id = 10230000) 
BEGIN
	update application_functions 
	set document_path='Assessment_Of_Hedge_Effectiveness/Run_Assessment_Trend_Graph/Run_Assessment_Trend_Graph.htm' 
	where function_id = 10232500 and func_ref_id = 10230000
	PRINT '10232500 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10233900 and func_ref_id = 10230000) 
BEGIN
	update application_functions 
	set document_path='Transaction_Processing/Hedge_relationship_report/hedge_relationship_report.htm' 
	where function_id = 10233900 and func_ref_id = 10230000
	PRINT '10233900 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234400 and func_ref_id = 10230000) 
BEGIN
	update application_functions 
	set document_path='Transaction_Processing/Automate_Matching_of_Hedges/Automate_Matching_of_Hedges.htm' 
	where function_id = 10234400 and func_ref_id = 10230000
	PRINT '10234400 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10241000 and func_ref_id = 10240000) 
BEGIN
	update application_functions 
	set document_path='Transaction_Processing/Reconcile_Cash_Entries_for_derivatives/RECONC~1.HTM' 
	where function_id = 10241000 and func_ref_id = 10240000
	PRINT '10241000 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234800 and func_ref_id = 10230000) 
BEGIN
	update application_functions 
	set document_path='Transaction_Processing/Bifurcation_of_Embedded_Derivatives/Bifurcation_of_Embedded_Derivative.htm' 
	where function_id = 10234800 and func_ref_id = 10230000
	PRINT '10234800 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234700 and func_ref_id = 10230000) 
BEGIN
	update application_functions 
	set document_path='Transaction_Processing/Maintain_Transactions_Tagging/Maintain_Transactions_Tagging.htm' 
	where function_id = 10234700 and func_ref_id = 10230000
	PRINT '10234700 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234600 and func_ref_id = 10230000) 
BEGIN
	update application_functions 
	set document_path='Transaction_Processing/First_Day_Gain_Loss_Treatment-Derivative/First_Day_Gain_Loss_Treatment-Derivative.htm' 
	where function_id = 10234600 and func_ref_id = 10230000
	PRINT '10234600 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234500 and func_ref_id = 10230000) 
BEGIN
	update application_functions 
	set document_path='Transaction_Processing/Veiw_Outstanding_Automation_Results/VIEW_O~1.HTM' 
	where function_id = 10234500 and func_ref_id = 10230000
	PRINT '10234500 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234300 and func_ref_id = 10230000) 
BEGIN
	update application_functions 
	set document_path='Transaction_Processing/Automation_of _Forcasted_Transaction/Automation_of_Forcasted_Transaction.htm' 
	where function_id = 10234300 and func_ref_id = 10230000
	PRINT '10234300 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10233715 and func_ref_id = 10233710) 
BEGIN
	update application_functions 
	set document_path='Transaction_Processing/Designation_of_a_Hedge/Designation_of_a_Hedge.htm' 
	where function_id = 10233715 and func_ref_id = 10233710
	PRINT '10233715 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131011 and func_ref_id = 10131000) 
BEGIN
	update application_functions 
	set document_path='Transaction_Processing/maintain_transaction/Maintain_Transaction.htm' 
	where function_id = 10131011 and func_ref_id = 10131000
	PRINT '10131011 UPDATED'
END

--insert new
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10231917) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id)
	VALUES (10231917,'Template From RFP_IU','Template From RFP_IU',10231910)
	PRINT '10231917 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10231918) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id)
	VALUES (10231918,'Template From RFP_DEL','Template From RFP_DEL',10231910)
	PRINT '10231918 INSERTED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10231917 and func_ref_id = 10231910) 
BEGIN
	update application_functions 
	set document_path='Hedge_Accounting_Strategy/Setup_Hedging_Relationship_Types/Setup_Hedging_Relationship_Types.htm' 
	where function_id = 10231917 and func_ref_id = 10231910
	PRINT '10231917 UPDATED'
END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10141000 and func_ref_id = 10140000) 
BEGIN
	update application_functions 
	set document_path='Reports/Run_Position_Report/Run_Position_Report.htm' 
	where function_id = 10141000 and func_ref_id = 10140000
	PRINT '10141000 UPDATED'
END

-- added by pavan

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131210) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10131210,'Maintain Transactions IU','Maintain Transactions IU',10131200,'windowRecInsert')
	PRINT '10131210 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131211) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10131211,'Delete Transactions','Delete Transactions',10131200,NULL)
	PRINT '10131211 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131212) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10131212,'Maintain Transactions Close','Maintain Transactions Close',10131200,NULL)
	PRINT '10131212 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131213) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10131213,'Maintain Transactions Transfer','Maintain Transactions Transfer',10131200,'windowInterBookTransfer')
	PRINT '10131213 INSERTED'
END


IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10233210) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10233210, 'Run What-If Mesurement Analysis', 'Run What-If Mesurement Analysis', 10233200, 'windowRunwhatifmeasurementanaiu')
	PRINT '10233210 INSERTED'
END 


IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131018) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10131018, 'Trade Ticket Report', 'Trade Ticket Report', 10131000, 'windowTradeTicket')
	PRINT '10131018 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10191900) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10191900, 'Maintain Counterparty Limit', 'Maintain Counterpaty Limit', 10190000, 'windowMaintainCounterpartyLimit')
	PRINT '10191900 INSERTED'
END 


IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131020) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10131020, 'Trade Ticket', 'Trade Ticket', 10131000, 'windowTradeTicket')
	PRINT '10131020 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131021) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10131021, 'Trade Ticket Trader Sign Off', 'Trade Ticket Trader Sign Off', 10131020, NULL)
	PRINT '10131021 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131022) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10131022, 'Trade Ticket Risk Sign Off', 'Trade Ticket Risk Sign Off', 10131020, NULL)
	PRINT '10131022 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131023) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10131023, 'Trade Ticket Back Office Sign Off', 'Trade Ticket Back Office Sign Off', 10131020, NULL)
	PRINT '10131023 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10182200) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182200, 'Run Counterparty MTM report', 'Run Counterparty MTM report', 10180000, 'windowCounterpartyMTMReport')
	PRINT '10182200 INSERTED'
END 

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10141800)
BEGIN
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10141800,'Transfer Book Position', 'Transfer Book Position', 10141000, 'windowTransferBookPosition')
	PRINT '10141800 INSERTED'
END

/* Added by	:	Narendra Shrestha 
 * Purpose	:	To use common function id for batch job 
 * Date		:	28th April, 2010
 */
 
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10201020)
BEGIN
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10201020,'Run Batch Job', 'Run Batch Job', 10200000, 'adiha_CreateBatchProcess')
	PRINT '10201020 INSERTED'
END

SET NOCOUNT OFF

-- added by pavan for EMS

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12103000) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103000,'Maintain Company Type Template','Maintain Company Type Template',12100000,'windowDefineMainCompTypeTemp')
	PRINT '12103000 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12103010) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103010,'Maintain Company Type Template IU','Maintain Company Type Template IU',12103000,'windowDefineMainCompTypeTempIU')
	PRINT '12103010 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12103011) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103011,'Delete Maintain Company Type Template','Delete Maintain Company Type Template',12103000,null)
	PRINT '12103011 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12103012) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103012,'Maintain Company Type Template Parameter','Maintain Company Type Template Parameter',12103000,'windowDefineMainCompTypeTempParamIU')
	PRINT '12103012 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12103013) 
BEGIN 
	INSERT INTO application_functions( function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103013,'Delete Maintain Company Type Template Parameter','Delete Maintain Company Type Template Parameter',12103000,'windowDefineMainCompTypeTempParamIU')
	PRINT '12103013 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10182200) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182200, 'Run Counterparty MTM report', 'Run Counterparty MTM report', 10180000, 'windowCounterpartyMTMReport')
	PRINT '10182200 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10122200) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10122200, 'View Compliance Calendar', 'View Compliance Calendar', 10120000, 'windowComplianceCalendar')
	PRINT '10122200 INSERTED'
END 

/* Added by Narendra */
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12103100) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103100, 'Maintain Emission Limits', 'Maintain Emission Limits', 12100000, 'windowMaintainLimits')
	PRINT '12103100 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12103110) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103110, 'Maintain Emission Limits IU', 'Maintain Emission Limits IU', 12103100, 'windowMaintainLimitsIU')
	PRINT '12103110 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12103111) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (12103111, 'Maintain Emission Limits Delete', 'Maintain Emission Limits Delete', 12103100, 'windowMaintainLimits')
	PRINT '12103111 INSERTED'
END
/*---------------------*/ 

SET NOCOUNT OFF
--pavan

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10221200 and func_ref_id = 10220000) 
BEGIN
update application_functions set function_name='Settlement Invoice Report' where function_id = 10221200
END


IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10221900) 
BEGIN 
	INSERT INTO application_functions (function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10221900, 'Run Settlement Report', 'Run Settlement Report', 10220000,'windowSettlementReport')
	PRINT '10221900 INSERTED'
END 

IF EXISTS (SELECT 'x' FROM application_functional_users WHERE functional_users_id = 14810 and function_id = 10182100) 
BEGIN
	update application_functional_users set function_id = 10221900 where functional_users_id = 14810
END


--IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10182100)
--BEGIN
--	delete  application_functions where function_id = 10182100 
--END
--tara
IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10182200) 
BEGIN 
	insert into application_functions(function_id,function_name,function_desc,func_ref_id,function_call) 
	values (10182200,'Run Counterparty MTM Report','Run Counterparty MTM Report',10180000,'windowCounterpartyMTMReport')
	PRINT '10182200 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234411)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10234411, 'Automate Matching of Hedges Report', 'Automate Matching of Hedges Report', '10234400', NULL)
	PRINT '10234411 INSERTED'
END

IF NOT EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234412)
BEGIN 
	INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES 
	(10234412, 'Create Hedge Relationship', 'Create Hedge Relationship', '10234411', NULL)
	PRINT '10234412 INSERTED'
END

/*Added By Shyam Mishra,July 07 2010
* Replaced	-> Maintain Definition Book IU 
* With		-> Maintain Definition Counterparty IU
*/
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101145)
BEGIN 
	UPDATE application_functions 
		SET function_name = 'Maintain Definition UOM IU' ,
			function_desc = 'Maintain Definition UOM IU' 
		WHERE function_id = 10101145
	PRINT '10101145 UPDATED'
END 

/*	
* Replaced	-> Maintain Definition Counterparty IU 
* With		-> Maintain Definition Book Attribute IU
*/
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101110)
BEGIN 
	UPDATE application_functions 
		SET function_name = 'Maintain Definition Book Attribute IU' ,
			function_desc = 'Maintain Definition Book Attribute IU' 
		WHERE function_id = 10101110
	PRINT '10101110 UPDATED'
END 

/*	
* Replaced	-> Delete Maintain Definition 
* With		-> Delete Maintain Definition Book Attribute
*/
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101146)
BEGIN 
	UPDATE application_functions 
		SET function_name = 'Delete Maintain Definition Book Attribute' ,
			function_desc = 'Delete Maintain Definition Book Attribute' 
		WHERE function_id = 10101146
	PRINT '10101146 UPDATED'
END 

/*	
* Replaced	-> func_ref_id = 10101110
* With		-> func_ref_id = 10101115
*/
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101122)
BEGIN 
	UPDATE application_functions 
		SET func_ref_id = 10101115 
		WHERE function_id = 10101122
	PRINT '10101122 UPDATED'
END 

/*	
* Replaced	-> func_ref_id = 10101110
* With		-> func_ref_id = 10101115
*/
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101161)
BEGIN 
	UPDATE application_functions 
		SET func_ref_id = 10101115 
		WHERE function_id = 10101161
	PRINT '10101161 UPDATED'
END 

/*End By Shyam Mishra,July 07 2010*/

/*
 * Added by Pawan Adhikari, July 08 2010
 * Replaced ->	Run Position Report
 * With		->	Run Daily Gas Position Report
 */
IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10161200)
BEGIN 
	UPDATE application_functions
		SET function_name = 'Run Daily Gas Position Report', 
			function_desc = 'Run Daily Gas Position Report'
		WHERE function_id = 10161200
	PRINT '10161200 UPDATED'
END

/*
 * Replaced ->	Run Position Report
 * With		->	Run Index Position Report
 */
IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10141000)
BEGIN 
	UPDATE application_functions
		SET function_name = 'Run Index Position Report', 
			function_desc = 'Run Index Position Report'
		WHERE function_id = 10141000
	PRINT '10141000 UPDATED'
END

/*
 * Replaced	->	Run Position Report
 * With		->	Run Inventory Position Report
 */
 IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 12131100)
	BEGIN 
		UPDATE application_functions
			SET function_name = 'Run Inventory Position Report', 
				function_desc = 'Run Inventory Position Report'
			WHERE function_id = 12131100
		PRINT '12131100 UPDATED'
	END
 
 /*
  * Replaced	->	Scheduling and Delivery
  * With		->	View Delivery Transactions
  */
 IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10161300)
	BEGIN 
		UPDATE application_functions
			SET function_name = 'View Delivery Transactions', 
				function_desc = 'View Delivery Transactions'
			WHERE function_id = 10161300
		PRINT '12131100 UPDATED'
	END
 /*Added by Pawan Adhikari, July 08 2010*/
 
 /*Added by Shyam Mishra, July 12 2010*/
 /*
  * Replaced	->	Maintain Definition Curve Def
  * With		->	Maintain Definition Curve Def IU
  */
 IF EXISTS(SELECT 'x' FROM application_functions WHERE function_id = 10101130)
	BEGIN 
		UPDATE application_functions
			SET function_name = 'Maintain Definition Curve Def IU', 
				function_desc = 'Maintain Definition Curve Def IU'
			WHERE function_id = 10101130
		PRINT '10101130 UPDATED'
	END
 /*Added by Shyam Mishra, July 12 2010*/

/* Added by Pawan Adhikari, July 26 2010 */
IF EXISTS (SELECT 'x' FROM application_functional_users WHERE function_id = 12101000)
	BEGIN
		UPDATE application_functional_users
		SET
			function_id = 10102300
		WHERE 
			function_id = 12101000		
	END
	
IF EXISTS (SELECT 'x' FROM application_functional_users WHERE function_id = 12101010)
	BEGIN
		UPDATE application_functional_users
		SET
			function_id = 10102310
		WHERE 
			function_id = 12101010
	END
	
IF EXISTS (SELECT 'x' FROM application_functional_users WHERE function_id = 12101011)
	BEGIN
		UPDATE application_functional_users
		SET
			function_id = 10102311
		WHERE 
			function_id = 12101011
	END


IF EXISTS (SELECT 'x' FROM application_functional_users WHERE function_id = 12111800)
	BEGIN
		UPDATE application_functional_users
		SET
			function_id = 10201100
		WHERE 
			function_id	= 12111800 
	END
	
IF EXISTS (SELECT 'x' FROM application_functional_users WHERE function_id = 12111900)
	BEGIN
		UPDATE application_functional_users
		SET
			function_id = 10201200
		WHERE
			function_id = 12111900 
	END

IF EXISTS (SELECT 'x' FROM application_functional_users WHERE function_id = 12111910)
	BEGIN
		UPDATE application_functional_users
		SET
			function_id = 10201210
		WHERE 
			function_id = 12111910 
	END
	
IF EXISTS (SELECT 'x' FROM application_functional_users WHERE function_id = 12111911)
	BEGIN
		UPDATE application_functional_users
		SET
			function_id = 10201211
		WHERE 
			function_id = 12111911 
	END
	
IF EXISTS (SELECT 'x' FROM application_functional_users WHERE function_id = 12111912)
	BEGIN
		UPDATE application_functional_users
		SET
			function_id = 10201212
		WHERE 
			function_id = 12111912 
	END

IF EXISTS (SELECT 'x' FROM application_functional_users WHERE function_id = 12111913)
	BEGIN
		UPDATE application_functional_users
		SET 
			function_id = 10201213
		WHERE 
			function_id = 12111913
	END



IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12101000 AND function_name = 'Setup Emissions Source/Sink Type')
	BEGIN
		DELETE FROM application_functions WHERE function_id = 12101000
		PRINT '12101000 DELETED'
	END
	
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12101010 AND function_name = 'Setup Emissions Source/Sink Type IU')
	BEGIN
		DELETE FROM application_functions WHERE function_id = 12101010
		PRINT '12101010 DELETED'
	END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12101011 AND function_name = 'Delete Setup Emissions Source/Sink Type')
	BEGIN
		DELETE FROM application_functions WHERE function_id = 12101011
		PRINT '12101011 DELETED'
	END
	
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12111800 AND function_name = 'Run Dashboard Report')
	BEGIN
		DELETE FROM application_functions WHERE function_id = 12111800
		PRINT '12111800 DELETED'
	END


IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12111900 AND function_name = 'Dashboard Report TEMPLATE')
	BEGIN
		DELETE FROM application_functions WHERE function_id = 12111900
		PRINT '12111900 DELETED'
	END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12111911 AND function_name = 'Delete Dashboard Report Template Header')
	BEGIN
		DELETE FROM application_functions WHERE function_id = 12111911
		PRINT '12111911 DELETED'
	END
	
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12111912 AND function_name = 'Dashboard Report Template IU')
	BEGIN
		DELETE FROM application_functions WHERE function_id = 12111912
		PRINT '12111912 DELETED'
	END

IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12111913 AND function_name = 'Delete Dashboard Report TEMPLATE')
	BEGIN
		DELETE FROM application_functions WHERE function_id = 12111913
		PRINT '12111913 DELETED'
	END
	
IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 12111910 AND function_name = 'Dashboard Report Template Header IU')
	BEGIN
		DELETE FROM application_functions WHERE function_id = 12111910
		PRINT '12111910 DELETED'
	END
	
/* End by Pawan Adhikari */

/* Added by Narendra Shrestha */
IF NOT EXISTS(SELECT 'X' FROM application_functions where function_id = 10141900)
BEGIN
	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10141900,'Run Load Forecast Report','Run Load Forecast Report',10140000,'windowRunLoadForecastReport')
	PRINT '10141900 INSERTED'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10222400)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10222400, 'Run Meter Data Report', 'Run Meter Data Report', 10220000, 'windowMeterDataReport')
 	PRINT ' Inserted 10222400 - Run Meter Data Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10222400 - Run Meter Data Report already EXISTS.'
END
/* End by Narendra Shrestha */

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10102514)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10102514, 'View Location Detail', 'View Location Detail', 10102500, '')
 	PRINT ' Inserted 10102514 - View Location Detail.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10102514 - View Location Detail already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10182900)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10182900, 'Hedge Cashflow Deferral Report', 'Hedge Cashflow Deferral Report', 10180000, 'windowRunMTMExplainReport')
 	PRINT ' Inserted 10182900 - Hedge Cashflow Deferral Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10182900 - Hedge Cashflow Deferral Report already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162400)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162400, 'Run Roll Forward Inventory Report', 'Run Roll Forward Inventory Report', 10160000, 'windowRunRollForwardInventoryReport')
 	PRINT ' Inserted 10162400 - Run Roll Forward Inventory Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162400 - Run Roll Forward Inventory Report already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162500)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162500, 'Run Inventory Calc', 'Run Inventory Calc', 10160000, 'windowRunInventoryCalc')
 	PRINT ' Inserted 10162500 - Run Inventory Calc.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162500 - Run Inventory Calc already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10162600)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10162600, 'Pipeline Imbalance Report', 'Pipeline Imbalance Report', 10160000, 'windowImbalance')
 	PRINT ' Inserted 10162600 - Pipeline Imbalance Report.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10162600 - Pipeline Imbalance Report already EXISTS.'
END

SET NOCOUNT OFF