IF OBJECT_ID(N'[dbo].[spa_view_invoice]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_view_invoice]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_view_invoice]
    @flag CHAR(1),
	@calc_id INT = NULL,
	@true_up_id VARCHAR(500) = NULL,
	@invoice_template INT = NULL,
	@invoice_month DATETIME = NULL

AS
/*
	DECLARE
	@flag CHAR(1) = 'f',
	@calc_id INT = 6376,
	@true_up_id VARCHAR(500) = '460',
	@invoice_template INT = '21',
	@invoice_month DATETIME = '2015-01-01'
--*/

SET NOCOUNT ON
DECLARE @desc VARCHAR(2000),
		@err_no INT
IF @flag = 't'
BEGIN
	SELECT	dbo.FNAdateformat(citu.true_up_month) [month],
			sdv.code [charge_type],
			citu.true_up_id,
			citu.value,
			sc.currency_name [currency],
			citu.volume [volume],
			su.uom_name [UOM],
			CASE WHEN citu.true_up_calc_id IS NOT NULL THEN 'Finalized' ELSE 'Estimate' END [Accounting Status],
			dbo.FNAdateformat(civ.finalized_date) [Finalized Date]
	FROM calc_invoice_true_up citu
	INNER JOIN static_data_value sdv ON citu.invoice_line_item_id = sdv.value_id
	INNER JOIN contract_group cg ON citu.contract_id = cg.contract_id
	LEFT JOIN source_currency sc ON cg.currency = sc.source_currency_id
	LEFT JOIN source_uom su ON cg.volume_uom = su.source_uom_id
	LEFT JOIN Calc_invoice_Volume_variance civv ON civv.calc_id = citu.true_up_calc_id
	LEFT JOIN calc_invoice_volume civ ON civv.calc_id = civ.calc_id AND citu.invoice_line_item_id = civ.invoice_line_item_id AND civ.prod_date = citu.true_up_month
	--OUTER APPLY(SELECT SUM(value) volume FROM calc_invoice_true_up ctu
	--		INNER JOIN formula_nested fn ON ctu.formula_id = fn.formula_group_id
	--			AND ctu.sequence_id = fn.sequence_order
	--			AND fn.show_value_id = 1200
	--			AND citu.true_up_month = ctu.true_up_month
	--		WHERE
	--			ctu.calc_id = citu.calc_id	
	--	) citu1
	WHERE citu.calc_id = @calc_id AND citu.is_final_result = 'y'
END

ELSE IF @flag = 'f'
BEGIN
	IF @invoice_template IS NULL OR @invoice_template = ''
	BEGIN
		BEGIN TRY
		BEGIN TRAN
			INSERT INTO calc_invoice_volume (calc_id, invoice_line_item_id, prod_date, value, volume, finalized, inv_prod_date, finalized_date, manual_input)
			SELECT	calc_id, invoice_line_item_id, true_up_month, value, citu.volume [volume], 'y' [finalized], NULL, GETDATE(), 'y'
			FROM calc_invoice_true_up citu
			INNER JOIN dbo.SplitCommaSeperatedValues(@true_up_id) ids ON citu.true_up_id = ids.item
			--OUTER APPLY(SELECT SUM(value) volume FROM calc_invoice_true_up ctu
			--			INNER JOIN formula_nested fn ON ctu.formula_id = fn.formula_group_id
			--				AND ctu.sequence_id = fn.sequence_order
			--				AND fn.show_value_id = 1200
			--				AND citu.true_up_month = ctu.true_up_month
			--			WHERE
			--				ctu.calc_id = citu.calc_id	
			--) citu1


			UPDATE citu
			SET true_up_calc_id = calc_id
			FROM calc_invoice_true_up citu
			INNER JOIN dbo.SplitCommaSeperatedValues(@true_up_id) ids ON citu.true_up_id = ids.item
		COMMIT

		EXEC spa_ErrorHandler 0
			, 'spa_view_process'
			, 'spa_view_process'
			, 'Success'
			, 'Trueup finalized successfully.'
			, ''
		
		END TRY
		BEGIN CATCH	
			IF @@TRANCOUNT > 0
				ROLLBACK
			SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

			SELECT @err_no = ERROR_NUMBER()

			EXEC spa_ErrorHandler @err_no
				, 'spa_view_process'
				, 'spa_view_process'
				, 'Error'
				, @DESC
				, ''
		END CATCH
	END
	ELSE 
	BEGIN
		BEGIN TRY
		BEGIN TRAN
			DECLARE @new_invoice_number INT

			INSERT INTO Calc_invoice_Volume_variance(
				as_of_date, 
				counterparty_id, 
				contract_id, 
				prod_date, 
				metervolume, 
				invoicevolume, 
				allocationvolume, 
				onpeak_volume,
				offpeak_volume,
				uom,
				actualVolume,
				book_entries,
				finalized,
				estimated,
				invoice_status,
				invoice_lock,
				invoice_type,
				prod_date_to,
				settlement_date,
				finalized_date,
				invoice_template_id,
				delta
				)
			SELECT	CONVERT(DATE, GETDATE(),103)  [as_of_date],
					citu.counterparty_id,
					citu.contract_id,
					MIN(true_up_month)[production_date],
					0 [metervolume],
					0 [invoicevolume],
					0 [allocationvolume],
					0 [onpeak_volume],
					0 [offpeak_volume],
					MAX(cg.volume_uom),
					0 [actualVolume],
					'm' [book_entries],
					'n' [finalized],
					'n' [estimated],
					'20701' [invoice_status],
					'n' [invoice_lock],
					'i' [invoice_type], 
					MAX(true_up_month) [production_date_to],
					MAX(dbo.FNAInvoiceDueDate(true_up_month,cg.settlement_date,cg.holiday_calendar_id,cg.settlement_days)) [settlement_date], 
					CONVERT(DATE, GETDATE(),103) [finalized_date],
					@invoice_template [invoice_template],
					'y' [delta]
			FROM calc_invoice_true_up citu
				INNER JOIN dbo.SplitCommaSeperatedValues(@true_up_id) ids ON citu.true_up_id = ids.item
				INNER JOIN contract_group cg ON citu.contract_id = cg.contract_id
			GROUP BY 
				citu.counterparty_id, citu.contract_id
			
			DECLARE @new_calc_id INT
			SET @new_calc_id = SCOPE_IDENTITY();

			INSERT INTO calc_invoice_volume (
				calc_id, 
				invoice_line_item_id, 
				prod_date, 
				value, 
				volume, 
				finalized, 
				inv_prod_date, 
				finalized_date,
				manual_input
			)
			SELECT	@new_calc_id [calc_id], 
					invoice_line_item_id, 
					true_up_month, 
					citu.value value, 
					citu.volume [volume], 
					'y' [finalized], 
					@invoice_month [invoice_prod_date], 
					CONVERT(DATE, GETDATE(),103) [finalized_date],
					'y'
			FROM calc_invoice_true_up citu
			INNER JOIN dbo.SplitCommaSeperatedValues(@true_up_id) ids ON citu.true_up_id = ids.item
			--OUTER APPLY(SELECT SUM(value) volume FROM calc_invoice_true_up ctu
			--			INNER JOIN formula_nested fn ON ctu.formula_id = fn.formula_group_id
			--				AND ctu.sequence_id = fn.sequence_order
			--				AND fn.show_value_id = 1200
			--			WHERE
			--				ctu.calc_id = citu.calc_id	
			--				AND citu.true_up_month = ctu.true_up_month
			--			) citu1
			--GROUP BY invoice_line_item_id,true_up_month 
			

			--UPDATE citu
			--SET true_up_calc_id = @new_invoice_number
			--FROM calc_invoice_true_up citu
			--INNER JOIN dbo.SplitCommaSeperatedValues(@true_up_id) ids ON citu.true_up_id = ids.item

			DECLARE @xml VARCHAR(500)
			SET @xml = '<Root><PSRecordSet calc_id = "'+CAST(@new_calc_id AS VARCHAR(100))+'" finalized_date = ""></PSRecordSet></Root>'
			EXEC  spa_update_invoice_number 'f', @xml 
			
			
			UPDATE citu
			SET true_up_calc_id = @new_calc_id
			FROM calc_invoice_true_up citu
			INNER JOIN dbo.SplitCommaSeperatedValues(@true_up_id) ids ON citu.true_up_id = ids.item

			UPDATE calc_invoice_volume_variance SET finalized='y'  WHERE calc_id=@new_calc_id

		COMMIT

		EXEC spa_ErrorHandler 0
			, 'spa_view_process'
			, 'spa_view_process'
			, 'Success'
			, 'Trueup finalized successfully.'
			, ''
		
		END TRY
		BEGIN CATCH	
			IF @@TRANCOUNT > 0
				ROLLBACK
			SET @DESC = 'Fail to insert Data ( Errr Description:' + ERROR_MESSAGE() + ').'

			SELECT @err_no = ERROR_NUMBER()

			EXEC spa_ErrorHandler @err_no
				, 'spa_view_process'
				, 'spa_view_process'
				, 'Error'
				, @DESC
				, ''
		END CATCH
	END
END

-- charge type grid history tab
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
	WHERE 1 = 1  AND civv.calc_id = @calc_id
	UNION ALL
	SELECT	calc_detail_id,
			manual_input,
			citu.invoice_line_item_id,
			sdv.code [charge_type],
			citu.[Value] [amount],
			sc.currency_name [currency],
			citu.Volume AS Volume,
			su.uom_id [uom],			
			dbo.FNAdateformat(citu.prod_date) [prod_month],				   
			CASE WHEN civ.status = 'v' THEN 'Voided' WHEN ISNULL(civ.finalized, 'n') = 'n' THEN 'Estimate' ELSE 'Finalized' END [calc_status],
			dbo.FNADateFormat(civ.finalized_date) [Finalized Date]
	FROM calc_invoice_true_up citu
	INNER JOIN static_data_value sdv ON citu.invoice_line_item_id = sdv.value_id
	INNER JOIN contract_group cg ON citu.contract_id = cg.contract_id
	LEFT JOIN source_currency sc ON cg.currency = sc.source_currency_id
	LEFT JOIN source_uom su ON cg.volume_uom = su.source_uom_id
	LEFT JOIN Calc_invoice_Volume_variance civv ON civv.calc_id = citu.true_up_calc_id
	LEFT JOIN calc_invoice_volume civ ON civv.calc_id = civ.calc_id AND citu.invoice_line_item_id = civ.invoice_line_item_id AND civ.prod_date = citu.true_up_month
	WHERE citu.calc_id = @calc_id AND citu.is_final_result = 'y'
END

--delete finalized true ups
ELSE IF @flag = 'z'
BEGIN	
	BEGIN TRY
	EXEC('DELETE FROM calc_invoice_true_up WHERE true_up_id  IN ('+@true_up_id+')')
	
	EXEC spa_ErrorHandler 0
			, 'spa_view_process'
			, 'spa_view_process'
			, 'Success'
			, 'Trueup deleted successfully.'
			, ''
		
		END TRY
		BEGIN CATCH	
			IF @@TRANCOUNT > 0
				ROLLBACK
			SET @DESC = 'Fail to delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'

			SELECT @err_no = ERROR_NUMBER()

			EXEC spa_ErrorHandler @err_no
				, 'spa_view_process'
				, 'spa_view_process'
				, 'Error'
				, @DESC
				, ''
		END CATCH
END	