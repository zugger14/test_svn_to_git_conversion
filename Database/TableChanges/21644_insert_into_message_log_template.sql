TRUNCATE TABLE [message_log_template]

INSERT INTO message_log_template(message_number, message_status, message_type, message, recommendation)
SELECT 10001, 'Error', 'Missing Value', ' Required value missing for column: <column_name>.', 'Please correct data and re-import.'
UNION ALL
SELECT 10002, 'Error', 'Invalid Data', ' Data ''<column_value>'' not found for column: <column_name>.', 'Please correct data and re-import.'
UNION ALL
SELECT 10003, 'Error', 'Column Mismatch', ' <mismatch_column> columns are missing in the file.', 'Please correct the file and reimport.'
UNION ALL
SELECT 10004, 'Error', 'Invalid Format', ' Data type mismatch for column: <column_name>, value: <column_value>', 'Please correct data and import.'
UNION ALL
SELECT 10005, 'Error', 'Import Trigger Error', ' Technical error found in import Rule Trigger.', 'Please check import trigger or contact technical support for help.'
UNION ALL
SELECT 10006, 'Error', 'Technical Error', ' Technical error found when importing data.', 'Please contact support for help.'
UNION ALL
SELECT 10007, 'Error', 'Data Repetition', ' Data repetition found for column : <column_name>, value: <column_value>, No of times:<repetition_count>.',  'Please correct data and import.'
UNION ALL
SELECT 10008, 'Error', 'Data Truncation', ' Data length exceeded for column: <column_name>. Maxmimum length supported: <column_length>.',  'Please correct data and import.'
UNION ALL
SELECT 10009, 'Error', 'Data Locked', ' <column_name> <column_value> has been locked.',  'Please unlock first to proceed.'
UNION ALL
SELECT 10010, 'Error', 'Data Exceed', ' Value for <column_name> : <column_value> cannot be greater than <check_value>.',  'Please correct data and re-import.'
UNION ALL
SELECT 10011, 'Error', 'Mapping Error', ' Data error for <column_name> : <column_value>(<column_name> : <column_value> for <column_name1>: <column_value1> is not mapped).',  'Please correct data and re-import.'
UNION ALL
SELECT 10012, 'Error', 'Data Error', ' <column_name> : <column_value> is not a <column_name1>. Please verify <column_name2>.',  'Please correct data and re-import.'
UNION ALL
SELECT 10013, 'Warning', 'Invalid Data', ' Data ''<column_value>'' not found for column: <column_name>.', 'Please correct data and re-import.'
UNION ALL
SELECT 10014, 'Error', 'Dependent Data Missing', ' Data (''<column_value>'') in Column: <column_name> depends on column: <column_name1>.', 'Please correct data and re-import.'
UNION ALL
SELECT 10015, 'Warning', 'Mapping Error', ' Data error for <column_name> : <column_value>(<column_name> : <column_value> for <column_name1>: <column_value1> is not mapped).',  'Please correct data and re-import.'
UNION ALL
SELECT 10016, 'Error', 'Data Error', ' Data error for <column_name>: <column_value>(Valid Data: <column_value1> or <column_value2>).',  'Please correct data and re-import.'
UNION ALL
SELECT 10017, 'Error', 'Mapping Error', ' The volume for <column_name>: <column_value> and <column_name1>: <column_value1> is already matched.',  'Please unmatch and re-import.'
UNION ALL
SELECT 10018, 'Error', 'Duplicate Data', ' Combination of <column_name>(<column_value>) and <column_name1>(<column_value1>) already exists.',  'Please correct data and re-import.'
UNION ALL
SELECT 10019, 'Error', 'Data Error', ' Value for <column_name1>: <column_value1> cannot be greater than <colume_name2>: <column_value2>.',  'Please correct data and re-import.'
UNION ALL
SELECT 10020, 'Warning', 'Data Error', ' Value for <column_name1>: <column_value1> cannot be greater than <colume_name2>: <column_value2>.',  'Please correct data and re-import.'
UNION ALL
SELECT 10021, 'Error', 'Column Mismatch', ' Mapped columns: <mismatch_column> are missing in the file.', 'Please correct the file and reimport.'
UNION ALL
SELECT 10022, 'Error', 'Duplicate Data', 'Duplicate data ''<column_value>''  for ''<column_name>'' found in system.', 'Please remove duplicate data from system.'

