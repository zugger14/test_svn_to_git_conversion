if COL_LENGTH('invoice_header', 'invoice_due_date') is null
begin
	alter table invoice_header
	add invoice_due_date datetime
end
else print 'Column invoice_due_date already exists.'
GO

if COL_LENGTH('invoice_header', 'amount') is null
begin
	alter table invoice_header
	add amount FLOAT
end
else print 'Column amount already exists.'

GO

if COL_LENGTH('invoice_header', 'description1') is null
begin
	alter table invoice_header
	add description1 VARCHAR(500)
end
else print 'Column description1 already exists.'

GO

if COL_LENGTH('invoice_header', 'description2') is null
begin
	alter table invoice_header
	add description2 VARCHAR(500)
end
else print 'Column description2 already exists.'

GO
