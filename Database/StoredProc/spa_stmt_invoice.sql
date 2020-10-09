
IF OBJECT_ID(N'[dbo].[spa_stmt_invoice]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_stmt_invoice]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 /**
	Operation for Settlement Invoice

	Parameters :
	@flag : Flag
			@flag = 's' -> Load data in the main grid
			@flag = 'a' -> Load settlement invoice details
			@flag = 'f' -> Finalize
			@flag = 'w' -> Update workflow status
			@flag = 'v' -> Void the invoice
			@flag = 'i' -> For Invoice RDL generation Header Level
			@flag = 'j' -> For Invoice RDL generation Detail Level
			@flag = 'g' -> For Invoice RDL generation Summary Level
			@flag = 'e' -> For sending settlement invoice 
	@delivery_date_from : Delivery Date From Filter
	@delivery_date_to : Delivery Date To Filter
	@settlement_date_from : Settlement Date From Filter
	@settlement_date_to : Settlement Date To Filter
	@payment_date_from : Payment Date From Filter
	@payment_date_to : Payment Date To Filter
	@counterparty_type : Counterparty Type Filter
	@counterparty_id : Counterparty Id Filter
	@contract_id : Contract Id Filter
	@invoice_type : Invoice Type Filter
	@invoice_id : Invoice Id Filter
	@show_backing_sheets : 'n'-just snow netting invoice,'y'-show individual as well as netting invoice
	@commodity_id : Commodity Id Filter
	@invoice_status : Invoice Status Filter
	@acc_status : Acc Status Filter
    @loc_status : lock Status Filter
    @pay_status : Pay Status Filter
	@is_voided : 'y' show voided invoice
	@xml : Xml Data
	@amount : Amount
	@invoice_date : Invoice Date
	@invoice_due_date : Invoice Due Date
	@description1 : Description1
	@description2 : Description2
	@invoice_ref_no : Invoice Ref No
	@stmt_invoice_id : Stmt Invoice Id (stmt_invoice_id FROM stmt_invoice)
	@accounting_month : Accounting Month
	@notify_users	:	Users to which the notifications is sent.
	@notify_roles	:	Roles to which the notifications is sent.
	@non_system_users : email ids for non system user which are not add in Setup User menu.
	@send_option : send option
	@process_id : Process Id 
	@group_by : Group result in deal/charge type e.t.c.
	
 */

CREATE PROCEDURE [dbo].[spa_stmt_invoice]
	@flag	VARCHAR(10),
	@delivery_date_from VARCHAR(20) = NULL,
	@delivery_date_to VARCHAR(20) = NULL,
	@settlement_date_from VARCHAR(20) = NULL,
	@settlement_date_to VARCHAR(20) = NULL,
	@payment_date_from VARCHAR(20) = NULL,
	@payment_date_to VARCHAR(20) = NULL,
	@counterparty_type CHAR(1) = NULL,
	@counterparty_id NVARCHAR(1000) = NULL,
	@contract_id VARCHAR(500) = NULL,
	@invoice_type CHAR(1) = NULL,
	@invoice_id VARCHAR(100) = NULL, 
	@show_backing_sheets CHAR(1) = NULL,
	@commodity_id INT = NULL,
	@invoice_status INT = NULL,
	@acc_status CHAR(1) = NULL,
	@is_voided CHAR(1) = NULL,
	@xml TEXT = NULL,
	@amount FLOAT = NULL,
	@invoice_date VARCHAR(20) = NULL,
	@invoice_due_date VARCHAR(20) = NULL,
	@description1 VARCHAR(500) = NULL,
	@description2 VARCHAR(500) = NULL,
	@invoice_ref_no VARCHAR(500) = NULL,
	@stmt_invoice_id INT = NULL,
	@accounting_month VARCHAR(20) = NULL,
	@notify_users NVARCHAR(MAX) = NULL,
 	@notify_roles NVARCHAR(MAX) = NULL,
 	@non_system_users NVARCHAR(MAX) = NULL,
	@send_option NCHAR(1) = NULL,
	@loc_status CHAR(1) = NULL,
	@pay_status CHAR(1) = NULL,
	@process_id VARCHAR(200) = NULL,
    @invoice_number VARCHAR(MAX) = NULL,
	@group_by VARCHAR(20) = NULL

AS

--DECLARE

--@flag	VARCHAR(10) = 'w',
--	@delivery_date_from VARCHAR(20) = NULL,
--	@delivery_date_to VARCHAR(20) = NULL,
--	@settlement_date_from VARCHAR(20) = NULL,
--	@settlement_date_to VARCHAR(20) = NULL,
--	@payment_date_from VARCHAR(20) = NULL,
--	@payment_date_to VARCHAR(20) = NULL,
--	@counterparty_type CHAR(1) = NULL,
--	@counterparty_id VARCHAR(500) = NULL,
--	@contract_id VARCHAR(500) = NULL,
--	@invoice_type CHAR(1) = NULL,
--	@invoice_id VARCHAR(100) = NULL, 
--	@show_backing_sheets CHAR(1) = 'n', -- To show individual invoice for netting counterparty
--	@commodity_id INT = NULL,
--	@invoice_status INT = 20701,
--	@acc_status CHAR(1) = NULL,
--	@is_voided CHAR(1) = NULL,
--	@xml VARCHAR(5000) = '<Root><PSRecordSet stmt_invoice_id = "6"></PSRecordSet></Root>',
--	@amount FLOAT = NULL,
--	@invoice_date VARCHAR(20) = NULL,
--	@invoice_due_date VARCHAR(20) = NULL,
--	@description1 VARCHAR(500) = NULL,
--	@description2 VARCHAR(500) = NULL,
--	@invoice_ref_no VARCHAR(500) = NULL,
--	@stmt_invoice_id INT = NULL,
--	@accounting_month VARCHAR(20) = NULL


SET NOCOUNT ON
DECLARE @sql VARCHAR(MAX),
		@idoc  INT,
		@alert_process_table VARCHAR(300),
		@message VARCHAR(4000),
		@job_name NVARCHAR(150) = NULL,
		@user_login_id NVARCHAR(250) = dbo.FNADBUser(),
		@msg VARCHAR(MAX),
		@batch_process_id VARCHAR(1024)

IF @flag = 's' --load Settlement Invoice main grid
BEGIN 
	 SET @sql = 'SELECT   ' + char(10)
			 + '		sc.counterparty_id   [counterparty],  ' + char(10)
			 + '		cg.contract_name   [contract],  ' + char(10)
			 + '		si.invoice_number   [invoice_number],  ' + char(10)
			 + '		si.stmt_invoice_id   [invoice_id],  ' + char(10)
			 + '		si.counterparty_id   [counterparty_id],  ' + char(10)
			 + '		si.contract_id contract_id,  ' + char(10)
			 + '		COALESCE(crt.template_name,crp_invoice.template_name) [inv_template], ' + char(10)
			 + '		COALESCE(crt.template_name,crp_remittance.template_name) [rem_template], ' + char(10)
			 + '		COALESCE(crt.template_name,crp_netting.template_name) [net_template], ' + char(10)
			 + '		dbo.FNADateFormat(si.prod_date_from) [date_from],  ' + char(10)
			 + '		dbo.FNADateFormat(si.prod_date_to) [date_to],  ' + char(10)


			 + '		COALESCE(dbo.FNADateFormat(si.invoice_date), dbo.FNADateFormat(si.as_of_date), dbo.FNADateFormat(dbo.FNAInvoiceDueDate( CASE WHEN cg.settlement_date = ''20023''  OR cg.settlement_date = ''20024'' THEN si.finalized_date ELSE si.prod_date_from END, cg.settlement_date, cg.holiday_calendar_id, cg.settlement_days))) [invoice_date],  ' + char(10)


			 + '		dbo.FNARemoveTrailingZeroes(ROUND(sid.[Value], 2)) [amount],  ' + char(10)
			 + '		scu.currency_name [currency],  ' + char(10)
			 + '		CASE WHEN si.is_finalized = ''f'' THEN ''Finalized'' WHEN ISNULL(si.is_finalized, ''n'') = ''n'' THEN ''Not Finalized''  END [acc_status],  ' + char(10)
			 + '		sdv_workflow.[description] AS [workflow_status],  ' + char(10)
			 + '		CASE WHEN si.is_voided = ''v'' THEN ''Voided'' WHEN ISNULL(si.is_voided, ''n'') = ''n'' THEN ''Not Voided''  END [void_status],  ' + char(10)
			 + '		CASE WHEN si.invoice_type =''i'' THEN ''Invoice'' WHEN si.invoice_type =''r'' THEN ''Remittance'' END [invoice_type],  ' + char(10)
			 + '		ISNULL(dbo.FNADateFormat(si.payment_date), dbo.FNADateFormat(dbo.FNAInvoiceDueDate( CASE WHEN cg.invoice_due_date = ''20023''  OR cg.invoice_due_date = ''20024'' THEN si.finalized_date ELSE si.prod_date_from END, cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days))) [payment_date],  ' + char(10)
			 + '		CAST(si.stmt_invoice_id AS VARCHAR(20)) [stmt_invoice_id],  ' + char(10)
			 + '		dbo.FNADateFormat(si.finalized_date) [finalized_date],  ' + char(10)
			 + '		si.invoice_note [invoice_note],  ' + char(10)
			 + '		si.invoice_status AS [invoice_status_id],  ' + char(10)
			 + '		dbo.FNADateFormat(si.as_of_date) [as_of_date],  ' + char(10)


			 + '		12345 [incoming_invoice_amount], '  + char(10)
			 + '		678 [variance], '  + char(10)


			  + '		dbo.FNADateFormat(si.create_ts) [create_date], ' + char(10) 
			 + '		si.create_user [create_user], ' + char(10) 
			 + '		dbo.FNADateFormat(si.update_ts) [update_date], ' + char(10) 
			 + '		si.update_user [update_user], ' + char(10) 


			 + '		si.netting_invoice_id [netting_invoice_id], ' + char(10) 
			 + '		si.invoice_file_name [invoice_file_name], ' + char(10) 
			 + '		COALESCE(crt.document_type,crp_invoice.document_type,crp_remittance.document_type) [document_type], ' + char(10)
			 + '        CASE WHEN si.payment_status = ''p'' THEN ''Paid'' WHEN si.payment_status = ''u'' THEN ''Unpaid'' ELSE '''' END [payment_status], ' + char(10)
              + '        CASE WHEN si.is_locked = ''y'' THEN ''Locked'' ELSE ''Unlocked'' END [is_locked] ' + char(10) 

			 + ' INTO #temp_all_invoice FROM stmt_invoice si ' + char(10)

			  + 'CROSS APPLY (SELECT SUM([Value]) [value], sid.stmt_invoice_id FROM stmt_invoice_detail sid WHERE si.stmt_invoice_id = sid.stmt_invoice_id GROUP BY sid.stmt_invoice_id) sid ' + char(10)

			 + 'INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = si.counterparty_id  ' + char(10)
			 + 'INNER JOIN contract_group cg ON  cg.contract_id = si.contract_id  ' + CHAR(10)

			 + 'OUTER APPLY (
					SELECT MAX(cg.currency) netting_currency FROM stmt_netting_group ng
					INNER JOIN stmt_netting_group_detail ngd ON ng.netting_group_id = ngd.netting_group_id
					INNER JOIN contract_group cg ON cg.contract_id = ngd.contract_detail_id
					WHERE si.contract_id = ng.netting_contract_id
				) nett ' + char(10)
			 
			 + 'LEFT JOIN source_currency scu ON scu.source_currency_id = ISNULL(nett.netting_currency, cg.currency)  ' + char(10)
			 + 'LEFT JOIN static_data_value sdv_workflow ON sdv_workflow.value_id = si.invoice_status  ' + char(10)
			 + 'LEFT JOIN static_data_value sdv ON sdv.value_id = si.invoice_status  ' + char(10)
			 + 'LEFT JOIN Contract_report_template crp_invoice ON crp_invoice.template_id = cg.invoice_report_template' + char(10)
			 + 'LEFT JOIN Contract_report_template crp_remittance ON crp_remittance.template_id = cg.Contract_report_template' + char(10)
			 + 'LEFT JOIN Contract_report_template crp_netting ON crp_netting.template_id = cg.netting_template' + char(10)
			 + 'LEFT JOIN contract_report_template crt ON  crt.template_id = si.invoice_template_id  ' + char(10)
			 --+ 'LEFT JOIN netting_group ng ON  ng.netting_group_id = si.netting_invoice_id  ' + char(10)
			  + 'WHERE  1 = 1 ' + char(10)
			 + ' AND sid.stmt_invoice_id = si.stmt_invoice_id '

			 IF @delivery_date_from IS NOT NULL AND @delivery_date_from != ''
				SET @sql += ' AND CONVERT(VARCHAR(10), si.prod_date_from, 120) >= ''' + CONVERT(VARCHAR(10), @delivery_date_from, 120) + ''''  + char(10)
	
			IF @delivery_date_to IS NOT NULL AND @delivery_date_to != ''
				SET @sql += ' AND CONVERT(VARCHAR(10), ISNULL(si.prod_date_to,si.prod_date_from), 120) <= ''' + CONVERT(VARCHAR(10), @delivery_date_to, 120) + ''''  + char(10)

			IF @settlement_date_from IS NOT NULL AND @settlement_date_from != ''
				SET @sql += ' AND CONVERT(VARCHAR(10), si.as_of_date, 120) >= ''' + CONVERT(VARCHAR(10), @settlement_date_from, 120) + ''''  + char(10)
	
			IF @settlement_date_to IS NOT NULL AND @settlement_date_to != ''
				SET @sql += ' AND CONVERT(VARCHAR(10), si.as_of_date, 120) <= ''' + CONVERT(VARCHAR(10), @settlement_date_to, 120) + ''''  + char(10)

			IF @payment_date_from IS NOT NULL AND @payment_date_from != ''
				SET @sql += ' AND ISNULL(si.payment_date, dbo.FNAInvoiceDueDate(si.prod_date_from, cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days)) >= ''' + CONVERT(VARCHAR(10), @payment_date_from, 120) + ''''  + char(10)
	
			IF @payment_date_to IS NOT NULL AND @payment_date_to != ''
				SET @sql += ' AND ISNULL(si.payment_date, dbo.FNAInvoiceDueDate(si.prod_date_from, cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days)) <= ''' + CONVERT(VARCHAR(10), @payment_date_to, 120) + ''''  + char(10)

			IF @counterparty_type IS NOT NULL AND @counterparty_type != ''
				SET @sql +=  ' AND sc.int_ext_flag = ''' + @counterparty_type + ''''  + char(10)

			IF @counterparty_id IS NOT NULL AND @counterparty_id != ''
				SET @sql += ' AND si.counterparty_id IN (' + @counterparty_id + ')'  + char(10)

			IF @contract_id IS NOT NULL AND @contract_id != ''
				SET @sql += ' AND si.contract_id IN (' + @contract_id + ')' + char(10)

			--IF @invoice_type IS NOT NULL AND @invoice_type != ''
			--	SET @sql +=  ' AND si.invoice_type = ''' + @invoice_type + '''' + char(10)

			IF @invoice_id IS NOT NULL AND @invoice_id != ''  
				SET @sql += ' AND CAST(si.stmt_invoice_id AS VARCHAR) = ''' + CAST(@invoice_id AS VARCHAR(100))+'''' + char(10)
            
            IF @invoice_number IS NOT NULL AND @invoice_number != ''  
				SET @sql += ' AND CAST(si.invoice_number AS VARCHAR) = ''' + CAST(@invoice_number AS VARCHAR(100))+'''' + char(10)

			IF @commodity_id IS NOT NULL AND @commodity_id != ''
				SET @sql += ' AND cg.commodity = ''' + CAST(@commodity_id AS VARCHAR(20)) + '''' + char(10)

			IF @invoice_status IS NOT NULL AND @invoice_status != ''
				SET @sql += ' AND si.invoice_status = ' + CAST(@invoice_status AS VARCHAR(20)) + char(10) 

			IF @acc_status IS NOT NULL AND @acc_status != ''
				SET @sql += ' AND si.is_finalized = ''' + CAST(@acc_status AS VARCHAR(20)) + '''' + char(10)
            
           IF @loc_status IS NOT NULL AND @loc_status != ''
				SET @sql += ' AND ISNULL(si.is_locked,''n'') = ''' + CAST(@loc_status AS VARCHAR(20)) + '''' + char(10)
			
			IF @is_voided IS NOT NULL AND @is_voided != ''
				SET @sql += ' AND si.is_voided = ''' + CAST(@is_voided AS VARCHAR(20)) + '''' + char(10)

            IF @pay_status IS NOT NULL AND @pay_status != ''
				SET @sql += ' AND ISNULL(si.payment_status,''u'') = ''' + CAST(@pay_status AS VARCHAR(20)) + '''' + char(10)

			IF NULLIF(@accounting_month, '') IS NOT NULL
				SET @sql += 'AND CAST(MONTH(si.as_of_date) AS VARCHAR(10))= ' + CAST(MONTH(@accounting_month) AS VARCHAR(10))
			
			IF ISNULL(@show_backing_sheets,'n') = 'n'
				SET @sql += ' AND ISNULL(si.is_backing_sheet,''n'') = ''n''' 


			SET @sql += ' ORDER BY sc.source_counterparty_id, cg.contract_id, dbo.FNADateFormat(si.as_of_date), dbo.FNADateFormat(si.prod_date_from)'

			SET @sql += 'SELECT counterparty,
								[contract],
								[invoice_number],
								[invoice_id],
								counterparty_id,
								contract_id,
								CASE WHEN a.invoice_type = ''Invoice'' THEN [inv_template]
									 WHEN a.invoice_type = ''Remittance'' THEN [rem_template]
									 WHEN a.invoice_type = ''Netting'' THEN [net_template]
								END [template_name],
								date_from,
								date_to,
								invoice_date,
								amount,
								currency,
								acc_status,
								workflow_status,
								void_status,
								invoice_type,
								payment_date,
								stmt_invoice_id,
								finalized_date,
								invoice_note,
								invoice_status_id,
								as_of_date,
								incoming_invoice_amount,
								variance,
								create_date,
								create_user,
								update_date,
								update_user,
								netting_invoice_id,
								invoice_file_name,
								document_type,
								payment_status,
								is_locked FROM (
							SELECT * FROM #temp_all_invoice tmp
							UNION ALL
							SELECT	tmp.counterparty
									,tmp.[contract]
									,tmp.invoice_number [invoice_number]
									,nett.stmt_invoice_id [invoice_id]
									,tmp.counterparty_id
									,tmp.contract_id
									,tmp.[inv_template]
									,tmp.[rem_template]
									,tmp.[net_template]
									,tmp.date_from
									,tmp.date_to
									,tmp.invoice_date
									,nett.amount
									,tmp.currency
									,tmp.acc_status
									,tmp.workflow_status
									,tmp.void_status
									,nett.invoice_type
									,tmp.payment_date
									,tmp.stmt_invoice_id
									,tmp.finalized_date
									,tmp.invoice_note
									,tmp.invoice_status_id
									,tmp.as_of_date
									,tmp.incoming_invoice_amount
									,tmp.variance
									,tmp.create_date
									,tmp.create_user
									,tmp.update_date
									,tmp.update_user
									,tmp.netting_invoice_id
									,tmp.invoice_file_name
									,tmp.document_type
									,tmp.payment_status
									,tmp.is_locked
							FROM #temp_all_invoice tmp
							INNER JOIN (
								SELECT	CAST(MAX(tmp.stmt_invoice_id) AS INT) * -1 [stmt_invoice_id],
										SUM(CAST(amount AS NUMERIC(32,20))) amount,
										''Netting'' [invoice_type]
								FROM #temp_all_invoice tmp
								INNER JOIN contract_group cg ON cg.contract_id = tmp.contract_id
								INNER JOIN counterparty_contract_address cca ON cca.counterparty_id = tmp.counterparty_id AND cca.contract_id = cg.contract_id
                                INNER JOIN stmt_invoice si ON si.stmt_invoice_id = tmp.stmt_invoice_id
								WHERE COALESCE(cca.netting_statement,cg.netting_statement,''n'') = ''y''
								AND ISNULL(si.is_voided,''n'') <> ''v''
                                HAVING COUNT(tmp.stmt_invoice_id) > 1
							) nett ON nett.stmt_invoice_id = tmp.stmt_invoice_id * -1
						) a WHERE 1 = 1
						'    
			IF @invoice_type IS NOT NULL AND @invoice_type != ''
				SET @sql +=  ' AND CASE WHEN a.invoice_type = ''Invoice'' THEN ''i''
										WHEN a.invoice_type = ''Remittance'' THEN ''r''	
										WHEN a.invoice_type = ''Netting'' THEN ''n'' 
								END = ''' + @invoice_type + '''' + char(10)
			EXEC(@sql)

END

ELSE IF @flag = 'u'
BEGIN 
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
	IF OBJECT_ID('tempdb..#temp_invoice_for_update') IS NOT NULL
		DROP TABLE #temp_invoice_for_update
		 
	SELECT  stmt_invoice_id [stmt_invoice_id],
			invoice_status [invoice_status],
			acc_status [acc_status],
			invoice_note [invoice_note], 
			NULLIF(payment_date, '') [payment_date],
			NULLIF(invoice_date, '') [invoice_date],
			is_voided [is_voided]
	INTO #temp_invoice_for_update
	FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
	WITH (
		stmt_invoice_id INT,
		invoice_status INT,
		acc_status CHAR(1),
		invoice_note VARCHAR(100), 
		payment_date DATE,
		invoice_date DATE,
		is_voided VARCHAR(10)
	)

	UPDATE si
		SET invoice_status = temp.invoice_status, 
	       invoice_note = temp.invoice_note,
		   is_finalized = temp.acc_status, 
	       is_voided = temp.is_voided,
	       payment_date = temp.payment_date,
		   invoice_date = temp.invoice_date
		FROM stmt_invoice si
		INNER JOIN #temp_invoice_for_update temp ON temp.stmt_invoice_id = si.stmt_invoice_id
	

	DECLARE @inv_process_id VARCHAR(100) = dbo.FNAGetNewID()
	DECLARE @inv_alert_process_table VARCHAR(200) = 'adiha_process.dbo.alert_stmt_invoice_' + @inv_process_id + '_ai'

	EXEC('CREATE TABLE ' + @inv_alert_process_table + ' (stmt_invoice_id INT)')
				
	SET @sql = 'INSERT INTO ' + @inv_alert_process_table + '(stmt_invoice_id) 
				SELECT stmt_invoice_id FROM #temp_invoice_for_update'

	EXEC(@sql)		
	EXEC spa_register_event 20630, 20589, @inv_alert_process_table, 1, @inv_process_id
			
	IF @@Error <> 0
	    EXEC spa_ErrorHandler @@Error,
	         'stmt_invoice',
	         'spa_stmt_invoice',
	         'DB Error',
	         'Failed to update Invoice.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'stmt_invoice',
	         'spa_stmt_invoice',
	         'Success',
	         'Changes have been saved successfully.',
	         ''
END

ELSE IF @flag = 'a' --load Settlement Invoice Details
BEGIN 
	SELECT	DISTINCT sid.stmt_invoice_detail_id,
			sid.invoice_line_item_id [charge_type_id],
			sdv_charge_type.code [charge_type],
			dbo.FNARemoveTrailingZeroes(ROUND(sid.[Value], 2)) [amount],
			scu.currency_name [currency],
			dbo.FNARemoveTrailingZeroes(ROUND(sid.Volume, 2)) AS Volume,
			su.uom_id [uom],
			dbo.FNAdateformat(sid.prod_date_from) [delivery_month],						   
			CASE WHEN si.is_finalized = 'f' THEN 'Finalized' ELSE 'Not Finalized' END [acc_status],
			dbo.FNADateFormat(si.finalized_date) [Finalized_Date]
	FROM stmt_invoice si
	LEFT JOIN stmt_invoice_detail sid
		ON si.stmt_invoice_id = sid.stmt_invoice_id
	INNER JOIN contract_group cg 
		ON cg.contract_id = si.contract_id
	LEFT JOIN static_data_value sdv_charge_type 
		ON  sdv_charge_type.value_id = sid.invoice_line_item_id and sdv_charge_type.[type_id] = 10019
	LEFT JOIN source_currency scu 
		ON scu.source_currency_id = cg.currency	
	LEFT JOIN stmt_checkout sch
		ON sch.stmt_invoice_detail_id = sid.stmt_invoice_detail_id
	OUTER APPLY( SELECT itm.item [stmt_checkout_id] FROM dbo.SplitCommaSeperatedValues(sid.description1) itm) a 
	LEFT JOIN stmt_checkout sch2
		ON sch2.stmt_checkout_id =  a.[stmt_checkout_id]
	LEFT JOIN source_uom su 
		ON  su.source_uom_id = COALESCE(cg.volume_uom,sch.uom_id, sch2.uom_id)
	WHERE si.stmt_invoice_id = @invoice_id
END

ELSE IF @flag = 'c' --load Settlement Counterparty Invoice grid
BEGIN 
	 SELECT sdv_charge_type.code [charge_type],
			sid.invoice_line_item_id 
	 FROM stmt_invoice si
	 INNER JOIN stmt_invoice_detail sid
		ON sid.stmt_invoice_id = si.stmt_invoice_id
	 LEFT JOIN stmt_counterparty_invoice sci
		ON sci.stmt_invoice_id = si.stmt_invoice_id
	 LEFT JOIN static_data_value sdv_charge_type 
		ON sdv_charge_type.value_id = sid.invoice_line_item_id
			AND sdv_charge_type.type_id = 10019
	WHERE si.stmt_invoice_id = @invoice_id
END

ELSE IF @flag = 'b' --Settlement Counterparty Invoice save  
BEGIN

		BEGIN TRY
			EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

			SELECT * INTO #temp_invoice
			FROM   OPENXML(@idoc, '/Root/PSRecordset', 2)
					WITH (
						charge_type VARCHAR(100) '@charge_type',
						shadow_calc FLOAT '@shadow_calc',
						amount FLOAT '@amount',
						variance FLOAT '@variance',
						[prod_date_from] DATETIME '@prod_date_from',
						[prod_date_to] DATETIME '@prod_date_to',
						[currency_id] INT '@currency_id',
						[invoice_volume] FLOAT '@invoice_volume',
						[invoice_volume_uom_id] INT '@invoice_volume_uom_id',
						[description1] VARCHAR(500) '@description1',
						[invoice_line_item_id] INT '@invoice_line_item_id'
					)
		
		IF @invoice_date = ''
		BEGIN
			SET @invoice_date = NULL
		END

		IF @invoice_due_date = ''
		BEGIN
			SET @invoice_due_date = NULL
		END
		
		BEGIN TRAN

		IF NOT EXISTS (SELECT 1 FROM stmt_counterparty_invoice  WHERE stmt_invoice_id = @stmt_invoice_id)
		BEGIN
			INSERT INTO stmt_counterparty_invoice 
			(
				stmt_invoice_id,
				invoice_ref_no,
				invoice_date,
				invoice_due_date,
				description1,
				description2
			)
			VALUES
			(	
				@stmt_invoice_id,
				@invoice_ref_no,
				@invoice_date,
				@invoice_due_date,
				@description1,
				@description2
			)

			DECLARE @stmt_counterparty_invoice_id INT
			SET @stmt_counterparty_invoice_id = SCOPE_IDENTITY()

			INSERT INTO stmt_counterparty_invoice_detail
			(
				[stmt_counterparty_invoice_id],
				[invoice_amount],
				[invoice_line_item_id],
				[description1],
				[prod_date_from],
				[prod_date_to],
				[currency_id],
				[invoice_volume],
				[invoice_volume_uom_id]
			)
			SELECT	@stmt_counterparty_invoice_id, 
					NULLIF(ti.amount,0), 
					ti.invoice_line_item_id,
					ti.[description1],
					NULLIF(ti.[prod_date_from],''),
					NULLIF(ti.[prod_date_to],''),
					NULLIF(ti.[currency_id],0),
					NULLIF(ti.[invoice_volume],0),
					NULLIF(ti.[invoice_volume_uom_id],0)
			FROM #temp_invoice ti

			EXEC spa_ErrorHandler 0
				, 'invoice_detail'
				, 'spa_stmt_invoice'
				, 'Success' 
				, 'Successfully saved data.'
				, ''
		END 
		ELSE 
		BEGIN
			UPDATE stmt_counterparty_invoice 
			SET
				invoice_ref_no = @invoice_ref_no,
				invoice_date = @invoice_date,
				invoice_due_date = @invoice_due_date,
				description1 = @description1,
				description2 = @description2

			UPDATE scid
			SET 
				scid.invoice_amount= NULLIF(ti.amount,0),
				scid.[description1] = ti.[description1],
				scid.[prod_date_from] = NULLIF(ti.[prod_date_from],''),
				scid.[prod_date_to] = NULLIF(ti.[prod_date_to],''),
				scid.[currency_id] = NULLIF(ti.[currency_id],0),
				scid.[invoice_volume] = NULLIF(ti.[invoice_volume],0),
				scid.[invoice_volume_uom_id] = NULLIF(ti.[invoice_volume_uom_id],0)
			FROM stmt_counterparty_invoice_detail scid
				INNER JOIN stmt_counterparty_invoice sci ON sci.stmt_counterparty_invoice_id = scid.stmt_counterparty_invoice_id 
				INNER JOIN #temp_invoice ti ON ti.invoice_line_item_id = scid.invoice_line_item_id
			WHERE sci.stmt_invoice_id = @stmt_invoice_id
		  
			EXEC spa_ErrorHandler 0
				, 'invoice_detail'
				, 'spa_stmt_invoice'
				, 'Success' 
				, 'Successfully updated data.'
				, ''
		END 

		COMMIT TRAN

		
	END TRY
	BEGIN CATCH	
		DECLARE @DESC VARCHAR(500)
		DECLARE @err_no INT 
			IF @@TRANCOUNT > 0
			   ROLLBACK

			SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

			SELECT @err_no = ERROR_NUMBER()

			EXEC spa_ErrorHandler @err_no
			   , 'invoice_detail'
			   , 'spa_stmt_invoice'
			   , 'Error'
			   , @DESC
			   , ''
	END CATCH	

END

ELSE IF @flag = 'f'
BEGIN
		DECLARE @spa VARCHAR(1000)
		SET @batch_process_id = dbo.FNAGetNewID()
		SET @job_name = 'stmt_invoice_finalize_job_' + @batch_process_id

		DECLARE @model_name VARCHAR(100),@url VARCHAR(5000)
		SET @spa = 'spa_stmt_invoice  @flag= ''z'', @invoice_id = ''' + @invoice_id + ''', @process_id = ''' + @batch_process_id + ''''

		SET @model_name = 'Invoice Process'
		SET @msg = 'Process to create invoice PDFs has been started.'

		EXEC spa_message_board 'i',@user_login_id,NULL,@model_name,@msg,'','','',@job_name,NULL,@batch_process_id
 
		EXEC spa_run_sp_as_job @job_name, @spa, @model_name, @user_login_id, 'TSQL'

		EXEC spa_ErrorHandler
			@error = 0,
			@msgType1 = 'STMT Invoice',
			@msgType2 = 'spa_stmt_invoice',
			@msgType3 = 'Success',
			@msg = 'Process to create invoice PDFs has been started. Check message board for details.',
			@recommendation = 'Check message board for details.',
			@logFlag = null	 
END

ELSE IF @flag = 'z' --Finalize Invoice  
BEGIN
	BEGIN TRY
		SELECT * INTO #invoice_collection FROM dbo.SplitCommaSeperatedValues(@invoice_id) id
		DECLARE @id INT, @status INT = 1, @url_name VARCHAR(5000), @total_time_for_pdf_process VARCHAR(200), @pdf_process_start_time  DATETIME 
		SET @pdf_process_start_time = GETDATE()

		/* To Finalize the Backing Sheet */
		INSERT INTO #invoice_collection
		SELECT DISTINCT si_b.stmt_invoice_id FROM stmt_invoice si
		INNER JOIN #invoice_collection tid ON tid.item = si.stmt_invoice_id
		INNER JOIN stmt_invoice_detail stid ON si.stmt_invoice_id = stid.stmt_invoice_id
		OUTER APPLY( SELECT itm.item [stmt_checkout_id] FROM dbo.SplitCommaSeperatedValues(stid.description1) itm) a 
		INNER JOIN stmt_invoice_detail stid_b ON stid_b.description1 = a.[stmt_checkout_id]
		INNER JOIN stmt_invoice si_b ON si_b.stmt_invoice_id = stid_b.stmt_invoice_id AND ISNULL(si_b.is_voided,'n') = ISNULL(si.is_voided,'n')
		WHERE ISNULL(si_b.is_backing_sheet,'n') = 'y'

		WHILE EXISTS(SELECT * FROM #invoice_collection) 
		BEGIN
			SELECT TOP(1) @id = item FROM #invoice_collection

			DECLARE @netting_id INT 
			SELECT @netting_id = 
				CASE 
					WHEN si.stmt_invoice_id > si1.stmt_invoice_id 
						THEN si.stmt_invoice_id 
					ELSE si1.stmt_invoice_id
				END * -1
			FROM stmt_invoice si
			INNER JOIN contract_group cg
				ON cg.contract_id = si.contract_id
			INNER JOIN counterparty_contract_address cca 
				ON cca.counterparty_id = si.counterparty_id 
				AND cca.contract_id = cg.contract_id
			OUTER APPLY (
				SELECT stmt_invoice_id FROM stmt_invoice si1
				WHERE si1.counterparty_id = si.counterparty_id
				AND si1.contract_id = si.contract_id
				AND si1.prod_date_from = si.prod_date_from
				AND si1.prod_date_to = si.prod_date_to
				AND si1.invoice_type <> si.invoice_type
			) si1
			WHERE COALESCE(cca.netting_statement,cg.netting_statement,'n') = 'y'
			AND ISNULL(si.is_voided,'n') <> 'v'
			AND si.stmt_invoice_id = @id
			AND si1.stmt_invoice_id IS NOT NULL

			IF @netting_id IS NOT NULL
			BEGIN
				EXEC spa_generate_document @document_category = 10000283, @document_sub_category = 42047, @filter_object_id = @id, @temp_generate = 0, @get_generated = 1, @show_output = 0

				IF NOT EXISTS (SELECT 1 FROM application_notes an WHERE ISNULL(parent_object_id, notes_object_id) = @id AND internal_type_value_id = 10000283 AND category_value_id = 42047)
				BEGIN
					SET @status = 0;
				END
			END

			IF @status <> 0
			BEGIN
				EXEC spa_generate_document @document_category = 10000283, @document_sub_category = 42031, @filter_object_id = @id, @temp_generate = 0, @get_generated = 1, @show_output = 0

				IF EXISTS (SELECT 1 FROM application_notes an WHERE ISNULL(parent_object_id, notes_object_id) = @id AND internal_type_value_id = 10000283)
				BEGIN
					UPDATE stmt_invoice
						SET is_finalized = 'f',
							finalized_date = GETDATE()
					WHERE stmt_invoice_id = @id

					INSERT INTO process_settlement_invoice_log (process_id, counterparty_id, prod_date, code, module, [description], invoice_id)
					SELECT @process_id, counterparty_id, getdate(), 'Success', 'Settlement invoice', 'Successfully finalize invoice : ' + CAST(stmt_invoice_id AS VARCHAR), stmt_invoice_id FROM stmt_invoice WHERE stmt_invoice_id = @id
				END
			END
			ELSE 
			BEGIN
				SET @status = 0;
				INSERT INTO process_settlement_invoice_log (process_id, counterparty_id, prod_date, code, module, [description], invoice_id)
				SELECT @process_id, counterparty_id, getdate(), 'Error', 'Settlement invoice', 'Failed to finalize invoice : ' + CAST(stmt_invoice_id AS VARCHAR), stmt_invoice_id FROM stmt_invoice WHERE stmt_invoice_id = @id
			END
			DELETE FROM #invoice_collection WHERE (item = @id);
		END

		SET @url_name = './dev/spa_html.php?__user_name__=''' + @user_login_id + '''&spa=exec spa_get_settlement_invoice_log ''' + @process_id + ''''
		SET @msg = '<a target="_blank" href="' + @url_name + '">' + 'Process to create invoice PDFs has been completed.</a>'
			 
		IF EXISTS (SELECT 1 FROM process_settlement_invoice_log psil WHERE psil.process_id = @process_id AND psil.code <> 'Success')
			SET @msg = '<a target="_blank" href="' + @url_name + '">' + 'Process to create invoice PDFs has been completed <font color="red"><b>(with errors)</b></font>.</a>'
			
		SET @total_time_for_pdf_process = dbo.FNAFindDateDifference(@pdf_process_start_time)
		SET @msg += '(Elapsed Time: ' + @total_time_for_pdf_process + ')'
		EXEC spa_message_board 'u',@user_login_id,NULL,'Settlement Invoice',@msg,'','','',NULL ,NULL,@process_id

		IF @status = '1'
		BEGIN			
			EXEC spa_ErrorHandler 0,
				'stmt_invoice',
				'spa_stmt_invoice',
				'Success',
				'Settlement finalized sucessfully',
				''		
		END
		ELSE 
		BEGIN
			EXEC spa_ErrorHandler -1,
				'stmt_invoice',
				'spa_stmt_invoice',
				'Error',
				'Failed to finalize settlement.',
				''	   
		END

	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
		IF @@Error <> 0
			EXEC spa_ErrorHandler @@Error,
				 'stmt_invoice',
				 'spa_stmt_invoice',
				 'Error',
				 'Failed to finalize settlement.',
				 ''	   
	END CATCH

END  

ELSE IF @flag = 'n' --Unfinalize Invoice  
BEGIN
	BEGIN TRY
			IF OBJECT_ID('tempdb..#invoice_unfinalize') IS NOT NULL
				DROP TABLE #invoice_unfinalize

			SELECT * INTO #invoice_unfinalize FROM dbo.SplitCommaSeperatedValues(@invoice_id) id

			/* Lock and Unlock backing sheet */
			INSERT INTO #invoice_unfinalize
			SELECT DISTINCT si_b.stmt_invoice_id FROM stmt_invoice si
			INNER JOIN #invoice_unfinalize tid ON tid.item = si.stmt_invoice_id
			INNER JOIN stmt_invoice_detail stid ON si.stmt_invoice_id = stid.stmt_invoice_id
			OUTER APPLY( SELECT itm.item [stmt_checkout_id] FROM dbo.SplitCommaSeperatedValues(stid.description1) itm) a 
			INNER JOIN stmt_invoice_detail stid_b ON stid_b.description1 = a.[stmt_checkout_id]
			INNER JOIN stmt_invoice si_b ON si_b.stmt_invoice_id = stid_b.stmt_invoice_id AND ISNULL(si_b.is_voided,'n') = ISNULL(si.is_voided,'n')
			WHERE ISNULL(si_b.is_backing_sheet,'n') = 'y'

			SET @sql = '
				UPDATE si
					SET is_finalized = ''n'',
						finalized_date = NULL
				FROM stmt_invoice si
				INNER JOIN #invoice_unfinalize tmp ON si.stmt_invoice_id = tmp.item'
			EXEC(@sql)
			
			SET @sql = '
				UPDATE si
					SET is_finalized = ''n'',
						finalized_date = NULL
				FROM stmt_invoice si
				INNER JOIN #invoice_unfinalize tmp ON si.stmt_invoice_id = tmp.item

				DELETE an FROM application_notes an 
				INNER JOIN #invoice_unfinalize tmp ON ISNULL(an.parent_object_id, an.notes_object_id) = tmp.item AND an.internal_type_value_id = 10000283
			'
			exec(@sql);

			EXEC spa_ErrorHandler 0,
					'stmt_invoice',
					'spa_stmt_invoice',
					'Success',
					'Settlement unfinalized sucessfully',
					''		
	END TRY
	BEGIN CATCH 
		IF @@Error <> 0
			EXEC spa_ErrorHandler @@Error,
				 'stmt_invoice',
				 'spa_stmt_invoice',
				 'Error',
				 'Failed to unfinalize settlement.',
				 ''	   
	END CATCH

END  

ELSE IF @flag = 'w' --update workflow status
BEGIN
	BEGIN TRY
		BEGIN TRAN
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
		IF OBJECT_ID('tempdb..#temp_invoices_for_update') IS NOT NULL
			DROP TABLE #temp_invoices_for_update

		CREATE TABLE #temp_invoices_for_update (stmt_invoice_id INT)
		
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		INSERT INTO #temp_invoices_for_update(stmt_invoice_id)
		SELECT stmt_invoice_id [stmt_invoice_id] 
		FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
		WITH (
			stmt_invoice_id VARCHAR(10) 
		)
			
		
	
			--EXEC('CREATE TABLE ' + @alert_process_table + ' (
			--		invoice_id			INT NOT NULL,
			--		counterparty_id		INT,
			--		contract_id			INT,
			--		as_of_date			DATETIME,
			--		invoice_date		DATETIME,
			--		flag				CHAR(1),
			--		errorcode			VARCHAR(100),
			--		message				VARCHAR(4000)
			--		)')
				
			--SET @sql = 'INSERT INTO ' + @alert_process_table + '(invoice_id, counterparty_id, contract_id, as_of_date, invoice_date, flag, errorcode, message) 
			--			SELECT si.stmt_invoice_id, si.counterparty_id, si.contract_id, si.as_of_date, si.payment_date, ''e'', '''', ''''
			--			FROM stmt_invoice si 
			--			INNER JOIN #temp_invoices_for_update tmp ON tmp.stmt_invoice_id = si.stmt_invoice_id'
		
			--EXEC(@sql)
		
			---- Trigger Workflow for Event "Invoice - Pre Update" Start
			--EXEC spa_register_event 20605, 20525, @alert_process_table, 0, @process_id
		
		--	SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @alert_process_table + ' WHERE errorcode = ''error'')
		--				BEGIN
		--					INSERT INTO #prevent_alert(errorcode,message)
		--					SELECT errorcode,message FROM ' +@alert_process_table + '
		--				END'
		--	EXEC(@sql)

		--	IF EXISTS(SELECT 1 FROM #prevent_alert WHERE errorcode = 'error')
		--	BEGIN
		--		SELECT @message = [message] FROM #prevent_alert WHERE errorcode = 'error'

		--		COMMIT
			
		--		EXEC spa_ErrorHandler -1,
		--			 'Settlement Invoice',
		--			 'spa_stmt_invoice',
		--			 'DB Error',
		--			 @message,
		--			 ''
			
		--		RETURN;
		--	END
		--	-- Trigger Workflow for Event "Invoice - Pre Update" End
		--END	

		UPDATE  si
		SET si.invoice_status = @invoice_status
		FROM stmt_invoice si
		INNER JOIN #temp_invoices_for_update tmp ON tmp.stmt_invoice_id = si.stmt_invoice_id		 
		
		SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())
		
		--IF @invoice_status = 20710
		--BEGIN
		SET @alert_process_table = 'adiha_process.dbo.alert_invoice_' + @process_id + '_output'


		EXEC('CREATE TABLE ' + @alert_process_table + ' (stmt_invoice_id INT)')
				
		SET @sql = 'INSERT INTO ' + @alert_process_table + '(stmt_invoice_id) 
					SELECT stmt_invoice_id FROM #temp_invoices_for_update'

		EXEC(@sql)		
		EXEC spa_register_event 20630, 20589, @alert_process_table, 1, @process_id

		COMMIT 
		
		---- alert call
			
		--SET @alert_process_table = 'adiha_process.dbo.alert_invoice_' + @process_id + '_ai'

		----PRINT('CREATE TABLE ' + @alert_process_table + '(stmt_invoice_id INT NOT NULL, invoice_number INT NOT NULL, invoice_status INT NOT NULL)')
		--EXEC('CREATE TABLE ' + @alert_process_table + ' (
		--		invoice_id				INT NOT NULL,
		--		invoice_number			VARCHAR(20) NOT NULL,
		--		invoice_status			INT,
		--		counterparty			VARCHAR(100),
		--		contract				VARCHAR(100),
		--		Prod_month				VARCHAR(100),
		--		hyperlink1				VARCHAR(5000),
		--		hyperlink2				VARCHAR(5000),
		--		hyperlink3				VARCHAR(5000),
		--		hyperlink4				VARCHAR(5000),
		--		hyperlink5				VARCHAR(5000)
		--		)')
				
		--SET @sql = 'INSERT INTO ' + @alert_process_table + '(invoice_id, invoice_number, invoice_status,counterparty,contract,Prod_month) 
		--			SELECT  si.stmt_invoice_id,
		--					si.invoice_number,
		--					si.invoice_status,
		--					sc.counterparty_name counterparty,
		--					cg.contract_name contract,
		--					dbo.FNADATEFORMAT(si.prod_date_from) Prod_month
		--			FROM stmt_invoice si 
		--			INNER JOIN #temp_invoices_for_update tmp ON tmp.stmt_invoice_id = si.stmt_invoice_id 
		--			LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = si.counterparty_id
		--			LEFT JOIN contract_group cg ON cg.contract_id = si.contract_id'


		----PRINT(@sql)
		--EXEC(@sql)		
		--EXEC spa_register_event 20605, 20512, @alert_process_table, 1, @process_id
		
		IF OBJECT_ID('tempdb..#temp_invoices_for_update') IS NOT NULL
			DROP TABLE #temp_invoices_for_update
		
		
			
		EXEC spa_ErrorHandler 0,
				'stmt_invoice',
				'spa_stmt_invoice',
				'Success',
				'Invoice status has been updated successfully.',
				''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Settlement Invoice',
             'spa_stmt_invoice',
             'DB Error',
             'Failed to update invoice status.',
             ''
	END CATCH
END

ELSE IF @flag = 'd' -- DELETE INVOICE
BEGIN
     BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
        IF OBJECT_ID('tempdb..#temp_invoice_delete') IS NOT NULL
		    DROP TABLE #temp_invoice_delete

        IF OBJECT_ID('tempdb..#temp_parent_detail') IS NOT NULL
		    DROP TABLE #temp_parent_detail

		SELECT	invoice_id
		INTO #temp_invoice_delete
		FROM OPENXML(@idoc, '/Root/GridDelete', 1)
		WITH (
			invoice_id INT
		)
        SELECT
            si.original_id_for_void
        INTO #temp_parent_detail
        FROM stmt_invoice si
        INNER JOIN #temp_invoice_delete tid ON tid.invoice_id = si.stmt_invoice_id

        BEGIN TRAN
			UPDATE  si
			SET si.is_voided ='n'
			FROM stmt_invoice si
			INNER JOIN #temp_parent_detail tid ON tid.original_id_for_void = si.stmt_invoice_id

			DELETE si_b
			FROM stmt_invoice si
			INNER JOIN #temp_invoice_delete tid ON tid.invoice_id = si.stmt_invoice_id
			INNER JOIN stmt_invoice_detail stid ON si.stmt_invoice_id = stid.stmt_invoice_id
			OUTER APPLY( SELECT itm.item [stmt_checkout_id] FROM dbo.SplitCommaSeperatedValues(stid.description1) itm) a 
			OUTER APPLY (
				SELECT DISTINCT stid_b.stmt_invoice_id
				FROM stmt_invoice_detail stid_b
				CROSS APPLY dbo.SplitCommaSeperatedValues(stid_b.description1) de
				WHERE de.item = a.stmt_checkout_id AND stid_b.stmt_invoice_id <> tid.invoice_id
			) inv
			INNER JOIN stmt_invoice si_b ON si_b.stmt_invoice_id = inv.stmt_invoice_id

			DELETE si
			FROM stmt_invoice si
			INNER JOIN #temp_invoice_delete tid ON tid.invoice_id = si.stmt_invoice_id

		COMMIT

        	EXEC spa_ErrorHandler 0,
			'stmt_invoice',
			'spa_stmt_invoice',
			'Success',
			'Invoice delete successfully.',
			''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
            'stmt_invoice',
			'spa_stmt_invoice',
			'Error',
			'Failed to delete.',
			''
	END CATCH 
END

ELSE IF @flag='v'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
	IF OBJECT_ID('tempdb..#temp_void') IS NOT NULL
		DROP TABLE #temp_void

	-- Execute a SELECT statement that uses the OPENXML rowset provider.
	SELECT invoice_id [invoice_id],
			as_of_date [as_of_date]
	INTO #temp_void
	FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
	WITH (
		invoice_id VARCHAR(10),
		as_of_date DATETIME
	)

	BEGIN TRY
	BEGIN TRAN

		/* Void the backing sheet */
		INSERT INTO #temp_void
		SELECT DISTINCT si_b.stmt_invoice_id, tid.as_of_date FROM stmt_invoice si
		INNER JOIN #temp_void tid ON tid.invoice_id = si.stmt_invoice_id
		INNER JOIN stmt_invoice_detail stid ON si.stmt_invoice_id = stid.stmt_invoice_id
		OUTER APPLY( SELECT itm.item [stmt_checkout_id] FROM dbo.SplitCommaSeperatedValues(stid.description1) itm) a 
		INNER JOIN stmt_invoice_detail stid_b ON stid_b.description1 = a.[stmt_checkout_id]
		INNER JOIN stmt_invoice si_b ON si_b.stmt_invoice_id = stid_b.stmt_invoice_id AND ISNULL(si_b.is_voided,'n') = ISNULL(si.is_voided,'n')
		WHERE ISNULL(si_b.is_backing_sheet,'n') = 'y'

		IF OBJECT_ID('tempdb..#temp_new_inv') IS NOT NULL
			DROP TABLE #temp_new_inv
		CREATE TABLE #temp_new_inv(stmt_invoice_id INT, original_id_for_void INT)

		INSERT INTO stmt_invoice (as_of_date, counterparty_id, contract_id, prod_date_from, prod_date_to, invoice_number, is_finalized, finalized_date, is_locked, invoice_status, invoice_type, invoice_note, invoice_template_id, payment_date, netting_invoice_id, invoice_file_name, netting_file_name, is_voided, description1, description2, description3, description4, description5, original_id_for_void)
		OUTPUT INSERTED.stmt_invoice_id, INSERTED.original_id_for_void INTO #temp_new_inv(stmt_invoice_id, original_id_for_void)
		SELECT tv.as_of_date, counterparty_id, contract_id, prod_date_from, prod_date_to, invoice_number, is_finalized, finalized_date, is_locked, invoice_status, CASE WHEN invoice_type = 'i' THEN 'r' ELSE 'i' END, invoice_note, invoice_template_id, payment_date, netting_invoice_id, invoice_file_name, netting_file_name, NULL, description1, description2, description3, description4, description5, si.stmt_invoice_id 
		FROM stmt_invoice si INNER JOIN #temp_void tv ON si.stmt_invoice_id = tv.invoice_id

		UPDATE si 
		SET is_voided = 'v'
		FROM stmt_invoice si
		INNER JOIN #temp_void tmp ON si.stmt_invoice_id = tmp.invoice_id

		--DECLARE @new_id INT
		--SET @new_id = SCOPE_IDENTITY()
	
		INSERT INTO stmt_invoice_detail (stmt_invoice_id, invoice_line_item_id, prod_date_from, prod_date_to, [value], volume, show_volume_in_invoice, show_charge_in_invoice, description1, description2, description3, description4, description5)
		SELECT tmp.stmt_invoice_id, invoice_line_item_id, prod_date_from, prod_date_to, -1 * [value], volume, show_volume_in_invoice, show_charge_in_invoice, description1, description2, description3, description4, description5 
		FROM stmt_invoice_detail sid INNER JOIN #temp_void tv ON sid.stmt_invoice_id = tv.invoice_id
		INNER JOIN #temp_new_inv tmp ON tmp.original_id_for_void =  tv.invoice_id

		--UPDATE stmt_invoice 
		--	SET invoice_number = @new_id
		--WHERE stmt_invoice_id = @new_id

		UPDATE sti 
		SET sti.invoice_number = sti.stmt_invoice_id,
			sti.is_finalized = 'n',
			sti.finalized_date =  NULL
		FROM stmt_invoice sti
		INNER JOIN #temp_new_inv tmp ON sti.stmt_invoice_id = tmp.stmt_invoice_id

		--EXEC spa_generate_document @document_category = 10000283, @document_sub_category = '', @filter_object_id = @new_id, @temp_generate = 0, @get_generated = 1, @show_output = 0

		DECLARE @vd_process_id VARCHAR(1000), @vd_alert_process_table VARCHAR(1000)
		SET @vd_process_id = dbo.FNAGetNewID()
		SET @vd_alert_process_table = 'adiha_process.dbo.alert_stmt_invoice_void_' + @vd_process_id + '_ai'

		EXEC('CREATE TABLE ' + @vd_alert_process_table + ' (stmt_invoice_id INT)')
				
		SET @sql = 'INSERT INTO ' + @vd_alert_process_table + '(stmt_invoice_id) 
					SELECT tmp.invoice_id FROM #temp_void tmp
					UNION ALL
					SELECT tmp1.stmt_invoice_id FROM #temp_new_inv tmp1'

		EXEC(@sql)		
		EXEC spa_register_event 20630, 20588, @vd_alert_process_table, 1, @vd_process_id

		COMMIT TRAN

		EXEC spa_ErrorHandler 0,
			'stmt_invoice',
			'spa_stmt_invoice',
			'Success',
			'Invoice void successfully.',
			''

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			   ROLLBACK
		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, "calc invoice Volume", 
			spa_stmt_invoice, "DB Error", 
			"Failed Voiding Charge Type.", ''

	END CATCH
END

ELSE IF @flag='i' OR  @flag='p'-- Generation of invoice.
BEGIN
	IF @flag = 'i'
	BEGIN
		SET @sql = '
		SELECT 
			MAX(sdv_charge_type.code) [Line Item],
			CAST(CAST(MAX(sid.prod_date_from) AS VARCHAR(20)) AS DATE) [Production Month],
			CAST(dbo.FNARemoveTrailingZeroes(ROUND(SUM(sco.settlement_volume), 2)) AS FLOAT) AS Volume, 
			MAX(su.uom_id) [UOM],
			AVG(sco.settlement_price) AS Rate, 
			NULL [Indexcurvevalue],
			CAST(dbo.FNARemoveTrailingZeroes(ROUND(SUM(sco.settlement_amount),2)) AS FLOAT) AS [Total],
			--2 Total,
			NULL AS [gl_account_number],
			--CASE WHEN [Order] = -1 THEN 0 
			--		WHEN [order]=0 THEN -1 ELSE [order] END 
			--AS [Order],
			NULL [Order],
			NULL [GroupBy] ,
			sdh.deal_id [DealID],
			NULL [Deal_info],
			NULL [deal_date],
			NULL [trade_type],
			NULL [Indexname],
			NULL [Indexcurvename],
			NULL [fixed_price],
			NULL [settled_price],
			MAX(scu.currency_name) [currency],
			NULL [location],
			NULL [country],
			MAX(sc.counterparty_name) [counterparty],
			MAX(sco.term_start) [entire_term_start],
			MAX(sco.term_end) [entire_term_end],
			MAX(sid.description1) [description1],
			NULL [contract_value],
			NULL [market_value],
			--CASE WHEN buy_sell =''b'' THEN ''Buy'' ELSE ''Sell'' END buy_sell,
			NULL [buy_sell],
			CAST(MAX(sid.prod_date_to) AS VARCHAR(20)) [prod_date_to],
			NULL tax_summed,
			NULL [header_buy_sell_flag],
			NULL [alias],
			CASE WHEN MAX(sp.calendar_from_month) = 1 AND MAX(sp.calendar_to_month) = 12
				THEN ''C''
			ELSE ''R''
			END [vintage_type],
			MAX(sdv_v.code) vintage,
			MAX(sdv_p1.code) + '' '' + MAX(sdv_p2.code) [product]
		FROM stmt_invoice si
		INNER JOIN stmt_invoice_detail sid 
			ON sid.stmt_invoice_id = si.stmt_invoice_id
		LEFT JOIN  stmt_checkout sco 
			ON sid.stmt_invoice_detail_id = sco.stmt_invoice_detail_id 
		LEFT JOIN source_deal_detail sdd 
			ON sdd.source_deal_detail_id = sco.source_deal_detail_id
		LEFT JOIN source_deal_header sdh 
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		LEFT JOIN contract_group cg 
			ON cg.contract_id = si.contract_id
		LEFT JOIN static_data_value sdv_charge_type 
			ON  sdv_charge_type.value_id = sid.invoice_line_item_id and sdv_charge_type.[type_id] = 10019
		LEFT JOIN source_currency scu 
			ON scu.source_currency_id = cg.currency	
		OUTER APPLY (
			SELECT MAX(uom_id) uom_id FROM stmt_checkout 
			WHERE stmt_invoice_detail_id = sid.stmt_invoice_detail_id
		) sch
		LEFT JOIN source_uom su 
			ON  su.source_uom_id = sch.uom_id
		LEFT JOIN source_counterparty sc 
			ON sc.source_counterparty_id = si.counterparty_id
		LEFT JOIN state_properties sp 
			ON sp.state_value_id = sdh.state_value_id
		LEFT JOIN static_data_value sdv_v 
			ON sdv_v.value_id = sdd.vintage AND sdv_v.type_id = 10092 
		LEFT JOIN static_data_value sdv_p1 
			ON sdv_p1.value_id = sdh.state_value_id
		LEFT JOIN static_data_value sdv_p2 
			ON sdv_p2.value_id = sdh.tier_value_id
		WHERE si.stmt_invoice_id = ' + @invoice_id + ' AND sco.accrual_or_final = ''f'''
		IF @group_by IS NULL 
			SET @sql +=  ' GROUP BY sdv_charge_type.code, sdh.deal_id' -- By Default for standard invoice.
		ELSE IF @group_by = 'deal' 
			SET @sql +=  ' GROUP BY sdh.deal_id'

		EXEC(@sql);
	END
	ELSE  -- Generation of invoice group by product.
	BEGIN
		/* Getting max deal id if invoice is created from multiple deal as we cannot shown exact volume and amount for multiple product.*/
		SELECT MAX(sdh.source_deal_header_id) source_deal_header_id
			INTO #table_sdh
		FROM stmt_invoice si
		INNER JOIN stmt_invoice_detail sid
			ON si.stmt_invoice_id = sid.stmt_invoice_id
		INNER JOIN stmt_checkout sch
			ON sch.stmt_invoice_detail_id = sid.stmt_invoice_detail_id
		INNER JOIN source_deal_detail sdd 
			ON sdd.source_deal_detail_id = sch.source_deal_detail_id
		INNER JOIN source_deal_header sdh 
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		WHERE si.stmt_invoice_id = @invoice_id

		SELECT 
			MAX(CAST(CAST(sid.prod_date_from AS VARCHAR(20)) AS DATE)) [Production Month],
			CAST(dbo.FNARemoveTrailingZeroes(ROUND(SUM(sid.Volume), 2)) AS FLOAT) AS Volume,  
			CAST(CASE WHEN ISNULL(NULLIF(CAST(SUM(sid.Volume) AS INT),0),'')='' THEN '0'
					ELSE ABS(ROUND(ROUND(SUM(sid.Value),2,0),2,0)/round(SUM(volume),0)) 
			END AS FLOAT) AS Rate, 
			ABS(CAST(dbo.FNARemoveTrailingZeroes(ROUND(SUM(sid.Value),2)) AS FLOAT)) AS [Total],
			MAX(sdh.deal_id) [DealID],
			MAX(scu.currency_name) [currency],
			MAX(si.prod_date_from) [entire_term_start],
			MAX(si.prod_date_to) [entire_term_end],
			MAX(sid.description1) [description1],
			CAST(MAX(sid.prod_date_to) AS VARCHAR(20)) [prod_date_to],
			CASE 
				WHEN MAX(sdh_rjur.code) IS NOT NULL 
					THEN MAX(sdh_rjur.code) + ' ' + MAX(sdh_rtier.code) 
				WHEN MAX(sdh_state.code) IS NOT NULL 
					THEN MAX(sdh_state.code) + ' ' + MAX(sdh_tier.code) 
				ELSE 'Others'
			END [product]
		FROM stmt_invoice si
		INNER JOIN stmt_invoice_detail sid 
			ON sid.stmt_invoice_id = si.stmt_invoice_id
		INNER JOIN source_deal_header sdh 
			ON sdh.counterparty_id = si.counterparty_id AND sdh.contract_id = si.contract_id
		INNER JOIN #table_sdh sdh_1 
			ON sdh_1.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN contract_group cg 
			ON cg.contract_id = si.contract_id
		LEFT JOIN source_currency scu 
			ON scu.source_currency_id = cg.currency	
		LEFT JOIN static_data_value sdh_rjur ON sdh_rjur.value_id = sdh.reporting_jurisdiction_id
		LEFT JOIN static_data_value sdh_rtier ON sdh_rtier.value_id = sdh.reporting_tier_id
		LEFT JOIN static_data_value sdh_state ON sdh_state.value_id = sdh.state_value_id
		LEFT JOIN static_data_value sdh_tier ON sdh_tier.value_id = sdh.tier_value_id
		WHERE si.stmt_invoice_id = @invoice_id
		GROUP BY 
		CASE 
			WHEN sdh_rjur.code IS NOT NULL 
				THEN sdh_rjur.code + ' ' + sdh_rtier.code 
			WHEN sdh_state.code IS NOT NULL 
				THEN sdh_state.code + ' ' + sdh_tier.code 
			ELSE 'Others'
		END 

	END
END

ELSE IF @flag='j' -- Generation of invoice.
BEGIN
	SELECT
		sdh1.internal_counterparty sdh_internal_cpty,
		fs.counterparty_id subs_cpty,
		fas_stra.primary_counterparty_id stra_cpty,
		fas_book.primary_counterparty_id book_cpty,
		ssbm.primary_counterparty_id sub_book_cpty,
		sdh1.source_deal_header_id
	INTO #table_sdh_info
	FROM portfolio_hierarchy book(NOLOCK)
	INNER JOIN Portfolio_hierarchy stra(NOLOCK) ON book.parent_entity_id = stra.entity_id
	INNER JOIN portfolio_hierarchy sub (NOLOCK) ON stra.parent_entity_id = sub.entity_id
	INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id
	INNER JOIN fas_subsidiaries fs ON fs.fas_subsidiary_id = sub.entity_id
	INNER JOIN fas_strategy fas_stra ON fas_stra.fas_strategy_id =  stra.entity_id
	INNER JOIN fas_books fas_book ON fas_book.fas_book_id =  book.entity_id
	INNER JOIN static_data_value sdv ON sdv.[type_id] = 400 AND ssbm.fas_deal_type_value_id = sdv.value_id
	INNER JOIN source_deal_header sdh1 on sdh1.source_system_book_id1=ssbm.source_system_book_id1
			AND sdh1.source_system_book_id2=ssbm.source_system_book_id2
			AND sdh1.source_system_book_id3=ssbm.source_system_book_id3
			AND sdh1.source_system_book_id4=ssbm.source_system_book_id4
	LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = fs.counterparty_id
	LEFT JOIN counterparty_contacts cc ON cc.counterparty_id = sc.source_counterparty_id
	WHERE source_deal_header_id IN (
		SELECT MAX(sdh.source_deal_header_id)
		FROM stmt_invoice si
		INNER JOIN stmt_invoice_detail sid
			ON si.stmt_invoice_id = sid.stmt_invoice_id
		INNER JOIN stmt_checkout sch
			ON sch.stmt_invoice_detail_id = sid.stmt_invoice_detail_id
		INNER JOIN source_deal_detail sdd 
			ON sdd.source_deal_detail_id = sch.source_deal_detail_id
		INNER JOIN source_deal_header sdh 
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		WHERE si.stmt_invoice_id = @invoice_id
	) 

	SELECT 
		MAX(sdh.source_deal_header_id) source_deal_header_id,
		MAX(sdh.deal_id) deal_id,
		MAX(cii.counterparty_name) counterparty_name,
		cii.counterparty_name counterparty,
		@invoice_id AS invoice_number,
		CAST(MAX(si.prod_date_from) AS DATE) invoice_date,

		/* start: Need to review later */
		ISNULL(MAX(cca.address1), MAX(ISNULL(sc_parent.[address],cii.[address]))) counterparty_contract_address1,
		ISNULL(MAX(cca.address2), MAX(ISNULL(sc_parent.[mailing_address], cii.[mailing_address]))) counterparty_contract_address2,
		ISNULL(MAX(cca.address3), MAX(ISNULL(sc_parent.[zip],cii.[zip]))) counterparty_contract_address3,
        ISNULL(MAX(cca.address4), MAX(ISNULL(sc_parent.[city],cii.[city]))) counterparty_contract_address4,
		MAX(ISNULL(cea0.external_value, cea.external_value)) AS counterparty_external_id1,
		MAX(si.invoice_type) report_type,
		MAX(cbi_cg_subs.accountname) AS primary_account_name,
		MAX(cbi_cg_subs.Account_no) AS primary_account_no,
		MAX(cbi_cg_subs.ACH_ABA) AS primary_iban,
		MAX(cbi_cg_subs.wire_ABA) AS primary_swift_no,
		MAX(cbi_cg_subs.bank_name) AS primary_bank_name,
		MAX(cbi.bank_name) AS bank_name,
		MAX(cbi.accountname) AS account_name,
		MAX(cbi.Account_no) AS account_no,
		MAX(cbi.ACH_ABA) AS iban,
		MAX(cbi.wire_ABA) AS swift_no,
		MAX(ISNULL(cc_receivables.address1,cc.cc_address1)) cc_address1,
        MAX(ISNULL(cc_receivables.address2,cc.cc_address2)) cc_address2,
        MAX(ISNULL(cc_receivables.zip,cc.cc_zip)) cc_zip,
        MAX(ISNULL(cc_receivables.city,cc.cc_city)) cc_city,

		MAX(sc_1.counterparty_name) counterparty_name1,
		MAX(cc_1.name) name1,
		MAX(cc_1.counterparty_id) counterparty_id1,
		MAX(cc_1.address1) [counterparty_address1],
		MAX(cc_1.email) [mailing_address1],
		MAX(cc_1.telephone) [phone1],
		MAX(cc_1.fax) [fax1],
		MAX(primary_cea.external_value) [vat_no1],
		MAX(primary_cea2.external_value) [chamber_of_commerce1],
		CONVERT(NUMERIC(18,2), AVG(sid1.value)) [settlement_amount],
		ABS(CONVERT(NUMERIC(18,2), AVG(sid1.value / NULLIF(sid.volume,0)))) [settlement_price],
		CONVERT(NUMERIC(18,2), AVG(sid1.volume)) [settlement_volume],
		MAX(sc1.currency_name) currency,
		MAX(sdv_p1.code) + ' ' + MAX(sdv_p2.code) [product],
		MAX(sdv_v.code) vintage,
		--CASE WHEN MAX(sdh.match_type) = 'y' THEN 'Compliance Year' ELSE 'Calendar Year' END vintage_type,
		CASE WHEN MAX(sdh.generator_id) IS NOT NULL THEN 'Yes' ELSE 'No' END [project_specific],
		MAX(si.payment_date) payment_date,
		MAX(sdh.deal_date) deal_date,
		MAX(su.uom_id) uom,
		MAX(sdh.header_buy_sell_flag) [buy_sell],

		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(sc_1.counterparty_name) 
			ELSE MAX(cii.counterparty_name) 
		END counterparty_b, -- Buyer
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cii.counterparty_name) 
			ELSE MAX(sc_1.counterparty_name)  
		END counterparty_s, -- Seller

		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cbi1.bank_name) 
			ELSE MAX(cbi.bank_name) 
		END bank_name_b, 
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cbi.bank_name) 
			ELSE MAX(cbi1.bank_name)  
		END bank_name_s,
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cbi1.accountname) 
			ELSE MAX(cbi.accountname) 
		END accountname_b, 
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cbi.accountname) 
			ELSE MAX(cbi1.accountname)  
		END accountname_s,
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cbi1.Account_no) 
			ELSE MAX(cbi.Account_no) 
		END account_no_b, 
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cbi.Account_no) 
			ELSE MAX(cbi1.Account_no)  
		END account_no_s,
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cbi1.ACH_ABA) 
			ELSE MAX(cbi.ACH_ABA) 
		END ACH_ABA_b, 
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cbi.ACH_ABA) 
			ELSE MAX(cbi1.ACH_ABA)  
		END ACH_ABA_s,
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cbi1.wire_ABA) 
			ELSE MAX(cbi.wire_ABA) 
		END wire_ABA_b, 
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cbi.wire_ABA) 
			ELSE MAX(cbi1.wire_ABA)  
		END wire_ABA_s,

		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cc_sc_1.address1) 
			ELSE MAX(cc_cci.address1) 
		END address1_b, 
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cc_cci.address1) 
			ELSE MAX(cc_sc_1.address1)  
		END address1_s,
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cc_sc_1.address2) 
			ELSE MAX(cc_cci.address2) 
		END address2_b, 
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cc_cci.address2) 
			ELSE MAX(cc_sc_1.address2)  
		END address2_s,
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cc_sc_1.city) 
			ELSE MAX(cc_cci.city) 
		END city_b, 
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cc_cci.city) 
			ELSE MAX(cc_sc_1.city)  
		END city_s,
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cc_sc_1.state) 
			ELSE MAX(cc_cci.state) 
		END state_b, 
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cc_cci.state) 
			ELSE MAX(cc_sc_1.state)  
		END state_s,
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cc_sc_1.zip) 
			ELSE MAX(cc_cci.zip) 
		END zip_b, 
		CASE WHEN MAX(sdh.header_buy_sell_flag) = 'b' 
				THEN MAX(cc_cci.zip) 
			ELSE MAX(cc_sc_1.zip)  
		END zip_s,
		CASE WHEN MAX(sp.calendar_from_month) = 1 AND MAX(sp.calendar_to_month) = 12
			THEN 'C'
		ELSE 'R'
		END [vintage_type],
		CASE 
			WHEN MAX(sco.commodity_id) = 'RECs' THEN 'REC'
			WHEN MAX(sco.commodity_id) = 'Power' THEN 'Power'
			ELSE ''
		END commodity_type,
		CASE WHEN MAX(sdh.is_environmental) = 'y' THEN 'OTC' ELSE 'Exchange Cleared' END environmental_type,
		cii.counterparty_name [counterparty_name]
FROM stmt_invoice si
INNER JOIN stmt_invoice_detail sid
	ON si.stmt_invoice_id = sid.stmt_invoice_id
LEFT JOIN stmt_checkout sch
	ON sch.stmt_invoice_detail_id = sid.stmt_invoice_detail_id
LEFT JOIN contract_group cg 
	ON cg.contract_id = si.contract_id
LEFT JOIN source_counterparty cii
	ON  cii.source_Counterparty_id = si.counterparty_id
LEFT JOIN source_counterparty sc_parent
	ON  sc_parent.source_counterparty_id = cii.netting_parent_counterparty_id
LEFT JOIN counterparty_contract_address cca 
	ON cca.counterparty_id = si.counterparty_id AND cca.contract_id = si.contract_id
LEFT JOIN counterparty_epa_account cea ON cea.counterparty_id = si.counterparty_id AND cea.external_type_id = 2200 AND NULLIF(cea.contract_id,'') IS NULL
LEFT JOIN counterparty_epa_account cea0 ON cea0.counterparty_id = si.counterparty_id AND cea0.external_type_id = 2200 AND cea0.contract_id = si.contract_id
LEFT JOIN fas_subsidiaries fs
	ON  cg.sub_id = fs.fas_subsidiary_id
LEFT JOIN source_counterparty fs_counterparty
	ON  fs.counterparty_id = fs_counterparty.source_counterparty_id
LEFT JOIN source_currency sc ON sc.source_currency_id = cg.currency
LEFT JOIN source_currency sc1 ON sc1.source_currency_id = sch.currency_id
OUTER APPLY (
	SELECT counterparty_id 
		FROM fas_subsidiaries f1
	WHERE f1.fas_subsidiary_id = -1
) company
LEFT JOIN #table_sdh_info sdh_1 ON 1 =1
LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdh_1.source_deal_header_id
LEFT JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
LEFT JOIN source_counterparty sc_1 on sc_1.source_counterparty_id = COALESCE(sdh_1.sdh_internal_cpty, sdh_1.sub_book_cpty,sdh_1.book_cpty,sdh_1.stra_cpty, sdh_1.subs_cpty, company.counterparty_id)
LEFT JOIN counterparty_contacts cc_1 ON cc_1.counterparty_id = sc_1.source_counterparty_id AND cc_1.is_primary = 'y' 
LEFT JOIN counterparty_epa_account primary_cea ON primary_cea.counterparty_id = COALESCE(sdh_1.sdh_internal_cpty, sdh_1.sub_book_cpty,sdh_1.book_cpty,sdh_1.stra_cpty, sdh_1.subs_cpty, company.counterparty_id) AND primary_cea.external_type_id = 2200
LEFT JOIN counterparty_epa_account primary_cea2 ON primary_cea2.counterparty_id = COALESCE(sdh_1.sdh_internal_cpty, sdh_1.sub_book_cpty,sdh_1.book_cpty,sdh_1.stra_cpty, sdh_1.subs_cpty, company.counterparty_id) AND primary_cea2.external_type_id = 307234  
LEFT JOIN static_data_value sdv_p1 ON sdv_p1.value_id = sdh.state_value_id
LEFT JOIN static_data_value sdv_p2 ON sdv_p2.value_id = sdh.tier_value_id
LEFT JOIN static_data_value sdv_v ON sdv_v.value_id = sdd.vintage AND sdv_v.type_id = 10092 
LEFT JOIN source_uom su ON su.source_uom_id = sch.uom_id
LEFT JOIN state_properties sp ON sp.state_value_id = sdh.state_value_id
LEFT JOIN source_commodity sco ON sco.source_commodity_id = sdh.commodity_id

/* charge tye can be different in details */
OUTER APPLY (
	SELECT SUM(sid1.value) value, SUM(sid1.volume) volume
		FROM stmt_invoice_detail sid1
	WHERE sid1.stmt_invoice_id = si.stmt_invoice_id
) sid1

/* Start: Bank info from contract -> subsidary */
OUTER APPLY (
	SELECT
	    TOP 1
	    cbi01.wire_ABA,
		cbi01.ACH_ABA,
		cbi01.bank_name,
		cbi01.Account_no,
		cbi01.accountname
	FROM counterparty_bank_info cbi01
	WHERE  cbi01.counterparty_id = fs_counterparty.source_counterparty_id AND cbi01.currency = sc.source_currency_id
	ORDER BY cbi01.primary_account DESC
	           		
) cbi_cg_subs


/* Start: Bank info of Buy/Sell counterparty */
OUTER APPLY (
	SELECT
	    TOP 1
	    cbi01.wire_ABA,
		cbi01.ACH_ABA,
		cbi01.bank_name,
		cbi01.Account_no,
		cbi01.accountname
	FROM counterparty_bank_info cbi01
	WHERE  cbi01.counterparty_id = COALESCE(sdh_1.sdh_internal_cpty, sdh_1.sub_book_cpty,sdh_1.book_cpty,sdh_1.stra_cpty, sdh_1.subs_cpty, company.counterparty_id) AND cbi01.currency = sc.source_currency_id
	ORDER BY cbi01.primary_account DESC
	           		
) cbi1 

OUTER APPLY (
	SELECT
	    TOP 1
	    cbi0.accountname,
		cbi0.wire_ABA,
		cbi0.reference,
		cca0.bank_account,
		cbi0.ACH_ABA,
		cbi0.bank_name,
		cbi0.Account_no
	FROM counterparty_bank_info cbi0
	LEFT JOIN counterparty_contract_address cca0 ON cca0.counterparty_id = si.counterparty_id AND cca0.contract_id = si.contract_id AND cbi0.bank_id = cca0.bank_account
	WHERE  cbi0.counterparty_id = ISNULL(sc_parent.source_counterparty_id,cii.source_counterparty_id) AND cbi0.currency = sc.source_currency_id
	ORDER BY ISNULL(cca0.bank_account,0) DESC, cbi0.primary_account DESC  -- cbi0.primary_account= 'y'
	           		
) cbi 
/* End: Bank info of Buy/Sell counterparty */

OUTER APPLY (
	SELECT address1 [cc_address1],
	        address2 [cc_address2],
	        zip [cc_zip],
	        city [cc_city],
	        [name] [cc_name],
	        cc.telephone [cc_phone],
	        fax [cc_fax],
	        cc.email [cc_email],
	        cc.country [cc_country],
	        cc.region [cc_region]
	FROM   counterparty_contacts cc
	WHERE  cc.counterparty_id = si.counterparty_id
	        AND cc.is_primary = 'y'
)cc

/* Start: Contacts Address of Buy/Sell counterparty */
OUTER APPLY (
	SELECT TOP 1 address1 [address1],
	        address2 [address2],
	        zip [zip],
	        city [city],
			sdv_state.code [state],
	        [name] [name],
	        cc.telephone [phone],
	        fax [fax],
	        cc.email [email],
	        cc.country [country],
	        cc.region [region]
	FROM   counterparty_contacts cc
	LEFT JOIN static_data_value sdv_state ON sdv_state.value_id = cc.state
	WHERE  cc.counterparty_id = ISNULL(sc_parent.source_counterparty_id,cii.source_counterparty_id)
	        ORDER BY is_primary DESC
) cc_cci

OUTER APPLY (
	SELECT TOP 1 address1 [address1],
	        address2 [address2],
	        zip [zip],
	        city [city],
			sdv_state.code [state],
	        [name] [name],
	        cc.telephone [phone],
	        fax [fax],
	        cc.email [email],
	        cc.country [country],
	        cc.region [region]
	FROM   counterparty_contacts cc
	LEFT JOIN static_data_value sdv_state ON sdv_state.value_id = cc.state
	WHERE  cc.counterparty_id = sc_1.source_counterparty_id
	        ORDER BY is_primary DESC
) cc_sc_1
/* End : Contacts Address of Buy/Sell counterparty */

LEFT JOIN counterparty_contacts cc_receivables ON cc_receivables.counterparty_contact_id = ISNULL(cca.receivables,sc_parent.receivables)


WHERE si.stmt_invoice_id = @invoice_id
GROUP BY cii.counterparty_name, si.invoice_number

END


IF @flag = 'g'
BEGIN
	SET @amount = ISNULL(@amount,0)

	SELECT 
		sdv.code [charge_type],
		CAST(dbo.FNARemoveTrailingZeroes(Round(sid.[value],2)) AS FLOAT) [shadow_calc],
		CASE WHEN @amount  IS NULL OR @amount = 0
				THEN Round(scid.invoice_amount,2)  
				ELSE ROUND((sid.[value] / ISNULL(NULLIF(a.total_shadow_calc,0),1)) * (COALESCE(@amount,invoice_amount, 0)*-1), 2) 
		END [amount],
		CAST(CASE WHEN @amount  IS NULL OR @amount = 0
				THEN Round(sid.[value],2) - (ROUND(scid.invoice_amount,2)) 
				ELSE Round(sid.[value],2) - (ROUND((sid.[value] / ISNULL(NULLIF(a.total_shadow_calc,0),1)) * (COALESCE(@amount,scid.invoice_amount, 0)*-1), 2))  
		END AS NUMERIC(32,2)) [variance],
		scid.prod_date_from [date_from],
		scid.prod_date_to [date_to],
		scid.currency_id [currency],
		scid.invoice_volume [volume],
		scid.invoice_volume_uom_id [uom],
		scid.[description1] [description],
		sid.invoice_line_item_id [invoice_line_item_id]
		
	INTO #table_invoice
	FROM
	stmt_invoice_detail sid
		LEFT JOIN stmt_counterparty_invoice sci ON sci.stmt_invoice_id = sid.stmt_invoice_id
		LEFT JOIN  stmt_counterparty_invoice_detail scid ON scid.stmt_counterparty_invoice_id = sci.stmt_counterparty_invoice_id AND sid.invoice_line_item_id = scid.invoice_line_item_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = sid.invoice_line_item_id 

	OUTER APPLY (
		SELECT SUM(value) total_shadow_calc FROM stmt_invoice_detail sid 
		WHERE sid.stmt_invoice_id = @stmt_invoice_id
	) a

	WHERE sid.stmt_invoice_id = @stmt_invoice_id

	SELECT * FROM #table_invoice
	UNION ALL
	SELECT '<strong>Total</strong>',
			CAST(SUM([shadow_calc]) AS NUMERIC(32,2)),
			CAST(SUM([amount]) AS NUMERIC(32,2)),
			CAST(SUM([variance]) AS NUMERIC(32,2)),
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL
	FROM #table_invoice
END

IF @flag = 'e'
BEGIN
	DECLARE 
	   @notification_type INT = 752 
	 , @parameter NVARCHAR(MAX)
	 , @report_folder NVARCHAR(1024) = N'custom_reports/'
	 , @report_file  NVARCHAR(MAX)
	 , @report_file_path NVARCHAR(MAX) = NULL
	 , @report_name NVARCHAR(MAX) = 'Invoice Report Collection'
	 , @filter NVARCHAR(MAX) 
	 , @reporting_param  NVARCHAR(MAX)  = ''
	 , @email_attachment NCHAR(4) = NULL
	 , @unique_process_id  NVARCHAR(13)
	 , @email_configuration_id INT
	 , @subject NVARCHAR(MAX)
	 , @email_description NVARCHAR(MAX)
	 , @email_footer NVARCHAR(MAX)
	 , @invoice_contact NVARCHAR(300) 
	 , @invoice_counterparty_id NVARCHAR(300) 
	 , @prod_date NVARCHAR(50) 
	 , @bcc_emails NVARCHAR(MAX)
	 , @cc_emails NVARCHAR(MAX)
	 , @email_address NVARCHAR(MAX)
	 , @selected_counterparty_id INT 
 	 , @selected_contract_id INT 
	 , @is_email_counterparty_contract BIT = 0
	 , @doc_path  NVARCHAR(MAX)
	
	SET @user_login_id = dbo.FNADBUser()   
	SET @email_attachment = CASE WHEN @notification_type IN (752) THEN 'y' ELSE 'n' END
	SET @unique_process_id = CONVERT(NVARCHAR(13), right(REPLACE(newid(),'-', ''),13))
	SET @batch_process_id = dbo.FNAGetNewID() + '_' + @unique_process_id
	SET @job_name = 'report_batch' + '_' + @batch_process_id

	SELECT 
		@report_file_path = document_path + '\temp_Note/Invoice Report Template.pdf'
		, @doc_path = document_path + '\temp_Note'
	FROM connection_string c

	SELECT 
	      @invoice_contact = ISNULL(cca.counterparty_full_name, sc.counterparty_contact_name)
		, @invoice_counterparty_id = sc.counterparty_id
		, @prod_date = CONCAT(SUBSTRING(DATENAME(mm,prod_date_from),1,3) +' ', CAST(DATEPART(yyyy,prod_date_from) AS NVARCHAR)) 
		, @invoice_type = CASE WHen @stmt_invoice_id > 0 THEN si.invoice_type  ELSE 'n' END
		, @selected_counterparty_id  = si.counterparty_id
		, @selected_contract_id = si.contract_id
	FROM stmt_invoice si
	INNER JOIN source_counterparty sc ON si.counterparty_id = sc.source_counterparty_id
	INNER JOIN contract_group cg  ON cg.contract_id = si.contract_id
	LEFT JOIN counterparty_contract_address cca ON cca.counterparty_id = sc.source_counterparty_id AND cca.contract_id = cg.contract_id
	WHERE stmt_invoice_id = abs(@stmt_invoice_id)

	IF ISNULL(NULLIF(@send_option, ''), 'n') = 'y' 
	BEGIN
		--Pick payables and receiveables address
		SELECT @is_email_counterparty_contract = 
			CASE WHEN NULLIF(cc.email,'') IS NOT NULL OR NULLIF(cc.email_bcc,'') IS NOT NULL OR NULLIF(cc.email_cc,'') IS NOT NULL 
				THEN 1 ELSE 0 
			END
		FROM counterparty_contract_address cca
		LEFT JOIN source_counterparty sc on sc.source_counterparty_id = @selected_counterparty_id
		LEFT JOIN counterparty_contacts cc on cc.counterparty_id = @selected_counterparty_id
			AND cc.counterparty_contact_id = (CASE WHEN  @invoice_type = 'i' THEN ISNULL(cca.payables,sc.payables)  WHEN  @invoice_type = 'r' THEN ISNULL(cca.receivables,sc.receivables) ELSE ISNULL(cca.netting, sc.netting)  END )
		WHERE  cca.counterparty_id = @selected_counterparty_id AND cca.contract_id = @selected_contract_id

		SELECT @email_address = 
			CASE @is_email_counterparty_contract
				WHEN 1
					THEN CASE 
							WHEN @invoice_type = 'i'
								THEN ISNULL(cc_payables.email, primary_contact.email)
							WHEN @invoice_type  = 'r' 
								THEN ISNULL(cc_receivables.email, primary_contact.email)
							ELSE ISNULL(cc_netting.email, primary_contact.email)
							END
				ELSE cca.email
				END
				, @cc_emails = CASE @is_email_counterparty_contract
				WHEN 1
					THEN CASE 
							WHEN @invoice_type = 'i'
								THEN ISNULL(cc_payables.email_cc, primary_contact.email_cc)
							WHEN @invoice_type = 'r' 
								THEN ISNULL(cc_receivables.email_cc, primary_contact.email_cc)
							ELSE ISNULL(cc_netting.email_cc, primary_contact.email)
							END
				ELSE cca.cc_mail
				END
				, @bcc_emails = CASE @is_email_counterparty_contract
				WHEN 1
					THEN CASE 
							WHEN @invoice_type = 'i'
								THEN ISNULL(cc_payables.email_bcc, primary_contact.email_bcc)
							WHEN @invoice_type = 'r' 
								THEN ISNULL(cc_receivables.email_bcc, primary_contact.email_bcc)
							ELSE ISNULL(cc_netting.email_bcc, primary_contact.email)
							END
				ELSE cca.bcc_mail
			END
		FROM source_counterparty sc
		LEFT JOIN counterparty_contract_address cca ON sc.source_counterparty_id = cca.counterparty_id
			AND cca.contract_id = @selected_contract_id
		LEFT JOIN counterparty_contacts cc_payables ON sc.source_counterparty_id = cc_payables.counterparty_id
			AND cc_payables.counterparty_contact_id = ISNULL(cca.payables, sc.payables)
		LEFT JOIN counterparty_contacts cc_receivables ON sc.source_counterparty_id = cc_receivables.counterparty_id
			AND cc_receivables.counterparty_contact_id = ISNULL(cca.receivables, sc.receivables)
		LEFT JOIN counterparty_contacts cc_netting ON sc.source_counterparty_id = cc_netting.counterparty_id
			AND cc_netting.counterparty_contact_id = ISNULL(cca.netting, sc.netting)
		LEFT JOIN counterparty_contacts primary_contact ON sc.source_counterparty_id = primary_contact.counterparty_id
			AND primary_contact.is_primary = 'y'
		WHERE sc.source_counterparty_id = @selected_counterparty_id

		IF NULLIF(@email_address,'') IS NOT NULL
		BEGIN							
			INSERT INTO batch_process_notifications (user_login_id, role_id, process_id, notification_type, attach_file, scheduled, csv_file_path, holiday_calendar_id, non_sys_user_email, bcc_email, cc_email)	
			SELECT NULL,
					NULL,
					@unique_process_id,
					@notification_type,
					@email_attachment,
					 'n',
					@doc_path,
					NULL,
					NULLIF(@email_address,''),
					NULLIF(@bcc_emails, ''),
					NULLIF(@cc_emails,'')
		END	
		
	END

	INSERT INTO batch_process_notifications (user_login_id, role_id, process_id, notification_type, attach_file, scheduled, csv_file_path, holiday_calendar_id, non_sys_user_email)
	SELECT  NULL,
			NULL,
			@unique_process_id,
			@notification_type,
			@email_attachment,
			 'n' ,
			@doc_path,
			NULL,
			a.item
	FROM  dbo.SplitCommaSeperatedValues(@non_system_users) a
	UNION
	SELECT a.item,
			NULL,
			@unique_process_id,
			@notification_type,
			@email_attachment,
			 'n' ,
			@doc_path,
			NULL,
			NULL
	FROM dbo.SplitCommaSeperatedValues(@notify_users) a
	LEFT JOIN application_users au ON au.user_login_id = a.item
	WHERE @notify_users IS NOT NULL AND au.user_active = 'y'
	UNION
	SELECT NULL,
			a.item,
			@unique_process_id,
			@notification_type,
			@email_attachment,
			'n' ,
			@doc_path,
			NULL,
			NULL
	FROM   dbo.SplitCommaSeperatedValues(@notify_roles) a
	WHERE  @notify_roles IS NOT NULL
	UNION
	SELECT @user_login_id,
			NULL,
			@unique_process_id,
			@notification_type,
			@email_attachment,
			 'n',
			@doc_path,
			NULL,
			NULL	
	WHERE @notification_type <> 750

	SELECT 
		@email_configuration_id = admin_email_configuration_id 
	FROM admin_email_configuration WHERE module_type = 17804 AND default_email = 'y'

	SET @report_file = @invoice_counterparty_id + CAST(@stmt_invoice_id AS NVARCHAR(20)) + '.pdf'

	SELECT @subject = email_subject
		 , @email_description = email_body
	FROM admin_email_configuration aec
	WHERE aec.module_type = 17804
		AND admin_email_configuration_id = @email_configuration_id

	SET @subject = REPLACE(@subject,'[invoice_number]', CAST(@stmt_invoice_id AS NVARCHAR(20)))
	SET @subject = REPLACE(@subject,'[prod_date]', @prod_date )
			
	SET @email_description = dbo.FNAURLDecode(@email_description)
	SET @email_description = REPLACE(@email_description, '[invoice_contact]', ISNULL(@invoice_contact, ''))
			
	SET @email_description = REPLACE(@email_description,'[prod_date]', @prod_date )
	SET @email_description = REPLACE(@email_description,'[invoice_number]', CAST(@stmt_invoice_id AS NVARCHAR(20)))
	SET @email_description = REPLACE(@email_description,'[invoice_type]',  CASE WHEN @invoice_type = 'i' THEN 'Invoice' WHEN @invoice_type = 'r' THEN 'Remittance' WHEN  @invoice_type  = 'n' THEN  'Netting' ELSE '' END )
			
	SELECT @email_footer = aec.email_footer 
	FROM admin_email_configuration aec 
	WHERE aec.module_type = 17804 
		AND admin_email_configuration_id = @email_configuration_id
			
	IF @email_footer IS NOT NULL
	BEGIN
		SET @email_description = @email_description + '<br />' + @email_footer
	END

	SET @filter = 'flag:b,invoice_ids:' + CAST(@stmt_invoice_id AS NVARCHAR(20))
	SET @parameter = REPLACE(@reporting_param, 'Invoice Report Template.pdf', @report_file)
	SET @parameter = REPLACE(@parameter, 'Invoice Report Template', @report_name) + @filter

	EXEC spa_message_board 'i', @user_login_id, NULL, 'Settlement Invoice', 'Emailing job started for Settlement invoices.', NULL, NULL, 's', @job_name, NULL, @unique_process_id, NULL, 'n'
	
	SET @sql = 'EXEC spa_rfx_export_report_job @report_param=''' + @parameter + ''', @proc_desc=''Send Settlement Invoice'' , @user_login_id=''farrms_admin'', @report_RDL_name=''' + @report_folder + @report_name + ''', @report_file_name=''' + @report_file+ ''', @report_file_full_path=''' + REPLACE(@report_file_path, 'Invoice Report Template.pdf', @report_file) + ''', @process_id=''' + @batch_process_id + ''', @email_description =''' + @email_description + ''',@email_subject=''' + @subject + ''',@is_aggregate=0,@call_from_invoice=''call_from_stmt_invoice'', @output_file_format=''PDF'''
	 
	EXEC (@sql) 

	IF NULLIF(@non_system_users, '') IS NULL AND NULLIF(@notify_roles, '') IS NULL AND NULLIF(@notify_roles, '') IS NULL AND NULLIF(@email_address, '') IS NULL 
	BEGIN 
		EXEC spa_message_board 'u', @user_login_id, NULL, 'Settlement Invoice', 'Email address not defined.', NULL, NULL, 's', @job_name, NULL, @unique_process_id, NULL, 'n'
	END 
	ELSE 
	BEGIN
		EXEC spa_message_board 'u', @user_login_id, NULL, 'Settlement Invoice', 'Settlement invoice sent.', NULL, NULL, 's', @job_name, NULL, @unique_process_id, NULL, 'n'
	END
	
END
ELSE IF @flag = 'paid' OR @flag = 'unpaid'-- Paid/Unpaid invoice.
BEGIN
	BEGIN TRY
		BEGIN TRAN
			SET @sql = '
				UPDATE stmt_invoice
					SET payment_status = ''' + CASE WHEN @flag = 'paid' THEN 'p' ELSE 'u' END + '''
				WHERE stmt_invoice_id IN (' + @invoice_id + ')'
			EXEC(@sql)

			SET @message = 'Settlement ' + CASE WHEN @flag = 'p' THEN 'paid' ELSE 'unpaid' END + ' sucessfully.'

			EXEC spa_ErrorHandler 0,
				'stmt_invoice',
				'spa_stmt_invoice',
				'Success',
				@message,
				''		
			COMMIT			
	END TRY
	BEGIN CATCH 
		SET @message = 'Failed to ' + CASE WHEN @flag = 'p' THEN 'paid' ELSE 'unpaid' END + ' settlement.'
		IF @@TRANCOUNT > 0
		   ROLLBACK
		IF @@Error <> 0
			EXEC spa_ErrorHandler @@Error,
				 'stmt_invoice',
				 'spa_stmt_invoice',
				 'Error',
				 @message,
				 ''	   
	END CATCH
END  

ELSE IF @flag = 'y' OR @flag = 'n'-- locked/Unlocked.
BEGIN
	BEGIN TRY
		BEGIN TRAN
			
			IF OBJECT_ID('tempdb..#invoice_lock_unlock') IS NOT NULL
				DROP TABLE #invoice_lock_unlock

			SELECT * INTO #invoice_lock_unlock FROM dbo.SplitCommaSeperatedValues(@invoice_id) id

			/* Lock and Unlock backing sheet */
			INSERT INTO #invoice_lock_unlock
			SELECT DISTINCT si_b.stmt_invoice_id FROM stmt_invoice si
			INNER JOIN #invoice_lock_unlock tid ON tid.item = si.stmt_invoice_id
			INNER JOIN stmt_invoice_detail stid ON si.stmt_invoice_id = stid.stmt_invoice_id
			OUTER APPLY( SELECT itm.item [stmt_checkout_id] FROM dbo.SplitCommaSeperatedValues(stid.description1) itm) a 
			INNER JOIN stmt_invoice_detail stid_b ON stid_b.description1 = a.[stmt_checkout_id]
			INNER JOIN stmt_invoice si_b ON si_b.stmt_invoice_id = stid_b.stmt_invoice_id AND ISNULL(si_b.is_voided,'n') = ISNULL(si.is_voided,'n')
			WHERE ISNULL(si_b.is_backing_sheet,'n') = 'y'

			SET @sql = '
				UPDATE si
					SET si.is_locked = ''' + @flag + '''
				FROM stmt_invoice si
				INNER JOIN #invoice_lock_unlock tmp ON si.stmt_invoice_id = tmp.item'
			EXEC(@sql)

		SET @message = 'Settlement ' + CASE WHEN @flag = 'y' THEN 'locked' ELSE 'unlocked' END + ' sucessfully.'

			EXEC spa_ErrorHandler 0,
				'stmt_invoice',
				'spa_stmt_invoice',
				'Success',
				@message,
				''		
			COMMIT			
	END TRY
	BEGIN CATCH 
		SET @message = 'Failed to ' + CASE WHEN @flag = 'y' THEN 'locked' ELSE 'unlocked' END + ' settlement.'
		IF @@TRANCOUNT > 0
		   ROLLBACK
		IF @@Error <> 0
			EXEC spa_ErrorHandler @@Error,
				 'stmt_invoice',
				 'spa_stmt_invoice',
				 'Error',
				 @message,
				 ''	   
	END CATCH
END  