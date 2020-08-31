if COL_LENGTH(N'application_notes', 'parent_object_id') is null
begin
	alter table application_notes
	add parent_object_id INT NULL
	print 'Column parent_object_id added.'
end
else
print 'Column parent_object_id already exists.'