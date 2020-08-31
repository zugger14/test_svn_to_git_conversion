IF COL_LENGTH('maintain_limit', 'effective_date') IS NULL
BEGIN
    ALTER TABLE
	 /**
        Columns
        effective_date : effective date
    */
	maintain_limit ADD effective_date DATETIME
	PRINT 'Column effective_date added in table maintain_limit. '
END
ELSE
BEGIN
	PRINT 'Column effective_date already exists in table maintain_limit.'
END

GO

IF COL_LENGTH('maintain_limit', 'deal_subtype') IS NULL
BEGIN
    ALTER TABLE
	 /**
        Columns
        deal_subtype : 
    */
	maintain_limit ADD deal_subtype INT
	PRINT 'Column deal_subtype added in table maintain_limit. '
END
ELSE
BEGIN
	PRINT 'Column deal_subtype already exists in table maintain_limit.'
END

GO

IF COL_LENGTH('maintain_limit', 'trade_date') IS NULL
BEGIN
    ALTER TABLE
	 /**
        Columns
        trade_date : 
    */
	maintain_limit ADD trade_date INT
	PRINT 'Column trade_date added in table maintain_limit. '
END
ELSE
BEGIN
	PRINT 'Column trade_date already exists in table maintain_limit.'
END

GO



    
	