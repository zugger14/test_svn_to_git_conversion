UPDATE application_functions 
SET func_ref_id = 10101182
WHERE function_id = 10101181

GO

UPDATE application_functions 
SET function_desc = 'Maintain Definition UOM View'
WHERE function_id = 10101151

GO

IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10101183)
BEGIN 
	INSERT INTO application_functions(function_id
									, function_name
									, function_desc
									, func_ref_id
									, book_required)
	SELECT 10101183, 'Maintain Definition UOM Conversion Delete', 'Maintain Definition UOM Conversion Delete', 10101182, 1
END 

IF NOT EXISTS (SELECT 1 FROM application_functions WHERE function_id = 10101182)
BEGIN 
	INSERT INTO application_functions(function_id
									, function_name
									, function_desc
									, func_ref_id
									, book_required
									, file_path)
	SELECT 10101182, 'Maintain Definition UOM Conversion View', 'Maintain Definition UOM Conversion View', 10101100, 1, '_setup/define_uom_conversion/define.uom.conversion.php'
END 


GO


UPDATE application_functional_users 
SET function_id = 10101183
WHERE function_id = 10101174

GO

UPDATE setup_menu 
SET function_id = 10101182 
WHERE function_id  = 10101151
GO
/*
select * from application_functions where 1=1 
--and function_id = 10101151
and function_desc like '%uom%'
select * from setup_menu where 1=1 
and display_name like '%uom%'
--and function_id = 10101151

select * from application_functions where function_id = 10101181
select * from application_functions where function_id = 10101182
select * from application_functions where function_id = 10101183
*/

