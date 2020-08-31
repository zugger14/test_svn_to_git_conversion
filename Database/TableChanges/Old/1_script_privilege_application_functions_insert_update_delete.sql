
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233010)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233010, 'Delete', 'Delete Void Deal Data', 10233000, NULL)
 	PRINT ' Inserted 10233010 - Delete Void Deal Data.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233010 - Delete Void Deal Data already EXISTS.'
END
	
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10234410)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10234410, 'Run', 'Match Transaction Automate Matching of Hedges', 10234400, NULL)
 	PRINT ' Inserted 10234410 - Match Transaction Automate Matching of Hedges.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10234410 - Match Transaction Automate Matching of Hedges already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237011)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10237011, 'Delete', 'Maintain Manual Journal Entries Delete', 10237000, NULL)
 	PRINT ' Inserted 10237011 - Maintain Manual Journal Entries Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237011 - Maintain Manual Journal Entries Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233610)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233610, 'Run', 'Close Accounting Period IU', 10233600, 'windowCloseMeasurement')
 	PRINT ' Inserted 10233610 - Close Accounting Period IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233610 - Close Accounting Period IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233611)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233611, 'Delete', 'Close Accounting Period Delete', 10233600, 'windowCloseMeasurement')
 	PRINT ' Inserted 10233611 - Close Accounting Period Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233611 - Close Accounting Period Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233310)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233310, 'Copy', 'Copy Prior MTM Value IU', 10233300, 'windowPriorMTM')
 	PRINT ' Inserted 10233310 - Copy Prior MTM Value IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233310 - Copy Prior MTM Value IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233311)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233311, 'Delete', 'Copy Prior MTM Value Delete', 10233300, 'windowPriorMTM')
 	PRINT ' Inserted 10233311 - Copy Prior MTM Value Delete.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233311 - Copy Prior MTM Value Delete already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10237312)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10237312, 'Run', 'Run Cum PNL Series', 10237300, NULL)
 	PRINT ' Inserted 10237312 - Run.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10237312 - Run already EXISTS.'
END

IF NOT EXISTS(SELECT * FROM application_functions WHERE function_id = 10101510)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101510, 'Add/Save', 'Parent Netting Group IU', 10101500, 'parentNetGrpDetailIU')
 	PRINT ' Inserted 10101510 - Parent Netting Group IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101510 - Parent Netting Group IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101511)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10101511, 'Delete', 'Delete Parent Netting Group', 10101500, NULL)
 	PRINT ' Inserted 10101511 - Delete Parent Netting Group.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101511 - Delete Parent Netting Group already EXISTS.'
END

UPDATE application_functions SET function_name = 'Add/Save' WHERE function_id = 10237010	--Maintain Manual Journal Entries IU
UPDATE application_functions SET function_name = 'Add/Save' WHERE function_id = 10237310	--View/Update Cum PNL Series IU
UPDATE application_functions SET function_name = 'Delete' WHERE function_id = 10237311	--Delete Cum PNL Series
UPDATE application_functions SET function_name = 'Run', func_ref_id = 10234000 WHERE function_id = 10234011	--Reclassify Date
UPDATE application_functions SET func_ref_id = 10132000 where func_ref_id=10131000	--  changed from Create and View Deals to Create and View Deals New
UPDATE application_functions SET function_name = 'Add/Save/Delete' where function_id = 13102010
UPDATE application_functions SET function_name = 'Revert' WHERE function_id = 10234010	--Delete Reclassify Hedge De-Designation
UPDATE application_functions SET function_name = 'Delete' WHERE function_id = 10234110	--Delete Amortize Deferred AOCI
UPDATE application_functions SET function_name = 'Run' WHERE function_id = 10234111	--Amortize Amortize Deferred AOCI
UPDATE application_functions SET function_name = 'Run' WHERE function_id = 10234610	--Process First Day Gain/Loss Treatment
UPDATE application_functions SET function_name = 'Save' WHERE function_id = 10234611	--Update First Day Gain/Loss Treatment
UPDATE application_functions SET function_name = 'Revert' WHERE function_id = 10234612	--Delete First Day Gain/Loss Treatment
UPDATE application_functions SET function_name = 'Add/Save' WHERE function_id = 10231910	--Setup Hedging Relationship Types IU
UPDATE application_functions SET function_name = 'Delete' WHERE function_id = 10231912	--Delete Setup Hedging Relationship Types
UPDATE application_functions SET function_name = 'Add/Save' WHERE function_id = 10237310	--View/Update Cum PNL Series IU
UPDATE application_functions SET function_name = 'Delete' WHERE function_id = 10237311	--Delete Cum PNL Series
UPDATE application_functions SET function_name = 'Delete' WHERE function_id = 10234511	--Delete View Outstanding Automation Results
UPDATE application_functions SET function_name = 'Approve' WHERE function_id = 10234512	--Approve Relationships View Outstanding Automation Results
UPDATE application_functions SET function_name = 'Finalize' WHERE function_id = 10234514	--Finalized Approved Transactions
UPDATE application_functions SET function_name = 'Run' WHERE function_id = 10234310	--Select Deals Group
UPDATE application_functions SET function_name = 'Add/Save' WHERE function_id = 10233710	--Insert Hedging RelationShip
UPDATE application_functions SET function_name = 'Delete' WHERE function_id = 10233718	--Delete Hedging RelationShip
UPDATE application_functions SET function_name = 'Dedesignate' WHERE function_id = 10233719	--Dedesignate Hedging RelationShip
UPDATE application_functions SET function_name = 'Copy' WHERE function_id = 10233720	--Copy Hedging RelationShip
UPDATE application_functions SET function_name = 'Update/Delete Closed Link' WHERE function_id = 10233721	--Update/Delete Closed Hedge Relationship
UPDATE application_functions SET function_name = 'Contract', function_desc = 'Contract' where function_id = 10105830








-- Remove from privilege hierarchy
--UPDATE func_ref_id to null
UPDATE application_functions SET func_ref_id = NULL WHERE function_id IN (10101051,10101060,10104819,10131025,10237012
					,10234611,10234510,10234513,10234515,10234311,10234312,10233717,10233722,10233723)
UPDATE application_functions SET func_ref_id = NULL WHERE func_ref_id = 10231910 -- function ids are used in application ui template so only removed from privilege list.
UPDATE application_functions SET func_ref_id = 10106300 WHERE func_ref_id = 10104800	--DAta import export new 10106300
UPDATE application_functions SET func_ref_id = NULL WHERE func_ref_id = 10233710	--Insert Hedging RelationShip
