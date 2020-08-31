SET NOCOUNT ON

UPDATE sdv
SET sdv.code = 'Final',
	sdv.[description] = 'Final'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE (sdv.code = 'Approved' OR sdv.[description] = 'Approved')
	AND sdt.[type_name] = 'Deal Status'
GO

UPDATE sdv
SET sdv.code = 'Risk Approved',
	sdv.[description] = 'Risk Approved'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Final Risk Review'
	AND sdt.[type_name] = 'Deal Status'
GO

UPDATE sdv
SET sdv.code = 'Void',
	sdv.[description] = 'Void'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Cancelled'
	AND sdt.[type_name] = 'Deal Status'
GO

UPDATE sdv
SET sdv.code = 'Trader Approved',
	sdv.[description] = 'Trader Approved'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Validated'
	AND sdt.[type_name] = 'Deal Status'
GO

UPDATE sdv
SET sdv.code = 'Energy Trading',
	sdv.[description] = 'Energy Trading'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Energy Trading & Marketing'
	AND sdt.[type_name] = 'Organization Type'
GO

UPDATE sdv
SET sdv.code = 'Clearing Party',
	sdv.[description] = 'Clearing Party'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Accounting Party'
	AND sdt.[type_name] = 'Organization Type'
GO

UPDATE sdv
SET sdv.code = 'ISO',
	sdv.[description] = 'ISO'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Confirming Party'
	AND sdt.[type_name] = 'Organization Type'
GO

UPDATE sdv
SET sdv.code = 'LSE',
	sdv.[description] = 'LSE'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Market Place'
	AND sdt.[type_name] = 'Organization Type'
GO

UPDATE sdv
SET sdv.code = 'Internal',
	sdv.[description] = 'Internal'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'JP Morgan'
	AND sdt.[type_name] = 'Organization Type'
GO

UPDATE sdv
SET sdv.code = 'Broker',
	sdv.[description] = 'Broker'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Municipal Utility'
	AND sdt.[type_name] = 'Organization Type'
GO

UPDATE sdv
SET sdv.code = 'New',
	sdv.[description] = 'New'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Director of Marketing and Sales Approved'
	AND sdt.[type_name] = 'Counterparty Status'
GO

UPDATE sdv
SET sdv.code = 'Analyst Approved',
	sdv.[description] = 'Analyst Approved'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Director of Marketing and Sales Approved Final'
	AND sdt.[type_name] = 'Counterparty Status'
GO

UPDATE sdv
SET sdv.code = 'Manager Approved',
	sdv.[description] = 'Manager Approved'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Risk Oversight Committee Approved'
	AND sdt.[type_name] = 'Counterparty Status'
GO

UPDATE sdv
SET sdv.code = 'Open',
	sdv.[description] = 'Open'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'New'
	AND sdt.[type_name] = 'Deal Detail Status'
GO

UPDATE sdv
SET sdv.code = 'Certified',
	sdv.[description] = 'Certified'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Delivered'
	AND sdt.[type_name] = 'Deal Detail Status'
GO

UPDATE sdv
SET sdv.code = 'Contractual',
	sdv.[description] = 'Contractual'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Exercised'
	AND sdt.[type_name] = 'Deal Detail Status'
GO

UPDATE sdv
SET sdv.code = 'Retired',
	sdv.[description] = 'Retired'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Expired'
	AND sdt.[type_name] = 'Deal Detail Status'
GO

UPDATE sdv
SET sdv.code = 'Forecast',
	sdv.[description] = 'Forecast'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Generated'
	AND sdt.[type_name] = 'Deal Detail Status'
GO

UPDATE sdv
SET sdv.code = 'Actual',
	sdv.[description] = 'Actual'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Settled'
	AND sdt.[type_name] = 'Deal Detail Status'
GO

UPDATE sdv
SET sdv.code = 'Ready for invoice',
	sdv.[description] = 'Ready for invoice'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code IN ('Pending', 'Ready for invoiced')
	AND sdt.[type_name] = 'Deal Detail Status'
GO

UPDATE sdv
SET sdv.code = 'Invoiced',
	sdv.[description] = 'Invoiced'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Transferred'
	AND sdt.[type_name] = 'Deal Detail Status'
GO

UPDATE sdv
SET sdv.code = 'New',
	sdv.[description] = 'New'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Draft'
	AND sdt.[type_name] = 'Contract Status'
GO

UPDATE sdv
SET sdv.code = 'Contract Analyst Approved',
	sdv.[description] = 'Contract Analyst Approved'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Submitted for Approval'
	AND sdt.[type_name] = 'Contract Status'
GO

UPDATE sdv
SET sdv.code = 'Contract Manager Approved',
	sdv.[description] = 'Contract Manager Approved'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Approved'
	AND sdt.[type_name] = 'Contract Status'
GO

UPDATE sdv
SET sdv.code = 'Complete',
	sdv.[description] = 'Complete'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Approved'
	AND sdt.[type_name] = 'Workflow Status'
GO

UPDATE sdv
SET sdv.code = 'Initial',
	sdv.[description] = 'Initial'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Draft'
	AND sdt.[type_name] = 'Workflow Status'
GO

UPDATE sdv
SET sdv.code = 'Analyst Approved',
	sdv.[description] = 'Analyst Approved'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Submitted for Approval'
	AND sdt.[type_name] = 'Workflow Status'
GO

UPDATE sdv
SET sdv.code = 'Manager Approved',
	sdv.[description] = 'Manager Approved'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Submitted for Recall'
	AND sdt.[type_name] = 'Workflow Status'
GO

UPDATE sdv
SET sdv.code = 'Exception',
	sdv.[description] = 'Exception'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Unapproved'
	AND sdt.[type_name] = 'Workflow Status'
GO

UPDATE sdv
SET sdv.code = '5A',
	sdv.[description] = '5A'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'A'
	AND sdt.[type_name] IN ('Debt rating4', 'D&B')
GO

UPDATE sdv
SET sdv.code = '4A',
	sdv.[description] = '4A'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'A+'
	AND sdt.[type_name] IN ('Debt rating4', 'D&B')
GO

UPDATE sdv
SET sdv.code = '3A',
	sdv.[description] = '3A'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'B+'
	AND sdt.[type_name] IN ('Debt rating4', 'D&B')
GO

UPDATE sdv
SET sdv.code = 'Verbally Confirmed',
	sdv.[description] = 'Verbally Confirmed'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Received Confirmation'
	AND sdt.[type_name] = 'Deal Confirm Status'
GO

UPDATE sdv
SET sdv.code = 'Confirmation Sent',
	sdv.[description] = 'Confirmation Sent'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code IN ('Approved and Ready to Send', 'Confrmation Sent')
	AND sdt.[type_name] = 'Deal Confirm Status'
GO

UPDATE sdv
SET sdv.code = 'Accounts Receivable',
	sdv.[description] = 'Accounts Receivable'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Accountant (Receivables)'
	AND sdt.[type_name] = 'Contact Type'
GO

UPDATE sdv
SET sdv.code = 'Accounts Payable',
	sdv.[description] = 'Accounts Payable'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Accountant (Payables)'
	AND sdt.[type_name] = 'Contact Type'
GO

UPDATE sdv
SET sdv.code = 'Accounting',
	sdv.[description] = 'Accounting'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Confirm Email'
	AND sdt.[type_name] = 'Contact Type'
GO

UPDATE sdv
SET sdv.code = 'Contracts',
	sdv.[description] = 'Contracts'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Distribution'
	AND sdt.[type_name] = 'Contact Type'
GO

UPDATE sdv
SET sdv.code = 'Do Not Trade',
	sdv.[description] = 'Do Not Trade'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'No Trade'
	AND sdt.[type_name] = 'Account Status'
GO

UPDATE sdv
SET sdv.code = 'Counterparty Guaranty',
	sdv.[description] = 'Counterparty Guaranty'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Guarantee of Payment for CP'
	AND sdt.[type_name] = 'Enhance Type'
GO

UPDATE sdv
SET sdv.code = 'Collaterals',
	sdv.[description] = 'Collaterals'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'Collateral'
	AND sdt.[type_name] = 'Enhance Type'
GO

UPDATE source_major_location
SET location_name = 'Supply',
	location_description = 'Supply'
WHERE location_name IN ('M2', 'Supply')
GO

UPDATE source_major_location
SET location_name = 'Demand',
	location_description = 'Demand'
WHERE location_name IN ('MQ', 'Demand')
GO

UPDATE sdv
SET sdv.code = 'Demand',
	sdv.[description] = 'Demand'
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdv.[type_id] = sdt.[type_id]
WHERE sdv.code = 'M2'
	AND sdt.[type_name] = 'Location Group'
GO

UPDATE sdt
SET sdt.[type_name] = 'D&B',
	sdt.[description] = 'D&B'
FROM static_data_type sdt
WHERE sdt.[type_name] = 'Debt rating4'
GO


DELETE sdv
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdt.type_id = sdv.type_id
WHERE sdv.code IN ('Initial', 'Manager Approved', 'Trader Approved')
	AND sdt.type_name = 'Deal Confirm Status' 
GO
 

DELETE sdv
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdt.type_id = sdv.type_id
WHERE sdv.code = 'Director Approved'
	AND sdt.type_name = 'Counterparty Status' 
GO

DELETE sdv
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdt.type_id = sdv.type_id
WHERE sdv.code = 'Analyst Approved'
	AND sdt.type_name = 'Deal Confirm Status' 
GO

DELETE sdv
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdt.type_id = sdv.type_id
WHERE sdv.code = 'Source'
	AND sdt.type_name = 'Location Group' 
GO

DELETE c
FROM source_major_location a
INNER JOIN source_minor_location b
	ON a.source_major_location_id = b.source_major_location_id
INNER JOIN delivery_path c
	ON b.source_minor_location_id = c.to_location
WHERE a.location_name IN ('Sink', 'Source')

DELETE b
FROM source_major_location a
INNER JOIN source_minor_location b
	ON a.source_major_location_id = b.source_major_location_id 
WHERE a.location_name IN ('Sink', 'Source')

DELETE 
FROM source_major_location
WHERE location_name = 'Sink'
GO

DELETE
FROM source_major_location
WHERE location_name = 'Source'
GO
 
UPDATE source_deal_header 
SET deal_status = 5604
WHERE deal_status in (5612,5632,5634)
GO

DELETE sdv
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdt.type_id = sdv.type_id
WHERE sdv.code IN ('Sample Approved', 'Initial Risk Review', 'Matured')
	AND sdt.type_name = 'Deal Status' 
GO
 
UPDATE counterparty_credit_info 
SET account_status = 10082
WHERE account_status = 10084
GO

DELETE sdv
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdt.type_id = sdv.type_id
WHERE sdv.code = 'New'
	AND sdt.type_name = 'Account Status' 
GO

UPDATE counterparty_credit_info 
SET Debt_rating = 307574
WHERE Debt_rating IN 
(SELECT value_id 
 FROM static_data_value 
 WHERE code IN  ('AAA+', 'BB+', 'AA+', 'AAA-', 'A+', 'AA-', 'BBB-', 'B-', 'A-', 'BBB+', 'BB-', 'B+', 'CCC+', 'CCC-')
	AND type_id = 10098
)
GO

DELETE 
FROM default_recovery_rate
WHERE Debt_rating IN 
(SELECT value_id 
 FROM static_data_value 
 WHERE code IN  ('AAA+', 'BB+', 'AA+', 'AAA-', 'A+', 'AA-', 'BBB-', 'B-', 'A-', 'BBB+', 'BB-', 'B+', 'CCC+', 'CCC-')
	AND type_id = 10098
)
GO

DELETE sdv 
FROM static_data_value sdv
INNER JOIN static_data_type sdt
	ON sdt.type_id = sdv.type_id
WHERE sdv.code IN ('AAA+', 'BB+', 'AA+', 'AAA-', 'A+', 'AA-', 'BBB-', 'B-', 'A-', 'BBB+', 'BB-', 'B+', 'CCC+', 'CCC-')
	AND sdt.type_name IN ('Primary debt rating', 'S&P', 'Debt Rating')
GO
 
UPDATE sdt
SET sdt.[type_name] = 'S&P',
	sdt.[description] = 'S&P'
FROM static_data_type sdt
WHERE sdt.type_name IN ('Primary debt rating', 'S&P', 'Debt Rating')
GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 17201)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (17201, 17200, 'Dispute', 'Dispute', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 17201 - Dispute.'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
    PRINT 'Static data value 17201 - Dispute already EXISTS.'
END
GO

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -32206)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32206, 32200, 'Risks', 'Risks', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -32206 - Risks.'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
    PRINT 'Static data value -32206 - Risks already EXISTS.'
END
GO

DELETE FROM static_data_value WHERE value_id = 309154

IF NOT EXISTS (SELECT 1 FROM static_data_value WHERE code = 'NG BR D24' AND [type_id] = 31800)
BEGIN
	INSERT INTO static_data_value ([type_id],code, [description])
	VALUES (31800, 'NG BR D24', 'NG BR D24')
END

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 309154)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (309154, 10020, 'Storage', 'Storage', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 309154 - Storage.'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
    PRINT 'Static data value 309154 - Storage already EXISTS.'
END
GO

DELETE FROM static_data_value WHERE code = 'Rating4' AND type_id = 10097

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10097)
BEGIN
    SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10097, 10097, 'Rating4', 'Rating4', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10097 - Rating4.'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
    PRINT 'Static data value -10097 - Rating4 already EXISTS.'
END
GO

DELETE FROM static_data_value WHERE type_id = 10098 AND code = 'D'

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10098)
BEGIN
    SET IDENTITY_INSERT static_data_value ON
	INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10098, 10098, 'D', 'D', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10098 - D.'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
    PRINT 'Static data value -10098 - D already EXISTS.'
END
GO

DELETE FROM static_data_value WHERE type_id = 10098 AND code = 'NR'

IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -10099)
BEGIN
	SET IDENTITY_INSERT static_data_value ON
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-10099, 10098, 'NR', 'NR', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -10099 - NR.'
	SET IDENTITY_INSERT static_data_value OFF
END
ELSE
BEGIN
    PRINT 'Static data value -10099 - NR already EXISTS.'
END
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'AAA'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11099)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11099, 11099, 'AAA', 'AAA', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11099 - AAA.'
END
ELSE
BEGIN
    PRINT 'Static data value -11099 - AAA already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'AA+'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11100)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11100, 11099, 'AA+', 'AA+', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11100 - AA+.'
END
ELSE
BEGIN
    PRINT 'Static data value -11100 - AA+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'AA'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11101)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11101, 11099, 'AA', 'AA', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11101 - AA.'
END
ELSE
BEGIN
    PRINT 'Static data value -11101 - AA already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'AA-'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11102)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11102, 11099, 'AA-', 'AA-', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11102 - AA-.'
END
ELSE
BEGIN
    PRINT 'Static data value -11102 - AA- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

UPDATE static_data_value
    SET code = 'AA-',
		[description] = 'AA-',
    [category_id] = ''
    WHERE [value_id] = -11102
PRINT 'Updated Static value -11102 - AA-.'
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'A-'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11103)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11103, 11099, 'A-', 'A-', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11103 - A-.'
END
ELSE
BEGIN
    PRINT 'Static data value -11103 - A- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'BBB+'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11104)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11104, 11099, 'BBB+', 'BBB+', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11104 - BBB+.'
END
ELSE
BEGIN
    PRINT 'Static data value -11104 - BBB+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'BBB'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11105)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11105, 11099, 'BBB', 'BBB', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11105 - BBB.'
END
ELSE
BEGIN
    PRINT 'Static data value -11105 - BBB already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'BBB-'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11106)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11106, 11099, 'BBB-', 'BBB-', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11106 - BBB-.'
END
ELSE
BEGIN
    PRINT 'Static data value -11106 - BBB- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'BB+'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11107)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11107, 11099, 'BB+', 'BB+', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11107 - BB+.'
END
ELSE
BEGIN
    PRINT 'Static data value -11107 - BB+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'BB'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11108)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11108, 11099, 'BB', 'BB', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11108 - BB.'
END
ELSE
BEGIN
    PRINT 'Static data value -11108 - BB already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'BB-'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11109)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11109, 11099, 'BB-', 'BB-', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11109 - BB-.'
END
ELSE
BEGIN
    PRINT 'Static data value -11109 - BB- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'B'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11110)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11110, 11099, 'B', 'B', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11110 - B.'
END
ELSE
BEGIN
    PRINT 'Static data value -11110 - B already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'B-'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11111)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11111, 11099, 'B-', 'B-', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11111 - B-.'
END
ELSE
BEGIN
    PRINT 'Static data value -11111 - B- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'CCC+'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11112)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11112, 11099, 'CCC+', 'CCC+', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11112 - CCC+.'
END
ELSE
BEGIN
    PRINT 'Static data value -11112 - CCC+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'CCC'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11113)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11113, 11099, 'CCC', 'CCC', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11113 - CCC.'
END
ELSE
BEGIN
    PRINT 'Static data value -11113 - CCC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'CCC-'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11114)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11114, 11099, 'CCC-', 'CCC-', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11114 - CCC-.'
END
ELSE
BEGIN
    PRINT 'Static data value -11114 - CCC- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'CC'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11115)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11115, 11099, 'CC', 'CC', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11115 - CC.'
END
ELSE
BEGIN
    PRINT 'Static data value -11115 - CC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'C'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11116)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11116, 11099, 'C', 'C', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11116 - C.'
END
ELSE
BEGIN
    PRINT 'Static data value -11116 - C already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11099 AND code = 'D'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11117)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11117, 11099, 'D', 'D', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11117 - D.'
END
ELSE
BEGIN
    PRINT 'Static data value -11117 - D already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'AAA'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11118)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11118, 11100, 'AAA', 'AAA', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11118 - AAA.'
END
ELSE
BEGIN
    PRINT 'Static data value -11118 - AAA already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'AA+'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11119)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11119, 11100, 'AA+', 'AA+', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11119 - AA+.'
END
ELSE
BEGIN
    PRINT 'Static data value -11119 - AA+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'AA'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11120)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11120, 11100, 'AA', 'AA', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11120 - AA.'
END
ELSE
BEGIN
    PRINT 'Static data value -11120 - AA already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'AA-'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11121)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11121, 11100, 'AA-', 'AA-', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11121 - AA-.'
END
ELSE
BEGIN
    PRINT 'Static data value -11121 - AA- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

UPDATE static_data_value
    SET code = 'AA-',
		[description] = 'AA-',
    [category_id] = ''
    WHERE [value_id] = -11121
PRINT 'Updated Static value -11121 - AA-.'
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'A-'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11122)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11122, 11100, 'A-', 'A-', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11122 - A-.'
END
ELSE
BEGIN
    PRINT 'Static data value -11122 - A- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

UPDATE static_data_value
    SET code = 'A-',
		[description] = 'A-',
    [category_id] = ''
    WHERE [value_id] = -11122
PRINT 'Updated Static value -11122 - A-.'
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'BBB+'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11123)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11123, 11100, 'BBB+', 'BBB+', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11123 - BBB+.'
END
ELSE
BEGIN
    PRINT 'Static data value -11123 - BBB+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'BBB'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11124)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11124, 11100, 'BBB', 'BBB', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11124 - BBB.'
END
ELSE
BEGIN
    PRINT 'Static data value -11124 - BBB already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'BBB-'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11125)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11125, 11100, 'BBB-', 'BBB-', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11125 - BBB-.'
END
ELSE
BEGIN
    PRINT 'Static data value -11125 - BBB- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

UPDATE static_data_value
    SET code = 'BBB-',
		[description] = 'BBB-',
    [category_id] = ''
    WHERE [value_id] = -11125
PRINT 'Updated Static value -11125 - BBB-.'
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'BB+'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11126)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11126, 11100, 'BB+', 'BB+', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11126 - BB+.'
END
ELSE
BEGIN
    PRINT 'Static data value -11126 - BB+ already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'BB'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11127)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11127, 11100, 'BB', 'BB', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11127 - BB.'
END
ELSE
BEGIN
    PRINT 'Static data value -11127 - BB already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'BB-'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11128)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11128, 11100, 'BB-', 'BB-', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11128 - BB-.'
END
ELSE
BEGIN
    PRINT 'Static data value -11128 - BB- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

UPDATE static_data_value
    SET code = 'BB-',
		[description] = 'BB-',
    [category_id] = ''
    WHERE [value_id] = -11128
PRINT 'Updated Static value -11128 - BB-.'
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'B'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11129)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11129, 11100, 'B', 'B', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11129 - B.'
END
ELSE
BEGIN
    PRINT 'Static data value -11129 - B already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'B-'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11130)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11130, 11100, 'B-', 'B-', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11130 - B-.'
END
ELSE
BEGIN
    PRINT 'Static data value -11130 - B- already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

UPDATE static_data_value
    SET code = 'B-',
		[description] = 'B-',
    [category_id] = ''
    WHERE [value_id] = -11130
PRINT 'Updated Static value -11130 - B-.'
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'CCC'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11131)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11131, 11100, 'CCC', 'CCC', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11131 - CCC.'
END
ELSE
BEGIN
    PRINT 'Static data value -11131 - CCC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'DDD'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11132)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11132, 11100, 'DDD', 'DDD', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11132 - DDD.'
END
ELSE
BEGIN
    PRINT 'Static data value -11132 - DDD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'DD'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11133)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11133, 11100, 'DD', 'DD', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11133 - DD.'
END
ELSE
BEGIN
    PRINT 'Static data value -11133 - DD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11100 AND code = 'D'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11134)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11134, 11100, 'D', 'D', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11134 - D.'
END
ELSE
BEGIN
    PRINT 'Static data value -11134 - D already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = '2A'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11135)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11135, 11101, ' 2A', ' 2A', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11135 -  2A.'
END
ELSE
BEGIN
    PRINT 'Static data value -11135 -  2A already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = '1A'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11136)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11136, 11101, ' 1A', ' 1A', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11136 -  1A.'
END
ELSE
BEGIN
    PRINT 'Static data value -11136 -  1A already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = 'BA'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11137)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11137, 11101, ' BA', ' BA', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11137 -  BA.'
END
ELSE
BEGIN
    PRINT 'Static data value -11137 -  BA already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = 'BB'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11138)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11138, 11101, ' BB', ' BB', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11138 -  BB.'
END
ELSE
BEGIN
    PRINT 'Static data value -11138 -  BB already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = 'CB'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11139)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11139, 11101, ' CB', ' CB', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11139 -  CB.'
END
ELSE
BEGIN
    PRINT 'Static data value -11139 -  CB already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = 'CC'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11140)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11140, 11101, ' CC', ' CC', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11140 -  CC.'
END
ELSE
BEGIN
    PRINT 'Static data value -11140 -  CC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = 'DC'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11141)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11141, 11101, ' DC', ' DC', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11141 -  DC.'
END
ELSE
BEGIN
    PRINT 'Static data value -11141 -  DC already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = 'DD'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11142)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11142, 11101, ' DD', ' DD', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11142 -  DD.'
END
ELSE
BEGIN
    PRINT 'Static data value -11142 -  DD already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = 'EE'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11143)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11143, 11101, ' EE', ' EE', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11143 -  EE.'
END
ELSE
BEGIN
    PRINT 'Static data value -11143 -  EE already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = 'EF'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11144)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11144, 11101, ' EF', ' EF', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11144 -  EF.'
END
ELSE
BEGIN
    PRINT 'Static data value -11144 -  EF already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = 'GG'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11145)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11145, 11101, ' GG', ' GG', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11145 -  GG.'
END
ELSE
BEGIN
    PRINT 'Static data value -11145 -  GG already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = 'HH'
DELETE FROM static_data_value WHERE type_id = 11101 AND code = ' HH'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11146)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11146, 11101, 'HH', 'HH', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11146 -  HH.'
END
ELSE
BEGIN
    PRINT 'Static data value -11146 -  HH already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = '1R'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11147)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11147, 11101, ' 1R', ' 1R', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11147 -  1R.'
END
ELSE
BEGIN
    PRINT 'Static data value -11147 -  1R already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 11101 AND code = '2R'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -11148)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-11148, 11101, ' 2R', ' 2R', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -11148 -  2R.'
END
ELSE
BEGIN
    PRINT 'Static data value -11148 -  2R already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 38800 AND code = 'BASE'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -38800)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-38800, 38800, 'BASE', 'BASE', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -38800 - BASE.'
END
ELSE
BEGIN
    PRINT 'Static data value -38800 - BASE already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 38800 AND code = 'SEP AGREEMENT'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -38801)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-38801, 38800, 'SEP AGREEMENT', 'SEP AGREEMENT', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -38801 - SEP AGREEMENT.'
END
ELSE
BEGIN
    PRINT 'Static data value -38801 - SEP AGREEMENT already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 38800 AND code = 'C.S. ANNEX'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -38802)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-38802, 38800, 'C.S. ANNEX', 'C.S. ANNEX', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -38802 - C.S. ANNEX.'
END
ELSE
BEGIN
    PRINT 'Static data value -38802 - C.S. ANNEX already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 38800 AND code = 'TARIFF'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -38803)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-38803, 38800, 'TARIFF', 'TARIFF', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -38803 - TARIFF.'
END
ELSE
BEGIN
    PRINT 'Static data value -38803 - TARIFF already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 32900 AND code = 'MAC CLAUSE'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -32900)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32900, 32900, 'MAC CLAUSE', 'MAC CLAUSE', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -32900 - MAC CLAUSE.'
END
ELSE
BEGIN
    PRINT 'Static data value -32900 - MAC CLAUSE already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

DELETE FROM static_data_value WHERE type_id = 38800 AND code = 'MAC CLAUSE'
DELETE FROM static_data_value WHERE type_id = 38800 AND code = 'MAC CLAUSE'
DELETE FROM static_data_value WHERE type_id = 38800 AND code = 'MAC CLAUSE'
DELETE FROM static_data_value WHERE type_id = 32900 AND code = 'NON-PAY'
DELETE FROM static_data_value WHERE type_id = 32900 AND code = 'PERF ASSURANCE'
DELETE FROM static_data_value WHERE type_id = 32900 AND code = 'RATING'
DELETE FROM static_data_value WHERE type_id = 32900 AND code = 'TNW'
DELETE FROM static_data_value WHERE type_id = 32800 AND code = 'MAC CLAUSE'
DELETE FROM static_data_value WHERE type_id = 32800 AND code = 'NON-PAY'
DELETE FROM static_data_value WHERE type_id = 32800 AND code = 'PERF ASSURANCE'
DELETE FROM static_data_value WHERE type_id = 32800 AND code = 'RATING'
DELETE FROM static_data_value WHERE type_id = 32800 AND code = 'TNW'

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -32901)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32901, 32900, 'NON-PAY', 'NON-PAY', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -32901 - NON-PAY.'
END
ELSE
BEGIN
    PRINT 'Static data value -32901 - NON-PAY already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -32902)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32902, 32900, 'PERF ASSURANCE', 'PERF ASSURANCE', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -32902 - PERF ASSURANCE.'
END
ELSE
BEGIN
    PRINT 'Static data value -32902 - PERF ASSURANCE already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -32903)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32903, 32900, 'RATING', 'RATING', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -32903 - RATING.'
END
ELSE
BEGIN
    PRINT 'Static data value -32903 - RATING already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -32904)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32904, 32900, 'TNW', 'TNW', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -32904 - TNW.'
END
ELSE
BEGIN
    PRINT 'Static data value -32904 - TNW already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -32800)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32800, 32800, 'MAC CLAUSE', 'MAC CLAUSE', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -32800 - MAC CLAUSE.'
END
ELSE
BEGIN
    PRINT 'Static data value -32800 - MAC CLAUSE already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -32801)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32801, 32800, 'NON-PAY', 'NON-PAY', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -32801 - NON-PAY.'
END
ELSE
BEGIN
    PRINT 'Static data value -32801 - NON-PAY already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -32802)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32802, 32800, 'PERF ASSURANCE', 'PERF ASSURANCE', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -32802 - PERF ASSURANCE.'
END
ELSE
BEGIN
    PRINT 'Static data value -32802 - PERF ASSURANCE already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -32803)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32803, 32800, 'RATING', 'RATING', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -32803 - RATING.'
END
ELSE
BEGIN
    PRINT 'Static data value -32803 - RATING already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -32804)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-32804, 32800, 'TNW', 'TNW', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -32804 - TNW.'
END
ELSE
BEGIN
    PRINT 'Static data value -32804 - TNW already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -39300)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-39300, 39300, '50,000', '50,000', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -39300 - 50,000.'
END
ELSE
BEGIN
    PRINT 'Static data value -39300 - 50,000 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -39301)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-39301, 39300, '250,000', '250,000', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -39301 - 250,000.'
END
ELSE
BEGIN
    PRINT 'Static data value -39301 - 250,000 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = -39302)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (-39302, 39300, '10,000,000', '10,000,000', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value -39302 - 10,000,000.'
END
ELSE
BEGIN
    PRINT 'Static data value -39302 - 10,000,000 already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

UPDATE sdt
SET sdt.[type_name] = 'Moodys',
	sdt.[description] = 'Moodys'
FROM static_data_type sdt
WHERE sdt.type_name IN ('Debt rating2', 'Moodys')
GO

UPDATE sdt
SET sdt.[type_name] = 'Fitch',
	sdt.[description] = 'Fitch'
FROM static_data_type sdt
WHERE sdt.type_name IN ('Debt rating3', 'Fitch')
GO

UPDATE static_data_value 
SET code = REPLACE(code, 'Guaranty', 'Guarantee')
WHERE code LIKE '%Guaranty%'
GO

UPDATE static_data_value 
SET [description] = REPLACE([description], 'Guaranty', 'Guarantee')
WHERE [description] LIKE '%Guaranty%'
GO

UPDATE static_data_value 
SET code = 'Ready for Invoice',
	[description] = 'Ready for Invoice'
WHERE code = 'Ready for invoice'
GO


SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25001)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25001, 25000, 'Closed', 'Closed', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25001 - Closed.'
END
ELSE
BEGIN
    PRINT 'Static data value 25001 - Closed already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 25000)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (25000, 25000, 'Ready for Schedule', 'Ready for Schedule', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 25000 - Ready for Schedule.'
END
ELSE
BEGIN
    PRINT 'Static data value 25000 - Ready for Schedule already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10104)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (10104, 10100, 'Parental Guarantee', 'Parental Guarantee', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10104 - Parental Guarantee.'
END
ELSE
BEGIN
    PRINT 'Static data value 10104 - Parental Guarantee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10103)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (10103, 10100, 'Letter of Credit', 'Letter of Credit', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10103 - Letter of Credit.'
END
ELSE
BEGIN
    PRINT 'Static data value 10103 - Letter of Credit already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

UPDATE counterparty_credit_enhancements 
SET enhance_type = NULL
WHERE enhance_type = -10101

DELETE 
FROM static_data_value 
WHERE value_id = -10101

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10102)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (10102, 10100, 'Cash', 'Cash', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10102 - Cash.'
END
ELSE
BEGIN
    PRINT 'Static data value 10102 - Cash already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

UPDATE counterparty_credit_enhancements 
SET enhance_type = 10102
WHERE enhance_type IS NULL

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10101)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (10101, 10100, 'Bond', 'Bond', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10101 - Bond.'
END
ELSE
BEGIN
    PRINT 'Static data value 10101 - Bond already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

SET IDENTITY_INSERT static_data_value ON
IF NOT EXISTS(SELECT 1 FROM static_data_value WHERE value_id = 10100)
BEGIN
    INSERT INTO static_data_value (value_id, [type_id], code, [description], category_id, create_user, create_ts)
    VALUES (10100, 10100, 'Bank Guarantee', 'Bank Guarantee', '', 'farrms_admin', GETDATE())
    PRINT 'Inserted static data value 10100 - Bank Guarantee.'
END
ELSE
BEGIN
    PRINT 'Static data value 10100 - Bank Guarantee already EXISTS.'
END
SET IDENTITY_INSERT static_data_value OFF
GO

UPDATE static_data_type
SET internal = 1
WHERE type_id = 10100
GO