IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_ems_source_sink_template]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_ems_source_sink_template]
GO 
Create procedure [dbo].[spa_ems_source_sink_template]
	@flag char(1),
	@source_template_id int =null,
	@source_group_template_id int =NULL,
	@source_name varchar(500) =NULL,
	@facility_id varchar(500) =NULL,
	@unit_id varchar(500)=NULL,
	@registered varchar(30) =NULL,
	@certification_id int =NULL,
	@technology int =NULL,
	@ems_book_id varchar(500) =NULL,
	@fuel_type int =NULL,
	@start_date varchar(500) =NULL,
	@ems_source_model_id int =NULL,
	@auto_certificate_number varchar(500) =NULL,
	@source_or_sink varchar(500) =NULL,
	@jurisdiction int =NULL

--select * from ems_source_sink_template
As
DECLARE @sql_stmt VARCHAR(5000)	

if @flag='s'
	Begin	
		set @sql_stmt ='	
			select source_template_id,
							esst.source_group_template_id,
							esst.source_name SourceSinkName,
							esst.facility_id SourceFacilityID,
							esst.unit_id UnitID,
							esst.registered Registered,
							esst.certification_id CertificationID,
							esst.technology TechnologyID,
							sdv.code Technology,
							esst.ems_book_id EmsBookID,
							eph.entity_name SourceSinkType,
							esst.ems_source_model_id EmsSourceModelID,
							esm.ems_source_model_name SourceModel,
							esst.fuel_type FuelTypeID,
							sdv1.code FuelType,
							dbo.FNADateFormat(esst.start_date) SourceStartDate,						
							esst.auto_certificate_number AutoCertNum,
							 case when esst.source_or_sink=''s'' then ''source'' else ''sink'' end SourceORSink,
							esst.jurisdiction JurisdictionID,
							sdv2.code Jurisdiction
					from ems_source_sink_template esst
					INNER JOIN ems_source_model esm on esm.ems_source_model_id=esst.ems_source_model_id
					INNER JOIN ems_portfolio_hierarchy eph on eph.entity_id=esst.ems_book_id 
					INNER JOIN static_data_value sdv on sdv.value_id=esst.technology	
					INNER JOIN static_data_value sdv1 on sdv1.value_id=esst.fuel_type	
					INNER JOIN static_data_value sdv2 on sdv2.value_id=esst.jurisdiction	
					where esst.source_group_template_id='+cast(@source_group_template_id as varchar(500))+''
		
			exec(@sql_stmt)
	End
else if @flag='i'
	Begin
		insert into ems_source_sink_template(
							source_group_template_id,
							source_name,
							facility_id,
							unit_id,
							registered,
							certification_id,
							technology,
							ems_book_id,
							fuel_type,
							start_date,
							ems_source_model_id,
							auto_certificate_number,
							source_or_sink,
							jurisdiction
			)values(

							@source_group_template_id,
							@source_name,
							@facility_id,	
							@unit_id,
							@registered,
							@certification_id,
							@technology,
							@ems_book_id,
							@fuel_type,
							@start_date,
							@ems_source_model_id,
							@auto_certificate_number,
							@source_or_sink,
							@jurisdiction	

			)

	If @@ERROR <> 0
		begin
			Exec spa_ErrorHandler @@ERROR, "Source Sink Template", 
					"spa_ems_source_sink_template", "DB Error", 
					"Insert of Source Sink Template  failed.", ''
			return
		end

			else Exec spa_ErrorHandler 0, 'Source Sink Template', 
					'spa_ems_source_sink_template', 'Success', 
					'Source Sink Template  successfully inserted.', ''
	End

else if @flag='u'
	Begin
		update ems_source_sink_template set
											
							source_name=@source_name,
							facility_id=@facility_id,
							unit_id=@unit_id,
							registered=@registered,
							certification_id=@certification_id,
							technology=@technology,
							ems_book_id=@ems_book_id,
							fuel_type=@fuel_type,
							start_date=@start_date,
							ems_source_model_id=@ems_source_model_id,
							auto_certificate_number=@auto_certificate_number,
							source_or_sink=@source_or_sink,
							jurisdiction=@jurisdiction

			where source_template_id=@source_template_id

If @@ERROR <> 0
		begin
			Exec spa_ErrorHandler @@ERROR, "Source Sink Template", 
					"spa_ems_source_sink_template", "DB Error", 
					"Update of Source Sink Template  failed.", ''
			return
		end

			else Exec spa_ErrorHandler 0, 'Source Sink Template', 
					'spa_ems_source_sink_template', 'Success', 
					'Source Sink Template  successfully updated.', ''

	End

else if @flag='a'
	Begin
		select source_template_id,
							esst.source_group_template_id,
							esst.source_name SourceSinkName,
							esst.facility_id SourceFacilityID,	
							esst.unit_id UnitID,	
							esst.registered Registered,
							esst.certification_id CertificationID,
							esst.technology Technology,
							sdv.code Technology,
							esst.ems_book_id EmsBookID,
							eph.entity_name SourceSinkType,
							esst.ems_source_model_id EmsSourceModelID,
							esm.ems_source_model_name SourceModel,
							esst.fuel_type FuelTypeID ,
							sdv1.code  FuelType,
							dbo.FNADateFormat(esst.start_date) SourceStartDate,						
							esst.auto_certificate_number AutoCertNum,
							 esst.source_or_sink,
							esst.jurisdiction JurisdictionID,
							sdv2.code Jurisdiction
							
					from ems_source_sink_template esst
					INNER JOIN ems_source_model esm on esm.ems_source_model_id=esst.ems_source_model_id
					INNER JOIN ems_portfolio_hierarchy eph on eph.entity_id=esst.ems_book_id
					INNER JOIN static_data_value sdv on sdv.value_id=esst.technology	
					INNER JOIN static_data_value sdv1 on sdv1.value_id=esst.fuel_type	
					INNER JOIN static_data_value sdv2 on sdv2.value_id=esst.jurisdiction
					where source_template_id=@source_template_id
	End

Else if @flag='d'
	Begin
		delete from ems_source_sink_template where  source_template_id=@source_template_id

		If @@ERROR <> 0
		begin
			Exec spa_ErrorHandler @@ERROR, "Source Sink Template", 
					"spa_ems_source_sink_template", "DB Error", 
					"Delete of Source Sink Template  failed.", ''
			return
		end

			else Exec spa_ErrorHandler 0, 'Source Sink Template', 
					'spa_ems_source_sink_template', 'Success', 
					'Source Sink Template  successfully Deleted.', ''

		
	End


