IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_company_info]') AND type IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_company_info]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	CRUD for company info

	Parameters
	@flag : Flag
			'i' -- Insert company information
			's' -- Get company information
			'u' -- Update company information
			'c' -- Gets farrms client configuration for the application
			'a' -- Gets SSRS settings, UI Setttings, Dynamic Calendar Dropdown and Date Format 
				   Including farrms client configuration for the application
	@company_id : Company Id
	@company_name : Name of the company
	@address1 : Company address
	@address2 : Alternative company address
	@contactphone : Phone number
	@city : City
	@state : State
	@zipcode : ZIP
	@country : Country
	@app_user_name : User login Id
	@company_code : Unique Code to refer company
	@phone_format : Phone format - Farrms Config
	@decimal_separator : Decimal separator - Farrms Config
	@group_separator : Group separator - Farrms Config
	@price_rounding : Default price column rounding value - Farrms Config
	@volume_rounding : Default volume column rounding value - Farrms Config
	@amount_rounding : Default amount column rounding value - Farrms Config
	@number_rounding : Default numeric column rounding value - Farrms Config
*/
CREATE PROCEDURE [dbo].[spa_company_info]
	@flag VARCHAR(1),
	@company_id INT = NULL,
	@company_name VARCHAR(250) = NULL,
	@address1 VARCHAR(250) = NULL,
	@address2 VARCHAR(250) = NULL,
	@contactphone VARCHAR(250) = NULL,
	@city VARCHAR(250) = NULL,
	@state VARCHAR(250) = NULL,
	@zipcode VARCHAR(250) = NULL,
	@country VARCHAR(250) = NULL,
	@app_user_name VARCHAR(64) = NULL,
	@company_code VARCHAR(64) = NULL,
	@phone_format CHAR(1) = NULL,
	@decimal_separator CHAR(1) = NULL,
	@group_separator CHAR(1) = NULL,
	@price_rounding INT = NULL,
	@volume_rounding INT = NULL,
	@amount_rounding INT = NULL,
	@number_rounding INT = NULL
AS
SET NOCOUNT ON
DECLARE @sql_stmt VARCHAR(1000)
DECLARE @error_no INT

IF @flag = 'i'
BEGIN
	BEGIN TRY
		INSERT INTO company_info(company_name, address1, address2, contactphone, city, [state], zipcode, country
							, company_code
							, phone_format
							, decimal_separator
							, group_separator
							, price_rounding
							, volume_rounding
							, amount_rounding
							, number_rounding
							)
		VALUES(@company_name, @address1, @address2, @contactphone, @city, @state, @zipcode, @country
							, @company_code
							, @phone_format
							, @decimal_separator
							, @group_separator
							, @price_rounding
							, @volume_rounding
							, @amount_rounding
							, @number_rounding
			  )

		EXEC spa_ErrorHandler 0, 'Company Info Setup',
				'spa_company_info', 'Success',
				'Changes has been saved successfully.', ''
	END TRY
	BEGIN CATCH
		SET @error_no = ERROR_NUMBER()
		EXEC spa_ErrorHandler @error_no, 'Company Info Setup',
				'spa_company_info', 'Error',
				'Failed to save data.', ''
	END CATCH
END
ELSE IF @flag = 's'
BEGIN
	SELECT company_id, company_name, address1, address2, contactphone, city, [state], zipcode, country
	FROM company_info
	WHERE company_name = @company_name
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
		UPDATE company_info
			SET company_name = @company_name,
				address1 = @address1,
				address2 = @address2,
				contactphone = @contactphone,
				city = @city,
				[state] = @state,
				zipcode = @zipcode,
				country = @country,
				company_code = @company_code,
				phone_format = @phone_format,
				decimal_separator = @decimal_separator,
				group_separator = @group_separator,
				price_rounding = @price_rounding,
				volume_rounding = @volume_rounding,
				amount_rounding = @amount_rounding,
				number_rounding = @number_rounding
		WHERE company_id = @company_id

		EXEC spa_ErrorHandler 0, 'Company Info Setup',
				'spa_company_info', 'Success',
				'Changes has been saved successfully.', ''
	END TRY
	BEGIN CATCH
		SET @error_no = ERROR_NUMBER()
		EXEC spa_ErrorHandler @error_no, 'Company Info Setup',
				'spa_company_info', 'Error',
				'Failed to save data.', ''
	END CATCH
END
-- ## Get the farrms configurations variable (previously defined in farrms.client.config.ini.php)
ELSE IF @flag = 'c'
BEGIN
	SELECT	ISNULL(country, 'US') [country]
			,phone_format
			,decimal_separator [global_decimal_separator]
			,group_separator [global_group_separator]
	FROM company_info
END
-- ## Get SSRS settings, UI Setttings, Dynamic Calendar Dropdown and Date Format
-- ## and the farrms configurations variable (previously defined in farrms.client.config.ini.php)
ELSE IF @flag = 'a'
BEGIN
	SELECT
		'farrms_client_configs' category
		, category_code
		, category_value
	FROM (
		SELECT	CAST(ISNULL(country, 'US') AS VARCHAR(16)) [country]
			, CAST(IIF(number_rounding = 0,'0,000','0,000.' + REPLICATE('0', ISNULL(number_rounding,4))) AS VARCHAR(16)) [global_number_format]
			, CAST(IIF(price_rounding = 0,'0,000','0,000.' + REPLICATE('0', ISNULL(price_rounding,4))) AS VARCHAR(16)) [global_price_format]
			, CAST(IIF(amount_rounding = 0,'0,000','0,000.' + REPLICATE('0', ISNULL(amount_rounding,4))) AS VARCHAR(16)) [global_amount_format]
			, CAST(IIF(volume_rounding = 0,'0,000','0,000.' + REPLICATE('0', ISNULL(volume_rounding,4))) AS VARCHAR(16)) [global_volume_format]
			,CAST(phone_format AS VARCHAR(16)) [phone_format]
			,CAST(ISNULL(tbl_au.decimal_separator, ci.decimal_separator) AS VARCHAR(16)) [global_decimal_separator]
			,CAST(ISNULL(tbl_au.group_separator, ci.group_separator) AS VARCHAR(16)) [global_group_separator]
			,CAST(LOWER(company_code) AS VARCHAR(16)) [company_code]
			,CAST(ISNULL(price_rounding,4) AS VARCHAR(16)) [global_price_rounding]
			,CAST(ISNULL(volume_rounding,4) AS VARCHAR(16)) [global_volume_rounding]
			,CAST(ISNULL(amount_rounding,4) AS VARCHAR(16)) [global_amount_rounding]
			,CAST(ISNULL(number_rounding,4) AS VARCHAR(16)) [global_number_rounding]
		FROM company_info ci
		OUTER APPLY( SELECT au.decimal_separator [decimal_separator]
						  , CASE au.group_separator WHEN '''' THEN '\'''
													WHEN 's' THEN ' '
													WHEN 'n' THEN ''
													ELSE au.group_separator 
							END [group_separator]
					 FROM application_users au
					 WHERE user_login_id = @app_user_name
		) tbl_au
	) p
	UNPIVOT (category_value FOR category_code IN ([country], [global_number_format], [global_price_format], phone_format, global_decimal_separator, global_group_separator, [company_code], [global_price_rounding], [global_volume_rounding], [global_amount_rounding], [global_number_rounding], [global_amount_format], [global_volume_format])
	) AS unpvt
	UNION
	SELECT
		'farrms_client_configs' category
		, category_code
		, category_value
	FROM (
		SELECT	CAST([date_format] AS VARCHAR(16)) [date_format],
				CAST(COALESCE(dbo.FNAChangeDateFormat(), '%Y-%m-%d') AS VARCHAR(16)) AS [dhtmlx_date_format],
				CAST([language] AS VARCHAR(16)) AS [language]
		FROM application_users au
		INNER JOIN region r ON au.region_id = r.region_id
		WHERE au.user_login_id = @app_user_name
	) p
	UNPIVOT (category_value FOR category_code IN ([date_format], [dhtmlx_date_format], [language])) AS unpvt
	UNION
	SELECT
		'ui_settings' category
		, REPLACE(LOWER(adcv.description), ' ', '_') [category_code]
		, adcv.var_value [category_value]
	FROM adiha_default_codes adc
	INNER JOIN adiha_default_codes_values adcv ON adcv.default_code_id = adc.default_code_id
	WHERE default_code = 'application_ui_template_settings'
	UNION
	SELECT
		'farrms_client_configs' category
		, category_code
		, category_value
	FROM (
		SELECT
			CAST(report_server_user_name AS VARCHAR(200)) report_server_user_name
			, CAST(report_server_domain AS VARCHAR(200)) report_server_domain
			, CAST(report_server_datasource_name AS VARCHAR(200)) report_server_datasource_name
			, CAST(report_server_target_folder AS VARCHAR(200)) report_server_target_folder
			, CAST(dbo.FNADecrypt(report_server_password) AS VARCHAR(200)) report_server_password
			, CAST(report_server_url AS VARCHAR(200)) report_server_url
			,CAST(ISNULL(saas_module_type,'') AS VARCHAR(200)) saas_module_type
		FROM connection_string
	) p
	UNPIVOT (category_value FOR category_code IN (
				report_server_user_name
				, report_server_domain
				, report_server_datasource_name
				, report_server_target_folder
				, report_server_password
				, report_server_url
				, saas_module_type
			)
	) AS unpvt
	UNION
	SELECT
		'dynamic_date_options' category, code category_code, CAST(value_id AS VARCHAR(100)) category_value
	FROM static_data_value
	WHERE type_id = 45600

END