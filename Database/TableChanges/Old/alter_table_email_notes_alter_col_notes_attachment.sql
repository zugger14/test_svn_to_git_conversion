if COL_LENGTH(N'email_notes', 'notes_attachment') is not null
begin
	alter table email_notes drop column notes_attachment
	alter table email_notes add notes_attachment varchar(3000) null
	print 'Column notes_attachment altered.'
end
else
print 'Column notes_attachment does not exists.'