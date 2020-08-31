IF COL_LENGTH(N'deal_type_pricing_maping', N'tou_mtm') IS NULL
BEGIN
	ALTER TABLE deal_type_pricing_maping ADD tou_mtm BIT
END