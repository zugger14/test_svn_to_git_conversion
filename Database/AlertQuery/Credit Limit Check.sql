IF EXISTS (
		SELECT *
		FROM adiha_process.sys.tables
		WHERE [name] = 'alert_counterparty_process_id_ac'
		)
BEGIN
	DECLARE @as_of_date DATE

	SELECT @as_of_date = as_of_date
	FROM adiha_process.dbo.alert_counterparty_process_id_ac

	CREATE TABLE #credit_exposure_detail (
		counterparty_id INT
		,counterparty_name VARCHAR(250)
		,parent_counterparty VARCHAR(250)
		,Total_Limit_Provided FLOAT
		,exposure_to_us FLOAT
		,limit_available_to_us FLOAT
		,limit_provided FLOAT
		,gross_exposure FLOAT
		,limit_to_us_variance FLOAT
		,as_of_date DATE
		)

	INSERT INTO #credit_exposure_detail (
		counterparty_name
		,counterparty_id
		,parent_counterparty
		,as_of_date
		,exposure_to_us
		,limit_provided
		,gross_exposure
		,limit_to_us_variance
		,limit_available_to_us
		,Total_Limit_Provided
		)
	EXEC spa_credit_exposure_calculation_report 'a'
		,@as_of_date
		,NULL
		,NULL

	SELECT MAX(ced.counterparty_id) [Id]
		,ced.counterparty_name [Counterparty]
		,MAX(ced.parent_counterparty) [Parent Counterparty]
		,ROUND(MAX(ISNULL(exposure_to_us, 0)), 2) [Net Exposure]
		,ROUND(MAX(limit_to_us_variance), 2) [Credit Available]
		,ROUND(MAX(limit_provided), 2) [Limit]
		,ROUND(SUM(ced.gross_exposure), 2) [Gross Exposure]
		,ROUND(MAX(ced.limit_to_us_variance), 2) [Limit Variance]
		,ROUND(MAX(total_limit_provided), 2) [Total Limit Provided]
	INTO #temp_counterparty_credit_data
	FROM #credit_exposure_detail ced
	INNER JOIN adiha_process.dbo.alert_counterparty_process_id_ac a ON a.counterparty_id = ced.counterparty_id
	WHERE ced.as_of_date = @as_of_date
	GROUP BY ced.counterparty_name
	ORDER BY ced.counterparty_name

	SELECT [Id]
		,[Counterparty]
		,[Parent Counterparty]
		,[Net Exposure]
		,[Limit]
		,[Total Limit Provided]
		,[Credit Available]
		,[Limit Variance]
		,((ISNULL(cci.min_threshold, 0) * [Limit]) / 100) [Min Threshold]
		,((ISNULL(cci.max_threshold, 100) * [Limit]) / 100) [Max Threshold]
		,'Exposure exceeded counterparty credit limit.' [Notification Type]
	INTO #max_violated
	FROM #temp_counterparty_credit_data a
	INNER JOIN counterparty_credit_info cci ON a.[Id] = cci.Counterparty_id
	WHERE [Limit Variance] < 0

	SELECT [Counterparty]
		,[Total Limit Provided] AS [Credit Limit]
		,[Net Exposure]
		,[Credit Available]
		,[Notification Type] AS [Description]
	INTO staging_table.alert_credit_exposure_output_process_id_aceo
	FROM #max_violated
	ORDER BY [Counterparty]

	IF EXISTS (
			SELECT 1
			FROM staging_table.alert_credit_exposure_output_process_id_aceo
			)
	BEGIN
		EXEC spa_insert_alert_output_status var_alert_sql_id
			,'process_id'
			,NULL
			,NULL
			,NULL

		IF EXISTS (
				SELECT 1
				FROM #max_violated
				)
		BEGIN
			UPDATE cci
			SET account_status = 10085
			FROM counterparty_credit_info cci
			INNER JOIN #max_violated mv ON mv.[Id] = cci.Counterparty_id

			UPDATE alert_workflows
			SET workflow_trigger = 'y'
			WHERE alert_workflows_id = 2 -- to be changed. Should take workflow id defined in alert

			SELECT id
				,5 [sql_id]
			INTO staging_table.nested_alert_new_process_id_na
			FROM #max_violated -- Should take id of Counterparty Approval Alert 		

			EXEC spa_run_alert_sql 5
				,'new_process_id'
				,NULL
				,NULL
				,NULL -- Should take id of Counterparty Approval Alert 		
		END
	END

	DROP TABLE #max_violated

	DROP TABLE #temp_counterparty_credit_data

	DROP TABLE #credit_exposure_detail
END