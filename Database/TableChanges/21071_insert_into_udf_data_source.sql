
IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'UOM')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('UOM', 'Exec spa_source_uom_maintain ''c''', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''UOM'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''UOM'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Meter')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Meter', 'EXEC spa_getAllMeter @flag = ''s''', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Meter'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Meter'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Calendar')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Calendar', 'SELECT DISTINCT sdv.value_id [Value ID],  sdv.code [code] 
			FROM static_data_value sdv 
			INNER JOIN static_data_type sdt
				ON sdv.type_id = sdt.type_id
				AND sdt.type_name = ''calendar''', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Calendar'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Calendar'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Commodity')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Commodity', 'Exec spa_source_commodity_maintain ''b''', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Commodity'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Commodity'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Block Definition')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Block Definition', 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 19900', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Block Definition'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Block Definition'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Country')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Country', 'SELECT DISTINCT sdv.value_id [Value ID],  sdv.code [code] 
			FROM static_data_value sdv 
			INNER JOIN static_data_type sdt
				ON sdv.type_id = sdt.type_id
				AND sdt.type_name = ''country''', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Country'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Country'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Region')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Region', 'SELECT DISTINCT sdv.value_id [Value ID],  sdv.code [code] 
			FROM static_data_value sdv 
			INNER JOIN static_data_type sdt
				ON sdv.type_id = sdt.type_id
				AND sdt.type_name = ''region''', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Region'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Region'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Contract Status')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Contract Status', 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 1900', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Contract Status'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Contract Status'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Invoice Status')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Invoice Status', 'EXEC spa_StaticDataValues @flag = ''h'', @type_id = 25000', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Invoice Status'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Invoice Status'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Book1')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Book1', 'EXEC spa_source_book_maintain ''x'', @source_system_book_type_value_id = 50', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Book1'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Book1'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Book2')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Book2', 'EXEC spa_source_book_maintain ''x'', @source_system_book_type_value_id = 51', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Book2'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Book2'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Book3')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Book3', 'EXEC spa_source_book_maintain ''x'', @source_system_book_type_value_id = 52', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Book3'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Book3'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Book4')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Book4', 'EXEC spa_source_book_maintain ''x'', @source_system_book_type_value_id = 53', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Book4'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Book4'' already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Sub Book')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Sub Book', 'SELECT book_deal_type_map_id [ID], 
				   logical_name [Code] 
			FROM source_system_book_map', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Sub Book'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Sub Book'' already EXISTS.'
END

GO
