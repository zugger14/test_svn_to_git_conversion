IF OBJECT_ID(N'[dbo].[spa_ComplianceJurisdiction]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ComplianceJurisdiction]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Used to insert, update and delete value from static_data_value, state_properties and state_properties_detail tables from Jurisdiction/Market menu.

	Parameters
	@flag : Operational Flag
			- 'i' to insert the data
			- 'u' to update the data
			- 'd' to delete the data
	@value_id : value_id from static_data_value to delete the data.
	@form_xml : Form  value in XML form.
	@grid_xml : Grid value in XML form.
	@del_xml : Value to be deleted in XML form.
*/

CREATE PROCEDURE [dbo].[spa_ComplianceJurisdiction]
	@flag CHAR(1),
	@value_id VARCHAR(1000) = NULL, 
	@form_xml VARCHAR(MAX) = NULL,
	@grid_xml VARCHAR(MAX) = NULL, 
	@del_xml VARCHAR(MAX) = NULL
AS

/* Debug mode

DECLARE @flag CHAR(1),
	@value_id VARCHAR(1000) = NULL, 
	@form_xml VARCHAR(MAX) = NULL,
	@grid_xml VARCHAR(MAX) = NULL,
	@del_xml VARCHAR(MAX) = NULL
SELECT @flag = 'u'
, @form_xml = '<Root><FormXML  state_value_id="50000213" code="WV" description="West Virginia" region_id="50000204" label_region_id="PJM" begin_date="" program_scope="" detail="n" calendar_from_month="4" calendar_to_month="3" current_next_year="c" type_id = "10002"></FormXML></Root>'
, @grid_xml = '<Root><GridGroup><Grid grid_id="tier_mapping"><GridRow  state_properties_details_id="1979" value_id="50000213" tier_id="50000218" technology_id="50000021" technology_subtype_id="50002695" price_index="7611" effective_date="2020-09-21" banking_years="9" ></GridRow> </Grid></GridGroup></Root>'


--*/

SET NOCOUNT ON

IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DELETE rge
			FROM rec_gen_eligibility rge
			INNER JOIN dbo.FNASplit(@value_id, ',') di ON di.item = rge.state_value_id

			DELETE emtd
			FROM eligibility_mapping_template_detail emtd
			INNER JOIN dbo.FNASplit(@value_id, ',') di ON di.item = emtd.state_value_id

			DELETE spd
			FROM state_properties_details spd
			INNER JOIN dbo.FNASplit(@value_id, ',') di ON di.item = spd.state_value_id

			DELETE sp
			FROM state_properties sp
			INNER JOIN dbo.FNASplit(@value_id, ',') di ON di.item = sp.state_value_id

			DELETE sdv
			FROM static_data_value sdv
			INNER JOIN dbo.FNASplit(@value_id, ',') di ON di.item = sdv.value_id
		
		COMMIT TRAN
		
		EXEC spa_ErrorHandler 0,
			'Compliance Jurisdiction',
			'spa_ComplianceJurisdiction',
			'Success',
			'Data deleted successfully.',
			@value_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

		DECLARE @err_msg VARCHAR(MAX) = ERROR_MESSAGE()

		EXEC spa_ErrorHandler @@ERROR,
			'Compliance Jurisdiction',
			'spa_ComplianceJurisdiction',
			'DB Error',
			@err_msg,
			''
	END CATCH
END

ELSE IF @flag IN ('i', 'u')
BEGIN
	DECLARE @idoc_form INT

	IF OBJECT_ID(N'tempdb..#temp_general_form') IS NOT NULL 
		DROP TABLE #temp_general_form
	
	EXEC sp_xml_preparedocument @idoc_form OUTPUT, @form_xml		

	SELECT NULLIF(state_value_id,'') state_value_id,
		[type_id],
		code,
		[description],
		NULLIF(region_id, '') region_id,
		NULLIF(begin_date, '') begin_date,
		NULLIF(program_scope, '') program_scope,
		detail,
		NULLIF(calendar_from_month, '') calendar_from_month,
		NULLIF(calendar_to_month, '') calendar_to_month,
		NULLIF(current_next_year, '') current_next_year
	INTO #temp_general_form
	FROM   OPENXML(@idoc_form, 'Root/FormXML', 1)
	WITH (
		state_value_id INT '@state_value_id',
		[type_id] INT '@type_id',
		code VARCHAR(500) '@code',
		[description] VARCHAR(500) '@description',
		region_id VARCHAR(MAX) '@region_id',
		begin_date DATE '@begin_date',
		program_scope INT '@program_scope',
		detail CHAR(1) '@detail',
		calendar_from_month INT '@calendar_from_month',
		calendar_to_month INT '@calendar_to_month',
		current_next_year CHAR(1) '@current_next_year'
	)

	

	DECLARE @code VARCHAR(500) = NULL
	DECLARE @type_id INT = NULL
	DECLARE @state_value_id INT = NULL

	SELECT @state_value_id = state_value_id, @code = code, @type_id = [type_id] from #temp_general_form
	
	IF (@flag = 'i')
	BEGIN
		-- Check dublicate code while inserting
		IF EXISTS(	SELECT 1 FROM dbo.static_data_value  
					WHERE code = @code AND [type_id] = @type_id 
		)
		BEGIN
			EXEC spa_ErrorHandler -1
				, 'compliance_jurisdiction'
				, 'spa_save_custom_form_data'
				, 'DB ERROR'
				, 'Duplicate data in (<b>Code</b> and <b>Data Type</b>).'
				, ''
		END
		ELSE 
		BEGIN -- insert into static_data_value and state_properties table.
			DECLARE @state_value_id_insert INT = NULL
			INSERT INTO static_data_value (type_id, code, description)
			SELECT [type_id], code, [description] from #temp_general_form

			SET @state_value_id_insert  = SCOPE_IDENTITY()

			INSERT INTO state_properties (state_value_id, region_id, begin_date, program_scope, detail, calendar_from_month, calendar_to_month, current_next_year)
			SELECT @state_value_id_insert,region_id, begin_date, program_scope, detail, calendar_from_month, calendar_to_month, current_next_year from #temp_general_form

			EXEC spa_ErrorHandler 0
			, 'compliance_jurisdiction'
			, 'spa_save_custom_form_data'
			, 'Success'
			, 'Changes have been saved successfully.'
			, @state_value_id_insert
		END
	END
	ELSE IF @flag = 'u'
	BEGIN  
		DECLARE @state_properties_details_ids VARCHAR(MAX)
		DECLARE @value_ids VARCHAR(MAX)
		DECLARE @tier_ids VARCHAR(MAX)
		DECLARE @state_rec_requirement_data_ids VARCHAR(MAX)

		IF OBJECT_ID(N'tempdb..#temp_del_grid') IS NOT NULL 
				DROP TABLE #temp_del_grid

		CREATE TABLE #temp_del_grid(
			state_properties_details_id INT,
			value_id INT,
			tier_id INT
		)

		IF OBJECT_ID(N'tempdb..#temp_del_grid_requirement') IS NOT NULL 
			DROP TABLE #temp_del_grid_requirement
		
		CREATE TABLE #temp_del_grid_requirement(
			state_rec_requirement_data_id INT,
			state_value_id INT,
			assignment_priority VARCHAR(2000) COLLATE DATABASE_DEFAULT
		)

		
		IF OBJECT_ID(N'tempdb..#temp_general_grid') IS NOT NULL 
			DROP TABLE #temp_general_grid

		CREATE TABLE #temp_general_grid(
			state_properties_details_id INT,
			value_id INT,
			tier_id INT,
			technology_id INT,
			technology_subtype_id INT,
			price_index INT,
			banking_years INT,
			effective_date DATE
		)

		IF EXISTS(	SELECT 1 FROM dbo.static_data_value  
					WHERE code = @code AND [type_id] = @type_id AND value_id <> @state_value_id
		) --Check the dublicate code name while updating
		BEGIN
			EXEC spa_ErrorHandler -1
				, 'compliance_jurisdiction'
				, 'spa_save_custom_form_data'
				, 'DB ERROR'
				, 'Duplicate data in <b>(Code</b> and <b>Data type).</b>'
				, ''
				
				RETURN;
		END

		-- @del_xml has the data of deleted row from tier mapping grid.
		IF (@del_xml = '<Root></Root>')
			SET @del_xml = ''

		IF (@del_xml <> '')  -- check the dependent data before deleting value from grid
		BEGIN
			DECLARE @idoc_grid_del INT
	
			EXEC sp_xml_preparedocument @idoc_grid_del OUTPUT, @del_xml

			INSERT INTO #temp_del_grid
			SELECT NULLIF(state_properties_details_id, '') state_properties_details_id,
			NULLIF (value_id, '') value_id,
			NULLIF(tier_id, '') tier_id
			FROM OPENXML(@idoc_grid_del, 'Root/GridDelete[@grid_id="tier_mapping"]/GridRow', 1)
			WITH (
				state_properties_details_id INT '@state_properties_details_id',
				value_id					INT '@value_id',
				tier_id						INT	'@tier_id'
			)  
			
			INSERT INTO #temp_del_grid_requirement
			SELECT NULLIF(state_rec_requirement_data_id, '') state_rec_requirement_data_id,
			NULLIF (state_value_id, '') state_value_id,
			NULLIF(assignment_priority, '') assignment_priority
			FROM OPENXML(@idoc_grid_del, 'Root/GridDelete[@grid_id = "state_rec_requirement_data"]/GridRow', 1)
			WITH (
				state_rec_requirement_data_id INT '@state_rec_requirement_data_id',
				state_value_id					INT '@state_value_id',
				assignment_priority						VARCHAR(2000)	'@assignment_priority'
			) 

			
			IF EXISTS (SELECT 1 FROM #temp_del_grid) --check the dependency in tier mapping grid.
			BEGIN
				SELECT @state_properties_details_ids = STUFF( (SELECT ', '+ CAST(state_properties_details_id AS VARCHAR(2000))
							  FROM #temp_del_grid 
							  FOR XML PATH('')
							 ), 1, 1, '')
			

				SELECT @tier_ids = STUFF( (SELECT ', '+ CAST(tier_id AS VARCHAR(2000))
							  FROM #temp_del_grid 
							  FOR XML PATH('')
							 ), 1, 1, '')
			

				SELECT @value_ids = STUFF( (SELECT ', '+ CAST(value_id AS VARCHAR(2000))
							  FROM #temp_del_grid 
							  FOR XML PATH('')
							 ), 1, 1, '')
			
				
				IF EXISTS ( SELECT 1 FROM state_properties_details spd
				INNER JOIN eligibility_mapping_template_detail emtd
					ON emtd.state_value_id = spd.state_value_id 
				INNER JOIN dbo.SplitCommaSeperatedValues(@tier_ids) a
					ON cast(emtd.tier_id AS VARCHAR) = a.item
				INNER JOIN dbo.SplitCommaSeperatedValues(@value_ids) b
					ON cast(emtd.state_value_id AS VARCHAR) = b.item ) -- Check if the dependent data is deleted from the grid.
				BEGIN 
					EXEC spa_ErrorHandler -1,
					'Save Custom Grid data'
					, 'spa_save_custom_form_data'
					, 'Error'
					, 'Please Delete Data from <b>Eligibility Mapping Grid</b> first.'
					, 'Dependency'

					RETURN;
				END
			END

			IF EXISTS (SELECT 1 FROM #temp_del_grid_requirement) -- check the dependency in requirement grid.
			BEGIN
				SELECT @state_rec_requirement_data_ids = STUFF( (SELECT ', '+ CAST(state_rec_requirement_data_id AS VARCHAR(2000))
							  FROM #temp_del_grid_requirement 
							  FOR XML PATH('')
							 ), 1, 1, '')
							
				IF EXISTS (SELECT 1 FROM state_rec_requirement_data srrd
							INNER JOIN state_rec_requirement_detail srrdt  ON  srrd.state_value_id = srrdt.state_value_id 
								AND srrd.state_rec_requirement_data_id = srrdt.state_rec_requirement_data_id
							INNER JOIN dbo.SplitCommaSeperatedValues(@state_rec_requirement_data_ids) a
												ON srrdt.state_rec_requirement_data_id = a.item)
				BEGIN
					EXEC spa_ErrorHandler -1,
					'Save Custom Grid data'
					, 'spa_save_custom_form_data'
					, 'Error'
					, 'Please Delete Data from <b>Requirement Data Grid</b> first.'
					, 'Dependency'

					RETURN;
				END
			END
		END

		--- @grid_xml has the updated and newly inserted data from the tier mapping grid.
		IF (@grid_xml = '<Root><GridGroup></GridGroup></Root>')
			SET @grid_xml = ''

		IF (@grid_xml <> '')
		BEGIN
			DECLARE @idoc_grid INT
	
			EXEC sp_xml_preparedocument @idoc_grid OUTPUT, @grid_xml
			
			INSERT INTO #temp_general_grid
			SELECT NULLIF(state_properties_details_id, '') state_properties_details_id,
			NULLIF (value_id, '') value_id,
			NULLIF(tier_id, '') tier_id,
			NULLIF(technology_id, '') technology_id,
			NULLIF(technology_subtype_id, '') technology_subtype_id,
			NULLIF([price_index], '') [price_index],
			NULLIF([banking_years], '') [banking_years],
			NULLIF([effective_date],'') [effective_date]
			FROM OPENXML(@idoc_grid, 'Root/GridGroup/Grid/GridRow', 1)
			WITH (
				state_properties_details_id INT '@state_properties_details_id',
				value_id					INT '@value_id',
				tier_id						INT	'@tier_id',
				technology_id				INT	'@technology_id',
				technology_subtype_id		INT	'@technology_subtype_id',
				price_index					INT	'@price_index',
				banking_years				INT	'@banking_years',
				effective_date				DATE '@effective_date'
			)

			---- Check for dublicate data inserted into grid------
			DECLARE @distinct INT, @all INT, @table_value_count INT
			SET @distinct = (
				SELECT COUNT(*) FROM 
				(
					SELECT DISTINCT tier_id
						, technology_id
						, technology_subtype_id
						, price_index
						, effective_date
					FROM #temp_general_grid
				) T
			)
			SET @all = (
				SELECT COUNT(*) FROM #temp_general_grid
			)
			
			SET @table_value_count = (
				 SELECT count(*) FROM #temp_general_grid tgd 
					INNER JOIN  state_properties_details spd ON spd.state_value_id = @state_value_id 
						AND spd.tier_id = tgd.tier_id 
						AND spd.technology_id = tgd.technology_id
						AND ISNULL(spd.technology_subtype_id, '') = ISNULL(tgd.technology_subtype_id, '')
						AND ISNULL(spd.price_index, '') = ISNULL(tgd.price_index, '')
						AND ISNULL(spd.effective_date, '') = ISNULL(tgd.effective_date, '')
						WHERE tgd.state_properties_details_id IS NULL

			)

			
			IF @distinct <> @all OR @table_value_count <> 0
			BEGIN
				EXEC spa_ErrorHandler -1,
					'Save Custom grid data'
					, 'spa_save_custom_form_data'
					, 'Error'
					, 'Duplicate Data in <b>(Tier, Technology, Technology Sub Type, Price Index and Effective Date)</b> in <b>Tier Mapping</b> grid.'
					, ''
				RETURN
			END
		END

		BEGIN TRY
			BEGIN TRAN
				IF EXISTS (SELECT 1 FROM #temp_general_grid)
				BEGIN -- insert the new data and update the old data form tiew mapping grid.
					INSERT INTO state_properties_details(state_value_id, tier_id, technology_id, technology_subtype_id, price_index, banking_years, effective_date )
					SELECT @state_value_id, tier_id, technology_id, technology_subtype_id, price_index, banking_years, effective_date FROM #temp_general_grid
					WHERE state_properties_details_id IS NULL AND value_id IS NULL

					UPDATE spd
						SET spd.tier_id = tgg.tier_id,
							spd.technology_id = tgg.technology_id,
							spd.technology_subtype_id = tgg.technology_subtype_id,
							spd.price_index = tgg.price_index,
							spd.banking_years = tgg.banking_years,
							spd.effective_date = tgg.effective_date
					FROM #temp_general_grid tgg 
					INNER JOIN state_properties_details spd ON spd.state_properties_details_id = tgg.state_properties_details_id
						AND tgg.value_id = spd.state_value_id
				END

				IF EXISTS (SELECT 1 FROM #temp_del_grid) -- delete the data from tier mapping grid
				BEGIN
					DELETE spd FROM state_properties_details spd 
					INNER JOIN dbo.SplitCommaSeperatedValues(@value_ids) c
						ON CAST(spd.state_value_id AS VARCHAR(20)) = c.item 
					INNER JOIN dbo.SplitCommaSeperatedValues(@state_properties_details_ids) d
						ON CAST(spd.state_properties_details_id AS VARCHAR(20)) = d.item
				END

				IF EXISTS (SELECT 1 FROM #temp_del_grid_requirement) -- delete the data from requirement grid
				BEGIN
					DELETE srrd FROM state_rec_requirement_data srrd
					INNER JOIN dbo.SplitCommaSeperatedValues(@state_rec_requirement_data_ids) a
										ON srrd.state_rec_requirement_data_id = a.item
				END

				 -- Update the value in static_data_value and state_properties form Jurisdiction/Market Menu.
				UPDATE sdv
					SET sdv.code = tgf.code,
						sdv.[description] = tgf.[description]
				FROM #temp_general_form tgf
				INNER JOIN static_data_value sdv ON sdv.value_id = tgf.state_value_id

				UPDATE sp
					SET sp.region_id = tgf.region_id, 
						sp.begin_date = tgf.begin_date, 
						sp.program_scope = tgf.program_scope, 
						sp.detail = tgf.detail, 
						sp.calendar_from_month = tgf.calendar_from_month, 
						sp.calendar_to_month = tgf.calendar_to_month, 
						sp.current_next_year = tgf.current_next_year
				FROM #temp_general_form tgf 
				INNER JOIN state_properties sp ON sp.state_value_id = tgf.state_value_id

			COMMIT TRAN
			EXEC spa_ErrorHandler 0
				, 'compliance_jurisdiction'
				, 'spa_save_custom_form_data'
				, 'Success'
				, 'Changes have been saved successfully.'
				, @state_value_id
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
			   ROLLBACK

		    DECLARE @error_msg VARCHAR(MAX);
			SET @error_msg = ERROR_MESSAGE();

			EXEC spa_ErrorHandler -1,
				 'compliance_jurisdiction',
				 'spa_save_custom_form_data',
				 'Error',
				 @error_msg,
				 ''
		END CATCH
	END
 END



 

			


		


