
DROP TABLE IF EXISTS #src
SELECT col INTO #src FROM(
VALUES  ('Volume')
	, ('Ask Value')
	, ('Bid Value')
	, ('Curve Value')
	, ('Actual Volume')
	, ('Schedule Volume')
	, ('Price')
	, ('Value')
	, ('Forecast Volume')
	, ('Certified Volume')
	, ('Volume Multiplier')
	, ('Fixed Price')
	, ('Addon')
	, ('Deal Volume')
	, ('Contractual Volume')
	, ('Fixed cost')
	, ('Volume Multiplier 2')
	)rs  (col)

UPDATE ic 
SET datatype = 'numeric(38,20)'
FROM ixp_rules ir
INNER JOIN ixp_import_data_source iids ON iids.rules_id = ir.ixp_rules_id
INNER JOIN ixp_import_data_mapping iidm ON iidm.ixp_rules_id = ir.ixp_rules_id
INNER JOIN ixp_tables it ON it.ixp_tables_id = iidm.dest_table_id
INNER JOIN ixp_columns ic ON ic.ixp_columns_id = iidm.dest_column
INNER JOIN #src s ON s.col = IIF(CHARINDEX('[', iidm.source_column_name) > 0,SUBSTRING(iidm.source_column_name, CHARINDEX('[', iidm.source_column_name) + 1, ABS(CHARINDEX(']', iidm.source_column_name) - CHARINDEX('[', iidm.source_column_name) - 1 )),iidm.source_column_name)
--where ir.ixp_rules_name IN ('deals')	
	

