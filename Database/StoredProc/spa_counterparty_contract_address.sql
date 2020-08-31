IF OBJECT_ID(N'[dbo].[spa_counterparty_contract_address]', N'P') IS NOT NULL
  DROP PROCEDURE [dbo].[spa_counterparty_contract_address]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	CRUD operations for table customer_order.

	Parameters 
	@import_flag						: Operation flag. 
											'u'
											'd'
	@counterparty_contract_address_id	:
	@counterparty_full_name				:
	@address1							:
	@address2							:
	@address3							:
	@address4							:
	@contract_id						:
	@email								:
	@fax								:
	@telephone							:
	@counterparty_id					:
	@contract_start_date				:
	@contract_end_date					:
	@apply_netting_rule					:
	@xml								:
	@time_zone							:
	@internal_counterparty_id			:
	@broker_id							:
*/

CREATE PROCEDURE [dbo].[spa_counterparty_contract_address] @flag char(1),
	@counterparty_contract_address_id int = NULL,
	@counterparty_full_name varchar(200) = NULL,
	@address1 NVARCHAR(1000) = NULL,
	@address2 NVARCHAR(1000) = NULL,	
	@address3 varchar(200) = NULL,
	@address4 varchar(200) = NULL,
	@contract_id VARCHAR(20) = NULL,
	@email varchar(200) = NULL,
	@fax varchar(20) = NULL,
	@telephone varchar(20) = NULL,
	@counterparty_id NVARCHAR(1000) = NULL,
	@contract_start_date datetime = NULL,
	@contract_end_date datetime = NULL,
	@apply_netting_rule char(1) = NULL,
	@xml NTEXT = NULL,
	@time_zone INT = NULL,
	@internal_counterparty_id VARCHAR(200) = NULL,
	@broker_id INT = NULL 
	
	AS

SET NOCOUNT ON

DECLARE @sql varchar(max)
DECLARE @desc VARCHAR(500)
DECLARE @err_no INT

DECLARE @alert_process_id VARCHAR(200)
DECLARE @alert_process_table VARCHAR(500)
DECLARE @new_counterparty_contract_address_id INT
SET @alert_process_id = dbo.FNAGetNewID()  
SET @alert_process_table = 'adiha_process.dbo.alert_counterparty_contract_address_' + @alert_process_id + '_cca'
DECLARE @idoc INT

IF @flag IN ('u', 'd')
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

	IF OBJECT_ID('tempdb..#temp_dispute_for_update') IS NOT NULL
		DROP TABLE #temp_contract_mapping_detail

	SELECT counterparty_contract_address_id,
		address1,
		address2,
		address3,
		address4,
		contract_id, 
		NULLIF(secondary_counterparty, '') secondary_counterparty,
		email,
		fax,
		telephone,
		counterparty_id,
		counterparty_full_name,
		NULLIF(contract_start_date, '') contract_start_date,
		NULLIF(contract_end_date, '') contract_end_date,
		apply_netting_rule,
		credit,
		billing_start_month,
		NULLIF(contract_date, '') contract_date,
		contract_status,
		contract_active,
		cc_mail,
		bcc_mail,
		remittance_to,
		cc_remittance,
		NULLIF(internal_counterparty_id, '') internal_counterparty_id,
		rounding,
		bcc_remittance,
		time_zone,
		NULLIF(offset_method, '') offset_method,
		NULLIF(interest_rate, '') interest_rate,
		NULLIF(interest_method, '') interest_method,
		NULLIF(negative_interest, '') negative_interest,
		NULLIF(no_of_days, '') no_of_days,
		NULLIF(threshold_provided, '') threshold_provided,
		NULLIF(threshold_received, '') threshold_received,
		NULLIF(payment_days, '') payment_days,
		NULLIF(invoice_due_date, '') invoice_due_date,
		NULLIF(holiday_calendar_id, '') holiday_calendar_id,
		NULLIF(counterparty_trigger, '') counterparty_trigger,
		NULLIF(company_trigger, '') company_trigger,
		CASE WHEN receivables = '' THEN NULL ELSE receivables END receivables,
		CASE WHEN payables = '' THEN NULL ELSE payables END payables,
		CASE WHEN confirmation = '' THEN NULL ELSE confirmation END confirmation,
		NULLIF(analyst, '') analyst, 
		NULLIF(min_transfer_amount, '') min_transfer_amount, 
		NULLIF(comments, '') comments,
        NULLIF(amendment_date,'') amendment_date,
		NULLIF(amendment_description,'') amendment_description,
		NULLIF(external_counterparty_id,'') external_counterparty_id,
		NULLIF(description,'') description, 
		NULLIF(allow_all_products, '') allow_all_products,
		NULLIF(margin_provision,'') margin_provision 
	INTO #temp_contract_mapping_detail
	FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
	WITH (counterparty_contract_address_id int,
			address1 varchar(100),
			address2 varchar(100),
			address3 varchar(100),
			address4 varchar(100),
			contract_id int,
			secondary_counterparty INT,
			email varchar(1000),
			fax varchar(50),
			telephone varchar(20),
			counterparty_id int,
			counterparty_full_name varchar(400),
			contract_start_date datetime,
			contract_end_date datetime,
			apply_netting_rule char,
			credit VARCHAR(MAX),
			billing_start_month int,
			contract_date datetime,
			contract_status int,
			contract_active char,
			cc_mail varchar(5000),
			bcc_mail varchar(5000),
			remittance_to varchar(5000),
			cc_remittance varchar(5000),
			internal_counterparty_id int,
			rounding int,
			bcc_remittance varchar(5000),
			time_zone INT,
			offset_method	INT,
			interest_rate	INT,
			interest_method	VARCHAR(200),
			negative_interest INT,
			no_of_days INT,
			threshold_provided FLOAT,
			threshold_received FLOAT,
			payment_days INT,
			invoice_due_date INT,
			holiday_calendar_id INT,
			counterparty_trigger INT,
			company_trigger	INT,
			receivables	INT,
			payables INT,
			confirmation INT,
			analyst VARCHAR(100),
			min_transfer_amount FLOAT,
			comments varchar(200),
            amendment_date DATETIME,
			amendment_description VARCHAR(1000),
			external_counterparty_id VARCHAR(500),
			description VARCHAR(500),
			allow_all_products CHAR(1),
			margin_provision INT
	)
END

IF @flag = 's'
BEGIN
	SELECT
		cca.counterparty_contract_address_id,
		cg.contract_name,
		dbo.FNADateFormat(cca.contract_date) [contract_date],
		dbo.FNADateFormat(cca.contract_start_date) [contract_start_date],
		dbo.FNADateFormat(cca.contract_end_date) [contract_end_date],
		sdv.code contract_status,
		cca.contract_active,
		cca.billing_start_month,
		cca.apply_netting_rule--,
		--cca.address1,
		--cca.address2,
		--cca.address3,
		--cca.address4,
		--cca.email,
		--cca.fax,
		--cca.telephone,
		--cca.counterparty_id,
		--cca.counterparty_full_name,
		--cca.cc_mail,
		--cca.bcc_mail,
		--cca.remittance_to,
		--cca.cc_remittance,
		--cca.bcc_remittance
		, tz.TIMEZONE_NAME [Timezone]
        , cca.amendment_date
		, cca.amendment_description
		, cca.external_counterparty_id
		, cca.description
	FROM counterparty_contract_address cca
	INNER JOIN contract_group cg ON cca.contract_id = cg.contract_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = cca.contract_status
	LEFT JOIN [time_zones] tz ON tz.timezone_id = cca.time_zone
	WHERE cca.counterparty_id = @counterparty_id
END
ELSE IF @flag = 'a'
BEGIN
	SELECT
		counterparty_full_name [FullName],
		[address1] [Address1],
		[address2] [Address2],
		[address3] [Address3],
		[address4] [Address4],
		contract_id [Contract],
		email [Email],
		fax [Fax],
		telephone [Telephone],
		dbo.FNADateFormat(contract_start_date) [Contract Start Date],
		dbo.FNADateFormat(contract_end_date) [Contract End Date],
		apply_netting_rule,
		time_zone
	FROM counterparty_contract_address
	WHERE counterparty_contract_address_id = @counterparty_contract_address_id
END
ELSE
IF @flag = 'i' -- Save Address both insert and update cases
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

	IF OBJECT_ID('tempdb..#temp_contract_address_mapping') IS NOT NULL
		DROP TABLE #temp_contract_address_mapping

	SELECT
		counterparty_contract_address_id [counterparty_contract_address_id],
		contract_id [contract_id], 
		counterparty_id [counterparty_id],
		NULLIF(internal_counterparty_id, '') internal_counterparty_id,
		NULLIF(allow_all_products, '') allow_all_products
	INTO #temp_contract_address_mapping
	FROM OPENXML(@idoc, '/Root/FormXML', 1)
	WITH (
		counterparty_contract_address_id INT,
		contract_id INT,
		counterparty_id INT,
		internal_counterparty_id INT,
		allow_all_products CHAR(1)
	)

	IF EXISTS (
		SELECT 1 FROM [dbo].[counterparty_contract_address] cca
		INNER JOIN #temp_contract_address_mapping tcam
			ON tcam.counterparty_id = cca.counterparty_id
				AND tcam.contract_id = cca.contract_id AND ISNULL(tcam.internal_counterparty_id, -1) = ISNULL(cca.internal_counterparty_id, -1)
				AND tcam.counterparty_contract_address_id <> cca.counterparty_contract_address_id
	)
	BEGIN
		EXEC spa_ErrorHandler -1,
			'counterparty_contract_address',
			'spa_counterparty_contract_address',
			'DB Error',
			'Selected contract is already mapped to the counterparty.',
			''
		RETURN
	END
	ELSE
	BEGIN TRY
		BEGIN TRAN
		-- Use spa_process_form_data to save the data
		DECLARE @form_save_process_table VARCHAR(200) = dbo.FNAProcessTableName('save_counterparty_contract_address', dbo.FNADBUser(), dbo.FNAGetNewID())
		EXEC('CREATE TABLE ' + @form_save_process_table + '(id INT)')
		
		EXEC spa_process_form_data @xml = @xml, @return_process_table = @form_save_process_table
		
		-- Get counterparty_contract_address_id From process table
		IF OBJECT_ID('tempdb..#form_save_process_table') IS NOT NULL
			DROP TABLE #form_save_process_table

		CREATE TABLE #form_save_process_table(new_counterparty_contract_address_id INT)
		
		INSERT INTO #form_save_process_table(new_counterparty_contract_address_id)
		EXEC('SELECT id FROM ' + @form_save_process_table)

		SELECT @new_counterparty_contract_address_id = new_counterparty_contract_address_id FROM #form_save_process_table

		-- IF @new_counterparty_contract_address_id is not defined halt the process
		IF NULLIF(@new_counterparty_contract_address_id, '') IS NULL
		BEGIN
			;THROW 51000, 'The record does not exist.', 1
			RETURN
		END

		UPDATE ccbt
			SET ccbt.buysell_allow = 'y'
		FROM counterparty_credit_block_trading ccbt
		INNER JOIN #temp_contract_address_mapping tcam
			ON tcam.counterparty_id = ccbt.counterparty_id
		WHERE tcam.allow_all_products = 'y'
		
		UPDATE ccbt
			SET ccbt.[contract] = tcam.contract_id,
				ccbt.internal_counterparty_id = tcam.internal_counterparty_id
		FROM counterparty_credit_block_trading ccbt
		INNER JOIN #temp_contract_address_mapping tcam
			ON ISNULL(tcam.counterparty_contract_address_id, -1) = ccbt.counterparty_contract_address_id
		
		SET @sql = 'CREATE TABLE ' + @alert_process_table + '
					(
						counterparty_contract_address_id INT
					)
					INSERT INTO ' + @alert_process_table + '(
						counterparty_contract_address_id
					)
					SELECT ' + CAST(@new_counterparty_contract_address_id AS VARCHAR)
		EXEC(@sql)
		
		COMMIT TRAN

		-- Start Alert/Workflow Process
		EXEC spa_register_event 20622, 20571, @alert_process_table, 1, @alert_process_id
		EXEC spa_register_event 20622, 20575, @alert_process_table, 1, @alert_process_id

		EXEC spa_ErrorHandler 0,
			'counterparty_contract_address',
			'spa_counterparty_contract_address',
			'Success',
			'Changes have been saved successfully.',
			@new_counterparty_contract_address_id
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK

		EXEC spa_ErrorHandler -1,
			'counterparty_contract_address',
			'spa_counterparty_contract_address',
			'DB Error',
			'Failed to save the data.',
			''
		RETURN
	END CATCH
END
ELSE IF @flag = 'u'
BEGIN
	BEGIN TRAN
	BEGIN TRY

		IF EXISTS (SELECT 1 FROM [dbo].[counterparty_contract_address] cca
						INNER JOIN #temp_contract_mapping_detail tcc
						ON tcc.counterparty_id = cca.counterparty_id
						AND tcc.contract_id = cca.contract_id AND cca.internal_counterparty_id IS NULL AND tcc.internal_counterparty_id IS NULL
						AND cca.counterparty_contract_address_id = tcc.counterparty_contract_address_id )
			OR  EXISTS (SELECT 1 FROM [counterparty_contract_address] cca 
							INNER JOIN #temp_contract_mapping_detail tcc
							ON tcc.counterparty_id = cca.counterparty_id
							AND cca.contract_id = tcc.contract_id
							AND tcc.internal_counterparty_id = cca.internal_counterparty_id
							AND cca.counterparty_contract_address_id = tcc.counterparty_contract_address_id)
		BEGIN
			UPDATE cca
			SET cca.address1 = tcc.address1,
				cca.address2 = tcc.address2,
				cca.address3 = tcc.address3,
				cca.address4 = tcc.address4,
				cca.contract_id = tcc.contract_id,
				cca.secondary_counterparty = tcc.secondary_counterparty,			
				cca.email = tcc.email,
				cca.fax = tcc.fax,
				cca.telephone = tcc.telephone,
				cca.counterparty_full_name = tcc.counterparty_full_name,
				cca.contract_start_date = tcc.contract_start_date,
				cca.contract_end_date = tcc.contract_end_date,
				cca.apply_netting_rule = tcc.apply_netting_rule,
				cca.credit = tcc.credit,
				cca.billing_start_month = tcc.billing_start_month,
				cca.contract_date = tcc.contract_date,
				cca.contract_status = tcc.contract_status,
				cca.contract_active = tcc.contract_active,
				cca.cc_mail = tcc.cc_mail,
				cca.bcc_mail = tcc.bcc_mail,
				cca.remittance_to = tcc.remittance_to,
				cca.cc_remittance = tcc.cc_remittance,
				cca.internal_counterparty_id = tcc.internal_counterparty_id,
				cca.rounding = tcc.rounding,
				cca.bcc_remittance = tcc.bcc_remittance,
				time_zone = tcc.time_zone,
                cca.amendment_date = tcc.amendment_date,
				cca.amendment_description = tcc.amendment_description,
				cca.external_counterparty_id = tcc.external_counterparty_id,
				cca.description = tcc.description,
				cca.offset_method = tcc.offset_method,
				cca.interest_rate = tcc.interest_rate,
				cca.interest_method = tcc.interest_method,
				cca.negative_interest = tcc.negative_interest,
				cca.no_of_days = tcc.no_of_days,		 
				cca.threshold_provided = tcc.threshold_provided,		
				cca.threshold_received = tcc.threshold_received,			
				cca.payment_days = tcc.payment_days,
				cca.invoice_due_date = tcc.invoice_due_date,
				cca.holiday_calendar_id = tcc.holiday_calendar_id,
				cca.counterparty_trigger = tcc.counterparty_trigger,
				cca.company_trigger = tcc.company_trigger,
				cca.receivables	 = tcc.receivables,
				cca.payables	 = tcc.payables,
				cca.confirmation = tcc.confirmation,
				cca.analyst = tcc.analyst,
				cca.min_transfer_amount = tcc.min_transfer_amount,
				cca.comments = tcc.comments,
				cca.allow_all_products = tcc.allow_all_products,
				cca.margin_provision = tcc.margin_provision 
			FROM [dbo].[counterparty_contract_address] cca
			INNER JOIN #temp_contract_mapping_detail tcc
			ON tcc.counterparty_contract_address_id = cca.counterparty_contract_address_id
		
			UPDATE ccbt
			SET ccbt.buysell_allow = 'y'
			FROM counterparty_credit_block_trading	ccbt 	
			INNER JOIN #temp_contract_mapping_detail tcc
			ON tcc.counterparty_id = ccbt.counterparty_id
			   --AND tcc.internal_counterparty_id = ccbt.internal_counterparty_id
			   --AND tcc.contract_id = ccbt.[contract]
			WHERE   tcc.allow_all_products = 'y'
		
		
			UPDATE ccbt
			SET ccbt.[contract] = tcc.contract_id,
				ccbt.internal_counterparty_id = tcc.internal_counterparty_id
			FROM counterparty_credit_block_trading	ccbt 	
			INNER JOIN #temp_contract_mapping_detail tcc
			ON tcc.counterparty_contract_address_id = ccbt.counterparty_contract_address_id
			--ON tcc.counterparty_id = ccbt.counterparty_id 

			SELECT @new_counterparty_contract_address_id = counterparty_contract_address_id FROM #temp_contract_mapping_detail
		
			SET @sql = 'CREATE TABLE ' + @alert_process_table + '
							 (
	                 			counterparty_contract_address_id INT
							 )
							INSERT INTO ' + @alert_process_table + '(
								counterparty_contract_address_id
							  )
							SELECT ' +  CAST(@new_counterparty_contract_address_id AS VARCHAR)

			EXEC(@sql)
			COMMIT TRAN

			EXEC spa_register_event 20622, 20572, @alert_process_table, 1, @alert_process_id
			EXEC spa_register_event 20622, 20575, @alert_process_table, 1, @alert_process_id

		EXEC spa_ErrorHandler 0,
				'counterparty_contract_address',
				'spa_counterparty_contract_address',
				'Success',
				'Changes have been saved successfully.',
				''
		END			
		ELSE
			BEGIN 	
				IF EXISTS (SELECT 1 FROM [dbo].[counterparty_contract_address] cca
							INNER JOIN #temp_contract_mapping_detail tcc
							ON tcc.counterparty_id = cca.counterparty_id
							AND tcc.contract_id = cca.contract_id AND tcc.internal_counterparty_id = cca.internal_counterparty_id)     
				OR EXISTS (SELECT 1 FROM [counterparty_contract_address] cca 
							INNER JOIN #temp_contract_mapping_detail tcc
							ON tcc.counterparty_id = cca.counterparty_id
							AND cca.contract_id = tcc.contract_id
							AND cca.internal_counterparty_id IS NULL AND tcc.internal_counterparty_id IS NULL)
				BEGIN
					COMMIT TRAN
					EXEC spa_ErrorHandler -1,
						'counterparty_contract_address',
						'spa_counterparty_contract_address',
						'DB Error',
						'Selected contract is already mapped to the counterparty.',
						''
				END
			ELSE
				BEGIN			 
				UPDATE cca
				SET cca.address1 = tcc.address1,
					cca.address2 = tcc.address2,
					cca.address3 = tcc.address3,
					cca.address4 = tcc.address4,
					cca.contract_id = tcc.contract_id,
					cca.secondary_counterparty = tcc.secondary_counterparty,			
					cca.email = tcc.email,
					cca.fax = tcc.fax,
					cca.telephone = tcc.telephone,
					cca.counterparty_full_name = tcc.counterparty_full_name,
					cca.contract_start_date = tcc.contract_start_date,
					cca.contract_end_date = tcc.contract_end_date,
					cca.apply_netting_rule = tcc.apply_netting_rule,
					cca.credit = tcc.credit,
					cca.billing_start_month = tcc.billing_start_month,
					cca.contract_date = tcc.contract_date,
					cca.contract_status = tcc.contract_status,
					cca.contract_active = tcc.contract_active,
					cca.cc_mail = tcc.cc_mail,
					cca.bcc_mail = tcc.bcc_mail,
					cca.remittance_to = tcc.remittance_to,
					cca.cc_remittance = tcc.cc_remittance,
					cca.internal_counterparty_id = tcc.internal_counterparty_id,
					cca.rounding = tcc.rounding,
					cca.bcc_remittance = tcc.bcc_remittance,
					time_zone = tcc.time_zone,
                    cca.amendment_date = tcc.amendment_date,
				    cca.amendment_description = tcc.amendment_description,
				    cca.external_counterparty_id = tcc.external_counterparty_id,
				    cca.description = tcc.description,
					cca.offset_method = tcc.offset_method,
					cca.interest_rate = tcc.interest_rate,
					cca.interest_method = tcc.interest_method,
					cca.negative_interest = tcc.negative_interest,
					cca.no_of_days = tcc.no_of_days,		 
					cca.threshold_provided = tcc.threshold_provided,		
					cca.threshold_received = tcc.threshold_received,			
					cca.payment_days = tcc.payment_days,
					cca.invoice_due_date = tcc.invoice_due_date,
					cca.holiday_calendar_id = tcc.holiday_calendar_id,
					cca.counterparty_trigger = tcc.counterparty_trigger,
					cca.company_trigger = tcc.company_trigger,
					cca.receivables	 = tcc.receivables,
					cca.payables	 = tcc.payables,
					cca.confirmation = tcc.confirmation,
					cca.analyst = tcc.analyst,
					cca.min_transfer_amount = tcc.min_transfer_amount,
					cca.comments = tcc.comments,
					cca.allow_all_products = tcc.allow_all_products,
					cca.margin_provision = tcc.margin_provision 
				FROM [dbo].[counterparty_contract_address] cca
				INNER JOIN #temp_contract_mapping_detail tcc
				ON tcc.counterparty_contract_address_id = cca.counterparty_contract_address_id
		
				UPDATE ccbt
				SET ccbt.buysell_allow = 'y'
				FROM counterparty_credit_block_trading	ccbt 	
				INNER JOIN #temp_contract_mapping_detail tcc
				ON tcc.counterparty_id = ccbt.counterparty_id
				   --AND tcc.internal_counterparty_id = ccbt.internal_counterparty_id
				   --AND tcc.contract_id = ccbt.[contract]
				WHERE   tcc.allow_all_products = 'y'
		
		
				UPDATE ccbt
				SET ccbt.[contract] = tcc.contract_id,
					ccbt.internal_counterparty_id = tcc.internal_counterparty_id
				FROM counterparty_credit_block_trading	ccbt 	
				INNER JOIN #temp_contract_mapping_detail tcc
				ON tcc.counterparty_contract_address_id = ccbt.counterparty_contract_address_id

				SELECT @new_counterparty_contract_address_id = counterparty_contract_address_id FROM #temp_contract_mapping_detail
		
				SET @sql = 'CREATE TABLE ' + @alert_process_table + '
								 (
	                 				counterparty_contract_address_id INT
								 )
								INSERT INTO ' + @alert_process_table + '(
									counterparty_contract_address_id
								  )
								SELECT ' +  CAST(@new_counterparty_contract_address_id AS VARCHAR)

				EXEC(@sql)

				COMMIT TRAN

				EXEC spa_register_event 20622, 20572, @alert_process_table, 1, @alert_process_id
				EXEC spa_register_event 20622, 20575, @alert_process_table, 1, @alert_process_id

			EXEC spa_ErrorHandler 0,
					'counterparty_contract_address',
					'spa_counterparty_contract_address',
					'Success',
					'Changes have been saved successfully.',
					''
			END		
		END
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
				ROLLBACK

		EXEC spa_ErrorHandler -1,
				'counterparty_contract_address',
				'spa_counterparty_contract_address',
				'DB Error',
				'Couldnot update',
				''
	END CATCH
END
ELSE IF @flag = 'd'
BEGIN TRY
	DELETE cca
	FROM counterparty_contract_address cca
	INNER JOIN #temp_contract_mapping_detail tcc
	ON tcc.counterparty_contract_address_id = cca.counterparty_contract_address_id


	EXEC spa_ErrorHandler 0,
		'counterparty_contract_address',
		'spa_counterparty_contract_address',
		'Success',
		'Successfully Deleted',
		''
END TRY
BEGIN CATCH
	EXEC spa_ErrorHandler -1,
		'counterparty_contract_address',
		'spa_counterparty_contract_address',
		'Error',
		'Couldnot Delete',
		''
END CATCH
--delete in new framework
ELSE IF @flag = 'x'
BEGIN TRY
	DELETE cca
		FROM counterparty_contract_address cca
	WHERE counterparty_contract_address_id = @counterparty_contract_address_id


	EXEC spa_ErrorHandler 0,
		'counterparty_contract_address',
		'spa_counterparty_contract_address',
		'Success',
		'Successfully Deleted',
		''
END TRY
BEGIN CATCH
	EXEC spa_ErrorHandler -1,
		'counterparty_contract_address',
		'spa_counterparty_contract_address',
		'Error',
		'Couldnot Delete',
		''
END CATCH
ELSE IF @flag = 'm'
BEGIN
	SELECT		
		sc2.counterparty_name AS internal_counterparty,
		cg.[contract_name],
		cca.counterparty_contract_address_id,
		dbo.FNADateFormat(cca.contract_date) [contract_date],
		dbo.FNADateFormat(cca.contract_start_date) [contract_start_date],
		dbo.FNADateFormat(cca.contract_end_date) [contract_end_date],
		sdv.code contract_status,
		CASE
		WHEN cca.contract_active = 'y' THEN 'Yes'
		ELSE 'No'
		END AS [contract_active],
		--cca.billing_start_month [billing_start_month],
		CASE
		WHEN cca.apply_netting_rule = 'y' THEN 'Yes'
		ELSE 'No'
		END AS [apply_netting_rule],	
		sdv1.code AS rounding,
		tz.TIMEZONE_NAME [time_zone]
        , cca.amendment_date
		, cca.amendment_description
		, cca.external_counterparty_id
		, cca.description
	FROM counterparty_contract_address cca
	INNER JOIN contract_group cg ON cca.contract_id = cg.contract_id
	LEFT JOIN static_data_value sdv ON sdv.value_id = cca.contract_status
	LEFT JOIN static_data_value sdv1 ON sdv1.value_id = cca.rounding
	LEFT JOIN source_counterparty sc2 ON sc2.source_counterparty_id = cca.internal_counterparty_id
	INNER JOIN source_counterparty AS sc ON sc.source_counterparty_id = cca.counterparty_id
	LEFT JOIN [time_zones] tz ON tz.TIMEZONE_ID = cca.time_zone
	WHERE cca.counterparty_id = @counterparty_id
			AND ISNULL(contract_type_def_id,38400) <> 38405 --Netting
END
ELSE IF @flag = 'n'
BEGIN
	SELECT 
		cg.contract_id [id]
		, cg.[contract_name] [value]
	FROM counterparty_contract_address cca
	INNER JOIN contract_group cg 
		ON cca.contract_id = cg.contract_id
	WHERE cca.counterparty_id= @broker_id	
END
ELSE IF (@flag = 'v')
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

	IF OBJECT_ID('tempdb..#temp_delete_detail') IS NOT NULL
		DROP TABLE #temp_delete_detail

	SELECT grid_id INTO #temp_delete_detail
	FROM OPENXML(@idoc, '/Root/GridDelete', 1)
	WITH (grid_id int	)
	--DELETE FROM counterparty_contacts WHERE counterparty_contact_id = @counterparty_contact_id

	DELETE cca
	FROM master_view_counterparty_contract_address cca
	INNER JOIN #temp_delete_detail tdd ON cca.counterparty_contract_address_id = tdd.grid_id

	DELETE ccbt 
	FROM counterparty_credit_block_trading  ccbt
	INNER JOIN #temp_delete_detail tdd ON ccbt.counterparty_contract_address_id = tdd.grid_id

	DELETE cca
	FROM counterparty_contract_address cca
	INNER JOIN #temp_delete_detail tdd ON cca.counterparty_contract_address_id = tdd.grid_id


	EXEC spa_ErrorHandler 0,
		'counterparty_contract_address',
		'spa_counterparty_contract_address',
		'Success',
		'Changes have been saved successfully.',
		''
END
ELSE IF (@flag = 'g')  --deleting grid data in Product grid
BEGIN 
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
	
	IF OBJECT_ID('tempdb..#temp_product_delete_detail') IS NOT NULL
		DROP TABLE #temp_product_delete_detail 

	SELECT
		grid_id
	INTO  #temp_product_delete_detail 
	FROM OPENXML(@idoc, '/Root/GridDelete', 1)
	WITH (
		grid_id INT
	)

	DELETE ccbt
	FROM counterparty_credit_block_trading ccbt 
	INNER JOIN  #temp_product_delete_detail  tdd ON ccbt.counterparty_credit_block_id = tdd.grid_id 
	
	EXEC spa_ErrorHandler 0
		, 'CreditBlock'
		, 'spa_counterparty_contract_address'
		, 'Success' 
		, 'Changes have been saved successfully.'
		, ''
END
ELSE IF (@flag = 'h')  --load grid data in Product grid
BEGIN
	SET @sql = '
		SELECT ccbt.counterparty_credit_block_id [counterparty_credit_block_id],
				scp.counterparty_name [counterparty_id],
				scp1.counterparty_name [internal_counterparty_id],
				cg.contract_name [contract_name],
				sc.commodity_name [comodity_id],
				sdt.source_deal_type_name [deal_type_id],
				CASE ccbt.buy_sell WHEN ''1'' THEN ''Buy'' WHEN ''2'' THEN ''Sell'' WHEN ''3'' THEN ''Both'' ELSE '''' END [buy_sell],
				sdht.template_name [template_id]
				--,
				--CASE buysell_allow WHEN ''y'' THEN ''Yes'' WHEN ''n'' THEN ''No'' ELSE '''' END [buysell_allow]
		FROM counterparty_credit_block_trading  ccbt
		LEFT JOIN source_commodity sc ON sc.source_commodity_id = ccbt.comodity_id
		LEFT JOIN source_deal_type sdt ON sdt.source_deal_type_id = ccbt.deal_type_id
		LEFT JOIN source_deal_header_template sdht ON sdht.template_id = ccbt.template_id
		Left JOIN source_counterparty scp ON scp.source_counterparty_id = ccbt.counterparty_id
		Left join contract_group cg on cg.contract_id = ccbt.contract
		LEFT JOIN source_counterparty scp1 ON scp1.source_counterparty_id = ccbt.internal_counterparty_id
		WHERE 1=1
	'
	+
	CASE WHEN @counterparty_id IS NOT NULL 
		THEN 
			' AND ccbt.counterparty_id = '+ CAST(@counterparty_id AS VARCHAR) +''
		ELSE 
			' AND ccbt.counterparty_id IS NULL'
		END	
	+
	CASE WHEN @internal_counterparty_id != ''
		THEN 
			' AND ccbt.[internal_counterparty_id] = '+ CAST(@internal_counterparty_id AS VARCHAR) +''
		ELSE 
			' AND ccbt.[internal_counterparty_id] IS NULL'
		END	
	+
	CASE WHEN @contract_id != ''
		THEN 
			' AND ccbt.[contract] = '+CAST(@contract_id AS VARCHAR)+''
		ELSE 
			' AND ccbt.[contract] IS NULL'
		END			
			
	EXEC(@sql)	
END	


ELSE IF @flag = 'y'
BEGIN
	DECLARE @neting_rule CHAR(1) = NULL
	DECLARE @is_active CHAR(1) = NULL
	SELECT @neting_rule = cg.neting_rule, 
		@is_active = cg.is_active 
	FROM contract_group AS cg 
	WHERE contract_id = @contract_id
    IF EXISTS (
        SELECT 1
        FROM   counterparty_contract_address
        WHERE  contract_id = @contract_id
                AND counterparty_id = @counterparty_id
    )
    BEGIN
        UPDATE counterparty_contract_address
        SET   apply_netting_rule = @neting_rule,
			contract_active = @is_active
        WHERE  contract_id = @contract_id
                AND counterparty_id     = @counterparty_id
    END
    ELSE
    BEGIN
        INSERT INTO counterparty_contract_address
        (
            contract_id,
            counterparty_id,
            apply_netting_rule,
            contract_active
        )
        VALUES
        (
            @contract_id,
            @counterparty_id,
            @neting_rule,
            @is_active
        )
    END
END