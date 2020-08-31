IF COL_LENGTH('formula_editor_parameter', 'formula_id') IS NOT NULL
BEGIN
	ALTER TABLE formula_editor_parameter 
	DROP COLUMN formula_id
END

IF EXISTS(SELECT 1 FROM sys.indexes 
		  WHERE name='IX_function_category' AND object_id = OBJECT_ID('dbo.map_function_category'))
BEGIN
	EXEC('ALTER TABLE [dbo].[map_function_category] DROP CONSTRAINT [IX_function_category]')
	 ALTER TABLE map_function_category
	 ADD CONSTRAINT IX_function_category
	 UNIQUE NONCLUSTERED([category_id] ASC, [function_name] ASC)
END

DECLARE @constraint_name VARCHAR(200)

IF COL_LENGTH('map_function_category', 'function_id') IS NOT NULL
BEGIN
	SELECT @constraint_name = CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
	WHERE TABLE_NAME = 'map_function_category'
	AND COLUMN_NAME = 'function_id'

	IF @constraint_name IS NOT NULL
	BEGIN
		EXEC ('ALTER TABLE map_function_category
			  DROP CONSTRAINT ' + @constraint_name )
	END
	
	ALTER TABLE map_function_category 
	DROP COLUMN function_id
END


IF EXISTS(SELECT 1 FROM sys.indexes 
		  WHERE name='IX_function_product' AND object_id = OBJECT_ID('dbo.map_function_product'))
BEGIN
	EXEC('ALTER TABLE [dbo].[map_function_product] DROP CONSTRAINT [IX_function_product]')
	ALTER TABLE map_function_product
	ADD CONSTRAINT IX_function_product
	UNIQUE NONCLUSTERED([product_id] ASC, [function_name] ASC)
END

IF COL_LENGTH('map_function_product', 'function_id') IS NOT NULL
BEGIN
	SET @constraint_name = NULL
	SELECT @constraint_name = CONSTRAINT_NAME FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
	WHERE TABLE_NAME = 'map_function_product'
	AND COLUMN_NAME = 'function_id'

	IF @constraint_name IS NOT NULL
	BEGIN
		EXEC ('ALTER TABLE map_function_product
			  DROP CONSTRAINT ' + @constraint_name )
	END
	
	ALTER TABLE map_function_product 
	DROP COLUMN function_id
END