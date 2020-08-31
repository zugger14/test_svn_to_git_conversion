IF OBJECT_ID('[dbo].[spa_company_source_sink_type_value]','p') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_company_source_sink_type_value]
GO

CREATE PROCEDURE [dbo].[spa_company_source_sink_type_value]
	@flag VARCHAR(1),
	@process_id VARCHAR(500) = NULL,
	@company_type_id INT = NULL,
	@fas_book_id INT = NULL,
	@company_source_sink_type_value_id INT = NULL,
	@source_sink_name VARCHAR(250) = NULL,
	@source_sink_facility_id VARCHAR(250) = NULL,
	@source_sink_type VARCHAR(1) = NULL,
	@source_start_date VARCHAR(50) = NULL,
	@ems_book_id INT = NULL,
	@ems_source_model_id INT = NULL,
	@changed VARCHAR(1) = NULL,    --ems_source_model_id changed or not while updating
	@registered VARCHAR(1) = NULL,
	@technology INT = NULL,
	@fuel_type INT = NULL,
	@jurisdiction INT = NULL,
	@source_sink_unit_id VARCHAR(50) = NULL,
	@source_sink_template_id INT = NULL	 ----- if the source/sink template id is passed then insert the values from the remplate.

AS

DECLARE @sql_stmt VARCHAR(5000)
DECLARE @gen_id VARCHAR(30)
DECLARE @sub_id INT

SET @sql_stmt = '';

IF @flag = 's'
BEGIN
	SET @sql_stmt='
		SELECT csstv.company_source_sink_type_value_id,
			csstv.source_sink_name SourceSinkName,
			csstv.source_sink_facility_id SourceFacilityID,
			csstv.source_sink_unit_id AS Unit,
			case when csstv.source_sink_type=''s'' then ''source'' else ''sink'' end SourceORSink,
			dbo.FNADateFormat(csstv.source_start_date) StartDate,
			csstv.ems_book_id,
			eph.entity_name SourceSinkType,
			csstv.ems_source_model_id SourceModelID,
			esm.ems_source_model_name SourceModel,
			csstv.fas_book_id FasBookID,
			ctpvt.parameter_value Book,
			csstv.registered,
			csstv.technology,
			csstv.fuel_type,
			csstv.jurisdiction
		FROM company_source_sink_type_value csstv
		INNER JOIN ems_source_model esm ON esm.ems_source_model_id = csstv.ems_source_model_id
		INNER JOIN ems_portfolio_hierarchy eph ON eph.entity_id =  csstv.ems_book_id 
		INNER JOIN company_template_parameter_value_tmp ctpvt ON ctpvt.value_id = csstv.fas_book_id
		WHERE csstv.process_id = ''' + @process_id + ''''
		+ CASE WHEN @fas_book_id IS NOT NULL THEN 'AND csstv.fas_book_id = ' + cast(@fas_book_id AS VARCHAR) ELSE '' END
	
	EXEC spa_print @sql_stmt
	EXEC(@sql_stmt)
END

ELSE IF @flag='a'
BEGIN
	SET @sql_stmt='
		SELECT csstv.source_sink_name SourceSinkName,
			csstv.source_sink_facility_id FacilityID,	
			csstv.source_sink_type,
			dbo.FNADateFormat(csstv.source_start_date) StartDate,
			csstv.ems_book_id,						
			csstv.ems_source_model_id SourceModelID,
			esm.ems_source_model_name SourceModelName,
			csstv.fas_book_id FasBookID,
			ctpvt.parameter_value Book,
			csstv.registered,
			csstv.technology,
			csstv.fuel_type,
			csstv.jurisdiction,
			csstv.source_sink_unit_id
		FROM company_source_sink_type_value csstv
		INNER JOIN ems_source_model esm ON esm.ems_source_model_id = csstv.ems_source_model_id
		INNER JOIN ems_portfolio_hierarchy eph ON eph.entity_id = csstv.ems_book_id 
		INNER JOIN company_template_parameter_value_tmp ctpvt ON ctpvt.value_id = csstv.fas_book_id
		WHERE 1 = 1 '
		+ CASE WHEN @company_source_sink_type_value_id IS NOT NULL THEN 'AND csstv.company_source_sink_type_value_id='+cast(@company_source_sink_type_value_id as varchar) ELSE '' END
	EXEC(@sql_stmt)
END

Else if @flag='i'

	Begin

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
			EXEC(@sql_stmt)
			
		
		SELECT
			 @sub_id=max(sb)
		FROM
			 #portfolio_hierarcy_tmp  
		WHERE bk=@fas_book_id AND hierarchy_level=0
				


		IF @source_sink_template_id IS NOT NULL ----- if the source/sink template id is passed then insert the values from the remplate.
			BEGIN
				INSERT INTO company_source_sink_type_value(
					source_sink_name,
					source_sink_facility_id,
					source_sink_type,
					source_start_date,
					ems_book_id,
					ems_source_model_id,
					fas_book_id,
					process_id,
					registered,
					technology,
					fuel_type,
					jurisdiction,
					certification_id,
					source_sink_unit_id,
					sub_id
				)

				SELECT	
					source_name,
					facility_id,
					source_or_sink,
					start_date,
					ems_book_id,
					ems_source_model_id,
					@fas_book_id,
					@process_id,
					registered,
					technology,
					fuel_type,
					jurisdiction,
					certification_id,
					unit_id,
					@sub_id
				FROM
					ems_source_sink_template
				WHERE
					source_group_template_id=@source_sink_template_id
					
			END

		ELSE
			BEGIN
				INSERT INTO company_source_sink_type_value(
					source_sink_name,source_sink_facility_id,
					source_sink_type,
					source_start_date,
					ems_book_id,
					ems_source_model_id,
					fas_book_id,
					process_id,
					registered,
					technology,
					fuel_type,
					jurisdiction,
					source_sink_unit_id,
					sub_id
				)
				VALUES(
					@source_sink_name,
					@source_sink_facility_id,
					@source_sink_type,
					@source_start_date,
					@ems_book_id,
					@ems_source_model_id,
					@fas_book_id,
					@process_id,
					@registered,
					@technology,
					@fuel_type,
					@jurisdiction,
					@source_sink_unit_id,
					@sub_id	
				)
			END
	
	SET @gen_id= SCOPE_IDENTITY()

	INSERT INTO ems_company_source_model_effective(
			generator_id,
			ems_source_model_id,
			effective_date
		)
	SELECT
			@gen_id,
			sm1.source_model_id,
			@source_start_date 
	FROM
		(select csstv.company_source_sink_type_value_id GenId,ctsm.source_model_id 
				from company_source_sink_type_value csstv 
				INNER JOIN company_type_source_model ctsm on csstv.ems_source_model_id=ctsm.company_type_source_model_id
					where csstv.company_source_sink_type_value_id=@gen_id)sm1


	If @@ERROR <> 0
		begin
			Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
					"spa_company_source_sink_type_value", "DB Error", 
					"Insert of company_source_sink_type_value  failed.", ''
			return
		end

			else Exec spa_ErrorHandler 0, 'Emissions Wizard Setup', 
					'spa_company_source_sink_type_value', 'Success', 
					'company_source_sink_type_value  successfully inserted.', ''

	End

Else if @flag='u'

Begin
	if @changed='n'
		Begin
		update company_source_sink_type_value set 
													source_sink_name=@source_sink_name,
													source_sink_facility_id=@source_sink_facility_id,
													source_sink_type=@source_sink_type,
													source_start_date=@source_start_date,
													ems_book_id=@ems_book_id,
													ems_source_model_id=@ems_source_model_id,
													fas_book_id=@fas_book_id,
													registered=@registered,
													technology=@technology,
													fuel_type=@fuel_type,
													jurisdiction=@jurisdiction,
													source_sink_unit_id=@source_sink_unit_id
		where company_source_sink_type_value_id=@company_source_sink_type_value_id
      End
	else if @changed='y'
		Begin
			--delete from ems_activity_data_sample_value where generator_id=@company_source_sink_type_value_id 
			update company_source_sink_type_value set 
													source_sink_name=@source_sink_name,
													source_sink_facility_id=@source_sink_facility_id,
													source_sink_type=@source_sink_type,
													source_start_date=@source_start_date,
													ems_book_id=@ems_book_id,
													ems_source_model_id=@ems_source_model_id,
													fas_book_id=@fas_book_id,
													registered=@registered,
													technology=@technology,
													fuel_type=@fuel_type,
													jurisdiction=@jurisdiction,
													source_sink_unit_id=@source_sink_unit_id
		where company_source_sink_type_value_id=@company_source_sink_type_value_id

		End

		If @@ERROR <> 0
			begin
				Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
						"spa_company_source_sink_type_value", "DB Error", 
						"Update of company_source_sink_type_value  failed.", ''
				return
			end

				else Exec spa_ErrorHandler 0, 'Emissions Wizard Setup', 
						'spa_company_source_sink_type_value', 'Success', 
						'company_source_sink_type_value  successfully updated.', ''


End

Else if @flag='d'
Begin
		delete from company_source_sink_type_value where company_source_sink_type_value_id=@company_source_sink_type_value_id

		--Delete data from ems_activity_data_sample_value also
		--delete from ems_activity_data_sample_value where generator_id=@company_source_sink_type_value_id
		
If @@ERROR <> 0
	begin
		Exec spa_ErrorHandler @@ERROR, "Emissions Wizard Setup", 
				"spa_company_source_sink_type_value", "DB Error", 
				"Delete of company_source_sink_type_value  failed.", ''
		return
	end

		else Exec spa_ErrorHandler 0, 'Emissions Wizard Setup', 
				'spa_company_source_sink_type_value', 'Success', 
				'company_source_sink_type_value  successfully deleted.', ''


End