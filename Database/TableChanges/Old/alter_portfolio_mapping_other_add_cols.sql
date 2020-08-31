
IF COL_LENGTH('portfolio_mapping_other', 'sub_book_id') IS NULL
ALTER TABLE portfolio_mapping_other
ADD sub_book_id INT
GO

IF COL_LENGTH('portfolio_mapping_other', 'template_id') IS NULL
ALTER TABLE portfolio_mapping_other
ADD template_id INT
GO

IF COL_LENGTH('portfolio_mapping_other', 'buy_total_volume') IS NULL
ALTER TABLE portfolio_mapping_other
ADD buy_total_volume NUMERIC(38, 20)
GO

IF COL_LENGTH('portfolio_mapping_other', 'sell_total_volume') IS NULL
ALTER TABLE portfolio_mapping_other
ADD sell_total_volume NUMERIC(38, 20)
GO

IF COL_LENGTH('portfolio_mapping_other', 'buy_volume_frequency') IS NULL
ALTER TABLE portfolio_mapping_other
ADD buy_volume_frequency CHAR(1)
GO

IF COL_LENGTH('portfolio_mapping_other', 'sell_volume_frequency') IS NULL
ALTER TABLE portfolio_mapping_other
ADD sell_volume_frequency CHAR(1)
GO

IF COL_LENGTH('portfolio_mapping_other', 'block_definition') IS NULL
ALTER TABLE portfolio_mapping_other
ADD block_definition INT
GO

IF COL_LENGTH('portfolio_mapping_other', 'buy_pricing_index') IS NULL
ALTER TABLE portfolio_mapping_other 
ADD buy_pricing_index INT
GO

IF COL_LENGTH('portfolio_mapping_other', 'sell_pricing_index') IS NULL
ALTER TABLE portfolio_mapping_other 
ADD sell_pricing_index INT
GO