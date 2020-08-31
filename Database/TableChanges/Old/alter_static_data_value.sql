IF EXISTS(SELECT 'x' FROM STATIC_data_value WHERE value_id=970)
BEGIN
	UPDATE STATIC_data_value SET code='6 Days or first business day after', DESCRIPTION='6 Days or first business day after'
	WHERE value_id=970
END
