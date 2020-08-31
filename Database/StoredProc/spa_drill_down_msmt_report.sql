IF OBJECT_ID(N'spa_drill_down_msmt_report', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_drill_down_msmt_report]
 GO 



-- EXEC spa_drill_down_msmt_report 'Assessment', 'd', '2004-12-31', '622', 'a', NULL

--EXEC spa_drill_down_msmt_report 'LINK', 'd', '2005-03-31', '654', 'a', NULL


create PROCEDURE [dbo].[spa_drill_down_msmt_report] 	@clm_type varchar(20),						
						@discount_option varchar(1),
						@as_of_date varchar(20),
						@link_id varchar(100),
						@settlement_option varchar(1),
						@term_month varchar(20) = NULL

AS
SET NOCOUNT ON 
-- DECLARE @term_month varchar(20)
-- DECLARE @discount_option varchar(1)
-- --DECLARE @sub_entity_id varchar(100)
-- DECLARE @settlement_option varchar(1)
-- DECLARE @as_of_date varchar(20)
-- DECLARE @link_id int
-- set @term_month = NULL
-- set @discount_option = 'd'
-- set @settlement_option = 'c'
-- set @as_of_date = '1/31/2003'
-- set @link_id = 64
--set @sub_entity_id = '1,2,20'
-- select * from static_data_value where type_id = 450
--AOCI

declare @st varchar(8000)
IF @clm_type = 'AOCI'
	set @st='
	select 	fsub.entity_name Sub, fs.entity_name Strategy, fb.entity_name Book, '''+dbo.FNADateFormat(@as_of_date) +''' as [As of Date],
		--dbo.FNAHyperLinkText(10233710, '+@link_id+ ','+ @link_id+') as [RelID], 
		dbo.FNATRMWinHyperlink(''a'', 10233700, ' + @link_id + ', ABS(' + @link_id + '),null,null,null,null,null,null,null,null,null,null,null,0) as [RelID], 
		dbo.FNAContractMonthFormat(rmv.term_month) as [Term],
		case when (link_type_value_id = 451) then  
			round(CASE when ('''+@discount_option+''' = ''u'') then u_total_aoci else d_total_aoci end, 2)
		else 0 end as [De-designation  AOCI], 
		case when (link_type_value_id = 450) then  		
			ROUND(CASE when ('''+@discount_option +'''= ''u'') then u_total_aoci else d_total_aoci end , 2)
		else 0 end [AOCI],
			round(CASE when ('''+@discount_option+''' = ''u'') then u_total_aoci else d_total_aoci end, 2) as [Total AOCI]
	from 	'+dbo.FNAGetProcessTableName(@as_of_date,'report_measurement_values')+' rmv INNER JOIN
		portfolio_hierarchy fb on fb.entity_id =  rmv.book_entity_id INNER JOIN
		portfolio_hierarchy fs on fs.entity_id =  rmv.strategy_entity_id INNER JOIN
		portfolio_hierarchy fsub on fsub.entity_id =  rmv.sub_entity_id 
	where rmv.as_of_date ='''+ @as_of_date+'''
	and dbo.FNAContractMonthFormat(rmv.term_month) ='+case when  @term_month is null then 'dbo.FNAContractMonthFormat(rmv.term_month)' else +''''+@term_month+'''' end +'
	and u_total_aoci <> 0
	and rmv.link_id = '+@link_id+'	order  by rmv.term_month'


--PNL
/*
If @clm_type = 'PNL'
set @st='
	select 	fsub.entity_name Sub, fs.entity_name Strategy, fb.entity_name Book, dbo.FNADateFormat('''+@as_of_date+''') as [As of Date],
		--@link_id as [RelID], 
		dbo.FNAHyperLinkText(10233710, '+@link_id+','+ @link_id+') as [RelID], 
		dbo.FNAContractMonthFormat(term_month) as [Term], 
		round(CASE when ('''+@discount_option+''' = ''u'') then u_pnl_extrinsic else d_pnl_extrinsic end, 0)  as [PNL Extrinsic], 
		case when (link_type_value_id in (451, 452)) then 
			round(CASE when ('''+@discount_option+''' = ''u'') then u_pnl_ineffectiveness  else d_pnl_ineffectiveness end, 0)
		else 0 end as [PNL De-designation], 
		case when (link_type_value_id = 450) then 
			round(CASE when ('''+@discount_option +'''= ''u'') then u_pnl_ineffectiveness  else d_pnl_ineffectiveness end, 0) 
		else 0 end as [PNL Ineffectiveness], 
		round(CASE when ('''+@discount_option+''' = ''u'') then u_pnl_mtm  else d_pnl_mtm end, 0)  as [PNL MTM], 
		round(CASE when ('''+@discount_option +'''= ''u'') then u_total_pnl  else d_total_pnl end, 0) as [Total PNL]  
	from 	'+dbo.FNAGetProcessTableName(@as_of_date,'report_measurement_values')+' report_measurement_values INNER JOIN
		portfolio_hierarchy fb on fb.entity_id =  report_measurement_values.book_entity_id INNER JOIN
		portfolio_hierarchy fs on fs.entity_id =  report_measurement_values.strategy_entity_id INNER JOIN
		portfolio_hierarchy fsub on fsub.entity_id =  report_measurement_values.sub_entity_id 
	where as_of_date = '''+@as_of_date+''' and u_total_pnl <> 0
	and link_id ='+ @link_id+'
	and dbo.FNAContractMonthFormat(term_month) = '+case when @term_month is null then 'dbo.FNAContractMonthFormat(term_month)' else ''''+@term_month+'''' end +'
	and (('''+@settlement_option+''' = ''f'' and term_month > dbo.FNAGetContractMonth('''+@as_of_date+'''))
	OR ('''+@settlement_option+''' = ''c'' and term_month >= dbo.FNAGetContractMonth('''+@as_of_date+'''))                
	OR  ('''+@settlement_option+''' = ''s'' and term_month <= dbo.FNAGetContractMonth('''+@as_of_date+'''))
	OR ('''+@settlement_option+''' = ''a'' and 1 = 1))  
	order  by term_month
'
*/
--LINK
If @clm_type = 'PNL'
set @st='
	select 	fsub.entity_name Sub, fs.entity_name Strategy, fb.entity_name Book, dbo.FNADateFormat('''+@as_of_date+''') as [As of Date],
		--dbo.FNAHyperLinkText(10233710, '+@link_id+','+ @link_id+') as [RelID], 
		dbo.FNATRMWinHyperlink(''a'', 10233700, ' + @link_id + ', ABS(' + @link_id + '),null,null,null,null,null,null,null,null,null,null,null,0) as [RelID], 
		dbo.FNAContractMonthFormat(term_month) as [Term], 
		round(CASE when ('''+@discount_option+''' = ''u'') then u_pnl_extrinsic else d_pnl_extrinsic end, 2)  as [PNL Extrinsic], 
		case when (link_type_value_id in (451, 452)) then 
			round(CASE when ('''+@discount_option+''' = ''u'') then u_pnl_ineffectiveness  else d_pnl_ineffectiveness end, 2) -
			round(CASE when ('''+@discount_option+''' = ''u'') then u_pnl_dedesignation else d_pnl_dedesignation end, 2)
		else 0 end as [PNL De-designation], 		 
		case when (link_type_value_id in (450, 451, 452)) then 
			round(CASE when ('''+@discount_option +'''= ''u'') then u_pnl_dedesignation  else d_pnl_dedesignation end, 2)
		else 0 end as [PNL Ineff Locked], 
		case when (link_type_value_id = 450) then 
			round(CASE when ('''+@discount_option +'''= ''u'') then u_pnl_ineffectiveness  else d_pnl_ineffectiveness end, 2) -
			round(CASE when ('''+@discount_option+''' = ''u'') then u_pnl_dedesignation else d_pnl_dedesignation end, 2)	 
		else 0 end as [PNL Ineffectiveness], 
		round(CASE when ('''+@discount_option+''' = ''u'') then u_pnl_mtm  else d_pnl_mtm end, 2)  as [PNL MTM], 
		round(CASE when ('''+@discount_option +'''= ''u'') then u_total_pnl  else d_total_pnl end, 2) as [Total PNL]  
	from 	'+dbo.FNAGetProcessTableName(@as_of_date,'report_measurement_values')+' report_measurement_values INNER JOIN
		portfolio_hierarchy fb on fb.entity_id =  report_measurement_values.book_entity_id INNER JOIN
		portfolio_hierarchy fs on fs.entity_id =  report_measurement_values.strategy_entity_id INNER JOIN
		portfolio_hierarchy fsub on fsub.entity_id =  report_measurement_values.sub_entity_id 
	where as_of_date = '''+@as_of_date+''' and u_total_pnl <> 0
	and link_id ='+ @link_id+'
	and dbo.FNAContractMonthFormat(term_month) = '+case when @term_month is null then 'dbo.FNAContractMonthFormat(term_month)' else ''''+@term_month+'''' end +'
	and (('''+@settlement_option+''' = ''f'' and term_month > dbo.FNAGetContractMonth('''+@as_of_date+'''))
	OR ('''+@settlement_option+''' = ''c'' and term_month >= dbo.FNAGetContractMonth('''+@as_of_date+'''))                
	OR  ('''+@settlement_option+''' = ''s'' and term_month <= dbo.FNAGetContractMonth('''+@as_of_date+'''))
	OR ('''+@settlement_option+''' = ''a'' and 1 = 1))  
	order  by term_month
'
--print @discount_option
--print @as_of_date
--print @link_id
--print @settlement_option  

If @clm_type = 'LINK'
	EXEC spa_msmt_link_drill_down @discount_option, @as_of_date, @link_id, @settlement_option, NULL,NULL,NULL, NULL,NULL,NULL, NULL,NULL,NULL,NULL,NULL,@term_month      



--(
--select cd.link_id, max(fas_book_id) fas_book_id, 
--max(eff_test_profile_id) eff_test_profile_id, max(use_eff_test_profile_id) use_eff_test_profile_id, 
--max(isnull(assessment_date, '''+@as_of_date+''')) assessment_date, max(eff_test_result_id) eff_test_result_id
--from '+dbo.FNAGetProcessTableName(@as_of_date,'calcprocess_deals')+ ' cd 
--where cd.calc_type = ''m'' and cd.as_of_date = '''+@as_of_date+''' and cd.link_id = '+@link_id+'
--group by cd.link_id
--) cd inner join

--ASSESSMENT
If @clm_type = 'Assessment'
set @st='
	SELECT  
		case when (av.link_id > 0) then 
			dbo.FNATRMWinHyperlink(''a'', 10233700, av.link_id, ABS(av.link_id),null,null,null,null,null,null,null,null,null,null,null,0) 
		else cast(av.link_id as varchar) end AS [RelID], 
		dbo.FNATRMWinHyperlink(''a'', 10231900, cast(rel1.eff_test_profile_id as VARCHAR(50)) + '' - '' + rel1.eff_test_name, ABS(rel1.eff_test_profile_id),null,null,null,null,null,null,null,null,null,null,null,0) AS RelName, 
		case when(rel2.eff_test_profile_id is null) then  '''' else 
		dbo.FNATRMWinHyperlink(''a'', 10231900, cast(rel2.eff_test_profile_id as VARCHAR(50)) + '' - '' + rel2.eff_test_name, ABS(rel2.eff_test_profile_id),null,null,null,null,null,null,null,null,null,null,null,0)
		 end AS  InheritFrom, 
		case when (assessment_test > 0) then ''Passed'' else ''Failed'' end + '' ('' + cast(round(isnull(av.dol_offset, 0), 4) as varchar) + '')'' [Test (H/HI Ratio)],
	    dbo.FNADateFormat(assessment_date) AS AssmtDate, 
	    assessment_type AS Approach, 
		case when(assessment_type <> ''DolOffset'') then series.code else NULL end Series,
		case when(assessment_type <> ''DolOffset'') then coalesce(rel2.on_number_of_curve_points, rel2.on_number_of_curve_points) 
			else NULL end Points,		 		
		test_range_from TestRangeFrom1, 
		test_range_to TestRangeTo1,
		case when(assessment_type <> ''DolOffset'') then use_assessment_value else assessment_value  end Value1,
		additional_test_range_from TestRangeFrom1, 
		additional_test_range_to TestRangeTo1,
		use_additional_assessment_values Value2,
		additional_test_range_from2 TestRangeFrom2, 
		additional_test_range_to2 TestRangeTo2,
		use_additional_assessment_values2 Value3,
		av.eff_test_result_id ResultId,
		featr.create_ts as CreatedOn
	FROM    

(
select link_id, max(fas_book_id) fas_book_id, 
max(eff_test_profile_id) eff_test_profile_id, max(use_eff_test_profile_id) use_eff_test_profile_id, 
max(isnull(assessment_date, '''+@as_of_date+''')) assessment_date, max(eff_test_result_id) eff_test_result_id,
max(use_assessment_values) use_assessment_value,  
max(use_additional_assessment_values) use_additional_assessment_values,
max(use_additional_assessment_values2) use_additional_assessment_values2,
max(on_eff_test_approach_value_id) on_eff_test_approach_value_id,
max(test_range_from) test_range_from,
max(test_range_to) test_range_to,
max(additional_test_range_from) additional_test_range_from,
max(additional_test_range_to) additional_test_range_to,
max(additional_test_range_from) additional_test_range_from2,
max(additional_test_range_to) additional_test_range_to2,
max(dol_offset) dol_offset
from '+dbo.FNAGetProcessTableName(@as_of_date,'calcprocess_deals')+' calcprocess_deals
where link_type = ''link'' and link_id ='+ @link_id+' and as_of_date = '''+@as_of_date+'''
group by link_id
) av inner join
(
select link_id, max(assessment_test) assessment_test, max(assessment_type) assessment_type, max(assessment_value) assessment_value
from '+dbo.FNAGetProcessTableName(@as_of_date,'report_measurement_values')+' report_measurement_values
where link_id = '+@link_id+' and as_of_date = '''+@as_of_date+'''
group by link_id
) at on at.link_id = av.link_id LEFT OUTER JOIN
fas_eff_hedge_rel_type rel1  ON  rel1.eff_test_profile_id = av.eff_test_profile_id	LEFT OUTER JOIN
fas_eff_hedge_rel_type rel2  ON  rel2.eff_test_profile_id = av.use_eff_test_profile_id LEFT OUTER JOIN
static_data_value series on series.value_id = coalesce(rel2.on_assmt_curve_type_value_id, rel1.on_assmt_curve_type_value_id) LEFT OUTER JOIN
fas_eff_ass_test_results featr on featr.eff_test_result_id = av.eff_test_result_id
'

--print(@st)
exec(@st)






