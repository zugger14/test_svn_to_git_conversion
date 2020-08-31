SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20631)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20600, 20631, 'Designation of a Hedge', 'Designation of a Hedge', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20631 - Designation of a Hedge.'
END
ELSE
BEGIN
    PRINT 'Static data value 20631 - Designation of a Hedge already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20591)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20500, 20591, 'Designation of a Hedge - Post Link Insert/Update', 'Designation of a Hedge - Post Link Insert/Update', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20591 - Designation of a Hedge - Post Link Insert/Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20591 - Designation of a Hedge - Post Link Insert already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF  
          
UPDATE static_data_value
SET [code] = 'Designation of a Hedge - Post Link Insert/Update',
    [category_id] = NULL
WHERE [value_id] = 20591

PRINT 'Updated Static value 20591 - Designation of a Hedge - Post Link Insert/Update.'        
IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20631 AND event_id = 20591)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20631,20591,1
END