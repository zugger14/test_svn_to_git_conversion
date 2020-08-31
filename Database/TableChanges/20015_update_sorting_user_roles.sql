UPDATE
adiha_grid_columns_definition
SET
sorting_preference = 'int'
WHERE
grid_id = (SELECT grid_id FROM adiha_grid_definition WHERE grid_name = 'role_users')
AND column_label = 'System ID'

UPDATE
adiha_grid_columns_definition
SET
sorting_preference = 'int'
WHERE
grid_id = (SELECT grid_id FROM adiha_grid_definition WHERE grid_name = 'application_functional_users')
AND
column_name = 'functional_users_id'

UPDATE
adiha_grid_columns_definition
SET
sorting_preference = 'str'
WHERE
grid_id = (SELECT grid_id FROM adiha_grid_definition WHERE grid_name = 'application_functional_users')
AND
column_name = 'role_name'

UPDATE
adiha_grid_columns_definition
SET
sorting_preference = 'int'
WHERE
grid_id = (SELECT grid_id FROM adiha_grid_definition WHERE grid_name = 'application_functional_users')
AND
column_name = 'function_id'

UPDATE
adiha_grid_columns_definition
SET
sorting_preference = 'str'
WHERE
grid_id = (SELECT grid_id FROM adiha_grid_definition WHERE grid_name = 'application_functional_users')
AND
column_name = 'entity_book'

UPDATE
adiha_grid_columns_definition
SET
sorting_preference = 'str'
WHERE
grid_id = (SELECT grid_id FROM adiha_grid_definition WHERE grid_name = 'application_functional_users')
AND
column_name = 'entity_strategy'


UPDATE
adiha_grid_columns_definition
SET
sorting_preference = 'str'
WHERE
grid_id = (SELECT grid_id FROM adiha_grid_definition WHERE grid_name = 'application_functional_users')
AND
column_name = 'entity_subsidary'

UPDATE
adiha_grid_columns_definition
SET
sorting_preference = 'str'
WHERE
grid_id = (SELECT grid_id FROM adiha_grid_definition WHERE grid_name = 'application_functional_users')
AND
column_name = 'parent_name'


