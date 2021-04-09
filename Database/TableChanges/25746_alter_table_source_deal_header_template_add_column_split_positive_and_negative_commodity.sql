IF OBJECT_ID(N'source_deal_header_template', N'U') IS NOT NULL 
		AND COL_LENGTH('source_deal_header_template', 'split_positive_and_negative_commodity') IS NULL
BEGIN
	ALTER TABLE
	/**
		Columns
		split_positive_and_negative_commodity : Split Positive and Negative Commodity 
	*/
		source_deal_header_template ADD split_positive_and_negative_commodity NCHAR(2) NULL
END
GO