IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10231900)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10231900, 'Setup Hedging Relationship Types', 'Setup Hedging Relationship Types', 10230000, 'windowSetupHedgingRelationshipsTypes')
 	PRINT ' Inserted 10231900 - Setup Hedging Relationship Types.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10231900 - Setup Hedging Relationship Types already EXISTS.'
END
IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10231910)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10231910, 'Setup Hedging Relationship Types IU', 'Setup Hedging Relationship Types IU', 10231900, 'windowSetupHedgingRelationshipsTypesDetail')
 	PRINT ' Inserted 10231910 - Setup Hedging Relationship Types IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10231910 - Setup Hedging Relationship Types IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10231912)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10231912, 'Delete Setup Hedging Relationship Types', 'Delete Setup Hedging Relationship Types', 10231900, NULL)
 	PRINT ' Inserted 10231912 - Delete Setup Hedging Relationship Types.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10231912 - Delete Setup Hedging Relationship Types already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10231913)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10231913, 'Hedge/Item Relationship types IU', 'Hedge/Item Relationship types IU', 10231910, 'windowSetupHedgingRelationshipsTypesDetailHedgingItems')
 	PRINT ' Inserted 10231913 - Hedge/Item Relationship types IU.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10231913 - Hedge/Item Relationship types IU already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10231914)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10231914, 'Delete Hedging Relationship type', 'Delete Hedging Relationship type', 10231910, NULL)
 	PRINT ' Inserted 10231914 - Delete Hedging Relationship type.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10231914 - Delete Hedging Relationship type already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10231915)
BEGIN
 	INSERT INTO application_functions(function_id, function_name, function_desc, func_ref_id, function_call)
	VALUES (10231915, 'Delete Item Relationship type', 'Delete Item Relationship type', 10231910, NULL)
 	PRINT ' Inserted 10231915 - Delete Item Relationship type.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10231915 - Delete Item Relationship type already EXISTS.'
END
