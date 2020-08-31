-- Module
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20622)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20622, 20600, 'Counterparty Contract', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20622 - Counterparty Contract.'
END
ELSE
BEGIN
    PRINT 'Static data value 20622 - Counterparty Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--Events
--1.Counterparty Contract Insert 
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20571)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20571, 20500, 'Counterparty Contract Insert', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20571 - Counterparty Contract Insert.'
END
ELSE
BEGIN
    PRINT 'Static data value 20571 - Counterparty Contract Insert already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--2.Counterparty Contract Update
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20572)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20572, 20500, 'Counterparty Contract Update', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20572 - Counterparty Contract Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20572 - Counterparty Contract Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--3.Counterparty Contract Insert Update
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20575)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20575, 20500, 'Counterparty Contract Insert Update', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20575 - Counterparty Contract Insert Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20575 - Counterparty Contract Insert Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


-- Module Event Mapping
--1. For Counterparty Contract Insert 
IF NOT EXISTS (
		SELECT 1
		FROM workflow_module_event_mapping
		WHERE module_id = 20622
			AND event_id = 20571
		)
BEGIN
	INSERT INTO workflow_module_event_mapping (
		module_id
		, event_id
		, is_active
		)
	SELECT 20622
		, 20571
		, 1
END
ELSE
	PRINT 'Already exists'

--2. For Counterparty Contract Update
IF NOT EXISTS (
		SELECT 1
		FROM workflow_module_event_mapping
		WHERE module_id = 20622
			AND event_id = 20572
		)
BEGIN
	INSERT INTO workflow_module_event_mapping (
		module_id
		, event_id
		, is_active
		)
	SELECT 20622
		, 20572
		, 1
END
ELSE
	PRINT 'Already exists'

--2. For Counterparty Contract Insert Update
IF NOT EXISTS (
		SELECT 1
		FROM workflow_module_event_mapping
		WHERE module_id = 20622
			AND event_id = 20575
		)
BEGIN
	INSERT INTO workflow_module_event_mapping (
		module_id
		, event_id
		, is_active
		)
	SELECT 20622
		, 20575
		, 1
END
ELSE
	PRINT 'Already exists'

	