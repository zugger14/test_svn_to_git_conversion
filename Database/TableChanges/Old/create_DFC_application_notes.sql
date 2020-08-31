--default constraint for application_notes
if not exists(select * from sysobjects o 
inner join syscolumns c
on o.id = c.cdefault
inner join sysobjects t
on c.id = t.id
where o.xtype = 'D'
and c.name = 'create_ts'
and t.name = 'application_notes')
begin
	ALTER TABLE application_notes
	ADD CONSTRAINT DFC_application_notes_create_ts
	DEFAULT GETDATE() FOR create_ts
	print 'Default constraint for create_ts created.'
end
else print 'Default constraint for create_ts already exists.'

if not exists(select * from sysobjects o 
inner join syscolumns c
on o.id = c.cdefault
inner join sysobjects t
on c.id = t.id
where o.xtype = 'D'
and c.name = 'create_user'
and t.name = 'application_notes')
begin
	ALTER TABLE application_notes
	ADD CONSTRAINT DFC_application_notes_create_user
	DEFAULT dbo.FNADbuser() FOR create_user
	print 'Default constraint for create_user created.'
end
else print 'Default constraint for create_user already exists.'
