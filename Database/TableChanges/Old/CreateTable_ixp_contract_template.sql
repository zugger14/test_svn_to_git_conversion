SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
/*
* Created date - 2013-03-21
* Template Table for contract.
* ixp_location_template
* Template table - will not store any data, is used for import feature 
*/
IF OBJECT_ID(N'[dbo].[ixp_contract_template]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[ixp_contract_template] (
    	contract_name VARCHAR(300),
		contract_desc VARCHAR(300),
		source_contract_id VARCHAR(300),
		volume_granularity VARCHAR(300),
		payment_days VARCHAR(300),
		settlement_days VARCHAR(300)
    )
END
ELSE
BEGIN
    PRINT 'Table ixp_contract_template EXISTS'
END
 
GO