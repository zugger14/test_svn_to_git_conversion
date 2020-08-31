IF NOT EXISTS ( SELECT 1 FROM static_data_value AS sdv WHERE sdv.code = 'Entity Code' )
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description]) VALUES (2200, 'Entity Code', 'Entity Code')
END