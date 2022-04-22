IF OBJECT_ID(N'dbo.FNANormalizeTo1Mw', N'TF') IS NOT NULL
    DROP FUNCTION dbo.FNANormalizeTo1Mw;
GO
CREATE FUNCTION dbo.FNANormalizeTo1Mw(@quantity_unit NVARCHAR(20), @quantity_volume NUMERIC(20,8), @price NUMERIC(20,8))
RETURNS @normalize TABLE 
(
    -- Columns returned by the function
    unit NVARCHAR(20), volume NUMERIC(20,10), price NUMERIC(20,5), inverse NUMERIC(20,18)
)
AS 
-- Returns the unit, volume, price, inverse values for subimission ACER Remit
BEGIN
	DECLARE @unit NVARCHAR(20), @volume NUMERIC(20,8), @inverse NUMERIC(20,18)
	--	Unit that are not supported by ACER submission, add unit list below
	SET @quantity_unit = CASE WHEN REPLACE(@quantity_unit, ' ', '') IN ('MW/MWh') THEN 'MW' ELSE @quantity_unit END

	SET @unit = CASE 
							WHEN @quantity_unit IN ('KW','KWh/h','KWh/d','MW','MWh/h','MWh/d','GW','GWh/h','GWh/d') THEN 'MW'	--Convert to MW
							WHEN @quantity_unit IN('Therm/d','KTherm/d','MTherm/d') THEN 'Therm/d'	--Convert to Therm/d
							WHEN @quantity_unit IN('cm/d','mcm/d') THEN 'cm/d'	--Convert to cm/d
							WHEN @quantity_unit IN('Btu/d','MMBtu/d') THEN 'Btu/d'	--Convert to Btu/d
							WHEN @quantity_unit IN('MJ/d','100MJ/d','GJ/d','MMJ/d') THEN 'MJ/d'	--Convert to MJ/d
						END
	SET @inverse = CASE 
							WHEN @quantity_unit ='KW' THEN (1 / (@quantity_volume / 1000))
							WHEN @quantity_unit ='KWh/h' THEN (1 / (@quantity_volume / 1000))
							WHEN @quantity_unit ='KWh/d' THEN (1 / (@quantity_volume / 1000))
							WHEN @quantity_unit ='MW' THEN (1 / @quantity_volume)
							WHEN @quantity_unit ='MWh/h' THEN (1 / @quantity_volume)
							WHEN @quantity_unit ='MWh/d' THEN (1 / (@quantity_volume))
							WHEN @quantity_unit ='GW' THEN (1 / (@quantity_volume * 1000))
							WHEN @quantity_unit ='GWh/h' THEN (1 / (@quantity_volume * 1000))
							WHEN @quantity_unit ='GWh/d' THEN (1 / (@quantity_volume * 1000))
							WHEN @quantity_unit ='Therm/d' THEN (1 / @quantity_volume)
							WHEN @quantity_unit ='KTherm/d' THEN (1 / (@quantity_volume * 1000))
							WHEN @quantity_unit ='MTherm/d' THEN (1 / (@quantity_volume * 1000000))
							WHEN @quantity_unit ='cm/d' THEN (1 / @quantity_volume)
							WHEN @quantity_unit ='mcm/d' THEN (1 / (@quantity_volume * 1000000))
							WHEN @quantity_unit ='Btu/d' THEN (1 / @quantity_volume)
							WHEN @quantity_unit ='MMBtu/d' THEN (1 / (@quantity_volume * 1000000))
							WHEN @quantity_unit ='MJ/d' THEN (1 / @quantity_volume)
							WHEN @quantity_unit ='100MJ/d' THEN (1 / (@quantity_volume * 100))
							WHEN @quantity_unit ='GJ/d' THEN (1 / (@quantity_volume * 1000))
							WHEN @quantity_unit ='MMJ/d' THEN (1 / (@quantity_volume * 1000000))
						END
	SET @volume = CASE 
						WHEN @quantity_unit ='KW' THEN (@quantity_volume / 1000) * @inverse
						WHEN @quantity_unit ='KWh/h' THEN (@quantity_volume / 1000) * @inverse
						WHEN @quantity_unit ='KWh/d' THEN (@quantity_volume / 1000) * @inverse
						WHEN @quantity_unit ='MW' THEN (@quantity_volume / 1) * @inverse
						WHEN @quantity_unit ='MWh/h' THEN @quantity_volume / 1 * @inverse
						WHEN @quantity_unit ='MWh/d' THEN @quantity_volume / 1 * @inverse
						WHEN @quantity_unit ='GW' THEN @quantity_volume * 1000 * @inverse
						WHEN @quantity_unit ='GWh/h' THEN @quantity_volume * 1000 * @inverse
						WHEN @quantity_unit ='GWh/d' THEN (@quantity_volume * 1000) * @inverse
						WHEN @quantity_unit ='Therm/d' THEN (@quantity_volume / 1) * @inverse
						WHEN @quantity_unit ='KTherm/d' THEN (@quantity_volume * 1000) * @inverse
						WHEN @quantity_unit ='MTherm/d' THEN (@quantity_volume * 1000000) * @inverse
						WHEN @quantity_unit ='cm/d' THEN (@quantity_volume / 1) * @inverse
						WHEN @quantity_unit ='mcm/d' THEN (@quantity_volume * 1000000) * @inverse
						WHEN @quantity_unit ='Btu/d' THEN (@quantity_volume / 1) * @inverse
						WHEN @quantity_unit ='MMBtu/d' THEN (@quantity_volume * 1000000) * @inverse
						WHEN @quantity_unit ='MJ/d' THEN (@quantity_volume / 1) * @inverse
						WHEN @quantity_unit ='100MJ/d' THEN (@quantity_volume * 100) * @inverse
						WHEN @quantity_unit ='GJ/d' THEN (@quantity_volume * 1000) * @inverse
						WHEN @quantity_unit ='MMJ/d' THEN (@quantity_volume * 1000000) * @inverse
					END
	SET @price = @price * @inverse
    INSERT @normalize
    SELECT @unit [unit], @volume [volume],  @price [Price], @inverse [inverse];
    RETURN
END
GO
