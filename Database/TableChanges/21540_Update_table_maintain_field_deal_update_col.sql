IF COL_LENGTH('maintain_field_deal', 'sql_string') IS NOT NULL
BEGIN
    UPDATE maintain_field_deal 
	SET sql_string = 'SELECT value_id, code FROM dbo.static_data_value WHERE type_id = 107400'
	where field_id = 206
END


IF COL_LENGTH('maintain_field_deal', 'default_value') IS NOT NULL
BEGIN
    UPDATE maintain_field_deal 
	SET default_value = '107400'
	where field_id = 206
END

