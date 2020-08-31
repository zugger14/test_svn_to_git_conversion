--threshold_provided
update ic
	SET ic.column_datatype = 'VARCHAR(200)'
FROM ixp_columns ic
INNER JOIN ixp_tables it ON ic.ixp_table_id = it.ixp_tables_id
	AND ic.ixp_columns_name = 'threshold_provided'
	AND it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
	AND ic.column_datatype = 'float'

-- threshold_received
update ic
	SET ic.column_datatype = 'VARCHAR(200)'
FROM ixp_columns ic
INNER JOIN ixp_tables it ON ic.ixp_table_id = it.ixp_tables_id
	AND ic.ixp_columns_name = 'threshold_received'
	AND it.ixp_tables_name = 'ixp_counterparty_contract_address_template'
	AND ic.column_datatype = 'float'