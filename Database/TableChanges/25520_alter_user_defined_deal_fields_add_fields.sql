

-- @1 Column Settlement Date
IF COL_LENGTH('user_defined_deal_fields','settlement_date') IS NULL
BEGIN
	ALTER TABLE dbo.user_defined_deal_fields ADD settlement_date DATETIME
END
IF COL_LENGTH('user_defined_deal_fields_audit', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_audit ADD settlement_date DATETIME
END
GO
IF COL_LENGTH('delete_user_defined_deal_fields', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ADD settlement_date DATETIME
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields ADD settlement_date DATETIME
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ADD settlement_date DATETIME
END
GO
IF COL_LENGTH('delete_user_defined_deal_detail_fields', 'settlement_date') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_detail_fields ADD settlement_date DATETIME
END
GO

-- @2 Column Settlement Calendar
IF COL_LENGTH('user_defined_deal_fields','settlement_calendar') IS NULL
BEGIN
	ALTER TABLE dbo.user_defined_deal_fields ADD settlement_calendar INT
END
IF COL_LENGTH('user_defined_deal_fields_audit', 'settlement_calendar') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_audit ADD settlement_calendar INT
END
GO
IF COL_LENGTH('delete_user_defined_deal_fields', 'settlement_calendar') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ADD settlement_calendar INT
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields', 'settlement_calendar') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields ADD settlement_calendar INT
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'settlement_calendar') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ADD settlement_calendar INT
END
GO
IF COL_LENGTH('delete_user_defined_deal_detail_fields', 'settlement_calendar') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_detail_fields ADD settlement_calendar INT
END
GO

-- @3 Column Settlement Days
IF COL_LENGTH('user_defined_deal_fields','settlement_days') IS NULL
BEGIN
	ALTER TABLE dbo.user_defined_deal_fields ADD settlement_days INT
END
IF COL_LENGTH('user_defined_deal_fields_audit', 'settlement_days') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_audit ADD settlement_days INT
END
GO
IF COL_LENGTH('delete_user_defined_deal_fields', 'settlement_days') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ADD settlement_days INT
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields', 'settlement_days') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields ADD settlement_days INT
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'settlement_days') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ADD settlement_days INT
END
GO
IF COL_LENGTH('delete_user_defined_deal_detail_fields', 'settlement_days') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_detail_fields ADD settlement_days INT
END
GO

-- @4 Column Payment Date
IF COL_LENGTH('user_defined_deal_fields','payment_date') IS NULL
BEGIN
	ALTER TABLE dbo.user_defined_deal_fields ADD payment_date DATETIME
END
IF COL_LENGTH('user_defined_deal_fields_audit', 'payment_date') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_audit ADD payment_date DATETIME
END
GO
IF COL_LENGTH('delete_user_defined_deal_fields', 'payment_date') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ADD payment_date DATETIME
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields', 'payment_date') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields ADD payment_date DATETIME
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'payment_date') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ADD payment_date DATETIME
END
GO
IF COL_LENGTH('delete_user_defined_deal_detail_fields', 'payment_date') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_detail_fields ADD payment_date DATETIME
END
GO

-- @5 Column Payment Calendar
IF COL_LENGTH('user_defined_deal_fields','payment_calendar') IS NULL
BEGIN
	ALTER TABLE dbo.user_defined_deal_fields ADD payment_calendar INT
END
IF COL_LENGTH('user_defined_deal_fields_audit', 'payment_calendar') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_audit ADD payment_calendar INT
END
GO
IF COL_LENGTH('delete_user_defined_deal_fields', 'payment_calendar') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ADD payment_calendar INT
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields', 'payment_calendar') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields ADD payment_calendar INT
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'payment_calendar') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ADD payment_calendar INT
END
GO
IF COL_LENGTH('delete_user_defined_deal_detail_fields', 'payment_calendar') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_detail_fields ADD payment_calendar INT
END
GO

-- @6 Column Payment Days
IF COL_LENGTH('user_defined_deal_fields','payment_days') IS NULL
BEGIN
	ALTER TABLE dbo.user_defined_deal_fields ADD payment_days INT
END
IF COL_LENGTH('user_defined_deal_fields_audit', 'payment_days') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_fields_audit ADD payment_days INT
END
GO
IF COL_LENGTH('delete_user_defined_deal_fields', 'payment_days') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_fields ADD payment_days INT
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields', 'payment_days') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields ADD payment_days INT
END
GO
IF COL_LENGTH('user_defined_deal_detail_fields_audit', 'payment_days') IS NULL
BEGIN
    ALTER TABLE user_defined_deal_detail_fields_audit ADD payment_days INT
END
GO
IF COL_LENGTH('delete_user_defined_deal_detail_fields', 'payment_days') IS NULL
BEGIN
    ALTER TABLE delete_user_defined_deal_detail_fields ADD payment_days INT
END
GO