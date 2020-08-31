IF COL_LENGTH('source_deal_header_template', 'actual_granularity') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD actual_granularity INT
END
GO

IF COL_LENGTH('source_deal_header_template', 'actualization_flag') IS NULL
BEGIN
    ALTER TABLE source_deal_header_template ADD actualization_flag CHAR(1)
	-- d - deal detail, s - shaped, m - meter
END
GO
