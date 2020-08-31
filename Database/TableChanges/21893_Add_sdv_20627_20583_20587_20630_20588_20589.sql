SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20627)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20600, 20627, 'Settlement Checkout', 'Settlement Checkout', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20627 - Settlement Checkout.'
END
ELSE
BEGIN
    PRINT 'Static data value 20627 - Settlement Checkout already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20583)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20500, 20583, 'Ready for Invoice', 'Ready for Invoice', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20583 - Ready for Invoice.'
END
ELSE
BEGIN
    PRINT 'Static data value 20583 - Ready for Invoice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20587)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20500, 20587, 'Prepare Invoice', 'Prepare Invoice', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20587 - Prepare Invoice.'
END
ELSE
BEGIN
    PRINT 'Static data value 20587 - Prepare Invoice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF    

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20630)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20600, 20630, 'Settlement Invoice', 'Settlement Invoice', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20630 - Settlement Invoice.'
END
ELSE
BEGIN
    PRINT 'Static data value 20630 - Settlement Invoice already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF                       

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20588)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20500, 20588, 'Settlement Invoice Insert', 'Settlement Invoice Insert', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20588 - Settlement Invoice Insert.'
END
ELSE
BEGIN
    PRINT 'Static data value 20588 - Settlement Invoice Insert already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF            


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 20589)
BEGIN
    INSERT INTO static_data_value ([type_id], [value_id], [code], [description], [category_id], create_user, create_ts)
    VALUES (20500, 20589, 'Settlement Invoice Update', 'Settlement Invoice Update', NULL, 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 20589 - Settlement Invoice Update.'
END
ELSE
BEGIN
    PRINT 'Static data value 20589 - Settlement Invoice Update already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF                         
GO


IF NOT EXISTS(SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20627 AND event_id = 20583)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20627, 20583, 1
END  
GO

IF NOT EXISTS(SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20627 AND event_id = 20587)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20627, 20587, 1
END     
GO

IF NOT EXISTS(SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20630 AND event_id = 20588)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20630, 20588, 1
END    
GO

IF NOT EXISTS(SELECT 1 FROM workflow_module_event_mapping WHERE module_id = 20630 AND event_id = 20589)
BEGIN
	INSERT INTO workflow_module_event_mapping (module_id, event_id, is_active)
	SELECT 20630, 20589, 1
END   
GO 

IF NOT EXISTS (SELECT 1 FROM alert_table_definition WHERE logical_table_name = 'Settlement Checkout' and physical_table_name = 'stmt_checkout')
BEGIN
	INSERT INTO alert_table_definition (logical_table_name, physical_table_name, is_action_view, primary_column)
	SELECT 'Settlement Checkout', 'stmt_checkout', 'y', 'stmt_checkout_id'
END

IF NOT EXISTS (SELECT 1 FROM alert_table_definition WHERE logical_table_name = 'Settlement Invoice' and physical_table_name = 'stmt_invoice')
BEGIN
	INSERT INTO alert_table_definition (logical_table_name, physical_table_name, is_action_view, primary_column)
	SELECT 'Settlement Invoice', 'stmt_invoice', 'y', 'stmt_invoice_id'
END
GO

DECLARE @rule_table_id INT
SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE logical_table_name = 'Settlement Checkout' and physical_table_name = 'stmt_checkout' 
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20627 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20627, @rule_table_id, 1
END

SELECT @rule_table_id = alert_table_definition_id FROM alert_table_definition WHERE logical_table_name = 'Settlement Invoice' and physical_table_name = 'stmt_invoice' 
IF NOT EXISTS (SELECT 1 FROM workflow_module_rule_table_mapping WHERE module_id = 20630 AND rule_table_id = @rule_table_id)
BEGIN
	INSERT INTO workflow_module_rule_table_mapping (module_id, rule_table_id, is_active)
	SELECT 20630, @rule_table_id, 1
END
GO