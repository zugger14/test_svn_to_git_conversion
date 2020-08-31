IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10231916)
BEGIN
  INSERT INTO application_functions (function_id, function_name, function_desc, func_ref_id, book_required)
    VALUES (10231916, 'Hedge Item', 'Hedge Item', 10231900, 0)
END
ELSE
Print 'Application Function exists for this function id.'

UPDATE
application_functions 
SET
func_ref_id = 10231916
, function_name = 'Add/Save'
WHERE
function_id = 10231913

UPDATE
application_functions 
SET
func_ref_id = 10231916
, function_name = 'Delete'
WHERE
function_id = 10231915
