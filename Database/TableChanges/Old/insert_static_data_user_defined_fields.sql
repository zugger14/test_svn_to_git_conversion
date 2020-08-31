--- pawan's insert script ----------------------
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
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5505)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5505, 5500, 'Percentage_Fixed_Offpeak', 'Percentage Fixed (Offpeak)', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5505 - Percentage_Fixed_Offpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5505 - Percentage_Fixed_Offpeak already EXISTS.'
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
	VALUES (-5510, 5500, 'Fixed_Fees_Onpeak', 'Fixed Fees (Onpeak)', 'farrms_admin', GETDATE())
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
	VALUES (-5511, 5500, 'Fixed_Fees_Baseload', 'Fixed Fees (Baseload)', 'farrms_admin', GETDATE())
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
	VALUES (-5512, 5500, 'Fixed_Fees_Offpeak', 'Fixed Fees (Offpeak)', 'farrms_admin', GETDATE())
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
	VALUES (-5518, 5500, 'Shaping_Y_Q', 'Shaping Y-Q', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5518 - Shaping_Y_Q.'
END
ELSE
BEGIN
	PRINT 'Static data value -5518 - Shaping_Y_Q already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5519)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5519, 5500, 'Shaping_Q_M', 'Shaping Q-M', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5519 - Shaping_Q_M.'
END
ELSE
BEGIN
	PRINT 'Static data value -5519 - Shaping_Q_M already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5520)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5520, 5500, 'Shaping_M_H', 'Shaping M-H', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5520 - Shaping_M_H.'
END
ELSE
BEGIN
	PRINT 'Static data value -5520 - Shaping_M_H already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5521)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5521, 5500, 'Shaping_Y_Q_Disc', 'Shaping Y-Q-Disc', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5521 - Shaping_Y_Q_Disc.'
END
ELSE
BEGIN
	PRINT 'Static data value -5521 - Shaping_Y_Q_Disc already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5522)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5522, 5500, 'Shaping_Q_M_Disc', 'Shaping Q-M-Disc', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5522 - Shaping_Q_M_Disc.'
END
ELSE
BEGIN
	PRINT 'Static data value -5522 - Shaping_Q_M_Disc already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5523)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5523, 5500, 'Shaping_M_H_Disc', 'Shaping M-H-Disc', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5523 - Shaping_M_H_Disc.'
END
ELSE
BEGIN
	PRINT 'Static data value -5523 - Shaping_M_H_Disc already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5524)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5524, 5500, 'Hedge_Risk', 'Hedge Risk', 'farrms_admin', GETDATE())
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
	VALUES (-5525, 5500, 'Imbalance_Risk', 'Imbalance Risk', 'farrms_admin', GETDATE())
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
	VALUES (-5526, 5500, 'Weather_Risk', 'Weather Risk', 'farrms_admin', GETDATE())
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
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5535)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5535, 5500, 'Fixed_Commodity_Onpeak', 'Fixed Commodity Onpeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5535 - Fixed_Commodity_Onpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5535 - Fixed_Commodity_Onpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5536)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5536, 5500, 'Fixed_Commodity_Offpeak', 'Fixed Commodity Offpeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5536 - Fixed_Commodity_Offpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5536 - Fixed_Commodity_Offpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5537)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5537, 5500, 'Fixed_Volume_Offpeak', 'Fixed Volume Offpeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5537 - Fixed_Volume_Offpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5537 - Fixed_Volume_Offpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5538)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5538, 5500, 'Fixed_Volume_Onpeak', 'Fixed Volume Onpeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5538 - Fixed_Volume_Onpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5538 - Fixed_Volume_Onpeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5539)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5539, 5500, 'Fixed_Volume_BSLD', 'Fixed Volume BSLD', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5539 - Fixed_Volume_BSLD.'
END
ELSE
BEGIN
	PRINT 'Static data value -5539 - Fixed_Volume_BSLD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5540)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5540, 5500, 'Fixed_Commodity', 'Fixed Commodity', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5540 - Fixed_Commodity.'
END
ELSE
BEGIN
	PRINT 'Static data value -5540 - Fixed_Commodity already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5541)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5541, 5500, 'Z', 'Z', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5541 - Z.'
END
ELSE
BEGIN
	PRINT 'Static data value -5541 - Z already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


--- end of pawan's insert script---------------------



SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5542)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5542, 5500, 'Capacity_UOM', 'Capacity UOM', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5542 - Capacity UOM.'
END
ELSE
BEGIN
	PRINT 'Static data value -5542 - Capacity UOM already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5543)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5543, 5500, 'Category', 'Category', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5543 - Category.'
END
ELSE
BEGIN
	PRINT 'Static data value -5543 - Category already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5544)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5544, 5500, 'Customer_Name', 'Customer Name', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5544 - Customer Name.'
END
ELSE
BEGIN
	PRINT 'Static data value -5544 - Customer Name already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5546)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5546, 5500, 'Exit_Point_EAN', 'Exit Point EAN', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5546 - Exit Point EAN.'
END
ELSE
BEGIN
	PRINT 'Static data value -5546 - Exit Point EAN already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5547)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5547, 5500, 'Fixation', 'Fixation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5547 - Fixation.'
END
ELSE
BEGIN
	PRINT 'Static data value -5547 - Fixation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5548)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5548, 5500, 'FixationOffPeak', 'Fixation OffPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5548 - FixationOffPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5548 - FixationOffPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5549)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5549, 5500, 'FixationOnPeak', 'Fixation OnPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5549 - FixationOnPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5549 - FixationOnPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5550)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5550, 5500, 'FixedOffPeak', 'Fixed OffPeak', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5550 - Fixed OffPeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5550 - FixedOffPeak already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

DELETE FROM static_data_value WHERE TYPE_ID = 5500 AND value_id > 0 AND code = 'Lump_Sum'
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5552)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5552, 5500, 'Lump_Sum', 'Lump Sum', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5552 - Lump Sum.'
END
ELSE
BEGIN
	PRINT 'Static data value -5552 - Lump Sum already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5553)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5553, 5500, 'Multiplier1', 'Multiplier1', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5553 - Multiplier1.'
END
ELSE
BEGIN
	PRINT 'Static data value -5553 - Multiplier1 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5554)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5554, 5500, 'Multiplier2', 'Multiplier2', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5554 - Multiplier2.'
END
ELSE
BEGIN
	PRINT 'Static data value -5554 - Multiplier2 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5555)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5555, 5500, 'Multiplier3', 'Multiplier3', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5555 - Multiplier3.'
END
ELSE
BEGIN
	PRINT 'Static data value -5555 - Multiplier3 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5556)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5556, 5500, 'Multiplier4', 'Multiplier4', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5556 - Multiplier4.'
END
ELSE
BEGIN
	PRINT 'Static data value -5556 - Multiplier4 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5557)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5557, 5500, 'Percentage_Fixed', 'Percentage Fixed', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5557 - Percentage Fixed.'
END
ELSE
BEGIN
	PRINT 'Static data value -5557 - Percentage Fixed already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5559)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5559, 5500, 'Pricing_Shipper', 'Pricing Shipper', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5559 - Pricing Shipper.'
END
ELSE
BEGIN
	PRINT 'Static data value -5559 - Pricing Shipper already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5561)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5561, 5500, 'Sourcing_Classification', 'Sourcing Classification', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5561 - Sourcing Classification.'
END
ELSE
BEGIN
	PRINT 'Static data value -5561 - Sourcing Classification already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5562)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5562, 5500, 'Standard_Profile', 'Standard Profile', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5562 - Standard Profile.'
END
ELSE
BEGIN
	PRINT 'Static data value -5562 - Standard Profile already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5564)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (-5564, 5500, 'is_profile', 'is_profile', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value -5564 - is_profile.'
END
ELSE
BEGIN
	PRINT 'Static data value -5564 - is_profile already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


-------------------- update script start--------------------------

SET IDENTITY_INSERT static_data_value ON
IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5514)
BEGIN
	UPDATE  static_data_value SET  code = 'Regional_Component' , [description] = 'Regional Component'
	WHERE value_id = -5514
	PRINT 'Updated static data value -5514 - Regional Component.'
END
ELSE
BEGIN
	PRINT 'Static data value -5514 - Regional Component does not EXIST.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5520)
BEGIN
	UPDATE  static_data_value set code = 'ShapingM-H', [description] = 'Shaping M-H' 
	WHERE value_id = -5520
	PRINT 'Updated static data value -5520 - ShapingM-H.'
END
ELSE
BEGIN
	PRINT 'Static data value -5520 - ShapingM-H does not EXIST.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5523)
BEGIN
	UPDATE static_data_value set code = 'ShapingM-H-Disc', [description] = 'Shaping M-H-Disc'
	WHERE value_id = -5523
	PRINT 'Updated static data value -5523 - ShapingM-H-Disc.'
END
ELSE
BEGIN
	PRINT 'Static data value -5523 - ShapingM-H-Disc does not EXIST.'
END
SET IDENTITY_INSERT static_data_value OFF


SET IDENTITY_INSERT static_data_value ON
IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5519)
BEGIN
	UPDATE static_data_value set code = 'ShapingQ-M', [description] = 'Shaping Q-M'
	WHERE value_id = -5519
	PRINT 'Updated static data value -5519 - ShapingQ-M.'
END
ELSE
BEGIN
	PRINT 'Static data value -5519 - ShapingQ-M does not EXIST.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5522)
BEGIN
	UPDATE static_data_value set code = 'ShapingQ-M-Disc', [description] = 'Shaping Q-M-Disc'
	WHERE value_id = -5522
	PRINT 'Updated static data value -5522 - ShapingQ-M-Disc.'
END
ELSE
BEGIN
	PRINT 'Static data value -5522 - ShapingQ-M-Disc does not EXIST.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5518)
BEGIN
	UPDATE static_data_value set code = 'ShapingY-Q', [description] = 'Shaping Y-Q'
	WHERE value_id = -5518
	PRINT 'Updated static data value -5518 - ShapingY-Q.'
END
ELSE
BEGIN
	PRINT 'Static data value -5518 - ShapingY-Q does not EXIST.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5521)
BEGIN
	UPDATE static_data_value set code = 'ShapingY-Q-Disc', [description] = 'Shaping Y-Q-Disc'
	WHERE value_id = -5521
	PRINT 'Updated static data value -5521 - ShapingY-Q-Disc.'
END
ELSE
BEGIN
	PRINT 'Static data value -5521 - ShapingY-Q-Disc does not EXIST.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5535)
BEGIN
	UPDATE  static_data_value set code = 'FixedCommodityOnpeak', [description] ='Fixed Commodity Onpeak'
	WHERE value_id = -5535
	PRINT 'Updated static data value -5535 - FixedCommodityOnpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5535 - FixedCommodityOnpeak does not EXIST.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5536)
BEGIN
	UPDATE static_data_value set code = 'FixedCommodityOffpeak', [description]='Fixed Commodity Offpeak'
	WHERE value_id = -5536
	PRINT 'Updated static data value -5536 - FixedCommodityOffpeak.'
END
ELSE
BEGIN
	PRINT 'Static data value -5536 - FixedCommodityOffpeak does not EXISTS.'
END 	
	SET IDENTITY_INSERT static_data_value OFF
	
SET IDENTITY_INSERT static_data_value ON
IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5540)
BEGIN
	UPDATE static_data_value set code = 'FixedCommodity', [description]='Fixed Commodity'
	WHERE value_id = -5540
	PRINT 'Updated static data value -5540 - FixedCommodity.'
END
ELSE
BEGIN
	PRINT 'Static data value -5540 - FixedCommodity does not EXISTS.'
END 
	SET IDENTITY_INSERT static_data_value OFF
	
------------------------- update script end--------------------------------

------------------------- delete script start --------------------------

IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5509)
BEGIN
	DELETE FROM  static_data_value WHERE value_id = -5509
	PRINT 'Static data value -5509 - Other_Fees Deleted.'
END
ELSE
BEGIN
	PRINT 'Static data value -5509 - Other_Fees does not EXIST.'
END

IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5511)
BEGIN
	DELETE FROM static_data_value WHERE value_id = -5511
	PRINT 'Static data value -5511 - Fixed_Fees_Baseload Deleted.'
END
ELSE
BEGIN
	PRINT 'Static data value -5511 - Fixed_Fees_Baseload does not EXIST.'
END

IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5512)
BEGIN
	DELETE FROM  static_data_value WHERE value_id = -5512
	PRINT 'Static data value -5512 - Fixed_Fees_Offpeak Deleted.'
END
ELSE
BEGIN
	PRINT 'Static data value -5512 - Fixed_Fees_Offpeak does not EXIST.'
END

IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5510)
BEGIN
	DELETE FROM  static_data_value WHERE value_id = -5510
	PRINT 'Static data value -5510 - Fixed_Fees_Onpeak Deleted.'
END
ELSE
BEGIN
	PRINT 'Static data value -5510 - Fixed_Fees_Onpeak does not EXIST.'
END

IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5539)
BEGIN
	DELETE FROM  static_data_value WHERE value_id = -5539
	PRINT 'Static data value -5539 - Fixed_Volume_BSLD Deleted.'
END
ELSE
BEGIN
	PRINT 'Static data value -5539 - Fixed_Volume_BSLD does not EXIST.'
END

IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5537)
BEGIN
	DELETE FROM static_data_value WHERE value_id = -5537
	PRINT 'Static data value -5537 - Fixed_Volume_Offpeak Deleted.'
END
ELSE
BEGIN
	PRINT 'Static data value -5537 - Fixed_Volume_Offpeak does not EXIST.'
END

IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5538)
BEGIN
	DELETE FROM static_data_value WHERE value_id = -5538
	PRINT 'Static data value -5538 - Fixed_Volume_Onpeak Deleted.'
END
ELSE
BEGIN
	PRINT 'Static data value -5538 - Fixed_Volume_Onpeak does not EXIST.'
END

IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5503)
BEGIN
	DELETE FROM static_data_value WHERE value_id = -5503
	PRINT 'Static data value -5503 - Percentage_Fixed_BSLD Deleted.'
END
ELSE
BEGIN
	PRINT 'Static data value -5503 - Percentage_Fixed_BSLD does not EXIST.'
END

IF EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -5505)
BEGIN
	DELETE FROM static_data_value WHERE value_id = -5505
	PRINT 'Static data value -5505 - Percentage_Fixed_Offpeak Deleted.'
END
ELSE
BEGIN
	PRINT 'Static data value -5505 - Percentage_Fixed_Offpeak does not EXIST.'
END

------------------------- delete script end --------------------------

------------------------ insert udf tabs ----------------------------

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 15600 AND code = 'Fees')
BEGIN	
	INSERT INTO static_data_value ([type_id], code, [description], create_user, create_ts)
	VALUES (15600, 'Fees', 'Fees', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value - Fees.'
END
ELSE
BEGIN
	PRINT 'Static data value  - Fees already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 15600 AND code = 'General')
BEGIN	
	INSERT INTO static_data_value ([type_id], code, [description], create_user, create_ts)
	VALUES (15600, 'General', 'General', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value - General.'
END
ELSE
BEGIN
	PRINT 'Static data value  - General already EXISTS.'
END


IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 15600 AND code = 'Risk Premium')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description], create_user, create_ts)
	VALUES (15600, 'Risk Premium', 'Risk Premium', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value - Risk Premium.'
END
ELSE
BEGIN
		PRINT 'Static data value  - Risk Premium already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 15600 AND code = 'Adder')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description], create_user, create_ts)
	VALUES (15600, 'Adder', 'Adder', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value - Adder.'
END
ELSE
BEGIN
		PRINT 'Static data value  - Adder already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 15600 AND code = 'Capacity')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description], create_user, create_ts)
	VALUES (15600, 'Capacity', 'Capacity', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value - Capacity.'
END
ELSE
BEGIN
		PRINT 'Static data value  - Capacity already EXISTS.'
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE [type_id] = 15600 AND code = 'Multiplier')
BEGIN
	INSERT INTO static_data_value ([type_id], code, [description], create_user, create_ts)
	VALUES (15600, 'Multiplier', 'Multiplier', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value - Multiplier.'
END
ELSE
BEGIN
		PRINT 'Static data value  - Multiplier already EXISTS.'
END

--SELECT * FROM static_data_value WHERE [type_id] = 15600 

-------------------- udf tab insert end--------------------------------------



-- CORRECTIONS
UPDATE static_data_value 
SET code = 'Multiplier1', description = 'Multiplier1'
WHERE [type_id] = 5500
AND code = 'Multtiplier1'

DELETE FROM static_data_value WHERE TYPE_ID = 5500 AND value_id < 0 AND code = 'Percentage_Fixed_Onpeak'

UPDATE sdv
SET code = REPLACE(code,' ','_') 
FROM static_data_value sdv 
WHERE TYPE_ID = 5500 AND code IN (
'Capacity UOM',
'Customer Name',
'Exit Point EAN',
'Flex Fee',
'Hedge Risk',
'Imbalance Risk',
'Lockin Percentage',
'Lump Sum',
'Percentage Fixed',
'Pricing Shipper',
'Regional Component',
'Sourcing Classification',
'Standard Profile',
'Weather Risk')

-- Corrected sourcin_classification to sourcing_classification
UPDATE sdv
SET code = 'Sourcing_Classification'
FROM static_data_value sdv
WHERE value_id = -5561 



-- Changed the order of the Multipliers in static data
UPDATE static_data_value SET [type_id]= 5500, [code] = 'tmpMultiplier1', [description] = 'Multiplier1' WHERE [value_id] = -5553 
PRINT 'Updated static data value -5553 - Multiplier1.'
UPDATE static_data_value SET [type_id]= 5500, [code] = 'tmpMultiplier2', [description] = 'Multiplier2' WHERE [value_id] = -5554 
PRINT 'Updated static data value -5554 - Multiplier2.'
UPDATE static_data_value SET [type_id]= 5500, [code] = 'tmpMultiplier3', [description] = 'Multiplier3' WHERE [value_id] = -5555 
PRINT 'Updated static data value -5555 - Multiplier3.'
UPDATE static_data_value SET [type_id]= 5500, [code] = 'tmpMultiplier4', [description] = 'Multiplier4' WHERE [value_id] = -5556 
PRINT 'Updated static data value -5556 - Multiplier4.'

UPDATE static_data_value SET [type_id]= 5500, [code] = 'Multiplier1', [description] = 'Multiplier1' WHERE [value_id] = -5553 
PRINT 'Updated static data value -5553 - Multiplier1.'
UPDATE static_data_value SET [type_id]= 5500, [code] = 'Multiplier2', [description] = 'Multiplier2' WHERE [value_id] = -5554 
PRINT 'Updated static data value -5554 - Multiplier2.'
UPDATE static_data_value SET [type_id]= 5500, [code] = 'Multiplier3', [description] = 'Multiplier3' WHERE [value_id] = -5555 
PRINT 'Updated static data value -5555 - Multiplier3.'
UPDATE static_data_value SET [type_id]= 5500, [code] = 'Multiplier4', [description] = 'Multiplier4' WHERE [value_id] = -5556 
PRINT 'Updated static data value -5556 - Multiplier4.'


UPDATE user_defined_deal_fields_template SET field_label = 'Multiplier1' WHERE field_name = -5553 and field_label = 'Multiplier3'
UPDATE user_defined_deal_fields_template SET field_label = 'Multiplier3' WHERE field_name = -5555 and field_label = 'Multiplier4'
UPDATE user_defined_deal_fields_template SET field_label = 'Multiplier4' WHERE field_name = -5556 and field_label = 'Multiplier1'

DELETE FROM static_data_value WHERE TYPE_ID = 5500 AND value_id < 0 AND code = 'Discount_AC'
