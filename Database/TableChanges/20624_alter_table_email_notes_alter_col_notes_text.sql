--alter column 'notes_text' from varchr(5000) to varchar(max), since incoming email will have more than 5000 characters
ALTER FULLTEXT INDEX ON email_notes DROP (notes_text)
go

if COL_LENGTH('email_notes', 'notes_text') is not null
begin
	alter table email_notes
	alter column notes_text varchar(max)
	print 'Column ''notes_text'' altered.'
end
else print 'Column ''notes_text'' does not exist.'
go


ALTER FULLTEXT INDEX ON email_notes ADD (notes_text)
go
