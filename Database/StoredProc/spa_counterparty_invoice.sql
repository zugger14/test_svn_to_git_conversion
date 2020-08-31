IF OBJECT_ID(N'[dbo].[spa_counterparty_invoice]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_counterparty_invoice]
GO

-- ===========================================================================================================
-- Author: bmaharjan@pioneersolutionsglobal.com
-- Create date: 2015-04-1
-- Description: CRUD operation for Counterparty Invoice
 
-- Params:
-- @flag     CHAR - Operation flag

-- ===========================================================================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_counterparty_invoice]
	@flag CHAR(1),
	@counterparty_id NVARCHAR(1000) = NULL,
	@contract_id VARCHAR(100) = NULL,
	@prod_date DATETIME = NULL,
	@as_of_date DATETIME = NULL,
	@amount FLOAT = NULL,
	@invoice_date VARCHAR(20) = NULL,
	@invoice_due_date VARCHAR(20) = NULL,
	@description1 VARCHAR(500) = NULL,
	@description2 VARCHAR(500) = NULL,
	@uom INT = NULL,
	@onpeak_volume FLOAT = NULL,
	@offpeak_volume FLOAT = NULL,
	@volume FLOAT = NULL,
	@invoice_ref_no VARCHAR(500) = NULL,
	@status CHAR(1) = NULL,
	@xmltext NTEXT = NULL
		
AS

SET NOCOUNT ON

DECLARE @idoc INT

--spa_counterparty_invoice 'g','3831',NULL,100,'2015-11-29','2015-11-29','sdsad','sadada'
--select * from source_counterparty

--To load charge type in grid for having shadow calc value with percentage allocation logic
IF @flag = 'g'
BEGIN
set @amount = ISNULL(@amount,0)
	
	CREATE TABLE #temp_calc_invoice(calc_id INT,counterparty_id INT,contract_id INT,prod_date date)

	INSERT INTO #temp_calc_invoice(calc_id,counterparty_id,contract_id,prod_date)
	SELECT 
		civv.calc_id,civv.counterparty_id,civv.contract_id,civv.prod_date
	FROM
		(SELECT MAX(as_of_date)as_of_date,MAX(invoice_type) invoice_type,MAX(settlement_date) settlement_date, counterparty_id,contract_id,prod_date FROM Calc_invoice_Volume_variance GROUP BY counterparty_id,contract_id,prod_date) civv_max
		INNER JOIN calc_invoice_volume_variance civv ON civv.counterparty_id = civv_max.counterparty_id
			AND civv.contract_id = civv_max.contract_id
			AND civv.prod_date = civv_max.prod_date
			AND civv.as_of_date = civv_max.as_of_date
			AND civv.invoice_type =  civv_max.invoice_type
			AND civv.settlement_date =  civv_max.settlement_date
	WHERE
		civv.counterparty_id IN (@counterparty_id)
		AND dbo.FNAGetcontractMonth(civv.prod_date) = dbo.FNAGetcontractMonth(@prod_date)
		AND civv.contract_id IN (@contract_id)


	SELECT isnull(invoice_detail_id,- 1) AS Invoice_detail_id
		,value_id
		,item
		,shadow_calc
		,invoice_amount,
		invoice_id,
		invoice_detail_id AS [detail_id],
		invoice_ref_no,
		invoice_date,
		short_text,
		invoice_description
	INTO #temp_chargetype_value
	FROM (
		SELECT sd.value_id
			,sd.description + '(' + sd.code + ')' item
			,SUM(ISNULL(a.value, 0)) shadow_calc
			,999 AS seq_number
			,cgd.sequence_order contract_sequence,
			id.invoice_detail_id,
			ih.invoice_id,
			id.invoice_amount invoice_amount,
			MAX(id.invoice_ref_no) invoice_ref_no,
			MAX(id.invoice_date) invoice_date,
			MAX(id.short_text) short_text,
			MAX(id.invoice_description) invoice_description
	FROM 
		#temp_calc_invoice tci
		INNER JOIN calc_invoice_volume_variance civ ON civ.calc_id = tci.calc_id
		INNER JOIN calc_invoice_volume a ON civ.calc_id = a.calc_id
		AND civ.invoice_type='r'
		LEFT JOIN invoice_header ih ON ih.counterparty_id = civ.counterparty_id 
						AND ih.contract_id = civ.contract_id
						AND ih.production_month = civ.prod_date
						AND ISNULL(a.manual_input,'n')='n'
		LEFT JOIN invoice_detail id on ih.invoice_id = id.invoice_id and id.invoice_line_item_id = a.invoice_line_item_id
		LEFT JOIN static_data_value sd ON sd.value_id = a.invoice_line_item_id
		LEFT JOIN contract_group cg ON cg.contract_id = civ.contract_id
		LEFT JOIN contract_group_detail cgd ON cgd.contract_id = cg.contract_id
			AND cgd.invoice_line_item_id = a.invoice_line_item_id
			AND ISNULL(cgd.deal_type, - 1) = ISNULL(a.deal_type_id, - 1)
			AND cgd.prod_type = CASE 
				WHEN ISNULL(cg.term_start, '') = ''
					THEN 'p'
				WHEN dbo.fnagetcontractmonth(cg.term_start) <= dbo.fnagetcontractmonth(@prod_date)
					THEN 'p'
				ELSE 't'
				END
		LEFT JOIN contract_charge_type cct ON cct.contract_charge_type_id = cg.contract_charge_type_id
		LEFT JOIN contract_charge_type_detail cctd ON cctd.contract_charge_type_id = cct.contract_charge_type_id
			AND cctd.invoice_line_item_id = a.invoice_line_item_id
			AND cctd.prod_type = CASE 
				WHEN ISNULL(cg.term_start, '') = ''
					THEN 'p'
				WHEN dbo.fnagetcontractmonth(cg.term_start) <= dbo.fnagetcontractmonth(@prod_date)
					THEN 'p'
				ELSE 't'
				END
		WHERE civ.counterparty_id IN (@counterparty_id)
			AND dbo.FNAGetcontractMonth(civ.prod_date) = dbo.FNAGetcontractMonth(@prod_date)
			--AND (civ.as_of_date) = @as_of_date
			AND civ.contract_id IN (@contract_id)
		GROUP BY sd.description
			,sd.code
			,sd.value_id
			,cgd.sequence_order, invoice_detail_id, ih.invoice_id, id.invoice_amount
		) a
	ORDER BY seq_number ,contract_sequence


	SELECT	item [charge_type],
			invoice_ref_no invoice_ref_no, 
			dbo.FNAdateformat(invoice_date) invoice_date,
			Round(shadow_calc,2) [Shadow Calc],
			CASE WHEN @amount  IS NULL OR @amount = 0
					THEN Round(invoice_amount,2)  
				    ELSE ROUND((shadow_calc / ISNULL(NULLIF(a.toatal_shadow_calc,0),1)) * (COALESCE(@amount,invoice_amount, 0)*-1), 2) 
			END [Amount],
			CASE WHEN @amount  IS NULL OR @amount = 0
					THEN Round(shadow_calc,2) - (ROUND(invoice_amount,2)) 
					ELSE Round(shadow_calc,2) - (ROUND((shadow_calc / ISNULL(NULLIF(a.toatal_shadow_calc,0),1)) * (COALESCE(@amount,invoice_amount, 0)*-1), 2))  
			END [Variance],
			--Round(invoice_amount,2) [Amount],
			--Round(shadow_calc,2) - Round(invoice_amount,2) [Variance],
			invoice_description [description],
			--shadow_calc / ISNULL(NULLIF(a.toatal_shadow_calc,0),1) [percentage],
			value_id [invoice_line_item_id],
			invoice_id,
			detail_id AS [invoice_detail_id]
	FROM #temp_chargetype_value
	CROSS APPLY (
		SELECT sum(shadow_calc) toatal_shadow_calc
		FROM #temp_chargetype_value
		) a
	UNION ALL 
	SELECT  '<strong>Total</strong>' [charge_type],
			NULL invoice_ref_no, 
			NULL invoice_date,
			SUM(Round(shadow_calc,2)) [Shadow Calc],
			CASE WHEN @amount  IS NULL OR @amount = 0
					THEN SUM(ROUND(invoice_amount, 2))  
					ELSE SUM(ROUND((shadow_calc / ISNULL(NULLIF(b.toatal_shadow_calc,0),1)) * (COALESCE(@amount,invoice_amount, 0)*-1), 2)) 
			END [Amount],
			CASE WHEN @amount  IS NULL OR @amount = 0
					THEN SUM(Round(shadow_calc,2) - ROUND(invoice_amount,2))  
					ELSE SUM(Round(shadow_calc,2) - (ROUND((shadow_calc / ISNULL(NULLIF(b.toatal_shadow_calc,0),1)) * (COALESCE(@amount,invoice_amount, 0)*-1), 2)))  
			END [Variance],
			NULL [description],
			NULL [invoice_line_item_id],
			NULL [invoice_id],
			NULL [invoice_detail_id]
	FROM #temp_chargetype_value
	CROSS APPLY (
		SELECT sum(shadow_calc) toatal_shadow_calc
		FROM #temp_chargetype_value
		) b

END

-- To load charge type in grid which has not been calc
IF @flag = 't'
BEGIN
	SELECT DISTINCT isnull(sd.[description], sd.code) AS [charge_type], 
		'' invoice_ref_no, 
		dbo.FNAdateformat(@invoice_date) invoice_date,
		0 shadow_calc,
		ISNULL(id.invoice_amount, '') amount,
		@description1 description1,
		@description2 description2,
		sd.value_id,
		ih.invoice_id,
		id.invoice_detail_id
		FROM source_counterparty civv
	LEFT JOIN counterparty_contract_address cca ON civv.source_counterparty_id = cca.counterparty_id
    LEFT JOIN contract_group cg ON cg.contract_id = cca.contract_id
    LEFT JOIN contract_group_detail cgd ON cgd.contract_id = cg.contract_id
            AND cgd.prod_type = CASE  WHEN ISNULL(cg.term_start, '') = '' THEN 'p' WHEN dbo.fnagetcontractmonth(cg.term_start) <= dbo.fnagetcontractmonth(@prod_date) THEN 'p'    ELSE 't' END
    LEFT JOIN contract_charge_type cct ON cct.contract_charge_type_id = cg.contract_charge_type_id
    LEFT JOIN contract_charge_type_detail cctd ON cctd.contract_charge_type_id = cct.contract_charge_type_id
            AND cctd.prod_type = CASE  WHEN ISNULL(cg.term_start, '') = '' THEN 'p' WHEN dbo.fnagetcontractmonth(cg.term_start) <= dbo.fnagetcontractmonth(@prod_date) THEN 'p' ELSE 't' END
    LEFT JOIN static_data_value sd ON sd.value_id = ISNULL(cgd.invoice_line_item_id, cctd.invoice_line_item_id)
	LEFT JOIN invoice_header ih ON ih.counterparty_id = civv.source_counterparty_id AND ih.contract_id = cg.contract_id
	LEFT JOIN invoice_detail id ON id.invoice_id = ih.invoice_id AND id.invoice_line_item_id = sd.value_id
	WHERE 1 = 1
            AND civv.source_counterparty_id = @counterparty_id AND cg.contract_id = @contract_id

END


ELSE IF @flag = 's'
BEGIN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xmltext

		SELECT * INTO #temp_invoice
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 2)
			   WITH (
				   charge_type NVARCHAR(100) '@charge_type',
				   invoice_ref_no NVARCHAR(100) '@invoice_ref_no',
				   invoice_date NVARCHAR(20) '@invoice_date',
				   invoice_due_date NVARCHAR(20) '@invoice_due_date',
				   shadow_calc FLOAT '@shadow_calc',
				   amount FLOAT '@amount',
				   description1 NVARCHAR(500) '@description1',
				   description2 NVARCHAR(500) '@description2',
				   invoice_line_item_id INT '@invoice_line_item_id',
				   invoice_id INT '@invoice_id',
				   invoice_detail_id INT '@invoice_detail_id'
			   )
		
		IF @invoice_date = ''
		BEGIN
			SET @invoice_date = NULL
		END

		IF @invoice_due_date = ''
		BEGIN
			SET @invoice_due_date = NULL
		END
 
		IF EXISTS (SELECT 1 FROM invoice_header WHERE invoice_ref_no IS NOT NULL AND invoice_ref_no <> '' AND invoice_ref_no = @invoice_ref_no AND invoice_id <> (SELECT invoice_id FROM invoice_header WHERE counterparty_id = @counterparty_id AND  contract_id = @contract_id AND production_month = @prod_date))
		BEGIN
			EXEC spa_ErrorHandler -1
                , 'invoice_detail'
                , 'spa_counterparty_invoice'
                , 'Error' 
                , 'Selected Invoice Ref No already exists in the system.'
                , ''
			RETURN
		END
		
		BEGIN TRAN
		IF NOT EXISTS (SELECT 1 FROM invoice_header  WHERE counterparty_id = @counterparty_id AND  contract_id = @contract_id AND production_month = @prod_date )
		BEGIN
			INSERT INTO invoice_header 
			(
				counterparty_id,
				uom_id,
				as_of_date,
				production_month,
				onpeak_volume,
				offpeak_volume,
				contract_id,
				invoice_volume,
				--amount,
				invoice_ref_no,
				invoice_date,
				invoice_due_date,
				description1,
				description2,
				status
			)
			VALUES
			(	
				@counterparty_id,
				@uom,
				@as_of_date,
				dbo.fnagetcontractmonth(@prod_date),
				@onpeak_volume,
				@offpeak_volume,
				@contract_id,
				@volume,
				--@amount,
				@invoice_ref_no,
				@invoice_date,
				@invoice_due_date,
				@description1,
				@description2,
				@status
			)

			DECLARE @invoice_id INT
			SET @invoice_id = SCOPE_IDENTITY()

			INSERT INTO invoice_detail
			(
				invoice_id,
				invoice_line_item_id,
				invoice_amount,
				invoice_date,
				invoice_ref_no,
				short_text,
				invoice_description
			)
			SELECT	@invoice_id, 
					ti.invoice_line_item_id, 
					ti.amount, 
					ti.invoice_date, 
					ti.invoice_ref_no, 
					ti.description1, 
					ti.description2 
			FROM #temp_invoice ti

			
			EXEC spa_ErrorHandler 0
                , 'invoice_detail'
                , 'spa_counterparty_invoice'
                , 'Success' 
                , 'Successfully saved data.'
                , ''
		END 
		ELSE 
		BEGIN
			UPDATE invoice_header 
			SET
				counterparty_id = @counterparty_id,
				uom_id = @uom,
				as_of_date = @as_of_date,
				production_month = dbo.fnagetcontractmonth(@prod_date),
				onpeak_volume = @onpeak_volume,
				offpeak_volume = @offpeak_volume,
				contract_id = @contract_id,
				invoice_volume = @volume,
				--amount = @amount,
				invoice_ref_no = @invoice_ref_no,
				invoice_date = @invoice_date,
				invoice_due_date = @invoice_due_date,
				description1 = @description1,
				description2 = @description2,
				status = @status
		 WHERE counterparty_id = @counterparty_id AND  contract_id = @contract_id AND production_month = @prod_date
		
			UPDATE id 
			SET 
				id.invoice_amount=ti.amount,
				id.invoice_date=ti.invoice_date,
				id.invoice_ref_no=ti.invoice_ref_no,
				id.short_text=ti.description1,
				id.invoice_description=ti.description2		
			FROM 
				invoice_header ih
				INNER JOIN invoice_detail id ON ih.invoice_id = id.invoice_id
				INNER JOIN #temp_invoice ti ON ti.invoice_line_item_id = id.invoice_line_item_id
			WHERE counterparty_id = @counterparty_id AND  contract_id = @contract_id AND production_month = @prod_date
		  
			EXEC spa_ErrorHandler 0
                , 'invoice_detail'
                , 'spa_counterparty_invoice'
                , 'Success' 
                , 'Successfully updated data.'
                , ''
		END 

		COMMIT TRAN
		/*
		INSERT INTO invoice_header 
		(
			counterparty_id,
			uom_id,
			as_of_date,
			production_month,
			onpeak_volume,
			offpeak_volume,
			contract_id
		)
		VALUES
		(	
			@counterparty_id,
			@uom,
			@as_of_date,
			dbo.fnagetcontractmonth(@prod_date),
			@onpeak_volume,
			@offpeak_volume,
			@contract_id
		)

		DECLARE @invoice_id INT
		SET @invoice_id = SCOPE_IDENTITY()

		INSERT INTO invoice_detail
		(
			invoice_id,
			invoice_line_item_id,
			invoice_amount,
			invoice_date,
			invoice_ref_no,
			short_text,
			invoice_description
		)
		SELECT	@invoice_id, 
				ti.invoice_line_item_id, 
				ti.amount, 
				ti.invoice_date, 
				ti.invoice_ref_no, 
				ti.description1, 
				ti.description2 
		FROM #temp_invoice ti
		*/
		
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
			   , 'spa_counterparty_invoice'
			   , 'Error'
			   , @DESC
			   , ''
	END CATCH	 
END