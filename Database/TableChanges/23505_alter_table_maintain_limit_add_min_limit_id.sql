IF COL_LENGTH('maintain_limit', 'min_limit_id') IS NULL
BEGIN
    ALTER TABLE
	 /**
        Columns
        min_limit_id : 
    */
	maintain_limit ADD min_limit_id INT
	PRINT 'Column min_limit_id added in table maintain_limit. '
END
ELSE
BEGIN
	PRINT 'Column min_limit_id already exists in table maintain_limit.'
END

GO


