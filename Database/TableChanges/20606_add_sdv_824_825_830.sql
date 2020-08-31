SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 830)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (830, 800, 'TotalPeriodHour', 'This function is used to find Total Period Hour', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 830 - TotalPeriodHour.'
END
ELSE
BEGIN
    PRINT 'Static data value 830 - TotalPeriodHour already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 825)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (825, 800, 'OffPeakPeriodHour', 'This function is used to find Off Peak Period Hour', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 825 - OffPeakPeriodHour.'
END
ELSE
BEGIN
    PRINT 'Static data value 825 - OffPeakPeriodHour already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 824)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (824, 800, 'OnPeakPeriodHour', 'This function is used to find On Peak Period Hour', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 824 - OnPeakPeriodHour.'
END
ELSE
BEGIN
    PRINT 'Static data value 824 - OnPeakPeriodHour already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF