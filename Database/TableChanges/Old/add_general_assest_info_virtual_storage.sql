SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'[dbo].[general_assest_info_virtual_storage]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[general_assest_info_virtual_storage]
    (
    	[general_assest_id] INT IDENTITY(1, 1) NOT NULL,
    	[storage_location] INT REFERENCES source_minor_location(source_minor_location_id) NOT NULL,
    	[storage_type] INT REFERENCES static_data_value(value_id) NOT NULL,
    	[beg_storage_volume] FLOAT NULL,
    	[volumn_uom] INT REFERENCES source_uom(source_uom_id) NOT NULL,
    	[beg_storage_cost] FLOAT, 
    	[cost_currency] INT REFERENCES source_currency(source_currency_id) NOT NULL,
    	[agreement] INT REFERENCES contract_group(contract_id) NOT NULL,
    	[fees] INT REFERENCES static_data_value(value_id) NOT NULL,
    	[create_user] VARCHAR(50) NULL,
    	[create_ts] DATETIME NULL,
    	[update_user] VARCHAR(50) NULL,
    	[update_ts] DATETIME NULL
    )

	ALTER TABLE dbo.general_assest_info_virtual_storage ADD CONSTRAINT
		DF_table_name_create_ts DEFAULT GETDATE() FOR create_ts

	ALTER TABLE dbo.general_assest_info_virtual_storage ADD CONSTRAINT
		DF_table_name_create_user DEFAULT dbo.FNADBUser() FOR create_user
END
ELSE
BEGIN
    PRINT 'Table general_assest_info_virtual_storage EXISTS'
END
