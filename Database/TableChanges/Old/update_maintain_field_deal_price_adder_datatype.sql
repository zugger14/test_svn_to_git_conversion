IF EXISTS (SELECT * FROM maintain_field_deal   WHERE farrms_field_id = 'price_adder' AND field_id = 105)
BEGIN
	UPDATE maintain_field_deal SET data_type = 'price' WHERE farrms_field_id = 'price_adder' AND field_id = 105
END
ELSE 
	PRINT 'No Record found'