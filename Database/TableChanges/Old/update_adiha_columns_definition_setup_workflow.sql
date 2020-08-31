-- Updating adiha_grid_columns_definition for setup workflow menu

update adiha_grid_columns_definition set is_hidden = 'y' where column_id = (
select column_id from adiha_grid_columns_definition where grid_id = (
select grid_id from adiha_grid_definition where grid_name = 'grid_setup_workflow'
) AND column_name = 'id')

update adiha_grid_columns_definition set column_width = 330 where column_id = (
select column_id from adiha_grid_columns_definition where grid_id = (
select grid_id from adiha_grid_definition where grid_name = 'grid_setup_workflow'
) AND column_name = 'name')