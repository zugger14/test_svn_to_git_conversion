IF NOT EXISTS (SELECT TOP  1 1 FROM process_filters WHERE filterId = 'ApproveHedgeRel')
	INSERT INTO process_filters (filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect)	
		VALUES ('ApproveHedgeRel', 'static_data_type', 'type_name', 'type_id', 150, 'n' )

IF NOT EXISTS (SELECT TOP  1 1 FROM process_filters WHERE filterId = 'FinalizeHedgeRel')
INSERT INTO process_filters (filterId, tableName, colNameForValue, colNameForId, precedence, allowMultiSelect)	
	VALUES ('FinalizeHedgeRel', 'static_data_type', 'type_name', 'type_id', 160, 'n' )	