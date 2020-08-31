IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Deal Status')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Deal Status', 'SELECT source_deal_type_id, source_deal_type_name 
FROM source_deal_type 
WHERE ISNULL(sub_type, ''n'') = ''y'' 
ORDER BY source_deal_type_name', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Deal Status'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Deal Status'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Location')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Location', 'EXEC spa_source_minor_location ''o''', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Location'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Location'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Trader')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Trader', 'EXEC spa_source_traders_maintain ''x''', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Trader'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Trader'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'currency')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('currency', 'Exec spa_source_currency_maintain ''p''', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''currency'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''currency'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'Price Curve Definition')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('Price Curve Definition', 'EXEC spa_source_price_curve_def_maintain ''l''', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''Price Curve Definition'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''Price Curve Definition'' already EXISTS.'
END

GO

IF NOT EXISTS(SELECT 1 FROM udf_data_source WHERE [udf_data_source_name] = 'custom')
BEGIN
    INSERT INTO udf_data_source ( [udf_data_source_name], [sql_string], [is_hidden], create_user, create_ts)
    VALUES ('custom', 'custom', 0, dbo.FNADBUser(), GETDATE())
    PRINT 'UDF Data Source - ''custom'' inserted Successfully.'
END
ELSE
BEGIN
    PRINT 'UDF Data Source - ''custom array'' already EXISTS.'
END

GO

