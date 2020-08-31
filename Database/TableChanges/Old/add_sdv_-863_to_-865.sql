SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -863)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-863, 800, 'BuySell', 'Function BuySell', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -863 - BuySell.'
END
ELSE
BEGIN
	PRINT 'Static data value -863 - BuySell already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -864)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-864, 800, 'SettlementVolm', 'Function SettlementVolm', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -864 - SettlementVolm.'
END
ELSE
BEGIN
	PRINT 'Static data value -864 - SettlementVolm already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -865)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-865, 800, 'DealMultiplier', 'Function DealMultiplier', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -865 - DealMultiplier.'
END
ELSE
BEGIN
	PRINT 'Static data value -865 - DealMultiplier already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
