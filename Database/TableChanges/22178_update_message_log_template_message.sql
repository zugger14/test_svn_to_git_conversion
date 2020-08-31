UPDATE message_log_template 
SET [message] = ' Value for <column_name1>: <column_value1> cannot be greater than <column_name2>: <column_value2>.'
WHERE message_number IN (10019, 10020) 

GO