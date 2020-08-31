/* 
 *	Deal Modules 
 */
IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20601 AND event_id = 20501)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20601,20501,0  
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20601 AND event_id = 20502)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20601,20502,1
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20601 AND event_id = 20503)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20601,20503,0 
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20601 AND event_id = 20504)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20601,20504,1 
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20601 AND event_id = 20505)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20601,20505,0
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20601 AND event_id = 20506)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20601,20506,1
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20601 AND event_id = 20536)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20601,20536,1
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20601 AND event_id = 20537)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20601,20537,1
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20601 AND event_id = 20513)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20601,20513,0
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20601 AND event_id = 20509)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20601,20509,0
END

/* 
 * Contract Modules 
 */
IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20603 AND event_id = 20510)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20603,20510,1 
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20603 AND event_id = 20511)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20603,20511,1
END

/* 
 * Invoice Modules 
 */
IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20605 AND event_id = 20512)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20605,20512,1
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20605 AND event_id = 20525)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20605,20525,1
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20605 AND event_id = 20526)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20605,20526,1 
END

/* 
 * Calender Module 
 */
IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20610 AND event_id = 20534)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20610,20534,1
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20610 AND event_id = 20535)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20610,20535,1 
END

/* 
 * Scheduling Module 
 */
IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20611 AND event_id = 20527)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20611,20527,1
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20611 AND event_id = 20528)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20611,20528,0
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20611 AND event_id = 20529)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20611,20529,0
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20611 AND event_id = 20530)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20611,20530,1 
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20611 AND event_id = 20531)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20611,20531,0
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20611 AND event_id = 20532)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20611,20532,0
END


/* 
 * Generic Module 
 */
IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20611 AND event_id = 20548)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT -1,20548,1
END

IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20611 AND event_id = 20538)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT -1,20538,1
END
