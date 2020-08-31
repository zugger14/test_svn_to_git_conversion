-- ===============================================================================================================
-- Create date: 2012-03-19
--  Description:	Static data value for Source Price Curve (Archive Data type id 2150
-- ===============================================================================================================

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2161)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (2161, 2150, 'Settlement Reporting', 'Settlement Reporting', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 2161 - Settlement Reporting.'
END
ELSE
BEGIN
	PRINT 'Static data value 2161 - Settlement Reporting already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
