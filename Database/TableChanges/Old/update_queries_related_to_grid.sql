update  adiha_grid_definition set load_sql = 'EXEC(''SELECT dbo.fnadateformat(production_month) [Production Month],gre_per[Third Party %],gre_volume[Third Party Volume],meter_id[Meter ID] FROM meter_id_allocation where meter_id = <ID>'')' where grid_id =47

INSERT INTO adiha_grid_columns_definition(grid_id, column_name, column_label, field_type, is_editable, is_required, column_order, is_hidden, column_width)
select 47, 'meter_id', 'Meter ID','ro','n','y', 1,'n',150

update adiha_grid_columns_definition set column_name = 'gre_per' from adiha_grid_columns_definition where grid_id = 47 and column_name = 'gre_pre'

update adiha_grid_definition set grid_type = 'g' where grid_id = 47
