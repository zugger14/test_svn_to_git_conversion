IF NOT EXISTS(SELECT 1 FROM application_functions WHERE function_id = 10101181)
BEGIN
 	INSERT INTO application_functions(function_id,function_name,function_desc,func_ref_id,function_call)
	VALUES (10101181, 'Maintain Definition UOM Conversion Add\Edit', 'Maintain Definition UOM Conversion Add\Edit', 10101151, NULL)
 	PRINT ' Inserted 10250000 - Message Board.'
END
ELSE
BEGIN
	PRINT 'Application FunctionID 10101181 - Maintain Definition UOM Conversion Add\Edit already EXISTS.'
END


UPDATE application_functions
SET func_ref_id = 10101151,
function_name = 'Maintain Definition UOM Conversion Delete',
function_desc = 'Maintain Definition UOM Conversion Delete'
WHERE function_id = 10101174

UPDATE application_functions
SET function_name = 'Maintain Definition UOM Conversion View',
	function_desc = 'Maintain Definition UOM Conversion View'
WHERE function_id = 10101151


--select * from application_functions where function_id = 10101151
--select * from application_functions where  func_ref_id = 10101151

GO
--select * from adiha_grid_definition where 
--grid_name like '%uom%' 

--UPDATE adiha_grid_definition
--SET edit_permission = 10101181
--WHERE grid_id = 36