IF OBJECT_ID('IX_source_price_curve_def', 'UQ') IS NOT NULL
BEGIN
	ALTER TABLE source_price_curve_def DROP CONSTRAINT IX_source_price_curve_def
END

IF OBJECT_ID('UQ_source_price_curve_def_source_system_curve_id_market_val_desc', 'UQ') IS NOT NULL
BEGIN
	ALTER TABLE source_price_curve_def DROP CONSTRAINT UQ_source_price_curve_def_source_system_curve_id_market_val_desc
END

IF OBJECT_ID('UQ_source_price_curve_def_source_system_curve_id', 'UQ') IS NULL
BEGIN
	ALTER TABLE source_price_curve_def
	ADD CONSTRAINT UQ_source_price_curve_def_source_system_curve_id
	UNIQUE(source_system_id, curve_id)
END

GO