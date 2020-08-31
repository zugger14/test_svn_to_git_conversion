IF NOT EXISTS (SELECT
    *
  FROM adiha_grid_definition agd
  WHERE agd.grid_name = 'contract_component')
BEGIN
  INSERT INTO adiha_grid_definition (grid_name, fk_table, fk_column, is_tree_grid, grouping_column, load_sql)
    VALUES ('contract_component', NULL, NULL, 'n', NULL, 'EXEC spa_contract_group_detail @flag=''s'',@contract_id=<ID>,@prod_type=''p''')

  DECLARE @grid_id varchar(100)
  SELECT
    @grid_id = grid_id
  FROM adiha_grid_definition agd
  WHERE agd.grid_name = 'contract_component'
  INSERT INTO adiha_grid_columns_definition (grid_id, column_name, column_label, field_type, sql_string, is_editable, is_required)
    SELECT
      @grid_id,
      'id',
      'ID',
      'ro',
      NULL,
      'n',
      'y'
    UNION ALL
    SELECT
      @grid_id,
      'contract_components',
      'Contract Components',
      'combo',
      '
EXEC spa_contract_group_detail_UI ''c''',
      'y',
      'y'

END

