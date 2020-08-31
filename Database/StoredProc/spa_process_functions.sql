/*
Author : Vishwas Khanal
Dated  : 03.Aug.2009
Purpose: Integration 
*/
if object_id('[dbo].[spa_process_functions]','p') is not null
	drop proc [dbo].[spa_process_functions]
go

create procedure [dbo].[spa_process_functions]
	@flag char(1) , -- i : insert, u : update, d : delete ,a : select
	@functionID int,
	@functionDesc varchar(8000)

as
begin
	if @flag = 'i'
	begin
		insert into dbo.process_functions
		(
			functionID,
			functionDesc
		)
		 values
		(
			@functionID,
			@functionDesc
		)

	end
	else if @flag = 'u'
	begin
		update dbo.process_functions
		set functionDesc = @functionDesc
		where functionID = @functionID
	end
	else if @flag = 'd'
	begin
		delete from dbo.process_functions where functionID = @functionID
	end
	else if @flag = 's'
	begin
		select functionID 'Function ID',functionDesc 'Description' from dbo.process_functions where functionID = @functionID
	end
end
