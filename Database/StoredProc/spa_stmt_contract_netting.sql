IF OBJECT_ID(N'[dbo].[spa_stmt_contract_netting]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_stmt_contract_netting]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 /**
	Operation for Settlement cross contract netting

	Parameters :
	@flag : Flag
			's'-- Get the netting group
			'i'-- Insert Update Netting group
			'c'-- Get the contracts for the dropdown
			'a'-- Get the contracts in the netting
			'b'-- Insert Update Netting Group Details
			'd'-- Get the contract details
			'e'-- Delete netting group details
			'f'-- Delete the netting group
	@counterparty_id : Counterparty Id
	@contract_ids : Contract Ids
	@netting_group_id : Netting Group Id
	@netting_contract_id : Netting Contract Id
	@xml : Xml Data to pass grid data
	@form_xml : Form Xml tp pass Form Data
	@internal_counterparty_id : Internal Counterparty Id
 */
 
-- ===========================================================================================================
-- Author: srranjitkar@pioneersolutionsglobal.com
-- Create date: 2019-02-02
-- Description: operations for Contract Netting
 
-- Params:
-- @flag CHAR(1) - Operation flag 
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_stmt_contract_netting]
    @flag CHAR(1) = NULL, 
	@counterparty_id INT = NULL,
	@contract_ids VARCHAR(MAX) = NULL,
	@netting_group_id INT = NULL,
	@netting_contract_id INT = NULL,
	@xml VARCHAR(MAX) = NULL,
	@form_xml VARCHAR(MAX) = NULL,
	@internal_counterparty_id INT = NULL
AS
SET NOCOUNT ON

/** * DEBUG QUERY START *
	SET NOCOUNT ON

	DECLARE @flag CHAR(1) = NULL, 
		@counterparty_id INT = NULL,
		@contract_ids VARCHAR(MAX) = NULL,
		@netting_group_id INT = NULL,
		@netting_contract_id INT = NULL,
		@xml VARCHAR(MAX) = NULL,
		@form_xml VARCHAR(MAX) = NULL

	SELECT  @flag='i',
			@xml='<Root><GridGroup><Grid><GridRow  netting_contract_id="21" internal_counterparty_id="8890" netting_contract="1" description="1" effective_date="2019-02-01" netting_type="109801" contract_id="11571" counterparty_id ="123" ></GridRow> <GridRow  netting_contract_id="22" internal_counterparty_id="9014" netting_contract="2a" description="2a" effective_date="2019-02-01" netting_type="109800" contract_id="11572" counterparty_id ="123" ></GridRow> <GridRow  netting_contract_id="23" internal_counterparty_id="8908" netting_contract="asd" description="asd" effective_date="2019-03-01" netting_type="109802" contract_id="11573" counterparty_id ="123" ></GridRow> <GridRow  netting_contract_id="" internal_counterparty_id="9049" netting_contract="1" description="" effective_date="2019-02-04" netting_type="109801" contract_id="" counterparty_id ="123" ></GridRow> </Grid></GridGroup></Root>',
			@form_xml='<FormXML  billing_cycle="17900" billing_start_month="" billing_from_date="" billing_to_date="" billing_from_hour="" billing_to_hour="" invoice_due_date="" payment_days="" settlement_date="" settlement_days="" payment_calendar="" settlement_calendar="" pnl_date="" pnl_calendar="" holiday_calendar_id="" volume_granularity="993" invoice_report_template="119" contract_report_template="119" netting_template="119" contract_email_template="12" netting_contract ="1"></FormXML>'
 
-- * DEBUG QUERY END * */

DECLARE @sql VARCHAR(MAX)
DECLARE @error_no INT
DECLARE @error_msg VARCHAR(500)

IF @flag = 's'
BEGIN
	SELECT	sng.netting_group_id [id],
			sng.internal_counterparty_id,
			sng.netting_group_name,
			cg.contract_desc,
            sng.netting_type,
			sng.effective_date,
			cg.contract_id
	FROM stmt_netting_group sng
	INNER JOIN contract_group cg
		ON cg.contract_id = sng.netting_contract_id
	WHERE sng.counterparty_id = @counterparty_id
END
 
ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
		DECLARE @idoc INT
		DECLARE @idoc1 INT
		EXEC sp_xml_preparedocument @idoc OUTPUT,
			 @xml
		EXEC sp_xml_preparedocument @idoc1 OUTPUT,
			 @form_xml

	       
		IF OBJECT_ID('tempdb..#temp_contract_netting') IS NOT NULL
		  DROP TABLE #temp_contract_netting
      
		SELECT NULLIF(netting_contract_id, '') netting_group_id,
			   NULLIF(internal_counterparty_id,'') internal_counterparty_id,
			   NULLIF(netting_contract,'') netting_contract,
			   NULLIF([description], '') [description],
			   NULLIF(effective_date, '') effective_date,
			   NULLIF(netting_type, '') netting_type,
			   NULLIF(counterparty_id, '') counterparty_id,
			   NULLIF(contract_id, '') contract_id
			   INTO  #temp_contract_netting
		FROM   OPENXML(@idoc, '/Root/GridGroup/Grid/GridRow', 1)
			   WITH (
						netting_contract_id INT,
						internal_counterparty_id INT,
						netting_contract VARCHAR(500),
						[description] VARCHAR(500),
						effective_date DATETIME, 
						netting_type INT,
						counterparty_id INT,
						contract_id INT
					)    

		IF OBJECT_ID('tempdb..#temp_invoice_data') IS NOT NULL
		  DROP TABLE #temp_invoice_data
      
		SELECT NULLIF(billing_cycle, '') billing_cycle,
			   NULLIF(billing_start_month,'') billing_start_month,
			   NULLIF(billing_from_date,'') billing_from_date,
			   NULLIF(billing_to_date, '') billing_to_date,
			   NULLIF(billing_from_hour, '') billing_from_hour,
			   NULLIF(invoice_due_date, '') invoice_due_date,
			   NULLIF(payment_days, '') payment_days,
			   NULLIF(settlement_date, '') settlement_date,
			   NULLIF(settlement_days, '') settlement_days,
			   NULLIF(payment_calendar, '') payment_calendar,
			   NULLIF(settlement_calendar, '') settlement_calendar,
			   NULLIF(pnl_calendar, '') pnl_calendar,
			   NULLIF(holiday_calendar_id, '') holiday_calendar_id,
			   NULLIF(volume_granularity, '') volume_granularity,
			   NULLIF(invoice_report_template, '') invoice_report_template,
			   NULLIF(contract_report_template, '') contract_report_template,
			   NULLIF(netting_template, '') netting_template,
			   NULLIF(contract_email_template, '') contract_email_template,
			   NULLIF(netting_contract, '') netting_contract ,
			   NULLIF(credit, '') credit ,
			   NULLIF(receivables, '') receivables ,
			   NULLIF(payables, '') payables ,
			   NULLIF(counterparty_id, '') counterparty_id ,
			   NULLIF(offset_method, '') offset_method 
			   INTO  #temp_invoice_data
		FROM   OPENXML(@idoc1, '/FormXML', 1)
			   WITH (
						billing_cycle INT ,
						billing_start_month INT ,
						billing_from_date INT ,
						billing_to_date INT ,
						billing_from_hour INT ,
						invoice_due_date INT ,
						payment_days INT ,
						settlement_date INT ,
						settlement_days INT ,
						payment_calendar INT ,
						settlement_calendar INT ,
						pnl_calendar INT ,
						holiday_calendar_id INT ,
						volume_granularity INT ,
						invoice_report_template INT ,
						contract_report_template INT ,
						netting_template INT ,
						contract_email_template INT ,
						netting_contract VARCHAR(100) ,
						credit INT ,
						receivables INT ,
						payables INT ,
						counterparty_id INT ,
						offset_method INT
					)   
					

		IF OBJECT_ID('tempdb..#temp_duplicate_nettng_contract') IS NOT NULL
		  DROP TABLE #temp_duplicate_nettng_contract 

		SELECT netting_contract,
				count(*) AS c
		INTO #temp_duplicate_nettng_contract
		FROM #temp_contract_netting
		GROUP BY netting_contract
		HAVING count(*) > 1
		ORDER BY c desc 

		IF OBJECT_ID('tempdb..#temp_already_existed_nettng_contract') IS NOT NULL
		  DROP TABLE #temp_already_existed_nettng_contract 

		SELECT DISTINCT t.netting_contract
		INTO #temp_already_existed_nettng_contract
		FROM #temp_contract_netting t 
		INNER JOIN stmt_netting_group sng
			ON sng.netting_group_name = t.netting_contract
		WHERE t.counterparty_id <> sng.counterparty_id	  

		IF EXISTS (
			SELECT 1 FROM #temp_contract_netting t  
				INNER JOIN contract_group cg ON cg.contract_id <> t.contract_id 
			AND t.netting_contract = cg.source_contract_id
		) 
		BEGIN
			SET @error_msg = 'Contract must be unique.'
			EXEC spa_ErrorHandler -1, 
 				'contract_netting', 
 				'spa_stmt_contract_netting', 
 				'Error', 
 				@error_msg,
 				''
		    RETURN
		END

		IF EXISTS(SELECT 1 FROM #temp_duplicate_nettng_contract)
		BEGIN
			SET @error_msg = 'Netting Contract must be unique.'
			EXEC spa_ErrorHandler -1, 
 				'contract_netting', 
 				'spa_stmt_contract_netting', 
 				'Error', 
 				@error_msg,
 				''
		    RETURN
		END


		IF EXISTS(SELECT 1 FROM #temp_already_existed_nettng_contract)
		BEGIN 
			DECLARE @existing_contracts VARCHAR(200)
			SELECT  @existing_contracts = STUFF(( SELECT  ', ' + netting_contract
					 FROM    #temp_already_existed_nettng_contract
							FOR XML PATH('')), 1, 1, '')  
		
			SET @error_msg = 'Netting Contract(s) :' + '<b>'+ @existing_contracts + '</b>' + ' already exists.'  

			EXEC spa_ErrorHandler -1, 
 				'contract_netting', 
 				'spa_stmt_contract_netting', 
 				'Error', 
 				@error_msg,
 				''
			RETURN
		END		 			 
				
		INSERT INTO contract_group (contract_name,source_contract_id, contract_desc, contract_type_def_id, source_system_id)
		SELECT	netting_contract, 
				netting_contract,
				[description],
				38405,
				2 
		FROM #temp_contract_netting t
		LEFT JOIN contract_group cg
			ON cg.contract_id = t.contract_id
		WHERE cg.contract_id IS NULL

		UPDATE cg
		SET [contract_desc] = [description],
			[contract_name] = [netting_contract],
			[source_contract_id] = [netting_contract] 
		FROM contract_group cg
		INNER JOIN #temp_contract_netting t
			ON cg.contract_id = t.contract_id 

		INSERT INTO stmt_netting_group(netting_group_name, counterparty_id, internal_counterparty_id, netting_contract_id, effective_date, netting_type)
		SELECT	t.netting_contract,
				t.counterparty_id,
				t.internal_counterparty_id,
				cg.contract_id,
				t.effective_date,
				t.netting_type
		FROM #temp_contract_netting t
		LEFT JOIN contract_group cg ON cg.contract_name =  t.netting_contract
		LEFT JOIN stmt_netting_group sng
			ON sng.netting_group_id = t.netting_group_id
		WHERE sng.netting_group_id IS NULL

		UPDATE sng
		SET 
			internal_counterparty_id = t.internal_counterparty_id, 
			effective_date = t.effective_date,
			netting_type =	t.netting_type,
			netting_group_name = t.netting_contract
		FROM  stmt_netting_group sng
		INNER JOIN #temp_contract_netting t ON sng.netting_group_id = t.netting_group_id 

		UPDATE cg
		SET 
			billing_cycle = t.billing_cycle ,
			billing_start_month = t.billing_start_month ,
			billing_from_date = t.billing_from_date ,
			billing_to_date = t.billing_to_date ,
			billing_from_hour = t.billing_from_hour ,
			invoice_due_date = t.invoice_due_date,
			payment_days = t.payment_days,
			settlement_date = t.settlement_date,
			settlement_days = t.settlement_days,
			payment_calendar = t.payment_calendar,
			settlement_calendar = t.settlement_calendar,
			pnl_calendar = t.pnl_calendar ,
			holiday_calendar_id = t.holiday_calendar_id ,
			volume_granularity = t.volume_granularity ,
			invoice_report_template = t.invoice_report_template ,
			contract_report_template = t.contract_report_template ,
			netting_template = t.netting_template ,
			contract_email_template = t.contract_email_template  
		FROM contract_group cg
		INNER JOIN	#temp_invoice_data  t
			ON t.netting_contract = cg.contract_name		
		 
		INSERT INTO counterparty_contract_address (contract_id, counterparty_id, internal_counterparty_id)
		SELECT	cg.contract_id,
				t.counterparty_id, 
				t.internal_counterparty_id
		FROM #temp_contract_netting  t
		LEFT JOIN contract_group cg
			ON cg.contract_name = t.netting_contract
		LEFT JOIN counterparty_contract_address cca
			ON cca.contract_id = cg.contract_id
				AND cca.counterparty_id = t.counterparty_id
		WHERE cca.counterparty_contract_address_id IS NULL

		--SELECT * FROM #temp_contract_netting
		--SELECT * FROM #temp_invoice_data
		UPDATE cca	
			SET payables = t.payables,
				receivables = t.receivables,
				credit = t.credit,
				offset_method = t.offset_method,			
				payment_days = t.payment_days, 
				invoice_due_date = t.invoice_due_date,
				holiday_calendar_id = t.holiday_calendar_id, 
				internal_counterparty_id = t1.internal_counterparty_id
		FROM #temp_invoice_data  t
		LEFT JOIN #temp_contract_netting t1 
			ON t1.netting_contract = t.netting_contract
				AND t1.counterparty_id = t.counterparty_id
		LEFT JOIN contract_group cg
			ON cg.contract_name = t.netting_contract
		INNER JOIN counterparty_contract_address cca
			ON cca.contract_id = cg.contract_id
				AND cca.counterparty_id = t.counterparty_id
							 
		    
		EXEC spa_ErrorHandler 0, 
 				'contract_netting', 
 				'spa_stmt_contract_netting', 
 				'Success', 
 				'Data has been saved successfully.',
 				''
		    RETURN
	END TRY
	BEGIN CATCH 
		IF @@Error <> 0
			EXEC spa_ErrorHandler @@Error,
				 'contract_netting',
				 'spa_stmt_contract_netting',
				 'DB Error',
				 'Failed to save Contract Netting.',
				 ''	   
	END CATCH  
END

ELSE IF @flag = 'c'
BEGIN 
	SET @sql = '
	SELECT		
		cg.contract_id [id],
		cg.[contract_name] [value]
	FROM counterparty_contract_address cca
	INNER JOIN contract_group cg ON cca.contract_id = cg.contract_id
	WHERE 1 = 1
		AND cca.counterparty_id =' + CAST(@counterparty_id AS VARCHAR) + '
		AND ISNULL(contract_type_def_id,38400) <> 38405 ' +
	CASE WHEN NULLIF(@internal_counterparty_id, '') IS NOT NULL THEN ' 
		AND cca.internal_counterparty_id = ' + CAST (@internal_counterparty_id AS VARCHAR) 
	ELSE '' END 

	EXEC (@sql)
END

ELSE IF @flag = 'a'
BEGIN
	SELECT	sngd.netting_group_detail_id,
			cg.contract_name,
			cg.contract_desc 
	FROM stmt_netting_group_detail sngd
	LEFT JOIN contract_group cg 
		ON cg.contract_id = sngd.contract_detail_id
	WHERE sngd.netting_group_id = @netting_group_id
END

ELSE IF @flag = 'b'
BEGIN
	BEGIN TRY 	     
		EXEC sp_xml_preparedocument @idoc OUTPUT,
			 @xml

		IF OBJECT_ID('tempdb..#temp_contract') IS NOT NULL
		  DROP TABLE #temp_contract
      
		SELECT 
			   netting_group_detail_id,	
			   NULLIF(netting_group_id, '') netting_group_id,
			   NULLIF(contract_id,'') contract_id 
			   INTO  #temp_contract
		FROM   OPENXML(@idoc, '/Root/GridGroup/Grid/GridRow', 1)
			   WITH (
						netting_group_detail_id VARCHAR(20),
						netting_group_id INT,
						contract_id INT 
					)      
		
		
		IF OBJECT_ID('tempdb..#temp_duplicate_netting_contract') IS NOT NULL
		  DROP TABLE #temp_duplicate_netting_contract 

		SELECT contract_id,
				count(*) AS c
		INTO #temp_duplicate_netting_contract
		FROM #temp_contract
		GROUP BY contract_id
		HAVING count(*) > 1
		ORDER BY c desc 

		IF EXISTS(SELECT 1 FROM #temp_duplicate_netting_contract)
		BEGIN
			SET @error_msg = 'Contract must be unique.'
			EXEC spa_ErrorHandler -1, 
 				'contract_netting', 
 				'spa_stmt_contract_netting', 
 				'Error', 
 				@error_msg,
 				''
		    RETURN
		END

		IF OBJECT_ID('tempdb..#temp_already_existed_contract') IS NOT NULL
		  DROP TABLE #temp_already_existed_contract 

		SELECT DISTINCT cg.contract_name
		INTO #temp_already_existed_contract
		FROM #temp_contract t 
		INNER JOIN stmt_netting_group_detail sng
			ON sng.netting_group_id = t.netting_group_id
		LEFT JOIN contract_group cg 
			ON cg.contract_id = t.contract_id
		WHERE t.contract_id = sng.contract_detail_id	
		AND t.netting_group_detail_id <> sng.netting_group_detail_id

		IF EXISTS(SELECT 1 FROM #temp_already_existed_contract)
		BEGIN
			SET @error_msg = 'Contract must be unique.'
			EXEC spa_ErrorHandler -1, 
 				'contract_netting', 
 				'spa_stmt_contract_netting', 
 				'Error', 
 				@error_msg,
 				''
		    RETURN
		END

		UPDATE s
		SET s.contract_detail_id = t.contract_id 
		FROM stmt_netting_group_detail s
		INNER JOIN #temp_contract t
			ON t.netting_group_detail_id = s.netting_group_detail_id
		WHERE t.netting_group_detail_id IS NOT NULL 

		INSERT INTO stmt_netting_group_detail(netting_group_id, contract_detail_id)
		SELECT	t.netting_group_id,
				t.contract_id 
		FROM #temp_contract t 
		WHERE t.netting_group_detail_id IS NULL OR t.netting_group_detail_id = ' '

		DECLARE @recommendation_return VARCHAR(2000) = SCOPE_IDENTITY()

		EXEC spa_ErrorHandler 0,
		         'contract_netting',
		         'spa_stmt_contract_netting',
		         'Success',
		         'Data has been successfully saved.',
		         @recommendation_return
		    
		    RETURN
	END TRY
	BEGIN CATCH 
		IF @@Error <> 0
			EXEC spa_ErrorHandler @@Error,
				 'contract_netting',
				 'spa_stmt_contract_netting',
				 'DB Error',
				 'Failed to save Contract.',
				 ''	   
	END CATCH  
END

ELSE IF @flag = 'd'
BEGIN
	SELECT 
			cg.invoice_due_date [payment_rule],
			cg.payment_days [payment_days],
			cg.settlement_date [settlement_rule],
			cg.settlement_days [settlement_days],
			cg.payment_calendar [payment_calendar],
			cg.settlement_calendar [settlement_calendar],
			cg.holiday_calendar_id [holiday_calendar],
			cg.volume_granularity [invoice_frequency],
			cg.invoice_report_template [invoice],
			cg.contract_report_template [remittance],
			cg.netting_template [netting],
			cg.contract_email_template [email],
			cca.[credit] [credit],
			cca.payables [payables],
			cca.receivables [receivables],
			c_c.name [credit_name],
			c_p.name [payables_name],
			c_r.name [receivables_name],
			cca.offset_method [offset_method]
	FROM contract_group cg 
	LEFT JOIN counterparty_contract_address cca
		ON cca.contract_id = cg.contract_id
			AND cca.counterparty_id = @counterparty_id
	LEFT JOIN counterparty_contacts c_c
		ON c_c.counterparty_contact_id = cca.[credit]
	LEFT JOIN counterparty_contacts c_p
		ON c_p.counterparty_contact_id = cca.payables
	LEFT JOIN counterparty_contacts c_r
		ON c_r.counterparty_contact_id = cca.receivables
	WHERE cg.contract_id = @netting_contract_id
END

ELSE IF @flag = 'e'
BEGIN
	EXEC('
			DELETE FROM stmt_netting_group_detail
			WHERE netting_group_detail_id IN (' +  @contract_ids + ')
	')

	EXEC spa_ErrorHandler 0,
		         'contract_netting',
		         'spa_stmt_contract_netting',
		         'Success',
		         'Contract(s) deleted successfully..',
		         ''		    
	RETURN
END

ELSE IF @flag = 'f'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DECLARE @contract_id VARCHAR(20)
			SELECT @contract_id = netting_contract_id from stmt_netting_group where netting_group_id = @netting_group_id

			DELETE FROM contract_group WHERE contract_id = @contract_id

	
			DELETE FROM stmt_netting_group_detail where netting_group_id = @netting_group_id

			DELETE FROM stmt_netting_group where netting_group_id = @netting_group_id

			EXEC spa_ErrorHandler 0,
						 'contract_netting',
						 'spa_stmt_contract_netting',
						 'Success',
						 'Netting Contract(s) deleted successfully..',
						 ''		     
			COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN
		
		--EXEC spa_print ERROR_MESSAGE()
		SET @error_no = ERROR_NUMBER()
		EXEC spa_ErrorHandler @error_no, 
							'contract_netting', 
							'spa_stmt_contract_netting', 
							'DB Error', 
							'Failed to delete Netting Contract.', ''
	END CATCH	
END
GO
 