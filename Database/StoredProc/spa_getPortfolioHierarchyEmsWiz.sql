IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_getPortfolioHierarchyEmsWiz]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_getPortfolioHierarchyEmsWiz]
GO 
--exec spa_getPortfolioHierarchyEmsWiz 'p','A02145A1_DBD4_498A_B8BD_4C9610A792F4'

create proc [dbo].[spa_getPortfolioHierarchyEmsWiz]
@flag char(1),
@process_id varchar(500)=NULL

AS

if @flag = 's'
Begin
	select * from 
	(
		select sub.value_id as entity_id,  sub.parameter_value + '|' as entity_name , 1 as have_rights, 
		ctt.section as hierarchy_level, sub.value_id as sb, 0 as st, 0 as bk, sub.process_id, sub.parent_process_id, sub.parameter_value as [cur_entity_name]
		from company_type_template ctt
		join company_template_parameter ctp on ctp.company_type_template_id = ctt.company_type_template_id and 
		 ctp.is_entity_name = 1 and ctt.section = 2
		join company_template_parameter_value_tmp sub on sub.parameter_id = ctp.parameter_id and 
			sub.parent_process_id = @process_id

		union all

		select strat.value_id,sub.parameter_value + '|' + strat.parameter_value + '|' as entity_name,
		1 as have_rights, ctt2.section as hierarchy_level, sub.value_id as sb, strat.value_id as st, 0 as bk, strat.process_id, strat.parent_process_id,strat.parameter_value as [cur_entity_name]
		from company_type_template ctt
		join company_type_template ctt2 on ctt2.parent_company_type_template_id = ctt.company_type_template_id
		join company_template_parameter ctp on ctp.company_type_template_id = ctt.company_type_template_id and
			ctp.is_entity_name = 1 and ctt.section = 2
		join company_template_parameter_value_tmp sub on sub.parameter_id = ctp.parameter_id and 
			sub.parent_process_id = @process_id
		join company_template_parameter ctp2 on ctp2.company_type_template_id = ctt2.company_type_template_id and
			ctp2.is_entity_name = 1
		join company_template_parameter_value_tmp strat on strat.parameter_id = ctp2.parameter_id and 
		strat.parent_process_id = sub.process_id

		union all

		select book.value_id,sub.parameter_value + '|' + strat.parameter_value + '|'+ book.parameter_value as entity_name,
		1 as have_rights, ctt3.section as hierarchy_level, sub.value_id as sb, strat.value_id as st, book.value_id as bk, book.process_id, book.parent_process_id,book.parameter_value as [cur_entity_name]
		from company_type_template ctt
		join company_type_template ctt2 on ctt2.parent_company_type_template_id = ctt.company_type_template_id
		join company_type_template ctt3 on ctt3.parent_company_type_template_id = ctt2.company_type_template_id

		join company_template_parameter ctp on ctp.company_type_template_id = ctt.company_type_template_id and
			ctp.is_entity_name = 1 and ctt.section = 2
		join company_template_parameter_value_tmp sub on sub.parameter_id = ctp.parameter_id and 
			sub.parent_process_id = @process_id

		join company_template_parameter ctp2 on ctp2.company_type_template_id = ctt2.company_type_template_id and
			ctp2.is_entity_name = 1
		join company_template_parameter_value_tmp strat on strat.parameter_id = ctp2.parameter_id and 
		strat.parent_process_id = sub.process_id

		join company_template_parameter ctp3 on ctp3.company_type_template_id = ctt3.company_type_template_id and
			ctp3.is_entity_name = 1
		join company_template_parameter_value_tmp book on book.parameter_id = ctp3.parameter_id and
		book.parent_process_id = strat.process_id
	) a
	order by a.sb,a.st,a.bk
End

else if @flag = 'p'
Begin
	
		select * from 
	(
		select sub.value_id as entity_id,  sub.parameter_value + '|' as entity_name , 1 as have_rights,
		0 as hierarchy_level, sub.value_id as sb, 0 as st, 0 as bk, 0 as src
		from company_type_template ctt
		join company_template_parameter ctp on ctp.company_type_template_id = ctt.company_type_template_id and 
		 ctp.is_entity_name = 1 and ctt.section = 2
		join company_template_parameter_value_tmp sub on sub.parameter_id = ctp.parameter_id
       where sub.parent_process_id=@process_id
		

		union all

		select strat.value_id,sub.parameter_value + '|' + strat.parameter_value + '|' as entity_name,
		1 as have_rights, 1 as hierarchy_level, sub.value_id as sb, strat.value_id as st, 0 as bk, 0 as src
		from company_type_template ctt
		join company_type_template ctt2 on ctt2.parent_company_type_template_id = ctt.company_type_template_id
		join company_template_parameter ctp on ctp.company_type_template_id = ctt.company_type_template_id and
			ctp.is_entity_name = 1 and ctt.section = 2
		join company_template_parameter_value_tmp sub on sub.parameter_id = ctp.parameter_id
		join company_template_parameter ctp2 on ctp2.company_type_template_id = ctt2.company_type_template_id and
			ctp2.is_entity_name = 1
		join company_template_parameter_value_tmp strat on strat.parameter_id = ctp2.parameter_id and 
		strat.parent_process_id = sub.process_id
		where sub.parent_process_id=@process_id

		union all

		select book.value_id,sub.parameter_value + '|' + strat.parameter_value + '|'+ book.parameter_value as entity_name,
		1 as have_rights, 2 as hierarchy_level, sub.value_id as sb, strat.value_id as st, book.value_id as bk, 0 as src
		from company_type_template ctt
		join company_type_template ctt2 on ctt2.parent_company_type_template_id = ctt.company_type_template_id
		join company_type_template ctt3 on ctt3.parent_company_type_template_id = ctt2.company_type_template_id

		join company_template_parameter ctp on ctp.company_type_template_id = ctt.company_type_template_id and
			ctp.is_entity_name = 1 and ctt.section = 2
		join company_template_parameter_value_tmp sub on sub.parameter_id = ctp.parameter_id

		join company_template_parameter ctp2 on ctp2.company_type_template_id = ctt2.company_type_template_id and
			ctp2.is_entity_name = 1
		join company_template_parameter_value_tmp strat on strat.parameter_id = ctp2.parameter_id and 
		strat.parent_process_id = sub.process_id

		join company_template_parameter ctp3 on ctp3.company_type_template_id = ctt3.company_type_template_id and
			ctp3.is_entity_name = 1
		join company_template_parameter_value_tmp book on book.parameter_id = ctp3.parameter_id and
			book.parent_process_id = strat.process_id
		where sub.parent_process_id=@process_id
	
	union all

		select book.value_id,sub.parameter_value + '|' + strat.parameter_value + '|'+ book.parameter_value +'|'+ csstv.source_sink_name as entity_name,
		1 as have_rights, 3 as hierarchy_level, sub.value_id as sb, strat.value_id as st, book.value_id as bk, csstv.company_source_sink_type_value_id as src
		from company_type_template ctt
		join company_type_template ctt2 on ctt2.parent_company_type_template_id = ctt.company_type_template_id
		join company_type_template ctt3 on ctt3.parent_company_type_template_id = ctt2.company_type_template_id

		join company_template_parameter ctp on ctp.company_type_template_id = ctt.company_type_template_id and
			ctp.is_entity_name = 1 and ctt.section = 2
		join company_template_parameter_value_tmp sub on sub.parameter_id = ctp.parameter_id

		join company_template_parameter ctp2 on ctp2.company_type_template_id = ctt2.company_type_template_id and
			ctp2.is_entity_name = 1
		join company_template_parameter_value_tmp strat on strat.parameter_id = ctp2.parameter_id and 
		strat.parent_process_id = sub.process_id

		join company_template_parameter ctp3 on ctp3.company_type_template_id = ctt3.company_type_template_id and
			ctp3.is_entity_name = 1
		join company_template_parameter_value_tmp book on book.parameter_id = ctp3.parameter_id and
		book.parent_process_id = strat.process_id
		
		join  company_source_sink_type_value csstv on csstv.fas_book_id= book.value_id 
			and sub.parent_process_id=csstv.process_id
	
		where sub.parent_process_id=@process_id

	) a
	order by a.sb,a.st,a.bk,a.src

End









