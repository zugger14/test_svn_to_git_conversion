
IF OBJECT_ID(N'[dbo].[spa_settlement_history]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_settlement_history]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

 /**
	Operation for View Invoice menu

	Parameters :
	@flag : Flag
			'g'-- return data for main grid in settlement history
			'w'-- charge type grid - invoice and history tab
			'h'-- load data in history grid
			'd'-- load data in dispute grid
			't'-- load the charge type details
			'u'-- Load Counterparty and Contract
			'y'-- Check if invoice is voided or not
			'l'-- Lock the invoice
			'o'-- Unlock the invoice
			'f'-- Finalize the invoice
			'n'-- Unfinalize the invoice
			'e'-- Delete the invoice
			'r'-- Update the invoice status
			'm'-- Update the invoice
			'a'-- Insert the settlement dispute
			'b'-- Update the settlement dispute
			'c'-- Delete the settlement dispute
			'x'-- Add manual adjustment
			'y'-- Update manual adjustment
			'z'-- Delete manual adjustment
			'j'-- Finalize manual adjustment
			'k'-- Unfinalize manual adjustment
			'v'-- Void the Invoice
			'p'-- Split the invoice
			'q'-- Reprocess the invoice
			'i'-- To load contract in dropdown as per selected counterparty
	@counterparty_id : Counterparty Id
	@contract_id : Contract Id
	@prod_date_from : Prod Date From
	@prod_date_to : Prod Date To
	@settlement_date_from : Settlement Date From
	@settlement_date_to : Settlement Date To
	@payment_date_from : Payment Date From
	@payment_date_to : Payment Date To
	@invoice_status : Invoice Status
	@calc_status : Calc Status
	@invoice_lock : Invoice Lock
	@invoice_number : Invoice Number
	@invoice_type : Invoice Type
	@deal_id : Deal Id
	@reference_id : Reference Id
	@commodity : Commodity
	@counterparty_type : Counterparty Type
	@calc_id : Calc Id
	@xml : Xml Data
	@invoice_template : Invoice Template
	@individual_invoice : Individual Invoice
	@reporting_param : Reporting Param
	@report_file_path : Report File Path
	@report_folder : Report Folder
	@batch_process_id : Batch Process Id
	@batch_report_param : Batch Report Param
 */

CREATE PROCEDURE [dbo].[spa_settlement_history]
    @flag CHAR(1),
    @counterparty_id NVARCHAR(1000) = NULL,
    @contract_id VARCHAR(500) = NULL,
    @prod_date_from DATETIME = NULL,
    @prod_date_to DATETIME = NULL,
    @settlement_date_from DATETIME = NULL,
    @settlement_date_to DATETIME = NULL,
    @payment_date_from DATETIME = NULL,
    @payment_date_to DATETIME = NULL,
    @invoice_status INT = NULL,
	@calc_status CHAR(1) = NULL,
	@invoice_lock CHAR(1) = NULL,
	@invoice_number VARCHAR(100) = NULL,
	@invoice_type CHAR(1) = NULL,
	@deal_id INT = NULL,
	@reference_id VARCHAR(500) = NULL,
	@commodity VARCHAR(500) = NULL,
	@counterparty_type CHAR(1) = NULL,
	@calc_id INT = NULL,
	@xml NVARCHAR(MAX) = NULL,
	@invoice_template INT = NULL,
	@individual_invoice CHAR(1) = 'n', -- To show individual invoice for netting counterparty
	@reporting_param VARCHAR(2000) = NULL, -- Added to download the pdf invoice after it is finalized or voided
	@report_file_path VARCHAR(2000) = NULL, -- Added to download the pdf invoice after it is finalized or voided
	@report_folder VARCHAR(2000) = NULL, -- Added to download the pdf invoice after it is finalized or voided
	@batch_process_id	varchar(120) = NULL,
	@batch_report_param	varchar(5000) = NULL	
    
AS
SET NOCOUNT ON; 
DECLARE @sql VARCHAR(MAX),
		@user_name VARCHAR(100),
		@idoc  INT,
		@message VARCHAR(4000),
		@process_id VARCHAR(200)

SET @user_name = dbo.FNADBUser()

DECLARE @filter_cpty_id INT
DECLARE @filter_contract_id INT
DECLARE @filter_as_of_date DATETIME
DECLARE @filter_date_from DATETIME
DECLARE @filter_date_to DATETIME
DECLARE @invoice_template_id INT 

SET @xml = NULLIF(@xml, '') 

IF OBJECT_ID('tempdb..#prevent_alert') IS NOT NULL
	DROP TABLE #prevent_alert

CREATE TABLE #prevent_alert(errorcode VARCHAR(50) COLLATE DATABASE_DEFAULT, [message] VARCHAR(1000) COLLATE DATABASE_DEFAULT)

IF @flag IN ('g') -- return data for main grid in settlement history
BEGIN	
	SET @sql = 'SELECT   ' + char(10)
			 + '		counterparty_name             [counterparty],  ' + char(10)
			 + '		ISNULL(cast(ng.netting_group_name as Nvarchar), contract_name) [contract],  ' + char(10)
			 + '		civv.invoice_number [invoice_number],  ' + char(10)
			 + '		civv.invoice_number + '' '' + ISNULL(''('' + CAST(civv1.invoice_number AS VARCHAR(20)) + '')'', '''') [concat_invoice],  ' + char(10)
			 + '		sc.source_counterparty_id  AS [counterparty_id],  ' + char(10)
			 + '		cg.contract_id contract_id,  ' + char(10)
			 + '		dbo.FNADateFormat(civv.prod_date) [date_from],  ' + char(10)
			 + '		dbo.FNADateFormat(civv.prod_date_to) [date_to],  ' + char(10)
			 + '		ISNULL(dbo.FNADateFormat(civv.settlement_date), dbo.FNADateFormat(dbo.FNAInvoiceDueDate( CASE WHEN cg.settlement_date = ''20023''  OR cg.settlement_date = ''20024'' THEN civv.finalized_date ELSE civv.prod_date END, cg.settlement_date, cg.holiday_calendar_id, cg.settlement_days))) [settlement_date],  ' + char(10)
			 + '		ISNULL(dbo.FNADateFormat(civv.payment_date), dbo.FNADateFormat(dbo.FNAInvoiceDueDate( CASE WHEN cg.invoice_due_date = ''20023''  OR cg.invoice_due_date = ''20024'' THEN civv.finalized_date ELSE civv.prod_date END, cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days))) [payment_date],  ' + char(10)
			 + '		CONVERT(VARCHAR(200),CAST(civ.[Value] AS NUMERIC(38,18)), 1) [amount],  ' + char(10)
			 + '		scu.currency_name [currency],  ' + char(10)
			 + '		CASE WHEN civv.invoice_type =''i'' THEN ''Invoice'' WHEN civv.invoice_type =''r'' THEN ''Remittance'' END [invoice_type],  ' + char(10)
			 + '		CASE WHEN ISNULL(civv.invoice_lock, ''n'') = ''n'' THEN ''Unlocked'' ELSE ''Locked'' END [lock_status],  ' + char(10)
			 + '		CASE WHEN civ.status = ''v'' THEN ''Voided'' WHEN ISNULL(civv.finalized, ''n'') = ''n'' THEN ''Estimate'' ELSE ''Finalized'' END [calc_status],  ' + char(10)
			 + '		sdv.[description] AS [invoice_status],  ' + char(10)
			 + '		CAST(civv.calc_id AS VARCHAR(20)) [calc_id],  ' + char(10)
			 + '		dbo.FNADateFormat(civv.finalized_date) [finalized_date],  ' + char(10)
			 + '		civv.invoice_note [invoice_note],  ' + char(10)
			 + '		civv.invoice_status AS [invoice_status_id],  ' + char(10)
			 + '		dbo.FNADateFormat(civv.as_of_date) [as_of_date],  ' + char(10)
			 + '		civ2.invoice_amount [incoming_invoice_amount], '  + char(10)
			 + '		ROUND(civ2.[variance], 2) [variance], ' +  + char(10)

			 + '		--CASE WHEN civv.invoice_type = ''i'' THEN NULL ELSE ih.amount END [incoming_invoice_amount],  ' + char(10)
			 + '		--CASE WHEN civv.invoice_type = ''i'' THEN NULL ELSE civ.value - ih.amount END [variance],  ' + char(10)

			 + '		ih.invoice_id [inv_rec_id], ' + char(10)
			 + '		ih.invoice_ref_no [invoice_ref_no], ' + char(10)  
			 + '		CASE WHEN civv.delta = ''y'' THEN ''Yes'' ELSE ''No'' END [delta], ' + char(10) 
			 + '		COALESCE(crt.template_name,crp_netting.template_name,crp_invoice.template_name,crp_remittance.template_name) [invoice_template], ' + char(10) 
			 + '		dbo.FNADateFormat(civv.create_ts) [create_date], ' + char(10) 
			 + '		civv.create_user [create_user], ' + char(10) 
			 + '		dbo.FNADateFormat(civv.update_ts) [update_date], ' + char(10) 
			 + '		civv.update_user [update_user], ' + char(10) 
			 + '		civv.netting_calc_id [netting_calc_id], ' + char(10) 
			 + '		civv.invoice_file_name [invoice_file_name], ' + char(10) 
			  + '		civv.netting_file_name [netting_file_name] ,' + char(10) 
			+ '		COALESCE(crt.document_type,crp_netting.document_type,crp_invoice.document_type,crp_remittance.document_type) [document_type] ' + char(10) 			 + 'INTO #temp_calc_summary FROM calc_invoice_volume_variance civv ' + char(10)
			 + 'CROSS APPLY (SELECT MAX(status) status, SUM([Value]) [value], civ.calc_id FROM calc_invoice_volume civ WHERE civv.calc_id = civ.calc_id GROUP BY civ.calc_id) civ ' + char(10)
			 + 'INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = civv.counterparty_id  ' + char(10)
			 + 'INNER JOIN contract_group cg ON  cg.contract_id = civv.contract_id  ' + char(10)
			 + 'LEFT JOIN invoice_header ih ON ih.counterparty_id = civv.counterparty_id AND ih.Production_month = civv.prod_date AND ih.contract_id = civv.contract_id ' + char(10)
			 + 'LEFT JOIN source_currency scu ON scu.source_currency_id = cg.currency  ' + char(10)
			 + 'LEFT JOIN static_data_value sdv ON sdv.value_id = civv.invoice_status  ' + char(10)
			 + 'LEFT JOIN Contract_report_template crp_invoice ON crp_invoice.template_id = cg.invoice_report_template AND civv.invoice_type = ''i'' ' + char(10)
			 + 'LEFT JOIN Contract_report_template crp_remittance ON crp_remittance.template_id = cg.Contract_report_template AND civv.invoice_type = ''r'' ' + char(10)
			 + 'LEFT JOIN Contract_report_template crp_netting ON crp_netting.template_id = cg.netting_template AND civv.netting_group_id IS NOT NULL' + char(10)
			 + 'LEFT JOIN contract_report_template crt ON  crt.template_id = civv.invoice_template_id  ' + char(10)
			 + 'LEFT JOIN netting_group ng ON  ng.netting_group_id = civv.netting_group_id  ' + char(10)
			 + 'OUTER APPLY ( ' + char(10)
			 + '    SELECT MAX(as_of_date) as_of_date ' + char(10)
			 + '    FROM   calc_invoice_volume_variance civv_a ' + char(10)
			 + '		   INNER JOIN calc_invoice_volume civ_a ON civv_a.calc_id = civ_a.calc_id ' + char(10)
			 + '    WHERE  civv_a.invoice_type = civv.invoice_type AND civv_a.counterparty_id = civv.counterparty_id ' + char(10)
			 + '            AND civv_a.contract_id = civv.contract_id ' + char(10)
			 + '            AND civv_a.prod_date = civv.prod_date ' + char(10)
			 + '            AND ISNULL(civ_a.status,'''') <> ''v''' + char(10)
			 + '            AND ISNULL(civv_a.invoice_template_id,-1) =  ISNULL(civv.invoice_template_id,-1)' + char(10)
			 + ') max_date  ' + char(10)			
			 + 'OUTER APPLY ( ' + char(10)
			 + '    SELECT MAX(as_of_date) as_of_date ' + char(10)
			 + '    FROM   calc_invoice_volume_variance civv_a ' + char(10)
			 + '		   INNER JOIN calc_invoice_volume civ_a ON civv_a.calc_id = civ_a.calc_id' + char(10)
			 + '    WHERE  civv_a.invoice_type = civv.invoice_type AND civv_a.counterparty_id = civv.counterparty_id ' + char(10)
			 + '            AND civv_a.contract_id = civv.contract_id ' + char(10)
			 + '            AND civv_a.prod_date = civv.prod_date ' + char(10)
			 + '            AND ISNULL(civ_a.status,'''') = ''v''' + char(10)
			 + ') max_date1  ' + char(10)		
			 +CASE WHEN @deal_id IS NOT NULL OR  @reference_id IS NOT NULL THEN 
				  ' INNER JOIN  calc_formula_value cfv ON cfv.calc_id = civv.calc_id ' + char(10)
				 + 'LEFT JOIN source_deal_header sdh ON  sdh.source_deal_header_id = cfv.source_deal_header_id  ' + char(10)
			 ELSE '' END
			 + 'LEFT JOIN calc_invoice_volume_variance civv1 ON civv1.calc_id = civv.original_invoice '
			 + 'CROSS APPLY(SELECT SUM(ROUND(id.invoice_amount, 2)) [invoice_amount], SUM(Round(civ.value,2) - ROUND(id.invoice_amount,2)) [variance] FROM calc_invoice_volume AS civ LEFT JOIN invoice_detail AS id ON ih.invoice_id = id.invoice_id AND id.invoice_line_item_id = civ.invoice_line_item_id WHERE civv.calc_id = civ.calc_id GROUP BY civ.calc_id) AS civ2 ' 
			 + 'WHERE  1 = 1 ' + char(10)
			 + 'AND (max_date1.as_of_date = civv.as_of_date OR max_date.as_of_date= civv.as_of_date)  AND civ.calc_id = civv.calc_id'
	
	IF @individual_invoice = 'n'
		SET @sql += ' AND civv.netting_calc_id IS NULL' 
	

	IF @counterparty_id IS NOT NULL
		SET @sql += ' AND civv.counterparty_id IN (' + @counterparty_id + ')' 
		
	IF @contract_id IS NOT NULL
		SET @sql += ' AND civv.contract_id IN (' + @contract_id + ')'
		
	IF @prod_date_from IS NOT NULL
		SET @sql += ' AND CONVERT(VARCHAR(10), civv.prod_date, 120) >= ''' + CONVERT(VARCHAR(10), @prod_date_from, 120) + ''''
	
	IF @prod_date_to IS NOT NULL
		SET @sql += ' AND CONVERT(VARCHAR(10), ISNULL(civv.prod_date_to,civv.prod_date), 120) <= ''' + CONVERT(VARCHAR(10), @prod_date_to, 120) + ''''
	
	IF @settlement_date_from IS NOT NULL
		SET @sql += ' AND CONVERT(VARCHAR(10), civv.settlement_date, 120) >= ''' + CONVERT(VARCHAR(10), @settlement_date_from, 120) + ''''
	
	IF @settlement_date_to IS NOT NULL
		SET @sql += ' AND CONVERT(VARCHAR(10), civv.settlement_date, 120) <= ''' + CONVERT(VARCHAR(10), @settlement_date_to, 120) + ''''
		
	IF @payment_date_from IS NOT NULL
		SET @sql += ' AND ISNULL(civv.payment_date, dbo.FNAInvoiceDueDate(civv.prod_date, cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days)) >= ''' + CONVERT(VARCHAR(10), @payment_date_from, 120) + ''''
	
	IF @payment_date_to IS NOT NULL
		SET @sql += ' AND ISNULL(civv.payment_date, dbo.FNAInvoiceDueDate(civv.prod_date, cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days)) <= ''' + CONVERT(VARCHAR(10), @payment_date_to, 120) + ''''
		
	IF @invoice_status IS NOT NULL
		SET @sql += ' AND civv.invoice_status = ' + CAST(@invoice_status AS VARCHAR(20)) 
		

	IF @calc_status IS NOT NULL AND @calc_status = 'v'
		SET @sql += ' AND ISNULL(civ.status, '''') = ''v'''

	IF @calc_status IS NOT NULL  AND @calc_status <> 'v'
		SET @sql += ' AND ISNULL(civv.finalized, ''n'') = ''' + @calc_status + '''  AND ISNULL(civ.status, '''') <> ''v'''
	
	IF @invoice_number IS NOT NULL
		SET @sql += ' AND ISNULL(CAST(civv.invoice_number AS VARCHAR),CAST(civv.calc_id AS VARCHAR)) = ''' + CAST(@invoice_number AS VARCHAR(100))+''''

	IF @calc_id IS NOT NULL
		SET @sql += ' AND CAST(civv.calc_id AS VARCHAR) = ''' + CAST(@calc_id AS VARCHAR(100))+''''
		
	IF @deal_id IS NOT NULL
		SET @sql += ' AND cfv.source_deal_header_id = ' + CAST(@deal_id AS VARCHAR(10))
	
	IF @reference_id IS NOT NULL
		SET @sql += ' AND sdh.deal_id = ''' + @reference_id + ''''

	IF @commodity IS NOT NULL
		SET @sql += ' AND cg.commodity = ''' + @commodity + ''''
	
		
	IF @counterparty_type IS NOT NULL
		SET @sql +=  ' AND sc.int_ext_flag = ''' + @counterparty_type + ''''
		
	IF @invoice_lock IS NOT NULL
	BEGIN
		IF  @invoice_lock ='n'
		BEGIN
			SET @sql +=  ' AND (civv.invoice_lock = ''' + @invoice_lock + ''' OR civv.invoice_lock IS NULL)'
		END
		ELSE 
		BEGIN
			SET @sql +=  ' AND civv.invoice_lock = ''' + @invoice_lock + ''''		
		END		
	END
		
	DECLARE @data_neg VARCHAR(max)
	SET @data_neg = '-'
	SET @sql += ' ORDER BY sc.source_counterparty_id, ISNULL(ng.netting_group_id, cg.contract_id), dbo.FNADateFormat(civv.as_of_date), dbo.FNADateFormat(civv.prod_date)'
	
	SET @sql += ' 
	SELECT * FROM 
				  (
					SELECT [counterparty], [contract], concat_invoice [invoice_number], [counterparty_id], [contract_id], [invoice_template], [date_from], [date_to], [settlement_date],
							CAST(CONVERT(numeric(38,2),[amount]) AS VARCHAR(50)) [amount], [currency], [calc_status], [invoice_status], [invoice_type], [lock_status], [payment_date], [calc_id], [finalized_date], 
							[invoice_note],  [invoice_status_id],[as_of_date],  [incoming_invoice_amount],  [variance],  [inv_rec_id],[invoice_ref_no],[delta], [create_date], [create_user], [update_date], [update_user],[netting_calc_id],[invoice_file_name],tc.[document_type]
					FROM #temp_calc_summary tc UNION ALL '
	
	SET @sql += '	SELECT a.[counterparty], a.[contract], CAST(a.[invoice_number] AS VARCHAR) [invoice_number], tcs1.[counterparty_id], tcs1.[contract_id], NULL [invoice_template], a.[date_from], a.[date_to], tcs1.[settlement_date], 
							CAST(a.[amount] AS VARCHAR(50)), tcs1.[currency], '''' [calc_status], '''' [invoice_status], ''Netting'' AS [invoice_type], '''' [lock_status], tcs1.[payment_date], a.[calc_id] [calc_id], '''' [finalized_date], 
							'''' [invoice_note], NULL [invoice_status_id],a.[as_of_date], NULL [incoming_invoice_amount], NULL [variance], NULL [inv_rec_id],[invoice_ref_no], NULL [delta],NULL [create_date], NULL [create_user], NULL [update_date], NULL [update_user], NULL [netting_calc_id], a.invoice_file_name [invoice_file_name],tcs1.[document_type]
					FROM #temp_calc_summary tcs1 
					INNER JOIN contract_group cg ON cg.contract_id = tcs1.contract_id 
					INNER JOIN 
						(
						SELECT [counterparty], [contract],'''+@data_neg+''' + CAST(MAX([invoice_number]) AS VARCHAR(200)) [invoice_number], [as_of_date],[date_from], [date_to], SUM(CAST([amount] AS numeric(38,2))) [amount],MAX([calc_id])*-1 [calc_id], MAX([netting_file_name]) [invoice_file_name],cs.[document_type]
						FROM #temp_calc_summary cs WHERE  [calc_status] <> ''Voided'' GROUP BY [Counterparty],[Contract],[as_of_date],[date_from], [date_to],cs.[document_type]
						) a 
						ON tcs1.calc_id = a.calc_id*-1
						WHERE cg.netting_statement = ''y''
					) ci WHERE 1 =1 '
	
	IF @invoice_type IS NOT NULL
		SET @sql +=  ' AND ci.invoice_type = ''' + CASE WHEN @invoice_type = 'i' THEN 'Invoice' WHEN @invoice_type = 'r' THEN 'Remittance' ELSE 'Netting' END + ''''
	
	SET @sql = @sql + ' ORDER BY  [counterparty], [contract],dbo.FNAClientToSqlDate([date_from]) desc'	

	
	EXEC (@sql)
END
-- charge type grid - invoice and history tab
ELSE IF @flag = 'w'
BEGIN		
	SELECT  
			civ.calc_detail_id [calc_detail_id],
			civ.manual_input [manual_input],
			civ.invoice_line_item_id [Charge Type ID],
			sd.code [charge_type],
			civ.[Value] [amount],
			sc.currency_name [currency],
			civ.Volume AS Volume,
			su.uom_id [uom],
			dbo.FNAdateformat(civ.prod_date) [prod_month],						   
			CASE WHEN civ.status = 'v' THEN 'Voided' WHEN ISNULL(civ.finalized, 'n') = 'n' THEN 'Estimate' ELSE 'Finalized' END [calc_status],
			dbo.FNADateFormat(civ.finalized_date) [Finalized Date]
	FROM calc_invoice_volume_variance civv
	INNER JOIN contract_group cg ON cg.contract_id = civv.contract_id
	INNER JOIN calc_invoice_volume civ ON  civv.calc_id = civ.calc_id
	INNER JOIN static_data_value sd ON  sd.value_id = civ.invoice_line_item_id
	LEFT JOIN source_uom su ON  su.source_uom_id = ISNULL(civ.uom_id, civv.uom)
	LEFT JOIN source_currency sc ON sc.source_currency_id = cg.currency		
	LEFT JOIN contract_group_detail cgd ON cgd.contract_id = cg.contract_id AND cgd.invoice_line_item_id = civ.invoice_line_item_id
	OUTER APPLY(
                SELECT cctd.sequence_order,
                        cctd.invoice_line_item_id
                FROM   contract_charge_type cct
                        LEFT JOIN contract_charge_type_detail cctd
                            ON  cctd.contract_charge_type_id = cct.contract_charge_type_id
                WHERE  cct.contract_charge_type_id = cg.contract_charge_type_id
                        AND cctd.invoice_line_item_id = civ.invoice_line_item_id
            ) contract_template	
	WHERE 1 = 1  
	AND civv.calc_id = @calc_id
	ORDER BY ISNULL(cgd.sequence_order,contract_template.sequence_order),civ.prod_date
END
-- history grid - first cell
ELSE IF @flag = 'h'
BEGIN
	SELECT @filter_cpty_id = civv.counterparty_id,
	       @filter_contract_id = civv.contract_id,
	       @filter_as_of_date = civv.as_of_date,
	       @filter_date_from = civv.prod_date,
	       @filter_date_to = civv.prod_date_to,
	       @invoice_template_id = ISNULL(civv.invoice_template_id,-1)
	FROM   Calc_invoice_Volume_variance civv
	WHERE  civv.calc_id = @calc_id
	
	SELECT civv.calc_id,
		   civv.invoice_number,
		   CASE 
				WHEN civv.invoice_type = 'i' THEN 'Invoice'
				WHEN civv.invoice_type = 'r' THEN 'Remittance'
		   END [invoice_type],
		   dbo.FNADateFormat(civv.as_of_date)  AS [As of Date],
		   dbo.FNADateFormat(civv.prod_date)   AS [date_from],
		   dbo.FNADateFormat(civv.prod_date_to)   AS [date_to],
		   dbo.FNADateFormat(civv.settlement_date)   AS settlement_date,
		   dbo.FNADateFormat(dbo.FNAInvoiceDueDate(civv.prod_date, cg.invoice_due_date, cg.holiday_calendar_id, cg.payment_days)) [payment_date],
		   CASE 
				WHEN [status] = 'v' THEN 'Voided'
				WHEN ISNULL(civ_status.finalized, 'n') = 'y' THEN 'Final'
				ELSE 'Estimate'
		   END [calc_status],
		   dbo.FNADateFormat(civv.finalized_date)   AS finalized_date,
		   sdv.code [invoice_status],
		   CASE WHEN invoice_lock = 'y' THEN 'Locked' ELSE 'Unlocked' END [lock_status],
		   civv.invoice_file_name
	FROM calc_invoice_volume_variance civv
	INNER JOIN contract_group cg ON cg.contract_id = civv.contract_id
	LEFT JOIN dbo.static_data_value sdv ON  sdv.value_id = civv.invoice_status
	CROSS APPLY(
		SELECT MAX(STATUS)        STATUS,
			   MAX(finalized)     finalized
		FROM   calc_invoice_volume
		WHERE  calc_id = civv.calc_id
	) civ_status
	WHERE  1 = 1 
	AND civv.counterparty_id = @filter_cpty_id AND civv.contract_id = @filter_contract_id AND civv.prod_date = @filter_date_from AND civv.prod_date_to = @filter_date_to
	AND civv.as_of_date < @filter_as_of_date
	AND ISNULL(civv.invoice_template_id,-1) = @invoice_template_id
	ORDER BY calc_id DESC
END
ELSE IF @flag = 'd'
BEGIN
	SELECT @filter_cpty_id = civv.counterparty_id,
	       @filter_contract_id = civv.contract_id,
	       @filter_as_of_date = civv.as_of_date,
	       @filter_date_from = civv.prod_date,
	       @filter_date_to = civv.prod_date_to
	FROM   Calc_invoice_Volume_variance civv
	WHERE  civv.calc_id = @calc_id
	
	SELECT dispute_id,
		   sc.counterparty_name [counterparty],
		   sd.contact_name [contract],		  
		   dbo.FNADateFormat(dispute_date_time) [dispute_date],
		   sdv.code,
		   dispute_comment [notes]
	FROM settlement_dispute sd
	INNER JOIN static_data_value sdv ON  sdv.value_id = sd.charge_type
	INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = sd.counterparty_id
	INNER JOIN contract_group cg ON  cg.contract_id = sd.contract_id 

	WHERE sd.contract_id = @filter_contract_id
		   AND sd.counterparty_id = @filter_cpty_id
		   AND sd.prod_date = @filter_date_from
		   AND sd.as_of_date = @filter_as_of_date
END
ELSE IF @flag = 't'
BEGIN
	SELECT civv.counterparty_id,
		sc.counterparty_id [counterparty],
		civv.contract_id,
		cg.source_contract_id [contract],
		civ.invoice_line_item_id,
		sdv.code [line_item],
		ISNULL(cfv.source_deal_header_id, sdd.source_deal_header_id) source_deal_header_id,
		dbo.FNAHyperLinkText(10131024, CAST(ISNULL(cfv.source_deal_header_id, sdd.source_deal_header_id) AS VARCHAR(10)) + ISNULL('(' + CAST(cfv.deal_id AS VARCHAR(10)) + ')', ''), CAST(ISNULL(cfv.source_deal_header_id, sdd.source_deal_header_id) AS VARCHAR(10))) 
		+ ' || Amount: ' + dbo.FNARemoveTrailingZeroes(ROUND(CAST(MAX(cfv.[value]) AS NUMERIC(38,20)), 2)) 
		+ ' || Volume:' + dbo.FNARemoveTrailingZeroes(ROUND(CAST(MAX(cfv.volume) AS NUMERIC(38,20)), 2))
		+ ' || Price:' + dbo.FNARemoveTrailingZeroes(ABS(ROUND(CAST(MAX(cfv.[value])/(CASE WHEN MAX(cfv.volume) = 0 THEN 1 ELSE MAX(cfv.volume) END) AS NUMERIC(38,20)),2))) [deal_id]		   
	FROM Calc_invoice_Volume_variance civv 
	INNER JOIN calc_invoice_volume civ ON civ.calc_id = civv.calc_id
	LEFT JOIN calc_formula_value AS cfv ON  civv.calc_id = cfv.calc_id AND civ.invoice_line_item_id = cfv.invoice_line_item_id AND cfv.is_final_result = 'y'
	INNER JOIN source_counterparty AS sc ON sc.source_counterparty_id = civv.counterparty_id
	INNER JOIN contract_group AS cg ON cg.contract_id = civv.contract_id
	INNER JOIN static_data_value AS sdv ON sdv.value_id = civ.invoice_line_item_id
	LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = cfv.deal_id 
 	LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = ISNULL(cfv.source_deal_header_id, sdd.source_deal_header_id) 
	WHERE  civv.calc_id = @calc_id
	GROUP BY civv.counterparty_id, sc.counterparty_id, civv.contract_id, cg.source_contract_id, civ.invoice_line_item_id, sdv.code, cfv.source_deal_header_id, cfv.deal_id, sdd.source_deal_header_id

END
ELSE IF @flag = 'u'
BEGIN
	SELECT civv.counterparty_id,
		sc.counterparty_id [counterparty],
		civv.contract_id,
		cg.source_contract_id [contract],
		'' invoice_line_item_id,
		'' line_items	   
	FROM Calc_invoice_Volume_variance civv 
	INNER JOIN source_counterparty AS sc ON sc.source_counterparty_id = civv.counterparty_id
	INNER JOIN contract_group AS cg ON cg.contract_id = civv.contract_id
	WHERE  civv.calc_id = @calc_id
	GROUP BY civv.counterparty_id, sc.counterparty_id, civv.contract_id, cg.source_contract_id
END

ELSE
IF @flag = 'y'
BEGIN	
		IF Exists (SELECT  distinct coalesce(civ.status, civ2.status), * FROM calc_invoice_volume_variance civv1
		INNER JOIN calc_invoice_volume_variance civv2 ON 
		civv1.counterparty_id = civv2.counterparty_id
		AND civv1.contract_id = civv2.contract_id
		AND civv1.prod_date = civv2.prod_date
		AND civv1.prod_date_to = civv2.prod_date_to
		INNER JOIN calc_invoice_volume civ on civ.calc_id = civv1.calc_id
		INNER JOIN calc_invoice_volume civ2 on civ2.calc_id = civv2.calc_id
		WHERE civv1.calc_id = @calc_id and (civ.status = 'v' or civ2.status = 'v'))
		SELECT 'v'
		ELSE 
		SELECT 'n'
END

-- lock/unlock invoices
ELSE IF @flag IN ('l', 'o')
BEGIN
	BEGIN TRY
		BEGIN TRAN
		EXEC sp_xml_preparedocument @idoc OUTPUT,@xml
		
		IF OBJECT_ID('tempdb..#temp_lock_unlock_invoices') IS NOT NULL
			DROP TABLE #temp_lock_unlock_invoices

		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT calc_id [calc_id],
				SUBSTRING([invoice_number], 1, ISNULL(NULLIF(CHARINDEX(' (', [invoice_number]), 0) , LEN([invoice_number]))) [invoice_number]
		INTO #temp_lock_unlock_invoices
		FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
		WITH (
			calc_id VARCHAR(10),
			[invoice_number] VARCHAR(20)
		)

		INSERT INTO #temp_lock_unlock_invoices
		SELECT 
			civv.calc_id,
			SUBSTRING(tlui.[invoice_number], 1, ISNULL(NULLIF(CHARINDEX(' (', tlui.[invoice_number]), 0) , LEN(tlui.[invoice_number]))) [invoice_number]
		FROM 
			#temp_lock_unlock_invoices tlui
			INNER JOIN Calc_invoice_Volume_variance civv ON tlui.calc_id = civv.netting_calc_id
		
		UPDATE  civv
		SET invoice_lock = CASE WHEN @flag = 'l' THEN 'y' ELSE 'n' END
		FROM calc_invoice_volume_variance civv
		INNER JOIN #temp_lock_unlock_invoices temp ON temp.calc_id = civv.calc_id		
		
		COMMIT
		
		IF @flag = 'l'
			SET @message = 'Settlements are locked sucessfully.'
		IF @flag = 'o'
			SET @message = 'Settlements are unlocked sucessfully.'
			
		EXEC spa_ErrorHandler 0,
             'Settlement History',
             'spa_settlement_history',
             'Success',
             @message,
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		IF @flag = 'l'
			SET @message = 'Fail to lock settlements.'
		IF @flag = 'o'
			SET @message = 'Fail to unlock settlements.'
				
		EXEC spa_ErrorHandler -1,
             'Settlement History',
             'spa_settlement_history',
             'DB Error',
             @message,
             ''
	END CATCH
END
ELSE IF @flag IN ('f', 'n')
BEGIN
	DECLARE @pdf_process_start_time  DATETIME 
	SET @pdf_process_start_time = GETDATE()
	BEGIN TRY
		BEGIN TRAN
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
		IF OBJECT_ID('tempdb..#temp_finalize_unfinalize_invoices') IS NOT NULL
			DROP TABLE #temp_finalize_unfinalize_invoices

		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT calc_id [calc_id],
			   finalized_date finalized_date
		INTO #temp_finalize_unfinalize_invoices
		FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
		WITH (
			calc_id VARCHAR(10),
			finalized_date DATETIME
		)
		
		INSERT INTO #temp_finalize_unfinalize_invoices
		SELECT 
			civv.calc_id,tfui.finalized_date
		FROM 
			#temp_finalize_unfinalize_invoices tfui
			INNER JOIN Calc_invoice_Volume_variance civv ON tfui.calc_id = civv.netting_calc_id

		DECLARE @alert_process_table VARCHAR(300)
			
		SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())
		SET @alert_process_table = 'adiha_process.dbo.alert_invoice_' + @process_id + '_ai'

		EXEC('CREATE TABLE ' + @alert_process_table + ' (
				calc_id				INT NOT NULL,
				counterparty_id		INT,
				contract_id			INT,
				as_of_date			DATETIME,
				invoice_date		DATETIME,
				flag				CHAR(1),
				errorcode			VARCHAR(100),
				message				NVARCHAR(4000)
				)')
				
		SET @sql = 'INSERT INTO ' + @alert_process_table + '(calc_id, counterparty_id, contract_id, as_of_date, invoice_date, flag, errorcode, message) 
					SELECT civv.calc_id, civv.counterparty_id, civv.contract_id, civv.as_of_date, civv.settlement_date, ''f'', '''', ''''
					FROM calc_invoice_volume_variance civv 
					INNER JOIN #temp_finalize_unfinalize_invoices tmp ON tmp.calc_id = civv.calc_id'
		
		EXEC(@sql)
		
		IF @flag = 'f'
		BEGIN
		-- Trigger Workflow for Event "Invoice - Pre Update" Start
		EXEC spa_register_event 20605, 20525, @alert_process_table, 0, @process_id
		
		SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @alert_process_table + ' WHERE errorcode = ''error'')
					BEGIN
						INSERT INTO #prevent_alert(errorcode,message)
						SELECT errorcode,message FROM ' +@alert_process_table + '
					END'
		EXEC(@sql)

		IF EXISTS(SELECT 1 FROM #prevent_alert WHERE errorcode = 'error')
		BEGIN
			SELECT @message = [message] FROM #prevent_alert WHERE errorcode = 'error'

			COMMIT
			
			EXEC spa_ErrorHandler -1,
				 'Settlement History',
				 'spa_settlement_history',
				 'DB Error',
				 @message,
				 ''
			
			RETURN;
		END
		-- Trigger Workflow for Event "Invoice - Pre Update" End
		END

		DECLARE @counter INT
		SELECT @counter = COUNT(1) FROM #temp_finalize_unfinalize_invoices
				
		SELECT DISTINCT tf.calc_id, tf.finalized_date, CASE WHEN cg.netting_statement = 'y' THEN 'y' ELSE 'n' END [netting_status], civv.invoice_type, cg.settlement_date, cg.holiday_calendar_id, cg.settlement_days
		INTO #temp_invoice_level_data
		FROM #temp_finalize_unfinalize_invoices tf
		INNER JOIN Calc_invoice_Volume_variance civv ON tf.calc_id = civv.calc_id
		INNER JOIN contract_group cg ON civv.contract_id = cg.contract_id
		
		-- Update Invoice Number
		EXEC spa_update_invoice_number @flag, @xml	
			
		-- 1) update of invoice level data starts
		-- 1.a) Finalized all deal level data if invoice is finalized
		UPDATE cfv
		SET finalized = CASE WHEN @flag = 'f' THEN 'y' ELSE 'n' END,
		finalized_date = CASE WHEN @flag = 'f' THEN temp.finalized_date ELSE NULL END
			--finalized_date = ISNULL(cfv.finalized_date, temp.finalized_date)
		FROM calc_formula_value cfv
		INNER JOIN #temp_invoice_level_data temp ON temp.calc_id = cfv.calc_id
		
		-- 1.b) Finalized all charge type level data if invoice is finalized
		UPDATE civ
		SET finalized = CASE WHEN @flag = 'f' THEN 'y' ELSE 'n' END,
		finalized_date = CASE WHEN @flag = 'f' THEN temp.finalized_date ELSE NULL END
			--finalized_date = ISNULL(civ.finalized_date, temp.finalized_date)
		FROM Calc_Invoice_Volume civ
		INNER JOIN #temp_invoice_level_data temp ON temp.calc_id = civ.calc_id
		
		-- 1.c) Finalized invoice
		UPDATE civv
		SET finalized = CASE WHEN @flag = 'f' THEN 'y' ELSE 'n' END,
			finalized_date = CASE WHEN @flag = 'f' THEN temp.finalized_date ELSE NULL END,
			settlement_date = dbo.FNAInvoiceDueDate( CASE WHEN temp.settlement_date = '20023'  OR temp.settlement_date = '20024' THEN CASE WHEN @flag = 'f' THEN temp.finalized_date ELSE NULL END ELSE civv.prod_date END, temp.settlement_date, temp.holiday_calendar_id, temp.settlement_days)
		FROM Calc_Invoice_Volume_variance civv
		INNER JOIN #temp_invoice_level_data temp ON temp.calc_id = civv.calc_id		
		-- 1) update of invoice level data ends	
				
		COMMIT
		
		DECLARE @message_part VARCHAR(100)
		
		IF @counter > 1
			SET @message_part = 'Settlements are '
		ELSE
			SET @message_part = 'Settlement is '
		
		IF @flag = 'f'
			SET @message = @message_part + 'finalized sucessfully.'
		IF @flag = 'n'
			SET @message = @message_part + 'unfinalized sucessfully.'
		
		
		--To Save the finalized invoice pdf in a folder
		DECLARE @netting_status CHAR(1), @c_invoice_type CHAR(1)
		DECLARE invoice_cursor CURSOR FOR 
		SELECT calc_id, netting_status, invoice_type
		FROM #temp_invoice_level_data

		OPEN invoice_cursor

		FETCH NEXT FROM invoice_cursor 
		INTO @calc_id, @netting_status,@c_invoice_type

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @flag = 'f'
			BEGIN
				EXEC spa_generate_document @document_category = 38, @document_sub_category = 42031, @filter_object_id = @calc_id, @temp_generate = 0, @get_generated = 1, @show_output = 0

				IF @netting_status = 'y' AND @c_invoice_type = 'i'
				BEGIN
					SET @calc_id = @calc_id * -1
					EXEC spa_generate_document @document_category = 38, @document_sub_category = 42047, @filter_object_id = @calc_id, @temp_generate = 0, @get_generated = 1, @show_output = 0
				END
				
			END
			ELSE
			BEGIN
				DECLARE @invoice_file_name VARCHAR(200)

				SELECT @invoice_file_name = attachment_file_name 
				FROM application_notes an WHERE internal_type_value_id = 38 AND category_value_id = 42031 AND ISNULL(parent_object_id, notes_object_id) = @calc_id

				DECLARE @file_to_delete NVARCHAR(512) = REPLACE(@report_file_path,'\\','\') + '\' + @invoice_file_name
				DECLARE @status NVARCHAR(max)
				EXEC spa_delete_file @file_to_delete, @status OUTPUT

				DELETE an FROM  application_notes an WHERE internal_type_value_id = 38 AND category_value_id = 42031 AND ISNULL(parent_object_id, notes_object_id) = @calc_id

				IF @netting_status = 'y' AND @c_invoice_type = 'i'
				BEGIN
					SELECT @invoice_file_name = attachment_file_name 
					FROM application_notes an WHERE internal_type_value_id = 38 AND category_value_id = 42047 AND ISNULL(parent_object_id, notes_object_id) = @calc_id

					SET @file_to_delete = REPLACE(@report_file_path,'\\','\') + '\' + @invoice_file_name
					EXEC spa_delete_file @file_to_delete, @status OUTPUT

					DELETE an FROM  application_notes an WHERE internal_type_value_id = 38 AND category_value_id = 42047 AND ISNULL(parent_object_id, notes_object_id) = @calc_id
				END
			END

			FETCH NEXT FROM invoice_cursor 
			INTO @calc_id,@netting_status,@c_invoice_type
		END

		CLOSE invoice_cursor
		DEALLOCATE invoice_cursor		
		
		-- Invoice pdf creation failed
		IF OBJECT_ID('tempdb..#invoice_creation_failed') IS NOT NULL
			DROP TABLE tempdb..#invoice_creation_failed
				
		CREATE TABLE #invoice_creation_failed (calc_id INT )
		
		INSERT INTO #invoice_creation_failed(calc_id)
		SELECT DISTINCT tmp.calc_id FROM #temp_invoice_level_data tmp
		LEFT JOIN application_notes an ON tmp.calc_id = ISNULL(parent_object_id, notes_object_id) AND internal_type_value_id = 38 AND category_value_id = 42031
		WHERE an.notes_id IS NULL
		
		UPDATE cfv
		SET finalized = 'n',
		finalized_date = NULL
		--finalized_date = ISNULL(cfv.finalized_date, temp.finalized_date)
		FROM calc_formula_value cfv
		INNER JOIN #temp_invoice_level_data temp ON temp.calc_id = cfv.calc_id
		INNER JOIN #invoice_creation_failed icf ON cfv.calc_id = icf.calc_id
		-- 1.b) UnFinalized all charge type level data if invoice is finalized
		UPDATE civ
		SET finalized = 'n',
		finalized_date = NULL			
		FROM Calc_Invoice_Volume civ
		INNER JOIN #temp_invoice_level_data temp ON temp.calc_id = civ.calc_id
		INNER JOIN #invoice_creation_failed icf ON civ.calc_id = icf.calc_id		
		-- 1.c) UnFinalized invoice
		UPDATE civv
		SET finalized = 'n',
			finalized_date = NULL,
			settlement_date = dbo.FNAInvoiceDueDate( CASE WHEN temp.settlement_date = '20023'  OR temp.settlement_date = '20024' THEN NULL ELSE civv.prod_date END, temp.settlement_date, temp.holiday_calendar_id, temp.settlement_days),
			invoice_number = civv.calc_id			
		FROM Calc_Invoice_Volume_variance civv
		INNER JOIN #temp_invoice_level_data temp ON temp.calc_id = civv.calc_id
		INNER JOIN #invoice_creation_failed icf ON civv.calc_id = icf.calc_id	
		
		UPDATE citu SET citu.invoice_number = icf.calc_id  FROM calc_invoice_true_up citu
		INNER JOIN #invoice_creation_failed icf ON citu.calc_id = icf.calc_id
		
		SET @alert_process_table = 'adiha_process.dbo.alert_invoice_' + @process_id 

		--PRINT('CREATE TABLE ' + @alert_process_table + '(calc_id INT NOT NULL, invoice_number INT NOT NULL, invoice_status INT NOT NULL)')
		EXEC('CREATE TABLE ' + @alert_process_table + ' (
				calc_id         INT NOT NULL,
				invoice_number  VARCHAR(250) NOT NULL,
				invoice_status  INT,
				counterparty	VARCHAR(100),
				contract	VARCHAR(100),
				Prod_month	VARCHAR(100),
				hyperlink1             VARCHAR(5000),
				hyperlink2             VARCHAR(5000),
				hyperlink3             VARCHAR(5000),
				hyperlink4             VARCHAR(5000),
				hyperlink5             VARCHAR(5000)
				)')
		
		SET @sql = 'INSERT INTO ' + @alert_process_table + '(calc_id, invoice_number, invoice_status,counterparty,contract,Prod_month) 
					SELECT civv.calc_id,
							civv.invoice_number,
							civv.invoice_status,
							sc.counterparty_name counterparty,
							cg.contract_name contract,
							dbo.FNADATEFORMAT(civv.prod_date) Prod_month
					FROM calc_invoice_volume_variance civv 
					INNER JOIN #temp_invoice_level_data tmp ON tmp.calc_id = civv.calc_id 
					LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = civv.counterparty_id
					LEFT JOIN contract_group cg ON cg.contract_id = civv.contract_id'


		--PRINT(@sql)
		EXEC(@sql)
		EXEC spa_register_event 20605, 20512, @alert_process_table, 0, @process_id
		
		IF @flag = 'f'
		BEGIN
			DECLARE @msg VARCHAR(500),@url_name VARCHAR(5000), @total_time_for_pdf_process VARCHAR(200)
			SET @url_name = './dev/spa_html.php?__user_name__=''' + @user_name + '''&spa=exec spa_get_settlement_invoice_log ''' + @batch_process_id + ''''
			SET @msg = '<a target="_blank" href="' + @url_name + '">' + 'Process to create invoice PDFs has been completed.</a>'
			 
			IF EXISTS (SELECT 1 FROM process_settlement_invoice_log psil WHERE psil.process_id = @batch_process_id AND psil.code <> 'Success')
				SET @msg = '<a target="_blank" href="' + @url_name + '">' + 'Process to create invoice PDFs has been completed <font color="red"><b>(with errors)</b></font>.</a>'
			
			--SET @total_time_for_pdf_process = CAST(DATEPART(mi,getdate()- @pdf_process_start_time ) AS VARCHAR)+ ' min '+ CAST(DATEPART(s,getdate()- @pdf_process_start_time) AS VARCHAR)+' sec'
			SET @total_time_for_pdf_process = dbo.FNAFindDateDifference(@pdf_process_start_time)
			SET @msg += '(Elapsed Time: ' + @total_time_for_pdf_process + ')'
			EXEC spa_message_board 'i',@user_name,NULL,' Invoice Process',@msg,'','','',NULL ,NULL,@batch_process_id
		END
			
		EXEC spa_ErrorHandler 0,
             'Settlement History',
             'spa_settlement_history',
             'Success',
             @message,
             ''
	       Return

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		IF @flag = 'f'
			SET @message = 'Fail to finalize settlement.'
		IF @flag = 'n'
			SET @message = 'Fail to unfinalize settlement.'
				
		EXEC spa_ErrorHandler -1,
             'Settlement History',
             'spa_settlement_history',
             'DB Error',
             @message,
             ''
	END CATCH
END
ELSE IF @flag = 'e'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT,@xml
			
		IF OBJECT_ID('tempdb..#temp_delete_invoices') IS NOT NULL
			DROP TABLE #temp_delete_invoices
			
		CREATE TABLE #temp_delete_invoices (calc_id INT, [invoice_number] VARCHAR(50) COLLATE DATABASE_DEFAULT, finalized CHAR(1) COLLATE DATABASE_DEFAULT, locked CHAR(1) COLLATE DATABASE_DEFAULT)

		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		INSERT INTO #temp_delete_invoices (calc_id, invoice_number)
		SELECT calc_id [calc_id],
				SUBSTRING([invoice_number], 1, ISNULL(NULLIF(CHARINDEX(' (', [invoice_number]), 0) , LEN([invoice_number]))) [invoice_number]			
		FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
		WITH (
			calc_id VARCHAR(10),
			[invoice_number] VARCHAR(20)
		)


		INSERT INTO #temp_delete_invoices (calc_id, invoice_number)
		SELECT 
			civv.calc_id,civv.invoice_number
		FROM 
			#temp_delete_invoices tdi
			INNER JOIN Calc_invoice_Volume_variance civv ON tdi.calc_id = civv.netting_calc_id
		
		--INSERT INTO #temp_delete_invoices (calc_id, invoice_number)
		--SELECT civv.calc_id, civv.invoice_number
		--FROM #temp_delete_invoices temp
		----INNER JOIN Calc_Invoice_Volume_variance civv ON civv.original_invoice = temp.[invoice_number]
		--INNER JOIN Calc_Invoice_Volume_variance civv ON civv.[calc_id] = temp.[calc_id]


		
		UPDATE temp
		SET finalized = COALESCE(cfv.finalized, civ.finalized, civv.finalized)
		FROM #temp_delete_invoices temp 
		OUTER APPLY(SELECT MAX(finalized) finalized  FROM calc_formula_value WHERE finalized = 'y' AND  calc_id = temp.calc_id ) cfv
		OUTER APPLY(SELECT MAX(finalized) finalized FROM calc_invoice_volume  WHERE finalized = 'y' AND ISNULL(status,'') <> 'v' AND calc_id = temp.calc_id) civ
		LEFT JOIN Calc_Invoice_Volume_variance civv ON civv.calc_id = temp.calc_id AND civv.finalized = 'y'
		WHERE
			COALESCE(cfv.finalized,civ.finalized,civv.finalized) IS NOT NULL

		IF EXISTS(SELECT 1 FROM #temp_delete_invoices WHERE finalized = 'y')
		BEGIN
			DECLARE @finalized_invoices VARCHAR(MAX)
			SELECT @finalized_invoices = COALESCE(@finalized_invoices + ', ', '') + CAST([invoice_number] AS VARCHAR(20))
			FROM #temp_delete_invoices
				
			SET @message = 'Settlement is already finalized for one or more invoice(s). Please unfinalize first. Finalized Invoices  - ' + @finalized_invoices
				
			EXEC spa_ErrorHandler -1,
				    'Invoice Deletion.',
				    'spa_settlement_history',
				    'Error',
				    @message,
				    ''
			RETURN
		END
		
		UPDATE temp
		SET locked = civv.invoice_lock
		FROM #temp_delete_invoices temp 
		INNER JOIN Calc_Invoice_Volume_variance civv ON civv.calc_id = temp.calc_id AND ISNULL(civv.invoice_lock, 'n') = 'y'
		
		IF EXISTS(SELECT 1 FROM #temp_delete_invoices WHERE locked = 'y')
		BEGIN
			DECLARE @locked_invoices VARCHAR(MAX)
			SELECT @locked_invoices = COALESCE(@locked_invoices + ', ', '') + CAST([invoice_number] AS VARCHAR(20))
			FROM #temp_delete_invoices
				
			SET @message = 'Settlement is already locked for selected invoice(s). Please unlock first. Finalized Invoices - ' + @locked_invoices
				
			EXEC spa_ErrorHandler -1,
				    'Invoice Deletion.',
				    'spa_settlement_history',
				    'Error',
				    @message,
				    ''
			RETURN
		END
		
		
		BEGIN TRAN
		
		IF OBJECT_ID('tempdb..#split_invoice') IS NOT NULL
			DROP TABLE #split_invoice	
			
		CREATE TABLE #split_invoice(calc_id INT,invoice_line_item_id INT, VALUE FLOAT, volume FLOAT, is_final_result CHAR(1) COLLATE DATABASE_DEFAULT)

		INSERT INTO calc_formula_value (
			invoice_line_item_id, seq_number, prod_date, [value], contract_id,
			counterparty_id, formula_id, calc_id, hour, formula_str, qtr,
			half, deal_type_id, generator_id, ems_generator_id, deal_id,
			volume, formula_str_eval, commodity_id, granularity, is_final_result,
			is_dst, source_deal_header_id, allocation_volume, counterparty_limit_id, finalized
		)
		OUTPUT INSERTED.calc_id,INSERTED.invoice_line_item_id,INSERTED.[value], INSERTED.volume, INSERTED.is_final_result
		INTO #split_invoice(calc_id,invoice_line_item_id, value, volume,is_final_result)
		SELECT 
			invoice_line_item_id, seq_number, civv.prod_date, [value], civv.contract_id,
			civv.counterparty_id, cfv.formula_id, civv.original_invoice, cfv.[hour], cfv.formula_str, cfv.qtr,
			cfv.half, cfv.deal_type_id, civv.generator_id, cfv.ems_generator_id, cfv.deal_id,
			cfv.volume, cfv.formula_str_eval, cfv.commodity_id, cfv.granularity, cfv.is_final_result,
			cfv.is_dst, cfv.source_deal_header_id, cfv.allocation_volume, cfv.counterparty_limit_id, 'n'
		FROM 
			#temp_delete_invoices temp
			INNER JOIN calc_invoice_volume_variance civv ON civv.calc_id = temp.calc_id
			INNER JOIN calc_formula_value cfv ON cfv.calc_id = temp.calc_id
		WHERE
			civv.original_invoice IS NOT NULL

		--UPDATE si SET si.split_calc_id= civv.calc_id
		--FROM 
		--	#split_invoice si
		--	INNER JOIN calc_invoice_volume_variance civv ON civv.original_invoice = si.calc_id

		DELETE id
			FROM #temp_delete_invoices temp 
			INNER JOIN Calc_Invoice_Volume_variance civv ON civv.calc_id = temp.calc_id
			INNER JOIN invoice_header ih 
				ON  ih.counterparty_id = civv.counterparty_id
			    AND ih.Production_month = civv.prod_date
			    AND ih.contract_id = civv.contract_id
			INNER JOIN invoice_detail id ON  id.invoice_id = ih.invoice_id
			CROSS APPLY(
			    SELECT MAX([status]) [status],
			           MAX(finalized) finalized
			    FROM calc_invoice_volume
			    WHERE calc_id = civv.calc_id
			) civ_status
			WHERE ISNULL(civ_status.[status], '') <> 'v'
			
			DELETE ih
			FROM #temp_delete_invoices temp 
			INNER JOIN Calc_Invoice_Volume_variance civv ON civv.calc_id = temp.calc_id
			INNER JOIN invoice_header ih 
				ON  ih.counterparty_id = civv.counterparty_id
			    AND ih.Production_month = civv.prod_date
			    AND ih.contract_id = civv.contract_id
			CROSS APPLY(
			    SELECT MAX([status]) [status],
			           MAX(finalized) finalized
			    FROM calc_invoice_volume
			    WHERE calc_id = civv.calc_id
			) civ_status
			WHERE ISNULL(civ_status.[status], '') <> 'v'
			
			DELETE cfv
			FROM calc_formula_value cfv 
			INNER JOIN #temp_delete_invoices temp ON cfv.calc_id = temp.calc_id
			
			DELETE civ
			FROM calc_invoice_volume civ 
			INNER JOIN #temp_delete_invoices temp ON civ.calc_id = temp.calc_id
			
			DELETE civv
			FROM calc_invoice_volume_variance civv 
			INNER JOIN #temp_delete_invoices temp ON civv.calc_id = temp.calc_id
			
			DELETE sa
			FROM settlement_adjustments sa 
			INNER JOIN #temp_delete_invoices temp ON sa.calc_id = temp.calc_id
			
			DELETE citu
			FROM calc_invoice_true_up citu 
			INNER JOIN #temp_delete_invoices temp ON citu.calc_id = temp.calc_id

			DELETE an FROM application_notes an 
			INNER JOIN #temp_delete_invoices temp ON ISNULL(an.parent_object_id, an.notes_object_id) = temp.calc_id
			WHERE an.internal_type_value_id = 38	

			UPDATE email_notes SET notes_object_id = NULL 			
			FROM email_notes en
			INNER JOIN #temp_delete_invoices temp ON  en.notes_object_id = temp.calc_id
			WHERE en.internal_type_value_id = 38

			UPDATE civ set civ.value= civ.value+a.[value],civ.volume = civ.volume+a.[volume]
			FROM 
				calc_invoice_volume civ 
				CROSS APPLY (
					SELECT SUM([value]) [value], SUM(volume) volume,calc_id,invoice_line_item_id FROM #split_invoice AS temp
					WHERE temp.calc_id = civ.calc_id AND temp.invoice_line_item_id = civ.invoice_line_item_id AND is_final_result = 'y' GROUP BY calc_id,invoice_line_item_id
				) a
			WHERE
				a.calc_id = civ.calc_id
				AND a.invoice_line_item_id = civ.invoice_line_item_id
		
		COMMIT
		
		EXEC spa_ErrorHandler 0,
			'Invoice Deletion.',
			'spa_settlement_history',
			'Success',
			'Changes have been saved successfully.',
			''
	END TRY
	BEGIN CATCH 
		IF @@TRANCOUNT > 0
		   ROLLBACK
 
		EXEC spa_ErrorHandler -1,
			'Invoice Deletion.',
			'spa_settlement_history',
			'Success',
			'Invoice Deleted Failed.',
			''
			
	END CATCH	
END
ELSE IF @flag = 'r'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
		IF OBJECT_ID('tempdb..#temp_invoices_for_update') IS NOT NULL
			DROP TABLE #temp_invoices_for_update

		CREATE TABLE #temp_invoices_for_update (calc_id INT, [invoice_number] VARCHAR(20) COLLATE DATABASE_DEFAULT)
		
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		INSERT INTO #temp_invoices_for_update(calc_id, invoice_number)
		SELECT calc_id [calc_id],
			   SUBSTRING([invoice_number], 1, ISNULL(NULLIF(CHARINDEX(' (', [invoice_number]), 0) , LEN([invoice_number]))) [invoice_number]
		FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
		WITH (
			calc_id VARCHAR(10),
			[invoice_number] VARCHAR(20)
		)
			
		SET @process_id = ISNULL(@process_id, dbo.FNAGetNewID())
		
		IF @invoice_status = 20710
		BEGIN
			SET @alert_process_table = 'adiha_process.dbo.alert_invoice_' + @process_id + '_output'

			EXEC('CREATE TABLE ' + @alert_process_table + ' (
					calc_id				INT NOT NULL,
					counterparty_id		INT,
					contract_id			INT,
					as_of_date			DATETIME,
					invoice_date		DATETIME,
					flag				CHAR(1),
					errorcode			VARCHAR(100),
					message				NVARCHAR(4000)
					)')
				
			SET @sql = 'INSERT INTO ' + @alert_process_table + '(calc_id, counterparty_id, contract_id, as_of_date, invoice_date, flag, errorcode, message) 
						SELECT civv.calc_id, civv.counterparty_id, civv.contract_id, civv.as_of_date, civv.settlement_date, ''e'', '''', ''''
						FROM calc_invoice_volume_variance civv 
						INNER JOIN #temp_invoices_for_update tmp ON tmp.calc_id = civv.calc_id'
		
			EXEC(@sql)
		
			-- Trigger Workflow for Event "Invoice - Pre Update" Start
			EXEC spa_register_event 20605, 20525, @alert_process_table, 0, @process_id
		
			SET @sql = 'IF EXISTS(SELECT 1 FROM ' + @alert_process_table + ' WHERE errorcode = ''error'')
						BEGIN
							INSERT INTO #prevent_alert(errorcode,message)
							SELECT errorcode,message FROM ' +@alert_process_table + '
						END'
			EXEC(@sql)

			IF EXISTS(SELECT 1 FROM #prevent_alert WHERE errorcode = 'error')
			BEGIN
				SELECT @message = [message] FROM #prevent_alert WHERE errorcode = 'error'

				COMMIT
			
				EXEC spa_ErrorHandler -1,
					 'Settlement History',
					 'spa_settlement_history',
					 'DB Error',
					 @message,
					 ''
			
				RETURN;
			END
			-- Trigger Workflow for Event "Invoice - Pre Update" End
		END	

		UPDATE  civv
		SET civv.invoice_status = @invoice_status
		FROM Calc_invoice_Volume_variance civv
		INNER JOIN #temp_invoices_for_update tmp ON tmp.calc_id = civv.calc_id			
	
		UPDATE  civv
		SET civv.status_id = @invoice_status
		FROM counterpartyt_netting_stmt_status civv
		INNER JOIN #temp_invoices_for_update tmp ON tmp.calc_id = civv.calc_id			
	
		INSERT INTO counterpartyt_netting_stmt_status(calc_id, status_id) 
		SELECT tmp.calc_id, @invoice_status
		FROM #temp_invoices_for_update tmp
		LEFT JOIN counterpartyt_netting_stmt_status civv ON civv.calc_id = tmp.calc_id
		WHERE civv.calc_id IS NULL
		
		
		COMMIT 
		
		-- alert call
			
		SET @alert_process_table = 'adiha_process.dbo.alert_invoice_' + @process_id + '_ai'

		--PRINT('CREATE TABLE ' + @alert_process_table + '(calc_id INT NOT NULL, invoice_number INT NOT NULL, invoice_status INT NOT NULL)')
		EXEC('CREATE TABLE ' + @alert_process_table + ' (
				calc_id         INT NOT NULL,
				invoice_number  VARCHAR(20) NOT NULL,
				invoice_status  INT,
				counterparty	NVARCHAR(100),
				contract	NVARCHAR(100),
				Prod_month	NVARCHAR(100),
				hyperlink1             VARCHAR(5000),
				hyperlink2             VARCHAR(5000),
				hyperlink3             VARCHAR(5000),
				hyperlink4             VARCHAR(5000),
				hyperlink5             VARCHAR(5000)
				)')
				
		SET @sql = 'INSERT INTO ' + @alert_process_table + '(calc_id, invoice_number, invoice_status,counterparty,contract,Prod_month) 
					SELECT civv.calc_id,
							civv.invoice_number,
							civv.invoice_status,
							sc.counterparty_name counterparty,
							cg.contract_name contract,
							dbo.FNADATEFORMAT(civv.prod_date) Prod_month
					FROM calc_invoice_volume_variance civv 
					INNER JOIN #temp_invoices_for_update tmp ON tmp.calc_id = civv.calc_id 
					LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = civv.counterparty_id
					LEFT JOIN contract_group cg ON cg.contract_id = civv.contract_id'


		--PRINT(@sql)
		EXEC(@sql)		
		EXEC spa_register_event 20605, 20512, @alert_process_table, 1, @process_id
		
		IF OBJECT_ID('tempdb..#temp_invoices_for_update') IS NOT NULL
			DROP TABLE #temp_invoices_for_update
		
		
			
		EXEC spa_ErrorHandler 0,
				'Calc_invoice_Volume_variance',
				'spa_settlement_history',
				'Success',
				'Invoice status has been updated successfully.',
				''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
             'Settlement History',
             'spa_settlement_history',
             'DB Error',
             'Failed to update invoice status.',
             ''
	END CATCH
END

ELSE IF @flag = 'm'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
	IF OBJECT_ID('tempdb..#temp_invoice_for_update') IS NOT NULL
		DROP TABLE #temp_invoice_for_update

	-- Execute a SELECT statement that uses the OPENXML rowset provider.
	SELECT calc_id [calc_id],
			invoice_status [invoice_status],
			lock_status [lock_status],
			invoice_note [invoice_note],
			settlement_date [settlement_date],
			payment_date [payment_date]
	INTO #temp_invoice_for_update
	FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
	WITH (
		calc_id INT,
		invoice_status INT,
		lock_status CHAR(1),
		invoice_note VARCHAR(100),
		settlement_date DATE,
		payment_date DATE
	)
	
	UPDATE civv
		SET invoice_status = temp.invoice_status,
	       invoice_lock = temp.lock_status,
	       invoice_note = temp.invoice_note,
	       settlement_date = temp.settlement_date,
	       payment_date = temp.payment_date
		FROM Calc_invoice_Volume_variance civv
		INNER JOIN #temp_invoice_for_update temp ON temp.calc_id = civv.calc_id
			
	IF @@Error <> 0
	    EXEC spa_ErrorHandler @@Error,
	         'Calc_invoice_Volume_variance',
	         'spa_settlement_history',
	         'DB Error',
	         'Failed to update Invoice.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'Calc_invoice_Volume_variance',
	         'spa_settlement_history',
	         'Success',
	         'Changes have been saved successfully.',
	         ''
END

ELSE IF @flag = 'a'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
	IF OBJECT_ID('tempdb..#temp_dispute_for_insert') IS NOT NULL
		DROP TABLE #temp_dispute_for_insert

	-- Execute a SELECT statement that uses the OPENXML rowset provider.
	SELECT contact_name [contact_name],
			dispute_date_time [dispute_date_time],
			charge_type [charge_type],
			dispute_comment [dispute_comment],
			counterparty_id [counterparty_id],
			contract_id [contract_id],
			billing_period [billing_period],
			as_of_date [as_of_date],
			dispute_user [dispute_user],
			prod_date [prod_date]
	INTO #temp_dispute_for_insert
	FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
	WITH (
		contact_name VARCHAR(10),
		dispute_date_time DATETIME,
		charge_type INT,
		dispute_comment VARCHAR(4000),
		counterparty_id INT,
		contract_id INT,
		billing_period DATE,
		as_of_date DATE,
		dispute_user VARCHAR(100),
		prod_date DATE
	)
	
	DECLARE @chk_invoice_line_item_id1 INT
	
	SELECT TOP 1 @filter_cpty_id = tmp.counterparty_id,
	       @filter_contract_id = tmp.contract_id,
	       @filter_as_of_date = tmp.as_of_date,
	       @filter_date_from = tmp.prod_date,
		   @chk_invoice_line_item_id1 = tmp.charge_type
	FROM   #temp_dispute_for_insert tmp
	
	IF EXISTS (SELECT 1
					FROM settlement_dispute sd
					INNER JOIN static_data_value sdv ON  sdv.value_id = sd.charge_type
					INNER JOIN source_counterparty sc ON  sc.source_counterparty_id = sd.counterparty_id
					INNER JOIN contract_group cg ON  cg.contract_id = sd.contract_id 
					WHERE sd.contract_id = @filter_contract_id
						   AND sd.counterparty_id = @filter_cpty_id
						   AND sd.prod_date = @filter_date_from
						   AND sd.as_of_date = @filter_as_of_date
						   AND sd.charge_type = @chk_invoice_line_item_id1)
	BEGIN
		EXEC spa_ErrorHandler 0, 'calc invoice Volume', 
			'spa_settlement_history', 'Error', 
			'Duplicate Charge Type.',''	
	END
	ELSE 
	BEGIN
		INSERT INTO settlement_dispute
		  (
			billing_period,
			dispute_date_time,
			dispute_user,
			dispute_comment,
			contract_id,
			counterparty_id,
			prod_date,
			as_of_date,
			charge_type,
			contact_name
		  )
		SELECT tmp.billing_period, 
			tmp.dispute_date_time,
			tmp.dispute_user,
			tmp.dispute_comment,
			tmp.contract_id,
			tmp.counterparty_id,
			tmp.prod_date,
			tmp.as_of_date,
			tmp.charge_type,
			tmp.contact_name
		FROM #temp_dispute_for_insert tmp
	
		DECLARE @new_dispute_id INT
		SET @new_dispute_id = SCOPE_IDENTITY()

		IF @@Error <> 0
			EXEC spa_ErrorHandler @@Error,
				 'settlement_dispute',
				 'spa_settlement_history',
				 'DB Error',
				 'Failed to insert Settlement dispute.',
				 ''
		ELSE
			EXEC spa_ErrorHandler 0,
				 'settlement_dispute',
				 'spa_settlement_history',
				 'Success',
				 'Settlement dispute inserted successfully.',
				 @new_dispute_id
	END
END

ELSE IF @flag = 'b'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
	IF OBJECT_ID('tempdb..#temp_dispute_for_update') IS NOT NULL
		DROP TABLE #temp_dispute_for_update

	-- Execute a SELECT statement that uses the OPENXML rowset provider.
	SELECT dispute_id [dispute_id],
			contact_name [contact_name],
			dispute_date_time [dispute_date_time],
			charge_type [charge_type],
			dispute_comment [dispute_comment],
			counterparty_id [counterparty_id],
			contract_id [contract_id],
			billing_period [billing_period],
			as_of_date [as_of_date],
			dispute_user [dispute_user],
			prod_date [prod_date]
	INTO #temp_dispute_for_update
	FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
	WITH (
		dispute_id INT,
		contact_name VARCHAR(100),
		dispute_date_time DATETIME,
		charge_type INT,
		dispute_comment VARCHAR(4000),
		counterparty_id INT,
		contract_id INT,
		billing_period DATE,
		as_of_date DATE,
		dispute_user VARCHAR(100),
		prod_date DATE
	)
	
	UPDATE sd
		SET billing_period = temp.billing_period,
	       dispute_date_time = temp.dispute_date_time,
	       dispute_user = temp.dispute_user,
	       dispute_comment = temp.dispute_comment,
	       contract_id = temp.contract_id,
	       counterparty_id = temp.counterparty_id,
	       prod_date = temp.prod_date,
	       as_of_date = temp.as_of_date,
	       charge_type = temp.charge_type,
	       contact_name = temp.contact_name
		FROM settlement_dispute sd
		INNER JOIN #temp_dispute_for_update temp ON temp.dispute_id = sd.dispute_id
			
	IF @@Error <> 0
	    EXEC spa_ErrorHandler @@Error,
	         'settlement_dispute',
	         'spa_settlement_history',
	         'DB Error',
	         'Failed to update Settlement dispute.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'settlement_dispute',
	         'spa_settlement_history',
	         'Success',
	         'Settlement dispute updated successfully.',
	         ''
END

ELSE IF @flag = 'c'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
	IF OBJECT_ID('tempdb..#temp_dispute_for_delete') IS NOT NULL
		DROP TABLE #temp_dispute_for_delete

	CREATE TABLE #temp_dispute_for_delete (dispute_id INT)
		
	-- Execute a SELECT statement that uses the OPENXML rowset provider.
	INSERT INTO #temp_dispute_for_delete(dispute_id)
	SELECT dispute_id [dispute_id]
	FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
	WITH (
		dispute_id VARCHAR(10)
	)
	
	DELETE sd FROM settlement_dispute sd
	INNER JOIN #temp_dispute_for_delete tmp ON tmp.dispute_id = sd.dispute_id
	
	IF @@Error <> 0
	    EXEC spa_ErrorHandler @@Error,
	         'settlement_dispute',
	         'spa_settlement_history',
	         'DB Error',
	         'Failed to delete Settlement dispute.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'settlement_dispute',
	         'spa_settlement_history',
	         'Success',
	         'Settlement dispute deleted successfully.',
	         ''
END

ELSE IF @flag='x'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
	IF OBJECT_ID('tempdb..#temp_manual_line_items_for_insert') IS NOT NULL
		DROP TABLE #temp_manual_line_items_for_insert
	
	-- Execute a SELECT statement that uses the OPENXML rowset provider.
	SELECT calc_id [calc_id],
			invoice_line_item_id [invoice_line_item_id],
			prod_date [prod_date],
			value [value],
			volume [volume],
			default_gl_id [default_gl_id],
			uom_id [uom_id],
			remarks [remarks],
			inv_prod_date [inv_prod_date],
			include_volume [include_volume],
			inventory [inventory]
	INTO #temp_manual_line_items_for_insert
	FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
	WITH (
		calc_id INT,
		invoice_line_item_id INT,
		prod_date DATETIME,
		value FLOAT,
		volume FLOAT,
		default_gl_id INT,
		uom_id INT,
		remarks VARCHAR(100),
		inv_prod_date DATETIME,
		include_volume CHAR(1),
		inventory CHAR(1)
	)
	
	DECLARE @chk_calc_id INT
	DECLARE @chk_invoice_line_item_id INT
	
	SELECT @chk_calc_id = calc_id, @chk_invoice_line_item_id = invoice_line_item_id FROM #temp_manual_line_items_for_insert

	IF EXISTS (SELECT 1 FROM calc_invoice_volume civ WHERE civ.calc_id = @chk_calc_id AND invoice_line_item_id = @chk_invoice_line_item_id)
	BEGIN
		EXEC spa_ErrorHandler 0, 'calc invoice Volume', 
			'spa_settlement_history', 'Error', 
			'Duplicate Charge Type.',''	
	END
	ELSE 
	BEGIN
		INSERT INTO calc_invoice_volume(
					calc_id,
					invoice_line_item_id,
					prod_date,
					value,
					manual_input,
					volume,
					default_gl_id,
					uom_id,
					remarks,
					finalized,
					finalized_id,
					inv_prod_date,
					include_volume,
					inventory
				)
		SELECT
				temp.calc_id,
				temp.invoice_line_item_id,
				dbo.fnagetcontractmonth(temp.prod_date),
				temp.value,
				'y',	
				temp.volume,
				temp.default_gl_id,--ISNULL(@default_gl_id,@default_gl_id_new),
				temp.uom_id,
				temp.remarks,
				'n',
				NULL,
				dbo.fnagetcontractmonth(temp.inv_prod_date),
				temp.include_volume,
				temp.inventory
		FROM #temp_manual_line_items_for_insert temp

		DECLARE @new_calc_detail_id INT
		SET @new_calc_detail_id = SCOPE_IDENTITY()

		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, "calc invoice Volume", 
			"spa_settlement_history", "DB Error", 
			"Error  Inserting Data.", ''
		ELSE
			EXEC spa_ErrorHandler 0, 'calc invoice Volume', 
			'spa_settlement_history', 'Success', 
			'Data Inserted Successfully.',@new_calc_detail_id
	END
END

ELSE IF @flag='y'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
	IF OBJECT_ID('tempdb..#temp_manual_line_items_for_update') IS NOT NULL
		DROP TABLE #temp_manual_line_items_for_update
	
	-- Execute a SELECT statement that uses the OPENXML rowset provider.
	SELECT calc_detail_id [calc_detail_id],
			invoice_line_item_id [invoice_line_item_id],
			prod_date [prod_date],
			value [value],
			volume [volume],
			default_gl_id [default_gl_id],
			uom_id [uom_id],
			remarks [remarks],
			inv_prod_date [inv_prod_date],
			include_volume [include_volume],
			inventory [inventory]
	INTO #temp_manual_line_items_for_update
	FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
	WITH (
		calc_detail_id INT,
		invoice_line_item_id INT,
		prod_date DATETIME,
		value FLOAT,
		volume FLOAT,
		default_gl_id INT,
		uom_id INT,
		remarks VARCHAR(100),
		inv_prod_date DATE,
		include_volume CHAR(1),
		inventory CHAR(1)
	)
	IF EXISTS (SELECT 1 FROM calc_invoice_volume civ WHERE civ.calc_id = @chk_calc_id AND invoice_line_item_id = @chk_invoice_line_item_id)
	BEGIN
		EXEC spa_ErrorHandler 0, 'calc invoice Volume', 
			'spa_settlement_history', 'Error', 
			'Duplicate Charge Type.',''	
	END
	ELSE 
	BEGIN
		UPDATE civ
			SET 
				invoice_line_item_id = temp.invoice_line_item_id,
				prod_date = dbo.fnagetcontractmonth(temp.prod_date),
				value = temp.value,
				volume = temp.volume,
				default_gl_id = temp.default_gl_id,
				uom_id = temp.uom_id,
				remarks = temp.remarks,
				inv_prod_date = dbo.fnagetcontractmonth(temp.inv_prod_date),
				include_volume = temp.include_volume,
				inventory = temp.inventory
			FROM calc_invoice_volume civ
				INNER JOIN #temp_manual_line_items_for_update temp ON temp.calc_detail_id = civ.calc_detail_id

		IF @@ERROR <> 0
			EXEC spa_ErrorHandler @@ERROR, "calc invoice Volume", 
			"spa_settlement_history", "DB Error", 
			"Error  Updating Data.", ''
		ELSE
			EXEC spa_ErrorHandler 0, 'calc invoice Volume', 
			'spa_settlement_history', 'Success', 
			'Data Updated Successfully.',''
	END
END

ELSE IF @flag = 'z'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
	IF OBJECT_ID('tempdb..#temp_manual_line_items_for_delete') IS NOT NULL
		DROP TABLE #temp_manual_line_items_for_delete

	CREATE TABLE #temp_manual_line_items_for_delete (calc_detail_id INT)
		
	-- Execute a SELECT statement that uses the OPENXML rowset provider.
	INSERT INTO #temp_manual_line_items_for_delete(calc_detail_id)
	SELECT calc_detail_id [calc_detail_id]
	FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
	WITH (
		calc_detail_id INT
	)
	
	DELETE civ FROM calc_invoice_volume civ
	INNER JOIN #temp_manual_line_items_for_delete tmp ON tmp.calc_detail_id = civ.calc_detail_id
	
	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, "calc invoice Volume", 
		"spa_settlement_history", "DB Error", 
		"Error  Deleting Data.", ''
	ELSE
		EXEC spa_ErrorHandler 0, 'calc invoice Volume', 
		'spa_settlement_history', 'Success', 
		'Data Deleted Successfully.',''
END

ELSE IF @flag IN ('j', 'k')
BEGIN
	BEGIN TRY
		BEGIN TRAN
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
		IF OBJECT_ID('tempdb..#temp_finalize_unfinalize_charge_type') IS NOT NULL
			DROP TABLE #temp_finalize_unfinalize_charge_type

		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT calc_id [calc_id],
			   finalized_date [finalized_date],
			   invoice_line_item_id [invoice_line_item_id]
		INTO #temp_finalize_unfinalize_charge_type
		FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
		WITH (
			calc_id VARCHAR(10),
			finalized_date DATE,
			invoice_line_item_id VARCHAR(10)
		)
		
		DECLARE @counter_charge INT
		SELECT @counter_charge = COUNT(1) FROM #temp_finalize_unfinalize_charge_type
		
		UPDATE civ
		SET finalized = CASE WHEN @flag = 'j' THEN 'y' ELSE 'n' END,
		finalized_date = CASE WHEN @flag = 'j' THEN temp.finalized_date ELSE NULL END
		FROM calc_invoice_volume civ
		INNER JOIN #temp_finalize_unfinalize_charge_type temp ON temp.calc_id = civ.calc_id AND temp.invoice_line_item_id = civ.invoice_line_item_id
		
		DECLARE @finalized_date DATETIME
		SELECT	@calc_id = calc_id,
				@finalized_date =  finalized_date
		FROM #temp_finalize_unfinalize_charge_type

		IF NOT EXISTS (SELECT * FROM calc_invoice_volume WHERE (finalized = 'n' OR finalized IS NULL) AND calc_id = @calc_id)
		BEGIN
			UPDATE Calc_invoice_Volume_variance
			SET finalized = 'y',
				finalized_date = @finalized_date
			WHERE calc_id = @calc_id
		END
		ELSE
		BEGIN
			UPDATE Calc_invoice_Volume_variance
			SET finalized = 'n',
				finalized_date = NULL
			WHERE calc_id = @calc_id
		END

		COMMIT
		
		DECLARE @message_part_charge VARCHAR(100)
		
		IF @counter_charge > 1
			SET @message_part_charge = 'Settlements are '
		ELSE
			SET @message_part_charge = 'Settlement is '
		
		IF @flag = 'j'
			SET @message = @message_part_charge + 'finalized sucessfully.'
		IF @flag = 'k'
			SET @message = @message_part_charge + 'unfinalized sucessfully.'
			
		EXEC spa_ErrorHandler 0,
             'Settlement History',
             'spa_settlement_history',
             'Success',
             @message,
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
		   
		IF @flag = 'j'
			SET @message = 'Fail to finalize settlement.'
		IF @flag = 'k'
			SET @message = 'Fail to unfinalize settlement.'
				
		EXEC spa_ErrorHandler -1,
             'Settlement History',
             'spa_settlement_history',
             'DB Error',
             @message,
             ''
	END CATCH
END

ELSE IF @flag='v'
BEGIN
	EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
	IF OBJECT_ID('tempdb..#temp_void') IS NOT NULL
		DROP TABLE #temp_void

	-- Execute a SELECT statement that uses the OPENXML rowset provider.
	SELECT calc_id [calc_id],
			as_of_date [inv_prod_date],
			invoice_line_item_id [invoice_line_item_id]
	INTO #temp_void
	FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
	WITH (
		calc_id VARCHAR(10),
		as_of_date DATETIME,
		invoice_line_item_id VARCHAR(10)
	)

	INSERT INTO #temp_void
		SELECT 
			civv.calc_id,tv.[inv_prod_date],tv.invoice_line_item_id
		FROM 
			#temp_void tv
			INNER JOIN Calc_invoice_Volume_variance civv ON tv.calc_id = civv.netting_calc_id

	
	
	DECLARE @asofdate VARCHAR(20),@prod_date VARCHAR(20),@calc_id_new INT, @inv_prod_date VARCHAR(100), @invoice_line_item_id VARCHAR(100), @remarks VARCHAR(100) = '', @netting_calc_id INT
	DECLARE @tmp VARCHAR(250)
	DECLARE @c_calc_id INT
	DECLARE @netting_calc_id_list VARCHAR(100) = '0'
	DECLARE @agg_calc_id INT

	
	DECLARE void_cursor CURSOR
    FOR SELECT DISTINCT calc_id FROM #temp_void
	OPEN void_cursor
	FETCH NEXT FROM void_cursor
	INTO @c_calc_id

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- To delete the invoice pdf and update the invoice file name to NULL to orginal invoice if it is voided.
		--DECLARE @invoice_file_name_void VARCHAR(200)
		--SELECT @invoice_file_name_void = invoice_file_name FROM calc_invoice_volume_variance WHERE calc_id = @c_calc_id
		--SET @report_file_path = REPLACE(@report_file_path, 'temp_Note/Invoice Report Template.pdf', 'invoice_docs')
		--SET @sql = 'xp_cmdshell ''del "' + REPLACE(@report_file_path,'\\','\') + '\' + @invoice_file_name_void + '"'',no_output'
		--EXEC(@sql)
		--SET @file_to_delete = REPLACE(@report_file_path,'\\','\') + '\' + @invoice_file_name_void
		--EXEC spa_delete_file @file_to_delete , @status OUTPUT

		--UPDATE civv
		--SET invoice_file_name = NULL
		--FROM Calc_invoice_Volume_variance civv
		--WHERE civv.calc_id = @calc_id

		SET @calc_id_new = NULL
		SELECT @inv_prod_date = inv_prod_date FROM #temp_void WHERE calc_id = @c_calc_id
		SET @tmp = ''
		SELECT @tmp = @tmp + CAST(invoice_line_item_id AS VARCHAR(30))+ ', ' from #temp_void WHERE calc_id = @c_calc_id
		SELECT @invoice_line_item_id = SUBSTRING(@tmp, 0, LEN(@tmp))
		SELECT @calc_id = @c_calc_id
		
		SELECT @counterparty_id = counterparty_id,
			   @contract_id      = contract_id,
			   @asofdate         = as_of_date,
			   @prod_date        = prod_date,
			   @invoice_type     = invoice_type,
			   @netting_calc_id	 = netting_calc_id
		FROM   dbo.Calc_invoice_Volume_variance
		WHERE  calc_id = @calc_id
	
		SELECT @calc_id_new = calc_id
		FROM   calc_invoice_volume_variance
		WHERE  counterparty_id      = @counterparty_id
			   AND contract_id      = @contract_id
			   AND as_of_date       = @inv_prod_date
			   AND prod_date        = @prod_date
			   AND invoice_type     = @invoice_type
			   AND netting_calc_id  = @netting_calc_id
			   AND @inv_prod_date > @asofdate
		
		IF 	@calc_id_new IS NULL 
		BEGIN
			DECLARE @n_inv_num INT
			SELECT @n_inv_num = (SELECT MAX(CAST(invoice_number AS INT)) FROM calc_invoice_volume_variance  WHERE ISNUMERIC(invoice_number) = 1)
		
			INSERT INTO dbo.Calc_invoice_Volume_variance
					( as_of_date ,
						counterparty_id ,
						generator_id ,
						contract_id ,
						prod_date ,
						metervolume ,
						invoicevolume ,
						allocationvolume ,
						variance ,
						onpeak_volume ,
						offpeak_volume ,
						uom ,
						actualVolume ,
						book_entries ,
						finalized ,
						invoice_id ,
						deal_id ,
						create_user ,
						create_ts ,
						update_user ,
						update_ts ,
						estimated ,
						calculation_time ,
						book_id ,
						sub_id ,
						process_id,
						invoice_type,
						netting_group_id,
						invoice_number,
						prod_date_to,
						settlement_date
					)
			SELECT 
						@inv_prod_date,
						counterparty_id ,
						generator_id ,
						contract_id ,
						prod_date ,
						metervolume ,
						invoicevolume ,
						allocationvolume ,
						variance ,
						onpeak_volume ,
						offpeak_volume ,
						uom ,
						actualVolume ,
						book_entries ,
						'n' ,
						invoice_id ,
						deal_id ,
						civv.create_user ,
						civv.create_ts ,
						civv.update_user ,
						civv.update_ts ,
						estimated ,
						calculation_time ,
						book_id ,
						sub_id ,
						process_id,
						invoice_type,
						netting_group_id,
						@n_inv_num+1,
						civv.prod_date_to,
						civv.settlement_date
				FROM
						Calc_invoice_Volume_variance civv
						--CROSS JOIN invoice_seed inv	
				WHERE calc_id = @calc_id    
			
				SELECT @calc_id_new = SCOPE_IDENTITY()

				IF @netting_calc_id IS NULL
					SET @agg_calc_id = @calc_id_new
				ELSE 
					SET @netting_calc_id_list = @netting_calc_id_list + ',' + CAST(@calc_id_new AS VARCHAR)
				--UPDATE invoice_seed SET last_invoice_number = (SELECT MAX(CAST(invoice_number AS INT)) FROM calc_invoice_volume_variance)
		END	
	
		SET @sql=
			'
			INSERT INTO calc_invoice_volume 
			(
				calc_id,
				invoice_line_item_id,
				prod_date,
				value,
				volume,
				manual_input,
				default_gl_id,
				uom_id,
				price_or_formula,
				onpeak_offpeak,
				finalized,
				finalized_id,
				inv_prod_date,
				include_volume,
				default_gl_id_estimate,
				status,
				remarks
			)
			SELECT 
				'+CAST(@calc_id_new AS VARCHAR)+',
				civ.invoice_line_item_id,
				civ.prod_date,
				(civ.value)*(-1),
				(civ.volume)*(-1),
				''y'',
				civ.default_gl_id,
				civ.uom_id,
				civ.price_or_formula,
				civ.onpeak_offpeak,
				civ.finalized,
				-1,
				civv.prod_date,
				civ.include_volume,
				civ.default_gl_id_estimate, 
				NULL,
				'''+@remarks +'''
			FROM 
				calc_invoice_volume  civ
				INNER JOIN calc_invoice_volume_variance civv ON civv.calc_id = civ.calc_id
				INNER JOIN #temp_void tv ON tv.invoice_line_item_id = civ.invoice_line_item_id AND tv.calc_id = civ.calc_id
				--LEFT JOIN invoice_header ih ON ih.counterparty_id=civv.counterparty_id
				--					AND ih.Production_month=civv.prod_date
				--					AND ih.as_of_date = civv.as_of_date
				--					AND ih.contract_id = civv.contract_id
				--LEFT JOIN invoice_detail id ON id.invoice_id = ih.invoice_id
				--	AND id.invoice_line_item_id = civ.invoice_line_item_id 					
			WHERE 
				civv.calc_id='+cast(@calc_id as varchar)

		--PRINT @sql
		EXEC(@sql)

		SET @sql='Update civ  
			SET
				status=''v'' ,
				finalized=''f''
			FROM calc_invoice_volume civ
			INNER JOIN #temp_void tv ON tv.invoice_line_item_id = civ.invoice_line_item_id
			WHERE civ.calc_id='+cast(@calc_id_new as varchar)
			
		EXEC(@sql)

		
		SET @sql='Update calc_invoice_volume_variance 
			SET
				finalized=''n'' 
		WHERE 
			calc_id='+cast(@calc_id as varchar)
	
		EXEC(@sql)

		SET @sql='Update civv
		SET
			civv.invoice_type = ''i''
		FROM  calc_invoice_volume_variance civv 	
		WHERE 
			calc_id='+cast(@calc_id_new as varchar)
		EXEC(@sql)	

		DECLARE @new_xml_string VARCHAR(200)
		DECLARE @today_date DATETIME
		SET @today_date = GETDATE ()
		SET @new_xml_string = '<Root><PSRecordSet calc_id="' + CAST(@calc_id_new AS VARCHAR) + '" finalized_date="' + CAST(@today_date AS VARCHAR) + '"/></Root>'
		EXEC spa_update_invoice_number 'f', @new_xml_string	
		
		EXEC spa_generate_document @document_category = 38, @document_sub_category = 42031, @filter_object_id = @calc_id_new, @temp_generate = 0, @get_generated = 1, @show_output = 0
				
	FETCH NEXT FROM void_cursor 
    INTO @c_calc_id
	END 
	CLOSE void_cursor
	DEALLOCATE void_cursor

	UPDATE civv
	SET civv.netting_calc_id = CAST(@agg_calc_id AS INT)
	FROM Calc_invoice_Volume_variance civv
	INNER JOIN dbo.SplitCommaSeperatedValues(@netting_calc_id_list) a ON civv.calc_id = a.item
	--WHERE calc_id IN (@netting_calc_id_list)

	IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR, "calc invoice Volume", 
		"spa_settlement_history", "DB Error", 
		"Failed Voiding Charge Type.", ''
	ELSE
		EXEC spa_ErrorHandler 0, 'calc invoice Volume', 
		'spa_settlement_history', 'Success', 
		'Charge Type Voided Successfully.',''
END

ELSE IF @flag = 'p'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml
		
		IF OBJECT_ID('tempdb..#temp_create_new_invoices') IS NOT NULL
			DROP TABLE #temp_create_new_invoices
		
		IF OBJECT_ID('tempdb..#newly_inserted_value') IS NOT NULL
			DROP TABLE #newly_inserted_value	
			
		CREATE TABLE #newly_inserted_value(invoice_line_item_id INT, calc_id INT, VALUE FLOAT, volume FLOAt, is_final_result CHAR(1) COLLATE DATABASE_DEFAULT)
		
		-- Execute a SELECT statement that uses the OPENXML rowset provider.
		SELECT calc_id [calc_id],
				charge_type_id charge_type_id,
				deal_id [deal_id],
				detail_id deal_detail_id 
		INTO #temp_create_new_invoices
		FROM OPENXML(@idoc, '/Root/PSRecordSet', 1)
		WITH (
			calc_id VARCHAR(10),
			charge_type_id VARCHAR(20),
			deal_id VARCHAR(20),
			detail_id VARCHAR(20)
		)
		
		-- create new invoice
		INSERT INTO Calc_invoice_Volume_variance (
			as_of_date, counterparty_id, generator_id, contract_id, prod_date,
			metervolume, invoicevolume, allocationvolume, variance, onpeak_volume,
			offpeak_volume, uom, actualVolume, book_entries, finalized,
			invoice_id, deal_id, create_user, create_ts, estimated,
			calculation_time, book_id, sub_id, process_id, invoice_number,
			comment1, comment2, comment3, comment4, comment5,
			invoice_status, invoice_lock, invoice_note, invoice_type, netting_group_id,
			prod_date_to, settlement_date, original_invoice,invoice_template_id
		)
		SELECT 
			as_of_date, counterparty_id, generator_id, contract_id, prod_date,
			metervolume, invoicevolume, allocationvolume, variance, onpeak_volume,
			offpeak_volume, uom, actualVolume, book_entries, 'n',
			invoice_id, deal_id, dbo.FNADBUser(), GETDATE(), estimated,
			calculation_time, book_id, sub_id, process_id, is1.last_invoice_number+1,
			comment1, comment2, comment3, comment4, comment5,
			invoice_status, 'n', invoice_note, invoice_type, netting_group_id,
			prod_date_to, settlement_date, invoice_number,@invoice_template
		FROM Calc_invoice_Volume_variance AS civv
		INNER JOIN (SELECT DISTINCT calc_id FROM #temp_create_new_invoices) ti ON ti.calc_id = civv.calc_id
		OUTER APPLY (SELECT last_invoice_number FROM invoice_seed AS is1) is1
		
		DECLARE @new_calc_id INT, @new_invoice_number INT
		SET @new_calc_id = SCOPE_IDENTITY()

		--SELECT @new_invoice_number = invoice_number FROM Calc_invoice_Volume_variance WHERE calc_id = @new_calc_id
		
		--UPDATE invoice_seed SET last_invoice_number = @new_invoice_number
		UPDATE Calc_invoice_Volume_variance SET  invoice_number = @new_calc_id WHERE calc_id = @new_calc_id
		INSERT INTO calc_invoice_volume (
			calc_id, invoice_line_item_id, prod_date, [Value], Volume,
			manual_input, default_gl_id, uom_id, price_or_formula, onpeak_offpeak,
			remarks, finalized, finalized_id, inv_prod_date, include_volume, create_user, create_ts,
			default_gl_id_estimate, [status], deal_type_id, inventory, apply_cash_calc_detail_id
		)
		SELECT 
			@new_calc_id, invoice_line_item_id, prod_date, [Value], Volume,
			manual_input, default_gl_id, uom_id, price_or_formula, onpeak_offpeak,
			remarks, 'n', NULL, inv_prod_date, include_volume, dbo.FNADBUser(), GETDATE(), 
			default_gl_id_estimate, [status], deal_type_id, inventory, apply_cash_calc_detail_id
		FROM calc_invoice_volume AS civ
		INNER JOIN  (SELECT DISTINCT calc_id, charge_type_id FROM #temp_create_new_invoices) ti ON ti.calc_id = civ.calc_id AND civ.invoice_line_item_id = ti.charge_type_id
		
		INSERT INTO calc_formula_value (
			invoice_line_item_id, seq_number, prod_date, [value], contract_id,
			counterparty_id, formula_id, calc_id, hour, formula_str, qtr,
			half, deal_type_id, generator_id, ems_generator_id, deal_id,
			volume, formula_str_eval, commodity_id, granularity, is_final_result,
			is_dst, source_deal_header_id, allocation_volume, counterparty_limit_id, finalized
		)
		OUTPUT INSERTED.invoice_line_item_id, @new_calc_id, INSERTED.[value], INSERTED.volume,INSERTED.is_final_result
		INTO #newly_inserted_value(invoice_line_item_id, calc_id, value, volume,is_final_result)
		SELECT 
			invoice_line_item_id, seq_number, prod_date, [value], contract_id,
			counterparty_id, formula_id, @new_calc_id, [hour], formula_str, qtr,
			half, deal_type_id, generator_id, ems_generator_id, cfv.deal_id,
			volume, formula_str_eval, commodity_id, granularity, is_final_result,
			is_dst, source_deal_header_id, allocation_volume, counterparty_limit_id, 'n'
		FROM calc_formula_value cfv
		INNER JOIN #temp_create_new_invoices ti 
			ON ti.calc_id = cfv.calc_id 
			AND cfv.invoice_line_item_id = ti.charge_type_id
			AND ISNULL(cfv.deal_id,-1) = ISNULL(NULLIF(ti.deal_detail_id,''),-1)
			AND COALESCE(cfv.source_deal_header_id,ti.deal_id,-1) = ISNULL(NULLIF(ti.deal_id,''),-1)

		-- delete details from original invoices
		DELETE cfv 
		FROM calc_formula_value cfv
		INNER JOIN #temp_create_new_invoices ti 
			ON ti.calc_id = cfv.calc_id 
			AND cfv.invoice_line_item_id = ti.charge_type_id
			AND ISNULL(cfv.deal_id,-1) = ISNULL(NULLIF(ti.deal_detail_id,''),-1)
			AND COALESCE(cfv.source_deal_header_id,ti.deal_id,-1) = ISNULL(NULLIF(ti.deal_id,''),-1)

		-- Update the volume and value of original line item, if some deals are still present in original invoice
		UPDATE civ
		SET [Value] = civ.[Value] - a.[value],
			Volume = civ.Volume - a.volume
		FROM calc_invoice_volume AS civ
		INNER JOIN #temp_create_new_invoices ti ON ti.calc_id = civ.calc_id AND civ.invoice_line_item_id = ti.charge_type_id
		OUTER APPLY (
			SELECT SUM([value]) [value], SUM(volume) volume FROM #newly_inserted_value where invoice_line_item_id = civ.invoice_line_item_id AND calc_id=@new_calc_id and is_final_result='y'
		) a	

		-- Lock the orginal invoice.
		UPDATE civv
		SET invoice_lock = 'n'
		FROM calc_invoice_Volume_variance civv
		INNER JOIN #temp_create_new_invoices ti ON ti.calc_id = civv.calc_id
		
		-- Update the volume and value of newly inserted line item
		UPDATE civ
		SET [Value] = a.[value],
			Volume = a.volume
		FROM calc_invoice_volume AS civ
		INNER JOIN calc_formula_value cfv ON cfv.calc_id = civ.calc_id AND civ.invoice_line_item_id = cfv.invoice_line_item_id
		OUTER APPLY (
			SELECT SUM([value]) [value], SUM(volume) volume FROM #newly_inserted_value AS temp
			WHERE temp.calc_id = civ.calc_id AND temp.invoice_line_item_id = civ.invoice_line_item_id  and is_final_result='y'
		) a
		WHERE civ.calc_id = @new_calc_id			
			
		--DELETE civ
		--FROM calc_invoice_volume AS civ
		--INNER JOIN (SELECT DISTINCT calc_id, charge_type_id FROM #temp_create_new_invoices) ti ON ti.calc_id = civ.calc_id AND civ.invoice_line_item_id = ti.charge_type_id
		--LEFT JOIN calc_formula_value AS cfv ON ti.calc_id = cfv.calc_id AND cfv.invoice_line_item_id = ti.charge_type_id
		--WHERE cfv.ID IS NULL

		COMMIT
		
		SET @message = 'Invoice is splited successfully. New Invoice is created successfully.'		
			
		EXEC spa_ErrorHandler 0,
             'Settlement History',
             'spa_settlement_history',
             'Success',
             @message,
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
				
		EXEC spa_ErrorHandler -1,
             'Settlement History',
             'spa_settlement_history',
             'DB Error',
             'Fail to split invoce.',
             ''
	END CATCH
END

ELSE IF @flag = 'q'
BEGIN
	BEGIN TRY
		BEGIN TRAN
		
		
		DECLARE @as_of_date DATETIME, @production_date DATETIME, @cpt_type CHAR(1)
		
		SELECT @production_date = civv.prod_date, @counterparty_id = civv.counterparty_id, @as_of_date = civv.as_of_date, @calc_id = civv.calc_id, @prod_date_to = civv.prod_date_to, @cpt_type = sc.int_ext_flag 
		FROM calc_invoice_volume_variance civv
		LEFT JOIN source_counterparty sc ON sc.source_counterparty_id = civv.counterparty_id
		WHERE calc_id = @calc_id
		
		EXEC spa_calc_invoice @prod_date = @production_date, @counterparty_id = @counterparty_id, @as_of_date = @as_of_date, @calc_id = @calc_id, @prod_date_to = @prod_date_to, @cpt_type = @cpt_type, @process_id = @batch_process_id
				
		DECLARE @model_name VARCHAR(100), @desc NVARCHAR(500), @url VARCHAR(5000), @error_warning VARCHAR(100), @error_success CHAR(1), @total_time VARCHAR(100)
		DECLARE @job_name			VARCHAR(50)
		DECLARE @user_id			VARCHAR(100)
		DECLARE @calc_start_time	 DATETIME 
		
		SET @job_name = 'batch_' + @batch_process_id
		SET @calc_start_time = GETDATE()
		SET @user_id = dbo.FNADBUser()
		
		IF @cpt_type = 'm'
			SET @model_name = 'Financial Model Calculation'
		ELSE
			SET @model_name = 'Settlement Reconciliation'
	

		SET @total_time=CAST(DATEPART(mi,getdate()-@calc_start_time) AS VARCHAR)+ ' min '+ CAST(DATEPART(s,getdate()-@calc_start_time) AS VARCHAR)+' sec'

		SET @error_warning = ''
		SET @error_success = 's'
		IF EXISTS(
			   SELECT 'X'
			   FROM   process_settlement_invoice_log
			   WHERE  process_id = @batch_process_id AND code IN ('Error', 'Warning')
		   )
		BEGIN
			SET @error_warning = ' <font color="red">(Warnings Found)</font>'
			SET @error_success = 'e'
		END

		SET @url = './dev/spa_html.php?__user_name__=''' + @user_id + '''&spa=exec spa_get_settlement_invoice_log ''' + @batch_process_id + ''''
		
		SET @desc = '<a target="_blank" href="' + @url + '">' + + @model_name + ' Processed:  As of Date  ' + dbo.FNAContractmonthFormat(@as_of_date)+ @error_warning+'.</a> (Elapsed Time: '+@total_time+')'	 
		
		
		EXEC spa_message_board 'i',
			 @user_id,
			 NULL,
			 'Settlement Reconciliation ',
			 @desc,
			 '',
			 '',
			 @error_success,
			 @job_name 
		
		
		COMMIT
		
		SET @message = 'Invoice is reprocessed successfully.'		
			
		EXEC spa_ErrorHandler 0,
             'Settlement History',
             'spa_settlement_history',
             'Success',
             @message,
             ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		   ROLLBACK
				
		EXEC spa_ErrorHandler -1,
             'Settlement History',
             'spa_settlement_history',
             'DB Error',
             'Fail to reprocess invoce.',
             ''
	END CATCH
END

-- To load contract in dropdown as per selected counterparty
-- Modified to add privlige
IF @flag = 'i'
BEGIN	
	CREATE TABLE #final_privilege_list(value_id INT, is_enable VARCHAR(20) COLLATE DATABASE_DEFAULT)
	EXEC spa_static_data_privilege @flag = 'p', @source_object = 'contract'

	SET @sql = 'SELECT DISTINCT cg.contract_id,
						CASE 
							WHEN cg.source_system_id = 2 THEN '''' + CASE 
																		WHEN cg.source_contract_id 
																				= cg.contract_name THEN 
																				cg.source_contract_id
																		ELSE cg.source_contract_id 
																				+ '' - '' + cg.contract_name
																	END
							ELSE ssd.source_system_name + ''.'' + CASE 
																		WHEN cg.source_contract_id 
																			= cg.contract_name THEN 
																			cg.source_contract_id
																		ELSE cg.source_contract_id 
																			+ '' - '' + cg.contract_name
																END
						END [contract_name],
					MIN(fpl.is_enable) [status]
				FROM #final_privilege_list fpl
				' + CASE WHEN dbo.FNAIsUserOnAdminGroup(dbo.FNADBUser(), 0) = 0 THEN 'INNER JOIN ' ELSE 'LEFT JOIN ' END + '
					contract_group cg ON cg.contract_id = fpl.value_id
						INNER JOIN source_system_description ssd
							ON  cg.source_system_id = ssd.source_system_id
						INNER JOIN counterparty_contract_address cca 
							ON cg.contract_id = cca.contract_id'
            
	IF (@counterparty_id <> '')
			SET @sql = @sql + ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @counterparty_id + ''') a ON a.item = cca.counterparty_id '
	SET @sql = @sql + ' WHERE 1=1 AND cg.is_active = ''y'''
	SET @sql =  @sql + 'GROUP BY cg.contract_id, cg.source_contract_id, cg.contract_name, cg.source_system_id, ssd.source_system_name  ORDER BY [contract_name]'	
       
	EXEC(@sql)       
END
