IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[spa_subsidiaries]')
              AND TYPE IN (N'P', N'PC')
   )
    DROP PROCEDURE [dbo].[spa_subsidiaries]
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_subsidiaries]
	@flag CHAR(1),
	@fas_subsidiary_id INT = NULL,
	@fas_subsidiary_name VARCHAR(100) = NULL,
	@entity_type_value_id INT = NULL ,
	@disc_source_value_id INT = NULL ,
	@disc_type_value_id INT = NULL ,
	@func_cur_value_id INT = NULL,
	@days_in_year INT = NULL,
	@long_term_months INT = NULL, 
	@entity_name VARCHAR(250) = NULL,
	@address1 VARCHAR(250) = NULL,
	@address2 VARCHAR(250) = NULL,
	@city VARCHAR(50) = NULL,
	@state_value_id  INT = NULL,
	@zip_code VARCHAR(50) = NULL,
	@country_value_id INT = NULL,
	@entity_url VARCHAR(250) = NULL,
	@tax_payer_id VARCHAR(50) = NULL,
	@contact_user_id VARCHAR(50) = NULL,
	@primary_naics_code_id	INT = NULL,
	@secondary_naics_code_id INT = NULL,
	@entity_category_id INT = NULL,
	@entity_sub_category_id   INT = NULL,
	@utility_type_id INT = NULL,	
	@ticker_symbol_id VARCHAR(50) = NULL,
	@ownership_status VARCHAR(1) = NULL,
	@partners VARCHAR(1000) = NULL,
	@holding_company VARCHAR(1) = NULL,
	@domestic_vol_initiatives INT = NULL,
	@domestic_registeries INT = NULL,
	@international_registeries INT = NULL,	
	@confidentiality_info VARCHAR(1) = NULL,
	@exclude_indirect_emissions VARCHAR(1) = NULL,
	@organization_boundaries INT = NULL,
	@base_year_from INT = NULL,
	@base_year_to INT = NULL,
	@tax_perc FLOAT = NULL,
	@discount_curve_id INT = NULL,
	@risk_free_curve_id INT = NULL,
	@counterparty_id INT = NULL,
	@timezone_id INT = NULL
AS

SET NOCOUNT ON

DECLARE @error_no INT

IF @flag = 's'
BEGIN
    --SELECT fas_subsidiary_id,
    --       a.entity_type_value_id,
    --       disc_source_value_id,
    --       disc_type_value_id,
    --       func_cur_value_id,
    --       days_in_year,
    --       long_term_months,
    --       a.entity_name,
    --       address1,
    --       address2,
    --       city,
    --       state_value_id,
    --       zip_code,
    --       country_value_id,
    --       entity_url,
    --       tax_payer_id,
    --       contact_user_id,
    --       primary_naics_code_id,
    --       secondary_naics_code_id,
    --       entity_category_id,
    --       entity_sub_category_id,
    --       utility_type_id,
    --       ticker_symbol_id,
    --       ownership_status,
    --       partners,
    --       holding_company,
    --       domestic_vol_initiatives,
    --       domestic_registeries,
    --       international_registeries,
    --       confidentiality_info,
    --       exclude_indirect_emissions,
    --       organization_boundaries,
    --       b.entity_name,
    --       base_year_from,
    --       base_year_to,
    --       tax_perc,
    --       discount_curve_id,
    --       risk_free_curve_id,
    --       counterparty_id,
    --       timezone_id
    --FROM   fas_subsidiaries a,
    --       portfolio_hierarchy b
    --WHERE  fas_subsidiary_id = @fas_subsidiary_id
    --       AND a.fas_subsidiary_id = b.entity_id
           
           
SELECT * FROM vwSubsidiary WHERE fas_subsidiary_id =@fas_subsidiary_id           
END
ELSE 
IF @flag = 'i'
BEGIN
    DECLARE @smt VARCHAR(500)
    IF EXISTS (
           SELECT 1
           FROM   portfolio_hierarchy
           WHERE  entity_name = @fas_subsidiary_name
                  AND hierarchy_level = 2
       )
    BEGIN
        SET @smt = 'The subsidiary ''' + @fas_subsidiary_name + ''' already exists.'
        
        EXEC spa_ErrorHandler -1,
             @smt,
             'spa_subsidiary',
             'DB Error',
             @smt,
             ''
        
        RETURN
    END
    
    BEGIN TRAN
    BEGIN TRY
    	INSERT INTO portfolio_hierarchy
    	VALUES
    	  (
    	    @fas_subsidiary_name,
    	    525,
    	    2,
    	    NULL,
    	    NULL,
    	    NULL,
    	    NULL,
    	    NULL
    	  ) 
    	--select * from portfolio_hierarchy where entity_name = @fas_subsidiary_name
    	
    	
    	SET @fas_subsidiary_id = SCOPE_IDENTITY() 
    	INSERT INTO fas_subsidiaries
    	  (
    	    fas_subsidiary_id,
    	    entity_type_value_id,
    	    disc_source_value_id,
    	    disc_type_value_id,
    	    func_cur_value_id,
    	    days_in_year,
    	    long_term_months,
    	    entity_name,
    	    address1,
    	    address2,
    	    city,
    	    state_value_id,
    	    zip_code,
    	    country_value_id,
    	    entity_url,
    	    tax_payer_id,
    	    contact_user_id,
    	    primary_naics_code_id,
    	    secondary_naics_code_id,
    	    entity_category_id,
    	    entity_sub_category_id,
    	    utility_type_id,
    	    ticker_symbol_id,
    	    ownership_status,
    	    partners,
    	    holding_company,
    	    domestic_vol_initiatives,
    	    domestic_registeries,
    	    international_registeries,
    	    confidentiality_info,
    	    exclude_indirect_emissions,
    	    organization_boundaries,
    	    base_year_from,
    	    base_year_to,
    	    tax_perc,
    	    discount_curve_id,
    	    risk_free_curve_id,
    	    counterparty_id,
    	    timezone_id
    	  )
    	VALUES
    	  (
    	    @fas_subsidiary_id,
    	    @entity_type_value_id,
    	    @disc_source_value_id,
    	    @disc_type_value_id,
    	    @func_cur_value_id,
    	    @days_in_year,
    	    @long_term_months,
    	    @entity_name,
    	    @address1,
    	    @address2,
    	    @city,
    	    @state_value_id,
    	    @zip_code,
    	    @country_value_id,
    	    @entity_url,
    	    @tax_payer_id,
    	    @contact_user_id,
    	    @primary_naics_code_id,
    	    @secondary_naics_code_id,
    	    @entity_category_id,
    	    @entity_sub_category_id,
    	    @utility_type_id,
    	    @ticker_symbol_id,
    	    @ownership_status,
    	    @partners,
    	    @holding_company,
    	    @domestic_vol_initiatives,
    	    @domestic_registeries,
    	    @international_registeries,
    	    @confidentiality_info,
    	    @exclude_indirect_emissions,
    	    @organization_boundaries,
    	    @base_year_from,
    	    @base_year_to,
    	    @tax_perc,
    	    @discount_curve_id,
    	    @risk_free_curve_id,
    	    @counterparty_id,
    	    @timezone_id
    	  )
    	
    	
    	EXEC spa_ErrorHandler 0,
    	     'Subsidiaries',
    	     'spa_subsidiaries',
    	     'Success',
    	     'Subsidiaries properties sucessfully inserted',
    	     @fas_subsidiary_id
    	
    	COMMIT TRAN
    END TRY
    BEGIN CATCH
    	ROLLBACK TRAN
    	
    	SELECT @error_no = ERROR_NUMBER()
    	EXEC spa_ErrorHandler @error_no,
    	     'Subsidiaries',
    	     'spa_subsidiaries',
    	     'DB Error',
    	     'Insert of subsidiaries data failed.',
    	     ''
    END CATCH
END
ELSE 
IF @flag = 'u'
BEGIN
    DECLARE @stmt VARCHAR(500)
    IF EXISTS (
           SELECT 1
           FROM   portfolio_hierarchy
           WHERE  entity_name = @fas_subsidiary_name
                  AND entity_id <> @fas_subsidiary_id
                  AND hierarchy_level = 2
       )
    BEGIN
        SET @stmt = 'The subsidiary ''' + @fas_subsidiary_name + ''' already exists.'
        
        EXEC spa_ErrorHandler -1,
             @stmt,
             'spa_subsidiary',
             'DB Error',
             @stmt,
             ''
        
        RETURN
    END
    
    BEGIN TRY 
		
		BEGIN TRAN 
		IF @fas_subsidiary_id = -1 AND NOT EXISTS(SELECT 1 FROM portfolio_hierarchy ph WHERE ph.entity_id = -1)
		BEGIN
			SET IDENTITY_INSERT [dbo].[portfolio_hierarchy] ON
			
			INSERT INTO portfolio_hierarchy (
				entity_id,
				entity_name,
				entity_type_value_id,
				hierarchy_level,
				parent_entity_id,
				create_user,
				create_ts,
				update_user,
				update_ts)
    		VALUES
    		  (
    	  		-1,
    			@fas_subsidiary_name,
    			525,
    			2,
    			NULL,
    			NULL,
    			NULL,
    			NULL,
    			NULL
    		  )
    		    	
    		SET IDENTITY_INSERT [dbo].[portfolio_hierarchy] OFF
		END
		ELSE
		BEGIN
			
			UPDATE portfolio_hierarchy
			SET    entity_name = @fas_subsidiary_name
			WHERE  entity_id = @fas_subsidiary_id	
			
		END
		
		IF @fas_subsidiary_id = -1 AND NOT EXISTS(SELECT 1 FROM fas_subsidiaries fs WHERE fs.fas_subsidiary_id = -1)
		BEGIN
							
    		INSERT INTO fas_subsidiaries
    		  (
    			fas_subsidiary_id,
    			entity_type_value_id,
    			disc_source_value_id,
    			disc_type_value_id,
    			func_cur_value_id,
    			days_in_year,
    			long_term_months,
    			entity_name,
    			address1,
    			address2,
    			city,
    			state_value_id,
    			zip_code,
    			country_value_id,
    			entity_url,
    			tax_payer_id,
    			contact_user_id,
    			primary_naics_code_id,
    			secondary_naics_code_id,
    			entity_category_id,
    			entity_sub_category_id,
    			utility_type_id,
    			ticker_symbol_id,
    			ownership_status,
    			partners,
    			holding_company,
    			domestic_vol_initiatives,
    			domestic_registeries,
    			international_registeries,
    			confidentiality_info,
    			exclude_indirect_emissions,
    			organization_boundaries,
    			base_year_from,
    			base_year_to,
    			tax_perc,
    			discount_curve_id,
    			risk_free_curve_id,
    			counterparty_id,
    			timezone_id
    		  )
    		VALUES
    		  (
    			@fas_subsidiary_id,
    			@entity_type_value_id,
    			@disc_source_value_id,
    			@disc_type_value_id,
    			@func_cur_value_id,
    			@days_in_year,
    			@long_term_months,
    			@entity_name,
    			@address1,
    			@address2,
    			@city,
    			@state_value_id,
    			@zip_code,
    			@country_value_id,
    			@entity_url,
    			@tax_payer_id,
    			@contact_user_id,
    			@primary_naics_code_id,
    			@secondary_naics_code_id,
    			@entity_category_id,
    			@entity_sub_category_id,
    			@utility_type_id,
    			@ticker_symbol_id,
    			@ownership_status,
    			@partners,
    			@holding_company,
    			@domestic_vol_initiatives,
    			@domestic_registeries,
    			@international_registeries,
    			@confidentiality_info,
    			@exclude_indirect_emissions,
    			@organization_boundaries,
    			@base_year_from,
    			@base_year_to,
    			@tax_perc,
    			@discount_curve_id,
    			@risk_free_curve_id,
    			@counterparty_id,
    			@timezone_id
    		  )	
		END
		ELSE
		BEGIN
		    
			UPDATE fas_subsidiaries
			SET    fas_subsidiary_id = @fas_subsidiary_id,
				   entity_type_value_id = @entity_type_value_id,
				   disc_source_value_id = @disc_source_value_id,
				   disc_type_value_id = @disc_type_value_id,
				   func_cur_value_id = @func_cur_value_id,
				   days_in_year = @days_in_year,
				   long_term_months = @long_term_months,
				   entity_name = @entity_name,
				   address1 = @address1,
				   address2 = @address2,
				   city = @city,
				   state_value_id = @state_value_id,
				   zip_code = @zip_code,
				   country_value_id = @country_value_id,
				   entity_url = @entity_url,
				   tax_payer_id = @tax_payer_id,
				   contact_user_id = @contact_user_id,
				   primary_naics_code_id = @primary_naics_code_id,
				   secondary_naics_code_id = @secondary_naics_code_id,
				   entity_category_id = @entity_category_id,
				   entity_sub_category_id = @entity_sub_category_id,
				   utility_type_id = @utility_type_id,
				   ticker_symbol_id = @ticker_symbol_id,
				   ownership_status = @ownership_status,
				   partners = @partners,
				   holding_company = @holding_company,
				   domestic_vol_initiatives = @domestic_vol_initiatives,
				   domestic_registeries = @domestic_registeries,
				   international_registeries = @international_registeries,
				   confidentiality_info = @confidentiality_info,
				   exclude_indirect_emissions = @exclude_indirect_emissions,
				   organization_boundaries = @organization_boundaries,
				   base_year_from = @base_year_from,
				   base_year_to = @base_year_to,
				   tax_perc = @tax_perc,
				   discount_curve_id = @discount_curve_id,
				   risk_free_curve_id = @risk_free_curve_id,
				   counterparty_id = @counterparty_id,
				   timezone_id = @timezone_id
			WHERE  fas_subsidiary_id = @fas_subsidiary_id
		END
        
        EXEC spa_ErrorHandler 0,
             'Subsidiaries properties sucessfully Updated',
             'spa_subsidiaries',
             'Success',
             'Subsidiaries properties sucessfully Updated',
             ''
                 
        COMMIT 
	END TRY 
	BEGIN CATCH
		
		EXEC spa_ErrorHandler @@ERROR,
             'Update of subsidiaries data failed.',
             'spa_subsidiaries',
             'DB Error',
             'Update of subsidiaries data failed.',
             ''
             		 
		ROLLBACK
		
	END CATCH 
             
             --exec spa_audit_trail '#temp_fas_subsidiaries',@fas_subsidiary_id
END
ELSE 
IF @flag = 'd'

BEGIN TRY
	BEGIN TRAN
		IF EXISTS(SELECT 1 FROM portfolio_hierarchy WHERE parent_entity_id = @fas_subsidiary_id)
		BEGIN
			IF @@TRANCOUNT > 0 ROLLBACK
	
			EXEC spa_ErrorHandler 1,
				'Subsidiaries',
				'spa_subsidiaries',
				'DB Error',
				'Please delete all Strategies for the selected Subsidiary first.',
				''
			RETURN
		END
		
		DELETE 
		FROM   program_affiliations
		WHERE  fas_subsidiary_id = @fas_subsidiary_id

		DELETE an FROM application_notes an 
			INNER JOIN fas_subsidiaries fs  ON fs.fas_subsidiary_id = ISNULL(an.parent_object_id, an.notes_object_id)
		WHERE an.internal_type_value_id = 25
			AND fs.fas_subsidiary_id = @fas_subsidiary_id

		UPDATE en SET notes_object_id = NULL 			
		FROM email_notes en
			INNER JOIN fas_subsidiaries fs  ON CAST(fs.fas_subsidiary_id AS VARCHAR(50)) = en.notes_object_id
		WHERE en.internal_type_value_id = 25
			AND fs.fas_subsidiary_id = @fas_subsidiary_id
		
		DELETE 
		FROM   fas_subsidiaries
		WHERE  fas_subsidiary_id = @fas_subsidiary_id
		
		DELETE 
		FROM   portfolio_hierarchy
		WHERE  entity_id = @fas_subsidiary_id
				
		EXEC spa_ErrorHandler 0,
				'Subsidiary',
				'spa_subsidiaries',
				'Success',
				'Changes have been saved successfully.',
            ''

	COMMIT
END TRY
BEGIN CATCH
	ROLLBACK TRAN
		EXEC spa_ErrorHandler -1,
            'Subsidiaries',
            'spa_subsidiaries',
            'DB Error',
            'The selected data cannot be deleted.',
            ''
		
	    IF @@TRANCOUNT > 0 
			ROLLBACK
	    --PRINT 'Delete Failed'
END CATCH
--For getting all subsidiary
ELSE IF @flag = 'p'
BEGIN
    SELECT entity_id, entity_name 
    FROM   portfolio_hierarchy ph
	WHERE hierarchy_level = 0
END