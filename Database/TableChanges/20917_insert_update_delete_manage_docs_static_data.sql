SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -50)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-50, 25, 'Credit File', 'Credit File', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -50 - Credit File.'
END
ELSE
BEGIN
    PRINT 'Static data value -50 - Credit File already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42034)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42034, 42000, 'Risks', 'Risks', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42034 - Risks.'
END
ELSE
BEGIN
    PRINT 'Static data value 42034 - Risks already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42035)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42035, 42000, 'Compliance', 'Compliance', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42035 - Compliance.'
END
ELSE
BEGIN
    PRINT 'Static data value 42035 - Compliance already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42036)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42036, 42000, 'Accounting', 'Accounting', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42036 - Accounting.'
END
ELSE
BEGIN
    PRINT 'Static data value 42036 - Accounting already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42037)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42037, 42000, 'Contract', 'Contract', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42037 - Contract.'
END
ELSE
BEGIN
    PRINT 'Static data value 42037 - Contract already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42038)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42038, 42000, 'Credit', 'Credit', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42038 - Credit.'
END
ELSE
BEGIN
    PRINT 'Static data value 42038 - Credit already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42039)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42039, 42000, 'Collateral', 'Collateral', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42039 - Collateral.'
END
ELSE
BEGIN
    PRINT 'Static data value 42039 - Collateral already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42040)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42040, 42000, 'Book', 'Book', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42040 - Book.'
END
ELSE
BEGIN
    PRINT 'Static data value 42040 - Book already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42041)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42041, 42000, 'Strategy', 'Strategy', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42041 - Strategy.'
END
ELSE
BEGIN
    PRINT 'Static data value 42041 - Strategy already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42042)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42042, 42000, 'Subsidiary', 'Subsidiary', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42042 - Subsidiary.'
END
ELSE
BEGIN
    PRINT 'Static data value 42042 - Subsidiary already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 42033)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (42033, 42000, 'General', 'General', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 42033 - General.'
END
ELSE
BEGIN
    PRINT 'Static data value 42033 - General already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DECLARE @value_ids_25 VARCHAR(MAX), @value_ids_42000 VARCHAR(MAX)

SELECT @value_ids_25 = ISNULL(@value_ids_25 + ',', '') + CAST(value_id AS VARCHAR(10)) 
FROM static_data_value WHERE type_id = 25
	AND code IN (
		'Counterparty Certificate',
		'Deal Required Documents',
		'Designation of Hedge',
		'Dispute',
		'First Day Gain Loss Treatment',
		'Hedge Documentation',
		'Hedge Relationship Type',
		'HedgeRelType',
		'Link',
		'Match Group',
		'Process',
		'Profile',
		'Renewable Source',
		'Schedule Match',
		'Ticket',
		'Workflow'
	)

SELECT @value_ids_42000 = ISNULL(@value_ids_42000 + ',', '') + CAST(value_id AS VARCHAR(10)) 
FROM static_data_value WHERE type_id = 42000
	AND code IN (
		'Deal Required Documents',
		'Deal Status',
		'Label',
		'Trade Ticket Collection',
		'Confirm Replacement Report Collection',
		'Invoice Report Collection',
		'Deal Confirm 2',
		'Trade Ticket',
		'Approved Counterparty',
		'Workflow',
		'Booking Declaration',
		'Booking Instructions',
		'Delivery Declaration',
		'Delivery Instructions',
		'Outward Collection Instructions',
		'Release Declaration',
		'Release Instructions',
		'Shipment Declaration',
		'Shipment Instructions',
		'Storage Declaration',
		'Storage Instructions'
	)

UPDATE a 
SET a.internal_type_value_id = 30
FROM application_notes a
INNER JOIN dbo.SplitCommaSeperatedValues(@value_ids_25) i
	ON a.internal_type_value_id = i.item

DELETE a 
FROM static_data_value a 
INNER JOIN dbo.SplitCommaSeperatedValues(@value_ids_25) i
	ON a.value_id = i.item

UPDATE a 
SET a.document_type_id = 42033
FROM documents_type a
INNER JOIN dbo.SplitCommaSeperatedValues(@value_ids_42000) i
	ON a.document_type_id = i.item

DELETE a
FROM static_data_value a 
INNER JOIN dbo.SplitCommaSeperatedValues(@value_ids_42000) i
	ON a.value_id = i.item
GO

UPDATE sdv
SET sdv.code = 'Certificate'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdt.type_id = sdv.type_id
WHERE sdv.type_id = 42000
	AND sdv.code = 'Counterparty Certificate'
GO

UPDATE sdv
SET sdv.code = 'Documents'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdt.type_id = sdv.type_id
WHERE sdv.type_id = 42000
	AND sdv.code = 'Counterparty Products'
GO

UPDATE sdv
SET sdv.code = 'Confirmation'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdt.type_id = sdv.type_id
WHERE sdv.type_id = 42000
	AND sdv.code = 'Deal Confirm'
GO