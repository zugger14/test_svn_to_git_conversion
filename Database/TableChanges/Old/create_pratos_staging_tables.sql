IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_stage_deal_header]') AND type IN (N'U'))
CREATE TABLE pratos_stage_deal_header
(
	--temp_id INT IDENTITY(1,1),
	source_system_id INT,

	source_deal_id VARCHAR(50),
	source_deal_id_old VARCHAR(50),
	block_type VARCHAR(100),
	block_description VARCHAR(100),
	[description] VARCHAR(100),
	deal_date VARCHAR(20), 
	counterparty VARCHAR(50), 
	deal_type VARCHAR(50),
	deal_sub_type VARCHAR(50),
	option_flag CHAR(1), 
	source_book_id1 VARCHAR(50),
	source_book_id2 VARCHAR(50),
	source_book_id3 VARCHAR(50),
	source_book_id4 VARCHAR(50),
	description1 VARCHAR(100),
	description2 VARCHAR(50),
	description3 VARCHAR(50),
	deal_category_id VARCHAR(50), 
	trader_name VARCHAR(50),
	header_buy_sell_flag CHAR(1),
	framework VARCHAR(50),
	legal_entity VARCHAR(50),
	[template] VARCHAR(50), 
	deal_status VARCHAR(50),
	[profile] VARCHAR(50), 
	fixing VARCHAR(50), 
	confirm_status VARCHAR(50), 
	reference_deal VARCHAR(50)
)
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_stage_deal_detail]') AND type IN (N'U'))
CREATE TABLE pratos_stage_deal_detail 
( 
	--temp_id INT IDENTITY(1,1),
	source_system_id INT,
	source_deal_id VARCHAR(50),

	term_start VARCHAR(20),
	term_end VARCHAR(20), 
	leg VARCHAR(50),	--INT,
	expiration_date VARCHAR(20),
	fixed_float_leg CHAR(1),
	buy_sell CHAR(1),
	source_curve VARCHAR(50), 
	fixed_price NUMERIC(38,20),
	deal_volume NUMERIC(38,20),
	volume_frequency CHAR(1),
	volume_uom VARCHAR(50), 
	physical_financial_flag CHAR(1), 
	location VARCHAR(50),
	capacity NUMERIC(38,20), 
	fixed_cost NUMERIC(38,20), 
	fixed_cost_currency VARCHAR(50),
	formula_currency VARCHAR(50),
	adder_currency VARCHAR(50),
	price_currency VARCHAR(50),
	meter VARCHAR(50),
	syv FLOAT
)
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_stage_formula]') AND type IN (N'U'))
CREATE TABLE pratos_stage_formula 
(
	row_id INT,	-- IDENTITY(1,1),
	source_system_id INT,
	source_deal_id VARCHAR(50),	
	term_start VARCHAR(20),
	term_end VARCHAR(20), 
	leg VARCHAR(50),	--INT,
	
	formula VARCHAR(500),
	[value] FLOAT
)
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_stage_udf]') AND type IN (N'U'))
CREATE TABLE pratos_stage_udf
( 
	source_system_id INT,
	source_deal_id VARCHAR(50),
	field VARCHAR(500),
	[value] VARCHAR(8000)
)
GO 

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[pratos_stage_vol]') AND type IN (N'U'))
CREATE TABLE pratos_stage_vol 
(
	vol_id INT,	
	source_system_id INT, 
	source_deal_id VARCHAR(50), 
	term_start VARCHAR(20),
	term_end VARCHAR(20), 
	leg VARCHAR(50),	
	deal_volume NUMERIC(38,20)
)


-- Table Changes -------------------------------------------------------

IF COL_LENGTH('pratos_stage_deal_header', 'commodity') IS NULL
	ALTER TABLE pratos_stage_deal_header ADD commodity VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_header', 'percentage_fixed_bsld_onpeak') IS NULL
	ALTER TABLE pratos_stage_deal_header ADD percentage_fixed_bsld_onpeak NUMERIC(38,20)
GO

IF COL_LENGTH('pratos_stage_deal_header', 'percentage_fixed_offpeak') IS NULL
	ALTER TABLE pratos_stage_deal_header ADD percentage_fixed_offpeak NUMERIC(38,20)
GO

IF COL_LENGTH('pratos_stage_deal_header', 'broker_name') IS NOT NULL
	ALTER TABLE pratos_stage_deal_header DROP COLUMN broker_name 
GO

IF COL_LENGTH('pratos_stage_deal_header', 'parent_counterparty') IS NULL
	ALTER TABLE pratos_stage_deal_header ADD parent_counterparty VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_header', 'source_deal_id_old') IS NULL
	ALTER TABLE pratos_stage_deal_header ADD source_deal_id_old VARCHAR(50)
GO 

------------------------------------------------------------------------

IF COL_LENGTH('pratos_stage_deal_detail', 'postal_code') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD postal_code VARCHAR(8)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'province') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD province VARCHAR(100)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'physical_shipper') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD physical_shipper VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'sicc_code') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD sicc_code VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'profile_code') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD profile_code VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'nominatorsapcode') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD nominatorsapcode VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'forecast_needed') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD forecast_needed CHAR(1)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'forecasting_group') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD forecasting_group VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'external_profile') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD external_profile VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'calculation_method') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD calculation_method CHAR(1)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'country') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD country CHAR(2)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'region') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD region VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'grid') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD grid VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'location_group') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD location_group VARCHAR(20)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'category') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD category VARCHAR(50)
GO 

IF COL_LENGTH('pratos_stage_deal_detail', 'tou_tariff') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD tou_tariff VARCHAR(100)
GO

IF COL_LENGTH('pratos_stage_deal_detail', 'percentage_fixed_bsld_onpeak') IS NOT NULL
	ALTER TABLE pratos_stage_deal_detail DROP COLUMN percentage_fixed_bsld_onpeak 
GO

IF COL_LENGTH('pratos_stage_deal_detail', 'percentage_fixed_offpeak') IS NOT NULL
	ALTER TABLE pratos_stage_deal_detail DROP COLUMN percentage_fixed_offpeak 
GO

IF COL_LENGTH('pratos_stage_formula', 'tariff') IS NULL
	ALTER TABLE pratos_stage_formula ADD tariff VARCHAR(100)
GO

IF COL_LENGTH('pratos_stage_deal_detail', 'volume_multiplier') IS  NULL
	ALTER TABLE pratos_stage_deal_detail ADD volume_multiplier FLOAT
GO

IF COL_LENGTH('pratos_stage_deal_header', 'product') IS  NULL
	ALTER TABLE pratos_stage_deal_header ADD product VARCHAR(100)
GO
