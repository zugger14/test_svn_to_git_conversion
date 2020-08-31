
IF COL_LENGTH('shipper_code_mapping', 'counterparty_id') IS NOT NULL
BEGIN
ALTER TABLE shipper_code_mapping ALTER COLUMN counterparty_id INT NOT NULL
END
GO

IF COL_LENGTH('shipper_code_mapping', 'location_id') IS NOT NULL
BEGIN
ALTER TABLE shipper_code_mapping ALTER COLUMN location_id INT NOT NULL
END
GO

IF COL_LENGTH('shipper_code_mapping', 'is_default') IS NOT NULL
BEGIN
ALTER TABLE shipper_code_mapping ALTER COLUMN is_default NCHAR NOT NULL
END
GO

--IF COL_LENGTH('shipper_code_mapping', 'create_user') IS NOT NULL
--BEGIN
--ALTER TABLE shipper_code_mapping ALTER COLUMN create_user NVARCHAR NOT NULL
--END
--GO

IF COL_LENGTH('shipper_code_mapping', 'shipper_code') IS NOT NULL
BEGIN
ALTER TABLE shipper_code_mapping ALTER COLUMN shipper_code NVARCHAR(200) NOT NULL
END
GO

IF COL_LENGTH('shipper_code_mapping', 'create_ts') IS NOT NULL
BEGIN
ALTER TABLE shipper_code_mapping ALTER COLUMN create_ts DATETIME NOT NULL
END
GO

IF NOT EXISTS (SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'shipper_code_mapping' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_shipper_code_mapping_counterparty_id')
BEGIN   
	ALTER TABLE [dbo].[shipper_code_mapping]  WITH CHECK 
	ADD  CONSTRAINT [FK_shipper_code_mapping_counterparty_id] 
	FOREIGN KEY([counterparty_id])
	REFERENCES [dbo].[source_counterparty] ([source_counterparty_id]) 

	ALTER TABLE [dbo].[shipper_code_mapping] 
	CHECK CONSTRAINT [FK_shipper_code_mapping_counterparty_id]
END
GO

IF NOT EXISTS (SELECT 1 
			FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
			WHERE CONSTRAINT_TYPE = 'Foreign KEY' 
			AND TABLE_NAME = 'shipper_code_mapping' 
			AND TABLE_SCHEMA ='dbo'
			AND CONSTRAINT_NAME = 'FK_shipper_code_mapping_location_id')
BEGIN   
	ALTER TABLE [dbo].[shipper_code_mapping]  WITH CHECK 
	ADD  CONSTRAINT [FK_shipper_code_mapping_location_id] 
	FOREIGN KEY([location_id])
	REFERENCES [dbo].[source_minor_location] ([source_minor_location_id]) 

	ALTER TABLE [dbo].[shipper_code_mapping] 
	CHECK CONSTRAINT [FK_shipper_code_mapping_location_id]
END







