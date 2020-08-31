
IF OBJECT_ID ('WF_Invoicedetails', 'V') IS NOT NULL
	DROP VIEW WF_Invoicedetails;
GO

-- ===============================================================================================================
-- Author: ryadav@pioneersolutionsglobal.com
-- Create date: 2018-08-15
-- Modified Date: 2019-01-18
-- Description: Created view for invoice detail and audit information.
-- ===============================================================================================================

CREATE VIEW [dbo].[WF_Invoicedetails]
AS  

WITH cte AS (
		SELECT civv.*, ROW_NUMBER() OVER (PARTITION BY civv.calc_id ORDER BY civv.Calc_invoice_Volume_variance_audit_id DESC) row_no
		FROM Calc_invoice_Volume_variance_audit civv
	), cte_previous AS (
		SELECT * FROM cte WHERE row_no = 2
	), civv_compare AS (
			SELECT  
				  civv.calc_id
				, civv.as_of_date
				, civv.counterparty_id
				, civv.generator_id
				, civv.contract_id
				, civv.prod_date
				, civv.metervolume
				, civv.invoicevolume
				, civv.allocationvolume
				, civv.variance
				, civv.actualVolume
				, civv.finalized
				, civv.create_user
				, civv.create_ts
				, civv.update_user
				, civv.update_ts
				, civv.estimated
				, civv.invoice_number
				, civv.invoice_status
				, civv.invoice_lock
				, civv.invoice_note
				, civv.invoice_type
				, civv.prod_date_to
				, civv.settlement_date
				, civv.finalized_date
				, civv.payment_date
				, civv.invoice_template_id
				, civv.invoice_file_name
				, cp.invoice_lock [previous_invoice_lock]
				, cp.invoice_status [previous_invoice_status]
				, civ.[amount]
			FROM Calc_invoice_Volume_variance civv
			LEFT JOIN (
				SELECT civ.calc_id, SUM(ISNULL(id.invoice_amount,civ.value)) [amount]
				FROM calc_invoice_volume civ
				INNER JOIN Calc_Invoice_Volume_variance civv ON civ.calc_id = civv.calc_id
				LEFT JOIN invoice_header ih ON ih.counterparty_id = civv.counterparty_id AND ih.contract_id = civv.contract_id AND ih.production_month = civv.prod_date
				LEFT JOIN invoice_detail id ON id.invoice_id = ih.invoice_id AND id.invoice_line_item_id = civ.invoice_line_item_id AND ISNULL(civ.manual_input,'n') = 'n'
				GROUP BY civ.calc_id
			) civ ON civ.calc_id = civv.calc_id
			LEFT JOIN cte_previous cp  ON cp.calc_id = civv.calc_id 
	)

	SELECT * FROM civv_compare

