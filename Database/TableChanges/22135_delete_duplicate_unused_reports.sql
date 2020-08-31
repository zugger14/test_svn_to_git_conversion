BEGIN TRY
	BEGIN TRAN
		DECLARE @report_ids VARCHAR(MAX)

		IF OBJECT_ID('tempdb..#del_report_ids') IS NOT NULL
		DROP TABLE #del_report_ids

		SELECT report_id
		INTO #del_report_ids
		FROM report
		WHERE [name] IN (
			'Cash Flow Report',
			'EOD - Derive Power Prices',
			'Monthly Position Summary Report By Book',
			'Gas Position Report',
			'MTM Export Report',
			'MTM Detail Report',
			'Delta Position Report',
			'NFC PnL Sensitivities Report',
			'Contract Settlement Report',
			'PNL Pivot Report',
			'PNL Report'
		)

		SELECT TOP 1 @report_ids = 
		STUFF(
				(
					SELECT ',' + CAST(report_id AS VARCHAR(20)) + ''
					FROM #del_report_ids
					FOR XML PATH('')
				), 1, 1, ''
		)
		FROM #del_report_ids

		EXEC spa_rfx_report @flag = 'd', @report_id = @report_ids, @process_id = NULL

		COMMIT TRAN
ENd TRY
BEGIN CATCH
	DECLARE @error NVARCHAR(MAX) = 'Error Occurred: ' + ERROR_MESSAGE()

	RAISERROR (@error, 16, 1)
	
	IF @@TRANCOUNT > 0 ROLLBACK TRAN
END CATCH

GO