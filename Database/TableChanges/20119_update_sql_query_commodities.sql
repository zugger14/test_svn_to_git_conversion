
UPDATE user_defined_fields_template
SET sql_string = 'SELECT source_commodity_id, commodity_id FROM source_commodity sc ORDER BY commodity_id'
WHERE Field_label = 'Commodities'
GO

