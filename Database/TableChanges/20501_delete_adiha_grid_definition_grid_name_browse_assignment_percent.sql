delete agcd from adiha_grid_columns_definition agcd 
	inner join adiha_grid_definition agd on agd.grid_id = agcd.grid_id
where agd.grid_name = 'browse_assignment_percent'

delete from adiha_grid_definition where grid_name = 'browse_assignment_percent' 

