IF OBJECT_ID(N'source_deal_header', N'U') IS NOT NULL
	AND COL_LENGTH('source_deal_header', 'sub_contract') IS NULL
BEGIN
    ALTER TABLE
	/**
		Columns
		sub_contract: A field for capturing the Park and Loan deal subcontract information.
	*/
	source_deal_header ADD sub_contract VARCHAR(200)

	PRINT 'Added column sub_contract in table source_deal_header.'
END
ELSE
	PRINT 'Column sub_contract exists in table source_deal_header.'

GO