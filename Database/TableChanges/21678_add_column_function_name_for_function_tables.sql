IF COL_LENGTH('map_function_category', 'function_name') IS NULL
BEGIN
	ALTER TABLE map_function_category 
	ADD function_name VARCHAR(150)
END

IF COL_LENGTH('map_function_category', 'function_desc') IS NULL
BEGIN
	ALTER TABLE map_function_category 
	ADD function_desc VARCHAR(500)
END

IF COL_LENGTH('formula_editor_parameter', 'function_name') IS NULL
BEGIN
	ALTER TABLE formula_editor_parameter 
	ADD function_name VARCHAR(150)
END

IF COL_LENGTH('map_function_product', 'function_name') IS NULL
BEGIN
	ALTER TABLE map_function_product 
	ADD function_name VARCHAR(150)
END

