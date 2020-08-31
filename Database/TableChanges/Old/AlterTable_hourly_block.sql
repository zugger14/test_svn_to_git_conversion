/*******************************************
Alter table hourly_block
Add column dst_applies CHAR(1)

*****************************************/
IF NOT EXISTS (SELECT 'X' FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = 'hourly_block' and column_name = 'dst_applies')
	Alter table dbo.hourly_block ADD dst_applies CHAR(1)

