IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 12101725)
BEGIN
  INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, book_required)
    VALUES (12101725, 'Map Meter ID IU', 'Map Meter ID IU', 12101700, 0)
END

IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 12101726)
BEGIN
  INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, book_required)
    VALUES (12101726, 'Map Meter ID Delete', 'Map Meter ID Delete', 12101700, 0)
END