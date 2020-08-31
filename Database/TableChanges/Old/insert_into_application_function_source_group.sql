IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 12101712)
BEGIN
  INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, book_required)
  VALUES (12101712, 'Setup Source Group', 'Setup Source Group', 12101700, 0)
END

IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 12101713)
BEGIN
  INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, book_required)
  VALUES (12101713, 'Setup Source Group IU', 'Setup Source Group IU', 12101712, 0)
END

IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 12101714)
BEGIN
  INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, book_required)
   VALUES (12101714, 'Setup Source Group Delete', 'Setup Source Group Delete', 12101712, 0)
END