if col_length('source_system_data_import_status','description') is not null
begin
	alter table source_system_data_import_status 
	alter column [description] varchar(8000)
	print 'Column [description] altered with data type varchar(8000)'
end
else print 'Column [description] does not exist.'