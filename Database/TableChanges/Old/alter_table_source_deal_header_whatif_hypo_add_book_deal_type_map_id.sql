/*
add column 'book_deal_type_map_id' [i.e. sub book id] on table source_deal_header_whatif_hypo
30 oct 2013
*/
IF COL_LENGTH(N'source_deal_header_whatif_hypo', 'book_deal_type_map_id') IS NULL
BEGIN
	ALTER TABLE source_deal_header_whatif_hypo ADD book_deal_type_map_id INT NOT NULL DEFAULT(8)
END
ELSE
	PRINT 'column already exists.'
	