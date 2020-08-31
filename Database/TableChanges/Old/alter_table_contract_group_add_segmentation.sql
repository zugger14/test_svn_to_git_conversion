--ADD COLUMN SEGMENTATION USED FOR TRANSPORTATION CONTRACT
if COL_LENGTH('contract_group', 'segmentation') is null
begin
	alter table contract_group
	add segmentation char(1)
end
else print 'Column segmentation already exists.'