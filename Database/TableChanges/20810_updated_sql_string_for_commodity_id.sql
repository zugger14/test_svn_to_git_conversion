IF EXISTS (SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'commodity_id' AND field_type = 'd')
BEGIN
	UPDATE maintain_field_deal
	SET sql_string = 'EXEC spa_source_commodity_maintain ''a''' 
	WHERE farrms_field_id = 'commodity_id' 
	AND field_type = 'd'
END