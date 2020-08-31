IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_location_price_index]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_location_price_index]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_location_price_index]
    @flag CHAR(1),
    @location_price_index_id INT = NULL,
    @location_id INT = NULL,
    @curve_id INT = NULL,
	@commodity_id INT = NULL
AS 

DECLARE @sql AS VARCHAR(5000)

IF @flag = 'i' 
BEGIN
    INSERT  INTO location_price_index ([location_id], [curve_id], commodity_id)
    VALUES  (@location_id, @curve_id, @commodity_id)
END
ELSE IF @flag = 'u' 
BEGIN
    UPDATE  location_price_index
    SET     location_id = @location_id,
            commodity_id = @commodity_id,
            curve_id = @curve_id
    WHERE   location_price_index_id = @location_price_index_id
END
ELSE IF @flag = 'd' 
BEGIN
    DELETE  location_price_index
    WHERE   location_price_index_id = @location_price_index_id
END
ELSE IF @flag = 's' 
BEGIN
	SELECT @sql = 'SELECT  distinct lpi.location_price_index_id,sml.location_name AS Location,sdv.code [Product Type],
			sdv1.code AS Price,spc.curve_id AS Curve
			FROM    location_price_index lpi
			INNER JOIN source_minor_location sml ON sml.source_minor_location_id = lpi.location_id
			INNER JOIN static_data_value sdv ON sdv.value_ID = lpi.product_type_id 
			INNER JOIN static_data_value sdv1 ON sdv1.value_ID = lpi.price_type_id
			INNER JOIN source_price_curve_def spc ON spc.source_curve_def_id = lpi.curve_id
			WHERE 1=1'
												
	IF @location_id IS NOT NULL 
		SET  @sql = @sql + ' AND sml.source_minor_location_id = ' + CAST(@location_id AS VARCHAR)
				
	IF @curve_id IS NOT NULL 
		SET  @sql = @sql + ' AND spc.source_curve_def_id = ' + CAST(@curve_id AS VARCHAR)
				
	EXEC spa_print @sql
	EXEC(@sql)				
END
ELSE IF @flag = 'a' 
BEGIN
    SELECT lpi.location_id,
            curve_id,
            sml.Location_Name
    FROM   location_price_index lpi
    LEFT JOIN source_minor_location sml ON sml.source_minor_location_id = lpi.location_id
    WHERE  location_price_index_id = @location_price_index_id
END
ELSE IF @flag = 'l' -- ## Used in Valuation Index Grid in Setup Location
BEGIN
	SELECT	location_price_index_id,
			location_id,
			commodity_id,
			curve_id,
			dbo.FNARemoveTrailingZeroes(multiplier) [multiplier],
			dbo.FNARemoveTrailingZeroes(adder) [adder],
			adder_index_id
	FROM location_price_index
	WHERE location_id = @location_id
END