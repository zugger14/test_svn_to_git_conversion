UPDATE source_uom
SET uom_name = uom_id
WHERE uom_name IS NULL

UPDATE source_uom
SET uom_desc = uom_id
WHERE uom_desc IS NULL


IF EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_source_uom_1' AND object_id = OBJECT_ID('source_uom'))
BEGIN
	DROP INDEX IX_source_uom_1 ON source_uom
END

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_uom' AND COLUMN_NAME = 'uom_name')
BEGIN
	ALTER TABLE source_uom ALTER COLUMN uom_name VARCHAR(100) NOT NULL	
END

IF NOT EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IX_source_uom_1' AND object_id = OBJECT_ID('source_uom'))
BEGIN
	CREATE NONCLUSTERED INDEX [IX_source_uom_1] ON [dbo].[source_uom] ([uom_name])
END