--Author: Tara Nath Subedi
--Purpose: Convert to TRM menu
--SET @convert2trm = 1, if you want to switch to TRM Menu.
--This file will be used for reversing purpose against to "Applicationfunctions_convert2fasmenu.sql"


DECLARE @convert2trm INT
SET @convert2trm = 0

IF @convert2trm = 1
BEGIN

	--============================--
	--update existing reference in function_id
	--============================--

	--Setup=>Maintain Static Data
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10100000'
		WHERE function_id=10101000
		PRINT '10101000 Updated.'
	END 

	--Setup=>Maintain Definition
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101100)
	BEGIN 
		UPDATE application_functions set func_ref_id='10100000'
		WHERE function_id=10101100
		PRINT '10101100 Updated.'
	END 

	--Setup=>Setup Book Structure
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101200)
	BEGIN 
		UPDATE application_functions set func_ref_id='10100000'
		WHERE function_id=10101200
		PRINT '10101200 Updated.'
	END 

	--Setup=>Map GL Codes
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101300)
	BEGIN 
		UPDATE application_functions set func_ref_id='10100000'
		WHERE function_id=10101300
		PRINT '10101300 Updated.'
	END 

	--Setup=>Maintain Deal Template
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101400)
	BEGIN 
		UPDATE application_functions set func_ref_id='10100000'
		WHERE function_id=10101400
		PRINT '10101400 Updated.'
	END 

	--Setup=>Maintain Netting Asset/Liab Groups
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101500)
	BEGIN 
		UPDATE application_functions set func_ref_id='10100000'
		WHERE function_id=10101500
		PRINT '10101500 Updated.'
	END 

	--Setup=>Maintain Configuration Parameter
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101700)
	BEGIN 
		UPDATE application_functions set func_ref_id='10100000'
		WHERE function_id=10101700
		PRINT '10101700 Updated.'
	END 

	--Setup=>Configure Interface Timeout Parameter
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10101800)
	BEGIN 
		UPDATE application_functions set func_ref_id='10100000'
		WHERE function_id=10101800
		PRINT '10101800 Updated.'
	END 

	--Setup=>Setup As of Date
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10102200)
	BEGIN 
		UPDATE application_functions set func_ref_id='10100000'
		WHERE function_id=10102200
		PRINT '10102200 Updated.'
	END 

	--Users and Roles=>Maintain Users
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10111000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10110000'
		WHERE function_id=10111000
		PRINT '10111000 Updated.'
	END 

	--Users and Roles=>Maintain Roles
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10111100)
	BEGIN 
		UPDATE application_functions set func_ref_id='10110000'
		WHERE function_id=10111100
		PRINT '10111100 Updated.'
	END 

	--Users and Roles=>Maintain Work Flow Menu
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10111200)
	BEGIN 
		UPDATE application_functions set func_ref_id='10110000'
		WHERE function_id=10111200
		PRINT '10111200 Updated.'
	END 

	--Users and Roles=>Run Privilege Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10111300)
	BEGIN 
		UPDATE application_functions set func_ref_id='10110000'
		WHERE function_id=10111300
		PRINT '10111300 Updated.'
	END 

	--Users and Roles=>Run System Access Log Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10111400)
	BEGIN 
		UPDATE application_functions set func_ref_id='10110000'
		WHERE function_id=10111400
		PRINT '10111400 Updated.'
	END 

	--Deal Capture=>Maintain Transactions
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10131000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10130000'
		WHERE function_id=10131000
		PRINT '10131000 Updated.'
	END 

	--Position Reporting=>Run Position Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10141000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10140000'
		WHERE function_id=10141000
		PRINT '10141000 Updated.'
	END 

	--Price Curve Management=>View Prices
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10151000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10150000'
		WHERE function_id=10151000
		PRINT '10151000 Updated.'
	END 

	--Valuation And Risk Analysis=>Run MTM
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10181000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10180000'
		WHERE function_id=10181000
		PRINT '10181000 Updated.'
	END 

	--Valuation And Risk Analysis=>Run MTM Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10181100)
	BEGIN 
		UPDATE application_functions set func_ref_id='10180000'
		WHERE function_id=10181100
		PRINT '10181100 Updated.'
	END 

	--Reporting=>Report Writer
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10201000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10200000'
		WHERE function_id=10201000
		PRINT '10201000 Updated.'
	END 

	--Accounting=>Setup Hedging Relationship Types
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10231900)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10231900
		PRINT '10231900 Updated.'
	END 

	--Accounting=>Run Hedging Relationship Types Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10232000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10232000
		PRINT '10232000 Updated.'
	END 

	--Accounting=>Manage Documents
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10232200)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10232200
		PRINT '10232200 Updated.'
	END 

	--Accounting=>Run Assessment
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10232300)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10232300
		PRINT '10232300 Updated.'
	END 

	--Accounting=>View Assessment Results
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10232400)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10232400
		PRINT '10232400 Updated.'
	END 

	--Accounting=>Run Assessment Trend Graph
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10232500)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10232500
		PRINT '10232500 Updated.'
	END 

	--Accounting=>Run What-If Effectiveness Analysis
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10232600)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10232600
		PRINT '10232600 Updated.'
	END 

	--Accounting=>Import Data
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10232700)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10232700
		PRINT '10232700 Updated.'
	END 

	--Accounting=>Run Import Audit Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10232800)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10232800
		PRINT '10232800 Updated.'
	END 

	--Accounting=>Maintain Missing Static Data
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10232900)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10232900
		PRINT '10232900 Updated.'
	END 

	--Accounting=>Delete Voided Deal
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10233000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10233000
		PRINT '10233000 Updated.'
	END 

	--Accounting=>Run What-If Measurement Analysis
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10233200)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10233200
		PRINT '10233200 Updated.'
	END 

	--Accounting=>Copy Prior MTM Value
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10233300)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10233300
		PRINT '10233300 Updated.'
	END 

	--Accounting=>Run Measurement
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10233400)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10233400
		PRINT '10233400 Updated.'
	END 

	--Accounting=>Run Calc Embedded Derivative
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10233500)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10233500
		PRINT '10233500 Updated.'
	END 

	--Accounting=>Close Accounting Period
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10233600)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10233600
		PRINT '10233600 Updated.'
	END 

	--Accounting=>Designation of a Hedge
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10233700)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10233700
		PRINT '10233700 Updated.'
	END 

	--Accounting=>De-Designation of a Hedge by FIFO/LIFO
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10233800)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10233800
		PRINT '10233800 Updated.'
	END 

	--Accounting=>Run Hedging Relationship Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10233900)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10233900
		PRINT '10233900 Updated.'
	END 

	--Accounting=>Reclassify Hedge De-Designation
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10234000
		PRINT '10234000 Updated.'
	END 

	--Accounting=>Amortize Deferred AOCI
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234100)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10234100
		PRINT '10234100 Updated.'
	END 

	--Accounting=>Life Cycle of Hedges
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234200)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10234200
		PRINT '10234200 Updated.'
	END 

	--Accounting=>Automation of Forecasted Transaction
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234300)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10234300
		PRINT '10234300 Updated.'
	END 

	--Accounting=>Automate Matching of Hedges
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234400)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10234400
		PRINT '10234400 Updated.'
	END 

	--Accounting=>View Outstanding Automation Results
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234500)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10234500
		PRINT '10234500 Updated.'
	END 

	--Accounting=>First Day Gain/Loss Treatment
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234600)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10234600
		PRINT '10234600 Updated.'
	END 

	--Accounting=>Maintain Transactions Tagging
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234700)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10234700
		PRINT '10234700 Updated.'
	END 

	--Accounting=>Bifurcation Of Embedded Derivatives
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234800)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10234800
		PRINT '10234800 Updated.'
	END 

	--Accounting=>Run Measurement Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10234900)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10234900
		PRINT '10234900 Updated.'
	END 

	--Accounting=>Run Measurement Trend Graph
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10235000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10235000
		PRINT '10235000 Updated.'
	END 

	--Accounting=>Run Period Change Values Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10235100)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10235100
		PRINT '10235100 Updated.'
	END 

	--Accounting=>Run AOCI Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10235200)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10235200
		PRINT '10235200 Updated.'
	END 

	--Accounting=>Run De-Designation Values Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10235300)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10235300
		PRINT '10235300 Updated.'
	END 

	--Accounting=>Run Journal Entry Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10235400)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10235400
		PRINT '10235400 Updated.'
	END 

	--Accounting=>Run Netted Journal Entry Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10235500)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10235500
		PRINT '10235500 Updated.'
	END 

	--Accounting=>Run Accounting Disclosure Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10235600)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10235600
		PRINT '10235600 Updated.'
	END 

	--Accounting=>Run Fair Value Disclosure Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10235700)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10235700
		PRINT '10235700 Updated.'
	END 

	--Accounting=>Run Assessment Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10235800)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10235800
		PRINT '10235800 Updated.'
	END 

	--Accounting=>Run Transaction Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10235900)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10235900
		PRINT '10235900 Updated.'
	END 

	--Accounting=>Run Tagging Export
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10236000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10236000
		PRINT '10236000 Updated.'
	END 

	--Accounting=>Run Missing Assessment Values Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10236100)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10236100
		PRINT '10236100 Updated.'
	END 

	--Accounting=>Run Failed Assessment Values Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10236200)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10236200
		PRINT '10236200 Updated.'
	END 

	--Accounting=>Run Unapproved Hedging Relationship Exception Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10236300)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10236300
		PRINT '10236300 Updated.'
	END 

	--Accounting=>Run Available Hedge Capacity Exception Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10236400)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10236400
		PRINT '10236400 Updated.'
	END 

	--Accounting=>Run Not Mapped Transaction Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10236500)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10236500
		PRINT '10236500 Updated.'
	END 

	--Accounting=>Run Tagging Audit Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10236600)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10236600
		PRINT '10236600 Updated.'
	END 

	--Accounting=>Run Hedge and Item Position Matching Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10236700)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10236700
		PRINT '10236700 Updated.'
	END 

	--Accounting=>Maintain Manual Journal Entries
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10237000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10237000
		PRINT '10237000 Updated.'
	END 

	--Treasury=>Reconcile Cash Entries for Derivatives
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10241000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10240000'
		WHERE function_id=10241000
		PRINT '10241000 Updated.'
	END 

	--Accounting->View/Update Cum PNL Series
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10237300)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=10237300
		PRINT '10237300 Updated.'
	END 
	
	--Compliance Management->Maintain Compliance Groups
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10121000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10120000'
		WHERE function_id=10121000
		PRINT '10121000 Updated.'
	END 

	--Compliance Management->Activity Process Map
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 10121400)
	BEGIN 
		UPDATE application_functions set func_ref_id='10120000'
		WHERE function_id=10121400
		PRINT '10121400 Updated.'
	END
	
		
	--Accounting->Derivative->Reporting->Run Hedging Relationship Audit Report
	IF EXISTS (SELECT 'x' FROM application_functions WHERE function_id = 13160000)
	BEGIN 
		UPDATE application_functions set func_ref_id='10230000'
		WHERE function_id=13160000
		PRINT '13160000 Updated.'
	END
	
	
END
