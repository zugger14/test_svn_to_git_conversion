-- Origin
IF COL_LENGTH('source_deal_detail', 'origin') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD origin INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'origin') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD origin INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'origin') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD origin INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'origin') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD origin INT
END
GO


-- form
IF COL_LENGTH('source_deal_detail', 'form') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD form INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'form') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD form INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'form') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD form INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'form') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD form INT
END
GO

-- Organic
IF COL_LENGTH('source_deal_detail', 'organic') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD organic CHAR(1)
END
GO

IF COL_LENGTH('source_deal_detail_template', 'organic') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD organic CHAR(1)
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'organic') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD organic CHAR(1)
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'organic') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD organic CHAR(1)
END
GO

-- Attr 1
IF COL_LENGTH('source_deal_detail', 'attribute1') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD attribute1 INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'attribute1') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD attribute1 INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'attribute1') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD attribute1 INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'attribute1') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD attribute1 INT
END
GO

-- Attr2
IF COL_LENGTH('source_deal_detail', 'attribute2') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD attribute2 INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'attribute2') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD attribute2 INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'attribute2') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD attribute2 INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'attribute2') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD attribute2 INT
END
GO

-- Attr3
IF COL_LENGTH('source_deal_detail', 'attribute3') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD attribute3 INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'attribute3') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD attribute3 INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'attribute3') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD attribute3 INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'attribute3') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD attribute3 INT
END
GO

-- Attr4
IF COL_LENGTH('source_deal_detail', 'attribute4') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD attribute4 INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'attribute4') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD attribute4 INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'attribute4') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD attribute4 INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'attribute4') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD attribute4 INT
END
GO

-- Attr5
IF COL_LENGTH('source_deal_detail', 'attribute5') IS NULL
BEGIN
    ALTER TABLE source_deal_detail ADD attribute5 INT
END
GO

IF COL_LENGTH('source_deal_detail_template', 'attribute5') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_template ADD attribute5 INT
END
GO

IF COL_LENGTH('delete_source_deal_detail', 'attribute5') IS NULL
BEGIN
    ALTER TABLE delete_source_deal_detail ADD attribute5 INT
END
GO

IF COL_LENGTH('source_deal_detail_audit', 'attribute5') IS NULL
BEGIN
    ALTER TABLE source_deal_detail_audit ADD attribute5 INT
END
GO