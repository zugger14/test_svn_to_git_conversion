IF COL_LENGTH('source_deal_header_template', 'save_mtm_at_calculation_granularity') IS NULL
BEGIN
	ALTER TABLE  dbo.source_deal_header_template ADD save_mtm_at_calculation_granularity INT
END

GO



