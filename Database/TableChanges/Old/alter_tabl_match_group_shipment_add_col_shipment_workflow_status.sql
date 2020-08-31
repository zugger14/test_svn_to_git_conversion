 IF COL_LENGTH('match_group_shipment', 'shipment_workflow_status') IS NULL
BEGIN
    ALTER TABLE match_group_shipment ADD shipment_workflow_status INT
END
GO
