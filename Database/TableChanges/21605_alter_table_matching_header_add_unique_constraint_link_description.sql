UPDATE matching_header
SET link_description = CAST(link_id AS VARCHAR(5))
WHERE link_description IS NULL

IF NOT EXISTS (
	SELECT 1
	FROM sys.indexes i
	INNER JOIN sys.index_columns ic ON i.index_id = ic.index_id
		AND i.object_id = ic.object_id
	WHERE i.is_unique_constraint = 1 AND i.name = 'UC_matching_header_link_description'
)
BEGIN
	ALTER TABLE matching_header ALTER COLUMN link_description VARCHAR(1000) NOT NULL
	ALTER TABLE matching_header ADD CONSTRAINT UC_matching_header_link_description UNIQUE(link_description);	
END
GO