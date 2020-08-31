if OBJECT_ID(N'[dbo].[master_view_counterparty_contacts]', N'U') is null --drop table [dbo].[master_view_counterparty_contacts]
begin
	create table [dbo].[master_view_counterparty_contacts] (
		master_view_counterparty_contacts_id INT IDENTITY(1,1) constraint PK_master_view_counterparty_contacts primary key,
		counterparty_contact_id int not null,
		counterparty_id int not null,
		counterparty_name varchar(200) null,
		title varchar(200) null,
		name varchar(200) null,
		address1 varchar(200) null,
		address2 varchar(200) null,
		city varchar(200) null,
		[state] varchar(200) null,
		zip varchar(10) null,
		country varchar(100) null,
		region varchar(100) null,
		email varchar(200) null,
		comment varchar(200) null,
		telephone varchar(20) null,
		fax varchar(20) null,
		cell_no varchar(15) null
	
	)
	print 'Object ''[dbo].[master_view_counterparty_contacts]'' created.'
end
else print 'Object ''[dbo].[master_view_counterparty_contacts]'' already exists.'
go

if OBJECT_ID(N'FK_counterparty_contact_id_master_view_counterparty_contacts_counterparty_contacts', N'F') is null
begin
	alter table [dbo].[master_view_counterparty_contacts]
	add CONSTRAINT [FK_counterparty_contact_id_master_view_counterparty_contacts_counterparty_contacts] 
			FOREIGN KEY([counterparty_contact_id])
			REFERENCES [dbo].[counterparty_contacts] ([counterparty_contact_id])
			ON DELETE CASCADE
	print 'FK Constraint ''FK_counterparty_contact_id_master_view_counterparty_contacts_counterparty_contacts'' created.'
end
else print 'FK Constraint ''FK_counterparty_contact_id_master_view_counterparty_contacts_counterparty_contacts'' already exists.'
go

if OBJECT_ID(N'FK_counterparty_id_master_view_counterparty_contacts_source_counterparty', N'F') is null
begin
	alter table [dbo].[master_view_counterparty_contacts]
	add CONSTRAINT [FK_counterparty_id_master_view_counterparty_contacts_source_counterparty] 
			FOREIGN KEY([counterparty_id])
			REFERENCES [dbo].[source_counterparty] ([source_counterparty_id])
	print 'FK Constraint ''FK_counterparty_id_master_view_counterparty_contacts_source_counterparty'' created.'
end
else print 'FK Constraint ''FK_counterparty_id_master_view_counterparty_contacts_source_counterparty'' already exists.'
go

IF NOT OBJECTPROPERTY(OBJECT_ID('[dbo].[master_view_counterparty_contacts]'), 'TableHasActiveFulltextIndex') = 1
BEGIN
    CREATE FULLTEXT INDEX ON [dbo].[master_view_counterparty_contacts] (
		title,name,address1,address2,city,state,zip,country,region,email,comment,telephone,fax,cell_no
	) KEY INDEX PK_master_view_counterparty_contacts;
	PRINT 'FULLTEXT INDEX ON master_view_counterparty_contacts created.'
END
ELSE
    PRINT 'FULLTEXT INDEX ON master_view_counterparty_contacts Already Exists.'
GO