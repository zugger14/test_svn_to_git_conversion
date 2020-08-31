/*
Author : Vishwas Khanal
Dated  : 03.Aug.2009
Purpose: Integration 
*/

if object_id ('[dbo].[spa_process_functions_user_detail]','p') is not null
	drop proc [dbo].[spa_process_functions_user_detail]
go

create proc [dbo].[spa_process_functions_user_detail]
	@flag char(1) , -- i : insert, u : update, d : delete ,a : select
	@functionID int,
	@functionDesc varchar(8000) = null,
	@processId INT =NULL,-- Group1
	@filterID varchar(8000) = null
as

begin	
	if @flag in ('i','u')
	begin
		update dbo.process_functions 
			set userFuncionDesc = @functionDesc , process = @processId 
				where functionID = @functionID

		if @flag = 'i'
		
			insert into dbo.process_functions_detail
			(
				functionID,
				userVendorFlag,
				filterID
							
			)
				select 
				@functionID,'u',item from dbo.splitcommaSeperatedValues(@filterID)

		else if @flag = 'u'
		begin
			delete from dbo.process_functions_detail where functionID = @functionID and userVendorFlag = 'u'

			insert into dbo.process_functions_detail
			(
				functionID,
				filterID,
				userVendorFlag			
			)
				select 
				@functionID,item,'u' from dbo.splitcommaSeperatedValues(@filterID)			
		end			
	end
	else if @flag = 'd'
	begin
		delete from dbo.process_functions_detail where functionID = @functionID and userVendorFlag = 'u'
		update dbo.process_functions set userFuncionDesc = NULL,process = NULL where functionID = @functionID 
	end
   else if @flag = 's'
	begin
		 SELECT process,functionID,userFuncionDesc[Function Description] from process_functions where process IS NOT NULL and userFuncionDesc IS NOT NULL
	end
	else if @flag = 'a'
	begin


		declare @list as varchar (8000)

		select @list = ''
		select @list = @list + ',' +''''+ cast(pfd.filterID as varchar) +'''' from dbo.process_functions_detail pfd where pfd.functionID = @functionID	
				 and pfd.userVendorFlag = 'u'
		select @list =  substring(@list,2,len(@list))


      select 	p.functionID,p.process,pch.process_name,p.userFuncionDesc,@list  from process_functions p
				INNER JOIN process_control_header pch on pch.process_id=p.process
	      where  p.functionID=cast(@functionID as varchar) order by p.functionID
	
	end
	else if @flag = 'l' /*for list box*/
	begin	
		DECLARE @sql_stm varchar(max)
		set @sql_stm ='select functionID,functionDesc from process_functions where 1=1 and '
		if @functionID is null
			set @sql_stm=@sql_stm +'process is NULL'
		else
			set @sql_stm=@sql_stm +'functionID='+cast(@functionID as varchar) 
		EXEC spa_print @sql_stm
		exec(@sql_stm)
	end

end