IF COL_LENGTH('pratos_stage_deal_detail', 'price_uom') IS NULL
	ALTER TABLE pratos_stage_deal_detail ADD price_uom VARCHAR(50)
GO