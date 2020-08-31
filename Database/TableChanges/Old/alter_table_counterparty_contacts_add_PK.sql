if OBJECT_ID(N'counterparty_contacts', N'U') is not null
begin
	if COL_LENGTH(N'counterparty_contacts', N'counterparty_contact_id') is not null
	begin
		IF OBJECT_ID(N'PK_counterparty_contact_id', N'PK') is null
		begin
			alter table counterparty_contacts 
			add constraint PK_counterparty_contact_id PRIMARY KEY (counterparty_contact_id)
			print 'constraint PK_counterparty_contact_id PRIMARY KEY added.'
		end
		else print 'constraint PK_counterparty_contact_id PRIMARY KEY already exists.'
		
	end
	else print 'Column ''counterparty_contact_id'' on table ''counterparty_contacts'' does not exists.'

end
else print 'Table ''counterparty_contacts'' does not exists.'