IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[spa_rec_generator]') AND [type] IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_rec_generator]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/**
	Used for CRUD operation of renewable resources form.
	Parameters
	@flag								:	Operation Flag (s = list Generator according to filter, a = list a Generator, i = insert, u = update, d = delete, c = copy, z = dropdown, m = Browser Sql for Import parameter)
	@generator_id						:	Id of Generator
	@generator_group_name				:	Group Name of Generator
	@tier_type_p						:	Tier Type of Generator 
	@technology_p						:	Techonology of Generator
	@fuel_value_id_p					:	Fuel Type of Generator
	@classification_value_id_p			:	Technology Sub type of Generator
	@source_curve_def_id_p				:	Curve Id of Generator
	@state_value_id_p					:	Jurisdiction of Generator
	@counterparty_id_p					:	Counterparty Id
	@contract_id_p						:	Contract Id
	@legal_entity_value_id				:	Company Name
	@form_xml							:	Form XML
	@grid_xml							:	Grid XML
	@fas_book_id						:	Book Id
	@meter_id							:	Meter Id
	@recorder_generator_map_id			:	Recorder Map Id
	@eligibility_mapping_template_id_p	:   Eligibility Mapping Template
	@fas_sub_book_id_p					:	Sub Book Id
	@del_generator_ids					:	Comma separated Generator Id for delete operation
	@xml 								:	Filter value in xml form.
	@delete_xml							:	Meter ID gird delete value in xml.
*/

CREATE PROCEDURE [dbo].[spa_rec_generator] 
	@flag CHAR(1) = NULL,
	@generator_id VARCHAR(100) = NULL,
	@generator_group_name INT = NULL,
	@tier_type_p INT = NULL,
	@technology_p INT = NULL,
	@fuel_value_id_p INT = NULL,
	@classification_value_id_p INT = NULL,
	@source_curve_def_id_p INT = NULL,
	@state_value_id_p INT = NULL,
	@counterparty_id_p INT = NULL,
	@contract_id_p INT = NULL,
	@legal_entity_value_id VARCHAR(MAX) = NULL,
	@form_xml VARCHAR(MAX) = NULL,
	@grid_xml VARCHAR(MAX) = NULL,
	@fas_book_id VARCHAR(MAX) = NULL,
	@meter_id VARCHAR(100) = NULL,
	@recorder_generator_map_id INT = NULL,
	@eligibility_mapping_template_id_p INT = NULL,
	@fas_sub_book_id_p VARCHAR(MAX) = NULL,
	@del_generator_ids VARCHAR(MAX) = NULL,
	@xml xml = NULL,
	@delete_xml VARCHAR(MAX) = NULL
	
AS

/* * DEBUG QUERY START *

	DECLARE 
	@flag CHAR(1) = NULL,
	@generator_id VARCHAR(100) = NULL,
	@generator_group_name INT = NULL,
	@tier_type_p INT = NULL,
	@technology_p INT = NULL,
	@fuel_value_id_p INT = NULL,
	@classification_value_id_p INT = NULL,
	@source_curve_def_id_p INT = NULL,
	@state_value_id_p INT = NULL,
	@counterparty_id_p INT = NULL,
	@contract_id_p INT = NULL,
	@legal_entity_value_id VARCHAR(MAX) = NULL,
	@form_xml VARCHAR(MAX) = NULL,
	@grid_xml VARCHAR(MAX) = NULL,
	@fas_book_id VARCHAR(MAX) = NULL,
	@meter_id VARCHAR(100) = NULL,
	@recorder_generator_map_id INT = NULL,
	@eligibility_mapping_template_id_p INT = NULL,
	@fas_sub_book_id_p VARCHAR(MAX) = NULL,
	--@desc varchar(max) = NULL,
	@del_generator_ids VARCHAR(MAX) = NULL,
	@xml xml = NULL,
	@delete_xml VARCHAR(MAX) = NULL

		
	SELECT @flag='i',@form_xml='<Root function_id="12101700"><FormXML first_gen_date="2018-12-17" code="test" id="test" owner="test" name="test" gen_state_value_id="50000046" fuel_value_id="50000294" technology="50000019" eligibility_mapping_template_id="9" show_detail="y" registered="n" registration_date="" ppa_effective_date="" ppa_expiration_date="" ppa="n" auto_certificate_number="n" exclude_inventory="n" ></FormXML></Root>',@grid_xml=NULL
-- * DEBUG QUERY END * */

SET NOCOUNT ON

DECLARE @sql_str VARCHAR(MAX)

IF @fas_sub_book_id_p = ''
	SET @fas_sub_book_id_p = NULL

IF @flag = 's'
BEGIN	

	IF OBJECT_ID('tempdb..#filter_xml') IS NOT NULL
		DROP TABLE #filter_xml

	CREATE TABLE #filter_xml(
		subsidiary_id INT,
		source_group INT,
		eligibility_mapping_template INT,
		book_structure VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		technology INT,
		fuel_type INT,
		classification_value_id INT,
		source_curve_def_id INT,
		counterparty_id INT,
		contract_id INT
	)

	DECLARE @idoc_filter_xml INT
	EXEC sp_xml_preparedocument @idoc_filter_xml OUTPUT, @xml

	INSERT INTO #filter_xml
	SELECT *
	FROM OPENXML(@idoc_filter_xml, 'FormXML', 1)
	WITH #filter_xml

	SELECT @fas_sub_book_id_p = COALESCE(LTRIM(CAST(('<X>'+REPLACE(book_structure,'||' ,'</X><X>')+'</X>') AS XML).value('(/X)[3]', 'varchar(100)')), '')  
	FROM #filter_xml

	SELECT 
	@legal_entity_value_id = subsidiary_id,
	@generator_group_name = source_group,
	@eligibility_mapping_template_id_p = eligibility_mapping_template,
	@technology_p = technology,
	@fuel_value_id_p = fuel_type,
	@classification_value_id_p = classification_value_id,
	@source_curve_def_id_p = source_curve_def_id,
	@counterparty_id_p = counterparty_id,
	@contract_id_p = contract_id 
	FROM #filter_xml



	SET @sql_str = '
		SELECT
			rg.generator_id,
			rg.name [source],
			rg.ID [external_facility_id],
			rg.code [unit],
			ph1.entity_name [op_company],
			ph2.entity_name [business_unit],
			city_value_id [city],
			sd1.code [state],
			rg.f_county [country],
			sd6.code [fuel],
			sd.code [technology],
			sd5.code [technology_sub_type],
			dbo.FNADateFormat(rg.first_gen_date) [start_date],
			sd3.code [generation_state],
			sd7.code [tier_type]
		FROM rec_generator rg
		LEFT JOIN static_data_value sd
			ON sd.value_id = rg.technology
		LEFT JOIN static_data_value sd1
			ON sd1.value_id = rg.state_value_id
		LEFT JOIN static_data_value sd2
			ON sd2.value_id = rg.gis_value_id
		LEFT JOIN static_data_value sd3
			ON sd3.value_id = rg.gen_state_value_id
		LEFT JOIN static_data_value sd4
			ON sd4.value_id = rg.country_id
		LEFT JOIN static_data_value sd5
			ON sd5.value_id = rg.classification_value_id
		LEFT JOIN static_data_value sd6
			ON sd6.value_id = rg.fuel_value_id
		LEFT JOIN static_data_value sd7
			ON sd7.value_id = rg.tier_type
		LEFT JOIN portfolio_hierarchy ph1
			ON ph1.entity_id = rg.legal_entity_value_id
				AND ph1.hierarchy_level = 2
		LEFT JOIN portfolio_hierarchy ph2
			ON ph2.entity_id = rg.fas_book_id
				AND ph2.hierarchy_level = 0
		LEFT JOIN source_counterparty sc
			ON sc.source_counterparty_id = rg.ppa_counterparty_id
		LEFT JOIN rec_generator_group rgg
			ON rgg.generator_group_id = rg.generator_group_name
		' +
		CASE WHEN NULLIF(@fas_sub_book_id_p,'') IS NOT NULL THEN '
		LEFT JOIN source_system_book_map ssbm
			ON rg.fas_book_id = ssbm.fas_book_id 
		INNER JOIN dbo.FNASplit(''' + @fas_sub_book_id_p + ''', '','') i
			ON i.item = ssbm.logical_name ' ELSE ''
		END + '
		WHERE 1 = 1'

	IF NULLIF(@legal_entity_value_id, '') IS NOT NULL
	BEGIN
		SET @sql_str = @sql_str + ' AND rg.legal_entity_value_id IN (' + @legal_entity_value_id + ')'
	END

	IF NULLIF(@generator_group_name, '') IS NOT NULL
	BEGIN
		SET @sql_str = @sql_str + ' AND rg.generator_group_name IN (' + CAST(@generator_group_name AS VARCHAR(10)) + ')'
	END

	IF NULLIF(@fas_book_id, '') IS NOT NULL
	BEGIN
		SET @sql_str = @sql_str + ' AND rg.fas_book_id IN (' + @fas_book_id + ')'
	END
	
	IF NULLIF(@tier_type_p, '') IS NOT NULL
	BEGIN
		SET @sql_str = @sql_str + ' AND rg.tier_type IN (' + CAST(@tier_type_p AS VARCHAR(20)) + ')'
	END
	
	IF NULLIF(@technology_p, '') IS NOT NULL
	BEGIN
		SET @sql_str = @sql_str + ' AND sd.value_id IN (' + CAST(@technology_p AS VARCHAR(20)) + ')'
	END
	
	IF NULLIF(@fuel_value_id_p, '') IS NOT NULL
	BEGIN
		SET @sql_str = @sql_str + ' AND sd6.value_id IN (' + CAST(@fuel_value_id_p AS VARCHAR(20)) + ')'
	END
	
	IF NULLIF(@classification_value_id_p, '') IS NOT NULL
	BEGIN
		SET @sql_str = @sql_str + ' AND sd5.value_id IN (' + CAST(@classification_value_id_p AS VARCHAR(20)) + ')'
	END
	
	IF NULLIF(@source_curve_def_id_p, '') IS NOT NULL
	BEGIN
		SET @sql_str = @sql_str + ' AND rg.source_curve_def_id IN (' + CAST(@source_curve_def_id_p AS VARCHAR(20)) + ')'
	END
	
	IF NULLIF(@state_value_id_p, '') IS NOT NULL
	BEGIN
		SET @sql_str = @sql_str + ' AND rg.state_value_id IN (' + CAST(@state_value_id_p AS VARCHAR(20)) + ')'
	END
	
	IF NULLIF(@counterparty_id_p, '') IS NOT NULL
	BEGIN
		SET @sql_str = @sql_str + ' AND sc.source_counterparty_id IN (' + CAST(@counterparty_id_p AS VARCHAR(20)) + ')'
	END
	
	IF NULLIF(@contract_id_p, '') IS NOT NULL
	BEGIN
		SET @sql_str = @sql_str + ' AND rg.ppa_contract_id IN (' + CAST(@contract_id_p AS VARCHAR(20)) + ')'
	END

	IF NULLIF(@eligibility_mapping_template_id_p, '') IS NOT NULL
	BEGIN
		SET @sql_str = @sql_str + ' AND rg.eligibility_mapping_template_id = ' + CAST(@eligibility_mapping_template_id_p AS VARCHAR(20)) + ''
	END

	SET @sql_str = @sql_str + ' ORDER BY rg.name'

	EXEC (@sql_str)
END
IF @flag = 'a'
BEGIN
	SELECT
		rg.generator_id,
		code,
		name,
		id,
		owner,
		classification_value_id,
		technology,
		first_gen_date,
		city_value_id,
		state_value_id,
		registered,
		gis_value_id,
		registration_date,
		gis_id_number,
		mandatory,
		legal_entity_value_id,
		early_banking_mwh,
		early_banking_expiration,
		gen_offset_technology,
		administrator_name,
		contact_user_login_id,
		source_curve_def_id,
		id2,
		ppa,
		ppa_counterparty_id,
		ppa_effective_date,
		ppa_expiration_date,
		utility_interconnect,
		control_area_operator,
		operator_user_login_id,
		nameplate_capacity,
		facility_name,
		gis_account_number,
		aggregate_environment,
		aggregate_envrionment_comment,
		rec_price,
		rec_formula_id,
		rec_uom_id,
		contract_price,
		contract_formula_id,
		contract_uom_id,
		gen_state_value_id,
		gen_address1,
		gen_address2,
		gen_address3,
		rg.auto_assignment_type,
		rg.auto_assignment_per,
		auto_certificate_number,
		rg.exclude_inventory,
		ppa_contract_id,
		contract_allocation,
		generator_group_name,
		tot_units,
		fuel_value_id,
		r_address,
		r_phone,
		r_email,
		r_url,
		c_address,
		c_phone,
		c_email,
		f_county,
		exp_annual_cap_factor,
		add_capacity_added,
		fac_contact_person,
		fac_address,
		fac_phone,
		fac_fax,
		fac_email,
		udf_group1,
		udf_group2,
		udf_group3,
		tier_type,
		reporting_fax,
		fac_address_2,
		fac_city,
		fa_zip,
		fac_zip,
		fac_state,
		REPLACE(fe.formula, 'dbo.FNA', '') rec_formula_name,
		REPLACE(fe1.formula, 'dbo.FNA', '') contract_formula_name,
		rg.fas_book_id,
		stra.entity_id strategy_id,		
        sub.entity_name + '||' + stra.entity_name + '||' + book.entity_name + '||' + sub_book.logical_name book_structure,
        ssbm.logical_name,
        rg.sub_tier_value_id,
		rg.eligibility_mapping_template_id,		
		rg.deal_template_id,
		rg.fas_sub_book_id,
		rg.show_detail
	FROM rec_generator rg
	LEFT JOIN source_system_book_map sub_book 
		ON sub_book.book_deal_type_map_id = rg.fas_sub_book_id
	LEFT JOIN portfolio_hierarchy book
        ON  book.entity_id = rg.fas_book_id
    LEFT JOIN portfolio_hierarchy stra
        ON  stra.entity_id = book.parent_entity_id 
	LEFT JOIN portfolio_hierarchy sub
        ON  sub.entity_id = stra.parent_entity_id
    LEFT JOIN rec_generator_assignment rgg 
		ON rgg.generator_assignment_id = rg.auto_assignment_per
	LEFT JOIN source_system_book_map ssbm
		ON ssbm.book_deal_type_map_id = rgg.source_book_map_id 
	LEFT JOIN formula_editor fe
		ON fe.formula_id = rg.rec_formula_id
	LEFT JOIN formula_editor fe1
		ON fe1.formula_id = rg.contract_formula_id
	WHERE rg.generator_id = @generator_id
END	
ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			IF EXISTS(
				SELECT 1
				FROM rec_generator rg
				INNER JOIN rec_generator_assignment rga ON rg.generator_id = rga.generator_id
				INNER JOIN dbo.FNASplit(@del_generator_ids, ',') di ON di.item = rg.generator_id
			)
			BEGIN
				EXEC spa_ErrorHandler -1, 'Rec Generator', 'spa_rec_generator', 'DB Error', 'The Generator using the Assignment/Allocation cannot be deleted.', 'return'
				RETURN
			END
			IF EXISTS(
				SELECT 1
				FROM source_deal_header sdh
				INNER JOIN dbo.FNASplit(@del_generator_ids, ',') di ON di.item = sdh.generator_id
			)
			BEGIN
				EXEC spa_ErrorHandler -1, 'Rec Generator', 'spa_rec_generator', 'DB Error', 'Failed to delete Source. Deal(s) are entered for this Source.', 'return'
				RETURN
			END
			IF EXISTS(
				SELECT 1
				FROM recorder_generator_map rgm
				INNER JOIN dbo.FNASplit(@del_generator_ids, ',') di ON di.item = rgm.generator_id
			)
			BEGIN
				EXEC spa_ErrorHandler -1, 'Rec Generator', 'spa_rec_generator', 'DB Error', 'Failed to delete Source. First delete data from <b>Meter ID</b> grid.', 'return'
				RETURN
			END
			
			DELETE an
			FROM application_notes an
			INNER JOIN rec_generator rg ON rg.generator_id = ISNULL(an.parent_object_id, an.notes_object_id)
			INNER JOIN dbo.FNASplit(@del_generator_ids, ',') di ON di.item = rg.generator_id
			WHERE an.internal_type_value_id = 400141

			UPDATE en
			SET notes_object_id = NULL
			FROM email_notes en
			INNER JOIN rec_generator rg ON rg.generator_id = en.notes_object_id
			INNER JOIN dbo.FNASplit(@del_generator_ids, ',') di ON di.item = rg.generator_id
			WHERE en.internal_type_value_id = 400141

			DELETE rg
			FROM rec_generator rg
			INNER JOIN dbo.FNASplit(@del_generator_ids, ',') di ON di.item = rg.generator_id

			EXEC spa_ErrorHandler 0,
				'Rec Generator',
				'spa_rec_generator',
				'Success',
				'Changes have been successfully saved.',
				@del_generator_ids
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK TRAN

		DECLARE @desc VARCHAR(1024)
		SET @desc = dbo.FNAHandleDBError(12101700)
		EXEC spa_ErrorHandler -1, 'spa_rec_generator', 'spa_rec_generator', 'Error', @desc, @del_generator_ids
	END CATCH
END
ELSE IF @flag IN ('i', 'u')
BEGIN
	BEGIN TRY
		BEGIN TRAN
		IF OBJECT_ID('tempdb..#rec_generator') IS NOT NULL
			DROP TABLE #rec_generator

		SELECT * INTO #rec_generator FROM rec_generator WHERE 1 = 2
		ALTER TABLE #rec_generator DROP COLUMN generator_id
		ALTER TABLE #rec_generator ADD generator_id INT

		DECLARE @code VARCHAR(100),
			@name VARCHAR(100),
			@id VARCHAR(100),
			@owner VARCHAR(100),
			@classification_value_id INT,
			@technology INT,
			@first_gen_date DATETIME,
			@city_value_id VARCHAR(100),
			@state_value_id INT,
			@registered CHAR(1),
			@gis_value_id INT,
			@registration_date DATETIME,
			@gis_id_number VARCHAR(100),
			@mandatory CHAR(1),
			--@legal_entity_value_id INT,
			@early_banking_mwh INT,
			@early_banking_expiration DATETIME,
			@gen_offset_technology CHAR(1),
			@administrator_name VARCHAR(100),
			@contact_user_login_id VARCHAR(100),
			@source_curve_def_id INT,
			@id2 VARCHAR(100),
			@ppa VARCHAR(100),
			@ppa_counterparty_id INT,
			@ppa_effective_date DATETIME,
			@ppa_expiration_date DATETIME,
			@utility_INTerconnect VARCHAR(100),
			@control_area_operator VARCHAR(100),
			@operator_user_login_id VARCHAR(100),
			@nameplate_capacity FLOAT,
			@facility_name VARCHAR(100),
			@gis_account_number VARCHAR(100),
			@aggregate_environment VARCHAR(100),
			@aggregate_envrionment_comment VARCHAR(100),
			@rec_price FLOAT,
			@rec_formula_id INT,
			@rec_uom_id INT,
			@contract_price FLOAT,
			@contract_formula_id INT,
			@contract_uom_id INT,
			@gen_state_value_id INT,
			@gen_address1 VARCHAR(2500),
			@gen_address2 VARCHAR(2500),
			@gen_address3 VARCHAR(100),
			@auto_assignment_type INT,
			@auto_assignment_per FLOAT,
			@auto_certificate_number VARCHAR(100),
			@exclude_inventory VARCHAR(100),
			@ppa_contract_id INT,
			@contract_allocation FLOAT,
			--@generator_group_name VARCHAR(100),
			@tot_units INT,
			@fuel_value_id INT,
			@r_address VARCHAR(2500),
			@r_phone VARCHAR(100),
			@r_email VARCHAR(100),
			@r_url VARCHAR(100),
			@c_address VARCHAR(2500),
			@c_phone VARCHAR(100),
			@c_email VARCHAR(100),
			@generator_type CHAR(1) = 'r',
			@f_county VARCHAR(100),
			@exp_annual_cap_factor VARCHAR(100),
			@add_capacity_added VARCHAR(100),
			@fac_contact_person VARCHAR(100),
			@fac_address VARCHAR(2500),
			@fac_phone VARCHAR(100),
			@fac_fax VARCHAR(100),
			@fac_email VARCHAR(100),
			@udf_group1 INT,
			@udf_group2 INT,
			@udf_group3 INT,
			@tier_type INT,
			@reporting_fax VARCHAR(100),
			@fac_address_2 VARCHAR(2500),
			@fac_city VARCHAR(100),
			@fa_zip VARCHAR(100),
			@fac_zip VARCHAR(100),
			@fac_state VARCHAR(100),
			@sub_tier_value_id INT,
			@eligibility_mapping_template_id INT,
			@deal_template_id INT,
			@fas_sub_book_id INT,
			@show_detail CHAR(1)

		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @form_xml

		INSERT INTO #rec_generator
		SELECT *
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH #rec_generator

		SELECT
			@generator_id = generator_id,
			@code = code,
			@name = [name],
			@id = id,
			@owner = [owner],
			@classification_value_id = classification_value_id,
			@technology = technology,
			@first_gen_date = NULLIF(first_gen_date, ''),
			@city_value_id = city_value_id,
			@state_value_id = state_value_id,
			@registered = registered,
			@gis_value_id = gis_value_id,
			@registration_date = NULLIF(registration_date, ''),
			@gis_id_number = gis_id_number,
			@mandatory = mandatory,
			@legal_entity_value_id = legal_entity_value_id,
			@early_banking_mwh = early_banking_mwh,
			@early_banking_expiration = early_banking_expiration,
			@gen_offset_technology = gen_offset_technology,
			@administrator_name = administrator_name,
			@contact_user_login_id = contact_user_login_id,
			@source_curve_def_id = source_curve_def_id,
			@id2 = id2,
			@ppa = ppa,
			@ppa_counterparty_id = ppa_counterparty_id,
			@ppa_effective_date = NULLIF(ppa_effective_date, ''),
			@ppa_expiration_date = NULLIF(ppa_expiration_date, ''),
			@utility_interconnect = utility_interconnect,
			@control_area_operator = control_area_operator,
			@operator_user_login_id = operator_user_login_id,
			@nameplate_capacity = nameplate_capacity,
			@facility_name = facility_name,
			@gis_account_number = gis_account_number,
			@aggregate_environment = aggregate_environment,
			@aggregate_envrionment_comment = aggregate_envrionment_comment,
			@rec_price = rec_price,
			@rec_formula_id = rec_formula_id,
			@rec_uom_id = rec_uom_id,
			@contract_price = contract_price,
			@contract_formula_id = contract_formula_id,
			@contract_uom_id = contract_uom_id,
			@gen_state_value_id = gen_state_value_id,
			@gen_address1 = gen_address1,
			@gen_address2 = gen_address2,
			@gen_address3 = gen_address3,
			@auto_assignment_type = auto_assignment_type,
			@auto_assignment_per = auto_assignment_per,
			@auto_certificate_number = auto_certificate_number,
			@exclude_inventory = exclude_inventory,
			@ppa_contract_id = ppa_contract_id,
			@contract_allocation = contract_allocation,
			@generator_group_name = generator_group_name,
			@tot_units = tot_units,
			@fuel_value_id = fuel_value_id,
			@r_address = r_address,
			@r_phone = r_phone,
			@r_email = r_email,
			@r_url = r_url,
			@c_address = c_address,
			@c_phone = c_phone,
			@c_email = c_email,
			@f_county = f_county,
			@exp_annual_cap_factor = exp_annual_cap_factor,
			@add_capacity_added = add_capacity_added,
			@fac_contact_person = fac_contact_person,
			@fac_address = fac_address,
			@fac_phone = fac_phone,
			@fac_fax = fac_fax,
			@fac_email = fac_email,
			@udf_group1 = udf_group1,
			@udf_group2 = udf_group2,
			@udf_group3 = udf_group3,
			@tier_type = tier_type ,
			@reporting_fax = reporting_fax,
			@fac_address_2 = fac_address_2,
			@fac_city = fac_city,
			@fa_zip = fa_zip,
			@fac_zip = fac_zip,
			@fac_state = fac_state,
			@fas_book_id = fas_book_id,
			@sub_tier_value_id = sub_tier_value_id,
			@eligibility_mapping_template_id = eligibility_mapping_template_id,
			@deal_template_id = deal_template_id,
			@fas_sub_book_id = fas_sub_book_id,
			@show_detail = show_detail
		FROM #rec_generator

	
		IF @flag = 'i'
		BEGIN
			
			INSERT INTO rec_generator (
				code, name, id, owner, classification_value_id, technology, first_gen_date, city_value_id, state_value_id, registered, gis_value_id, 
				registration_date, gis_id_number, mandatory, legal_entity_value_id, early_banking_mwh, early_banking_expiration, gen_offset_technology, 
				administrator_name, contact_user_login_id, source_curve_def_id, id2, ppa, ppa_counterparty_id, ppa_effective_date, ppa_expiration_date, 
				utility_interconnect, control_area_operator, operator_user_login_id, nameplate_capacity, facility_name, gis_account_number, aggregate_environment, 
				aggregate_envrionment_comment, rec_price, rec_formula_id, rec_uom_id, contract_price, contract_formula_id, contract_uom_id, gen_state_value_id, 
				gen_address1, gen_address2, gen_address3, auto_assignment_type, auto_assignment_per, auto_certificate_number, exclude_inventory, ppa_contract_id, 
				contract_allocation, generator_group_name, tot_units, fuel_value_id, r_address, r_phone, r_email, r_url, c_address, c_phone, c_email, f_county, 
				exp_annual_cap_factor, add_capacity_added, fac_contact_person, fac_address, fac_phone, fac_fax, fac_email, udf_group1, udf_group2, udf_group3, 
				tier_type, generator_type, reporting_fax, fac_address_2, fac_city, fa_zip, fac_zip, fac_state, fas_book_id, sub_tier_value_id, eligibility_mapping_template_id,
				deal_template_id, fas_sub_book_id, show_detail
			) VALUES (
				@code, @name, @id, @owner, @classification_value_id, @technology, @first_gen_date, @city_value_id, @state_value_id, @registered, @gis_value_id, 
				@registration_date, @gis_id_number, @mandatory, @legal_entity_value_id, @early_banking_mwh, @early_banking_expiration, @gen_offset_technology, 
				@administrator_name, @contact_user_login_id, @source_curve_def_id, @id2, @ppa, @ppa_counterparty_id, @ppa_effective_date, @ppa_expiration_date, 
				@utility_interconnect, @control_area_operator, @operator_user_login_id, @nameplate_capacity, @facility_name, @gis_account_number, @aggregate_environment, 
				@aggregate_envrionment_comment, @rec_price, @rec_formula_id, @rec_uom_id, @contract_price, @contract_formula_id, @contract_uom_id, @gen_state_value_id, 
				@gen_address1, @gen_address2, @gen_address3, @auto_assignment_type, @auto_assignment_per, @auto_certificate_number, @exclude_inventory, @ppa_contract_id, 
				@contract_allocation, @generator_group_name, @tot_units, @fuel_value_id, @r_address, @r_phone, @r_email, @r_url, @c_address, @c_phone, @c_email, @f_county, 
				@exp_annual_cap_factor, @add_capacity_added, @fac_contact_person, @fac_address, @fac_phone, @fac_fax, @fac_email, @udf_group1, @udf_group2, @udf_group3, 
				@tier_type, @generator_type, @reporting_fax, @fac_address_2, @fac_city, @fa_zip, @fac_zip, @fac_state, @fas_book_id , @sub_tier_value_id, 
				@eligibility_mapping_template_id, @deal_template_id, @fas_sub_book_id, @show_detail
			)

			SET @generator_id = SCOPE_IDENTITY()
		END
		
		ELSE IF @flag = 'u'
		BEGIN
			UPDATE rec_generator
			SET code = @code,
				name = @name,
				id = @id,
				[owner] = @owner,
				classification_value_id = @classification_value_id,
				technology = @technology,
				first_gen_date = @first_gen_date,
				city_value_id = @city_value_id,
				state_value_id = @state_value_id,
				registered = @registered,
				gis_value_id = @gis_value_id,
				registration_date = @registration_date,
				gis_id_number = @gis_id_number,
				mandatory = @mandatory,
				legal_entity_value_id = @legal_entity_value_id,
				early_banking_mwh = @early_banking_mwh,
				early_banking_expiration = @early_banking_expiration,
				gen_offset_technology = @gen_offset_technology,
				administrator_name = @administrator_name,
				contact_user_login_id = @contact_user_login_id,
				source_curve_def_id = @source_curve_def_id,
				id2 = @id2,
				ppa = @ppa,
				ppa_counterparty_id = @ppa_counterparty_id,
				ppa_effective_date = @ppa_effective_date,
				ppa_expiration_date = @ppa_expiration_date,
				utility_interconnect = @utility_interconnect,
				control_area_operator = @control_area_operator,
				operator_user_login_id = @operator_user_login_id,
				nameplate_capacity = @nameplate_capacity,
				facility_name = @facility_name,
				gis_account_number = @gis_account_number,
				aggregate_environment = @aggregate_environment,
				aggregate_envrionment_comment = @aggregate_envrionment_comment,
				rec_price = @rec_price,
				rec_formula_id = @rec_formula_id,
				rec_uom_id = @rec_uom_id,
				contract_price = @contract_price,
				contract_formula_id = @contract_formula_id,
				contract_uom_id = @contract_uom_id,
				gen_state_value_id = @gen_state_value_id,
				gen_address1 = @gen_address1,
				gen_address2 = @gen_address2,
				gen_address3 = @gen_address3,
				auto_assignment_type = @auto_assignment_type,
				auto_assignment_per = @auto_assignment_per,
				auto_certificate_number = @auto_certificate_number,
				exclude_inventory = @exclude_inventory,
				ppa_contract_id = @ppa_contract_id,
				contract_allocation = @contract_allocation,
				generator_group_name = @generator_group_name,
				tot_units = @tot_units,
				fuel_value_id = @fuel_value_id,
				r_address = @r_address,
				r_phone = @r_phone,
				r_email = @r_email,
				r_url = @r_url,
				c_address = @c_address,
				c_phone = @c_phone,
				c_email = @c_email,
				f_county = @f_county,
				exp_annual_cap_factor = @exp_annual_cap_factor,
				add_capacity_added = @add_capacity_added,
				fac_contact_person = @fac_contact_person,
				fac_address = @fac_address,
				fac_phone = @fac_phone,
				fac_fax = @fac_fax,
				fac_email = @fac_email,
				udf_group1 = @udf_group1,
				udf_group2 = @udf_group2,
				udf_group3 = @udf_group3,
				tier_type = @tier_type,
				generator_type = @generator_type,
				reporting_fax = @reporting_fax,
				fac_address_2 = @fac_address_2,
				fac_city = @fac_city,
				fa_zip = @fa_zip,
				fac_zip = @fac_zip,
				fac_state =	@fac_state,
				fas_book_id = @fas_book_id,
				sub_tier_value_id = @sub_tier_value_id,
				eligibility_mapping_template_id = @eligibility_mapping_template_id,
				deal_template_id = @deal_template_id,
				fas_sub_book_id = @fas_sub_book_id,
				show_detail = @show_detail
			WHERE generator_id = @generator_id
		END

		IF (@grid_xml = '<Root><GridGroup></GridGroup></Root>')
			SET @grid_xml = ''

		IF(@delete_xml = '<Root><GridGroup></GridGroup></Root>')
			SET @delete_xml = ''

		IF (@grid_xml <> '')
		BEGIN
			IF OBJECT_ID('tempdb..#recorder_generator_map') IS NOT NULL
				DROP TABLE #recorder_generator_map
		
			CREATE TABLE #recorder_generator_map (
				id INT,
				generator_id INT,
				meter_id INT,
				effective_date DATE,
				recorder_id VARCHAR(100) COLLATE DATABASE_DEFAULT ,
				allocation_per FLOAT,
				from_vol FLOAT,
				to_vol FLOAT
			)

		

			DECLARE @idoc_grid INT
			EXEC sp_xml_preparedocument @idoc_grid OUTPUT, @grid_xml

			INSERT INTO #recorder_generator_map
			SELECT NULLIF(id, '') id,
			NULLIF (generator_id, '') generator_id,
			NULLIF(meter_id, '') meter_id,
			NULLIF(effective_date, '') effective_date,
			NULLIF(recorder_id, '') recorder_id,
			NULLIF(allocation_per, '') allocation_per,
			NULLIF(from_vol, '') from_vol,
			NULLIF(to_vol,'') to_vol
			FROM OPENXML(@idoc_grid, 'Root/GridGroup/Grid/GridRow', 1)
			WITH (
				id INT '@id',
				generator_id					INT '@generator_id',
				meter_id						INT	'@meter_id',
				effective_date					DATE	'@effective_date',
				recorder_id						VARCHAR(100)	'@recorder_id',
				allocation_per					FLOAT	'@allocation_per',
				from_vol						FLOAT	'@from_vol',
				to_vol							FLOAT '@to_vol'
			)

			IF OBJECT_ID(N'tempdb..#temp_allocation_new') IS NOT NULL 
				DROP TABLE #temp_allocation_new
			
			CREATE TABLE #temp_allocation_new(
				allocation_per FLOAT
				, meter_id INT
			)
			
			IF OBJECT_ID(N'tempdb..#temp_allocation_old') IS NOT NULL 
				DROP TABLE #temp_allocation_old
			
			CREATE TABLE #temp_allocation_old(
				allocation_per FLOAT
				, meter_id INT
			)

			IF OBJECT_ID(N'tempdb..#temp_allocation') IS NOT NULL 
				DROP TABLE #temp_allocation
			
			CREATE TABLE #temp_allocation(
				allocation_per FLOAT
				, meter_id INT
			)
			
			INSERT INTO #temp_allocation_new
			SELECT SUM(allocation_per) 
				, meter_id
			FROM #recorder_generator_map 
			GROUP BY meter_id

			INSERT INTO #temp_allocation_old
			SELECT SUM(allocation_per) , meter_id
			FROM  recorder_generator_map 
			WHERE meter_id in (SELECT meter_id FROM #recorder_generator_map) AND ID NOT IN (SELECT ISNULL(id, '') FROM #recorder_generator_map)
			GROUP BY meter_id
			

			INSERT INTO #temp_allocation 
			SELECT SUM (allocation_per), meter_id
			FROM (SELECT allocation_per, meter_id
				  FROM #temp_allocation_new
				  UNION ALL
				  SELECT allocation_per, meter_id
				  FROM #temp_allocation_old
				) t
			GROUP BY meter_id
			
			
			

			--select * from #temp_allocation
			--drop table #temp_allocation
			
			

			IF EXISTS(select 1 from #temp_allocation group by meter_id having sum(allocation_per) > 1)
			BEGIN
				EXEC spa_ErrorHandler -1, 'spa_rec_generator', 'spa_rec_generator', 'Error', '<b>Total Allocation Percent</b> Should not exceed 1.', ''
				ROLLBACK
				RETURN
			END
			

			INSERT INTO recorder_generator_map (meter_id, generator_id, effective_date, recorderid, allocation_per, from_vol, to_vol) 
			SELECT meter_id, generator_id, effective_date, recorder_id, allocation_per, from_vol, to_vol
			FROM #recorder_generator_map WHERE id IS NULL
			
			UPDATE rgm
				SET rgm.meter_id = rgm1.meter_id,
					rgm.effective_date = rgm1.effective_date,
					rgm.recorderid = rgm1.recorder_id,
					rgm.allocation_per = rgm1.allocation_per,
					rgm.from_vol = rgm1.from_vol,
					rgm.to_vol = rgm1.to_vol
			FROM #recorder_generator_map rgm1 
			INNER JOIN recorder_generator_map rgm ON rgm.id = rgm1.id
				AND rgm.generator_id = rgm1.generator_id
		END

		IF (@delete_xml<> '')
		BEGIN
			IF OBJECT_ID('tempdb..#recorder_generator_map_delete') IS NOT NULL
				DROP TABLE #recorder_generator_map_delete
		
			CREATE TABLE #recorder_generator_map_delete (
				id INT,
				generator_id INT
			)

		

			DECLARE @idoc_grid_del INT
			EXEC sp_xml_preparedocument @idoc_grid_del OUTPUT, @delete_xml

			INSERT INTO #recorder_generator_map_delete
			SELECT NULLIF(id, '') id,
			NULLIF (generator_id, '') generator_id
			FROM OPENXML(@idoc_grid_del, 'Root/GridGroup/GridDelete/GridRow', 1)
			WITH (
				id				INT	'@id',
				generator_id	INT '@generator_id'
			)

			DELETE rgm from recorder_generator_map rgm
			INNER JOIN #recorder_generator_map_delete rgmd ON rgm.ID = rgmd.id 
				AND rgm.generator_id = rgmd.generator_id
		END



		--DECLARE @recommendation VARCHAR(250)
		--SET @recommendation = CAST(@generator_id AS VARCHAR(10)) + ',' + @name

		EXEC spa_ErrorHandler 0
					, 'rec_generator'
					, 'spa_rec_generator'
					, 'Success' 
					, 'Changes have been successfully saved.'
					, @generator_id
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		     
		SET @desc = ERROR_MESSAGE()
		IF (@desc LIKE '%Violation of UNIQUE KEY constraint ''UC_rec_generator_code_id''%')
		BEGIN
			EXEC spa_ErrorHandler -1, 'spa_rec_generator', 'spa_rec_generator', 'Error', 'Unit ID and Facility ID should be unique', ''
		END
		ELSE IF (@desc LIKE '%Violation of UNIQUE KEY constraint ''IX_recorder_generator_map''%')
		BEGIN 
			EXEC spa_ErrorHandler -1, 'spa_rec_generator', 'spa_rec_generator', 'Error', '<b>Recorder ID</b> must be unique.', ''
		END
		ELSE
		BEGIN
			EXEC spa_ErrorHandler -1, 'spa_rec_generator', 'spa_rec_generator', 'Error', @desc, ''			
		END	

	END CATCH
END
ELSE IF @flag = 'c'
BEGIN
	BEGIN TRY 
		INSERT INTO rec_generator(code, name, id, owner, classification_value_id, technology, first_gen_date, city_value_id, state_value_id, registered, gis_value_id, 
					registration_date, gis_id_number, mandatory, legal_entity_value_id, early_banking_mwh, early_banking_expiration, gen_offset_technology, 
					administrator_name, contact_user_login_id, source_curve_def_id, id2, ppa, ppa_counterparty_id, ppa_effective_date, ppa_expiration_date, 
					utility_interconnect, control_area_operator, operator_user_login_id, nameplate_capacity, facility_name, gis_account_number, aggregate_environment, 
					aggregate_envrionment_comment, rec_price, rec_formula_id, rec_uom_id, contract_price, contract_formula_id, contract_uom_id, gen_state_value_id, 
					gen_address1, gen_address2, gen_address3, auto_assignment_type, auto_assignment_per, auto_certificate_number, exclude_inventory, ppa_contract_id, 
					contract_allocation, generator_group_name, tot_units, fuel_value_id, r_address, r_phone, r_email, r_url, c_address, c_phone, c_email, f_county, 
					exp_annual_cap_factor, add_capacity_added, fac_contact_person, fac_address, fac_phone, fac_fax, fac_email, udf_group1, udf_group2, udf_group3, 
					tier_type, generator_type, reporting_fax, fac_address_2, fac_city, fa_zip, fac_zip, fac_state, fas_book_id,deal_template_id,
					eligibility_mapping_template_id, fas_sub_book_id, show_detail)
	
		SELECT 'Copy of - ' + code, 'Copy of - ' + name, 'Copy of - ' + id, 'Copy of - ' + owner, classification_value_id, technology, first_gen_date, city_value_id, state_value_id, registered, gis_value_id, 
					registration_date, gis_id_number, mandatory, legal_entity_value_id, early_banking_mwh, early_banking_expiration, gen_offset_technology, 
					administrator_name, contact_user_login_id, source_curve_def_id, id2, ppa, ppa_counterparty_id, ppa_effective_date, ppa_expiration_date, 
					utility_interconnect, control_area_operator, operator_user_login_id, nameplate_capacity, facility_name, gis_account_number, aggregate_environment, 
					aggregate_envrionment_comment, rec_price, rec_formula_id, rec_uom_id, contract_price, contract_formula_id, contract_uom_id, gen_state_value_id, 
					gen_address1, gen_address2, gen_address3, auto_assignment_type, auto_assignment_per, auto_certificate_number, exclude_inventory, ppa_contract_id, 
					contract_allocation, generator_group_name, tot_units, fuel_value_id, r_address, r_phone, r_email, r_url, c_address, c_phone, c_email, f_county, 
					exp_annual_cap_factor, add_capacity_added, fac_contact_person, fac_address, fac_phone, fac_fax, fac_email, udf_group1, udf_group2, udf_group3, 
					tier_type, generator_type, reporting_fax, fac_address_2, fac_city, fa_zip, fac_zip, fac_state, fas_book_id, deal_template_id, 
					eligibility_mapping_template_id, fas_sub_book_id, show_detail
		FROM rec_generator 
		WHERE generator_id = @generator_id

		SET @generator_id = SCOPE_IDENTITY();

		EXEC spa_ErrorHandler 0
					, 'rec_generator'
					, 'spa_rec_generator'
					, 'Success' 
					, 'Changes have been successfully saved.'
					, @generator_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK

		SET @desc = dbo.FNAHandleDBError(10167300)  
		EXEC spa_ErrorHandler -1, 'spa_rec_generator', 'spa_rec_generator', 'Error', @desc, ''

	END CATCH
END
IF @flag = 'z'
BEGIN
	-- For Dropdown
	SELECT rg.generator_id [id], rg.name [source] FROM rec_generator AS rg
END
ELSE IF @flag = 'x'
BEGIN
	SELECT rgm.id, 
		   rgm.generator_id, 
		   rgm.meter_id,
		   rgm.effective_date,
		   mi.recorderid recorder_id, 
		   rgm.allocation_per, 
		   rgm.from_vol, 
		   rgm.to_vol
	FROM recorder_generator_map rgm
	LEFT JOIN meter_id mi 
		ON mi.meter_id = rgm.meter_id
	WHERE rgm.generator_id = @generator_id
END

ELSE IF @flag = 'l' 
BEGIN
	SELECT ISNULL(SUM(allocation_per),0) [allocation_per] 
	FROM recorder_generator_map 
	WHERE meter_id = @meter_id AND id <> ISNULL(@recorder_generator_map_id, '')
END

ELSE IF @flag = 'm' --Browser Sql for Import parameter
BEGIN
	DECLARE @idoc2 INT, @gen_group_name VARCHAR(100)
	EXEC sp_xml_preparedocument @idoc2 OUTPUT, @form_xml	
	SELECT @gen_group_name = generator_group_name
	FROM OPENXML(@idoc2, '/Root/FormXML', 1)
	WITH (
		generator_group_name  VARCHAR(100)
	)
	
	SELECT rg.gis_id_number, rg.[name], rg.code
	FROM rec_generator rg
	INNER JOIN rec_generator_group rgg ON rgg.generator_group_id = rg.generator_group_name
	WHERE rgg.generator_group_name = @gen_group_name 
END

ELSE IF @flag = 'k' 
BEGIN
	SELECT generator_id
		  ,[name]
		  ,[id]
		  ,[code]
	FROM rec_generator
	ORDER BY [name]
END

GO
