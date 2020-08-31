--ALTER TABLE state_rec_requirement_data
IF EXISTS(SELECT 1 FROM sys.[columns] AS c WHERE c.name = 'capacity_conv_factor' AND c.[object_id] = OBJECT_ID(N'state_rec_requirement_data'))
	ALTER TABLE state_rec_requirement_data DROP COLUMN capacity_conv_factor	
IF EXISTS(SELECT 1 FROM sys.[columns] AS c WHERE c.name = 'capacity_conv_factor_source' AND c.[object_id] = OBJECT_ID(N'state_rec_requirement_data'))
	ALTER TABLE state_rec_requirement_data DROP COLUMN capacity_conv_factor_source
IF EXISTS(SELECT 1 FROM sys.[columns] AS c WHERE c.name = 'statewide_requirement' AND c.[object_id] = OBJECT_ID(N'state_rec_requirement_data'))
	ALTER TABLE state_rec_requirement_data DROP COLUMN statewide_requirement
IF EXISTS(SELECT 1 FROM sys.[columns] AS c WHERE c.name = 'statewide_requirement_source' AND c.[object_id] = OBJECT_ID(N'state_rec_requirement_data'))
	ALTER TABLE state_rec_requirement_data DROP COLUMN statewide_requirement_source
IF EXISTS(SELECT 1 FROM sys.[columns] AS c WHERE c.name = 'statewide_usable_offsets' AND c.[object_id] = OBJECT_ID(N'state_rec_requirement_data'))
	ALTER TABLE state_rec_requirement_data DROP COLUMN statewide_usable_offsets
IF EXISTS(SELECT 1 FROM sys.[columns] AS c WHERE c.name = 'statewide_usable_offsets_source' AND c.[object_id] = OBJECT_ID(N'state_rec_requirement_data'))
	ALTER TABLE state_rec_requirement_data DROP COLUMN statewide_usable_offsets_source
IF EXISTS(SELECT 1 FROM sys.[columns] AS c WHERE c.name = 'total_retail_sales' AND c.[object_id] = OBJECT_ID(N'state_rec_requirement_data'))
	ALTER TABLE state_rec_requirement_data DROP COLUMN total_retail_sales
IF EXISTS(SELECT 1 FROM sys.[columns] AS c WHERE c.name = 'total_retail_sales_source' AND c.[object_id] = OBJECT_ID(N'state_rec_requirement_data'))
	ALTER TABLE state_rec_requirement_data DROP COLUMN total_retail_sales_source
IF EXISTS(SELECT 1 FROM sys.[columns] AS c WHERE c.name = 'our_sales' AND c.[object_id] = OBJECT_ID(N'state_rec_requirement_data'))
	ALTER TABLE state_rec_requirement_data DROP COLUMN our_sales
IF EXISTS(SELECT 1 FROM sys.[columns] AS c WHERE c.name = 'our_sales_source' AND c.[object_id] = OBJECT_ID(N'state_rec_requirement_data'))
	ALTER TABLE state_rec_requirement_data DROP COLUMN our_sales_source
IF EXISTS(SELECT 1 FROM sys.[columns] AS c WHERE c.name = 'adjustment' AND c.[object_id] = OBJECT_ID(N'state_rec_requirement_data'))
	ALTER TABLE state_rec_requirement_data DROP COLUMN adjustment
IF EXISTS(SELECT 1 FROM sys.[columns] AS c WHERE c.name = 'adjustment_source' AND c.[object_id] = OBJECT_ID(N'state_rec_requirement_data'))
	ALTER TABLE state_rec_requirement_data DROP COLUMN adjustment_source
IF EXISTS(SELECT 1 FROM sys.[columns] AS c WHERE c.name = 'adjustment_years' AND c.[object_id] = OBJECT_ID(N'state_rec_requirement_data'))
	ALTER TABLE state_rec_requirement_data DROP COLUMN adjustment_years
