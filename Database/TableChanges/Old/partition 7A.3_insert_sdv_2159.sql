-- ===============================================================================================================
-- Create date: 2012-05-10
--  Description:	Static data value for Position tables (Archive Data type id 2150
-- This code contains only 3 tables viz
--report_hourly_position_profile
--report_hourly_position_breakdown
--delta_report_hourly_position_breakdown
-- ===============================================================================================================
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 2159)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (2159, 2150, 'Position1', 'Position1', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 2159 - Position1.'
END
ELSE
BEGIN
	PRINT 'Static data value 2159 - Position1 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

