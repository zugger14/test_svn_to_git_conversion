
/*
* Adds new functionality LimitViolation for complaince activity
*/

IF NOT EXISTS (SELECT 1 FROM process_filters pf WHERE filterId = 'LimitViolation')
BEGIN
	INSERT INTO process_filters(filterId, tableName, colNameForValue, colNameForId,
	            precedence, allowMultiSelect)
	VALUES ('LimitViolation', 'static_data_type', 'type_name', 'type_id', 150, 'n')
	
	PRINT 'Process filter LimitViolation added.'
END
ELSE
BEGIN
	PRINT 'Process filter LimitViolation already exists.'
END

IF NOT EXISTS (SELECT 1 FROM process_control_header pf WHERE process_id = 8)
BEGIN
	SET IDENTITY_INSERT process_control_header ON
	INSERT INTO process_control_header(process_id, process_number, process_name,
	            process_owner)
	VALUES (8, '6', 'Trader Limit Violation Notification', 'farrms_admin')
	SET IDENTITY_INSERT process_control_header ON
	
	PRINT 'Process control Trader Limit Violation Notification added.'
END
ELSE
BEGIN
	PRINT 'Process control Trader Limit Violation Notification already exists.'
END

GO


IF NOT EXISTS (SELECT 1 FROM process_functions pf WHERE functionId = 120)
BEGIN
	INSERT INTO process_functions(functionId, functionDesc, userFuncionDesc,
	            process)
	VALUES (120, 'Limit Violation', 'Notify Trader on Limit Violation', 8)
	
	PRINT 'Process function Limit Violation added.'
END
ELSE
BEGIN
	PRINT 'Process function Limit Violation already exists.'
END

IF NOT EXISTS (SELECT 1 FROM process_functions_detail pfd WHERE functionId = 120)
BEGIN
	INSERT INTO process_functions_detail(functionId, filterId, userVendorFlag)
	VALUES (120, 'LimitViolation', 'v')
	
	PRINT 'Process function detail LimitViolation added.'
END
ELSE
BEGIN
	PRINT 'Process function detail LimitViolation already exists.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 6000)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (6000, 'Limit Violation', 1, 'Deal Volume Limit Violation', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 6000 - Limit Violation.'
END
ELSE
BEGIN
	PRINT 'Static data type 6000 - Limit Violation already EXISTS.'
END

GO
