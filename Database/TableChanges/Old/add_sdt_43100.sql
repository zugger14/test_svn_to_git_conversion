IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 43100)
BEGIN
	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (43100, 'Shipment Workflow Status', 0, 'Shipment Workflow Status', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data type 43100 - Shipment Workflow Status.'
END
ELSE
BEGIN
	PRINT 'Static data type 43100 - Shipment Workflow Status already EXISTS.'
END
GO

