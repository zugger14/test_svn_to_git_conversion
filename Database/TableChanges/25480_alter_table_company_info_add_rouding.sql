IF COL_LENGTH(N'[dbo].[company_info]', N'price_rounding') IS NULL
BEGIN
    ALTER TABLE
	/**
		Columns
		price_rounding : Round value for Price value
	*/
		[dbo].[company_info] ADD price_rounding INT
	PRINT 'price_rounding column added'
END
GO

IF COL_LENGTH(N'[dbo].[company_info]', N'volume_rounding') IS NULL
BEGIN
    ALTER TABLE
	/**
		Columns
		volume_rounding : Round value for Volume value
	*/
		[dbo].[company_info] ADD volume_rounding INT
	PRINT 'volume_rounding column added'
END
GO

IF COL_LENGTH(N'[dbo].[company_info]', N'amount_rounding') IS NULL
BEGIN
    ALTER TABLE
	/**
		Columns
		amount_rounding : Round value for Amount value
	*/
		[dbo].[company_info] ADD amount_rounding INT
	PRINT 'amount_rounding column added'
END
GO

IF COL_LENGTH(N'[dbo].[company_info]', N'number_rounding') IS NULL
BEGIN
    ALTER TABLE
	/**
		Columns
		number_rounding : Round value for Number
	*/
		[dbo].[company_info] ADD number_rounding INT
	PRINT 'number_rounding column added'
END
GO