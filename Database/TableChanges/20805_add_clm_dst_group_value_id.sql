--WITH(NOEXPAND) 

----update time_zones set dst_group_value_id=102200

--select * from time_zones

--select * from mv90_dst

--select * from hour_block_term

IF COL_LENGTH('time_zones','dst_group_value_id') IS NULL 
	alter table dbo.time_zones add dst_group_value_id int

IF COL_LENGTH('mv90_dst','dst_group_value_id') IS NULL 
	alter table dbo.mv90_dst add dst_group_value_id int

IF COL_LENGTH('hour_block_term','dst_group_value_id') IS NULL 
	alter table dbo.hour_block_term add dst_group_value_id int
