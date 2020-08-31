
-- Module
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20618)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20618, 20600, 'Counterparty Credit Enhancement', 'Counterparty Credit Enhancement', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20618 - Counterparty Credit Enhancement.'
END
ELSE
BEGIN
    PRINT 'Static data value 20618 - Counterparty Credit Enhancement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



--Events
--1.Credit Enhancement Update 
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20559)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20559, 20500, 'Credit Enhancement Update', 'Credit Enhancement Update', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20559 - Credit Enhancement Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20559 - Credit Enhancement Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--2.Credit Enhancement Insert
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20560)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20560, 20500, 'Credit Enhancement Insert', 'Credit Enhancement Insert', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20560 - Credit Enhancement Insert.'
END
ELSE
BEGIN
    PRINT 'Static data value 20560 - Credit Enhancement Insert already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


-- Module Event Mapping
--1.Credit Enhancement Update
IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20618 AND event_id = 20559)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20618,20559,1
END
--2.Credit Enhancement Insert
IF NOT EXISTS (SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20618 AND event_id = 20560)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20618,20560,1 
END

