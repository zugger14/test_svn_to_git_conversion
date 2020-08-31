
/*****************************************************************
* Modified By :Mukesh Singh
* Modified Date : 16-Marcha-2009
* Purpose : To delete counterparty from the Maintain Counterparty 
* @flag 'g': To load in grid 
****************************************************************/

IF EXISTS (SELECT * FROM   sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_source_counterparty_maintain]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_source_counterparty_maintain]
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_source_counterparty_maintain]
	 @flag AS CHAR(1)
	,@source_counterparty_id VARCHAR(MAX) = NULL
	,@source_system_id INT = NULL
	,@counterparty_id VARCHAR(1000) = NULL
	,@counterparty_name VARCHAR(1000) = NULL
	,@counterparty_desc VARCHAR(1000) = NULL
	,@int_ext_flag CHAR(1) = NULL
	,@netting_parent_counterparty_id INT = NULL
	,@type_of_entity INT = NULL
	,@address VARCHAR(255) = NULL
	,@phone_no VARCHAR(100) = NULL
	,@mailing_address VARCHAR(255) = NULL
	,@fax VARCHAR(100) = NULL
	,@email VARCHAR(100) = NULL
	,@contact_name VARCHAR(100) = NULL
	,@contact_title VARCHAR(100) = NULL
	,@contact_address VARCHAR(255) = NULL
	,@contact_phone VARCHAR(100) = NULL
	,@contact_fax VARCHAR(100) = NULL
	,@contact_email VARCHAR(5000) = NULL
	,@contact_address2 VARCHAR(100) = NULL
	,@instruction VARCHAR(500) = NULL
	,@confirm_from_text VARCHAR(500) = NULL
	,@confirm_to_text VARCHAR(500) = NULL
	,@confirm_instruction VARCHAR(500) = NULL
	,@counterparty_contact_title VARCHAR(50) = NULL
	,@counterparty_contact_name VARCHAR(100) = NULL
	,@parent_counterparty_id INT = NULL
	,@counterparty_contact_id VARCHAR(100) = NULL
	,@city VARCHAR(50) = NULL
	,@state INT = NULL
	,@zip VARCHAR(50) = NULL
	,@customer_duns_number VARCHAR(50) = NULL
	,@is_active CHAR(1) = NULL
	,@tax_id VARCHAR(500) = NULL
	,@delivery_method INT = NULL
	,@country VARCHAR(500) = NULL
	,@region INT = NULL
	,@cc_email VARCHAR(5000) = NULL
	,@bcc_email VARCHAR(5000) = NULL
	,@cc_remmittance VARCHAR(5000) = NULL
	,@bcc_remmittance VARCHAR(5000) = NULL
	,@email_remittance_to VARCHAR(5000) = NULL
	,@xml VARCHAR(MAX) = NULL
	,@check_apply CHAR(1) = NULL
	,@not_int_ext_flag CHAR(1) = NULL
	,@static_type_name VARCHAR(100) = NULL
	,@static_code VARCHAR(100) = NULL,
	 @counterparty_type VARCHAR(5) = NULL,
	 @eff_test_profile_id INT = NULL,
	 @filter_value VARCHAR(1000) = NULL	
	 

AS 
SET NOCOUNT ON
DECLARE @Sql_Select VARCHAR(5000)
DECLARE @ident_source_counterparty_id  VARCHAR(50)
DECLARE @alert_process_table VARCHAR(100)
DECLARE @process_id VARCHAR(100)

SELECT @filter_value = NULLIF(NULLIF(@filter_value, '<FILTER_VALUE>'), '')

IF @flag IN('c', 'g', 'e', 'p', 'f', 'h', 'k', 'n', 'o','m', 'j')
BEGIN
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT )
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'counterparty'
END

IF @flag = 'i'
BEGIN
    DECLARE @cont1 VARCHAR(100)
    SELECT @cont1 = COUNT(*)
    FROM   source_counterparty
    WHERE  counterparty_id = @counterparty_id
           AND source_system_id = @source_system_id
    
    IF (@cont1 > 0)
    BEGIN
        SELECT 'Error',
               'Can not insert duplicate ID :' + @counterparty_id,
               'spa_application_security_role',
               'DB Error',
               'Can not insert duplicate ID :' + @counterparty_id,
               ''
        
        RETURN
    END
    
    BEGIN TRY
    	BEGIN TRAN	
    	INSERT INTO source_counterparty
    	  (
    	    source_system_id,
    	    counterparty_id,
    	    counterparty_name,
    	    counterparty_desc,
    	    int_ext_flag,
    	    netting_parent_counterparty_id,
    	    type_of_entity,
    	    [address],
    	    phone_no,
    	    mailing_address,
    	    fax,
    	    email,
    	    contact_name,
    	    contact_title,
    	    contact_address,
    	    contact_phone,
    	    contact_fax,
    	    contact_email,
    	    contact_address2,
    	    instruction,
    	    confirm_from_text,
    	    confirm_to_text,
    	    confirm_instruction,
    	    counterparty_contact_title,
    	    counterparty_contact_name,
    	    parent_counterparty_id,
    	    counterparty_contact_id,
    	    city,
    	    [state],
    	    zip,
    	    customer_duns_number,
    	    is_active,
    	    tax_id,
    	    delivery_method,
    	    country,
    	    region,
    	    cc_email,
    	    bcc_email,
    	    cc_remittance,
    	    bcc_remittance,
    	    email_remittance_to
    	  )
    	VALUES
    	  (
    	    @source_system_id,
    	    @counterparty_id,
    	    @counterparty_name,
    	    @counterparty_desc,
    	    @int_ext_flag,
    	    @netting_parent_counterparty_id,
    	    @type_of_entity,
    	    @address,
    	    @phone_no,
    	    @mailing_address,
    	    @fax,
    	    @email,
    	    @contact_name,
    	    @contact_title,
    	    @contact_address,
    	    @contact_phone,
    	    @contact_fax,
    	    @contact_email,
    	    @contact_address2,
    	    @instruction,
    	    @confirm_from_text,
    	    @confirm_to_text,
    	    @confirm_instruction,
    	    @counterparty_contact_title,
    	    @counterparty_contact_name,
    	    @parent_counterparty_id,
    	    @counterparty_contact_id,
    	    @city,
    	    @state,
    	    @zip,
    	    @customer_duns_number,
    	    @is_active,
    	    @tax_id,
    	    @delivery_method,
    	    @country,
    	    @region,
    	    @cc_email,
    	    @bcc_email,
    	    @cc_remmittance,
    	    @bcc_remmittance,
    	    @email_remittance_to
    	  )
    	
    	SET @ident_source_counterparty_id = SCOPE_IDENTITY()
		EXEC spa_counterparty_credit_info 'i',
    	     NULL,
    	     @ident_source_counterparty_id,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
    	     NULL,
			 'sp'
    	
    	COMMIT TRAN
    	EXEC spa_ErrorHandler 0,
    	     'MaintainDefination',
    	     'spa_source_counterparty_maintain',
    	     'Success',
    	     'Defination data value inserted.',
    	     @ident_source_counterparty_id
    END TRY
    BEGIN CATCH
    	ROLLBACK
    	IF @@Error <> 0
    	    EXEC spa_ErrorHandler @@Error,
    	         'MaintainDefination',
    	         'spa_source_counterparty_maintain',
    	         'DB Error',
    	         'Failed to insert defination value.',
    	         ''
    END CATCH
END
ELSE 
IF @flag = 'a'
BEGIN
    SELECT source_counterparty.source_counterparty_id,
           source_system_description.source_system_id AS system_name,
           source_counterparty.counterparty_id,
           source_counterparty.counterparty_name,
           source_counterparty.counterparty_desc,
           source_counterparty.int_ext_flag,
           source_counterparty.netting_parent_counterparty_id,
           type_of_entity,
           ADDRESS,
           phone_no,
           mailing_address,
           fax,
           email,
           contact_name,
           contact_title,
           contact_address,
           contact_phone,
           contact_fax,
           contact_email,
           contact_address2,
           instruction,
           confirm_from_text,
           confirm_to_text,
           confirm_instruction,
           counterparty_contact_title,
           counterparty_contact_name,
           parent_counterparty_id,
           counterparty_contact_id,
           city,
           STATE,
           zip,
           customer_duns_number,
           source_counterparty.is_active,
           source_counterparty.tax_id,
           source_counterparty.delivery_method,
           source_counterparty.country,
           source_counterparty.region,
           source_counterparty.cc_email,
           source_counterparty.bcc_email,
           source_counterparty.cc_remittance,
           source_counterparty.bcc_remittance,
           source_counterparty.email_remittance_to
    FROM   source_counterparty
           INNER JOIN source_system_description
                ON  source_system_description.source_system_id = 
                    source_counterparty.source_system_id 
                    --where source_counterparty_id in @source_counterparty_id
			INNER JOIN SplitCommaSeperatedValues(@source_counterparty_id) csv
                ON  csv.Item = source_counterparty.source_counterparty_id
END
ELSE 
IF @flag = 's'
BEGIN
    SET @Sql_Select = 'SELECT source_counterparty.source_counterparty_id ID
							, source_counterparty.counterparty_name + CASE WHEN source_counterparty.source_system_id=2 THEN '''' ELSE ''.'' + source_system_description.source_system_name END as Name
							, source_counterparty.counterparty_desc as Description
							, source_system_description.source_system_name as System
							, CASE WHEN int_ext_flag=''i'' THEN ''internal''  when int_ext_flag=''e'' then ''external'' 
								when int_ext_flag=''b'' THEN ''broker'' 
								when int_ext_flag=''c'' THEN ''clearing'' when int_ext_flag=''m'' 
								THEN ''Model'' 
							  END Type
							, dbo.FNADateTimeFormat(source_counterparty.create_ts,1) [Created Date]
							, source_counterparty.create_user [Created User]
							, source_counterparty.update_user [Updated User]
							, dbo.FNADateTimeFormat(source_counterparty.update_ts,1) [Updated Date] 
						FROM source_counterparty 
						INNER JOIN source_system_description ON source_system_description.source_system_id = source_counterparty.source_system_id
						WHERE 1 = 1 '
					+ CASE 
						   WHEN @source_system_id IS NOT NULL THEN 
								'  AND source_counterparty.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id)
								+ ''
						   ELSE ''
					  END
					+ CASE 
						   WHEN @int_ext_flag IS NOT NULL THEN 
								' AND source_counterparty.int_ext_flag = ''' + @int_ext_flag
								+ ''''
						   ELSE ''
					  END
					+ CASE 
						   WHEN @source_counterparty_id IS NOT NULL THEN 
								' AND source_counterparty.source_counterparty_id = ' + CAST(@source_counterparty_id AS VARCHAR(100)) 
								+ ''
						   ELSE ''
					  END
			    
    SET @Sql_Select = @Sql_Select + 
        ' ORDER BY source_counterparty.counterparty_name'
    
    EXEC (@SQL_select)
END
ELSE 
IF @flag = 'u'
BEGIN
    DECLARE @cont VARCHAR(100)
    
    SELECT @cont = COUNT(*)
    FROM   source_counterparty
    WHERE  counterparty_id = @counterparty_id
           AND source_counterparty_id <> @source_counterparty_id
           AND source_system_id = @source_system_id
    
    IF (@cont > 0)
    BEGIN
        SELECT 'Error',
               'Can not update duplicate ID :' + @counterparty_id,
               'spa_application_security_role',
               'DB Error',
               'Can not update duplicate ID :' + @counterparty_id,
               ''
        
        RETURN
    END
    
    UPDATE source_counterparty
    SET    source_system_id = @source_system_id,
           counterparty_id = @counterparty_id,
           counterparty_name = @counterparty_name,
           counterparty_desc = @counterparty_desc,
           int_ext_flag = @int_ext_flag,
           netting_parent_counterparty_id = @netting_parent_counterparty_id,
           type_of_entity = @type_of_entity,
           ADDRESS = @address,
           phone_no = @phone_no,
           mailing_address = @mailing_address,
           fax = @fax,
           email = @email,
           contact_name = @contact_name,
           contact_title = @contact_title,
           contact_address = @contact_address,
           contact_phone = @contact_phone,
           contact_fax = @contact_fax,
           contact_email = @contact_email,
           contact_address2 = @contact_address2,
           instruction = @instruction,
           confirm_from_text = @confirm_from_text,
           confirm_to_text = @confirm_to_text,
           confirm_instruction = @confirm_instruction,
           counterparty_contact_title = @counterparty_contact_title,
           counterparty_contact_name = @counterparty_contact_name,
           parent_counterparty_id = @parent_counterparty_id,
           counterparty_contact_id = @counterparty_contact_id,
           city = @city,
           STATE = @state,
           zip = @zip,
           customer_duns_number = @customer_duns_number,
           is_active = @is_active,
           tax_id = @tax_id,
           delivery_method = @delivery_method,
           country = @country,
           region = @region,
           cc_email = @cc_email,
           bcc_email = @bcc_email,
           cc_remittance = @cc_remmittance,
           bcc_remittance = @bcc_remmittance,
           email_remittance_to = @email_remittance_to
    WHERE  source_counterparty_id = @source_counterparty_id
    
    IF @@Error <> 0
        EXEC spa_ErrorHandler @@Error,
             'MaintainDefination',
             'spa_source_counterparty_maintain',
             'DB Error',
             'Failed to update defination value.',
             ''
    ELSE
        EXEC spa_ErrorHandler 0,
             'MaintainDefination',
             'spa_source_counterparty_maintain',
             'Success',
             'Defination data value updated.',
             ''
END
ELSE 
IF @flag = 'd'
BEGIN
    DECLARE @message VARCHAR(8000)
    BEGIN TRY
    	BEGIN TRAN
    		IF EXISTS(
    			SELECT 1
    			FROM rec_generator rg
				INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = rg.ppa_counterparty_id
			)
    		BEGIN
    			DECLARE @generator_name VARCHAR(100)
    			SELECT @generator_name = CONCAT(@generator_name, rg.[name], ', ')
    			FROM rec_generator rg
    			INNER JOIN contract_group cg ON cg.contract_id = rg.ppa_contract_id
    			WHERE rg.ppa_counterparty_id = @source_counterparty_id

				SET @generator_name = LEFT(@generator_name, LEN(@generator_name) - 1)
    	    
    			SELECT @message = 'Failed to delete counterparty. Counterparty is mapped to generator ' + @generator_name + '.'
    	    
    			EXEC spa_ErrorHandler -1,
    				'MaintainDefinition',
    				'spa_source_counterparty_maintain',
    				'DB Error',
    				@message,
    				''
				COMMIT TRAN
    			RETURN
    		END
    	
    		IF EXISTS (
				SELECT 1
				FROM calc_invoice_volume_variance ih
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id = ih.counterparty_id
				INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = sc.source_counterparty_id
			)
			BEGIN
				 SELECT @message = 'Failed to delete counterparty. Counterparty is mapped to Invoice.'
    	              	    
    			EXEC spa_ErrorHandler -1,
    				'MaintainDefinition',
    				'spa_source_counterparty_maintain',
    				'DB Error',
    				@message,
    				''
    			 COMMIT TRAN
    			 RETURN	
			End
    	
			DELETE cbi
			FROM counterparty_bank_info cbi
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = cbi.counterparty_id
    		
			DELETE mvcce
			FROM master_view_counterparty_credit_enhancements mvcce
			INNER JOIN counterparty_credit_info cci ON mvcce.counterparty_credit_info_id = cci.counterparty_credit_info_id
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = cci.counterparty_id

    		DELETE cce
    		FROM counterparty_credit_enhancements cce
    		INNER JOIN counterparty_credit_info cci ON cce.counterparty_credit_info_id = cci.counterparty_credit_info_id
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = cci.counterparty_id
    		
			DELETE mv 
			FROM master_view_counterparty_credit_info mv
			INNER JOIN counterparty_credit_info cci ON cci.counterparty_credit_info_id = mv.counterparty_credit_info_id
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = cci.counterparty_id

    		DELETE cci
			FROM counterparty_credit_info cci
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = cci.counterparty_id
    	
    		IF EXISTS(
    			SELECT 1
    			FROM counterparty_epa_account cea
				INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = cea.counterparty_id
    		)
    		BEGIN
    			--EXEC spa_ErrorHandler -1,
    			--     'MaintainDefinition',
    			--     'spa_source_counterparty_maintain',
    			--     'DB Error',
    			--     'Please delete related data for the counterparty first.',
    			--     ''
    			--COMMIT TRAN 
    			--RETURN
				DELETE mvcea
    			FROM master_view_counterparty_epa_account mvcea
				INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = mvcea.counterparty_id

    			DELETE cea
    			FROM counterparty_epa_account cea
				INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = cea.counterparty_id
    		END
    	
    		DELETE bf
    		FROM broker_fees bf
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = bf.counterparty_id

			DELETE mvcc
    		FROM master_view_counterparty_contacts mvcc
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = mvcc.counterparty_id

    		DELETE cc
    		FROM counterparty_contacts cc
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = cc.counterparty_id

			DELETE mvcca
    		FROM master_view_counterparty_contract_address mvcca
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = mvcca.counterparty_id
			
			DELETE cca
    		FROM counterparty_contract_address cca
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = cca.counterparty_id

			/* 
			 * Delete Associated Products/Certificates/Approved Counterparty and Products
			 */
			DELETE an
			FROM counterparty_products cp
			INNER JOIN application_notes an on an.notes_object_id = cp.counterparty_product_id
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = cp.counterparty_id

			DELETE cp
			FROM counterparty_products cp
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = cp.counterparty_id
		 
			DELETE an
			FROM counterparty_certificate cf
			INNER JOIN application_notes an on an.notes_object_id = cf.counterparty_certificate_id
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = cf.counterparty_id

			DELETE cf 
			FROM counterparty_certificate cf
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = cf.counterparty_id

			DELETE an
			FROM approved_product ap
			LEFT JOIN approved_counterparty ac on ac.approved_counterparty_id = ap.approved_counterparty_id
			INNER JOIN application_notes an on an.notes_object_id = ap.approved_product_id
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = ac.counterparty_id

			DELETE ap
			FROM approved_product ap
			LEFT JOIN approved_counterparty ac on ac.approved_counterparty_id = ap.approved_counterparty_id
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = ac.counterparty_id

			DELETE ac
			FROM approved_counterparty ac
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = ac.counterparty_id

    		/* 
			 * Delete Associated Products/Certificates/Approved Counterparty and Products
			 */
			 
			/** DELETE Associate documents and mails attached **/
			DELETE an
			FROM application_notes an
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = ISNULL(an.parent_object_id, an.notes_object_id)
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = sc.source_counterparty_id
			WHERE an.internal_type_value_id = 37

			UPDATE en
			SET notes_object_id = NULL
			FROM email_notes en
			INNER JOIN source_counterparty sc ON sc.source_counterparty_id = en.notes_object_id
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = sc.source_counterparty_id
			WHERE en.internal_type_value_id = 37

    		DELETE sc
			FROM source_counterparty sc
			INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = sc.source_counterparty_id

			--EXEC spa_maintain_udf_header 'd', NULL, @source_counterparty_id
    	COMMIT TRAN
    	--rollback tran
    	EXEC spa_ErrorHandler 0,
    	     'MaintainDefinition',
    	     'spa_source_counterparty_maintain',
    	     'Success',
    	     'Changes have been saved successfully.',
    	     @source_counterparty_id
	END TRY
    BEGIN CATCH
    	BEGIN
			IF @@TRANCOUNT > 0
    			ROLLBACK TRAN

    		DECLARE @er INT
    		DECLARE @er_msg	VARCHAR(200)
    		DECLARE @check VARCHAR(100)
    		DECLARE @dealid INT
			
    		SET @er = ERROR_NUMBER()
    		SET @er_msg = ERROR_MESSAGE()

    		IF EXISTS(
    			SELECT 1
    		    FROM source_deal_header dh
    		    INNER JOIN broker_fees bf ON dh.broker_id = bf.counterparty_id
				INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = dh.broker_id
    		)
    		BEGIN
    		    --select @dealid = source_deal_header_id from source_deal_header where counterparty_id=@source_counterparty_id
    		    SET @message = 'Failed to delete counterparty. Deal(s) are entered for this broker.'
    		END
    		ELSE IF EXISTS(
				SELECT 1
    		    FROM source_deal_header sdh
				INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = sdh.counterparty_id
    		)
			BEGIN
    		    SET @message = 'Failed to delete counterparty. Deal(s) are entered for this counterparty.'
			END
    		ELSE
    		--IF EXISTS(
    		--       SELECT 'x'
    		--       FROM   broker_fees
    		--       WHERE  counterparty_id = @source_counterparty_id
    		--   )
    		--    SET @message = 
    		--        'Failed to delete broker. Please delete broker fee(s) first.'
    		--ELSE
    		IF EXISTS(
				SELECT 1
				FROM deal_confirmation_rule dcr
				INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = dcr.counterparty_id
    		)
			BEGIN
    			SET @message = 'Failed to delete counterparty. Confirm Rule(s) are defined for this counterparty.'
			END
    		        
			IF EXISTS(
				SELECT 1
				FROM source_major_location sml
				INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = sml.counterparty
    		)
    		SET @message = 'Failed to delete counterparty. Counterparty is mapped in location group.'
    		
			IF EXISTS(
				SELECT 1
				FROM calc_invoice_volume_variance ih
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id = ih.counterparty_id
				INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = sc.source_counterparty_id
			)
    		SET @message = 'Failed to delete counterparty. Counterparty is mapped in Invoice.'
   			
			IF EXISTS(
				SELECT 1
				FROM approved_counterparty ap
				INNER JOIN source_counterparty sc ON sc.source_counterparty_id = ap.approved_counterparty
				INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = sc.source_counterparty_id
			)
			SET @message = 'Failed to delete counterparty. Approved Counterparty are entered for this Counterparty.'
 
    		
			IF EXISTS(
				SELECT 1
				FROM counterparty_credit_limits ccl
				INNER JOIN dbo.FNASplit(@source_counterparty_id, ',') di ON di.item = ccl.counterparty_id
			)
			SET @message = 'Failed to delete counterparty. Limits have been setup for this counterparty.'
			
			IF NULLIF(@message, '') IS NULL
				SET @message = dbo.FNAHandleDBError(10105800)
    		
    		EXEC spa_ErrorHandler -1,
    		     'MaintainDefinition',
    		     'spa_source_counterparty_maintain',
    		     'DB Error',
    		     @message,
    		     ''
    	END
    END CATCH

END
IF @flag = 'l'
BEGIN
	SELECT sc.contact_email
	FROM   source_counterparty sc
	WHERE  sc.source_counterparty_id = @source_counterparty_id
END
ELSE IF @flag = 'r'
BEGIN
	SELECT STUFF((
		SELECT TOP 10 CAST(',' AS VARCHAR(MAX)) + sc.counterparty_name
		FROM source_counterparty sc
		INNER JOIN dbo.SplitCommaSeperatedValues(@source_counterparty_id) csv ON csv.Item = sc.source_counterparty_id
		ORDER BY sc.counterparty_contact_name
		FOR XML PATH(''), TYPE).value('.[1]', 'VARCHAR(8000)'), 1, 1, '') 
			+ (CASE WHEN (SELECT COUNT(1) FROM dbo.SplitCommaSeperatedValues(@source_counterparty_id)) > 10 THEN '...' ELSE '' END) counterparty_names
	
END
ELSE IF @flag = 'g'
BEGIN
	DECLARE @ctpy_type VARCHAR(4000) = NULL, @entity_type VARCHAR(4000) = NULL, @contract VARCHAR(4000) = NULL, @available_certificate VARCHAR(4000) = NULL, @required_certificate VARCHAR(4000) = NULL,
		@buy_sell CHAR(1) = NULL, @product VARCHAR(4000) = NULL, @approved_counterparty VARCHAR(4000) = NULL,
		@commodity VARCHAR(4000)
	
	IF @xml IS NOT NULL
	BEGIN
		DECLARE @idoc INT
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
		SELECT
			@ctpy_type = counterparty_type,
			@entity_type = entity_type,
			@contract = contract,
			@available_certificate = available_certificate,
			@required_certificate = required_certificate,
			@buy_sell = buy_sell,
			@commodity = commodity,
			@product = product,
			@approved_counterparty = approved_counterparty
		FROM OPENXML(@idoc, '/FormXML', 1)
		WITH (
			counterparty_type VARCHAR(4000),
			entity_type VARCHAR(4000),
			contract VARCHAR(4000),
			available_certificate VARCHAR(4000),
			required_certificate VARCHAR(4000),
			buy_sell CHAR(1),
			commodity VARCHAR(4000),
			product VARCHAR(4000),
			approved_counterparty VARCHAR(4000)
		)
		
	END

	SET @Sql_Select = '
		SELECT DISTINCT 	
			   sc2.counterparty_name [parent_counterparty_id],
			   sc.counterparty_name,
			   sc.source_counterparty_id,	
			   sc.counterparty_id,
			   sc.counterparty_desc,
			   CASE 
					WHEN sc.int_ext_flag = ''i'' THEN ''Internal''
					WHEN sc.int_ext_flag = ''e'' THEN ''External''
					WHEN sc.int_ext_flag = ''b'' THEN ''Broker''
					WHEN sc.int_ext_flag = ''c'' THEN ''Clearing''
					WHEN sc.int_ext_flag = ''m'' THEN ''Model''
			   END counterparty_type,			   
			   sdv.code [entity_type],
			   sc.customer_duns_number,
			   sc.tax_id,
			   CASE 
					WHEN sc.is_active = ''y'' THEN ''Yes''
					ELSE ''No''
			   END is_active,
			   sc.contact_title,
			   sc.contact_name,
			   sc.contact_address,
			   sc.contact_address2,
			   sc.contact_phone,
			   sc.contact_fax,
			   sdv2.[description] [delivery_method],
			   4002 type_id,
			   ISNULL(sdad.is_active, 0) is_privilege_active,
			   sc.counterparty_contact_notes
		FROM #final_privilege_list cp '
		+ CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
			source_counterparty sc ON sc.source_counterparty_id = cp.value_id
		LEFT JOIN source_counterparty sc2 ON sc.parent_counterparty_id=sc2.source_counterparty_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = sc.type_of_entity
		LEFT JOIN static_data_value sdv2 ON sdv2.value_id = sc.delivery_method
		LEFT JOIN static_data_active_deactive sdad ON sdad.type_id = 4002
	'
	IF @contract IS NOT NULL
		SET @Sql_Select += ' LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sc.source_counterparty_id'
	IF @available_certificate IS NOT NULL
		SET @Sql_Select += ' LEFT JOIN counterparty_certificate cc ON cc.counterparty_id = sc.source_counterparty_id'
	IF @required_certificate IS NOT NULL
		SET @Sql_Select += ' LEFT JOIN counterparty_certificate cc2 ON cc2.counterparty_id = sc.source_counterparty_id'
	IF @buy_sell IS NOT NULL OR @product IS NOT NULL OR @commodity IS NOT NULL
		SET @Sql_Select += ' LEFT JOIN counterparty_products cp ON cp.counterparty_id = sc.source_counterparty_id'
	IF @product IS NOT NULL
		SET @Sql_Select += '
							LEFT JOIN dbo.SplitCommaSeperatedValues((
							SELECT STUFF(
								(
									SELECT '',''  + CAST(cp.product_computed_name AS VARCHAR(MAX))
									FROM dbo.SplitCommaSeperatedValues(''' + CAST(@product AS VARCHAR(4000)) + ''') s
									INNER JOIN counterparty_products cp ON cp.counterparty_product_id = s.item
									FOR XML PATH('''')
								)
							, 1, 1, '''') [product_computed_name]
						)) cpp ON cpp.item = cp.product_computed_name'
	IF @approved_counterparty IS NOT NULL
		SET @Sql_Select += ' LEFT JOIN approved_counterparty ac ON ac.counterparty_id = sc.source_counterparty_id'
	SET @Sql_Select += ' WHERE 1=1 '

	IF @ctpy_type IS NOT NULL
		SET @Sql_Select += ' AND sc.int_ext_flag IN (''' + CAST(REPLACE(@ctpy_type, ',', ''',''') AS VARCHAR(4000)) + ''')'
	IF @entity_type IS NOT NULL
		SET @Sql_Select += ' AND sc.type_of_entity IN (' + CAST(@entity_type AS VARCHAR(4000)) + ')'
	IF @contract IS NOT NULL
		SET @Sql_Select += ' AND cca.contract_id IN (' + CAST(@contract AS VARCHAR(4000)) + ')'
	IF @available_certificate IS NOT NULL
		SET @Sql_Select += ' AND cc.certificate_id IN (' + CAST(@available_certificate AS VARCHAR(4000)) + ') AND cc.available_reqd = ''a'''
	IF @required_certificate IS NOT NULL
		SET @Sql_Select += ' AND cc2.certificate_id IN (' + CAST(@required_certificate AS VARCHAR(4000)) + ') AND cc2.available_reqd = ''b'''
	IF @buy_sell IS NOT NULL
		SET @Sql_Select += ' AND cp.buy_sell = ''' + CAST(@buy_sell AS VARCHAR(10)) + ''''
	IF @commodity IS NOT NULL
		SET @Sql_Select += ' AND cp.commodity_id IN (' + CAST(@commodity AS VARCHAR(4000)) + ')'
	IF @product IS NOT NULL
		SET @Sql_Select += ' AND cp.product_computed_name = cpp.item'
	IF @approved_counterparty IS NOT NULL
		SET @Sql_Select += ' AND ac.approved_counterparty IN (' + CAST(@approved_counterparty AS VARCHAR(4000)) + ')'
	IF @source_counterparty_id IS NOT NULL
		SET @Sql_Select += ' AND sc.source_counterparty_id IN (' + CAST(@source_counterparty_id AS VARCHAR(4000)) + ')'	

	SET @Sql_Select += ' ORDER BY sc.counterparty_name'
	
	EXEC(@Sql_Select)
END
ELSE IF @flag = 'j' -- DHTMLX Grid in Counterparty Credit Info UI
BEGIN
	SET @Sql_Select = 'SELECT DISTINCT --cci.counterparty_credit_info_id,	
		   sc.source_counterparty_id,
		   sc.counterparty_name,
		   sc.counterparty_desc,
		   sc.counterparty_id,
		   cci.account_status,
		   cci.Risk_rating,
		   cci.Debt_rating,
		   cci.cva_data,
		   cci.pfe_criteria,
		   cci.Debt_Rating2,
		   cci.Debt_Rating3,
		   cci.Debt_Rating4,
		   cci.Debt_Rating5,
		   cci.Industry_type1,
		   cci.Industry_type2,
		   cci.Ticker_symbol,
		   cci.SIC_Code,
		   dbo.FNADateFormat(cci.Customer_since) Customer_since,
		   cci.Duns_No,
		   cci.Approved_by,
		   dbo.FNADateFormat(cci.Date_established) Date_established,
		   dbo.FNADateFormat(cci.Last_review_date) Last_review_date,
		   dbo.FNADateFormat(cci.Next_review_date) Next_review_date,
		   --cci.cva_data,
		   --cci.pfe_criteria,
		   cci.exclude_exposure_after,
		   4002 type_id,
		   ISNULL(sdad.is_active, 0) is_privilege_active,
		   case cci.Watch_list WHEN ''n'' THEN ''No'' ELSE ''Yes'' END Watch_list,
		   case cci.check_apply WHEN ''n'' THEN ''No'' ELSE ''Yes'' END check_apply,
		   cci.limit_expiration
	FROM #final_privilege_list cp '
		+ CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
			source_counterparty sc ON sc.source_counterparty_id = cp.value_id
	LEFT JOIN source_counterparty sc2 ON sc.parent_counterparty_id=sc2.source_counterparty_id
	INNER JOIN counterparty_credit_info cci ON sc.source_counterparty_id=cci.Counterparty_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = cci.account_status
	LEFT JOIN static_data_value sdv2 ON sdv2.value_id = cci.Risk_rating
	LEFT JOIN static_data_value sdv3 ON sdv3.value_id = cci.Debt_rating
	LEFT JOIN static_data_value sdv4 ON sdv4.value_id = cci.cva_data
	LEFT JOIN static_data_value sdv5 ON sdv5.value_id = cci.pfe_criteria
	LEFT JOIN static_data_value sdv6 ON sdv6.value_id = cci.Debt_Rating2
	LEFT JOIN static_data_active_deactive sdad ON sdad.type_id = 4002
	ORDER BY sc.counterparty_name'
	EXEC(@Sql_Select)
END
ELSE IF @flag = 'c'
BEGIN
	/* 
	*	Flag = 'c'
	*	Show Counterparty Dropdown List
	*	Modified to implement privilege in counterparty dropdown
	*/
	SET @Sql_Select = '	SELECT DISTINCT '
	IF @filter_value IS NOT NULL AND @filter_value = '-1'
	BEGIN
		SET @Sql_Select += ' TOP 1 '
	END
	SET @Sql_Select += '		sc.source_counterparty_id ,
								CASE  
									WHEN sc.source_system_id = 2 THEN '''' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + '' - '' + sc.counterparty_name END 
									ELSE ssd.source_system_name + ''.'' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + '' - '' + sc.counterparty_name END 
								END [counterparty], 
								MIN(cp.is_enable) [status]
						FROM #final_privilege_list cp ' 
						+ CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
						 source_counterparty sc ON sc.source_counterparty_id = cp.value_id
						INNER JOIN source_system_description ssd ON  ssd.source_system_id = sc.source_system_id'
		IF @filter_value IS NOT NULL AND @filter_value <> '-1'
		BEGIN
			SET @Sql_Select += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = sc.source_counterparty_id'
		END
		SET @Sql_Select += ' WHERE 1=1 AND sc.is_active = ''y'''

		IF @type_of_entity IS NOT NULL
			SET @Sql_Select =  @Sql_Select + ' AND sc.type_of_entity = ' + CAST(@type_of_entity AS VARCHAR(10))

		IF @int_ext_flag IS NOT NULL
			SET @Sql_Select =  @Sql_Select + ' AND sc.int_ext_flag = ''' + @int_ext_flag + ''''
			
		IF @not_int_ext_flag IS NOT NULL
			SET @Sql_Select =  @Sql_Select + ' AND sc.int_ext_flag <> ''' + @not_int_ext_flag + ''''
				
		IF @is_active IS NOT NULL
			SET @Sql_Select =  @Sql_Select + ' AND sc.is_active = ''' + @is_active + ''''
			
		SET @Sql_Select +=	' GROUP BY sc.source_counterparty_id, sc.counterparty_name, sc.source_system_id, sc.counterparty_id, sc.counterparty_name, ssd.source_system_name
						ORDER BY [counterparty]'
		
		EXEC(@Sql_Select)
END
ELSE IF @flag = 'f'
BEGIN
	SET @Sql_Select = '
		SELECT sc.source_counterparty_id,
				sc.counterparty_name, 
				MIN(cp.is_enable) [status]
		FROM #final_privilege_list cp ' 
		+ CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
		 source_counterparty sc ON sc.source_counterparty_id = cp.value_id 
		INNER JOIN counterparty_credit_info cci ON cci.Counterparty_id = sc.source_counterparty_id 
		WHERE 1=1
		'
	IF @int_ext_flag IS NOT NULL
		SET @Sql_Select =  @Sql_Select + ' AND sc.int_ext_flag = ''' + @int_ext_flag + ''''
	SET @Sql_Select += ' GROUP BY sc.source_counterparty_id, sc.counterparty_name'
	EXEC(@Sql_Select)
END
ELSE IF @flag = 'h'
BEGIN
	SET @Sql_Select = '
		SELECT DISTINCT d.source_counterparty_id counterparty_id,
			CASE WHEN d.counterparty_name <> d.counterparty_id THEN d.counterparty_id + '' - '' + d.counterparty_name ELSE d.counterparty_id END + 
			CASE WHEN ssd.source_system_id=2 THEN '''' ELSE ''.'' + ssd.source_system_name 
			END AS [Pipeline Name], 
				MIN(cp.is_enable) [status]
		FROM #final_privilege_list cp ' 
		+ CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
		 source_counterparty d ON d.source_counterparty_id = cp.value_id  
		INNER JOIN source_system_description ssd ON d.source_system_id = ssd.source_system_id 
		INNER JOIN fas_strategy c ON ssd.source_system_id = c.source_system_id 
		INNER JOIN portfolio_hierarchy b ON  b.parent_entity_id = c.fas_strategy_id 
		LEFT JOIN rec_generator rg ON d.source_counterparty_id = rg.ppa_counterparty_id 
		INNER JOIN static_data_value sdv ON sdv.value_id = d.type_of_entity AND sdv.value_id=-10021
		WHERE 1 = 1 '
		SET @Sql_Select += ' GROUP BY d.source_counterparty_id, d.counterparty_name, d.counterparty_id, ssd.source_system_id, ssd.source_system_name'

	EXEC(@Sql_Select)
END
ELSE IF @flag = 'k'
BEGIN
	SET @Sql_Select = '
		SELECT DISTINCT sc.source_counterparty_id,
			CASE WHEN sc.counterparty_name <> sc.counterparty_id THEN sc.counterparty_id + '' - '' + sc.counterparty_name ELSE sc.counterparty_id END + 
			CASE WHEN ssd.source_system_id=2 THEN '''' ELSE ''.'' + ssd.source_system_name 
			END AS [Pipeline Name], 
			MIN(cp.is_enable) [status]
		FROM #final_privilege_list cp ' 
		+ CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
		 source_counterparty sc ON sc.source_counterparty_id = cp.value_id
			INNER JOIN source_system_description ssd ON sc.source_system_id = ssd.source_system_id	
			INNER JOIN delivery_path dp ON sc.source_counterparty_id = dp.counterParty
			INNER JOIN fas_strategy fs ON ssd.source_system_id = fs.source_system_id 
			INNER JOIN portfolio_hierarchy ph ON ph.parent_entity_id = fs.fas_strategy_id 
			LEFT JOIN delivery_path_detail dpd ON dp.path_id = dpd.path_id
			OR dp.path_id = dpd.path_name
		WHERE sc.is_active = ''y'' AND sc.int_ext_flag IN(''e'')
		 '
		SET @Sql_Select += ' GROUP BY sc.source_counterparty_id, sc.counterparty_name, sc.counterparty_id, ssd.source_system_id, ssd.source_system_name
							ORDER BY [Pipeline Name]'

	EXEC(@Sql_Select)
END
ELSE IF @flag = 'n'
BEGIN
	SET @Sql_Select = '
		SELECT sc.source_counterparty_id [ID],
		   	CASE WHEN sc.source_system_id = 2 THEN '''' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + '' - '' + sc.counterparty_name END 
			ELSE ssd.source_system_name + ''.'' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + '' - '' + sc.counterparty_name END 
			END  [Pipeline Name],
			MIN(cp.is_enable) [status]
		FROM #final_privilege_list cp ' 
			+ CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
			source_counterparty sc ON sc.source_counterparty_id = cp.value_id
		INNER JOIN source_system_description ssd ON ssd.source_system_id = sc.source_system_id
		INNER JOIN static_data_value sdv ON sdv.value_id = sc.type_of_entity 
		WHERE 1=1'
				
		IF @type_of_entity IS NOT NULL
			SET @Sql_Select =  @Sql_Select + ' AND sc.type_of_entity = ' + CAST(@type_of_entity AS VARCHAR(10))
		
		SET @Sql_Select += ' GROUP BY sc.source_counterparty_id, sc.source_system_id, sc.counterparty_name, sc.counterparty_id, ssd.source_system_name							
							ORDER BY CASE  
							WHEN sc.source_system_id = 2 THEN '''' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + '' - '' + sc.counterparty_name END 
							ELSE ssd.source_system_name + ''.'' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + '' - '' + sc.counterparty_name END 
							END
			'
		Exec(@Sql_Select);
END
ELSE IF @flag = 'o'
BEGIN
	SET @Sql_Select = '
			SELECT DISTINCT sc2.source_counterparty_id,
				sc2.counterparty_name + CASE WHEN ssd.source_system_id = 2 THEN ''''
				ELSE ''.'' + ssd.source_system_name
				END AS NAME,
				MIN(cp.is_enable) [status]
			FROM #final_privilege_list cp ' 
				+ CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
				source_counterparty sc ON sc.source_counterparty_id = cp.value_id
				INNER JOIN counterparty_contract_address cca ON  cca.counterparty_id = sc.source_counterparty_id 
				INNER JOIN contract_group cg ON  cca.contract_id = cg.contract_id
				LEFT JOIN static_data_value sdv ON  sdv.value_id = cca.contract_status
				LEFT JOIN static_data_value sdv1 ON  sdv1.value_id = cca.rounding
				LEFT JOIN source_counterparty sc2 ON  sc2.source_counterparty_id = cca.internal_counterparty_id
				LEFT JOIN source_system_description ssd ON  ssd.source_system_id = cg.source_system_id		
			WHERE  1 = 1'
			
			IF @counterparty_id IS NOT NULL
			BEGIN
				SET @Sql_Select = @Sql_Select + ' AND cca.counterparty_id = ' + @counterparty_id 
			END
			
			IF @counterparty_id IS NOT NULL
			BEGIN
				SET @Sql_Select = @Sql_Select + ' AND sc2.int_ext_flag IN ('''+@counterparty_type+''')  AND sc2.is_active = ''y'''
			END	

			SET @Sql_Select += ' GROUP BY sc2.source_counterparty_id, sc2.counterparty_name, ssd.source_system_id, ssd.source_system_name
								ORDER BY NAME '

	Exec(@Sql_Select);
END
ELSE IF @flag = 'm'
BEGIN
	SET @Sql_Select = '
			SELECT DISTINCT sc.source_counterparty_id [Counterparty ID] 
			,sc.counterparty_name + CASE WHEN ssd.source_system_id=2 THEN '''' ELSE ''.'' + ssd.source_system_name  END AS [Counterparty Name],		
			MIN(cp.is_enable) [status]
			FROM #final_privilege_list cp ' 
				+ CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
				source_counterparty sc ON sc.source_counterparty_id = cp.value_id
			INNER JOIN source_system_description ssd ON sc.source_system_id = ssd.source_system_id
			--INNER JOIN fas_strategy fs ON  ssd.source_system_id = fs.source_system_id 
			--INNER JOIN portfolio_hierarchy ph ON ph.parent_entity_id = fs.fas_strategy_id
			outer apply (
				select ph.entity_id
				from portfolio_hierarchy ph 
				where ph.parent_entity_id = ' + isnull(CAST(@eff_test_profile_id AS VARCHAR), 'ph.parent_entity_id+1') + '
			) ph_oa
			WHERE 1=1 '
			+ CASE WHEN @eff_test_profile_id IS NOT NULL THEN ' and ph_oa.entity_id is not null' ELSE '' END 
			+ CASE WHEN @source_system_id IS NOT NULL THEN ' AND ssd.source_system_id = ' + CAST(@source_system_id AS VARCHAR) ELSE '' END
			+ ' AND sc.int_ext_flag IN('''+@counterparty_type+''') 
			AND sc.is_active = ''y'''				
			
		SET @Sql_Select += ' GROUP BY sc.source_counterparty_id, sc.counterparty_name, ssd.source_system_id, ssd.source_system_name
								ORDER BY [Counterparty Name] '		
		Exec(@Sql_Select);
END
ELSE IF @flag = 'e'
BEGIN
	/* 
	*	Flag = 'e'
	*	Show Counterparty Browser grid
	*/
	SET @Sql_Select = '	SELECT sc.source_counterparty_id, 
								CASE  
									WHEN sc.source_system_id = 2 THEN '''' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + '' - '' + sc.counterparty_name END 
									ELSE ssd.source_system_name + ''.'' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + '' - '' + sc.counterparty_name END 
								END [counterparty],
								CASE WHEN int_ext_flag = ''e'' THEN ''External'' ELSE CASE WHEN int_ext_flag = ''b'' THEN ''Broker'' ELSE ''Internal'' END END [counterparty_type] , 
								MIN(cp.is_enable) [status]
						FROM #final_privilege_list cp '  
						+ CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
						 source_counterparty sc ON sc.source_counterparty_id = cp.value_id
						 INNER JOIN source_system_description ssd ON  ssd.source_system_id = sc.source_system_id'

	IF @check_apply IS NOT NULL
		SET @Sql_Select += ' RIGHT JOIN counterparty_credit_info AS cci ON  cci.Counterparty_id = sc.source_counterparty_id'
	
	IF @filter_value IS NOT NULL AND @filter_value <> '-1'
	BEGIN
		SET @Sql_Select += ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @filter_value + ''') s ON s.item = sc.source_counterparty_id'
	END
	
	SET @Sql_Select += ' WHERE 1=1'
	
	IF @check_apply = 'n'
		SET @Sql_Select += ' AND cci.check_apply IS NULL OR cci.check_apply = ''n'''
	ELSE IF @check_apply = 'y'
		SET @Sql_Select += ' AND cci.check_apply = ''y'''

	SET @Sql_Select +=	'	GROUP BY sc.source_counterparty_id, sc.counterparty_id, sc.counterparty_name, sc.int_ext_flag, sc.source_system_id, ssd.source_system_name ORDER BY [counterparty]'
	EXEC(@Sql_Select)
END
ELSE IF @flag = 'p'
BEGIN
	/*
	*	Flag = 'p'
	*	Show Counterparty Dropdown mapped with counterparty_epa_account
	*/
	SET @Sql_Select = ' SELECT sc.source_counterparty_id,
								sc.counterparty_name,
								MIN(cp.is_enable) [status]
	                    FROM #final_privilege_list cp '  
						+ CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + ' 
	                    counterparty_epa_account cea ON  cea.counterparty_id = cp.value_id
	                    INNER JOIN static_data_value sdv_cea ON sdv_cea.value_id = cea.external_type_id 
						INNER JOIN static_data_type sdt_cea ON sdt_cea.type_id = sdv_cea.type_id AND sdt_cea.type_name = '''+@static_type_name+'''
						INNER JOIN source_counterparty sc ON  cea.counterparty_id =  sc.source_counterparty_id 
	                    WHERE cea.external_type_id = sdv_cea.value_id AND sdv_cea.code = '''+@static_code+''''
	                    
	SET @Sql_Select +=	' GROUP BY sc.source_counterparty_id, sc.counterparty_name '                   
						
	EXEC(@Sql_Select)
END
ELSE IF @flag = 't'
BEGIN
	    SET @Sql_Select = 'SELECT source_counterparty.source_counterparty_id ID
							, source_counterparty.counterparty_name + CASE WHEN source_counterparty.source_system_id=2 THEN '''' ELSE ''.'' + source_system_description.source_system_name END as Name
							
						FROM source_counterparty 
						INNER JOIN source_system_description ON source_system_description.source_system_id = source_counterparty.source_system_id
						WHERE 1 = 1 '
					+ CASE 
						   WHEN @source_system_id IS NOT NULL THEN 
								'  AND source_counterparty.source_system_id=' + CONVERT(VARCHAR(20), @source_system_id)
								+ ''
						   ELSE ''
					  END
					+ CASE 
						   WHEN @int_ext_flag IS NOT NULL THEN 
								' AND source_counterparty.int_ext_flag = ''' + @int_ext_flag
								+ ''''
						   ELSE ''
					  END
					+ CASE 
						   WHEN @source_counterparty_id IS NOT NULL THEN 
								' AND source_counterparty.source_counterparty_id = ' + CAST(@source_counterparty_id AS VARCHAR(100)) 
								+ ''
						   ELSE ''
					  END
					
    SET @Sql_Select = @Sql_Select + 
        ' ORDER BY source_counterparty.counterparty_name'
    
    EXEC (@SQL_select)
END
ELSE IF @flag = 'y' -- pipeline dropdown and grid
BEGIN	
	SELECT sc.source_counterparty_id, 
		CASE  
				WHEN sc.source_system_id = 2 THEN '' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + ' - ' + sc.counterparty_name END 
				ELSE ssd.source_system_name + '.' + CASE WHEN sc.counterparty_id = sc.counterparty_name THEN sc.counterparty_id  ELSE sc.counterparty_id + ' - ' + sc.counterparty_name END 
		END [counterparty] 
	FROM   source_counterparty sc 
	INNER JOIN source_system_description ssd ON  ssd.source_system_id = sc.source_system_id
	WHERE sc.type_of_entity = -10021 -- ID for Pipeline
	ORDER BY sc.counterparty_id
END
ELSE IF @flag = 'b'
BEGIN
	SELECT sc.int_ext_flag
	FROM source_counterparty sc
	WHERE sc.source_counterparty_id = @counterparty_id
END

IF @flag IN ('v','z')
BEGIN
	SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())
	SET @alert_process_table = 'adiha_process.dbo.alert_counterparty_' + @process_id + '_ac'

		--PRINT('CREATE TABLE ' + @alert_process_table + '(calc_id INT NOT NULL, invoice_number INT NOT NULL, invoice_status INT NOT NULL)')
	EXEC('CREATE TABLE ' + @alert_process_table + ' (
			source_counterparty_id      INT NOT NULL,
			counterparty_name			VARCHAR(200) NOT NULL
			)')
				
	SET @Sql_Select = 'INSERT INTO ' + @alert_process_table + '(source_counterparty_id, counterparty_name) 
				SELECT sc.source_counterparty_id, sc.counterparty_name
				FROM source_counterparty sc
				WHERE sc.source_counterparty_id = ' + @counterparty_id
				
	EXEC(@Sql_Select)		

	IF @flag = 'z'
	BEGIN
		EXEC spa_register_event 20602, 20542, @alert_process_table, 1, @process_id
		EXEC spa_register_event 20602, 20574, @alert_process_table, 1, @process_id
	END
	ELSE IF @flag = 'v'
	BEGIN
		EXEC spa_register_event 20602, 20544, @alert_process_table, 1, @process_id
		EXEC spa_register_event 20602, 20574, @alert_process_table, 1, @process_id
	END
END
GO