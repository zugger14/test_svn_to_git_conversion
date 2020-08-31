if object_id('[dbo].[spa_getReqRevisionDependencyHierarchy]','p') is not null
drop proc [dbo].[spa_getReqRevisionDependencyHierarchy]
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



--exec spa_getReqRevisionDependencyHierarchy 's',135
--select * from process_risk_controls
--select * from process_risk_controls_email
--select * from static_data_value where type_id=725
--select * from process_risk_control_std_dependency

--exec spa_getRiskControlDependencyHierarchy 'r','1083','2008-01-01','2009-01-01' -- This will give tree structure of particular activity dependencies
-- exec spa_getRiskControlDependencyHierarchy		-- This will give tree structure of all activity

-- =============================================
-- Author:		<Gyan Koju>
-- Create date: <08/28/2008>
-- Description:	<fetch Dependent Activities in Tree Structure>


-- =============================================

Create proc [dbo].[spa_getReqRevisionDependencyHierarchy]
@flag varchar(1),				
@requirement_revision_id int = NULL, 
@as_of_date varchar(50) = NULL,
@as_of_date_to varchar(50) = NULL
as

declare @sql_select varchar(max),@sql_from varchar(max),@sql varchar(max),@sql_select_d varchar(max)
declare  @hierarchy_level int
Declare @level_depth int
Declare @count_level_depth int
Declare @sql_level_depth varchar(max)


if @flag = 's'
begin
set @sql=''
		set @sql_select_d=''
		--declare @requirement_revision_id int
--		set @requirement_revision_id='907'
		
		select @level_depth = requirement_revision_hierarchy_level from process_risk_control_std_dependency where 
                          requirements_revision_id = @requirement_revision_id and requirements_revision_id_depend_on 
                       is not null 
			set 	@level_depth=isnull(@level_depth,0)		
		--print @level_depth
		
		set @count_level_depth = 0

		--
		set @sql_level_depth = ''

		while @count_level_depth <= @level_depth
		begin


			if @count_level_depth=0
				begin
				set @sql_level_depth=@sql_level_depth+
						'process_risk_control_std_dependency a'+cast(@count_level_depth as varchar)
						+' join	process_requirements_revisions d'+cast(@count_level_depth as varchar)
						+ ' on d'+ cast(@count_level_depth as varchar) +'.requirements_revision_id=a'
						+cast(@count_level_depth as varchar)+'.requirements_revision_id' 
						
				end
				else
				begin
					set @sql_level_depth=@sql_level_depth+
						' join process_risk_control_std_dependency a'+cast(@count_level_depth as varchar)
						+' on a'+cast(@count_level_depth as varchar)+'.requirements_revision_id_depend_on=a'
						+cast(@count_level_depth-1 as varchar)+'.requirements_revision_dependency_id	join process_requirements_revisions d'
						+cast(@count_level_depth as varchar)+'  on d'+cast(@count_level_depth as varchar)
						+'.requirements_revision_id=a'+cast(@count_level_depth as varchar)+'.requirements_revision_id'

				end
			set @count_level_depth=@count_level_depth+1
		end

set @sql_level_depth=@sql_level_depth + case when @requirement_revision_id is null then '' else ' and a'+cast(@level_depth as varchar) 
+ '.requirements_revision_id='+cast(@requirement_revision_id as varchar) end
EXEC spa_print @sql_level_depth

		DECLARE perfect_match CURSOR FOR 
		select distinct requirement_revision_hierarchy_level from process_risk_control_std_dependency order by requirement_revision_hierarchy_level
		OPEN perfect_match
		FETCH NEXT FROM perfect_match INTO @hierarchy_level
		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC spa_print @hierarchy_level
			set @sql_select=''
			set @sql_from=''
			set @sql_select_d=''

			EXEC spa_print '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'


			select 
			@sql_select_d=@sql_select_d+'d'+cast(a.requirement_revision_hierarchy_level as varchar)+'.risk_control_description + '' | ''+',

			@sql_from=@sql_from+
			case when a.requirement_revision_hierarchy_level <= @level_depth 
			then 
				case when  @sql_from='' then @sql_level_depth else '' end
			else
					' join process_risk_control_std_dependency a'+cast(a.requirement_revision_hierarchy_level as varchar)
					+' on a'+cast(a.requirement_revision_hierarchy_level as varchar)+'.requirements_revision_id_depend_on=a'
					+cast(a.requirement_revision_hierarchy_level-1 as varchar)+'.requirements_revision_dependency_id	join process_requirements_revisions d'
					+cast(a.requirement_revision_hierarchy_level as varchar)+'  on d'+cast(a.requirement_revision_hierarchy_level as varchar)
					+'.requirements_revision_id=a'+cast(a.requirement_revision_hierarchy_level as varchar)+'.requirements_revision_id'
			end
			from (
				select distinct requirement_revision_hierarchy_level from process_risk_control_std_dependency where requirement_revision_hierarchy_level<=@hierarchy_level) a 

		EXEC spa_print @sql_select_d
		EXEC spa_print '>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'
		--
			set @sql_select_d=left(@sql_select_d,len(@sql_select_d)-9)

		set @sql_select_d='a'+cast(@hierarchy_level as varchar)+'.requirements_revision_id,'+'a'+cast(@hierarchy_level as varchar)+'.requirements_revision_dependency_id,'+'a'+cast(@hierarchy_level as varchar)+'.requirements_revision_id_depend_on,'+@sql_select_d+', 1 as have_rights,'+cast(@hierarchy_level as varchar)+' level'
			--set @sql_select=left(@sql_select,len(@sql_select)-9)
			set @sql_from=@sql_from+' and a'+cast(@hierarchy_level as varchar)+'.requirement_revision_hierarchy_level='+cast(@hierarchy_level as varchar)
			EXEC spa_print @sql_select_d
			EXEC spa_print @sql_from
			EXEC spa_print '*****************************************************************************'
			set @sql=@sql+case when @hierarchy_level=0 then '' else ' union all ' end +  ' select ' +@sql_select_d + ' from '+@sql_from 
		FETCH NEXT FROM perfect_match INTO @hierarchy_level
		END
		CLOSE perfect_match
		DEALLOCATE perfect_match
		set @sql=' select a.requirements_revision_dependency_id,a.risk_control_description + ''|'' entity_name, a.have_rights, a.level,a.requirements_revision_id_depend_on, a.requirements_revision_id from ('+@sql+') a where risk_control_description is not null order by risk_control_description'
		EXEC spa_print @sql
		exec(@sql)


end









