IF OBJECT_ID(N'[dbo].[spa_deal_fields_mapping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_fields_mapping]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/**
	It is used to get the options of dependent combos in deal UI after handling the privilege

	Parameters
	@flag : Operation flag mandatory
			's' - Return the Json for drop down values 
			'v' - Return Default value of a combo
	@template_id : Deal Template Id
	@counterparty_id : Counterparty Id
	@deal_fields : Deal Fields
	@default_value : Default Value
	@deal_id : Deal Id
	@json_string : Json String an output variable
	@process_table : Process Table
	@deal_type_id : Deal Type Id
	@commodity_id : Commodity Id
	@trader_id : Trader Id
	@state_value_id : State Value Id
	@reporting_jurisdiction_id : Reporting Jurisdiction Id,
	@location_id : Location Id,
	@sub_book_id : Sub Book Id,
	@term_start : Term Start of Deal Detail
	@contract_id : Contract Id of Deal
	@buy_sell_flag : Detail Buy sell flag
*/ 

CREATE PROCEDURE [dbo].[spa_deal_fields_mapping]
    @flag NCHAR(1),
    @template_id INT = NULL,
    @counterparty_id INT = NULL,
    @deal_fields NVARCHAR(100),
    @default_value INT = NULL,
    @deal_id INT = NULL,
	@json_string NVARCHAR(MAX) = NULL OUTPUT,
	@process_table NVARCHAR(200) = NULL,
	@deal_type_id INT = NULL,
	@commodity_id INT = NULL,
	@trader_id INT = NULL,
	@state_value_id INT = NULL,
	@reporting_jurisdiction_id INT = NULL,
	@location_id INT = NULL,
	@sub_book_id INT = NULL,
	@term_start DATETIME = NULL,
	@contract_id INT = NULL,
	@buy_sell_flag NCHAR(1) = NULL,
	@load_default BIT = 1
AS
/*------------------Debug Section------------------
DECLARE @flag NCHAR(1),
		@template_id INT = NULL,
		@counterparty_id INT = NULL,
		@deal_fields NVARCHAR(100),
		@default_value INT = NULL,
		@deal_id INT = NULL,
		@json_string NVARCHAR(MAX) = NULL,
		@process_table NVARCHAR(200) = NULL,
		@deal_type_id INT = NULL,
		@commodity_id INT = NULL,
		@trader_id INT = NULL,
		@state_value_id INT = NULL,
		@reporting_jurisdiction_id INT = NULL,
		@location_id INT = NULL,
		@sub_book_id INT = NULL,
		@term_start DATETIME = NULL,
		@contract_id INT = NULL,
		@buy_sell_flag NCHAR(1) = NULL

SELECT @flag='s',@deal_id='11110',@counterparty_id='8904',@deal_fields='tier_value_id',@default_value='10316',@template_id= NULL,@deal_type_id='1248',@commodity_id='2294',@trader_id='2162',@state_value_id='50000593'
-------------------------------------------------*/
SET NOCOUNT ON

DECLARE @sql NVARCHAR(MAX), @shipper_default_value INT
SET @location_id = NULLIF(@location_id, 0)
SET @default_value = NULLIF(@default_value, 0)
SET @counterparty_id = NULLIF(@counterparty_id, 0)

IF @flag = 's' OR @flag = 'c' OR @flag = 'v'
BEGIN
	DECLARE @field_template_id INT,
			@blank_value NCHAR(1)

	DECLARE @sql_query NVARCHAR(500)

	IF @deal_id IS NOT NULL
	BEGIN		
		SELECT @template_id = ISNULL(@template_id, sdh.template_id),
			   @deal_type_id = ISNULL(@deal_type_id, sdh.source_deal_type_id),
			   @commodity_id = ISNULL(@commodity_id, sdh.commodity_id),
			   @counterparty_id = CASE WHEN ISNULL(@counterparty_id, 0) = -1 THEN NULL WHEN @deal_fields = 'counterparty2_trader' THEN ISNULL(@counterparty_id, sdh.counterparty_id2) ELSE ISNULL(@counterparty_id, sdh.counterparty_id) END,
			   @trader_id = ISNULL(@trader_id, sdh.trader_id),
			   @state_value_id = CASE WHEN ISNULL(@state_value_id, 0) = -1 THEN NULL ELSE ISNULL(@state_value_id, sdh.state_value_id) END,
			   @reporting_jurisdiction_id = CASE WHEN ISNULL(@reporting_jurisdiction_id, 0) = -1 THEN NULL ELSE ISNULL(@reporting_jurisdiction_id, sdh.reporting_jurisdiction_id) END
		FROM source_deal_header sdh
		WHERE sdh.source_deal_header_id = @deal_id
	END
	ELSE
	BEGIN
		SELECT @trader_id = ISNULL(@trader_id, st.source_trader_id)
		FROM source_traders st
		WHERE st.user_login_id = dbo.FNADBUser()

		SELECT @deal_type_id = ISNULL(@deal_type_id, sdh.source_deal_type_id),
			   @commodity_id = ISNULL(@commodity_id, sdh.commodity_id),
			   @counterparty_id = CASE WHEN ISNULL(@counterparty_id, 0) = -1 THEN NULL WHEN @deal_fields = 'counterparty2_trader' THEN ISNULL(@counterparty_id, sdh.counterparty_id2) ELSE ISNULL(@counterparty_id, sdh.counterparty_id) END,
			   @trader_id = ISNULL(@trader_id, sdh.trader_id),
			   @state_value_id = CASE WHEN ISNULL(@state_value_id, 0) = -1 THEN NULL ELSE ISNULL(@state_value_id, sdh.state_value_id) END,
			   @reporting_jurisdiction_id = CASE WHEN ISNULL(@reporting_jurisdiction_id, 0) = -1 THEN NULL ELSE ISNULL(@reporting_jurisdiction_id, sdh.reporting_jurisdiction_id) END
		FROM source_deal_header_template sdh
		WHERE sdh.template_id = @template_id
	END

	IF OBJECT_ID('tempdb..#combination_table') IS NOT NULL
		DROP TABLE #combination_table

	CREATE TABLE #combination_table (template_id INT, deal_type_id INT, commodity_id INT, counterparty_id INT, trader_id INT)

	INSERT INTO #combination_table(
	    template_id,
	    deal_type_id,
	    commodity_id,
	    counterparty_id,
	    trader_id
	)
	SELECT 1,0,0,0,0  UNION ALL
	SELECT 1,0,0,0,1  UNION ALL
	SELECT 1,0,0,1,0  UNION ALL
	SELECT 1,0,0,1,1  UNION ALL
	SELECT 1,0,1,0,0  UNION ALL
	SELECT 1,0,1,0,1  UNION ALL
	SELECT 1,0,1,1,0  UNION ALL
	SELECT 1,0,1,1,1  UNION ALL
	SELECT 1,1,0,0,0  UNION ALL
	SELECT 1,1,0,0,1  UNION ALL
	SELECT 1,1,0,1,0  UNION ALL
	SELECT 1,1,0,1,1  UNION ALL
	SELECT 1,1,1,0,0  UNION ALL
	SELECT 1,1,1,0,1  UNION ALL
	SELECT 1,1,1,1,0  UNION ALL
	SELECT 1,1,1,1,1 

	UPDATE #combination_table
	SET template_id = CASE WHEN template_id = 1 THEN @template_id ELSE 0 END,
		deal_type_id = CASE WHEN deal_type_id = 1 THEN ISNULL(@deal_type_id, 0) ELSE 0 END,
		commodity_id = CASE WHEN commodity_id = 1 THEN ISNULL(@commodity_id, 0) ELSE 0 END,
		counterparty_id = CASE WHEN counterparty_id = 1 THEN ISNULL(@counterparty_id, 0) ELSE 0 END,
		trader_id = CASE WHEN trader_id = 1 THEN ISNULL(@trader_id, 0) ELSE 0 END
	WHERE 1 = 1

	IF OBJECT_ID('tempdb..#temp_deal_fields_mapping') IS NOT NULL	
		DROP TABLE #temp_deal_fields_mapping
	
	CREATE TABLE #temp_deal_fields_mapping (deal_fields_mapping_id INT, deal_type_id INT, commodity_id INT, counterparty_id INT)
	
	-- collect mapping matching all fields
	INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
	SELECT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
	FROM deal_fields_mapping dfm
	INNER JOIN #combination_table ct 
		ON ct.template_id = dfm.template_id
		AND ct.deal_type_id = dfm.deal_type_id
		AND ct.commodity_id = dfm.commodity_id
		AND ct.counterparty_id = dfm.counterparty_id
		AND ct.trader_id = dfm.trader_id
	WHERE ct.deal_type_id <> 0 AND ct.commodity_id <> 0 AND ct.counterparty_id <> 0 AND ct.trader_id <> 0
	AND dfm.deal_type_id IS NOT NULL
	AND dfm.commodity_id IS NOT NULL
	AND dfm.counterparty_id IS NOT NULL
	AND dfm.trader_id IS NOT NULL

	-- collect mapping matching three attribute
	IF NOT EXISTS(SELECT 1 FROM #temp_deal_fields_mapping)
	BEGIN
		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.deal_type_id = dfm.deal_type_id
			AND ct.commodity_id = dfm.commodity_id
			AND ct.counterparty_id = dfm.counterparty_id
		WHERE ct.deal_type_id <> 0 AND ct.commodity_id <> 0 AND ct.counterparty_id <> 0 AND ct.trader_id = 0
		AND dfm.deal_type_id IS NOT NULL
		AND dfm.commodity_id IS NOT NULL
		AND dfm.counterparty_id IS NOT NULL

		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.deal_type_id = dfm.deal_type_id
			AND ct.commodity_id = dfm.commodity_id
			AND ct.trader_id = dfm.trader_id
		WHERE ct.deal_type_id <> 0 AND ct.commodity_id <> 0 AND ct.trader_id <> 0 AND ct.counterparty_id = 0
		AND dfm.deal_type_id IS NOT NULL
		AND dfm.commodity_id IS NOT NULL
		AND dfm.trader_id IS NOT NULL

		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.deal_type_id = dfm.deal_type_id
			AND ct.counterparty_id = dfm.counterparty_id
			AND ct.trader_id = dfm.trader_id
		WHERE ct.deal_type_id <> 0 AND ct.trader_id <> 0 AND ct.counterparty_id <> 0 AND ct.commodity_id = 0
		AND dfm.deal_type_id IS NOT NULL
		AND dfm.counterparty_id IS NOT NULL
		AND dfm.trader_id IS NOT NULL

		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.commodity_id = dfm.commodity_id
			AND ct.counterparty_id = dfm.counterparty_id
			AND ct.trader_id = dfm.trader_id
		WHERE ct.commodity_id <> 0 AND ct.trader_id <> 0 AND ct.counterparty_id <> 0 AND ct.deal_type_id = 0
		AND dfm.commodity_id IS NOT NULL
		AND dfm.counterparty_id IS NOT NULL
		AND dfm.trader_id IS NOT NULL
	END

	-- collect mapping matching two attribute
	IF NOT EXISTS(SELECT 1 FROM #temp_deal_fields_mapping)
	BEGIN
		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT DISTINCT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.deal_type_id = dfm.deal_type_id
			AND ct.commodity_id = dfm.commodity_id
		WHERE ct.deal_type_id <> 0 AND ct.commodity_id <> 0 AND ct.counterparty_id = 0 AND ct.trader_id = 0
		AND dfm.deal_type_id IS NOT NULL
		AND dfm.commodity_id IS NOT NULL

		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT DISTINCT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.deal_type_id = dfm.deal_type_id
			AND ct.counterparty_id = dfm.counterparty_id
		WHERE ct.deal_type_id <> 0 AND ct.counterparty_id <> 0 AND ct.commodity_id = 0 AND ct.trader_id = 0
		AND dfm.deal_type_id IS NOT NULL
		AND dfm.counterparty_id IS NOT NULL

		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT DISTINCT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.deal_type_id = dfm.deal_type_id
			AND ct.trader_id = dfm.trader_id
		WHERE ct.deal_type_id <> 0 AND ct.trader_id <> 0 AND ct.commodity_id = 0 AND ct.counterparty_id = 0
		AND dfm.deal_type_id IS NOT NULL
		AND dfm.trader_id IS NOT NULL

		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT DISTINCT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.commodity_id = dfm.commodity_id
			AND ct.trader_id = dfm.trader_id
		WHERE ct.commodity_id <> 0 AND ct.trader_id <> 0 AND ct.deal_type_id = 0 AND ct.counterparty_id = 0
		AND dfm.commodity_id IS NOT NULL
		AND dfm.trader_id IS NOT NULL

		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT DISTINCT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.commodity_id = dfm.commodity_id
			AND ct.counterparty_id = dfm.counterparty_id
		WHERE ct.commodity_id <> 0 AND ct.counterparty_id <> 0 AND ct.deal_type_id = 0 AND ct.trader_id = 0
		AND dfm.commodity_id IS NOT NULL
		AND dfm.counterparty_id IS NOT NULL

		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT DISTINCT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.trader_id = dfm.trader_id
			AND ct.counterparty_id = dfm.counterparty_id
		WHERE ct.trader_id <> 0 AND ct.counterparty_id <> 0 AND ct.deal_type_id = 0 AND ct.commodity_id = 0
		AND dfm.trader_id IS NOT NULL
		AND dfm.counterparty_id IS NOT NULL
	END

	-- collect mapping matching one attribute
	IF NOT EXISTS(SELECT 1 FROM #temp_deal_fields_mapping)
	BEGIN
		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.deal_type_id = dfm.deal_type_id
		WHERE ct.deal_type_id <> 0 AND ct.commodity_id = 0 AND ct.counterparty_id = 0 AND ct.trader_id = 0
		AND dfm.deal_type_id IS NOT NULL

		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.commodity_id = dfm.commodity_id
		WHERE ct.commodity_id <> 0 AND ct.deal_type_id = 0 AND ct.counterparty_id = 0 AND ct.trader_id = 0
		AND dfm.commodity_id IS NOT NULL

		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.counterparty_id = dfm.counterparty_id
		WHERE ct.counterparty_id <> 0 AND ct.deal_type_id = 0 AND ct.commodity_id = 0 AND ct.trader_id = 0
		AND dfm.counterparty_id IS NOT NULL

		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct 
			ON ct.template_id = dfm.template_id
			AND ct.trader_id = dfm.trader_id
		WHERE ct.trader_id <> 0 AND ct.deal_type_id = 0 AND ct.commodity_id = 0 AND ct.counterparty_id = 0
		AND dfm.trader_id IS NOT NULL
	END

	-- collect mapping matching template
	IF NOT EXISTS(SELECT 1 FROM #temp_deal_fields_mapping)
	BEGIN
		INSERT INTO #temp_deal_fields_mapping(deal_fields_mapping_id, deal_type_id, commodity_id, counterparty_id)
		SELECT dfm.deal_fields_mapping_id, dfm.deal_type_id, dfm.commodity_id, dfm.counterparty_id
		FROM deal_fields_mapping dfm
		INNER JOIN #combination_table ct ON ct.template_id = dfm.template_id
		WHERE ct.deal_type_id = 0 AND ct.commodity_id = 0 AND ct.counterparty_id = 0 AND ct.trader_id = 0
		AND dfm.deal_type_id IS NULL AND dfm.commodity_id  IS NULL AND dfm.counterparty_id IS NULL
	END
	
	IF OBJECT_ID('tempdb..#temp_combo') IS NOT NULL
		DROP TABLE #temp_combo
	
	CREATE TABLE #temp_combo ([value] NVARCHAR(10) COLLATE DATABASE_DEFAULT , [text] NVARCHAR(1000) COLLATE DATABASE_DEFAULT , selected NVARCHAR(10) COLLATE DATABASE_DEFAULT , [state] NVARCHAR(10) COLLATE DATABASE_DEFAULT DEFAULT 'enable' )
	
	IF OBJECT_ID('tempdb..#final_privilege_list') IS NOT NULL
		DROP TABLE #final_privilege_list

	CREATE TABLE #final_privilege_list(value_id INT, is_enable NVARCHAR(20) COLLATE DATABASE_DEFAULT )
	DECLARE @source_object NVARCHAR(100), @state_column NVARCHAR(100) = '', @privilege_join NVARCHAR(200) = '', @insert_statement NVARCHAR(200)

	SELECT @source_object = CASE @deal_fields
								WHEN 'contract_id' THEN 'contract'
								WHEN 'curve_id' THEN 'pricecurve'
								WHEN 'location_id' THEN 'location'
								WHEN 'formula_curve_id' THEN 'pricecurve'
								WHEN 'detail_commodity_id' THEN  'commodity'
								WHEN 'counterparty_id' THEN 'counterparty'
								WHEN 'deal_volume_uom_id' THEN 'uom'
								WHEN 'trader_id' THEN 'traders'
								WHEN 'status' THEN 'static_data_value'
								WHEN 'tier_value_id' THEN 'tier_value_id'
								WHEN 'reporting_tier_id' THEN 'reporting_tier_id'
								WHEN 'sub_book' THEN ''
								ELSE ''
							END

	IF @source_object <> ''
	BEGIN
		SET @sql = 'EXEC spa_static_data_privilege @flag = ''p'', @source_object = ''' + @source_object + ''''
		EXEC(@sql)
	END
	
	DECLARE @user_name NVARCHAR(100) = dbo.FNADBUser()
	DECLARE @is_app_admin INT = dbo.FNAAppAdminRoleCheck(@user_name)
	
	IF @source_object = 'tier_value_id'
	BEGIN
		
		IF OBJECT_ID('tempdb..#final_privilege_list_tier') IS NOT NULL
		DROP TABLE #final_privilege_list_tier

		create table #final_privilege_list_tier
		(value_id int , is_enable NVARCHAR(200) COLLATE DATABASE_DEFAULT)
		
		INSERT INTO #final_privilege_list_tier
		SELECT DISTINCT sdv.value_id, CASE WHEN ISNULL(is_enable, 1) = 1 THEN 'enable' 
		WHEN sdad.is_active = 1 AND ISNULL(is_enable, 1) = 0 
		AND @is_app_admin = 0 THEN 'disable'
		ELSE 'enable' END [state]  
		FROM static_data_value sdv
		LEFT JOIN static_data_privilege sdp
			ON sdv.value_id = sdp.value_id
		LEFT JOIN application_security_role asr
			ON sdp.role_id = asr.role_id
		LEFT JOIN application_role_user aru
			ON aru.role_id = asr.role_id
		LEFT JOIN state_properties_details spd
			ON spd.tier_id = sdv.value_id
				--AND sdv.type_id = 15000	
		LEFT JOIN static_data_active_deactive sdad on sdad.type_id = sdv.type_id
		WHERE --sdv.type_id = 15000
			 spd.state_value_id = @state_value_id
			AND (@user_name = sdp.user_id 
				OR @is_app_admin = 1 
				OR sdp.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(@user_name))
				OR ISNULL(sdad.is_active, 0) = 0
				--OR is_enable IS NULL
				)
			--Group by sdv.value_id, sdad.is_active 

			--select * from #final_privilege_list_tier

			INSERT INTO #final_privilege_list
			SELECT value_id, min(is_enable)  From  #final_privilege_list_tier group by value_id
		
	END


	IF @source_object = 'reporting_tier_id'
	BEGIN
		
		IF OBJECT_ID('tempdb..#final_privilege_list_reporting_tier') IS NOT NULL
		DROP TABLE #final_privilege_list_reporting_tier

		create table #final_privilege_list_reporting_tier
		(value_id int , is_enable NVARCHAR(200) COLLATE DATABASE_DEFAULT)
		
		INSERT INTO #final_privilege_list_reporting_tier
		SELECT DISTINCT sdv.value_id, CASE WHEN ISNULL(is_enable, 1) = 1 THEN 'enable' 
		WHEN sdad.is_active = 1 AND ISNULL(is_enable, 1) = 0 
		AND @is_app_admin = 0 THEN 'disable'
		ELSE 'enable' END [state]  
		FROM static_data_value sdv
		LEFT JOIN static_data_privilege sdp
			ON sdv.value_id = sdp.value_id
		LEFT JOIN application_security_role asr
			ON sdp.role_id = asr.role_id
		LEFT JOIN application_role_user aru
			ON aru.role_id = asr.role_id
		LEFT JOIN state_properties_details spd
			ON spd.tier_id = sdv.value_id
				--AND sdv.type_id = 15000	
		LEFT JOIN static_data_active_deactive sdad on sdad.type_id = sdv.type_id
		WHERE --sdv.type_id = 15000
			 spd.state_value_id = @reporting_jurisdiction_id
			AND (@user_name = sdp.user_id 
				OR @is_app_admin = 1 
				OR sdp.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(@user_name))
				OR ISNULL(sdad.is_active, 0) = 0
				--OR is_enable IS NULL
				)
			--Group by sdv.value_id, sdad.is_active 

			--select * from #final_privilege_list_reporting_tier

			INSERT INTO #final_privilege_list
			SELECT value_id, min(is_enable)  From  #final_privilege_list_reporting_tier group by value_id
		
	END


	IF @source_object = 'static_data_value' --Mapped for Deal Detail Status
	BEGIN
		INSERT INTO #final_privilege_list
		SELECT sdv.value_id, 'enabled'
		FROM static_data_value sdv
		LEFT JOIN static_data_privilege sdp
			ON sdv.value_id = sdp.value_id
		LEFT JOIN application_security_role asr
			ON sdp.role_id = asr.role_id
		LEFT JOIN application_role_user aru
			ON aru.role_id = asr.role_id
		LEFT JOIN static_data_active_deactive sdad
			ON sdv.type_id = sdad.type_id
		WHERE sdv.type_id = 25000	
			AND (@user_name = sdp.user_id 
				OR @is_app_admin = 1 
				OR sdp.role_id IN (SELECT role_id FROM dbo.FNAGetUserRole(@user_name))
				OR NULLIF(sdad.is_active, 0) IS NULL
			)
	END

	SELECT @field_template_id = field_template_id FROM source_deal_header_template sdht WHERE sdht.template_id = @template_id
	SELECT @blank_value = CASE WHEN ISNULL(mftd.value_required, 'n') = 'y' THEN 'n' ELSE 'y' END 
	FROM maintain_field_template_detail mftd 
	INNER JOIN maintain_field_deal mfd ON mfd.field_id = mftd.field_id
	WHERE mftd.field_template_id = @field_template_id AND mfd.farrms_field_id = @deal_fields
	
	IF @blank_value = 'y'
	BEGIN
		INSERT INTO #temp_combo(value, text)
		SELECT '', ''
	END

	IF EXISTS(SELECT 1 FROM #temp_deal_fields_mapping)
	BEGIN
		IF @deal_fields = 'counterparty_id' OR @deal_fields = 'counterparty_id2'
		BEGIN
			IF OBJECT_ID('tempdb..#temp_deal_fields_mapping_counterparty') IS NOT NULL
				DROP TABLE #temp_deal_fields_mapping_counterparty
			
			CREATE TABLE #temp_deal_fields_mapping_counterparty (
				counterparty_type NCHAR(1) COLLATE DATABASE_DEFAULT  ,
				entity_type INT,
				counterparty_id INT
			)
		
			IF OBJECT_ID('tempdb..#temp_collect_cpty') IS NOT NULL
				DROP TABLE #temp_collect_cpty
			
			CREATE TABLE #temp_collect_cpty (
				counterparty_id INT,
				counterparty_name NVARCHAR(500) COLLATE DATABASE_DEFAULT  
			)
		
			INSERT INTO #temp_deal_fields_mapping_counterparty(counterparty_type, entity_type, counterparty_id)
			SELECT dfmc.counterparty_type,
				   dfmc.entity_type,
				   dfmc.counterparty_id
			FROM deal_fields_mapping_counterparty dfmc
			INNER JOIN #temp_deal_fields_mapping t1 ON  t1.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
		
			INSERT INTO #temp_collect_cpty(counterparty_id, counterparty_name)
			SELECT sc.source_counterparty_id, CASE WHEN sc.counterparty_name <> sc.counterparty_id THEN sc.counterparty_name + ' - ' + sc.counterparty_id ELSE sc.counterparty_name END counterparty_name
			FROM #temp_deal_fields_mapping_counterparty t1
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = t1.counterparty_id
			WHERE t1.counterparty_id IS NOT NULL AND sc.is_active = 'y'
			GROUP BY sc.source_counterparty_id, CASE WHEN sc.counterparty_name <> sc.counterparty_id THEN sc.counterparty_name + ' - ' + sc.counterparty_id ELSE sc.counterparty_name END
		
			INSERT INTO #temp_collect_cpty(counterparty_id, counterparty_name)
			SELECT sc.source_counterparty_id, CASE WHEN sc.counterparty_name <> sc.counterparty_id THEN sc.counterparty_name + ' - ' + sc.counterparty_id ELSE sc.counterparty_name END counterparty_name
			FROM #temp_deal_fields_mapping_counterparty t1
			INNER JOIN source_counterparty sc
				ON sc.int_ext_flag = ISNULL(NULLIF(t1.counterparty_type, ''), sc.int_ext_flag)
				AND sc.type_of_entity = ISNULL(t1.entity_type, sc.type_of_entity)
				AND sc.is_active = 'y'
			LEFT JOIN #temp_collect_cpty t2 ON t2.counterparty_id = sc.source_counterparty_id
			WHERE t2.counterparty_id IS NULL AND t1.counterparty_id IS NULL 
			AND (NULLIF(t1.counterparty_type, '') IS NOT NULL OR t1.entity_type IS NOT NULL)
			GROUP BY sc.source_counterparty_id, CASE WHEN sc.counterparty_name <> sc.counterparty_id THEN sc.counterparty_name + ' - ' + sc.counterparty_id ELSE sc.counterparty_name END		
		
			INSERT INTO #temp_combo(value, text, state)
			SELECT t1.counterparty_id, t1.counterparty_name, MIN(fpl.is_enable)
			FROM #temp_collect_cpty t1
			INNER JOIN #final_privilege_list fpl ON fpl.value_id = t1.counterparty_id
			GROUP BY t1.counterparty_id, t1.counterparty_name	
		
			DROP TABLE #temp_collect_cpty
			DROP TABLE #temp_deal_fields_mapping_counterparty
			DROP TABLE #temp_deal_fields_mapping
		END
		ELSE IF @deal_fields = 'location_id'
		BEGIN
			IF OBJECT_ID('tempdb..#temp_deal_fields_mapping_locations') IS NOT NULL
				DROP TABLE #temp_deal_fields_mapping_locations
			
			CREATE TABLE #temp_deal_fields_mapping_locations (
				location_group INT,
				commodity_id INT,
				location_id INT
			)
		
			IF OBJECT_ID('tempdb..#temp_collect_location') IS NOT NULL
				DROP TABLE #temp_collect_location
			
			CREATE TABLE #temp_collect_location (
				location_id INT,
				location_name NVARCHAR(500) COLLATE DATABASE_DEFAULT  
			)
		
			INSERT INTO #temp_deal_fields_mapping_locations(location_group, commodity_id, location_id)
			SELECT dfmc.location_group, dfmc.commodity_id, dfmc.location_id
			FROM deal_fields_mapping_locations dfmc
			INNER JOIN #temp_deal_fields_mapping t1 ON  t1.deal_fields_mapping_id = dfmc.deal_fields_mapping_id

			INSERT INTO #temp_collect_location(location_id, location_name)
			SELECT sml.source_minor_location_id, sml.Location_Name
			FROM #temp_deal_fields_mapping_locations t1
			INNER JOIN source_minor_location sml ON sml.source_minor_location_id = t1.location_id
			WHERE t1.location_id IS NOT NULL
			GROUP BY sml.source_minor_location_id, sml.Location_Name
		
			INSERT INTO #temp_collect_location(location_id, location_name)
			SELECT sml.source_minor_location_id, sml.Location_Name
			FROM #temp_deal_fields_mapping_locations t1
			INNER JOIN source_minor_location sml 
				ON ISNULL(sml.source_major_location_ID, -1) = COALESCE(t1.location_group, sml.source_major_location_ID, -1)
				AND ISNULL(sml.Commodity_id, -1) = COALESCE(t1.commodity_id, sml.Commodity_id, -1)
			LEFT JOIN #temp_collect_location t2 ON t2.location_id = sml.source_minor_location_id
			WHERE t1.location_id IS NULL AND t2.location_id IS NULL
			AND (t1.location_group IS NOT NULL OR t1.commodity_id IS NOT NULL)
			GROUP BY sml.source_minor_location_id, sml.Location_Name
		
			INSERT INTO #temp_combo(value, text, state)
			SELECT t1.location_id, t1.location_name, MIN(fpl.is_enable)
			FROM #temp_collect_location t1
			INNER JOIN #final_privilege_list fpl ON fpl.value_id = t1.location_id
			GROUP BY t1.location_id, t1.location_name		
		
			DROP TABLE #temp_collect_location
			DROP TABLE #temp_deal_fields_mapping_locations
			DROP TABLE #temp_deal_fields_mapping
		END
		ELSE IF @deal_fields = 'contract_id'
		BEGIN
			IF OBJECT_ID('tempdb..#temp_deal_fields_mapping_contracts') IS NOT NULL
				DROP TABLE #temp_deal_fields_mapping_contracts
			
			CREATE TABLE #temp_deal_fields_mapping_contracts (
				subsidiary_id INT,
				contract_id INT
			)
		
			IF OBJECT_ID('tempdb..#temp_collect_contract') IS NOT NULL
				DROP TABLE #temp_collect_contract
			
			CREATE TABLE #temp_collect_contract(
				contract_id       INT,
				contract_name     NVARCHAR(500) COLLATE DATABASE_DEFAULT  
			)
		
			INSERT INTO #temp_deal_fields_mapping_contracts(subsidiary_id, contract_id)
			SELECT dfmc.subsidiary_id, dfmc.contract_id
			FROM deal_fields_mapping_contracts dfmc
			INNER JOIN #temp_deal_fields_mapping t1 ON  t1.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
		
			INSERT INTO #temp_collect_contract(contract_id, contract_name)
			SELECT cg.contract_id, cg.contract_name
			FROM #temp_deal_fields_mapping_contracts t1
			INNER JOIN contract_group cg ON cg.contract_id = t1.contract_id
			WHERE t1.contract_id IS NOT NULL
			GROUP BY cg.contract_id, cg.contract_name
		
			INSERT INTO #temp_collect_contract(contract_id, contract_name)
			SELECT cg.contract_id, cg.contract_name
			FROM #temp_deal_fields_mapping_contracts t1
			INNER JOIN contract_group cg ON cg.sub_id = t1.subsidiary_id
			LEFT JOIN #temp_collect_contract t2 ON t2.contract_id = cg.contract_id
			WHERE t1.contract_id IS NULL AND t2.contract_id IS NULL 
			AND t1.subsidiary_id IS NOT NULL
			GROUP BY cg.contract_id, cg.contract_name
		
			INSERT INTO #temp_combo(value, text, state)
			SELECT t1.contract_id, t1.contract_name, MIN(fpl.is_enable)
			FROM counterparty_contract_address cca
			INNER JOIN #temp_collect_contract t1 ON t1.contract_id = cca.contract_id
			INNER JOIN #final_privilege_list fpl ON fpl.value_id = t1.contract_id
			WHERE cca.counterparty_id = @counterparty_id
			GROUP BY t1.contract_id, t1.contract_name

			DROP TABLE #temp_collect_contract
			DROP TABLE #temp_deal_fields_mapping_contracts
			DROP TABLE #temp_deal_fields_mapping
		END
		ELSE IF @deal_fields = 'detail_commodity_id'
		BEGIN
			IF OBJECT_ID('tempdb..#temp_deal_fields_mapping_commodity') IS NOT NULL
				DROP TABLE #temp_deal_fields_mapping_commodity

			CREATE TABLE #temp_deal_fields_mapping_commodity (
				detail_commodity_id INT
			)

			IF OBJECT_ID('tempdb..#temp_collect_commodity') IS NOT NULL
				DROP TABLE #temp_collect_commodity

			CREATE TABLE #temp_collect_commodity (
				commodity_id INT,
				commodity_name NVARCHAR(500) COLLATE DATABASE_DEFAULT
			)

			INSERT INTO #temp_deal_fields_mapping_commodity(detail_commodity_id)
			SELECT dfmc.detail_commodity_id
			FROM deal_fields_mapping_commodity dfmc
			INNER JOIN #temp_deal_fields_mapping t1 ON  t1.deal_fields_mapping_id = dfmc.deal_fields_mapping_id

			INSERT INTO #temp_collect_commodity(commodity_id, commodity_name)
			SELECT sc.source_commodity_id, sc.commodity_name
			FROM #temp_deal_fields_mapping_commodity t1
			INNER JOIN source_commodity sc ON sc.source_commodity_id = t1.detail_commodity_id
			WHERE t1.detail_commodity_id IS NOT NULL
			GROUP BY sc.source_commodity_id, sc.commodity_name

			INSERT INTO #temp_combo(value, text, state)
			SELECT t1.commodity_id, t1.commodity_name, MIN(fpl.is_enable)
			FROM #temp_collect_commodity t1
			INNER JOIN #final_privilege_list fpl ON fpl.value_id = t1.commodity_id
			GROUP BY t1.commodity_id, t1.commodity_name

			DROP TABLE #temp_collect_commodity
			DROP TABLE #temp_deal_fields_mapping_commodity
			DROP TABLE #temp_deal_fields_mapping
		END
		ELSE IF @deal_fields = 'curve_id'
		BEGIN
			IF OBJECT_ID('tempdb..#temp_deal_fields_mapping_curves') IS NOT NULL
				DROP TABLE #temp_deal_fields_mapping_curves

			CREATE TABLE #temp_deal_fields_mapping_curves (
				commodity_id INT,
				index_group INT,
				market VARCHAR(100),
				curve_id INT,
				source_curve_type_value_id INT
			)

			IF OBJECT_ID('tempdb..#temp_collect_curves') IS NOT NULL
				DROP TABLE #temp_collect_curves

			CREATE TABLE #temp_collect_curves (
				curve_id INT,
				curve_name NVARCHAR(500) COLLATE DATABASE_DEFAULT
			)

			INSERT INTO #temp_deal_fields_mapping_curves(commodity_id, index_group, market, curve_id,source_curve_type_value_id)
			SELECT dfmc.commodity_id, dfmc.index_group, dfmc.market, dfmc.curve_id,source_curve_type_value_id
			FROM deal_fields_mapping_curves dfmc
			INNER JOIN #temp_deal_fields_mapping t1 ON  t1.deal_fields_mapping_id = dfmc.deal_fields_mapping_id

			INSERT INTO #temp_collect_curves(curve_id, curve_name)
			SELECT spcd.source_curve_def_id, spcd.curve_name
			FROM #temp_deal_fields_mapping_curves t1
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = t1.curve_id
			WHERE t1.curve_id IS NOT NULL
			GROUP BY spcd.source_curve_def_id, spcd.curve_name

			INSERT INTO #temp_collect_curves(curve_id, curve_name)
			SELECT spcd.source_curve_def_id, spcd.curve_name
			FROM #temp_deal_fields_mapping_curves t1
			INNER JOIN source_price_curve_def spcd
				ON ISNULL(spcd.index_group, -1) = COALESCE(t1.index_group, spcd.index_group, -1)
				AND ISNULL(spcd.market_value_desc, '-1') = COALESCE(t1.market, spcd.market_value_desc, '-1')
				AND ISNULL(spcd.commodity_id, -1) = COALESCE(t1.commodity_id, spcd.commodity_id, -1)
				AND ISNULL(spcd.source_curve_type_value_id, -1) = COALESCE(t1.source_curve_type_value_id, spcd.source_curve_type_value_id, -1)
			LEFT JOIN #temp_collect_curves t2 ON t2.curve_id = spcd.source_curve_def_id
			WHERE t1.curve_id IS NULL AND t2.curve_id IS NULL
			AND (t1.index_group IS NOT NULL OR t1.market IS NOT NULL OR t1.commodity_id IS NOT NULL OR t1.source_curve_type_value_id IS NOT NULL)
			GROUP BY spcd.source_curve_def_id, spcd.curve_name

			INSERT INTO #temp_combo(value, text, state)
			SELECT t1.curve_id, t1.curve_name, MIN(fpl.is_enable)
			FROM #temp_collect_curves t1
			INNER JOIN #final_privilege_list fpl ON fpl.value_id = t1.curve_id
			GROUP BY t1.curve_id, t1.curve_name

			DROP TABLE #temp_collect_curves
			DROP TABLE #temp_deal_fields_mapping_curves
			DROP TABLE #temp_deal_fields_mapping
		END
		ELSE IF @deal_fields = 'formula_curve_id'
		BEGIN
			IF OBJECT_ID('tempdb..#temp_deal_fields_mapping_formula_curves') IS NOT NULL
				DROP TABLE #temp_deal_fields_mapping_formula_curves

			CREATE TABLE #temp_deal_fields_mapping_formula_curves (
				commodity_id INT,
				index_group INT,
				market INT,
				formula_curve_id INT,
				source_curve_type_value_id INT
			)

			IF OBJECT_ID('tempdb..#temp_collect_formula_curves') IS NOT NULL
				DROP TABLE #temp_collect_formula_curves

			CREATE TABLE #temp_collect_formula_curves (
				curve_id INT,
				curve_name NVARCHAR(500) COLLATE DATABASE_DEFAULT
			)

			INSERT INTO #temp_deal_fields_mapping_formula_curves(commodity_id, index_group, market, formula_curve_id,source_curve_type_value_id)
			SELECT dfmc.commodity_id, dfmc.index_group, dfmc.market, dfmc.formula_curve_id,source_curve_type_value_id
			FROM deal_fields_mapping_formula_curves dfmc
			INNER JOIN #temp_deal_fields_mapping t1 ON  t1.deal_fields_mapping_id = dfmc.deal_fields_mapping_id

			INSERT INTO #temp_collect_formula_curves(curve_id, curve_name)
			SELECT spcd.source_curve_def_id, spcd.curve_name
			FROM #temp_deal_fields_mapping_formula_curves t1
			INNER JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = t1.formula_curve_id
			WHERE t1.formula_curve_id IS NOT NULL
			GROUP BY spcd.source_curve_def_id, spcd.curve_name

			INSERT INTO #temp_collect_formula_curves(curve_id, curve_name)
			SELECT spcd.source_curve_def_id, spcd.curve_name
			FROM #temp_deal_fields_mapping_formula_curves t1
			INNER JOIN source_price_curve_def spcd
				ON ISNULL(spcd.index_group, -1) = COALESCE(t1.index_group, spcd.index_group, -1)
				AND ISNULL(spcd.market_value_desc, -1) = COALESCE(t1.market, spcd.market_value_desc, -1)
				AND ISNULL(spcd.commodity_id, -1) = COALESCE(t1.commodity_id, spcd.commodity_id, -1)
				AND ISNULL(spcd.source_curve_type_value_id, -1) = COALESCE(t1.source_curve_type_value_id, spcd.source_curve_type_value_id, -1)
			LEFT JOIN #temp_collect_formula_curves t2 ON t2.curve_id = spcd.source_curve_def_id
			WHERE t1.formula_curve_id IS NULL AND t2.curve_id IS NULL
			AND (t1.index_group IS NOT NULL OR t1.market IS NOT NULL OR t1.commodity_id IS NOT NULL OR t1.source_curve_type_value_id IS NOT NULL)
			GROUP BY spcd.source_curve_def_id, spcd.curve_name
		
			INSERT INTO #temp_combo(value, text, state)
			SELECT t1.curve_id, t1.curve_name, MIN(fpl.is_enable)
			FROM #temp_collect_formula_curves t1
			INNER JOIN #final_privilege_list fpl ON fpl.value_id = t1.curve_id
			GROUP BY t1.curve_id, t1.curve_name		
		
			DROP TABLE #temp_collect_formula_curves
			DROP TABLE #temp_deal_fields_mapping_formula_curves
			DROP TABLE #temp_deal_fields_mapping
		END
		ELSE IF @deal_fields = 'trader_id'
		BEGIN
			IF OBJECT_ID('tempdb..#temp_deal_fields_mapping_trader') IS NOT NULL
				DROP TABLE #temp_deal_fields_mapping_trader
			
			CREATE TABLE #temp_deal_fields_mapping_trader (
				trader_id INT
			)
		
			IF OBJECT_ID('tempdb..#temp_collect_trader') IS NOT NULL
				DROP TABLE #temp_collect_trader
			
			CREATE TABLE #temp_collect_trader (
				trader_id INT,
				trader_name NVARCHAR(500) COLLATE DATABASE_DEFAULT  
			)
		
			INSERT INTO #temp_deal_fields_mapping_trader(trader_id)
			SELECT dfmc.trader_id
			FROM deal_fields_mapping_trader dfmc
			INNER JOIN #temp_deal_fields_mapping t1 ON  t1.deal_fields_mapping_id = dfmc.deal_fields_mapping_id

			INSERT INTO #temp_collect_trader(trader_id, trader_name)
			SELECT sc.source_trader_id, sc.trader_name
			FROM #temp_deal_fields_mapping_trader t1
			INNER JOIN source_traders sc ON sc.source_trader_id = t1.trader_id
			WHERE t1.trader_id IS NOT NULL
			GROUP BY sc.source_trader_id, sc.trader_name

		
			INSERT INTO #temp_combo(value, text, state)
			SELECT t1.trader_id, t1.trader_name, MIN(fpl.is_enable)
			FROM #temp_collect_trader t1
			INNER JOIN #final_privilege_list fpl ON fpl.value_id = t1.trader_id
			GROUP BY t1.trader_id, t1.trader_name		

			DROP TABLE #temp_collect_trader
			DROP TABLE #temp_deal_fields_mapping_trader
			DROP TABLE #temp_deal_fields_mapping
		END
		ELSE IF @deal_fields = 'status'
		BEGIN
			IF OBJECT_ID('tempdb..#temp_deal_fields_mapping_detail_status') IS NOT NULL
				DROP TABLE #temp_deal_fields_mapping_detail_status
			
			CREATE TABLE #temp_deal_fields_mapping_detail_status (
				detail_status_id INT
			)
		
			IF OBJECT_ID('tempdb..#temp_collect_detail_status') IS NOT NULL
				DROP TABLE #temp_collect_detail_status
			
			CREATE TABLE #temp_collect_detail_status (
				detail_status_id INT,
				detail_status_name NVARCHAR(500) COLLATE DATABASE_DEFAULT  
			)
		
			INSERT INTO #temp_deal_fields_mapping_detail_status(detail_status_id)
			SELECT dfmc.detail_status_id
			FROM deal_fields_mapping_detail_status dfmc
			INNER JOIN #temp_deal_fields_mapping t1 ON  t1.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
		
			INSERT INTO #temp_collect_detail_status(detail_status_id, detail_status_name)
			SELECT sc.value_id, sc.code
			FROM #temp_deal_fields_mapping_detail_status t1
			INNER JOIN static_data_value sc ON sc.value_id = t1.detail_status_id and sc.type_id = 25000
			WHERE t1.detail_status_id IS NOT NULL
			GROUP BY  sc.value_id, sc.code
		
			INSERT INTO #temp_combo(value, text, state)
			SELECT t1.detail_status_id, t1.detail_status_name, MIN(fpl.is_enable)
			FROM #temp_collect_detail_status t1
			INNER JOIN #final_privilege_list fpl ON fpl.value_id = t1.detail_status_id
			GROUP BY t1.detail_status_id, t1.detail_status_name		
		
			DROP TABLE #temp_collect_detail_status
			DROP TABLE #temp_deal_fields_mapping_detail_status
			DROP TABLE #temp_deal_fields_mapping
		END
		ELSE IF @deal_fields = 'deal_volume_uom_id'
		BEGIN
			IF OBJECT_ID('tempdb..#temp_deal_fields_mapping_uom') IS NOT NULL
				DROP TABLE #temp_deal_fields_mapping_uom
			
			CREATE TABLE #temp_deal_fields_mapping_uom (
				uom_id INT
			)
		
			IF OBJECT_ID('tempdb..#temp_collect_uom') IS NOT NULL
				DROP TABLE #temp_collect_uom
			
			CREATE TABLE #temp_collect_uom (
				uom_id INT,
				uom_name NVARCHAR(500) COLLATE DATABASE_DEFAULT  
			)
		
			INSERT INTO #temp_deal_fields_mapping_uom(uom_id)
			SELECT dfmc.uom_id
			FROM deal_fields_mapping_uom dfmc
			INNER JOIN #temp_deal_fields_mapping t1 ON  t1.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
		
			INSERT INTO #temp_collect_uom(uom_id, uom_name)
			SELECT sc.source_uom_id, sc.uom_name
			FROM #temp_deal_fields_mapping_uom t1
			INNER JOIN source_uom sc ON sc.source_uom_id = t1.uom_id
			WHERE t1.uom_id IS NOT NULL
			GROUP BY sc.source_uom_id, sc.uom_name
		
			INSERT INTO #temp_combo(value, text, state)
			SELECT t1.uom_id, t1.uom_name, MIN(fpl.is_enable)
			FROM #temp_collect_uom t1
			INNER JOIN #final_privilege_list fpl ON fpl.value_id = t1.uom_id
			GROUP BY t1.uom_id, t1.uom_name		
		
			DROP TABLE #temp_collect_uom
			DROP TABLE #temp_deal_fields_mapping_uom
			DROP TABLE #temp_deal_fields_mapping
		END
		ELSE IF @deal_fields = 'sub_book'
		BEGIN
			IF OBJECT_ID('tempdb..#temp_deal_fields_mapping_sub_book') IS NOT NULL
				DROP TABLE #temp_deal_fields_mapping_sub_book
			
			CREATE TABLE #temp_deal_fields_mapping_sub_book (
				sub_book_id INT
			)
		
			IF OBJECT_ID('tempdb..#temp_collect_sub_book') IS NOT NULL
				DROP TABLE #temp_collect_sub_book
			
			CREATE TABLE #temp_collect_sub_book (
				sub_book_id INT,
				logical_name NVARCHAR(500) COLLATE DATABASE_DEFAULT  
			)
		
			INSERT INTO #temp_deal_fields_mapping_sub_book(sub_book_id)
			SELECT dfmc.sub_book_id
			FROM deal_fields_mapping_sub_book dfmc
			INNER JOIN #temp_deal_fields_mapping t1 ON  t1.deal_fields_mapping_id = dfmc.deal_fields_mapping_id
		
			INSERT INTO #temp_collect_sub_book(sub_book_id, logical_name)
			SELECT sc.book_deal_type_map_id, sc.logical_name
			FROM #temp_deal_fields_mapping_sub_book t1
			INNER JOIN source_system_book_map sc ON sc.book_deal_type_map_id = t1.sub_book_id
			WHERE t1.sub_book_id IS NOT NULL
			GROUP BY sc.book_deal_type_map_id, sc.logical_name
		
			INSERT INTO #temp_combo(value, text, state)
			SELECT t1.sub_book_id, t1.logical_name, 1
			FROM #temp_collect_sub_book t1
			GROUP BY t1.sub_book_id, t1.logical_name		
		
			DROP TABLE #temp_collect_sub_book
			DROP TABLE #temp_deal_fields_mapping_sub_book
			DROP TABLE #temp_deal_fields_mapping
		END
	END
		
	IF @deal_fields = 'counterparty_trader' OR @deal_fields = 'counterparty2_trader'
	BEGIN
		--IF @counterparty_id IS NOT NULL
		--BEGIN			
			INSERT INTO #temp_combo(value, text)
			SELECT cc.counterparty_contact_id,
				   cc.name
			FROM counterparty_contacts cc
			INNER JOIN static_data_value sdv ON  cc.contact_type = sdv.value_id
			WHERE sdv.value_id = -32200 AND sdv.type_id = 32200 AND cc.counterparty_id = @counterparty_id
			ORDER BY cc.name  
		--END
	END 
	
	IF @deal_fields = 'tier_value_id'
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM #temp_combo WHERE value <> '')
		BEGIN
			INSERT INTO #temp_combo(value, text, state)
			SELECT sdv.value_id, sdv.code, fpl.is_enable
			FROM static_data_value sdv
			INNER JOIN #final_privilege_list fpl ON fpl.value_id = sdv.value_id
		END
	END


	IF @deal_fields = 'reporting_tier_id'
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM #temp_combo WHERE value <> '')
		BEGIN
			INSERT INTO #temp_combo(value, text, state)
			SELECT sdv.value_id, sdv.code, fpl.is_enable
			FROM static_data_value sdv
			INNER JOIN #final_privilege_list fpl ON fpl.value_id = sdv.value_id
		END
	END

	IF @deal_fields = 'contract_id'
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM #temp_combo WHERE value <> '')
		BEGIN
			INSERT INTO #temp_combo(value, text, state)
			SELECT cg.contract_id, CASE WHEN cg.source_contract_id <> cg.contract_name THEN  cg.source_contract_id + ' - ' + cg.contract_name ELSE contract_name END contract_name, MIN(fpl.is_enable)
			FROM counterparty_contract_address cca
			INNER JOIN contract_group cg ON cg.contract_id = cca.contract_id
			INNER JOIN #final_privilege_list fpl ON fpl.value_id = cg.contract_id
			WHERE cca.counterparty_id = @counterparty_id
			GROUP BY cg.contract_id, CASE WHEN cg.source_contract_id <> cg.contract_name THEN  cg.source_contract_id + ' - ' + cg.contract_name ELSE contract_name END
		END
	END
	
	IF @deal_fields IN ('shipper_code1', 'shipper_code2') 
	BEGIN
		DECLARE @deal_date_rule INT  ,
		@deal_date DATETIME, @term_rule INT, @term_frequency NCHAR(1), @latest_start_eff_dt DATETIME

		SELECT @deal_date_rule = sdht.deal_date_rule,
				@term_rule = sdht.term_rule,
				@term_frequency =  sdht.term_frequency_type
		FROM dbo.source_deal_header_template sdht
		WHERE sdht.template_id = @template_id 	

		IF @deal_date IS NULL
			SET @deal_date = CONVERT(DATE, GETDATE())

		IF NULLIF(@term_start, '') IS NULL
		BEGIN
			SET @deal_date = dbo.FNAResolveDate(@deal_date, @deal_date_rule)
			SET @term_start = dbo.FNAResolveDate(@deal_date, @term_rule)
			
			IF @deal_date = @term_start
			BEGIN
				IF @term_frequency = 'd'
					SET @term_start = DATEADD(day, 1, @term_start)
				IF @term_frequency = 'm'
					SET @term_start = DATEADD(m, DATEDIFF(m, -1, @term_start), 0) 
			END
		END

		IF OBJECT_ID('tempdb..#temp_collect_shipper_code') IS NOT NULL
			DROP TABLE #temp_collect_shipper_code
			
		CREATE TABLE #temp_collect_shipper_code (
			shipper_code_id INT,
			shipper_code NVARCHAR(500) COLLATE DATABASE_DEFAULT,
			is_default NCHAR(1) COLLATE DATABASE_DEFAULT,
			effective_date DATETIME
		)
		
		IF @contract_id IS NOT NULL
			SELECT @location_id = location_id FROM transportation_contract_location WHERE contract_id = @contract_id AND rec_del = IIF (@buy_sell_flag = 'b', 2, 1)

		INSERT INTO #temp_collect_shipper_code(shipper_code_id, shipper_code, is_default, effective_date)
		SELECT scmd.shipper_code_mapping_detail_id, 
			IIF(@deal_fields = 'shipper_code1',scmd.shipper_code1, scmd.shipper_code), 
			IIF(@deal_fields = 'shipper_code1',scmd.shipper_code1_is_default, scmd.is_default), 
			scmd.effective_date
		FROM shipper_code_mapping sscm
		INNER JOIN shipper_code_mapping_detail scmd ON scmd.shipper_code_id = sscm.shipper_code_id				
		WHERE sscm.counterparty_id = @counterparty_id AND scmd.is_active = 'y' AND scmd.[location_id] = @location_id 
		AND (
			(MONTH(scmd.effective_date) <= MONTH(@term_start) AND YEAR(scmd.effective_date) <= YEAR(@term_start) )
			OR (YEAR(scmd.effective_date) < YEAR(@term_start) AND scmd.effective_date < @term_start) 
		)

		DECLARE @dup_shipper_code NVARCHAR(200), @effective_date DATETIME
		DECLARE remove_duplicate CURSOR FOR
		
		SELECT DISTINCT shipper_code, effective_date FROM 
		(SELECT tcsc.* FROM #temp_collect_shipper_code tcsc
			CROSS APPLY (SELECT shipper_code FROM #temp_collect_shipper_code GROUP BY shipper_code 		
				HAVING COUNT(shipper_code)> 1) dupli
			CROSS APPLY (SELECT shipper_code, MAX(effective_date) effective_date FROM #temp_collect_shipper_code inn 
				WHERE inn.shipper_code = dupli.shipper_code GROUP BY inn.shipper_code )  latest
			WHERE tcsc.shipper_code = latest.shipper_code AND tcsc.effective_date = latest.effective_date
		) fitlered

		OPEN remove_duplicate
		FETCH NEXT FROM remove_duplicate
		INTO @dup_shipper_code, @effective_date
		WHILE @@FETCH_STATUS = 0
		BEGIN	
			DELETE FROM #temp_collect_shipper_code WHERE shipper_code = @dup_shipper_code AND effective_date != @effective_date
			IF EXISTS (SELECT 1 FROM #temp_collect_shipper_code WHERE shipper_code = @dup_shipper_code AND is_default = 'y')
			BEGIN
				DELETE FROM #temp_collect_shipper_code WHERE shipper_code = @dup_shipper_code		
				AND is_default != 'y'
			END
			ELSE
			BEGIN
				DELETE FROM #temp_collect_shipper_code WHERE shipper_code_id NOT IN 
				(SELECT MIN(shipper_code_id) FROM #temp_collect_shipper_code WHERE shipper_code = @dup_shipper_code )
				AND shipper_code = @dup_shipper_code
			END
			FETCH NEXT FROM remove_duplicate INTO @dup_shipper_code, @effective_date
		END
		CLOSE remove_duplicate
		DEALLOCATE remove_duplicate

		IF NOT EXISTS(SELECT 1 FROM #temp_combo WHERE value <> '')
		BEGIN
			INSERT INTO #temp_combo(value, text, state)
			SELECT shipper_code_id, shipper_code, 'Enable' FROM #temp_collect_shipper_code
			
			IF NOT EXISTS (SELECT 1 FROM #temp_combo WHERE value = @default_value) 
				SET @default_value= NULL

			SELECT TOP 1 @latest_start_eff_dt = effective_date 
			FROM #temp_collect_shipper_code 
			WHERE (MONTH(effective_date) < MONTH(@term_start) AND YEAR(effective_date) <= YEAR(@term_start) )
					OR (YEAR(effective_date) < YEAR(@term_start) AND effective_date < @term_start) 
			ORDER BY effective_date DESC				

			SELECT TOP 1 @default_value = IIF(@deal_id IS NOT NULL, @default_value, tcsc.shipper_code_id)
			FROM #temp_collect_shipper_code tcsc
			INNER JOIN #temp_combo tc ON tc.value = tcsc.shipper_code_id
			OUTER APPLY (SELECT shipper_code_id FROM #temp_collect_shipper_code WHERE is_default = 'y' AND YEAR(effective_date) = YEAR(@latest_start_eff_dt) AND MONTH(effective_date) = MONTH(@latest_start_eff_dt)) a
			WHERE 1=1
			AND (MONTH(effective_date) = MONTH(@term_start) AND YEAR(effective_date) = YEAR(@term_start) AND is_default = 'y') 
			OR  (
					(
						(MONTH(effective_date) < MONTH(@term_start) AND YEAR(effective_date) = YEAR(@term_start) ) 
						OR  (YEAR(effective_date) < YEAR(@term_start) AND effective_date < @term_start) 
					)
					AND NOT EXISTS (SELECT 1 FROM #temp_collect_shipper_code WHERE MONTH(effective_date) = MONTH(@term_start) AND YEAR(effective_date) = YEAR(@term_start)) 
					AND tcsc.shipper_code_id = a.shipper_code_id 
			) 
			ORDER BY shipper_code ASC 

			IF NULLIF(@default_value, '') IS NULL			
			BEGIN
				SELECT TOP 1 @latest_start_eff_dt = effective_date 
				FROM #temp_collect_shipper_code 			
				ORDER BY effective_date DESC

				SELECT TOP 1 @shipper_default_value = shipper_code_id
				FROM #temp_collect_shipper_code tcsc
				INNER JOIN #temp_combo tc ON tc.value = tcsc.shipper_code_id
				OUTER APPLY ( SELECT TOP 1 effective_date 
					FROM #temp_collect_shipper_code WHERE YEAR(effective_date) = YEAR(@latest_start_eff_dt) 
					AND MONTH(@latest_start_eff_dt) = MONTH(effective_date)
					ORDER BY shipper_code ASC
				) a
				WHERE tcsc.effective_date = CASE WHEN (MONTH(tcsc.effective_date) = MONTH(@term_start) AND YEAR(tcsc.effective_date) = YEAR(@term_start) )
										THEN tcsc.effective_date 
										WHEN (
											MONTH(tcsc.effective_date) < MONTH(@term_start) AND YEAR(tcsc.effective_date) = YEAR(@term_start) 
											OR (YEAR(tcsc.effective_date) < YEAR(@term_start) AND tcsc.effective_date < @term_start) 
											) THEN a.effective_date
										END
				ORDER BY shipper_code ASC
			END

		END
	END
	IF @deal_fields <> 'counterparty_trader' AND @deal_fields <> 'counterparty2_trader' AND @deal_fields <> 'contract_id' AND @deal_fields <> 'tier_value_id' AND @deal_fields <> 'reporting_tier_id' AND @deal_fields <> 'shipper_code2' AND @deal_fields <> 'shipper_code1'
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM #temp_combo WHERE value <> '')
		BEGIN	
			SELECT @sql_query = mfd.sql_string
			FROM maintain_field_deal mfd
			WHERE mfd.farrms_field_id = @deal_fields
			
			BEGIN TRY				
				INSERT INTO #temp_combo([value], [text], [state])
				EXEC(@sql_query)
			END TRY
			BEGIN CATCH				
				INSERT INTO #temp_combo([value], [text])
				EXEC(@sql_query)
			END CATCH
		END
	END
	
	IF @load_default = 1
	BEGIN
		UPDATE #temp_combo
		SET selected = 'true'
		WHERE value = ISNULL(@default_value, @shipper_default_value)
	END
	ELSE IF @load_default = 0
	BEGIN
		UPDATE #temp_combo
		SET selected = 'true'
		WHERE value = @default_value
	END

	IF @flag = 'v'
	BEGIN
		IF @deal_fields IN ('shipper_code1', 'shipper_code2') 
		BEGIN 
			SET @default_value = @shipper_default_value 
		END

		SET @json_string = @default_value
		RETURN
	END
	
	IF @process_table IS NULL
	BEGIN
		DECLARE @dropdown_xml XML
		DECLARE @param NVARCHAR(100)
		DECLARE @nsql NVARCHAR(4000)
		DECLARE @json NVARCHAR(MAX)
	
		SET @param = N'@dropdown_xml XML OUTPUT';

		SET @nsql = ' SET @dropdown_xml = (SELECT [value], [text], [state], [selected]
						FROM #temp_combo ORDER BY [text] ASC
						FOR XML RAW (''row''), ROOT (''root''), ELEMENTS)'
	
		EXECUTE sp_executesql @nsql, @param,  @dropdown_xml = @dropdown_xml OUTPUT;
		SET @dropdown_xml = REPLACE(CAST(@dropdown_xml AS NVARCHAR(MAX)), '"', '\"')
		SET @json = dbo.FNAFlattenedJSON(@dropdown_xml)
	
		IF @flag = 's'
		BEGIN		
			IF CHARINDEX('[', @json, 0) <= 0
				SET @json = '{"options":[' + @json + ']}'
			ELSE
				SET @json = '{"options":' + @json + '}'
	
			SELECT @json json_string
		END
		ELSE 
		BEGIN
			SET @json_string = @json
		END		
	END	
	ELSE
	BEGIN
		EXEC('SELECT * INTO ' + @process_table + ' FROM #temp_combo')
	END		
END