IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233700)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233700, 'Designation of a Hedge', 'Designation of a Hedge', 10230000, 'windowDesignationofaHedgeFromMenu')
 	PRINT ' Inserted 10233700 - Designation of a Hedge.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233700 - Designation of a Hedge already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233710)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233710, 'Insert Hedging RelationShip', 'Insert Hedging RelationShip', 10233700, 'windowDesignationofaHedgeFromMenu')
 	PRINT ' Inserted 10233710 - Insert Hedging RelationShip.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233710 - Insert Hedging RelationShip already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233711)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233711, 'Run Analysis Hedging RelationShip', 'Run Analysis Hedging RelationShip', 10233710, 'windowHedgingRunEffectiveness')
 	PRINT ' Inserted 10233711 - Run Analysis Hedging RelationShip.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233711 - Run Analysis Hedging RelationShip already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233712)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233712, 'Delete Dedesignation', 'Delete Dedesignation', 10233710, NULL)
 	PRINT ' Inserted 10233712 - Delete Dedesignation.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233712 - Delete Dedesignation already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233713)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233713, 'Hedges IU', 'Hedges IU', 10233710, 'windowSelectDealDetail')
 	PRINT ' Inserted 10233713 - Hedges IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233713 - Hedges IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233714)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233714, 'Delete Hedges', 'Delete Hedges', 10233710, NULL)
 	PRINT ' Inserted 10233714 - Delete Hedges.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233714 - Delete Hedges already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233715)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233715, 'Hedge Items IU', 'Hedge Items IU', 10233710, 'windowSelectDealDetail')
 	PRINT ' Inserted 10233715 - Hedge Items IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233715 - Hedge Items IU already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233716)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233716, 'Delete Hedge Items', 'Delete Hedge Items', 10233710, NULL)
 	PRINT ' Inserted 10233716 - Delete Hedge Items.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233716 - Delete Hedge Items already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233717)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233717, 'Detail Hedging RelationShip', 'Detail Hedging RelationShip', 10233700, NULL)
 	PRINT ' Inserted 10233717 - Detail Hedging RelationShip.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233717 - Detail Hedging RelationShip already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233718)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233718, 'Delete Hedging RelationShip', 'Delete Hedging RelationShip', 10233700, NULL)
 	PRINT ' Inserted 10233718 - Delete Hedging RelationShip.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233718 - Delete Hedging RelationShip already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233719)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233719, 'Dedesignate Hedging RelationShip', 'Dedesignate Hedging RelationShip', 10233700, 'windowDedesignateMutlipleHedges')
 	PRINT ' Inserted 10233719 - Dedesignate Hedging RelationShip.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233719 - Dedesignate Hedging RelationShip already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233720)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233720, 'Copy Hedging RelationShip', 'Copy Hedging RelationShip', 10233700, 'windowCopyLink')
 	PRINT ' Inserted 10233720 - Copy Hedging RelationShip.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233720 - Copy Hedging RelationShip already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10233721)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10233721, 'Update/Delete Closed Hedge Relationship', 'Update/Delete Closed Hedge Relationship', 10233700, NULL)
 	PRINT ' Inserted 10233721 - Update/Delete Closed Hedge Relationship.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10233721 - Update/Delete Closed Hedge Relationship already EXISTS.'
END
