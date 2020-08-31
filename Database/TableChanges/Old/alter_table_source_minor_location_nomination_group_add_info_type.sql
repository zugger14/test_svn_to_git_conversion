--added col info_type to distinguish between meter info and route info (two fieldsets on UI)
if COL_LENGTH('source_minor_location_nomination_group', 'info_type') is null
begin
	alter table source_minor_location_nomination_group
	add info_type char(1)
	print 'Column info_type added.'
end
else print 'Column info_type already exists.'