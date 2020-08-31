UPDATE maintain_field_deal 
SET sql_string = 'EXEC spa_get_source_book_map @flag=''z'', @function_id=10131010' 
WHERE default_label = 'Sub Book' AND farrms_field_id = 'sub_book'