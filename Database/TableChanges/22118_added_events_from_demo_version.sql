SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20570)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20570, 20500, 'Counterparty Credit Limit Insert', 'Counterparty Credit Limit Insert', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20570 - Counterparty Credit Limit Insert.'
END
ELSE
BEGIN
    PRINT 'Static data value 20570 - Counterparty Credit Limit Insert already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


IF NOT EXISTS(SELECT 1 FROM workflow_module_event_mapping WHERE event_id = 20570 AND module_id = 20609)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20609, 20570, 1
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20577)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20577, 20500, 'Counterparty Credit Limit Insert Update', 'Counterparty Credit Limit Insert Update', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20577 - Counterparty Credit Limit Insert Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20577 - Counterparty Credit Limit Insert Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM workflow_module_event_mapping WHERE event_id = 20577 AND module_id = 20609)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20609, 20577, 1
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20578)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20578, 20500, 'Counterparty Credit File Insert Update', 'Counterparty Credit File Insert Update', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20578 - Counterparty Credit File Insert Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20578 - Counterparty Credit File Insert Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM workflow_module_event_mapping WHERE event_id = 20578 AND module_id = 20604)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20604, 20578, 1
END

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20576)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20576, 20500, 'Credit Enhancement Insert Update', 'Credit Enhancement Insert Update', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20576 - Credit Enhancement Insert Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20576 - Credit Enhancement Insert Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM workflow_module_event_mapping WHERE event_id = 20576 AND module_id = 20618)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20618, 20576, 1
END


