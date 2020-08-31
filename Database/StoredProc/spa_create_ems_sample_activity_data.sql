
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_ems_sample_activity_data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_ems_sample_activity_data]
GO 

-- exec spa_create_ems_sample_activity_data 'S',1900,
CREATE procedure [dbo].[spa_create_ems_sample_activity_data]
@flag varchar(1),
@company_type_id int ,
@process_id varchar(100)

As
if @flag='s'
Begin

DECLARE @sql_stmt VARCHAR(1000)

CREATE TABLE #portfolio_hierarcy_tmp(
		entity_id INT,
		ph_entity_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		have_rights INT,
		hierarchy_level INT,
		sb INT,
		st INT,
		bk INT,
		process_id VARCHAR(50) COLLATE DATABASE_DEFAULT,
		parent_process_id VARCHAR(50) COLLATE DATABASE_DEFAULT,
		cur_entity_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		ph_entity_id int
	)

	SET @sql_stmt='	
				insert INTo #portfolio_hierarcy_tmp
				( 
					entity_id ,
					ph_entity_name,
					have_rights,
					hierarchy_level,
					sb,
					st,
					bk,
					process_id,
					parent_process_id,
					cur_entity_name
				)
				EXEC spa_getPortfolioHierarchyEmsWiz ''s'',''' + cast(@process_id AS VARCHAR(500)) + ''''

exec(@sql_stmt)



select DISTINCT
	
	ph2.cur_entity_name AS [Sub],
	ph1.cur_entity_name AS [Stra],
	ph.cur_entity_name AS [Book],
	csstv.source_sink_facility_id as [FacilityID],
	csstv.source_sink_unit_id as [Unit],
	esi.input_name as [Input],
	dbo.fnadateformat(ea.term_start) as [term_start],
	dbo.fnadateformat(ea.term_end) as [term_end],
	ea.frequency as [Frequency],
	max(esdv1.code) as char1,
	max(esdv2.code) as char2,
	max(esdv3.code) as char3,
	max(esdv4.code) as char4,
	max(esdv5.code) as char5,
	max(esdv6.code) as char6,
	max(esdv7.code) as char7,
	max(esdv8.code) as char8,
	max(esdv9.code) as char9,
	max(esdv10.code) as char10,
	max(cast(ea.input_value as float)) as [input_value],
	su.uom_id as [uom]
FROM
		company_source_sink_type_value csstv join ems_input_map eim on eim.source_model_id=csstv.ems_source_model_id
		join ems_activity_data_sample ea on ea.ems_input_id=eim.input_id
		join ems_source_input esi on esi.ems_source_input_id=eim.input_id

		left join ems_input_characteristics eic1 on eic1.ems_source_input_id=esi.ems_source_input_id and eic1.sequence_id=1
		left join ems_static_data_value esdv1 on esdv1.type_id=eic1.type_id and ISNULL(ltrim(rtrim(ea.char1)),-1)=esdv1.value_id 

		left join ems_input_characteristics eic2 on eic2.ems_source_input_id=esi.ems_source_input_id and eic2.sequence_id=2
		left join ems_static_data_value esdv2 on esdv2.type_id=eic2.type_id and ISNULL(ltrim(rtrim(ea.char2)),-1)=esdv2.value_id

		left join ems_input_characteristics eic3 on eic3.ems_source_input_id=esi.ems_source_input_id and eic3.sequence_id=2
		left join ems_static_data_value esdv3 on esdv3.type_id=eic3.type_id and ISNULL(ltrim(rtrim(ea.char3)),-1)=esdv3.value_id

		left join ems_input_characteristics eic4 on eic4.ems_source_input_id=esi.ems_source_input_id and eic4.sequence_id=2
		left join ems_static_data_value esdv4 on esdv4.type_id=eic4.type_id and ISNULL(ltrim(rtrim(ea.char4)),-1)=esdv4.value_id

		left join ems_input_characteristics eic5 on eic5.ems_source_input_id=esi.ems_source_input_id and eic5.sequence_id=2
		left join ems_static_data_value esdv5 on esdv5.type_id=eic5.type_id and ISNULL(ltrim(rtrim(ea.char5)),-1)=esdv5.value_id

		left join ems_input_characteristics eic6 on eic6.ems_source_input_id=esi.ems_source_input_id and eic6.sequence_id=2
		left join ems_static_data_value esdv6   on esdv6.type_id=eic6.type_id and ISNULL(ltrim(rtrim(ea.char6)),-1)=esdv6.value_id

		left join ems_input_characteristics eic7 on eic7.ems_source_input_id=esi.ems_source_input_id and eic7.sequence_id=2
		left join ems_static_data_value esdv7 on esdv7.type_id=eic7.type_id and ISNULL(ltrim(rtrim(ea.char7)),-1)=esdv7.value_id

		left join ems_input_characteristics eic8 on eic8.ems_source_input_id=esi.ems_source_input_id and eic8.sequence_id=2
		left join ems_static_data_value esdv8 on esdv8.type_id=eic8.type_id and ISNULL(ltrim(rtrim(ea.char8)),-1)=esdv8.value_id

		left join ems_input_characteristics eic9 on eic9.ems_source_input_id=esi.ems_source_input_id and eic9.sequence_id=2
		left join ems_static_data_value esdv9 on esdv9.type_id=eic9.type_id and ISNULL(ltrim(rtrim(ea.char9)),-1)=esdv9.value_id

		left join ems_input_characteristics eic10 on eic10.ems_source_input_id=esi.ems_source_input_id and eic10.sequence_id=2
		left join ems_static_data_value esdv10 on esdv10.type_id=eic10.type_id and ISNULL(ltrim(rtrim(ea.char10)),-1)=esdv10.value_id

		left join source_uom su on ltrim(rtrim(ea.uom_id))=su.source_uom_id
		join #portfolio_hierarcy_tmp ph on ph.entity_id=csstv.fas_book_id and ph.hierarchy_level=0
		join #portfolio_hierarcy_tmp ph1 on ph.parent_process_id=ph1.process_id and ph1.hierarchy_level=1
		join #portfolio_hierarcy_tmp ph2 on ph1.parent_process_id=ph2.process_id and ph2.hierarchy_level=2
		--and ctpv.parent_process_id=@process_id

 WHERE 1=1
	  AND csstv.process_id=@process_id	
	--AND ctpv.value_id IS NOT NULL
 GROUP BY
	ph.cur_entity_name ,
	ph1.cur_entity_name ,
	ph2.cur_entity_name ,
	csstv.source_sink_facility_id,
	csstv.source_sink_unit_id,
	esi.input_name ,
	ea.term_start ,
	ea.term_end ,
	ea.frequency ,
	su.uom_id
--where csstv.process_id=@process_id
	  

End

















