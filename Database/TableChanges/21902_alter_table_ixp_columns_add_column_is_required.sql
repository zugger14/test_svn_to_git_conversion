IF COL_LENGTH('ixp_columns', 'is_required') IS NULL
BEGIN
    ALTER TABLE ixp_columns ADD is_required BIT DEFAULT 0
	PRINT 'Column is_required added in table ixp_columns. '
END
ELSE
BEGIN
	PRINT 'Column is_required already exists in table ixp_columns.'
END


GO

UPDATE ixp_columns SET is_required = 0 where is_required is null

