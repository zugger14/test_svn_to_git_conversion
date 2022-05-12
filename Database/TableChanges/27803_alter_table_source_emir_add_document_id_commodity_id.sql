IF COL_LENGTH('source_emir', 'document_id') IS NULL
BEGIN
    ALTER TABLE source_emir ADD document_id INT
END
GO

IF COL_LENGTH('source_emir', 'commodity_id') IS NULL
BEGIN
    ALTER TABLE source_emir ADD commodity_id NVARCHAR(50)
END
GO

IF COL_LENGTH('source_emir', 'broker_id') IS NULL
BEGIN
    ALTER TABLE source_emir ADD broker_id NVARCHAR(250)
END
GO

IF COL_LENGTH('source_emir', 'broker_name') IS NULL
BEGIN
    ALTER TABLE source_emir ADD broker_name NVARCHAR(2000)
END
GO