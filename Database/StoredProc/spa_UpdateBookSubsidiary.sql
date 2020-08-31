IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_UpdateBookSubsidiaryXml]') AND TYPE IN (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_UpdateBookSubsidiaryXml]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_UpdateBookSubsidiaryXml]
	@flag CHAR(1),
	@xml TEXT,
	@xml2 TEXT 

AS

SET NOCOUNT ON

--DECLARE @fas_subsidiary_id INT 

BEGIN TRY
	
	DECLARE @id INT 
	DECLARE @idoc INT
	DECLARE @doc VARCHAR(1000)

	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	SELECT * INTO #ztbl_xmlvalue
	
	FROM OPENXML (@idoc, '/Root/FormXML', 2)
		 WITH (	 fas_subsidiary_id  INT  '@fas_subsidiary_id',
				 [entity_name] VARCHAR(100) '@entity_name',
				 func_cur_value_id INT '@func_cur_value_id',
				 counterparty_id INT '@counterparty_id',
				 entity_type_value_id INT '@entity_type_value_id',
				 disc_source_value_id  INT '@disc_source_value_id',
				 disc_type_value_id INT '@disc_type_value_id',
				 risk_free_curve_id INT '@risk_free_curve_id',
				 discount_curve_id INT '@discount_curve_id',
				 days_in_year INT '@days_in_year',
				 long_term_months INT '@long_term_months',
				 tax_perc FLOAT '@tax_perc',
				 timezone_id INT '@timezone_id',
				 entity_name_o VARCHAR(250) '@entity_name_o',
				 primary_naics_code_id INT '@primary_naics_code_id',
				 address1 VARCHAR(250) '@address1',
				 secondary_naics_code_id INT '@secondary_naics_code_id',
				 address2 VARCHAR(250) '@address2',
				 entity_category_id INT '@entity_category_id',
				 city VARCHAR(250) '@city',
				 entity_sub_category_id INT '@entity_sub_category_id',
				 state_value_id INT '@state_value_id',
				 utility_type_id INT '@utility_type_id',
				 zip_code VARCHAR(250) '@zip_code',
				 ticker_symbol_id VARCHAR(250) '@ticker_symbol_id',
				 country_value_id INT '@country_value_id',
				 entity_url VARCHAR(250) '@entity_url',
				 tax_payer_id VARCHAR(250) '@tax_payer_id',
				 contact_user_id VARCHAR(250) '@contact_user_id',
				 ownership_status VARCHAR(250) '@ownership_status',
				 partners VARCHAR(250) '@partners',
				 base_year_from INT '@base_year_from',
				 base_year_to INT '@base_year_to',
				 organization_boundaries INT '@organization_boundaries',
				 confidentiality_info VARCHAR(1) '@confidentiality_info',
				 holding_company VARCHAR(250) '@holding_company',
				 exclude_indirect_emissions VARCHAR(1) '@exclude_indirect_emissions'
				  )


	DECLARE @idoc2 INT
	DECLARE @doc2 VARCHAR(1000)

	EXEC sp_xml_preparedocument @idoc2 OUTPUT, @xml2

	-------------------------------------------------------------------
	SELECT * INTO #ztbl_gridvalue
	FROM OPENXML (@idoc2, '/GridGroup/Grid/GridRow', 2)
		WITH ( fas_subsidiary_id  INT  '@fas_subsidiary_id',
				affiliation_id INT '@affiliation_id',
				affiliation_type_id INT '@affiliation_type_id',
				affiliation_value_id INT '@affiliation_value_id')
	--	SELECT * FROM #ztbl_gridvalue		
	
	
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
		
		IF @subsidiary_id = 0
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
				 exclude_indirect_emissions 
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
				 exclude_indirect_emissions)
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
				 zxv. long_term_months,
				 zxv.tax_perc ,
				 zxv.timezone_id ,
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
				 zxv.exclude_indirect_emissions  )
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
				 exclude_indirect_emissions = zxv.exclude_indirect_emissions;
				
				
		
	  --SELECT @fas_subsidiary_id = fas_subsidiary_id FROM #ztbl_xmlvalue
		--SELECT * FROM portfolio_hierarchy AS ph
		--SELECT * FROM fas_strategy AS fs
		
			
			
			--SELECT * FROM #ztbl_gridvalue
			--SELECT pa.affiliation_id, grd.affiliation_id,grd.fas_subsidiary_id,grd.affiliation_type_id,grd.affiliation_value_id
			--       FROM #ztbl_gridvalue grd inner join program_affiliations pa ON pa.fas_subsidiary_id = grd.fas_subsidiary_id 
			--       AND pa.affiliation_id = grd.affiliation_id 
			
			--ROLLBACK
			
			MERGE program_affiliations pa
			USING (SELECT affiliation_id,fas_subsidiary_id,affiliation_type_id,affiliation_value_id
			       FROM #ztbl_gridvalue) grd ON pa.fas_subsidiary_id = grd.fas_subsidiary_id 
			       AND pa.affiliation_id = grd.affiliation_id 
			
			
			 WHEN NOT MATCHED BY TARGET THEN
		
			 		INSERT (fas_subsidiary_id,affiliation_type_id,affiliation_value_id) 
			 		VALUES (@id,grd.affiliation_type_id,grd.affiliation_value_id)
			 
			 WHEN MATCHED THEN 
			 	UPDATE SET 
			
			 		pa.affiliation_type_id = grd.affiliation_type_id,
			 		pa.affiliation_value_id = grd.affiliation_value_id
			 		
			 WHEN NOT MATCHED BY SOURCE 
			 AND pa.fas_subsidiary_id = @id
			 THEN 
			 	DELETE
				;
	
		
		EXEC spa_ErrorHandler 0
			, 'Subsidiary Group'
			, 'spa_getXml'
			, 'Success'
			, 'Changes have been saved successfully.'
			, ''
			
			
				

		COMMIT
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
		
	DECLARE @msg VARCHAR(5000)
	SELECT @msg = 'Failed Inserting record (' + ERROR_MESSAGE() + ').'
	
	EXEC spa_ErrorHandler @@ERROR
		, 'Subsidiary Book Details'
		, 'spa_UpdateBookSubsidiaryXml'
		, 'Error'
		, @msg
		, 'Failed Inserting Record'
END CATCH



