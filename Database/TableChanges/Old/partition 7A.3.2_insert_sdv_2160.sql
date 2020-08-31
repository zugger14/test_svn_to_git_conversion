-- ===============================================================================================================
-- Create date: 2012-05-10
--  Description:	Static data value for Position tables (Archive Data type id 2150
-- This code contains only 3 tables viz
--deal_position_break_down
--report_hourly_position_fixed
--delta_report_hourly_position
--report_hourly_position_deal
-- ===============================================================================================================
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2160)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (2160, 2150, 'Position2', 'Position2', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 2160 - Position2.'
END
ELSE
BEGIN
	PRINT 'Static data value 2160 - Position2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

