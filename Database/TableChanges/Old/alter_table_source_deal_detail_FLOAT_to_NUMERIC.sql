/*
 * Converting table column definitions to reduce rounding errors
 * 
 * column types changed form FLOAT to NUMERIC(38,20)
 * 
 * TODO : DROP VIEW dbo.vwHourly_position_monthly_AllFilter_breakdown
 * TODO : DROP VIEW dbo.vwHourly_position_monthly_AllFilter
 * 
 */

DROP VIEW dbo.vwHourly_position_monthly_AllFilter
DROP VIEW dbo.vwHourly_position_monthly_AllFilter_breakdown


IF EXISTS (SELECT * FROM   information_schema.columns WHERE table_name = 'source_deal_detail' AND column_name = 'capacity')
BEGIN
	ALTER TABLE source_deal_detail ALTER COLUMN capacity NUMERIC(38,20)
END

IF EXISTS (SELECT * FROM   information_schema.columns WHERE table_name = 'source_deal_detail' AND column_name = 'total_volume')
BEGIN
	ALTER TABLE source_deal_detail ALTER COLUMN total_volume NUMERIC(38,20)
END

IF EXISTS (SELECT * FROM   information_schema.columns WHERE table_name = 'source_deal_detail' AND column_name = 'volume_multiplier2')
BEGIN
	ALTER TABLE source_deal_detail ALTER COLUMN volume_multiplier2 NUMERIC(38,20)
END

IF EXISTS (SELECT * FROM   information_schema.columns WHERE table_name = 'source_deal_detail' AND column_name = 'price_adder2')
BEGIN
	ALTER TABLE source_deal_detail ALTER COLUMN price_adder2 NUMERIC(38,20)
END

IF EXISTS (SELECT * FROM   information_schema.columns WHERE table_name = 'source_deal_detail' AND column_name = 'multiplier')
BEGIN
	ALTER TABLE source_deal_detail ALTER COLUMN multiplier NUMERIC(38,20)
END

/*
 * Re Execute the Create View Scripts for
 * VIEW dbo.vwHourly_position_monthly_AllFilter_breakdown
 * VIEW dbo.vwHourly_position_monthly_AllFilter
 */
 
 