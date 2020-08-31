UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'formula_id' AND agd.grid_name = 'formula_editor'

UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'priority' AND agd.grid_name = 'assign_priority_to_nomination_group'

UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'Volatility' AND agd.grid_name = 'monte_carlo_model_parameter'

UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'settlement_days' AND agd.grid_name = 'contract_group'

UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'mdq' AND agd.grid_name = 'contract_group_transportation'



UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'link_id' AND agd.grid_name = 'DedesignationHedge'

UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'link_id' AND agd.grid_name = 'ReclassifyHedgeDedesignation'

UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'role_id' AND agd.grid_name = 'maintain_role_grid'

--For all Link ID which is in real only mode.
UPDATE agcd
SET sorting_preference = 'int'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_label LIKE '%Link ID%' AND agcd.field_type = 'ro'

--For sorting_preference srt

UPDATE agcd
SET sorting_preference = 'str'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.sorting_preference = 'srt'

--For NULL Value.

UPDATE agcd
SET sorting_preference = 'str'
FROM adiha_grid_columns_definition agcd
INNER JOIN adiha_grid_definition agd ON agd.grid_id = agcd.grid_id
WHERE agcd.column_name = 'contract_id_show' AND agd.grid_name = 'contract_group_transportation'







