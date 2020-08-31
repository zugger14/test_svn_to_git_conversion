IF EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_rec_generator_name]') AND type IN (N'P', N'PC'))
  DROP PROCEDURE [dbo].[spa_rec_generator_name]
GO

CREATE PROCEDURE [dbo].[spa_rec_generator_name] 
	@flag CHAR(1),
	@generator_group_id VARCHAR(255) = NULL,
	@generator_group_name VARCHAR(255) = NULL,
	@generator_type CHAR(1) = NULL,
	@sub_id INT = NULL,
	@book_id INT = NULL,
	@grid_xml XML = NULL
AS

/******************************************************************
DECLARE	@flag CHAR(1),
		@generator_group_id VARCHAR(255) = NULL,
		@generator_group_name VARCHAR(255) = NULL,
		@generator_type CHAR(1) = NULL,
		@sub_id INT = NULL,
		@book_id INT = NULL,
		@grid_xml XML = NULL

SET @flag = 'i'
SET @grid_xml='<Root><PSRecordset  generator_group_id="54" generator_group_name="East Ridge Windfarm123" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="55" generator_group_name="Garwin MC Neilus" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="56" generator_group_name="Lake Benton Power Partners LLC" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="53" generator_group_name="Minwind" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="57" generator_group_name="Moraine II" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="58" generator_group_name="Norgaad  North- Dajan North" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="59" generator_group_name="Norgaad South-Dajan South" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="60" generator_group_name="Northern Alternative" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="64" generator_group_name="psco" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="61" generator_group_name="Rock County" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="62" generator_group_name="Ruthon Ridge" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="63" generator_group_name="Shaokatan Windfarm" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="65" generator_group_name="South Ridge Wind" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="68" generator_group_name="Upg_Test" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="66" generator_group_name="Viking 2" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="67" generator_group_name="West Pipestone" generator_type="r" ></PSRecordset> <PSRecordset  generator_group_id="52" generator_group_name="Westridge" generator_type="r" ></PSRecordset> </Root>'
--****************************************************************/

SET NOCOUNT ON
IF @flag = 's'
BEGIN
	SELECT MAX(generator_group_id) GroupId,
		   generator_group_name [Groups]
	FROM rec_generator_group
	WHERE ((generator_type = @generator_type)
	OR (@generator_type = 'r' OR generator_type IS NULL))
	GROUP BY generator_group_name
	ORDER BY generator_group_name
END
ELSE IF @flag = 'a'
BEGIN
	SELECT
		generator_group_id,
		generator_group_name,
		generator_type
	FROM rec_generator_group
	WHERE generator_group_id = @generator_group_id
END
ELSE IF @flag = 'i'
BEGIN
	IF @grid_xml IS NOT NULL
	BEGIN
	BEGIN TRY
	BEGIN TRAN
		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @grid_xml
		
		IF OBJECT_ID('tempdb..#rec_generator_group') IS NOT NULL
			DROP TABLE #rec_generator_group
		
		SELECT
			generator_group_id,
			generator_group_name,
			generator_type
		INTO #rec_generator_group
		FROM rec_generator_group 
		WHERE 1 <> 1
		
		ALTER TABLE #rec_generator_group DROP COLUMN generator_group_id
		ALTER TABLE #rec_generator_group ADD generator_group_id INT

		INSERT INTO #rec_generator_group
		SELECT generator_group_name,
			   generator_type,
			   generator_group_id
		FROM OPENXML(@idoc, '/Root/PSRecordset', 1)
		WITH #rec_generator_group


		MERGE rec_generator_group AS t
		USING 
			(
				SELECT 
					generator_group_name,
					generator_type,
					generator_group_id
				FROM #rec_generator_group		
			) AS s
		ON (t.generator_group_id = s.generator_group_id) 
		WHEN NOT MATCHED BY TARGET 
		THEN 
			INSERT(generator_group_name, generator_type) 
			VALUES( s.generator_group_name, s.generator_type)
		WHEN MATCHED 
		THEN 
			UPDATE 
			SET generator_group_name = s.generator_group_name,
				generator_type = s.generator_type
		WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

		EXEC spa_ErrorHandler 0,
             'Rec Generator Name',
             'spa_rec_generator_name',
             'Success',
             'Changes have been successfully saved.',
             ''
    COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK

		DECLARE @desc VARCHAR(1024)
		SET @desc = dbo.FNAHandleDBError(12101712)  
		EXEC spa_ErrorHandler -1, 'spa_rec_generator_name', 'spa_rec_generator_name', 'Error', @desc, ''

	END CATCH
	END
END
--IF @flag = 'u'
--BEGIN
--UPDATE rec_generator_group
--SET generator_group_name = @generator_group_name,
--    generator_type = @generator_type
--WHERE generator_group_id = @generator_group_id

--IF @@ERROR <> 0
--    EXEC spa_ErrorHandler @@ERROR,
--                        "Rec Generator",
--                        "spa_rec_generator",
--                        "DB Error",
--                        "Error on updating Rec generator.",
--                        ''
--ELSE
--    EXEC spa_ErrorHandler 0,
--                        'Rec Generator',
--                        'spa_rec_generatpr',
--                        'Success',
--                        'Rec Generator successfully updated.',
--                        ''
--END
--IF @flag = 'd'
--BEGIN
--IF EXISTS (SELECT
--    'X'
--    FROM rec_generator rg
--    INNER JOIN rec_generator_group rgg
--    ON rgg.generator_group_name = rg.generator_group_name
--    INNER JOIN dbo.SplitCommaSeperatedValues(@generator_group_id) items
--    ON rgg.generator_group_id = items.item)
--    EXEC spa_ErrorHandler -1,
--                        'Generator Group Source cannot be deleted as it is being used.',
--                        'spa_rec_generator_name',
--                        'DB Error',
--                        'Generator Group Source cannot be deleted as it is being used.',
--                        ''
--ELSE
--BEGIN
--    DELETE rec_generator_group
--    FROM rec_generator_group rgg
--    INNER JOIN dbo.SplitCommaSeperatedValues(@generator_group_id) items
--        ON rgg.generator_group_id = items.item

--    IF @@ERROR <> 0
--    EXEC spa_ErrorHandler @@ERROR,
--                            'Error on deleting Rec generator.',
--                            'spa_rec_generator_name',
--                            'DB Error',
--                            'Error on deleting Rec generator.',
--                            ''
--    ELSE
--    EXEC spa_ErrorHandler 0,
--                            'Rec Generator deleted.',
--                            'spa_rec_generator_name',
--                            'Success',
--                            'Rec Generator deleted.',
--                            ''
--END
--END
--IF @flag = 'c' -- Copy Group and sources
--BEGIN

--INSERT rec_generator_group (generator_group_name, generator_type)
--    VALUES (@generator_group_name, @generator_type)


--INSERT INTO rec_generator (code, name, id, owner, classification_value_id, technology
--, first_gen_date, upgraded, upgrade_date, city_value_id
--, state_value_id, registered, gis_value_id, registration_date
--, gis_id_number, mandatory, legal_entity_value_id, early_banking_mwh
--, early_banking_expiration, gen_offset_technology, administrator_name
--, contact_user_login_id, source_curve_def_id, id2, ppa, ppa_counterparty_id
--, ppa_effective_date, ppa_expiration_date, utility_interconnect
--, control_area_operator, operator_user_login_id
--, nameplate_capacity, facility_name, gis_account_number, aggregate_environment
--, aggregate_envrionment_comment, rec_price, rec_formula_id, rec_uom_id, contract_price
--, contract_formula_id, contract_uom_id, geneartor_iso_name, wisconsin_id, gen_state_value_id
--, gen_address1, gen_address2, gen_address3, auto_assignment_type, auto_assignment_per
--, auto_certificate_number, exclude_inventory, tax_benefit_curve_id, tax_price, tax_formula_id
--, tax_deal_type, ppa_contract_id, contract_allocation, generator_group_name, tot_units, fuel_value_id
--, r_address, r_phone, r_email, r_url, c_address, c_phone, c_email, generator_type, ems_source_model_id
--, fas_book_id, ems_book_id, f_county, captured_co2_emission, onsite_offsite, de_minimis_source
--, country_id, resource_type, reduction, reduction_type, reduction_sub_type, reduc_start_date
--, reduc_end_date, base_year, sustainability_verified, sustainability_system, co2_captured_for_generator_id
--, source_sink_type, create_user, create_ts, update_user, update_ts, exp_annual_cap_factor, add_capacity_added
--, fac_contact_person, fac_address, fac_phone, fac_fax, fac_email, location_id, udf_group1, udf_group2
--, udf_group3, is_hypothetical, uom, throughput, create_obligation_deal, tier_type)


--    SELECT
--    CASE
--        WHEN NULLIF(code, '') IS NOT NULL THEN 'Copy of ' + code
--        ELSE code
--    END,
--    'Copy of ' + name,
--    CASE
--        WHEN NULLIF(code, '') IS NULL THEN 'Copy of ' + id
--        ELSE id
--    END,
--    owner,
--    classification_value_id,
--    technology,
--    first_gen_date,
--    upgraded,
--    upgrade_date,
--    city_value_id,
--    state_value_id,
--    registered,
--    gis_value_id,
--    registration_date,
--    gis_id_number,
--    mandatory,
--    @sub_id,
--    early_banking_mwh,
--    early_banking_expiration,
--    gen_offset_technology,
--    administrator_name,
--    contact_user_login_id,
--    source_curve_def_id,
--    id2,
--    ppa,
--    ppa_counterparty_id,
--    ppa_effective_date,
--    ppa_expiration_date,
--    utility_interconnect,
--    control_area_operator,
--    operator_user_login_id,
--    nameplate_capacity,
--    facility_name,
--    gis_account_number,
--    aggregate_environment,
--    aggregate_envrionment_comment,
--    rec_price,
--    rec_formula_id,
--    rec_uom_id,
--    contract_price,
--    contract_formula_id,
--    contract_uom_id,
--    geneartor_iso_name,
--    wisconsin_id,
--    gen_state_value_id,
--    gen_address1,
--    gen_address2,
--    gen_address3,
--    auto_assignment_type,
--    auto_assignment_per,
--    auto_certificate_number,
--    exclude_inventory,
--    tax_benefit_curve_id,
--    tax_price,
--    tax_formula_id,
--    tax_deal_type,
--    ppa_contract_id,
--    contract_allocation,
--    @generator_group_name,
--    tot_units,
--    fuel_value_id,
--    r_address,
--    r_phone,
--    r_email,
--    r_url,
--    c_address,
--    c_phone,
--    c_email,
--    @generator_type,
--    ems_source_model_id,
--    @book_id,
--    ems_book_id,
--    f_county,
--    captured_co2_emission,
--    onsite_offsite,
--    de_minimis_source,
--    country_id,
--    resource_type,
--    reduction,
--    reduction_type,
--    reduction_sub_type,
--    reduc_start_date,
--    reduc_end_date,
--    base_year,
--    sustainability_verified,
--    sustainability_system,
--    co2_captured_for_generator_id,
--    source_sink_type,
--    create_user,
--    create_ts,
--    update_user,
--    update_ts,
--    exp_annual_cap_factor,
--    add_capacity_added,
--    fac_contact_person,
--    fac_address,
--    fac_phone,
--    fac_fax,
--    fac_email,
--    location_id,
--    udf_group1,
--    udf_group2,
--    udf_group3,
--    is_hypothetical,
--    uom,
--    throughput,
--    create_obligation_deal,
--    tier_type

--    FROM rec_generator rg
--    WHERE generator_group_name IN (SELECT
--    generator_group_name GroupName
--    FROM rec_generator_group
--    WHERE generator_group_id = @generator_group_id)

--IF @@ERROR <> 0
--    EXEC spa_ErrorHandler @@ERROR,
--                        "Rec Generator",
--                        "spa_rec_generator",
--                        "DB Error",
--                        "Error on updating Rec generator.",
--                        ''
--ELSE
--    EXEC spa_ErrorHandler 0,
--                        'Rec Generator',
--                        'spa_rec_generatpr',
--                        'Success',
--                        'Rec Generator successfully updated.',
--                        ''
--END