IF COL_LENGTH('maintain_limit', 'limit_percentage') IS NULL
BEGIN
    ALTER TABLE
	/**
        Columns
        limit_percentage : 
    */
	maintain_limit ADD limit_percentage float
	PRINT 'Column limit_percentage added in table maintain_limit. '
END
ELSE
BEGIN
	PRINT 'Column limit_percentage already exists in table maintain_limit.'
END
GO