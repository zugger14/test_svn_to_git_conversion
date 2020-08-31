--add column 'workflow_process_id' on email_notes to get details of particular emails from workflow and workflow details
if COL_LENGTH('email_notes', 'workflow_process_id') is null
begin
	alter table email_notes
	add workflow_process_id varchar(200)
	print 'Column ''workflow_process_id'' added.'
end
else print 'Column ''workflow_process_id'' already exists.'
go

--drop old column workflow_process_id
if COL_LENGTH('email_notes', 'workflow_process_id') is not null
begin
	alter table email_notes
	drop column workflow_process_id
	print 'Column ''workflow_process_id'' dropped.'

end
else print 'Column ''workflow_process_id'' does not exist.'
go

--add new column workflow_activity_id
if COL_LENGTH('email_notes', 'workflow_activity_id') is null
begin
	alter table email_notes
	add workflow_activity_id INT NULL
	print 'Column ''workflow_activity_id'' added.'
end
else print 'Column ''workflow_activity_id'' already exists.'
go

--add fk workflow_process_id, set null on workflow activity delete.
if OBJECT_ID(N'FK_workflow_activity_id_email_notes_workflow_activities', N'F') is null
begin
	if COL_LENGTH('email_notes', 'workflow_activity_id') is not null
	begin
		alter table [dbo].[email_notes]
		add CONSTRAINT [FK_workflow_activity_id_email_notes_workflow_activities] 
				FOREIGN KEY([workflow_activity_id])
				REFERENCES [dbo].[workflow_activities] ([workflow_activity_id])
				ON DELETE SET NULL
		print 'FK Constraint ''FK_workflow_activity_id_email_notes_workflow_activities'' created.'
	end
	else print 'Column ''workflow_activity_id'' does not exist.'
end
else print 'FK Constraint ''FK_workflow_activity_id_email_notes_workflow_activities'' already exists.'
go
