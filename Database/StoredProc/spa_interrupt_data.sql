
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

--select * from interrupt_data_map
--select * from interrupt_data
--exec spa_interrupt_data 'u',6,255,'7/25/2007',16,0,18,0
IF OBJECT_ID(N'[dbo].[spa_interrupt_data]', N'P') IS NOT NULL
drop proc [dbo].[spa_interrupt_data]
go

create proc [dbo].[spa_interrupt_data]
@flag char(1) ,
@interrupt_id int = NULL,
@contract_id int=NULL,
@prod_date datetime=NULL,
@hr_begin varchar(50)=NULL,
@min_begin varchar(50)=NULL,
@hr_end varchar(50)=NULL,
@min_end varchar(50)=NULL,
@type varchar(100) = NULL,
@comment varchar(100) = NULL,
@clq_demand float=NULL

AS
Begin

declare @tmp_year varchar(50),
@start_date varchar(50),
@end_date varchar(50),
@temp_prod_date smalldatetime

declare @sql_stmt varchar(1000)
declare @hr_begin_proxy varchar(50), @min_begin_proxy  varchar(50), @hr_end_proxy  varchar(50), @min_end_proxy  varchar(50)
declare @hr_begin_proxy2 varchar(50), @min_begin_proxy2  varchar(50), @hr_end_proxy2  varchar(50), @min_end_proxy2  varchar(50)

if @flag = 's' and @contract_id is not null
begin
	set @sql_stmt = '
	select interrupt_id as [ID], 
		cg.contract_name as [Contract Name],
		dbo.FNADateFormat(prod_date) as [Interruption Date],
		hr_begin as [Hour From],
		min_begin as [Minute From],
		hr_end as [Hour End],
		min_end as [Minute End],
		ida.[type] as [Type],
		ida.comment as [Comment],
		ida.clq_demand [CLQ Demand]
	from interrupt_data ida
	left join contract_group cg on cg.contract_id = ida.contract_id
	where '

	if @contract_id is not null
		set @sql_stmt = @sql_stmt + ' ida.contract_id = ' + cast(''+@contract_id+'' as varchar)

	exec(@sql_stmt)
end

if @flag = 'a' and @interrupt_id is not null
begin
	set @sql_stmt = '
	select interrupt_id as [ID], 
		contract_id as [Contract Name],
		dbo.FNADateFormat(prod_date) as [Interruption Date],
		hr_begin as [Hour From],
		min_begin as [Minute From],
		hr_end as [Hour End],
		min_end as [Minute End],
		[type] as [Type],
		comment as [Comment],
		clq_demand
	from interrupt_data where interrupt_id = ' + cast(@interrupt_id as varchar)

	exec(@sql_stmt)
end

if @flag = 'i'
begin
	
	
--	if datepart(mm,@prod_date)>=7 
--				begin
--					set @start_date = (cast(datepart(yyyy,@prod_date)as varchar)+'-'+'07'+'-'+'01')
--					set @end_date   = ((cast((cast(datepart(yyyy,@prod_date)as varchar)+1)AS VARCHAR)+'-'+'06')+'-'+'30') 
--				end
--			else if  datepart(mm,@prod_date)<= 6 
--				begin
--					set @start_date = cast(cast(cast(datepart(yyyy,@prod_date)as varchar)-1 AS VARCHAR)+'-'+'07'+'-'+'01' as varchar)
--					set @end_date = cast(cast(datepart(yyyy,@prod_date)as varchar)+'-'+'06'+'-'+'30' as varchar)
--
--				end
--
--			 			
--				select @temp_prod_date=prod_date 
--					from interrupt_data
--					where contract_id = @contract_id 
--					and prod_date BETWEEN @start_date and @end_date
--				
--				
--			if (@temp_prod_date is not null)
--			   begin
--					Exec spa_ErrorHandler 1,'Interrupt Map Block Value for this Fiscal Year Already Exists', 
--					"spa_interrupt_data_map", "DB Error", 
--					"Interrupt Map Block Value for this Fiscal Year Already Exists.", 'Interrupt Map Block Value for this Fiscal Year Already Exists'
--			    return
--				end	
--			else
--			begin
--                  	if @min_begin = 0 
--							begin
--						--		if @hr_begin = 1
--						--			set @hr_begin_proxy = 24
--						--		else
--						--			set @hr_begin_proxy = @hr_begin - 1
--								set @hr_begin_proxy = @hr_begin
--								set @min_begin_proxy = 60
--							end
--					else
--					begin
--						set @hr_begin_proxy = @hr_begin
--						set @min_begin_proxy = @min_end
--					end
--							
--					if @min_end = 0 
--					begin
--						--		if @hr_begin = 1
--						--			set @hr_end_proxy = 24
--						--		else
--						--			set @hr_end_proxy = @hr_begin - 1
--								set @hr_end_proxy = @hr_end
--								set @min_end_proxy = 60
--					end
--					else
--					begin
--								set @hr_end_proxy = @hr_end
--								set @min_end_proxy = @min_end
--					end

			

			set @hr_begin_proxy = @hr_begin + 1

			if @hr_begin_proxy > 24
				set @hr_begin_proxy = 24
			
			
			
			set @min_begin_proxy = @min_begin + 15

			if @min_begin_proxy > 60
				set @min_begin_proxy = 60

			set @hr_end_proxy = @hr_end + 1
			
			if @hr_end_proxy > 24
				set @hr_end_proxy = 24
			
			
			
			set @min_end_proxy = @min_end + 15
			

			if @min_end_proxy > 60
				set @min_end_proxy = 60

		-- for InterruptCalc
			if @min_begin = 0 
				begin
			--		if @hr_begin = 1
			--			set @hr_begin_proxy = 24
			--		else
			--			set @hr_begin_proxy = @hr_begin - 1
					set @hr_begin_proxy2 = @hr_begin
					set @min_begin_proxy2 = 60
				end
				else
				begin
					set @hr_begin_proxy2 = @hr_begin
					set @min_begin_proxy2 = @min_end
				end
				
				if @min_end = 0 
				begin
			--		if @hr_begin = 1
			--			set @hr_end_proxy = 24
			--		else
			--			set @hr_end_proxy = @hr_begin - 1
					set @hr_end_proxy2 = @hr_end
					set @min_end_proxy2 = 60
				end
				else
				begin
					set @hr_end_proxy2 = @hr_end
					set @min_end_proxy2 = @min_end
				end

			
			select @temp_prod_date=prod_date  from interrupt_data where prod_date=@prod_date and contract_id=@contract_id
			if (@temp_prod_date is not null)
				begin
					Exec spa_ErrorHandler 1,'Interrupt Map Block Value for this Date Already Exists', 
					"spa_interrupt_data_map", "DB Error", 
					"Interrupt Map Block Value for this Date Already Exists.", 'Interrupt Map Block Value for this Date Already Exists'
			    return
			end	
			else
				begin
					insert into interrupt_data 
					(contract_id, prod_date, hr_begin, min_begin, hr_begin_proxy, min_begin_proxy, hr_end, min_end, 
					hr_end_proxy, min_end_proxy, type, comment, hr_begin_proxy2, min_begin_proxy2, hr_end_proxy2, 
					min_end_proxy2,clq_demand)
					values
					(@contract_id, @prod_date, @hr_begin, @min_begin, @hr_begin_proxy, @min_begin_proxy, @hr_end, @min_end, 
					 @hr_end_proxy, @min_end_proxy, @type, @comment, @hr_begin_proxy2, @min_begin_proxy2, @hr_end_proxy2, 
					 @min_end_proxy2,@clq_demand)

							If @@ERROR <> 0
								Exec spa_ErrorHandler @@ERROR, "Interruption Block", 
								"spa_interrupt_data", "DB Error", 
								"Error on Inserting Interruption Block.", ''
							else
								Exec spa_ErrorHandler 0, 'Interruption Block', 
								'spa_interrupt_data', 'Success', 
								'Interruption Block successfully inserted.', ''

					
				end

	end
	

if @flag = 'u'
begin
	
	set @hr_begin_proxy = @hr_begin + 1

	if @hr_begin_proxy > 24
		set @hr_begin_proxy = 24
	
	
	
	set @min_begin_proxy = @min_begin + 15

	if @min_begin_proxy > 60
		set @min_begin_proxy = 60

	set @hr_end_proxy = @hr_end + 1
	
	if @hr_end_proxy > 24
		set @hr_end_proxy = 24
	
	
	
	set @min_end_proxy = @min_end + 15
	

	if @min_end_proxy > 60
		set @min_end_proxy = 60

	-- For InterruptCalc

		if @min_begin = 0 
		begin
	--		if @hr_begin = 1
	--			set @hr_begin_proxy = 24
	--		else
	--			set @hr_begin_proxy = @hr_begin - 1
			set @hr_begin_proxy2 = @hr_begin
			set @min_begin_proxy2 = 60
		end
		else
		begin
			set @hr_begin_proxy2 = @hr_begin+1
			set @min_begin_proxy2 = case when @min_begin=0 then 60 else @min_begin-15 end
		end
		
		if @min_end = 0 
		begin
	--		if @hr_begin = 1
	--			set @hr_end_proxy = 24
	--		else
	--			set @hr_end_proxy = @hr_begin - 1
			set @hr_end_proxy2 = @hr_end
			set @min_end_proxy2 = 60
		end
		else
		begin
			set @hr_end_proxy2 = @hr_end+1
			set @min_end_proxy2 = case when @min_end=0 then 60 else @min_end-15 end
		end
	
	update interrupt_data set
		contract_id = @contract_id, 
		prod_date = @prod_date, 
		hr_begin = @hr_begin, 
		min_begin = @min_begin,
		hr_begin_proxy = @hr_begin_proxy, 
		min_begin_proxy = @min_begin_proxy, 
		hr_end = @hr_end, 
		min_end = @min_end,
		hr_end_proxy = @hr_end_proxy, 
		min_end_proxy = @min_end_proxy, 
		[type] = @type, 
		comment = @comment,
		hr_begin_proxy2 = @hr_begin_proxy2, 
		min_begin_proxy2 = @min_begin_proxy2, 
		hr_end_proxy2 = @hr_end_proxy2, 
		min_end_proxy2 = @min_end_proxy2,
		clq_demand=@clq_demand
	where 
		interrupt_id = @interrupt_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Interruption Block", 
		"spa_interrupt_data", "DB Error", 
		"Error on Updating Interruption Block.", ''
	else
		Exec spa_ErrorHandler 0, 'Interruption Block', 
		'spa_interrupt_data', 'Success', 
		'Interruption Block successfully updated.', ''

end

if @flag = 'd'
begin
	delete from interrupt_data where interrupt_id = @interrupt_id

	If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Interruption Block", 
		"spa_interrupt_data", "DB Error", 
		"Error on Deleting Interruption Block.", ''
	else
		Exec spa_ErrorHandler 0, 'Interruption Block', 
		'spa_interrupt_data', 'Success', 
		'Interruption Block successfully deleted.', ''
end
	

end


















