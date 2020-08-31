SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 4049)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (4049, 4000, 'PriceCurveVolatilityCorrelationData Import', 'PriceCurveVolatilityCorrelationData Import', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 4049 - PriceCurveVolatilityCorrelationData Import.'
END
ELSE
BEGIN
	PRINT 'Static data value 4049 - PriceCurveVolatilityCorrelationData Import already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


IF NOT EXISTS(SELECT 1 FROM external_source_import WHERE data_type_id=4049)
INSERT INTO external_source_import(source_system_id,data_type_id) SELECT 2,4049





