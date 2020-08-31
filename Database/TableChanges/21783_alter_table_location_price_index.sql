-- ## Remove Foreign Key Constraints
IF EXISTS ( SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'FOREIGN KEY' 
			AND TABLE_NAME = 'location_price_index' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_location_price_index_static_data_value' )
BEGIN
   ALTER TABLE dbo.location_price_index DROP CONSTRAINT [FK_location_price_index_static_data_value]
END
IF EXISTS ( SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'FOREIGN KEY' 
			AND TABLE_NAME = 'location_price_index' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_location_price_index_static_data_value1' )
BEGIN
   ALTER TABLE dbo.location_price_index DROP CONSTRAINT [FK_location_price_index_static_data_value1]
END
-- ## Remove columns
IF COL_LENGTH('location_price_index', 'product_type_id') IS NOT NULL
BEGIN
    ALTER TABLE location_price_index DROP COLUMN product_type_id
	PRINT 'Column product_type_id removed successfully.'
END
ELSE
	PRINT 'Column product_type_id doesnot exists.'

IF COL_LENGTH('location_price_index', 'price_type_id') IS NOT NULL
BEGIN
    ALTER TABLE location_price_index DROP COLUMN price_type_id
	PRINT 'Column price_type_id removed successfully.'
END
ELSE
	PRINT 'Column price_type_id doesnot exists.'

-- ## Add columns
IF COL_LENGTH(N'[dbo].[location_price_index]', N'commodity_id') IS NULL
BEGIN
    ALTER TABLE [dbo].[location_price_index] ADD commodity_id INT NOT NULL
		CONSTRAINT FK_location_price_index_source_commodity FOREIGN KEY REFERENCES source_commodity(source_commodity_id)

    PRINT 'Column commodity_id added successfully.'
END
ELSE
    PRINT 'Column commodity_id already exists.'

IF COL_LENGTH(N'[dbo].[location_price_index]', N'multiplier') IS NULL
BEGIN
    ALTER TABLE [dbo].[location_price_index] ADD multiplier NUMERIC(32,8)

    PRINT 'Column multiplier added successfully.'
END
ELSE
    PRINT 'Column multiplier already exists.'

IF COL_LENGTH(N'[dbo].[location_price_index]', N'adder') IS NULL
BEGIN
    ALTER TABLE [dbo].[location_price_index] ADD adder NUMERIC(32,8)

    PRINT 'Column adder added successfully.'
END
ELSE
    PRINT 'Column adder already exists.'

IF COL_LENGTH(N'[dbo].[location_price_index]', N'adder_index_id') IS NULL
BEGIN
    ALTER TABLE [dbo].[location_price_index] ADD adder_index_id INT
		CONSTRAINT FK_location_price_index_source_price_curve_def1 FOREIGN KEY REFERENCES source_price_curve_def(source_curve_def_id)

    PRINT 'Column adder_index_id added successfully.'
END
ELSE
    PRINT 'Column adder_index_id already exists.'
