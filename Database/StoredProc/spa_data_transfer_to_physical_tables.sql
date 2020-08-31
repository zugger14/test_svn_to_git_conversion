IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_data_transfer_to_physical_tables]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_data_transfer_to_physical_tables]
GO 

/*
	Author		:	Poojan Shrestha
	Date		:	Sept 9, 2008 Tuesday
	Description	:	Transfer data from a temporary table (company_source_sink_type_value) 
					used in Wizard form for source/sink to physical tables (rec_generator,
					source_sink_type, ems_source_model_effective)
*/

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




CREATE procedure [dbo].[spa_data_transfer_to_physical_tables]
@process_id varchar(500)
as


--print @id;
--declare @process_id varchar(500);
--
--set @process_id = 'parent_id_1220951389A';

EXEC spa_print @process_id;

declare @generator_id int;
insert into rec_generator(name,id,source_sink_type,first_gen_date,registered)
	select source_sink_name,source_sink_facility_id,source_sink_type,source_start_date,registered
	from company_source_sink_type_value where process_id=@process_id;

If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
				"spa_data_transfer_to_physical_tables", "DB Error", 
				"Insert of company source sink  failed.", ''
		return
	end

insert into source_sink_type(generator_id, source_sink_type_id, emissions_reporting_group_id)
	select rg.generator_id,csstv.ems_book_id, 5244 
	from company_source_sink_type_value csstv, rec_generator rg
	where process_id=@process_id
	and	csstv.source_sink_facility_id = rg.id;

If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
				"spa_data_transfer_to_physical_tables", "DB Error", 
				"Insert of company source sink type failed.", ''
		return
	end


insert into ems_source_model_effective(generator_id, ems_source_model_id, effective_date)
	select rg.generator_id, csstv.ems_source_model_id, csstv.source_start_date 
	from company_source_sink_type_value csstv,rec_generator rg
	where process_id=@process_id
	and	csstv.source_sink_facility_id = rg.id;


If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
				"spa_data_transfer_to_physical_tables", "DB Error", 
				"Insert of source model value  failed.", ''
		return
	end

		Exec spa_ErrorHandler 0, 'Emissions Wizard Setup', 
				'spa_data_transfer_to_physical_tables', 'Success', 
				'company source sink type value  successfully inserted.', ''
	


