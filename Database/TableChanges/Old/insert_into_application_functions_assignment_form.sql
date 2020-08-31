IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 12101720)
BEGIN
  INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, book_required)
  VALUES (12101720, 'Assignment Form', 'Assignment Form', 12101700, 0)
END

IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 12101721)
BEGIN
  INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, book_required)
  VALUES (12101721, 'Assignment Form IU', 'Assignment Form IU', 12101720, 0)
END

IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 12101722)
BEGIN
  INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, book_required)
  VALUES (12101722, 'Assignment Form Delete', 'Assignment Form Delete', 12101720, 0)
END