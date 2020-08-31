
IF OBJECT_ID(N'[dbo].[spa_invoice_adjustment]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_invoice_adjustment]
GO

-- ===========================================================================================================
-- Author: arai@pioneersolutionsglobal.com
-- Create date: 2018-01-10
-- Description: Operations for adjustment of invoice.
 
-- Params:
-- @flag     CHAR - Operation flag

-- ===========================================================================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[spa_invoice_adjustment]
	@flag CHAR(1),
	@counterparty_id VARCHAR(MAX) = NULL,
	@contract_id VARCHAR(MAX) = NULL,
	@prod_date_from VARCHAR(10) = '',
	@prod_date_to VARCHAR(10) = '',
	@created_time VARCHAR(10) = '',
	@created_by VARCHAR(500) = '',
	@true_up_id VARCHAR(MAX) = NULL,
	@calc_id VARCHAR(MAX) = NULL,
	@invoice_template INT = NULL,
	@invoice_month VARCHAR(10) = NULL,
	@show_adjusted_value CHAR(1) = 'n'
AS

SET NOCOUNT ON

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
	BEGIN
		SET @prod_date_from = COALESCE(NULLIF(@prod_date_from, ''), '1900-01-01')
		SET @prod_date_to = COALESCE(NULLIF(@prod_date_to, ''), '9999-01-01')

		SET @sql = '
			SELECT
				citp.true_up_id [True up ID],
				citp.calc_id [Calc ID],
			    sc.counterparty_name Counteparty,
			    cg.contract_name [Contract],
			    dbo.FNADateFormat(civ.prod_date) [Production Month],
			    sdv.code [Charge Type],
			 	CONVERT(VARCHAR,CAST(dbo.FNARemoveTrailingZeroes(ROUND(civ.volume + citp.volume, 2)) AS money),1) [Current Volume],
				CONVERT(VARCHAR,CAST(dbo.FNARemoveTrailingZeroes(ROUND(civ.volume, 2)) AS money),1) [Prior Volume],
				ROUND(dbo.FNARemoveTrailingZeroes(civ.value + citp.value), 2) [Current Value],
				ROUND(dbo.FNARemoveTrailingZeroes(civ.value), 2) [Prior Value],
				CONVERT(VARCHAR,CAST(dbo.FNARemoveTrailingZeroes(ROUND(citp.volume, 2)) AS money),1) [Delta Volume],
				su.uom_name [UOM],
				ROUND(dbo.FNARemoveTrailingZeroes(citp.value), 2) [Delta Value],
			   cur.currency_name [Currency],
			   CASE WHEN civ1.finalized = ''y'' THEN ''Final'' else ''Estimate'' END [Accounting Status],
			   dbo.FNADateFormat(civ1.finalized_date) [Finalized Date],
			   civv2.invoice_number [Invoice Number],
			   au.user_f_name + au.user_l_name [Created By],
			   dbo.FNADateTimeFormat(civv.create_ts,2) [Created Time]
			FROM 
				   calc_invoice_volume_variance civv
				   INNER JOIN calc_invoice_volume civ ON civv.calc_id=civ.calc_id
				   INNER JOIN calc_invoice_true_up citp ON citp.calc_id = civv.calc_id
						  AND citp.prod_date = civ.prod_date AND civ.invoice_line_item_id = citp.invoice_line_item_id
				   INNER JOIN source_counterparty sc On sc.source_counterparty_id =civv.counterparty_id
				   INNER JOIN contract_group cg ON cg.contract_id = civv.contract_id
				   INNER JOIN static_data_value sdv ON sdv.value_id = civ.invoice_line_item_id
				   INNER JOIN source_currency cur On cur.source_currency_id = cg.currency
				   LEFT JOIN calc_invoice_volume_variance civv2 ON civv2.calc_id = citp.true_up_calc_id
				   LEFT JOIN calc_invoice_volume civ1 ON civ1.calc_id = civv2.calc_id AND civ1.invoice_line_item_id = citp.invoice_line_item_id AND ISNULL(civ1.manual_input,''n'')=''y'' AND civv2.prod_date = civ.prod_date
				   LEFT JOIN source_UOM su ON su.source_uom_id = civv.uom
				   INNER JOIN application_users au ON au.user_login_id = civv.create_user
				   LEFT JOIN calc_invoice_volume civ2 ON civ2.calc_id = citp.true_up_calc_id AND civ2.invoice_line_item_id = citp.invoice_line_item_id AND civ2.prod_date = citp.prod_date		
				   '+ CASE WHEN @created_by <> '' THEN ' INNER JOIN dbo.SplitCommaSeperatedValues(''' + @created_by+ ''')a ON a.item = civv.create_user' ELSE '' END +'
			WHERE 1=1 
			AND citp.value <> 0
			'+ CASE WHEN @prod_date_from <> '' THEN ' AND citp.true_up_month BETWEEN ''' + CONVERT(VARCHAR(10),@prod_date_from,120) + ''' AND ''' + CONVERT(VARCHAR(10),@prod_date_to,120) + '''' ELSE '' END +'
			'+ CASE WHEN @counterparty_id <> '' THEN ' AND civv.counterparty_id IN('+@counterparty_id+')' ELSE '' END +'
			'+ CASE WHEN @contract_id <> '' THEN ' AND civv.contract_id IN('+@contract_id+')' ELSE '' END +'
			'+ CASE WHEN @created_time <> '' THEN ' AND CONVERT(VARCHAR(10),civv.create_ts,120) = '''+CONVERT(VARCHAR(10),@created_time,120)+'''' ELSE '' END
			 + CASE WHEN @show_adjusted_value = 'y' THEN  ' AND civ2.calc_id IS NOT NULL '  ELSE ' AND civ2.calc_id IS  NULL '  END

		--PRINT @SQL
		EXEC(@sql)

	END
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRY
			DELETE citu FROM calc_invoice_true_up citu
				INNER JOIN dbo.SplitCommaSeperatedValues(@true_up_id) a on a.item = citu.true_up_id

			EXEC spa_ErrorHandler 0, 
 				'view_adjustment', 
 				'spa_contract_settlement', 
 				'Success', 
 				'Changes have been saved successfully.',
 				''
	 	END TRY
 		BEGIN CATCH
		   IF @@TRANCOUNT > 0
           ROLLBACK
			
			DECLARE @DESC varchar(500)
			DECLARE @err_no varchar(100)
			SET @DESC = 'Fail to Delete Data ( Errr Description:' + ERROR_MESSAGE() + ').'
			SELECT @err_no = ERROR_NUMBER()

			EXEC spa_ErrorHandler @err_no
			   , 'view_adjustment'
			   , 'spa_contract_settlement'
			   , 'Error'
			   , @DESC
			   , ''
		END CATCH
	END
	ELSE IF @flag = 'f' -- Finalize the charge type to post in invoice.
	BEGIN

		IF OBJECT_ID('tempdb..#temp_calc_id') IS NOT NULL
			DROP TABLE #temp_calc_id

		SELECT 
			civv.calc_id org_calc_id ,MAX(civv1.calc_id) new_calc_id,MAX(civv1.finalized) finalized,civv.invoice_type invoice_type
		INTO 
			#temp_calc_id
		FROM 
			calc_invoice_volume_variance civv
			LEFT JOIN calc_invoice_volume_variance civv1 ON civv.counterparty_id = civv1.counterparty_id
				AND civv.contract_id = civv1.contract_id
				AND civv1.prod_date = @invoice_month
				AND ISNULL(civv1.invoice_template_id,-1) = COALESCE(NULLIF(@invoice_template,''),civv1.invoice_template_id,-1)
		WHERE
			civv.calc_id IN(SELECT item FROM dbo.SplitCommaSeperatedValues(@calc_id))
		GROUP BY civv.calc_id,civv.invoice_type


		IF EXISTS(SELECT 'x' FROM #temp_calc_id WHERE finalized = 'y')
		BEGIN
				EXEC spa_ErrorHandler 0
			, 'spa_view_process'
			, 'spa_view_process'
			, 'Error'
			, 'Invoice is already Finalized and cannot be adjusted for the selected Month.'
			, ''
		
		RETURN

		END


		IF EXISTS(SELECT 'X' FROM #temp_calc_id WHERE org_calc_id IS NOT NULL AND new_calc_id IS NOT NULL)
		BEGIN
		BEGIN TRY
		BEGIN TRAN
			INSERT INTO calc_invoice_volume (calc_id, invoice_line_item_id, prod_date, value, volume, finalized, inv_prod_date, finalized_date, manual_input)
			SELECT	tci.new_calc_id, invoice_line_item_id, true_up_month, value, citu.volume [volume], 'n' [finalized], NULL, GETDATE(), 'y'
			FROM calc_invoice_true_up citu
			INNER JOIN dbo.SplitCommaSeperatedValues(@true_up_id) ids ON citu.true_up_id = ids.item
			INNER JOIN #temp_calc_id tci ON tci.org_calc_id = citu.calc_id AND tci.new_calc_id IS NOT NULL
			
			UPDATE citu
			SET true_up_calc_id = tci.new_calc_id
			FROM calc_invoice_true_up citu
			INNER JOIN dbo.SplitCommaSeperatedValues(@true_up_id) ids ON citu.true_up_id = ids.item
			INNER JOIN #temp_calc_id tci ON tci.org_calc_id = citu.calc_id AND tci.new_calc_id IS NOT NULL
		COMMIT

		EXEC spa_ErrorHandler 0
			, 'spa_view_process'
			, 'spa_view_process'
			, 'Success'
			, 'Invoice Adjustment finalized successfully.'
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
	ELSE IF EXISTS(SELECT 'X' FROM #temp_calc_id WHERE org_calc_id IS NOT NULL AND new_calc_id IS NULL)
	BEGIN
		BEGIN TRY
		BEGIN TRAN
			DECLARE @new_invoice_number INT

			IF OBJECT_ID('tempdb..#temp_inserted_invoice') IS NOT NULL
			DROP TABLE #temp_inserted_invoice

			CREATE TABLE #temp_inserted_invoice(calc_id INT,counterparty_id INT,contract_id INT,prod_date DATETIME,invoice_type CHAR(1))
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
		   OUTPUT inserted.calc_id,inserted.counterparty_id,inserted.contract_id,inserted.prod_date,inserted.invoice_type INTO #temp_inserted_invoice	
			SELECT	CONVERT(DATE, GETDATE(),103)  [as_of_date],
					citu.counterparty_id,
					citu.contract_id,
					@invoice_month [production_date],
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
					MAX(citu.invoice_type) [invoice_type], 
					@invoice_month [production_date_to],
					MAX(dbo.FNAInvoiceDueDate(@invoice_month,cg.settlement_date,cg.holiday_calendar_id,cg.settlement_days)) [settlement_date], 
					CONVERT(DATE, GETDATE(),103) [finalized_date],
					@invoice_template [invoice_template],
					'y' [delta]
			FROM calc_invoice_true_up citu
				INNER JOIN dbo.SplitCommaSeperatedValues(@true_up_id) ids ON citu.true_up_id = ids.item
				INNER JOIN contract_group cg ON citu.contract_id = cg.contract_id
				INNER JOIN #temp_calc_id tci ON tci.org_calc_id = citu.calc_id AND tci.new_calc_id IS NULL
			GROUP BY 
				citu.counterparty_id, citu.contract_id



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
			SELECT	tii.calc_id [calc_id], 
					invoice_line_item_id, 
					true_up_month, 
					citu.value value, 
					citu.volume [volume], 
					'n' [finalized], 
					@invoice_month [invoice_prod_date], 
					CONVERT(DATE, GETDATE(),103) [finalized_date],
					'y'
			FROM calc_invoice_true_up citu
			INNER JOIN dbo.SplitCommaSeperatedValues(@true_up_id) ids ON citu.true_up_id = ids.item
			INNER JOIN #temp_calc_id tci ON tci.org_calc_id = citu.calc_id AND tci.new_calc_id IS NULL
			INNER JOIN #temp_inserted_invoice tii ON tii.counterparty_id = citu.counterparty_id
				AND  tii.contract_id = citu.contract_id
				AND  tii.prod_date =@invoice_month
				AND	 tci.invoice_type = citu.invoice_type
			--DECLARE @xml VARCHAR(500)
			--SET @xml = '<Root><PSRecordSet calc_id = "'+CAST(@new_calc_id AS VARCHAR(100))+'" finalized_date = ""></PSRecordSet></Root>'
			--EXEC  spa_update_invoice_number 'f', @xml 
			
			update civv
				SET civv.invoice_number = tii.calc_id
			FROM
				Calc_invoice_Volume_variance civv
				INNER JOIN #temp_inserted_invoice tii ON tii.calc_id = civv.calc_id


			UPDATE citu
			SET true_up_calc_id = tii.calc_id
			FROM calc_invoice_true_up citu
			INNER JOIN dbo.SplitCommaSeperatedValues(@true_up_id) ids ON citu.true_up_id = ids.item
			INNER JOIN #temp_calc_id tci ON tci.org_calc_id = citu.calc_id AND tci.new_calc_id IS NULL
			INNER JOIN #temp_inserted_invoice tii ON tii.counterparty_id = citu.counterparty_id
				AND  tii.contract_id = citu.contract_id
				AND  tii.prod_date =@invoice_month
				AND	 tci.invoice_type = citu.invoice_type

			--UPDATE calc_invoice_volume_variance SET finalized='y'  WHERE calc_id=@new_calc_id

		COMMIT

		EXEC spa_ErrorHandler 0
			, 'spa_view_process'
			, 'spa_view_process'
			, 'Success'
			, 'Invoice Adjustment finalized successfully.'
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

