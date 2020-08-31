/****** Object:  UserDefinedFunction [dbo].[FNARUDFCharges]    Script Date: 04/02/2009 17:36:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNARUDFCharges]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[FNARUDFCharges]
GO

DELETE FROM static_data_value WHERE value_id IN(834,877,879,887,884,883,881,880)
Go

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 834)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (834, 800, 'DealFees', 'DealFees', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 8349 - DealFees.'
END
ELSE
BEGIN
	PRINT 'Static data value 834 - DealFees already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 877)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (877, 800, 'DealSettlement', 'DealSettlement', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 877 - DealSettlement.'
END
ELSE
BEGIN
	PRINT 'Static data value 877 - DealSettlement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 879)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (879, 800, 'ShapedVol', 'ShapedVol', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 879 - ShapedVol.'
END
ELSE
BEGIN
	PRINT 'Static data value 879 - ShapedVol already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
