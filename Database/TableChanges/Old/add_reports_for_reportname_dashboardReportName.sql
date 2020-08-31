/**************************************************
* Creted By : Mukesh Singh
* Created Date:21-Sept-2009
* Purpose : To add Report for Dash Board Reporting
*
***************************************************/
--'GHG Report' supports both plot and html type,report_type NULL means both.
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 1) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(1,'GHG Report','windowRunGHGTrackingReport',NULL)
END 
ELSE
	UPDATE dashboardReportName SET report_type=NULL WHERE template_id=1 

IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 2) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(2,'Credit Exposure Report','windowRunCreditExposureReport','h')
END 
--'Limit Report' supports both plot and html type,report_type NULL means both.
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 3) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(3,'Limit Report ','windowLimitsReport',NULL)

END
ELSE
	UPDATE dashboardReportName SET report_type=NULL WHERE template_id=3
 
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 4) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(4,'Export Credit Data Report ','windowExportCreditData','h')
END

IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 5) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(5,'Fixed/MTM Exposure Report ','windowRunFixdMtmExposureReport','h')
END
--'Exposure Concentration Report ' supports both plot and html type,report_type NULL means both.
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 6) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(6,'Exposure Concentration Report ','windowRunConcExposureReport',NULL)
END 
ELSE
	UPDATE dashboardReportName SET report_type=NULL WHERE template_id=6 

IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 7) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(7,'Credit Reserve Report ','windowCrRunReserveReport','h')
END 
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 8) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(8,'Aged A/R Report ','windowAgedARReport','h')
END 
--'windowCalculateCreditExposure' is not report to be listed in dashboard.
--IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 9) 
--BEGIN 
--	INSERT INTO dashboardReportName
--	(template_id,report_name,instance_name,report_type)
--	VALUES(9,'Calculate Credit Exposure ','windowCalculateCreditExposure','h')
--END
DELETE FROM dashboardReportName WHERE instance_name='windowCalculateCreditExposure';

--MTM Report supports both plot and html type,report_type NULL means both.
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 10) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(10,'MTM Report ','windowMTMReport',NULL)
END  
ELSE
	UPDATE dashboardReportName SET report_type=NULL WHERE template_id=10 

IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 11) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(11,'Position Report ','windowRunPositionReport','h')
END 

IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 12) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(12,'Options Report ','windowRunOptionsReport','h')
END   

--'Compliance Due Date Violation Report' is plot only.
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 13) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(13,'Compliance Due Date Violation Report','RunComplianceDateVoilationReport','p')
END

-- 'View Prices' supports both 'plot' and 'html' type.
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 14) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(14,'View Prices','windowViewPrices',NULL)
END

-- 'VaR Report' supports both 'plot' and 'html' type.
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 15) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type)
	VALUES(15,'VaR Report','windowVaRreport',NULL)
END

--************************************************************--

--Purpose: Adding 'module_type' column in 'dashboardReportName' table.
--'module_type' determines which reports need to be displayed in dashboard for particular module (trm,fas,ems)
-- 1st lowermost bit for "trm" ,2nd lowermost bit for "ems", 3rd lowermost bit for "fas"
	-- respective bit, 1 means available in that module, 0 means not available in that module.
-- xxxxx001 (for eg: module_type=1) available only in  "trm". 
-- xxxxx011 (for eg: module_type=3) available only in  "trm and ems"
-- xxxxx111 (for eg: module_type=7) available in       "trm, ems and fas"

IF NOT EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='dashboardReportName' AND COLUMN_NAME='module_type')
BEGIN
	ALTER TABLE dashboardReportName ADD module_type TINYINT
	PRINT '''module_type'' column added in ''dashboardReportName'' table.'
END
GO
--1	GHG Report
UPDATE dashboardReportName SET module_type=2 WHERE template_id=1 
--2	Credit Exposure Report
UPDATE dashboardReportName SET module_type=1 WHERE template_id=2 
--3	Limit Report 
UPDATE dashboardReportName SET module_type=1 WHERE template_id=3 
--4	Export Credit Data Report 
UPDATE dashboardReportName SET module_type=1 WHERE template_id=4 
--5	Fixed/MTM Exposure Report 
UPDATE dashboardReportName SET module_type=1 WHERE template_id=5 
--6	Exposure Concentration Report 
UPDATE dashboardReportName SET module_type=1 WHERE template_id=6 
--7	Credit Reserve Report 
UPDATE dashboardReportName SET module_type=1 WHERE template_id=7 
--8	Aged A/R Report 
UPDATE dashboardReportName SET module_type=1 WHERE template_id=8 
--10	MTM Report 
UPDATE dashboardReportName SET module_type=5 WHERE template_id=10 
--11	Position Report 
UPDATE dashboardReportName SET module_type=5 WHERE template_id=11
--12	Options Report 
UPDATE dashboardReportName SET module_type=1 WHERE template_id=12 
--13	Compliance Due Date Violation Report
UPDATE dashboardReportName SET module_type=7 WHERE template_id=13 
--14	View Prices
UPDATE dashboardReportName SET module_type=7 WHERE template_id=14 
--15	VaR Report
UPDATE dashboardReportName SET module_type=1 WHERE template_id=15 

--************************************************************--
--Adding more reports
--Position Reporting -> Run Trader Position Report
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 16) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type,module_type)
	VALUES(16,'Trader Position Report','windowRunTraderPositionReport','h',1)
END

--Settlement and Billing -> Run Settlement Report 
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 17) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type,module_type)
	VALUES(17,'Settlement Report','windowSettlementReport','h',1)
END

--************************************************************--
--Adding reports for 'ems' module
--Inventory And Reductions->Export Emissions Inventory/Reductions Data (HTML only/EMS module)
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 18) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type,module_type)
	VALUES(18,'Emissions Inventory/Reductions Data','windowMaintainEmsInvReport','h',2)
END

--Inventory And Reductions->Run Emissions Limit Report (Both/EMS Module)
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 19) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type,module_type)
	VALUES(19,'Emissions Limit Report','windowMaintainEmsInputReport',NULL,2)
END
--Inventory And Reductions->Benchmark Emissions Input & Output Data (Both/EMS Module)
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 20) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type,module_type)
	VALUES(20,'Benchmark Emissions Input & Output Data','windowRunEMSAnalyticalReport',NULL,2)
END
--Inventory And Reductions->Control Chart (Both/EMS Module)
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 21) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type,module_type)
	VALUES(21,'Control Chart','windowControlChart',NULL,2)
END
 --Inventory And Reductions->Run Emissions What-IF Report' (HTML only/EMS module)
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 22) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type,module_type)
	VALUES(22,'Emissions What-IF Report','windowRunEmissionsWhatIfReport','h',2)
END


--Inventory and Compliance Reporting->Run Target Report (HTML only/EMS module)
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 23) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type,module_type)
	VALUES(23,'Target Report','windowRunTargetReport','h',2)
END

--Inventory and Compliance Reporting->Run Inventory Position Report (HTML only/EMS module)
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 24) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type,module_type)
	VALUES(24,'Inventory Position Report','windowRunRecActivity','h',2)
END

--Inventory and Compliance Reporting->Run Transaction Report (HTML only/EMS module)
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 25) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type,module_type)
	VALUES(25,'Transaction Report','windowRunTransactionsReport','h',2)
END

--Inventory and Compliance Reporting->Run Compliance Report (HTML only/EMS module)
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 26) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type,module_type)
	VALUES(26,'Compliance Report','windowRecComplianceReport','h',2)
END

--Inventory and Compliance Reporting->Run Exposure Report (HTML only/EMS module)
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 27) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type,module_type)
	VALUES(27,'Exposure Report','windowRecExposureReport','h',2)
END

-- Inventory and Compliance Reporting->Run Market Value Report (HTML only/EMS module)
IF NOT EXISTS (SELECT 'x' FROM dashboardReportName WHERE template_id = 28) 
BEGIN 
	INSERT INTO dashboardReportName
	(template_id,report_name,instance_name,report_type,module_type)
	VALUES(28,'Market Value Report','windowRunMarketValueReport','h',2)
END
--************************************************************--

SELECT * FROM dashboardReportName