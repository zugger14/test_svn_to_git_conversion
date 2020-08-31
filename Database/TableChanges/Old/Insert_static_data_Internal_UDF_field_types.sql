
IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 18700)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (18700, 'Internal UDF Field Type', 1, 'Internal UDF Field Type', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 18700 - Internal UDF Field Type.'
END
ELSE
BEGIN
	PRINT 'Static data type 18700 - Internal UDF Field Type already EXISTS.'
END
GO

--THE FOLLOWING ARE FOR BASELOAD
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18700)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18700, 18700, 'Position based fee', 'Position based fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18700 - Position based fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18700 - Position based fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18701)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18701,18700, 'Deal Volume based fee', 'Deal Volume based fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18701 - Deal Volume based fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18701 - Deal Volume based fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18702)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18702, 18700, 'Capacity based Annual fee', 'Capacity based Annual fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18702 - Capacity based Annual fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18702 - Capacity based Annual fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18703)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18703, 18700, 'Capacity based fee', 'Capacity based fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18703 - Capacity based fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18703 - Capacity based fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18704)
BEGIN
      INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
      VALUES (18704, 18700, 'Deal Volume based Annual fee', 'Deal Volume based Annual fee', 'farrms_admin', GETDATE())
      PRINT 'Inserted static data value 18704 - Deal Volume based Annual fee.'
END
ELSE
BEGIN
      PRINT 'Static data value 18704 - Deal Volume based Annual fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

--THE FOLLOWING ARE FOR ONPEAK
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18705)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18705, 18700, 'OnPeak Position based fee', 'OnPeak Position based fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18705 - OnPeak Position based fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18705 - OnPeak Position based fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18706)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18706,18700, 'OnPeak Deal Volume based fee', 'OnPeak Deal Volume based fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18706 - OnPeak Deal Volume based fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18706 - OnPeak Deal Volume based fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18707)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18707, 18700, 'OnPeak Capacity based Annual fee', 'OnPeak Capacity based Annual fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18707 - OnPeak Capacity based Annual fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18707 - OnPeak Capacity based Annual fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18708)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18708, 18700, 'OnPeak Capacity based fee', 'OnPeak Capacity based fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18708 - OnPeak Capacity based fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18708 - OnPeak Capacity based fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18709)
BEGIN
      INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
      VALUES (18709, 18700, 'OnPeak Deal Volume based Annual fee', 'OnPeak Deal Volume based Annual fee', 'farrms_admin', GETDATE())
      PRINT 'Inserted static data value 18709 - OnPeak Deal Volume based Annual fee.'
END
ELSE
BEGIN
      PRINT 'Static data value 18709 - OnPeak Deal Volume based Annual fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF


--THE FOLLOWING ARE FOR OFFPEAK
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18710)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18710, 18700, 'OffPeak Position based fee', 'OffPeak Position based fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18710 - OffPeak Position based fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18710 - OffPeak Position based fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18711)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18711,18700, 'OffPeak Deal Volume based fee', 'OffPeak Deal Volume based fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18711 - OffPeak Deal Volume based fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18711 - OffPeak Deal Volume based fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18712)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18712, 18700, 'OffPeak Capacity based Annual fee', 'OffPeak Capacity based Annual fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18712 - OffPeak Capacity based Annual fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18712 - OffPeak Capacity based Annual fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18713)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (18713, 18700, 'OffPeak Capacity based fee', 'OffPeak Capacity based fee', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 18713 - OffPeak Capacity based fee.'
END
ELSE
BEGIN
	PRINT 'Static data value 18713 - OffPeak Capacity based fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18714)
BEGIN
      INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
      VALUES (18714, 18700, 'OffPeak Deal Volume based Annual fee', 'OffPeak Deal Volume based Annual fee', 'farrms_admin', GETDATE())
      PRINT 'Inserted static data value 18714 - OffPeak Deal Volume based Annual fee.'
END
ELSE
BEGIN
      PRINT 'Static data value 18714 - OffPeak Deal Volume based Annual fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18715)
BEGIN
      INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
      VALUES (18715, 18700, 'Lump Sum Annual fee', 'Lump Sum Annual fee', 'farrms_admin', GETDATE())
      PRINT 'Inserted static data value 18715 - Lump Sum Annual fee.'
END
ELSE
BEGIN
      PRINT 'Static data value 18715 - Lump Sum Annual fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 18716)
BEGIN
      INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
      VALUES (18716, 18700, 'Lump Sum Monthly fee', 'Lump Sum Monthly fee', 'farrms_admin', GETDATE())
      PRINT 'Inserted static data value 18716 - Lump Sum Monthly fee.'
END
ELSE
BEGIN
      PRINT 'Static data value 18716 - Lump Sum Monthly fee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF