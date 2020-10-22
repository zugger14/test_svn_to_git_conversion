SET NOCOUNT ON

IF OBJECT_ID(N'[dbo].spa_counterparty_credit_limits', N'P ') IS NOT NULL 
	DROP PROCEDURE [dbo].spa_counterparty_credit_limits
GO
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**
	Insert/update values in the table counterparty_credit_limits

	Parameters
	@flag	:	Operation Flag
	@xml	:	XML String of the Data to be inserted/updated
	@counterparty_credit_limit_id	:	Counterparty Credit Limit id
	@counterparty_id	:	Counterparty id
*/

CREATE PROCEDURE [dbo].[spa_counterparty_credit_limits]
		@flag AS CHAR(1),
		@xml VARCHAR(MAX) = NULL,
		@counterparty_credit_limit_id VARCHAR(50) = NULL,
		@counterparty_id INT = NULL
AS
/********Debug************
		DECLARE
		@flag AS CHAR(1),
		@xml VARCHAR(MAX) = NULL,
		@counterparty_credit_limit_id VARCHAR(50) = NULL,
		@counterparty_id INT = NULL

		SELECT @flag='u',@xml='<Root function_id="10181313"><FormXML  counterparty_credit_limit_id="308" internal_counterparty_id="" contract_id="12530" effective_Date="2019-09-01" credit_limit="110000" credit_limit_to_us="" currency_id="1" max_threshold="" min_threshold="" tenor_limit="" counterparty_id="7672" threshold_provided="" threshold_received="" limit_status=""></FormXML></Root>'
--**************/

SET NOCOUNT ON
DECLARE @sql VARCHAR(5000), @idoc INT
DECLARE @status_pre INT,@credit_limit_pre FLOAT,@watch_list_pre CHAR(1),@counterparty_name NVARCHAR(1000), @debt_rating_pre VARCHAR(100)

IF @flag IN ('i', 'u')
BEGIN
	BEGIN TRAN
	BEGIN TRY
		EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

		IF OBJECT_ID('tempdb..#temp_counterparty_credit_limits') IS NOT NULL
			DROP TABLE #temp_counterparty_credit_limits
		SELECT
			NULLIF(counterparty_credit_limit_id, '') counterparty_credit_limit_id,
			CASE WHEN effective_Date = '' THEN NULL ELSE effective_Date END AS effective_Date,
			CASE WHEN CAST(credit_limit AS VARCHAR(50)) = '' THEN NULL ELSE credit_limit END AS credit_limit,
			--NULLIF(CAST(credit_limit_to_us AS VARCHAR(50)), '') credit_limit_to_us,
			NULLIF(credit_limit_to_us, '') credit_limit_to_us,
			CASE WHEN tenor_limit = '' THEN NULL ELSE tenor_limit END AS tenor_limit,
			NULLIF(max_threshold, '') AS max_threshold,
			NULLIF(min_threshold, '') AS min_threshold,
			counterparty_id,
			NULLIF(internal_counterparty_id, '') AS internal_counterparty_id,
			NULLIF(contract_id, '') AS contract_id,
			NULLIF(currency_id, '') currency_id,
			NULLIF(threshold_received, '') threshold_received,
			NULLIF(threshold_provided, '') threshold_provided,
			NULLIF(limit_status, '') limit_status
		INTO #temp_counterparty_credit_limits
		FROM OPENXML(@idoc, '/Root/FormXML', 1)
		WITH (
			counterparty_credit_limit_id INT,
			effective_Date DATETIME,
			credit_limit FLOAT,
			credit_limit_to_us FLOAT,
			tenor_limit INT,
			max_threshold FLOAT,
			min_threshold FLOAT,
			counterparty_id INT,
			internal_counterparty_id INT,
			contract_id INT,
			currency_id INT,
			threshold_received FLOAT,
			threshold_provided FLOAT,
			limit_status INT
		)

		--select * from #temp_counterparty_credit_limits 
		--select * from counterparty_credit_limits where counterparty_id = 8884
		--return


		--SELECT * FROM counterparty_credit_limits ccl
		--	INNER JOIN #temp_counterparty_credit_limits tccl
		--		ON ISNULL(tccl.contract_id, '') = ISNULL(ccl.contract_id, '')
		--			AND ISNULL(tccl.internal_counterparty_id, '') = ISNULL(ccl.internal_counterparty_id,'')
		--			AND tccl.effective_Date = ccl.effective_Date
		--			AND tccl.counterparty_id = ccl.counterparty_id

		--WHERE ccl.counterparty_credit_limit_id <> tccl.counterparty_credit_limit_id
		--			RETURN

		IF EXISTS(
			SELECT 1 FROM counterparty_credit_limits ccl
			INNER JOIN #temp_counterparty_credit_limits tccl
				ON ISNULL(tccl.contract_id, '') = ISNULL(ccl.contract_id, '')
					AND ISNULL(tccl.internal_counterparty_id, '') = ISNULL(ccl.internal_counterparty_id,'')
					AND tccl.effective_Date = ccl.effective_Date
					AND ISNULL(tccl.counterparty_id, '') = ISNULL(ccl.counterparty_id, '')
			WHERE ISNULL(ccl.counterparty_credit_limit_id, '') <> ISNULL(tccl.counterparty_credit_limit_id, '')
		) 
		BEGIN
			EXEC spa_ErrorHandler 1
				, 'Conterparty Credit Limit'
				, 'spa_counterparty_credit_limits'
				, 'DB Error'
				, 'Duplicate data in <b>Internal Counterparty</b>, <b>Contract</b> and <b>Effective Date</b>'
				, 'credit limit should not be duplicate'

			COMMIT
			RETURN 
		END

	
		SELECT @counterparty_id = t.counterparty_id FROM #temp_counterparty_credit_limits AS t
		SELECT @counterparty_credit_limit_id = t.counterparty_credit_limit_id FROM #temp_counterparty_credit_limits AS t
		IF EXISTS (SELECT 1 FROM counterparty_credit_limits ccl
		INNER JOIN #temp_counterparty_credit_limits tccl
			ON ISNULL(tccl.contract_id, '') = ISNULL(ccl.contract_id, '')
			AND ISNULL(tccl.internal_counterparty_id, '') = ISNULL(ccl.internal_counterparty_id,'')
			AND ISNULL(tccl.credit_limit, '') = ISNULL(ccl.credit_limit, '')
			AND ISNULL(tccl.credit_limit_to_us, '') = ISNULL(ccl.credit_limit_to_us, '')
			AND tccl.effective_Date = ccl.effective_Date
			AND tccl.currency_id = ccl.currency_id
			AND tccl.counterparty_id = ccl.counterparty_id
			AND tccl.counterparty_credit_limit_id <> ccl.counterparty_credit_limit_id
			  )
		BEGIN
			DELETE ccl FROM counterparty_credit_limits ccl
			INNER JOIN #temp_counterparty_credit_limits tccl
				ON ISNULL(tccl.contract_id, '') = ISNULL(ccl.contract_id,'')
				AND ISNULL(tccl.internal_counterparty_id, '') = ISNULL(ccl.internal_counterparty_id, '')
				AND ISNULL(tccl.credit_limit, '') = ISNULL(ccl.credit_limit, '')
				AND ISNULL(tccl.credit_limit_to_us, '') = ISNULL(ccl.credit_limit_to_us, '')
				AND tccl.effective_Date = ccl.effective_Date
				AND tccl.currency_id = ccl.currency_id
				AND tccl.counterparty_id = ccl.counterparty_id
				AND tccl.counterparty_credit_limit_id <> ccl.counterparty_credit_limit_id
		END
		IF @flag = 'i'
		BEGIN
			INSERT INTO counterparty_credit_limits
			(
				effective_Date,
				credit_limit,
				credit_limit_to_us,
				tenor_limit,
				max_threshold,
				min_threshold,
				counterparty_id,
				internal_counterparty_id,
				contract_id,
				currency_id,
				create_user,
				create_ts,
				threshold_received,
				threshold_provided,
				limit_status
			)
			SELECT
				effective_Date,
				credit_limit,
				credit_limit_to_us,
				tenor_limit,
				max_threshold,
				min_threshold,
				counterparty_id,
				internal_counterparty_id,
				contract_id,
				currency_id,
				dbo.FNADBUser(),
				CURRENT_TIMESTAMP,
				threshold_received,
				threshold_provided,
				limit_status
			FROM #temp_counterparty_credit_limits

			SET @counterparty_credit_limit_id = SCOPE_IDENTITY()
			SELECT @counterparty_name=sc.counterparty_name FROM source_counterparty sc
			INNER JOIN counterparty_credit_limits cci ON cci.counterparty_id = sc.source_counterparty_id
			WHERE  cci.counterparty_credit_limit_id = @counterparty_credit_limit_id

			--print @counterparty_credit_limit_id
		END
		IF @flag = 'u'
		BEGIN
			--COLLECT PREVIOUS DATA
			SELECT 
				@credit_limit_pre=ISNULL(credit_limit, 0),
				@counterparty_name=sc.counterparty_name,
				@Counterparty_id = sc.source_counterparty_id
			FROM source_counterparty sc
			INNER JOIN counterparty_credit_limits cci ON cci.counterparty_id = sc.source_counterparty_id
			WHERE  cci.counterparty_credit_limit_id = @counterparty_credit_limit_id

			UPDATE c
			SET effective_Date = t.effective_Date,
				credit_limit = t.credit_limit,
				credit_limit_to_us = t.credit_limit_to_us,
				tenor_limit = t.tenor_limit,
				max_threshold = t.max_threshold,
				min_threshold = t.min_threshold,
				counterparty_id = t.counterparty_id,
				internal_counterparty_id = t.internal_counterparty_id,
				contract_id = t.contract_id,
				currency_id = t.currency_id,
				threshold_received = t.threshold_received,
				threshold_provided = t.threshold_provided,
				limit_status = t.limit_status
			FROM #temp_counterparty_credit_limits AS t
			INNER JOIN counterparty_credit_limits c ON c.counterparty_credit_limit_id=t.counterparty_credit_limit_id
	
		
		END	

		-- alert
		DECLARE @process_table VARCHAR(500)
		DECLARE @sql_stmt VARCHAR(MAX)
		DECLARE @process_id VARCHAR(200)
		DECLARE @set_up_as_of_date VARCHAR(30)
		SELECT @set_up_as_of_date = as_of_date FROM module_asofdate
		SET @process_id = dbo.FNAGetNewID()  
		SET @process_table = 'adiha_process.dbo.counterparty_credit_limits_' + @process_id + '_ccl'

		SET @sql_stmt = 'CREATE TABLE ' + @process_table + '
							(
	                 		counterparty_id    INT,
	                 		counterparty_credit_limit_id INT,
	                 		counterparty_name  VARCHAR(200),
	                 		debt_rating        VARCHAR(200),
	                 		credit_limit       float,
	                 		as_of_date			VARCHAR(30),
	                 		hyperlink1 VARCHAR(5000), 
         					hyperlink2 VARCHAR(5000), 
         					hyperlink3 VARCHAR(5000), 
         					hyperlink4 VARCHAR(5000), 
         					hyperlink5 VARCHAR(5000)
							)
						INSERT INTO ' + @process_table + '(
							counterparty_id,
							counterparty_credit_limit_id,
							counterparty_name,
							credit_limit,
							as_of_date
							)
						SELECT ' +  CAST(@Counterparty_id AS VARCHAR(30)) + ',
							''' + CAST(@counterparty_credit_limit_id AS VARCHAR(30)) + ''',	
							''' + @counterparty_name + ''',
							' + CAST(ISNULL(@credit_limit_pre, '') AS VARCHAR(30))+ ',
							''' + @set_up_as_of_date + ''''

		EXEC(@sql_stmt)

		IF @flag = 'u'
			EXEC spa_register_event 20609, 20524, @process_table, 1, @process_id
		ELSE IF @flag = 'i'
			EXEC spa_register_event 20609, 20570, @process_table, 1, @process_id

		EXEC spa_register_event 20609, 20577, @process_table, 1, @process_id
		--end of alert	
		COMMIT
		EXEC spa_ErrorHandler 0, 
			'Conterparty Credit Limit', 
			'spa_counterparty_credit_limits', 
			'Success', 
			'Changes have been saved successfully.', 
			''
	END TRY
	BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK
	DECLARE @error_desc VARCHAR(500) = ERROR_MESSAGE()
	EXEC spa_ErrorHandler 1, 
		'Conterparty Credit Limit', 
		'spa_counterparty_credit_limits', 
		'DB Error', 
		'Failed to insert Conterparty Credit Limit.',
		@error_desc
	END CATCH
END

ELSE IF @flag='d'
BEGIN
	IF EXISTS (SELECT c.counterparty_credit_limit_id  FROM counterparty_credit_limits c INNER JOIN dbo.SplitCommaSeperatedValues(@counterparty_credit_limit_id) scsv ON scsv.item = c.counterparty_credit_limit_id )
		BEGIN
		SET @sql = '
		DELETE FROM master_view_counterparty_credit_limits
		WHERE counterparty_credit_limit_id IN( '+ @counterparty_credit_limit_id + ' )
		
		DELETE FROM counterparty_credit_limits
		WHERE counterparty_credit_limit_id IN( '+ @counterparty_credit_limit_id + ' )'
			
		EXEC(@sql)
		EXEC spa_ErrorHandler 0,
			'Counterparty Credit Limit',
			'spa_counterparty_credit_limits', 
			'Success', 
			'Changes have been saved successfully.', 
			''
		END        
	ELSE
	BEGIN 
    EXEC spa_ErrorHandler 1, 
		'Counterparty Credit Limit', 
		'spa_counterparty_credit_limits',
			'Error', 
			'Failed to delete Counterparty Credit Limit.', 
			''
	END
END

ELSE IF @flag = 'g' --Counterparty Credit Info Limit DHTMLX Grid
BEGIN
	SELECT	
			ISNULL(sca.counterparty_name, '') [internal_counterparty],
			ISNULL(ccl.counterparty_credit_limit_id, '') [limit_id],
			ccl.counterparty_credit_limit_id [system_id],
			cg.contract_name [Contract],
			sc.counterparty_name [Counterparty], 
			dbo.fnadateformat(ccl.effective_Date) [Effective Date], 
			scu.currency_name [Currency],
			ccl.credit_limit [Credit Limit], 
			ccl.credit_limit_to_us [Credit Limit To Us], 
			ccl.max_threshold [Max Threshold],
			ccl.min_threshold [Min Threshold], 
			ccl.tenor_limit [Tenor Limit],
			sdv.code [Limit Status]
	FROM  counterparty_credit_limits AS ccl 
	LEFT JOIN source_counterparty AS sc ON sc.source_counterparty_id = ccl.counterparty_id 
	LEFT JOIN source_counterparty  AS sca ON ccl.internal_counterparty_id = sca.source_counterparty_id
	LEFT JOIN source_currency scu ON scu.source_currency_id = ccl.currency_id
	LEFT JOIN contract_group AS cg ON cg.contract_id = ccl.contract_id
	LEFT JOIN static_data_value AS sdv ON sdv.value_id = ccl.limit_status 
	WHERE ccl.counterparty_id=@Counterparty_id
END

GO
