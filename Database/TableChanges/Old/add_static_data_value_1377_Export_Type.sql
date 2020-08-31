/************************************************************
-- Author:		sbantawa@pioneersolutionglobals.com
-- Create date:	18th May, 2012
-- Description:	Adding Export Type RWE SAP Export
************************************************************/

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 1377)
BEGIN
	INSERT INTO static_data_value (value_id, [type_id], code, [description], create_user, create_ts)
	VALUES (1377, 1375, 'RWE SAP Export', 'RWE SAP Export', 'farrms_admin', GETDATE())
	PRINT 'Inserted static data value 1377 - RWE SAP Export.'
END
ELSE
BEGIN
	PRINT 'Static data value 1377 - RWE SAP Export already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF