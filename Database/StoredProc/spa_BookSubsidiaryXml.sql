
IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_BookSubsidiaryXml]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_BookSubsidiaryXml]

/**
 Stored Procedure to Insert/Update data in fas_subsidiaries. 
 Parameters
	@flag : Operation flag optional
			i - insert data in fas_subsidiaries.  
			u - update data in fas_subsidiaries.			
	@xml : xml data.
	

*/
 
 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_BookSubsidiaryXml]
	@flag CHAR(1),
	@xml NVARCHAR(MAX)

AS

SET NOCOUNT ON

--DECLARE @fas_subsidiary_id INT 

BEGIN TRY
	
	DECLARE @id INT 
	DECLARE @idoc INT
	DECLARE @doc NVARCHAR(1000)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	SELECT 
		NULLIF(fas_subsidiary_id, '') fas_subsidiary_id
		, NULLIF([entity_name], '') [entity_name] 
		, NULLIF(func_cur_value_id, '')  func_cur_value_id
		, NULLIF(counterparty_id , '') counterparty_id
		, NULLIF(entity_type_value_id, '')  entity_type_value_id
		, NULLIF(disc_source_value_id, '')   disc_source_value_id
		, NULLIF(disc_type_value_id, '')  disc_type_value_id
		, NULLIF(risk_free_curve_id, '')  risk_free_curve_id
		, NULLIF(discount_curve_id, '')  discount_curve_id
		, NULLIF(days_in_year, '')  days_in_year
		, NULLIF(long_term_months, '')  long_term_months
		, NULLIF(tax_perc, '')  tax_perc
		, NULLIF(timezone_id, '')  timezone_id
		, NULLIF(fx_conversion_market, '') fx_conversion_market
		, NULLIF(entity_name_o, '')  entity_name_o
		, NULLIF(primary_naics_code_id, '')  primary_naics_code_id
		, NULLIF(address1, '')  address1
		, NULLIF(secondary_naics_code_id, '')  secondary_naics_code_id
		, NULLIF(address2, '')  address2
		, NULLIF(entity_category_id, '')  entity_category_id
		, NULLIF(city, '')  city
		, NULLIF(entity_sub_category_id, '')  entity_sub_category_id
		, NULLIF(state_value_id, '')  state_value_id
		, NULLIF(utility_type_id, '')  utility_type_id
		, NULLIF(zip_code, '')  zip_code
		, NULLIF(ticker_symbol_id, '')  ticker_symbol_id
		, NULLIF(country_value_id, '')  country_value_id
		, NULLIF(entity_url, '')  entity_url
		, NULLIF(tax_payer_id, '')  tax_payer_id
		, NULLIF(contact_user_id, '')  contact_user_id
		, NULLIF(ownership_status, '')  ownership_status
		, NULLIF(partners, '')  partners
		, NULLIF(base_year_from, '')  base_year_from
		, NULLIF(base_year_to, '')  base_year_to
		, NULLIF(organization_boundaries, '')  organization_boundaries
		, NULLIF(confidentiality_info , '') confidentiality_info
		, NULLIF(holding_company, '')  holding_company
		, NULLIF(exclude_indirect_emissions , '') exclude_indirect_emissions
		, NULLIF(accounting_code, '') accounting_code
	INTO #ztbl_xmlvalue
	
	FROM OPENXML (@idoc, '/Root/FormXML', 2)
		 WITH (	 fas_subsidiary_id  INT  '@fas_subsidiary_id',
				 [entity_name] NVARCHAR(100) '@entity_name',
				 func_cur_value_id INT '@func_cur_value_id',
				 counterparty_id INT '@counterparty_id',
				 entity_type_value_id INT '@entity_type_value_id',
				 disc_source_value_id  INT '@disc_source_value_id',
				 disc_type_value_id INT '@disc_type_value_id',
				 risk_free_curve_id INT '@risk_free_curve_id',
				 discount_curve_id INT '@discount_curve_id',
				 days_in_year NVARCHAR(20) '@days_in_year',
				 long_term_months NVARCHAR(20) '@long_term_months',
				 tax_perc NVARCHAR(20) '@tax_perc',
				 timezone_id INT '@timezone_id',
				 fx_conversion_market INT '@fx_conversion_market',
				 entity_name_o NVARCHAR(250) '@entity_name_o',
				 primary_naics_code_id INT '@primary_naics_code_id',
				 address1 NVARCHAR(250) '@address1',
				 secondary_naics_code_id INT '@secondary_naics_code_id',
				 address2 NVARCHAR(250) '@address2',
				 entity_category_id INT '@entity_category_id',
				 city NVARCHAR(250) '@city',
				 entity_sub_category_id INT '@entity_sub_category_id',
				 state_value_id INT '@state_value_id',
				 utility_type_id INT '@utility_type_id',
				 zip_code NVARCHAR(250) '@zip_code',
				 ticker_symbol_id NVARCHAR(250) '@ticker_symbol_id',
				 country_value_id INT '@country_value_id',
				 entity_url NVARCHAR(250) '@entity_url',
				 tax_payer_id NVARCHAR(250) '@tax_payer_id',
				 contact_user_id NVARCHAR(250) '@contact_user_id',
				 ownership_status NVARCHAR(250) '@ownership_status',
				 partners NVARCHAR(250) '@partners',
				 base_year_from INT '@base_year_from',
				 base_year_to INT '@base_year_to',
				 organization_boundaries INT '@organization_boundaries',
				 confidentiality_info NVARCHAR(1) '@confidentiality_info',
				 holding_company NVARCHAR(250) '@holding_company',
				 exclude_indirect_emissions NVARCHAR(1) '@exclude_indirect_emissions',
				 accounting_code VARCHAR(500) '@accounting_code'
				  )
	
	IF @flag IN ('i', 'u')
	BEGIN
		--PRINT 'Merge'
		BEGIN TRAN
		
		MERGE portfolio_hierarchy ph
		USING (SELECT fas_subsidiary_id,[entity_name]
		FROM #ztbl_xmlvalue) zxv ON ph.[entity_id] = zxv.fas_subsidiary_id
	
		WHEN NOT MATCHED BY TARGET THEN
		INSERT ([entity_name],hierarchy_level,entity_type_value_id,parent_entity_id)
		VALUES ( zxv.[entity_name],2,525,NULL )
		WHEN MATCHED THEN
		UPDATE SET	 ph.[entity_name] = zxv.[entity_name];
		
		DECLARE @subsidiary_id INT
		SELECT @subsidiary_id = fas_subsidiary_id FROM #ztbl_xmlvalue
		
		IF @subsidiary_id IS NULL
		SET @id = SCOPE_IDENTITY()
		ELSE 
		SET @id = @subsidiary_id
		
		MERGE fas_subsidiaries AS fs
		USING (
			SELECT fas_subsidiary_id,
				 func_cur_value_id,
				 counterparty_id,
				 entity_type_value_id,
				 disc_source_value_id ,
				  disc_type_value_id,
				 risk_free_curve_id ,
				 discount_curve_id ,
				 days_in_year ,
				 long_term_months ,
				 tax_perc ,
				 timezone_id ,
				 fx_conversion_market,
				 entity_name_o ,
				 primary_naics_code_id,
				 address1 ,
				 secondary_naics_code_id ,
				 address2 ,
				 entity_category_id ,
				 city ,
				 entity_sub_category_id ,
				 state_value_id ,
				 utility_type_id ,
				 zip_code ,
				 ticker_symbol_id ,
				 country_value_id ,
				 entity_url ,
				 tax_payer_id ,
				 contact_user_id ,
				 ownership_status ,
				 partners ,
				 base_year_from ,
				 base_year_to ,
				 organization_boundaries ,
				 confidentiality_info ,
				 holding_company ,
				 exclude_indirect_emissions,
				 accounting_code
			FROM #ztbl_xmlvalue) zxv ON fs.fas_subsidiary_id = zxv.fas_subsidiary_id
			
			WHEN NOT MATCHED BY TARGET THEN
				INSERT (
				fas_subsidiary_id,
				 func_cur_value_id ,
				 counterparty_id,
				 entity_type_value_id,
				 disc_source_value_id,
				 disc_type_value_id ,
				 risk_free_curve_id ,
				 discount_curve_id ,
				 days_in_year ,
				 long_term_months ,
				 tax_perc ,
				 timezone_id ,
				 fx_conversion_market,
				 [entity_name] ,
				 primary_naics_code_id,
				 address1 ,
				 secondary_naics_code_id ,
				 address2 ,
				 entity_category_id ,
				 city ,
				 entity_sub_category_id ,
				 state_value_id ,
				 utility_type_id ,
				 zip_code ,
				 ticker_symbol_id ,
				 country_value_id ,
				 entity_url ,
				 tax_payer_id ,
				 contact_user_id ,
				 ownership_status ,
				 partners ,
				 base_year_from ,
				 base_year_to ,
				 organization_boundaries ,
				 confidentiality_info ,
				 holding_company ,
				 exclude_indirect_emissions,
				 accounting_code)
				VALUES (
				@id,
				 zxv.func_cur_value_id,
				 zxv.counterparty_id,
				 zxv.entity_type_value_id,
				 zxv.disc_source_value_id,
				 zxv.disc_type_value_id ,
				 zxv.risk_free_curve_id ,
				 zxv.discount_curve_id ,
				 zxv.days_in_year ,
				 zxv.long_term_months,
				 zxv.tax_perc ,
				 zxv.timezone_id ,
				 zxv.fx_conversion_market ,
				 zxv.entity_name_o ,
				 zxv.primary_naics_code_id,
				 zxv.address1 ,
				 zxv.secondary_naics_code_id ,
				 zxv.address2 ,
				 zxv.entity_category_id ,
				 zxv.city ,
				 zxv.entity_sub_category_id ,
				 zxv.state_value_id ,
				 zxv.utility_type_id ,
				 zxv.zip_code ,
				 zxv.ticker_symbol_id ,
				 zxv.country_value_id ,
				 zxv.entity_url ,
				 zxv.tax_payer_id ,
				 zxv.contact_user_id ,
				 zxv.ownership_status ,
				 zxv.partners ,
				 zxv.base_year_from ,
				 zxv.base_year_to ,
				 zxv.organization_boundaries ,
				 zxv.confidentiality_info ,
				 zxv.holding_company ,
				 zxv.exclude_indirect_emissions,
				 zxv.accounting_code)
			WHEN MATCHED THEN
				UPDATE SET
				 func_cur_value_id = zxv.func_cur_value_id ,
				 counterparty_id = zxv.counterparty_id,
				 entity_type_value_id = zxv.entity_type_value_id,
				 disc_source_value_id = zxv.disc_source_value_id,
				 disc_type_value_id = zxv.disc_type_value_id,
				 risk_free_curve_id = zxv.risk_free_curve_id ,
				 discount_curve_id = zxv.discount_curve_id,
				 days_in_year = zxv.days_in_year,
				 long_term_months =  zxv.long_term_months,
				 tax_perc = zxv.tax_perc,
				 timezone_id = zxv.timezone_id,
				 fx_conversion_market = zxv.fx_conversion_market ,
				 [entity_name] = zxv.entity_name_o,
				 primary_naics_code_id = zxv.primary_naics_code_id,
				 address1 = zxv.address1,
				 secondary_naics_code_id = zxv.secondary_naics_code_id,
				 address2 = zxv.address2,
				 entity_category_id = zxv.entity_category_id,
				 city = zxv.city,
				 entity_sub_category_id = zxv.entity_sub_category_id,
				 state_value_id = zxv.state_value_id,
				 utility_type_id = zxv.utility_type_id,
				 zip_code = zxv.zip_code,
				 ticker_symbol_id = zxv.ticker_symbol_id ,
				 country_value_id = zxv.country_value_id,
				 entity_url = zxv.entity_url,
				 tax_payer_id = zxv.tax_payer_id,
				 contact_user_id = zxv.contact_user_id,
				 ownership_status = zxv.ownership_status,
				 partners = zxv.partners,
				 base_year_from = zxv.base_year_from,
				 base_year_to = zxv.base_year_to,
				 organization_boundaries = zxv.organization_boundaries,
				 confidentiality_info = zxv.confidentiality_info,
				 holding_company = zxv.holding_company,
				 exclude_indirect_emissions = zxv.exclude_indirect_emissions,
				 accounting_code = zxv.accounting_code;

		
			--Release Bookstructure cache key.
		IF  EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_manage_memcache]') AND TYPE IN (N'P', N'PC'))
		BEGIN
			EXEC [spa_manage_memcache] @flag = 'd', @other_key_source='BookStructure', @source_object = 'spa_BookSubsidiaryXml @flag=iu'
		END

		IF @id IS NULL
			SELECT @id = fas_subsidiary_id FROM #ztbl_xmlvalue

		EXEC spa_ErrorHandler 0
			, 'Subsidiary Group'
			, 'spa_getXml'
			, 'Success'
			, 'Changes have been saved successfully.'
			, @id
			
		COMMIT
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
		
	DECLARE @msg NVARCHAR(4000)
	SELECT @msg = 'Subsidiary name must be unique.'--'Failed Inserting record (' + ERROR_MESSAGE() + ').'
	
	EXEC spa_ErrorHandler -1
		, 'Subsidiary Book Details'
		, 'spa_BookSubsidiaryXml'
		, 'Error'
		, @msg
		, 'Failed Inserting Record'
END CATCH