UPDATE static_data_value
    SET code = 'commodity_attribute',
	description = 'Commodity Attribute Type',
    [category_id] = ''
    WHERE [value_id] = 4071
PRINT 'Updated Static value 4071 - commodity_attribute.'