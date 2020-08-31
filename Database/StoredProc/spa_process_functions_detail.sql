/*
Author : Vishwas Khanal
Dated  : 27.July.2009
*/
if object_id('[dbo].[spa_process_functions_detail]','p') is not null
	drop proc [dbo].[spa_process_functions_detail]
go

create procedure [dbo].[spa_process_functions_detail]
	@flag char(1) , -- i : insert, u : update, d : delete ,a : select
	@functionID int,
	@functionDesc varchar(8000) = null,
	@filterID varchar(8000) = null

as

begin
declare @list varchar(8000)
	if @flag = 'i'
	begin
	 begin tran
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

		insert into dbo.process_functions_detail
		(
			functionID,
			userVendorFlag,
			filterID						
		)
			select 
			@functionID,'v',item from dbo.splitcommaSeperatedValues(@filterID)
				inner join dbo.process_filters on item = filterID
					order by precedence asc
						
				
							
		if @@error<>0		
			rollback tran		
		else
			commit tran
		
	end
	else if @flag = 'u'
	begin		
		begin tran
		update dbo.process_functions
		set functionDesc = @functionDesc			
		where functionID = @functionID

		delete from dbo.process_functions_detail where functionID = @functionID and userVendorFlag = 'v'

		insert into dbo.process_functions_detail
		(
			functionID,
			userVendorFlag,
			filterID
						
		)
			select 
			@functionID,'v',item from dbo.splitcommaSeperatedValues(@filterID)			
			inner join dbo.process_filters on item = filterID
					order by precedence asc
						
		if @@error<>0		
			rollback tran		
		else
			commit tran

	
	end
	else if @flag = 'd'
	begin
		delete from dbo.process_functions_detail where functionID = @functionID and userVendorFlag = 'v'
		delete from dbo.process_functions where functionID = @functionID 	
	end
	else if @flag = 's'
	begin		

		SELECT IDENTITY(INT,1,1) as sno ,* into #process_functions_detail FROM process_functions_detail 

		SELECT functionID [functionID] ,
		SUBSTRING(
		(
			select (','+filterID)
			from #process_functions_detail o2
			where o1.functionID = o2.functionID
--				and o1.userVendorFlag = o2.userVendorFlag
				and userVendorFlag = 'v'
			order by sno ASC	
--			functionID,
--			filterID					
			for xml path ('')
		),2,1000) [functionDesc] --into #tmp
		from #process_functions_detail o1				
				where userVendorFlag = 'v'
					group by functionID
				
	end
	else if @flag = 'a'
	begin		
		select @list = ''
		select @list = @list + ',' +  cast(pfd.filterID as varchar) from dbo.process_functions_detail pfd where pfd.functionID = @functionID	
						and pfd.userVendorFlag = 'v'

		select @list =  substring(@list,2,len(@list))
			

		select pf.functionID ,pf.functionDesc ,@list 
			from dbo.process_functions pf 			
			where pf.functionID = @functionID
	end
	else if @flag = 'f'
	begin		
		select @list = ''
		select @list = @list + ',' +''''+  cast(pfd.filterID as varchar) +'''' from dbo.process_functions_detail pfd where pfd.functionID = @functionID	
				 and pfd.userVendorFlag = 'v'
      
		select @list =  substring(@list,2,len(@list))
		exec ('select 	p.filterID from process_filters p
	      where p.filterID IN('+@list+') order by p.precedence asc')
	end



end
