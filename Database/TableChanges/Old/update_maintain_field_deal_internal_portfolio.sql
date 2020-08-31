IF EXISTS (SELECT 1 FROM maintain_field_deal WHERE farrms_field_id = 'internal_portfolio_id')
BEGIN 
	UPDATE maintain_field_deal 
	SET sql_string = 'SELECT value_id,code FROM dbo.static_data_value WHERE [type_id]=39800'
	WHERE farrms_field_id = 'internal_portfolio_id'
END 
