IF OBJECT_ID('[dbo].[spa_company_source_sink_type_temp_value]') IS NOT NULL
DROP PROC [dbo].[spa_company_source_sink_type_temp_value]
go
CREATE PROC [dbo].[spa_company_source_sink_type_temp_value]
@flag char(1),
@company_type_id int = NULL,
@source_sink_type_id int = NULL,
@process_id varchar(500) = NULL

AS
if @flag='i'
BEGIN
--truncate table company_source_sink_type_temp	
--select * from company_source_sink_type_temp 
--delete from company_source_sink_type_temp where company_source_sink_type_id between 4 and 100
--declare @process_id varchar(500)
--SET @process_id = REPLACE(newid(),'-','_')

insert into company_source_sink_type_temp(source_sink_type_id,company_type_id,process_id) 
select entity_id,'3700',@process_id from (
			select distinct ems_ph.entity_id,  ems_ph.entity_name + '|' as entity_name, 1 as have_rights, ems_ph.hierarchy_level, 
			 ems_ph.entity_id sb,0 st, 0 bk
			from ems_portfolio_hierarchy ems_ph 
			join ems_portfolio_hierarchy strat on strat.parent_entity_id = ems_ph.entity_id and ems_ph.hierarchy_level = 2
			join ems_portfolio_hierarchy book on book.parent_entity_id = strat.entity_id 
			join company_source_sink_type csst on csst.source_sink_type_id = book.entity_id

			union all

			select distinct strat.entity_id, ems_ph.entity_name+'|'+ strat.entity_name + '|',  
			1 as have_rights, strat.hierarchy_level, ems_ph.entity_id sb,strat.entity_id  st, 0 bk
			from ems_portfolio_hierarchy ems_ph
			join ems_portfolio_hierarchy strat on strat.parent_entity_id = ems_ph.entity_id and strat.hierarchy_level = 1
			join ems_portfolio_hierarchy book on book.parent_entity_id = strat.entity_id 
			join company_source_sink_type csst on csst.source_sink_type_id = book.entity_id

			union all

			select distinct book.entity_id, ems_ph.entity_name+'|'+ strat.entity_name+'|'+book.entity_name,  
			1 as have_rights, book.hierarchy_level, ems_ph.entity_id sb,strat.entity_id  st, book.entity_id bk
			from ems_portfolio_hierarchy ems_ph
			join ems_portfolio_hierarchy strat on strat.parent_entity_id = ems_ph.entity_id 
			join ems_portfolio_hierarchy book on book.parent_entity_id = strat.entity_id and book.hierarchy_level = 0
			join company_source_sink_type csst on csst.source_sink_type_id = book.entity_id
			) a
			order by a.sb,a.st,a.bk
END


