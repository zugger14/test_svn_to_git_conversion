SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5501)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5501, 5500, 'Flex_Fee', 'Flex Fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5501 - Flex_Fee.'
END
ELSE
BEGIN
	PRINT 'Static data value -5501 - Flex_Fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5502)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5502, 5500, 'Lockin_Percentage', 'Lockin Percentage', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5502 - Lockin_Percentage.'
END
ELSE
BEGIN
	PRINT 'Static data value -5502 - Lockin_Percentage already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5503)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5503, 5500, 'Percentage_Fixed_BSLD', 'Percentage Fixed (BSLD)', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5503 - Percentage_Fixed_BSLD.'
END
ELSE
BEGIN
	PRINT 'Static data value -5503 - Percentage_Fixed_BSLD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5504)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5504, 5500, 'Percentage_Fixed_Onpeak', 'Percentage Fixed (Onpeak)', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5504 - Percentage_Fixed_Onpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5504 - Percentage_Fixed_Onpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5505)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5505, 5500, 'Percentage_Fixed_offpeak', 'Percentage Fixed (Offpeak)', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5505 - Percentage_Fixed_offpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5505 - Percentage_Fixed_offpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5509)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5509, 5500, 'Other_Fees', 'Other Fees', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5509 - Other_Fees.'
END
ELSE
BEGIN
	PRINT 'Static data value -5509 - Other_Fees already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5510)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5510, 5500, 'Fixed_Fees_Onpeak', 'Fixed fees (onpeak)', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5510 - Fixed_Fees_Onpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5510 - Fixed_Fees_Onpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5511)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5511, 5500, 'Fixed_Fees_Baseload', 'Fixed fees (baseload)', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5511 - Fixed_Fees_Baseload.'
END
ELSE
BEGIN
	PRINT 'Static data value -5511 - Fixed_Fees_Baseload already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5512)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5512, 5500, 'Fixed_Fees_Offpeak', 'Fixed fees (offpeak)', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5512 - Fixed_Fees_Offpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5512 - Fixed_Fees_Offpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5513)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5513, 5500, 'Discount', 'Discount', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5513 - Discount.'
END
ELSE
BEGIN
	PRINT 'Static data value -5513 - Discount already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5514)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5514, 5500, 'Regional_Component', 'Regional Component', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5514 - Regional_Component.'
END
ELSE
BEGIN
	PRINT 'Static data value -5514 - Regional_Component already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5515)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5515, 5500, 'AddOnOffPeak', 'Add On OffPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5515 - AddOnOffPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5515 - AddOnOffPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5516)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5516, 5500, 'AddOnOnPeak', 'Add On OnPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5516 - AddOnOnPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5516 - AddOnOnPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5517)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5517, 5500, 'Validity', 'Validity', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5517 - Validity.'
END
ELSE
BEGIN
	PRINT 'Static data value -5517 - Validity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5518)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5518, 5500, 'ShapingY-Q', 'ShapingY-Q', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5518 - ShapingY-Q.'
END
ELSE
BEGIN
	PRINT 'Static data value -5518 - ShapingY-Q already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5519)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5519, 5500, 'ShapingQ-M', 'ShapingQ-M', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5519 - ShapingQ-M.'
END
ELSE
BEGIN
	PRINT 'Static data value -5519 - ShapingQ-M already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5520)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5520, 5500, 'ShapingM-H', 'ShapingM-H', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5520 - ShapingM-H.'
END
ELSE
BEGIN
	PRINT 'Static data value -5520 - ShapingM-H already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5521)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5521, 5500, 'ShapingY-Q-Disc', 'ShapingY-Q-Disc', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5521 - ShapingY-Q-Disc.'
END
ELSE
BEGIN
	PRINT 'Static data value -5521 - ShapingY-Q-Disc already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5522)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5522, 5500, 'ShapingQ-M-Disc', 'ShapingQ-M-Disc', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5522 - ShapingQ-M-Disc.'
END
ELSE
BEGIN
	PRINT 'Static data value -5522 - ShapingQ-M-Disc already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5523)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5523, 5500, 'ShapingM-H-Disc', 'ShapingM-H-Disc', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5523 - ShapingM-H-Disc.'
END
ELSE
BEGIN
	PRINT 'Static data value -5523 - ShapingM-H-Disc already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5524)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5524, 5500, 'Hedge Risk', 'Hedge Risk', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5524 - Hedge Risk.'
END
ELSE
BEGIN
	PRINT 'Static data value -5524 - Hedge Risk already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5525)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5525, 5500, 'Imbalance Risk', 'Imbalance Risk', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5525 - Imbalance Risk.'
END
ELSE
BEGIN
	PRINT 'Static data value -5525 - Imbalance Risk already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5526)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5526, 5500, 'Weather Risk', 'Weather Risk', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5526 - Weather Risk.'
END
ELSE
BEGIN
	PRINT 'Static data value -5526 - Weather Risk already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5527)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5527, 5500, 'LoadShapingOffPeak', 'Load Shaping OffPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5527 - LoadShapingOffPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5527 - LoadShapingOffPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5528)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5528, 5500, 'PVOffPeak', 'PV OffPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5528 - PVOffPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5528 - PVOffPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5529)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5529, 5500, 'ValidityOffPeak', 'Validity OffPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5529 - ValidityOffPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5529 - ValidityOffPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5530)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5530, 5500, 'VolumeFlexOffPeak', 'Volume Flex OffPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5530 - VolumeFlexOffPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5530 - VolumeFlexOffPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5531)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5531, 5500, 'LoadShapingOnPeak', 'Load Shaping OnPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5531 - LoadShapingOnPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5531 - LoadShapingOnPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5532)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5532, 5500, 'PVOnPeak', 'PV OnPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5532 - PVOnPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5532 - PVOnPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5533)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5533, 5500, 'ValidityOnPeak', 'Validity OnPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5533 - ValidityOnPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5533 - ValidityOnPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5534)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5534, 5500, 'VolumeFlexOnPeak', 'Volume Flex OnPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5534 - VolumeFlexOnPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5534 - VolumeFlexOnPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
