
/****** Object:  StoredProcedure [dbo].[spa_company_template_parameter_value_tmp]    Script Date: 05/20/2009 16:41:36 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_company_template_parameter_value_tmp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_company_template_parameter_value_tmp]
/****** Object:  StoredProcedure [dbo].[spa_company_template_parameter_value_tmp]    Script Date: 05/20/2009 16:41:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec spa_company_template_parameter_value_tmp 's', 1900,'parent_id_1220665313N','2',NULL,NULL,NULL
CREATE proc [dbo].[spa_company_template_parameter_value_tmp]
@flag varchar(1),
@company_type_id int=NULL,
@process_id varchar(500)=NULL,

@section varchar(50)=NULL,
@parameterName varchar(500)=NULL,
@parameterValue varchar(500)=NULL,



@book_id varchar(500)=NULL

AS

--DECLARE @company_type_id int, @section varchar(50)

DECLARE @cols NVARCHAR(2000), @sql_stmt varchar(8000)

DECLARE @company_type_template_id int

declare @split_char char(1), @parent_process_id varchar(500), @parameter_id int



set @split_char = ','

if @flag = 's'
BEGIN


	set @sql_stmt = ''

	--set @company_type_id = 1900
	--set @section = 'Level1'

	SELECT  @cols = COALESCE(@cols + ',[' + ctp.parameter_name + ']',
							 '[' + ctp.parameter_name + ']')
	FROM company_template_parameter ctp 
	join company_type_template ctt on ctt.company_type_template_id = ctp.company_type_template_id
	where ctt.company_type_id = @company_type_id and ctt.section=@section


	select @company_type_template_id = company_type_template_id from company_type_template where section = @section
		   AND company_type_id=@company_type_id


	SET @sql_stmt = 'SELECT company_type_id,company_type_template_id,section, '+
	@cols +',process_id,parent_process_id
	FROM
	(SELECT   
		ctpvt.process_id,ctt.company_type_id,ctt.company_type_template_id,ctt.section,ctp.parameter_name,  
	ctpvt.parameter_value, ctpvt.parent_process_id

	FROM    company_type_template ctt 
	join company_template_parameter ctp on ctp.company_type_template_id = ctt.company_type_template_id
	join company_template_parameter_value_tmp ctpvt on ctpvt.parameter_id=ctp.parameter_id
	where 1=1 '
	
	if @company_type_template_id is not null
		set @sql_stmt = @sql_stmt + ' and ctt.company_type_template_id = ' + cast(@company_type_template_id as varchar)
	
	if @process_id is not null
		set @sql_stmt = @sql_stmt + ' and ctpvt.parent_process_id = ''' + cast(@process_id as varchar(500)) + ''''
	
	set @sql_stmt = @sql_stmt + 
	') p
	PIVOT
	(
	MAX([parameter_value])
	FOR parameter_name IN
	( '+
	@cols +' )
	) AS pvt
	ORDER BY process_id DESC;'

	EXEC spa_print @sql_stmt

	exec(@sql_stmt)

	

END
Else if @flag = 'i'
BEGIN
	
	set @parent_process_id = NULL

--	set @parameterName = 'base_year_from1,base_year_to1'
--
--	set @parameterValue = '2005,2005'
--
	
	
	if @process_id is null
	begin
		SET @process_id = REPLACE(newid(),'-','_')
		set @parent_process_id = REPLACE(newid(),'-','_')
	end
	else
	BEGIN
		set @parent_process_id = @process_id
		set @process_id = REPLACE(newid(),'-','_')
	END
	


	create table #t (id int IDENTITY (1,1) NOT NULL , num varchar(50) COLLATE DATABASE_DEFAULT)

	

	select @sql_stmt = 'insert into #t select '''+

		  replace(@parameterName,@split_char,''' union all select ''')

	set @sql_stmt = @sql_stmt + ''''
	
	exec spa_print @sql_stmt
	
	exec ( @sql_stmt )

	

	create table #t2 (id int IDENTITY (1,1) NOT NULL , num varchar(50) COLLATE DATABASE_DEFAULT)

	select @sql_stmt = 'insert into #t2 select '''+

		  replace(@parameterValue,@split_char,''' union all select ''')

	set @sql_stmt = @sql_stmt + ''''
	
	exec spa_print @sql_stmt

	exec ( @sql_stmt )

	
	
	--
--	insert into company_template_parameter_value_tmp 
--	select ctp.parameter_id, t2.num, @process_id, @parent_process_id from #t t
--	join company_template_parameter ctp on ctp.parameter_name = t.num
--	join company_type_template ctt on ctt.company_type_template_id = ctp.company_type_template_id
--	join #t2 t2 on t2.id = t.id and t2.num <> ''


	insert into company_template_parameter_value_tmp 
	select ctp.parameter_id,t2.num, @process_id, @parent_process_id from company_template_parameter ctp
	join company_type_template ctt on ctt.company_type_template_id = ctp.company_type_template_id
	join #t t on t.num = ctp.parameter_name
	join #t2 t2 on t2.id = t.id and t2.num <> ''
	where ctt.company_type_id = @company_type_id and ctt.section = @section


--insert book
if @section = '1'
begin
	set @parent_process_id=@process_id
	SET @process_id = REPLACE(newid(),'-','_')

	EXEC spa_print @book_id

	create table #t3 (id int IDENTITY (1,1) NOT NULL , num varchar(50) COLLATE DATABASE_DEFAULT)

		select @sql_stmt = 'insert into #t3 select '''+

			  replace(@book_id,@split_char,''' union all select ''')

		set @sql_stmt = @sql_stmt + '''' 
		
		exec spa_print @sql_stmt

		exec ( @sql_stmt )
	
	--select * from #t3

	--declare @parameter_name varchar(100)
--	select @parameter_id = parameter_id from company_template_parameter where 
--	company_type_template_id = (select company_type_template_id from company_type_template  
--where company_type_id = 1900 and section='Level2')
	declare @book_id_temp int, @book_value varchar(max)

	DECLARE book_cursor CURSOR FOR
	select * from #t3

	open book_cursor

	FETCH NEXT FROM book_cursor
	INTO @book_id_temp,@book_value
		
	WHILE @@FETCH_STATUS = 0   -- book
	BEGIN 
		set @process_id = REPLACE(newid(),'-','_')
		
		select @parameter_id = ctp.parameter_id from company_type_template strat
		join  company_type_template book on book.parent_company_type_template_id = strat.company_type_template_id
		join company_template_parameter ctp on ctp.company_type_template_id = book.company_type_template_id
		where strat.company_type_id = @company_type_id and strat.section=@section and ctp.is_entity_name = 1

		--set @parameter_name = @parameter_name 
			

		
	--	insert into company_template_parameter_value_tmp 
	--	select ctp.parameter_id, eph.entity_name ,@process_id,@parent_process_id from #t3 t3 
	--	left join company_template_parameter ctp on ctp.parameter_name = @parameterName 
	--	join ems_portfolio_hierarchy eph on eph.entity_id = t3.num
		
--		insert into company_template_parameter_value_tmp (parameter_id,	parameter_value, process_id, parent_process_id)
--		values
--		(@parameter_id,@book_value,@process_id,@parent_process_id)

		insert into company_template_parameter_value_tmp 
		select ctp.parameter_id, eph.entity_name ,@process_id,@parent_process_id from #t3 t3 
		join company_template_parameter ctp on ctp.parameter_id = @parameter_id
		join ems_portfolio_hierarchy eph on eph.entity_id = t3.num 
		where t3.id = @book_id_temp

		
		
		set @parameter_id = null
		
		select @parameter_id = ctp.parameter_id from company_type_template strat
		join  company_type_template book on book.parent_company_type_template_id = strat.company_type_template_id
		join company_template_parameter ctp on ctp.company_type_template_id = book.company_type_template_id
		where strat.company_type_id = @company_type_id and strat.section=@section and ctp.is_entity_name = 0

		insert into company_template_parameter_value_tmp 
		select ctp.parameter_id, 'n' ,@process_id,@parent_process_id from #t3 t3 
		join company_template_parameter ctp on ctp.parameter_id = @parameter_id
		join ems_portfolio_hierarchy eph on eph.entity_id = t3.num
		where t3.id = @book_id_temp

	--	insert into company_template_parameter_value_tmp 
	--	select ctp.parameter_id, NULL ,@process_id,@parent_process_id from company_template_parameter ctp 
	--				where ctp.parameter_id = @parameter_id

		
		FETCH NEXT FROM book_cursor
		INTO @book_id_temp,@book_value
	End
	CLOSE book_cursor
	DEALLOCATE  book_cursor
	drop table #t3
End
	


	If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
				"spa_company_type_template", "DB Error", 
				"Insert of parameter value failed.", ''
		return
	end

		else Exec spa_ErrorHandler 0, 'Emissions Wizard Setup', 
				'spa_company_type_template', 'Success', 
				'Paramter value successfully inserted.', ''

	drop table #t
	drop table #t2
	
	
END
Else if @flag = 'u'
Begin

	set @parent_process_id = NULL

--	set @parameterName = 'base_year_from1,base_year_to1'
--
--	set @parameterValue = '2005,2005'
--
--	set @split_char = ','
	
	
	create table #tUpdate (id int IDENTITY (1,1) NOT NULL , num varchar(50) COLLATE DATABASE_DEFAULT)

	

	select @sql_stmt = 'insert into #tUpdate select '''+

		  replace(@parameterName,@split_char,''' union all select ''')

	set @sql_stmt = @sql_stmt + ''''
	
	exec spa_print @sql_stmt
	
	exec ( @sql_stmt )


	create table #tUpdate2 (id int IDENTITY (1,1) NOT NULL , num varchar(50) COLLATE DATABASE_DEFAULT)

	select @sql_stmt = 'insert into #tUpdate2 select '''+

		  replace(@parameterValue,@split_char,''' union all select ''')

	set @sql_stmt = @sql_stmt + ''''
	
	exec spa_print @sql_stmt

	exec ( @sql_stmt )
	
	update company_template_parameter_value_tmp set
	parameter_value = t2.num from #tUpdate t
	join company_template_parameter ctp on ctp.parameter_name = t.num 
	join #tUpdate2 t2 on t2.id = t.id and t2.num <> ''
	join company_template_parameter_value_tmp ctpvt on ctpvt.parameter_id = ctp.parameter_id
	where ctpvt.process_id = @process_id

	If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
				"spa_company_type_template", "DB Error", 
				"Update of parameter value failed.", ''
		return
	end

		else Exec spa_ErrorHandler 0, 'Emissions Wizard Setup', 
				'spa_company_type_template', 'Success', 
				'Paramter value successfully updated.', ''

	
	drop table #tUpdate
	drop table #tUpdate2
End
Else if @flag = 'd'
Begin

	if @section = '2'
	begin
		delete ctpvt3 from company_template_parameter_value_tmp ctpvt1
		join company_template_parameter_value_tmp ctpvt2 on ctpvt2.parent_process_id = ctpvt1.process_id
		join company_template_parameter_value_tmp ctpvt3 on ctpvt3.parent_process_id = ctpvt2.process_id
		where ctpvt1.process_id = @process_id


		delete ctpvt2 from company_template_parameter_value_tmp ctpvt1
		join company_template_parameter_value_tmp ctpvt2 on ctpvt2.parent_process_id = ctpvt1.process_id
		where ctpvt1.process_id = @process_id

		delete ctpvt1 from company_template_parameter_value_tmp ctpvt1 
		where ctpvt1.process_id = @process_id
	end
	else if @section = '1'
	begin
		delete ctpvt2 from company_template_parameter_value_tmp ctpvt1
		join company_template_parameter_value_tmp ctpvt2 on ctpvt2.parent_process_id = ctpvt1.process_id
		where ctpvt1.process_id = @process_id

		delete ctpvt1 from company_template_parameter_value_tmp ctpvt1 
		where ctpvt1.process_id = @process_id
	end
	--delete from company_template_parameter_value_tmp where process_id = @process_id
	
	If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
				"spa_company_type_template", "DB Error", 
				"Deletion of parameter value failed.", ''
		return
	end

		else Exec spa_ErrorHandler 0, 'Emissions Wizard Setup', 
				'spa_company_type_template', 'Success', 
				'Paramter value successfully deleted.', ''
End
Else if @flag = 'a'
Begin
--	select ctpvt.value_id, ctp.parameter_name, ctp.parameter_desc, ctp.parameter_type,
--	ctpvt.parameter_value, ctpvt.process_id
--	 from company_template_parameter_value_tmp ctpvt
--	join company_template_parameter ctp on ctp.parameter_id = ctpvt.parameter_id
--	where process_id = @process_id

	set @sql_stmt = ''

	--set @company_type_id = 1900
	--set @section = 'Level1'

	SELECT  @cols = COALESCE(@cols + ',[' + ctp.parameter_name + ']',
							 '[' + ctp.parameter_name + ']')
	FROM company_template_parameter ctp 
	join company_type_template ctt on ctt.company_type_template_id = ctp.company_type_template_id
	where ctt.company_type_id = @company_type_id and ctt.section=@section


	select @company_type_template_id = company_type_template_id from company_type_template where section = @section


	SET @sql_stmt = 'SELECT company_type_id,company_type_template_id,section, '+
	@cols +',process_id,parent_process_id
	FROM
	(SELECT   
		ctpvt.process_id,ctt.company_type_id,ctt.company_type_template_id,ctt.section,ctp.parameter_name,  
	ctpvt.parameter_value, ctpvt.parent_process_id

	FROM    company_type_template ctt 
	join company_template_parameter ctp on ctp.company_type_template_id = ctt.company_type_template_id
	join company_template_parameter_value_tmp ctpvt on ctpvt.parameter_id=ctp.parameter_id
	where 1=1 '
	
	if @company_type_template_id is not null
		set @sql_stmt = @sql_stmt + ' and ctt.company_type_template_id = ' + cast(@company_type_template_id as varchar)
	
	if @process_id is not null
		set @sql_stmt = @sql_stmt + ' and ctpvt.parent_process_id = ''' + cast(@process_id as varchar(500)) + ''''
	
	set @sql_stmt = @sql_stmt + 
	') p
	PIVOT
	(
	MAX([parameter_value])
	FOR parameter_name IN
	( '+
	@cols +' )
	) AS pvt
	ORDER BY process_id DESC;'

	EXEC spa_print @sql_stmt

	exec(@sql_stmt)

End









