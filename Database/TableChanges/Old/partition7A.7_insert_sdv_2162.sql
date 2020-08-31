-- ===============================================================================================================
-- Create date: 2012-03-19
--  Description:	Static data value for Source Price Curve (Archive Data type id 2150
-- ===============================================================================================================

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2162)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (2162, 2150, 'FX-Exposure', 'FX-Exposure', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 2162 - FX-Exposure.'
END
ELSE
BEGIN
	PRINT 'Static data value 2162 - FX-Exposure already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
