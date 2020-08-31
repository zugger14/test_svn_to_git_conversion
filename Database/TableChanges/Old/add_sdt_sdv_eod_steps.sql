IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19700)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19700, 'Eod Steps', 1, 'Eod Steps', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19700 - Eod Steps.'
END
ELSE
BEGIN
	PRINT 'Static data type 19700 - Eod Steps already EXISTS.'
END	

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19701)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19701, 19700, 'CMA spot price import request', 'CMA spot price import', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19701 - CMA spot price import.'
END
ELSE
BEGIN
	PRINT 'Static data value 19701 - CMA spot price import already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19702)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19702, 19700, 'CMA spot price import', 'CMA spot price import', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19702 - CMA spot price import.'
END
ELSE
BEGIN
	PRINT 'Static data value 19702 - CMA spot price import already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19703)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19703, 19700, 'Pratos staging tables processing', 'Pratos staging tables processing', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19703 - Pratos staging tables processing.'
END
ELSE
BEGIN
	PRINT 'Static data value 19703 - Pratos staging tables processing already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

IF NOT EXISTS(SELECT 1 FROM static_data_type WHERE [type_id] = 19700)
BEGIN
 	INSERT INTO static_data_type([type_id], [type_name], internal, [description], create_user, create_ts)
	VALUES (19700, 'Eod Steps', 1, 'Eod Steps', 'farrms_admin', GETDATE())
 	PRINT 'Inserted static data type 19700 - Eod Steps.'
END
ELSE
BEGIN
	PRINT 'Static data type 19700 - Eod Steps already EXISTS.'
END	

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19704)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19704, 19700, 'Load Forecast Files', 'Load Forecast Files', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19704 - Load Forecast Files.'
END
ELSE
BEGIN
	PRINT 'Static data value 19704 - Load Forecast Files already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19705)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19705, 19700, 'Run Deals Position Calc', 'Run Deals Position Calc', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19705 - Run Deals Position Calc.'
END
ELSE
BEGIN
	PRINT 'Static data value 19705 - Run Deals Position Calc already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19706)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19706, 19700, 'Recalculate Position for deals', 'Recalculate Position for deals', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19706 - Recalculate Position for deals.'
END
ELSE
BEGIN
	PRINT 'Static data value 19706 - Recalculate Position for deals already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19707)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19707, 19700, 'Check Deals with zero or NULL position', 'Check Deals with zero or NULL position', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19707 - Check Deals with zero or NULL position.'
END
ELSE
BEGIN
	PRINT 'Static data value 19707 - Check Deals with zero or NULL position already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19708)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19708, 19700, 'Import Forward prices from CMA Request', 'Import Forward prices from CMA Request', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19708 - Import Forward prices from CMA Request.'
END
ELSE
BEGIN
	PRINT 'Static data value 19708 - Import Forward prices from CMA Request already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19709)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19709, 19700, 'Import Forward prices from CMA Response', 'Import Forward prices from CMA Response', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19709 - Import Forward prices from CMA Response.'
END
ELSE
BEGIN
	PRINT 'Static data value 19709 - Import Forward prices from CMA Response already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19710)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19710, 19700, 'Copy Missing Prices', 'Copy Missing Prices', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19710 - Copy Missing Prices.'
END
ELSE
BEGIN
	PRINT 'Static data value 19710 - Copy Missing Prices already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19711)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19711, 19700, 'Check all price curves exist for cache curves', 'Check all price curves exist for cache curves', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19711 - Check all price curves exist for cache curves.'
END
ELSE
BEGIN
	PRINT 'Static data value 19711 - Check all price curves exist for cache curves already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19712)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19712, 19700, 'Copy Best available prices', 'Copy Best available prices', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19712 - Copy Best available prices.'
END
ELSE
BEGIN
	PRINT 'Static data value 19712 - Copy Best available prices already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19713)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19713, 19700, 'Run Cache Curves', 'Run Cache Curves', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19713 - Run Cache Curves.'
END
ELSE
BEGIN
	PRINT 'Static data value 19713 - Run Cache Curves already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19714)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19714, 19700, 'Copy Best available prices cache curves', 'Copy Best available prices cache curves', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19714 - Copy Best available prices cache curves.'
END
ELSE
BEGIN
	PRINT 'Static data value 19714 - Copy Best available prices cache curves already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19715)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19715, 19700, 'Calculate Storage WACOG Price', 'Calculate Storage WACOG Price', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19715 - Calculate Storage WACOG Price.'
END
ELSE
BEGIN
	PRINT 'Static data value 19715 - Calculate Storage WACOG Price already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19716)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19716, 19700, 'Run MTM Process', 'Run MTM Process', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19716 - Run MTM Process.'
END
ELSE
BEGIN
	PRINT 'Static data value 19716 - Run MTM Process already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19717)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19717, 19700, 'Run Deal Settlement', 'Run Deal Settlement', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19717 - Run Deal Settlement.'
END
ELSE
BEGIN
	PRINT 'Static data value 19717 - Run Deal Settlement already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19718)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19718, 19700, 'Run FX Exposure Calculation', 'Run FX Exposure Calculation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19718 - Run FX Exposure Calculation.'
END
ELSE
BEGIN
	PRINT 'Static data value 19718 - Run FX Exposure Calculation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF	

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19719)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19719, 19700, 'Run Hedge Deferral Calculation', 'Run Hedge Deferral Calculation', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19719 - Run Hedge Deferral Calculation.'
END
ELSE
BEGIN
	PRINT 'Static data value 19719 - Run Hedge Deferral Calculation already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19720)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19720, 19700, 'Functional check', 'Functional check', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19720 - Functional check.'
END
ELSE
BEGIN
	PRINT 'Static data value 19720 - Functional check already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19721)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19721, 19700, 'Generate cube', 'Generate cube', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19721 - Generate cube.'
END
ELSE
BEGIN
	PRINT 'Static data value 19721 - Generate cube already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19722)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19722, 19700, 'Check if all required cube data are populated in CUBES', 'Check if all required cube data are populated in CUBES', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19722 - Check if all required cube data are populated in CUBES.'
END
ELSE
BEGIN
	PRINT 'Static data value 19722 - Check if all required cube data are populated in CUBES already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19723)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19723, 19700, 'Send EoD status Email', 'Send EoD status Email', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19723 - Send EoD status Email.'
END
ELSE
BEGIN
	PRINT 'Static data value 19723 - Send EoD status Email already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 19724)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (19724, 19700, 'Process/Enable processing from Pratos Staging Tables', 'Process/Enable processing from Pratos Staging Tables', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 19724 - Process/Enable processing from Pratos Staging Tables.'
END
ELSE
BEGIN
	PRINT 'Static data value 19724 - Process/Enable processing from Pratos Staging Tables already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
