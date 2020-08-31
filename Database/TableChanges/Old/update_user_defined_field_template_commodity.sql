UPDATE user_defined_fields_template
SET sql_string = 'select source_book_id,source_book_name from source_book where source_system_book_type_value_id=51'
WHERE Field_label = 'Commodity'
