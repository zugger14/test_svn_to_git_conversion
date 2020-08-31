
IF  NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_template' AND COLUMN_NAME = 'deal_status')
ALTER TABLE source_deal_header_template add deal_status INT

IF  NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_template' AND COLUMN_NAME = 'deal_category_value_id')
ALTER TABLE source_deal_header_template add deal_category_value_id INT

IF  NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_template' AND COLUMN_NAME = 'legal_entity')
ALTER TABLE source_deal_header_template add legal_entity INT

IF  NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_template' AND COLUMN_NAME = 'commodity_id')
ALTER TABLE source_deal_header_template add commodity_id INT

IF  NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_template' AND COLUMN_NAME = 'internal_portfolio_id')
ALTER TABLE source_deal_header_template add internal_portfolio_id INT

IF  NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_template' AND COLUMN_NAME = 'product_id')
ALTER TABLE source_deal_header_template add product_id INT

IF  NOT EXISTS(SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'source_deal_header_template' AND COLUMN_NAME = 'internal_desk_id')
ALTER TABLE source_deal_header_template add internal_desk_id INT
