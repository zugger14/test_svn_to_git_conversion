--Module
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20624)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20624, 20600, 'Incident Log', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20624 - Incident Log.'
END
ELSE
BEGIN
    PRINT 'Static data value 20624 - Incident Log already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--Event
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20573)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20573, 20500, 'Incident Log Insert/Update', '', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20573 - Incident Log Insert/Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20573 - Incident Log Insert/Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


-- Module Event Mapping
IF NOT EXISTS (
		SELECT 1
		FROM workflow_module_event_mapping
		WHERE module_id = 20624
			AND event_id = 20573
		)
BEGIN
	INSERT INTO workflow_module_event_mapping (
		module_id
		, event_id
		, is_active
		)
	SELECT 20624
		, 20573
		, 1
END
ELSE
	PRINT 'Already exists'


