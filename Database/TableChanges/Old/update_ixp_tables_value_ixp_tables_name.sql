UPDATE ixp_tables
SET ixp_tables_name = ixp_tables_name + '_template'
WHERE CHARINDEX('_template', ixp_tables_name) = 0

UPDATE ixp_tables
SET ixp_tables_name = ixp_tables_name + '_template'
WHERE ixp_tables_name IN ('ixp_user_defined_fields_template', 'ixp_maintain_field_template', 'ixp_source_deal_header_template', 'ixp_source_deal_detail_template')
