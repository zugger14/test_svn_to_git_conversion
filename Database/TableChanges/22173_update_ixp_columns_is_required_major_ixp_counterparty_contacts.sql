DECLARE @ixp_table_id INT
SELECT @ixp_table_id = ixp_tables_id FROM ixp_tables WHERE ixp_tables_name = 'ixp_counterparty_contacts'

--update is_required and is_major
UPDATE ixp_columns
SET is_required = 0, is_major = 0
WHERE ixp_table_id = @ixp_table_id

UPDATE ixp_columns
SET is_required = 1
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name IN ('counterparty_id', 'name', 'contact_type', 'id')

UPDATE ixp_columns
SET is_major = 1
WHERE ixp_table_id = @ixp_table_id AND ixp_columns_name IN ('counterparty_id', 'id', 'is_primary')

--update sequence
UPDATE ixp_columns
SET seq = NULL
WHERE ixp_table_id = @ixp_table_id
  
SELECT 'counterparty_id' [name], 10 [seq]
INTO #temp 
UNION ALL SELECT 'title'		, 20
UNION ALL SELECT 'name'			, 30
UNION ALL SELECT 'contact_type'	, 40
UNION ALL SELECT 'id'			, 50
UNION ALL SELECT 'address1'		, 60
UNION ALL SELECT 'address2'		, 70
UNION ALL SELECT 'zip'			, 80
UNION ALL SELECT 'state'		, 90
UNION ALL SELECT 'region'		, 100
UNION ALL SELECT 'city'			, 110
UNION ALL SELECT 'country'		, 120
UNION ALL SELECT 'telephone'	, 130
UNION ALL SELECT 'cell_no'		, 140
UNION ALL SELECT 'fax'			, 150
UNION ALL SELECT 'email'		, 160
UNION ALL SELECT 'email_cc'		, 170
UNION ALL SELECT 'email_bcc'	, 180
UNION ALL SELECT 'comment'		, 190
UNION ALL SELECT 'is_primary'	, 200
UNION ALL SELECT 'is_active'	, 210

UPDATE ic SET seq = tmp.seq
FROM ixp_columns ic
INNER JOIN #temp tmp
	ON ic.ixp_columns_name = tmp.[name]
WHERE ixp_table_id = @ixp_table_id
