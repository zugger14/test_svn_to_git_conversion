IF COL_LENGTH('template_mapping', 'deal_type_id') IS NOT NULL
BEGIN
ALTER TABLE template_mapping ALTER COLUMN deal_type_id INT NULL
END
GO
