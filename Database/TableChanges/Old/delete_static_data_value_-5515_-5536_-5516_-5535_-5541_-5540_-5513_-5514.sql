--Regional Component(-5514)
IF (SELECT 1 FROM static_data_value sdv WHERE sdv.value_id = '-5514') IS NOT NULL
BEGIN
	DELETE FROM static_data_value WHERE value_id = '-5514'
	PRINT 'Static data value Regional Component deleted.'
END
GO
-- Discount(-5513)
IF (SELECT 1 FROM static_data_value sdv WHERE sdv.value_id = '-5513') IS NOT NULL
BEGIN
	DELETE FROM static_data_value WHERE value_id = '-5513'
	PRINT 'Static data value Discount deleted.'
END

-- FixedCommodity(-5540)
IF (SELECT 1 FROM static_data_value sdv WHERE sdv.value_id = '-5540') IS NOT NULL
BEGIN
	DELETE FROM static_data_value WHERE value_id = '-5540'
	PRINT 'Static data value FixedCommodity deleted.'
END
GO

-- Z(-5541)
IF (SELECT 1 FROM static_data_value sdv WHERE sdv.value_id = '-5541') IS NOT NULL
BEGIN
	DELETE FROM static_data_value WHERE value_id = '-5541'
	PRINT 'Static data value Z deleted.'
END
GO

-- FixedCommodityOnPeak(-5535)
IF (SELECT 1 FROM static_data_value sdv WHERE sdv.value_id = '-5535') IS NOT NULL
BEGIN
	DELETE FROM static_data_value WHERE value_id = '-5535'
	PRINT 'Static data value FixedCommodityOnPeak deleted.'
END
GO

-- AddOnOnPeak(-5516)
IF (SELECT 1 FROM static_data_value sdv WHERE sdv.value_id = '-5516') IS NOT NULL
BEGIN
	DELETE FROM static_data_value WHERE value_id = '-5516'
	PRINT 'Static data value AddOnOnPeak deleted.'
END
GO

-- FixedCommodityOffpeak(-5536)
IF (SELECT 1 FROM static_data_value sdv WHERE sdv.value_id = '-5536') IS NOT NULL
BEGIN
	DELETE FROM static_data_value WHERE value_id = '-5536'
	PRINT 'Static data value FixedCommodityOffpeak deleted.'
END
GO
-- AddOnOffPeak(-5515)
IF (SELECT 1 FROM static_data_value sdv WHERE sdv.value_id = '-5515') IS NOT NULL
BEGIN
	DELETE FROM static_data_value WHERE value_id = '-5515'
	PRINT 'Static data value AddOnOffPeak deleted.'
END