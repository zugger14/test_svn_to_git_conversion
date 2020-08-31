
UPDATE af SET af.func_ref_id = NULL
FROM setup_menu sm
INNER JOIN application_functions af ON af.function_id = sm.function_id 

--Insert script
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10201600 AND parent_menu_id = 13121295 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10201600,
		'windowReportManager',
		'Report Manager',
		1,
		13121295,
		13000000,
		4
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10101400 AND parent_menu_id = 10100000 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10101400,
		'windowMaintainDealTemplate',
		'Setup Deal Templates',
		1,
		10100000,
		13000000,
		4
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10104100 AND parent_menu_id = 10100000 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10104100,
		'windowSetupUDFTemplate',
		'Setup UDF Template',
		1,
		10100000,
		13000000,
		6
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'
	
	

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10104200 AND parent_menu_id = 10100000 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10104200,
		'windowSetupFieldTemplate',
		'Setup Field Template',
		1,
		10100000,
		13000000,
		5
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	

	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10122500 AND parent_menu_id = 10100000 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10122500,
		'windowMaintainAlerts',
		'Maintain Events Rule',
		1,
		10100000,
		13000000,
		7
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
	
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10101500 AND parent_menu_id = 10100000 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10101500,
		'windowMaintainNettingGroups',
		'Setup Netting Group',
		1,
		10100000,
		13000000,
		8
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	

	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10101182 AND parent_menu_id = 10100000 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10101182,
		'WindowDefineUOMConversion',
		'Setup UOM Conversion',
		1,
		10100000,
		13000000,
		9
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
	
	
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10104900 AND parent_menu_id = 10100000 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10104900,
		'windowEmailSetup',
		'Compose Email',
		1,
		10100000,
		13000000,
		10
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
		
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10105800 AND parent_menu_id = 10101099 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10105800,
		'windowSetupCounterparty',
		'Setup Counterparty',
		1,
		10101099,
		13000000,
		5
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10232000 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10232000,
		NULL,
		'Hedging Relationship Types Report',
		1,
		10202200,
		13000000,
		1
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10234900 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10234900,
		NULL,
		'Measurement Report',
		1,
		10202200,
		13000000,
		2
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10142400 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10142400,
		NULL,
		'Derivative Position Report',
		1,
		10202200,
		13000000,
		3
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
	
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10236400 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10236400,
		NULL,
		'Available Hedge Capacity Exception Report',
		1,
		10202200,
		13000000,
		4
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
		
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10235400 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10235400,
		NULL,
		'Journal Entries Report',
		1,
		10202200,
		13000000,
		5
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
		
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10233900 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10233900,
		NULL,
		'Hedging Relationship Report',
		1,
		10202200,
		13000000,
		6
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
			
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10236500 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10236500,
		NULL,
		'Not Mapped Transaction Report',
		1,
		10202200,
		13000000,
		7
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
			
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10235200 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10235200,
		NULL,
		'AOCI Report',
		1,
		10202200,
		13000000,
		8
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
					
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10235800 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10235800,
		NULL,
		'Assessment Report',
		1,
		10202200,
		13000000,
		9
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
					
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 13160000 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		13160000,
		NULL,
		'Hedging Relationship Audit Report',
		1,
		10202200,
		13000000,
		10
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
					
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10235500 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10235500,
		NULL,
		'Netted Journal Entry Report',
		1,
		10202200,
		13000000,
		11
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
						
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10235600 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10235600,
		NULL,
		'Accounting Disclosure Report',
		1,
		10202200,
		13000000,
		12
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
		
						
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10235700 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10235700,
		NULL,
		'Fair Value Disclosure Report',
		1,
		10202200,
		13000000,
		13
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
						
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10235100 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10235100,
		NULL,
		'Period Change Values Report',
		1,
		10202200,
		13000000,
		14
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
						
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10236600 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10236600,
		NULL,
		'Tagging Audit Report',
		1,
		10202200,
		13000000,
		15
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
							
IF NOT EXISTS(SELECT * FROM setup_menu WHERE function_id = 13121200 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		13121200,
		NULL,
		'Hedge Ineffectiveness Report',
		1,
		10202200,
		13000000,
		16
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
							
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10235300 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10235300,
		NULL,
		'De-designation Values Report',
		1,
		10202200,
		13000000,
		17
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
							
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10236100 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10236100,
		NULL,
		'Missing Assessment Values Report',
		1,
		10202200,
		13000000,
		18
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	

	
								
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10236200 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10236200,
		NULL,
		'Failed Assessment Values Report',
		1,
		10202200,
		13000000,
		19
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
									
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10232800 AND parent_menu_id = 10202200 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10232800,
		NULL,
		'Import Audit Report',
		1,
		10202200,
		13000000,
		20
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	

--TRM specfic view reports
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10161400 AND parent_menu_id = 10202200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10161400,
		NULL,
		'Gas Storage Position Report',
		1,
		10202200,
		10000000,
		1
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	

IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10162600 AND parent_menu_id = 10202200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10162600,
		NULL,
		'Pipeline Imbalance Report',
		1,
		10202200,
		10000000,
		2
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10202000 AND parent_menu_id = 10202200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10202000,
		NULL,
		'User Activity Log Report',
		1,
		10202200,
		10000000,
		3
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10202100 AND parent_menu_id = 10202200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10202100,
		NULL,
		'Message Board Log Report',
		1,
		10202200,
		10000000,
		4
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	


IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10202201 AND parent_menu_id = 10202200 AND product_category = 10000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10202201,
		NULL,
		'SAP Settlement Export',
		1,
		10202200,
		10000000,
		5
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	

									
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10211213 AND parent_menu_id = 10100000 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10211213,
		NULL,
		'Setup Custom Report Template',
		1,
		10100000,
		13000000,
		6
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	
									
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10211213 AND parent_menu_id = 10100000 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10211213,
		NULL,
		'Setup Custom Report Template',
		1,
		10100000,
		13000000,
		6
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
									
IF NOT EXISTS(SELECT 1 FROM setup_menu WHERE function_id = 10101500 AND parent_menu_id = 10100000 AND product_category = 13000000)
BEGIN
	INSERT INTO setup_menu (
		function_id,
		window_name,
		display_name,
		hide_show,
		parent_menu_id,
		product_category,
		menu_order
	) 
	VALUES (
		10101500,
		NULL,
		'Setup Netting Group',
		1,
		10100000,
		13000000,
		7
	)
END
ELSE
	PRINT 'This function ID already exists in menu.'	
	



UPDATE setup_menu set parent_menu_id = 13000000 where product_category = 13000000 AND function_id IN (10100000,10110000,10120000,13121295,13180000,10233499,13200000)
UPDATE setup_menu SET function_id = 10130000  where  function_id = 10131099 and product_category = 13000000
UPDATE setup_menu SET parent_menu_id = 10130000  where  parent_menu_id = 10131099 and product_category = 13000000

--setup 10100000
UPDATE setup_menu SET parent_menu_id = 10101099  where function_id = 10105800 and product_category = 13000000 
UPDATE setup_menu SET parent_menu_id = 10100000  where function_id = 13102000 and product_category = 13000000

 
UPDATE setup_menu SET parent_menu_id = 13180000  where function_id = 10106300 and product_category = 13000000 
UPDATE setup_menu SET parent_menu_id = 13180000  where function_id = 10131300 and product_category = 13000000 
UPDATE setup_menu SET parent_menu_id = 13180000  where function_id = 10233000 and product_category = 13000000 

--Hedge Management
UPDATE setup_menu SET parent_menu_id = 10231997  where function_id = 10231900 and product_category = 13000000 --Setup Hedging Relationship Types
UPDATE setup_menu SET parent_menu_id = 12193099  where function_id = 10234000 and product_category = 13000000 --Reclassify Hedge De-Designation

--Hedge Effectiveness Testing 13200000
UPDATE setup_menu SET parent_menu_id = 13200000  where function_id = 10151000 and product_category = 13000000 --View Prices
UPDATE setup_menu SET parent_menu_id = 13200000  where function_id = 10237300 and product_category = 13000000 --View/Update Cum PNL Series
UPDATE setup_menu SET parent_menu_id = 13200000  where function_id = 10232300 and product_category = 13000000 --Hedge Effectiveness Assessment

UPDATE setup_menu SET display_name = 'Reference Data'  where display_name = 'Setup Static Data' and menu_type = 1 and product_category = 13000000 
UPDATE setup_menu SET display_name = 'Deal Capture'  where display_name = 'Deal Capture and Tagging' and menu_type = 1 and product_category = 13000000
UPDATE setup_menu SET display_name = 'Data Import/Export'  where display_name = 'Data Import/Export New UI'  --and product_category = 13000000
UPDATE setup_menu SET display_name = 'Create and View Deals'  where display_name = 'Create and View Deals New'  and product_category = 13000000
UPDATE setup_menu SET display_name = 'Run MTM Process' where display_name = 'Calc MTM' and product_category = 13000000
	
	
--Update menu type to 1
UPDATE setup_menu SET menu_type = 1 WHERE function_id IN ( 13190000,13200000,13210000,13180000)

--Set to hide menu from menu list but display in privilege hierarchy
UPDATE setup_menu SET hide_show = 0 where parent_menu_id = 10202200

--remove from setup menu
DELETE from setup_menu where function_id = 10101100  and product_category = 13000000  --Maintain Definition
DELETE from setup_menu where function_id = 10102800  and product_category = 13000000  --Setup Profile
DELETE from setup_menu where function_id = 10101499  and product_category = 13000000  --Setup Deal Templates
DELETE from setup_menu where function_id = 10101900  and product_category = 13000000   --	Setup Logical Trade Lock
DELETE from setup_menu where function_id = 10102000  and product_category = 13000000   --	Setup Tenor Bucket
DELETE from setup_menu where function_id = 10102200  and product_category = 13000000   --	Setup As of Date
DELETE from setup_menu where function_id = 10102300  and product_category = 13000000   --		Setup Emissions Source/Sink Type
DELETE from setup_menu where function_id = 10102799  and product_category = 13000000   --		Manage Data
DELETE from setup_menu where function_id = 10103000  and product_category = 13000000   --		Define Meter IDs
DELETE from setup_menu where function_id = 10103399  and product_category = 13000000   --		Setup Contract Components
DELETE from setup_menu where function_id = 10103800  and product_category = 13000000   --		Maintain Source Generator
DELETE from setup_menu where function_id = 13170000  and product_category = 13000000   --		Mapping Setup
DELETE from setup_menu where function_id = 10111300  and product_category = 13000000	-- Run Privilege Report
DELETE from setup_menu where function_id = 10111400  and product_category = 13000000	-- Run System Access Log Report
DELETE from setup_menu where function_id = 10111500  and product_category = 13000000	--Maintain Report
DELETE from setup_menu where function_id = 10120000  and product_category = 13000000	-- Compliance Management
DELETE from setup_menu where function_id = 10234800  and product_category = 13000000	-- Bifurcation Of Embedded Derivatives
DELETE from setup_menu where function_id = 10238000  and product_category = 13000000	-- Maintain Transactions Tagging
DELETE from setup_menu where function_id = 10131000  and product_category = 13000000	-- Create and View Deals
DELETE from setup_menu where function_id = 10231996  and product_category = 13000000	-- Hedge Management duplicate data
DELETE from setup_menu where parent_menu_id = 10231996  and product_category = 13000000	-- Hedge Management
DELETE from setup_menu where function_id = 12191099  and product_category = 13000000	-- Effectiveness Reporting
DELETE from setup_menu where function_id = 10235699  and product_category = 13000000	-- Disclosures
DELETE from setup_menu where function_id = 13220000  and product_category = 13000000	-- Disclosures menu
DELETE from setup_menu where parent_menu_id = 13220000  and product_category = 13000000	-- Disclosures sub menu
DELETE from setup_menu where function_id = 10230095  and product_category = 13000000	-- Accounting derivative Transaction Processing
DELETE from setup_menu where function_id = 10241000  and product_category = 13000000	-- Reconcile Cash Entries for Derivatives
DELETE from setup_menu where function_id = 10230095  and product_category = 13000000	-- Accounting derivative Transaction Processing
DELETE from setup_menu where function_id = 10131399  and product_category = 13000000	-- ETrm dup data
DELETE from setup_menu where function_id = 10232900  and product_category = 13000000 --- Maintain Missing Static Data
DELETE from setup_menu where function_id = 10232400  and product_category = 13000000 --- View Assessment Results
DELETE from setup_menu where function_id = 10232500  and product_category = 13000000 --- Run Assessment Trend Graph
DELETE from setup_menu where function_id = 10232600  and product_category = 13000000 --- Run What-If Effectiveness Analysis
DELETE from setup_menu where function_id = 10151099  and product_category = 13000000  -- Hedge Effectiveness Testing
DELETE from setup_menu where function_id = 10233800  and product_category = 13000000	-- De-Designation of a Hedge by FIFO/LIFO
DELETE from setup_menu where function_id = 10233896  and product_category = 13000000	-- Hedge Designation / De-Designation Based on Dynamic Limit
DELETE from setup_menu where function_id = 10233499  and product_category = 13000000	-- --Hedge Ineffectiveness Measurement
DELETE from setup_menu where function_id = 10181100  and product_category = 13000000	-- --Run MTM Report
DELETE from setup_menu where function_id = 10233200  and product_category = 13000000	-- -Run What-If Measurement Analysis
DELETE from setup_menu where function_id = 10233500  and product_category = 13000000	-- -Calc Embedded Derivative
DELETE from setup_menu where function_id = 13151000  and product_category = 13000000	-- -Calc Dynamic Limit and Designaton/ De-designation
DELETE from setup_menu where function_id = 13121299  and product_category = 13000000	--Effectiveness Reporting
DELETE from setup_menu where function_id = 13121298  and product_category = 13000000	--Position Reporting
DELETE from setup_menu where function_id = 13121297  and product_category = 13000000	--Audit Reporting
DELETE from setup_menu where function_id = 13121296  and product_category = 13000000	--Exception Reporting
DELETE from setup_menu where function_id = 10234200  and product_category = 13000000	--Life Cycle of Hedges 
DELETE from setup_menu where function_id = 10104800  --and product_category IN (10000000,13000000)	--Data Import/Export old one
DELETE from setup_menu where parent_menu_id = 13121299 and product_category = 13000000 -- Effectiveness Reporting menu does not extists.
DELETE from setup_menu where parent_menu_id = 10101499 and function_id in (10104100,10104200) and product_category = 13000000 -- Removed from Setup Deal Template.
DELETE from setup_menu where parent_menu_id = 13121298 and product_category = 13000000 -- Position Reporting menu does not extists.
DELETE from setup_menu where parent_menu_id = 13121297 and product_category = 13000000 -- Audit Reporting menu does not extists.
DELETE from setup_menu where parent_menu_id = 13121296 and product_category = 13000000 -- Exception Reporting menu does not extists. 
DELETE from setup_menu where parent_menu_id = 10103399  and product_category = 13000000   --		Setup Contract Components  menu doesnot exists
DELETE from setup_menu where parent_menu_id = 10101499  and product_category = 13000000   --		Setup Deal Templates  menu of this id doesnot exists
DELETE from setup_menu where function_id = 10234700  and product_category = 13000000	--Maintain Deal Transfer

