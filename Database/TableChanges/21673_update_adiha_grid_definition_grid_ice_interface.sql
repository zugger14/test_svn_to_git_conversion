IF NOT EXISTS (SELECT * FROM adiha_grid_definition WHERE load_sql = 'EXEC spa_ixp_import_data_interface @flag = ''g''' AND grid_name = 'ice_interface')
BEGIN
UPDATE adiha_grid_definition SET load_sql = 'EXEC spa_ixp_import_data_interface @flag = ''g''' where grid_name = 'ice_interface'
END