IF COL_LENGTH('source_remit_standard','load_delivery_intervals') IS NOT NULL
	ALTER TABLE source_remit_standard ALTER COLUMN load_delivery_intervals NVARCHAR(2000) NULL
GO

IF COL_LENGTH('source_remit_standard','delivery_capacity') IS NOT NULL
	ALTER TABLE source_remit_standard ALTER COLUMN delivery_capacity NVARCHAR(2000) NULL
GO

IF COL_LENGTH('source_remit_standard','quantity_unit_used_in_field_55') IS NOT NULL
	ALTER TABLE source_remit_standard ALTER COLUMN quantity_unit_used_in_field_55 NVARCHAR(2000) NULL
GO

IF COL_LENGTH('source_remit_standard','price_time_interval_quantity') IS NOT NULL
	ALTER TABLE source_remit_standard ALTER COLUMN price_time_interval_quantity NVARCHAR(2000) NULL
GO

-- Date time data type changed because we have to store date time ISO 8061 Format Eg: 2016-03-21T 12:00:00.00Z
IF COL_LENGTH('source_remit_standard','transaction_timestamp') IS NOT NULL
	ALTER TABLE source_remit_standard ALTER COLUMN transaction_timestamp VARCHAR(25) NULL
GO


IF COL_LENGTH('source_remit_standard','delivery_point_or_zone') IS NOT NULL
	ALTER TABLE source_remit_standard ALTER COLUMN delivery_point_or_zone VARCHAR(1000) NULL
GO

IF COL_LENGTH('source_remit_standard','order_id') IS NOT NULL
	ALTER TABLE source_remit_standard ALTER COLUMN order_id VARCHAR(512) NULL
GO

