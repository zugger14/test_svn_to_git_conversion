
IF OBJECT_ID(N'[dbo].[ice_security_definition]', 'U') IS NULL 
  BEGIN 
      CREATE TABLE [dbo].[ice_security_definition] 
        ( 
           [id]                           [INT] IDENTITY(1, 1) PRIMARY KEY , 
           [product_id]                   [INT] NULL, 
           [exchange_name]                 [VARCHAR](100) NOT NULL, 
           [product_name]                  [VARCHAR](5000) NOT NULL, 
           [granularity]                  [INT] NOT NULL, 
           [tick_value]                    [NUMERIC](38, 20) NULL, 
           [uom]                          [INT] NULL, 
           [hub_name]                      [VARCHAR](5000) NOT NULL, 
           [currency]                     [INT] NULL, 
           [cfi_code]                      [VARCHAR](500) NULL, 
           [price_unit]                   [VARCHAR](555) NULL, 
           underlying_contract_multiplier [VARCHAR](555) NULL, 
           [lot_size]                      [VARCHAR](555) NULL, 
           [static_data_value]            [VARCHAR](555) NULL,
		   [create_user]                  [VARCHAR](50) NULL DEFAULT dbo.FNADBUser(), 
           [create_ts]                    [DATETIME] NULL DEFAULT GETDATE(), 
           [update_user]                  [VARCHAR](50) NULL, 
           [update_ts]                    [DATETIME] NULL 
        ) 
  END 
GO 


-- This column doesnt exist in act version
IF COL_LENGTH('ice_security_definition', 'hub_alias') IS NULL
BEGIN
	ALTER TABLE ice_security_definition ADD hub_alias VARCHAR(555)
END
-- SecuritiyDefnitionId(Code) Referes to static data
IF COL_LENGTH('ice_security_definition', 'security_definition_id') IS NULL
BEGIN
	ALTER TABLE ice_security_definition ADD security_definition_id INT NOT NULL
END

-- Rename Column
IF COL_LENGTH('ice_security_definition', 'hubalias') IS NOT NULL AND COL_LENGTH('ice_security_definition', 'hub_alias') IS NULL
BEGIN
	EXEC SP_RENAME 'ice_security_definition.[hubalias]' , 'hub_alias', 'COLUMN'
END

IF COL_LENGTH('ice_security_definition', 'exchangename') IS NOT NULL AND COL_LENGTH('ice_security_definition', 'exchange_name') IS NULL
BEGIN
	EXEC SP_RENAME 'ice_security_definition.[exchangename]' , 'exchange_name', 'COLUMN'
END

IF COL_LENGTH('ice_security_definition', 'productname') IS NOT NULL AND COL_LENGTH('ice_security_definition', 'product_name') IS NULL
BEGIN
	EXEC SP_RENAME 'ice_security_definition.[productname]' , 'product_name', 'COLUMN'
END

IF COL_LENGTH('ice_security_definition', 'tickvalue') IS NOT NULL AND COL_LENGTH('ice_security_definition', 'tick_value') IS NULL
BEGIN
	EXEC SP_RENAME 'ice_security_definition.[tickvalue]' , 'tick_value', 'COLUMN'
END

IF COL_LENGTH('ice_security_definition', 'hubname') IS NOT NULL AND COL_LENGTH('ice_security_definition', 'hub_name') IS NULL
BEGIN
	EXEC SP_RENAME 'ice_security_definition.[hubname]' , 'hub_name', 'COLUMN'
END

IF COL_LENGTH('ice_security_definition', 'cficode') IS NOT NULL AND COL_LENGTH('ice_security_definition', 'cfi_code') IS NULL
BEGIN
	EXEC SP_RENAME 'ice_security_definition.[cficode]' , 'cfi_code', 'COLUMN'
END

IF COL_LENGTH('ice_security_definition', 'underlyingcontractmultiplier') IS NOT NULL AND COL_LENGTH('ice_security_definition', 'underlying_contract_multiplier') IS NULL
BEGIN
	EXEC SP_RENAME 'ice_security_definition.[underlyingcontractmultiplier]' , 'underlying_contract_multiplier', 'COLUMN'
END

IF COL_LENGTH('ice_security_definition', 'lotsize') IS NOT NULL AND COL_LENGTH('ice_security_definition', 'lot_size') IS NULL
BEGIN
	EXEC SP_RENAME 'ice_security_definition.[lotsize]' , 'lot_size', 'COLUMN'
END