
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_generator]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_source_generator]

GO

CREATE PROCEDURE [dbo].spa_source_generator
@flag CHAR(1),
@source_generator_id INT= NULL,
@generator_id VARCHAR(50)=NULL,
@generator_name VARCHAR(100)=NULL,
@generator_desc VARCHAR(100)=NULL,
@generator_owner VARCHAR(100)=NULL,
@generator_capacity VARCHAR(100)=NULL,
@generator_start_date DATETIME=NULL,
@technology INT=NULL,
@fuel_type INT=NULL,
@facility_address1 VARCHAR(100)=NULL,
@facility_address2 VARCHAR(100)=NULL,
@facility_phone VARCHAR(20)=NULL,
@facility_email_address VARCHAR(20)=NULL,
@facility_country VARCHAR(50)=NULL,
@facility_city VARCHAR(50)=NULL,
@generation_state INT=NULL,
@location_id INT=NULL,
@max_rampup_rate VARCHAR(20)=NULL,
@max_rampdown_rate VARCHAR(20)=NULL,
@upper_operating_limit VARCHAR(20)=NULL,
@lower_operating_limit VARCHAR(20)=NULL,
@max_response_level VARCHAR(20)=NULL,
@max_interrupts VARCHAR(20)=NULL,
@max_dispatch_level VARCHAR(20)=NULL,
@min_dispatch_level VARCHAR(20)=NULL,
@must_run_unit CHAR(1)=NULL,
@generator_group_id INT=NULL,
@uom_id INT =NULL,
@book_id INT =NULL,
@generation_end_date  DATETIME = NULL,
@formula_id INT = NULL,
@technology_sub_type INT = NULL,
@udf_group_1 INT = NULL,
@udf_group_2 INT = NULL,
@udf_group_3 INT = NULL,
@generator_type CHAR = NULL

AS
DECLARE @sql VARCHAR(5000)

IF @flag='s'
BEGIN
	SET @sql='SELECT
			sg.generator_id  
			,sg.id [Generator ID]
			,sg.name [Generator Name]
			,sg.code [Generator Desc]
			,sg.owner [Owner]
			,sg.nameplate_capacity [Capacity]
			,[dbo].FNADateFormat(sg.reduc_start_date) [Start Date]
			,sg.technology [Technology]
			,sdv.code [Technology]
			,sg.fuel_value_id [Fuel Type ID]
			,sdv1.code [Fuel Type] 
			,sg.fac_address [Address1]
			,sg.gen_address1 [Address2]
			,sg.fac_phone [Phone]
			,sg.fac_email [E-mail]
			,sg.f_county [County]
			,sg.city_value_id [City]
			,sg.state_value_id 
			,sdv2.code [Generation State]
			,sg.location_id [Location]
			,sg.generator_group_name [Group]
			,sg.uom 
			,su.uom_id [UOM]
			,sg.fas_book_id 
			,ph.entity_name [Book ID]
			,[dbo].FNADateFormat(sg.reduc_end_date) [End Date]
			,sg.rec_formula_id [Formula ID]
			,sg.reduction_sub_type [Technology Sub Type ID]
			,sdv3.code [Technology Sub Type ID]
			,sg.udf_group1 [UDF Group1]
			,sdv4.code [UDF Group1]
			,sg.udf_group2 [UDF Group2]
			,sdv5.code [UDF Group2]
			,sg.udf_group3 [UDF Group3]
			,sdv6.code [UDF Group3]

	FROM rec_generator sg 
	LEFT JOIN dbo.source_minor_location sml ON sml.source_minor_location_id = sg.location_id
	LEFT JOIN dbo.static_data_value sdv ON sdv.value_id = sg.technology
	LEFT JOIN dbo.static_data_value sdv1 ON sdv1.value_id = sg.fuel_value_id
	LEFT JOIN dbo.static_data_value sdv2 ON sdv2.value_id = sg.state_value_id
	LEFT JOIN dbo.static_data_value sdv3 ON sdv3.value_id = sg.reduction_sub_type
	LEFT JOIN dbo.static_data_value sdv4 ON sdv4.value_id = sg.udf_group1
	LEFT JOIN dbo.static_data_value sdv5 ON sdv5.value_id = sg.udf_group2
	LEFT JOIN dbo.static_data_value sdv6 ON sdv6.value_id = sg.udf_group3
	LEFT JOIN dbo.source_uom su ON su.source_uom_id = sg.uom
	LEFT JOIN portfolio_hierarchy ph ON ph.entity_id = sg.fas_book_id
	LEFT  JOIN formula_editor fe ON fe.formula_id = sg.rec_formula_id
	WHERE 1=1 AND sg.generator_type = ''s'''
	
	IF @generator_id IS NOT NULL 
	SET @sql = @sql +' AND sg.generator_id='''+@generator_id+''''
	
	IF @generator_name IS NOT NULL 
	SET @sql = @sql +' AND sg.name='''+@generator_name+''''
	
	IF @book_id IS NOT NULL 
	SET @sql = @sql +'AND sg.fas_book_id='+ CAST(@book_id AS VARCHAR)
	
	EXECUTE(@sql)
END

ELSE IF @flag='a'
BEGIN
	SELECT	sg.id
			,sg.name
			,sg.code
			,sg.owner
			,sg.nameplate_capacity
			,[dbo].FNADateFormat(sg.reduc_start_date)
			,sg.technology
			,sg.fuel_value_id
			,sg.fac_address
			,sg.gen_address1
			,sg.fac_phone
			,sg.fac_email
			,sg.f_county
			,sg.city_value_id
			,sg.state_value_id
			,sg.location_id
			,sg.generator_group_name
			,sg.uom
			,sg.fas_book_id
			,[dbo].FNADateFormat(sg.reduc_end_date)
			,sg.rec_formula_id
			,case fe.formula_type when  'n' then 'Nested Formula' else [dbo].[FNAFormulaFormat](fe.formula,'r') end [Formula]
			,fe.formula_type
			,sg.reduction_sub_type
			,sg.udf_group1
			,sg.udf_group2
			,sg.udf_group3
			
	FROM rec_generator sg
	LEFT  JOIN formula_editor fe ON fe.formula_id = sg.rec_formula_id
	WHERE generator_id = @source_generator_id
END

ELSE IF @flag='i'
BEGIN
	INSERT INTO rec_generator(
					 id
					,name
					,code
					,owner
					,nameplate_capacity
					,reduc_start_date
					,technology
					,fuel_value_id
					,fac_address
					,gen_address1
					,fac_phone
					,fac_email
					,f_county
					,city_value_id
					,state_value_id
					,location_id
					,generator_group_name
					,uom
					,fas_book_id
					,reduc_end_date
					,rec_formula_id
					,reduction_sub_type
					,udf_group1
					,udf_group2
					,udf_group3
					,generator_type
					,registered
				)VALUES(
					@generator_id
					,@generator_name
					,@generator_desc
					,@generator_owner
					,@generator_capacity
					,@generator_start_date
					,@technology
					,@fuel_type
					,@facility_address1
					,@facility_address2
					,@facility_phone
					,@facility_email_address
					,@facility_country
					,@facility_city
					,@generation_state
					,@location_id
					,@generator_group_id
					,@uom_id 
					,@book_id 
					,@generation_end_date
					,@formula_id
					,@technology_sub_type
					,@udf_group_1
					,@udf_group_2
					,@udf_group_3
					,@generator_type
					,'n'
				)

				set @source_generator_id = scope_identity()
				if @@Error <> 0
						Exec spa_ErrorHandler @@Error, 'rec_generator', 
								'spa_source_generator', 'DB Error', 
								'Failed to insert source generator.', ''
						Else
						Exec spa_ErrorHandler 0, 'rec_generator', 
								'spa_source_generator', 'Success', 
								'source generator inserted successfully.', @source_generator_id

END

ELSE IF @flag='u'
BEGIN
	UPDATE rec_generator SET
					id = @generator_id
					,name = @generator_name
					,code = @generator_desc
					,owner = @generator_owner
					,nameplate_capacity = @generator_capacity
					,reduc_start_date = @generator_start_date
					,technology = @technology
					,fuel_value_id = @fuel_type
					,fac_address = @facility_address1
					,gen_address1 = @facility_address2
					,fac_phone = @facility_phone
					,fac_email = @facility_email_address
					,f_county = @facility_country
					,city_value_id = @facility_city
					,state_value_id = @generation_state
					,location_id = @location_id
					,generator_group_name = @generator_group_id
					,uom = @uom_id 
					,fas_book_id = @book_id 
					,reduc_end_date = @generation_end_date
					,rec_formula_id = @formula_id
					,reduction_sub_type = @technology_sub_type
					,udf_group1 = @udf_group_1
					,udf_group2 = @udf_group_2
					,udf_group3 = @udf_group_3
																			
		WHERE generator_id = @source_generator_id	
							
			if @@Error <> 0
			Exec spa_ErrorHandler @@Error, 'rec_generator', 
					'spa_source_generator', 'DB Error', 
					'Failed to update source generator.', ''
			Else
			Exec spa_ErrorHandler 0, 'rec_generator', 
					'spa_source_generator', 'Success', 
					'source generator updated successfully.', ''
END

ELSE IF @flag='d'
BEGIN
	IF EXISTS (SELECT 1 FROM power_outage WHERE source_generator_id=@source_generator_id)
		BEGIN
			if @@Error <> 0
			Exec spa_ErrorHandler @@Error, 'source_generator', 
					'spa_source_generator', 'DB Error', 
					'Failed to delete source generator.', ''
			Else
			Exec spa_ErrorHandler -1, '', 
					'', '', 
					'The selected data is in use.', ''
		END
	ELSE
		BEGIN
			DELETE FROM rec_generator WHERE generator_id = @source_generator_id
			EXEC spa_maintain_udf_header 'd', NULL, @source_generator_id
			
			if @@Error <> 0
					Exec spa_ErrorHandler @@Error, 'source_generator', 
							'spa_source_generator', 'DB Error', 
							'Failed to delete source generator.', ''
					Else
					Exec spa_ErrorHandler 0, 'source_generator', 
							'spa_source_generator', 'Success', 
							'source generator deleted successfully.', ''
		END
END
