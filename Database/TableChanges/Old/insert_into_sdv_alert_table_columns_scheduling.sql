/*
Scheduling uses vwScheduling View
#1. Creating Module
#2. Creating Events
#3. Creating Table Objects
#4. Creating Table Objects Columns
#5. Creating Document Category
#6. Creating Document Sub Category
*/

/* #1
------------- CREATING MODULE -------------- */ 
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20611)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20611, 20600, 'Scheduling', 'Scheduling', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20611 - Scheduling.'
END
ELSE
BEGIN
	PRINT 'Static data value 20611 - Scheduling already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

/* ------------- CREATING MODULE END -------------- */



/* #2 
------------- CREATING EVENTS -------------- */ 
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20527)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (20527, 20500, 'Scheduling - Post Insert', 'Scheduling - Post Insert', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 20527 - Scheduling - Post Insert.'
END
ELSE
BEGIN
	PRINT 'Static data value 20527 - Scheduling - Post Insert already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20528)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20528, 20500, 'Scheduling - Pre Insert', ' Scheduling - Pre Insert', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20528 - Scheduling - Pre Insert.'
END
ELSE
BEGIN
    PRINT 'Static data value 20528 - Scheduling - Pre Insert already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20529)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20529, 20500, 'Scheduling - Pre Update', ' Scheduling - Pre Update', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20529 - Scheduling - Pre Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20529 - Scheduling - Pre Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20530)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20530, 20500, 'Scheduling - Post Update', ' Scheduling - Post Update', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20530 - Scheduling - Post Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20530 - Scheduling - Post Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20531)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20531, 20500, 'Scheduling - Pre Delete', ' Scheduling - Pre Delete', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20531 - Scheduling - Pre Delete.'
END
ELSE
BEGIN
    PRINT 'Static data value 20531 - Scheduling - Pre Delete already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20532)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (20532, 20500, 'Scheduling - Post Delete', ' Scheduling - Post Delete', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20532 - Scheduling - Post Delete.'
END
ELSE
BEGIN
    PRINT 'Static data value 20532 - Scheduling - Post Delete already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

/* ------------- CREATING EVENTS END -------------- */ 



/* #3 
------------- CREATING TABLE OBJECT -------------- */ 
DECLARE @new_alert_table_definition_id INT

IF NOT EXISTS (SELECT 1 FROM alert_table_definition WHERE logical_table_name = 'Scheduling')
BEGIN
	INSERT INTO alert_table_definition(logical_table_name, physical_table_name)
	VALUES ('Scheduling', 'vwScheduling')
	SET @new_alert_table_definition_id = SCOPE_IDENTITY()
END
ELSE 
BEGIN
	SELECT @new_alert_table_definition_id = alert_table_definition_id FROM alert_table_definition WHERE logical_table_name = 'Scheduling'
END

/* ------------- CREATING TABLE OBJECT END -------------- */ 


/* #4 
------------- CREATING TABLE OBJECT COLUMNS -------------- */ 
IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'match_group_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'match_group_id', 'y', 'Match Group ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mg_create_ts')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mg_create_ts', 'n', 'Match Group Create Time'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mg_create_user')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mg_create_user', 'n', 'Match Group Create User'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mg_update_ts')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mg_update_ts', 'n', 'Match Group Update Time'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mg_update_user')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mg_update_user', 'n', 'Match Group Update User'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgs_match_group_shipment_id]')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgs_match_group_shipment_id]', 'n', 'shipment ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgs_create_ts')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgs_create_ts', 'n', 'shipment Create Time'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgs_create_user')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgs_create_user', 'n', 'shipment Create User'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgs_update_ts')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgs_update_ts', 'n', 'shipment Update Time'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgs_update_user')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgs_update_user', 'n', 'shipment Update User'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgs_shipment_status')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgs_shipment_status', 'n', 'shipment Status'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgs_from_location')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgs_from_location', 'n', 'From Location'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgs_to_location')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgs_to_location', 'n', 'To Location'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgs_is_transportation_deal_created')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgs_is_transportation_deal_created', 'n', 'Transportated Deal Created'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_match_group_header_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_match_group_header_id', 'n', 'Match Group Header ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_match_book_auto_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_match_book_auto_id', 'n', 'Match Book ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_match_bookout')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_match_bookout', 'n', 'Match Bookout'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_source_minor_location_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_source_minor_location_id', 'n', 'Source Minor Location ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_scheduler')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_scheduler', 'n', 'Schedular'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_location')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_location', 'n', 'Location'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_status')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_status', 'n', 'Status'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_scheduled_from')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_scheduled_from', 'n', 'Schedule From'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_scheduled_to')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_scheduled_to', 'n', 'Schedule To'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_match_number')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_match_number', 'n', 'Match Number'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_pipeline_cycle')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_pipeline_cycle', 'n', 'Pipeline Cycle'
END
IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_consignee')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_consignee', 'n', 'Consignee'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_carrier')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_carrier', 'n', 'Carrier'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_po_number')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_po_number', 'n', 'PO Number'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_container')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_container', 'n', 'Container'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_line_up')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_line_up', 'n', 'Line Up'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_commodity_origin_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_commodity_origin_id', 'n', 'Commodity Origin'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_commodity_form_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_commodity_form_id', 'n', 'Commodity Form'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_organic')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_organic', 'n', 'Organic'	
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_commodity_form_attribute1')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_commodity_form_attribute1', 'n', 'Attribute1'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_commodity_form_attribute2')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_commodity_form_attribute2', 'n', 'Attribute2'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_commodity_form_attribute3')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_commodity_form_attribute3', 'n', 'Attribute3'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_commodity_form_attribute4')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_commodity_form_attribute4', 'n', 'Attribute4'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_commodity_form_attribute5')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_commodity_form_attribute5', 'n', 'Attribute5'	
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_estimated_movement_date')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_estimated_movement_date', 'n', 'Estimated Movement Date'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_create_user')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_create_user', 'n', 'Match Header Create User'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_create_ts')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_create_ts', 'n', 'Match Header Create Time'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_update_user')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_update_user', 'n', 'Match Header Update User'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgh_update_ts')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgh_update_ts', 'n', 'Match Header Update Time'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_match_group_detail_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_match_group_detail_id', 'n', 'Match Group Detail ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_quantity')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_quantity', 'n', 'Quantity'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_source_commodity_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_source_commodity_id', 'n', 'Commodity'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_scheduling_period')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_scheduling_period', 'n', 'Scheduling Period'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_notes')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_notes', 'n', 'Notes'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_source_deal_detail_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_source_deal_detail_id', 'n', 'Deal Detail ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_is_complete')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_is_complete', 'n', 'Is Complete'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_create_user')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_create_user', 'n', 'Match Detail Create User'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_create_ts')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_create_ts', 'n', 'Match Detail Create Time'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_update_user')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_update_user', 'n', 'Match Detail Update User'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_update_ts')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_update_ts', 'n', 'Match Detail Update Time'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_bookout_split_volume')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_bookout_split_volume', 'n', 'Bookout Split Volume'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_split_deal_detail_volume_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_split_deal_detail_volume_id', 'n', 'Volume'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_frequency')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_frequency', 'n', 'Frequency'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_lot')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_lot', 'n', 'Lot'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_batch_id')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_batch_id', 'n', 'Batch ID'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_inco_terms')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_inco_terms', 'n', 'Inco Terms'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgd_crop_year')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgd_crop_year', 'n', 'Crop Year'
END

IF NOT EXISTS (SELECT 1 FROM alert_columns_definition WHERE alert_table_id = @new_alert_table_definition_id AND column_name = 'mgs_workflow_status')
BEGIN
	INSERT INTO alert_columns_definition(alert_table_id, column_name, is_primary, column_alias)
	SELECT @new_alert_table_definition_id, 'mgs_workflow_status', 'n', 'Workflow Status'
END

/* ------------- CREATING TABLE OBJECT COLUMNS END -------------- */ 


/* #5
------------- CREATING DOCUMENT CATEGORY -------------- */ 
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 45)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (45, 25, 'Schedule Match', ' Schedule Match', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 45 - Schedule Match.'
END
ELSE
BEGIN
    PRINT 'Static data value 45 - Schedule Match already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

/* ------------- CREATING DOCUMENT CATEGORY END -------------- */ 


/* #6
------------- CREATING DOCUMENT SUB CATEGORY -------------- */ 
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42007)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42007, 42000, 'Booking Declaration', ' Booking Declaration', '45', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42007 - Booking Declaration.'
END
ELSE
BEGIN
    PRINT 'Static data value 42007 - Booking Declaration already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42008)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42008, 42000, 'Booking Instructions', ' Booking Instructions', '45', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42008 - Booking Instructions.'
END
ELSE
BEGIN
    PRINT 'Static data value 42008 - Booking Instructions already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42009)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42009, 42000, 'Delivery Declaration', ' Delivery Declaration', '45', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42009 - Delivery Declaration.'
END
ELSE
BEGIN
    PRINT 'Static data value 42009 - Delivery Declaration already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42010)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42010, 42000, 'Delivery Instructions', ' Delivery Instructions', '45', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42010 - Delivery Instructions.'
END
ELSE
BEGIN
    PRINT 'Static data value 42010 - Delivery Instructions already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42011)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42011, 42000, 'Outward Collection Instructions', ' Outward Collection Instructions', '45', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42011 - Outward Collection Instructions.'
END
ELSE
BEGIN
    PRINT 'Static data value 42011 - Outward Collection Instructions already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42012)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42012, 42000, 'Release Declaration', ' Release Declaration', '45', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42012 - Release Declaration.'
END
ELSE
BEGIN
    PRINT 'Static data value 42012 - Release Declaration already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42013)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42013, 42000, 'Release Instructions', ' Release Instructions', '45', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42013 - Release Instructions.'
END
ELSE
BEGIN
    PRINT 'Static data value 42013 - Release Instructions already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42014)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42014, 42000, 'Shipment Declaration', ' Shipment Declaration', '45', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42014 - Shipment Declaration.'
END
ELSE
BEGIN
    PRINT 'Static data value 42014 - Shipment Declaration already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42015)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42015, 42000, 'Shipment Instructions', ' Shipment Instructions', '45', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42015 - Shipment Instructions.'
END
ELSE
BEGIN
    PRINT 'Static data value 42015 - Shipment Instructions already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42016)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42016, 42000, 'Storage Declaration', ' Storage Declaration', '45', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42016 - Storage Declaration.'
END
ELSE
BEGIN
    PRINT 'Static data value 42016 - Storage Declaration already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42017)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42017, 42000, 'Storage Instructions', ' Storage Instructions', '45', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42017 - Storage Instructions.'
END
ELSE
BEGIN
    PRINT 'Static data value 42017 - Storage Instructions already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

/* ------------- CREATING DOCUMENT SUB CATEGORY END -------------- */ 