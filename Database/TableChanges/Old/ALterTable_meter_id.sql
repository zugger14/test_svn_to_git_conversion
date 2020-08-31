IF COL_LENGTH('meter_id', 'counterparty_id') IS NULL
BEGIN
	ALTER TABLE meter_id add counterparty_id INT
	PRINT 'Column meter_id.counterparty_id added.'
END
ELSE
BEGIN
	PRINT 'Column meter_id.counterparty_id already exists.'
END
GO


IF COL_LENGTH('meter_id', 'commodity_id') IS NULL
BEGIN
	ALTER TABLE meter_id add commodity_id INT
	PRINT 'Column meter_id.commodity_id added.'
END
ELSE
BEGIN
	PRINT 'Column meter_id.commodity_id already exists.'
END
GO

IF COL_LENGTH('meter_id', 'sub_meter_id') IS NULL
BEGIN
	ALTER TABLE [dbo].[meter_id] ADD sub_meter_id INT
	ALTER TABLE [dbo].[meter_id] WITH NOCHECK ADD CONSTRAINT [FK_meter_id_meter_id] FOREIGN KEY([sub_meter_id]) REFERENCES [dbo].[meter_id](meter_id)
	
	PRINT 'Column meter_id.sub_meter_id added.'
END
ELSE
BEGIN
	PRINT 'Column meter_id.sub_meter_id already exists.'
END
GO


IF COL_LENGTH('meter_id', 'country_id') IS NULL
BEGIN
	ALTER TABLE meter_id add country_id INT
	PRINT 'Column meter_id.country_id added.'
END
ELSE
BEGIN
	PRINT 'Column meter_id.country_id already exists.'
END
GO


IF COL_LENGTH('meter_id', 'granularity') IS NULL
BEGIN
	ALTER TABLE meter_id ADD granularity CHAR(1)
	PRINT 'Column meter_id.granularity added.'
END
ELSE
BEGIN
	PRINT 'Column meter_id.granularity already exists.'
END
GO
