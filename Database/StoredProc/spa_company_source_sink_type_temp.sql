
IF OBJECT_ID('[dbo].[spa_company_source_sink_type_temp]','p') IS NOT NULL 
drop proc [dbo].[spa_company_source_sink_type_temp]
GO
--select * from company_source_sink_type_temp
--exec spa_company_source_sink_type_temp 'i', '32,236', 1900
--exec spa_company_source_sink_type_temp 'i', '31,30', 1900
--exec spa_company_source_sink_type_temp 'i', '125,124', 1900
CREATE proc [dbo].[spa_company_source_sink_type_temp]
@flag char(1),
@ems_book varchar(500)=NULL,
@company_type_id int =NULL,
@process_id varchar(500)=NULL

AS

if @flag = 's'
BEGIN

	select * from (
	select distinct ems_ph.entity_id,  ems_ph.entity_name + '|' as entity_name, 1 as have_rights, ems_ph.hierarchy_level, 
	 ems_ph.entity_id sb,0 st, 0 bk
	from ems_portfolio_hierarchy ems_ph 
	join ems_portfolio_hierarchy strat on strat.parent_entity_id = ems_ph.entity_id and ems_ph.hierarchy_level = 2
	join ems_portfolio_hierarchy book on book.parent_entity_id = strat.entity_id 
	join company_source_sink_type_temp csst on csst.source_sink_type_id = book.entity_id

	union all

	select distinct strat.entity_id, ems_ph.entity_name+'|'+ strat.entity_name + '|',  
	1 as have_rights, strat.hierarchy_level, ems_ph.entity_id sb,strat.entity_id  st, 0 bk
	from ems_portfolio_hierarchy ems_ph
	join ems_portfolio_hierarchy strat on strat.parent_entity_id = ems_ph.entity_id and strat.hierarchy_level = 1
	join ems_portfolio_hierarchy book on book.parent_entity_id = strat.entity_id 
	join company_source_sink_type_temp csst on csst.source_sink_type_id = book.entity_id

	union all

	select distinct book.entity_id, ems_ph.entity_name+'|'+ strat.entity_name+'|'+book.entity_name,  
	1 as have_rights, book.hierarchy_level, ems_ph.entity_id sb,strat.entity_id  st, book.entity_id bk
	from ems_portfolio_hierarchy ems_ph
	join ems_portfolio_hierarchy strat on strat.parent_entity_id = ems_ph.entity_id 
	join ems_portfolio_hierarchy book on book.parent_entity_id = strat.entity_id and book.hierarchy_level = 0
	join company_source_sink_type_temp csst on csst.source_sink_type_id = book.entity_id
	) a
	order by a.sb,a.st,a.bk

	--select * from company_source_sink_type_temp
END

else if @flag='i'

BEGIN
--declare @company_type_id varchar(1000)
--declare @ems_book varchar(500)
--set @ems_book='32,236'
--set @company_type_id=1900


		--SET @process_id = REPLACE(newid(),'-','_')
if @process_id is null
	begin
		SET @process_id = REPLACE(newid(),'-','_')
	end
	else
	BEGIN
		set @process_id = REPLACE(newid(),'-','_')
	END
	

declare @sql_stmt1 varchar(1000)
declare @sql_stmt varchar(1000)
declare @split_char char(1)
SET @split_char=','

create table #t (id int IDENTITY (1,1) NOT NULL , num varchar(50) COLLATE DATABASE_DEFAULT)

	select @sql_stmt = 'insert into #t select '''+

		  replace(@ems_book,@split_char,''' union all select ''')

	set @sql_stmt = @sql_stmt + ''''
	
	exec spa_print @sql_stmt

	exec ( @sql_stmt )


	
	--
	insert into company_source_sink_type_temp(company_type_id,source_sink_type_id,process_id) 

	select  @company_type_id company_type_id ,num,@process_id from #t 
--print @sql_stmt1
--exec(@sql_stmt1)

If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
				"spa_company_source_sink_type_temp", "DB Error", 
				"Insert of source_sink_type_temp  failed.", ''
		return
	end

		else Exec spa_ErrorHandler 0, 'Emissions Wizard Setup', 
				'spa_company_source_sink_type_temp', 'Success', 
				'source_sink_type_temp  successfully inserted.', ''
	


END


