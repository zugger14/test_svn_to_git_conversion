-- trader_id

IF EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'IX_source_traders')
BEGIN
	ALTER TABLE source_traders
	DROP CONSTRAINT IX_source_traders
END

--EXEC sp_fulltext_column      
--@tabname =  'source_traders' , 
--@colname =  'trader_id' , 
--@action =  'drop' 
--GO

DROP INDEX IX_source_traders_1 ON source_traders

IF COL_LENGTH('source_traders', 'trader_id') IS NOT NULL
BEGIN
    ALTER TABLE source_traders ALTER COLUMN trader_id nvarchar(400)
END
GO

--EXEC sp_fulltext_column       
--@tabname =  'source_traders' , 
--@colname =  'trader_id' , 
--@action =  'add' 
--GO
CREATE INDEX IX_source_traders_1
ON source_traders (trader_id)

IF NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'IX_source_traders')
BEGIN
	ALTER TABLE source_traders
	ADD CONSTRAINT IX_source_traders UNIQUE (source_system_id, trader_id)
END


-- trader_desc
IF COL_LENGTH('source_traders', 'trader_desc') IS NOT NULL
BEGIN
    ALTER TABLE source_traders ALTER COLUMN trader_desc nvarchar(400)
END
GO

-- trader_name
IF COL_LENGTH('source_traders', 'trader_name') IS NOT NULL
BEGIN
    ALTER TABLE source_traders ALTER COLUMN trader_name nvarchar(400)
END
GO

