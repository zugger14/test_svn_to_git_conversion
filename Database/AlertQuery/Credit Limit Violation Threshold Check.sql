SET NOCOUNT ON 
IF EXISTS (SELECT 1
           FROM   adiha_process.sys.tables
           WHERE  [name] = 'alert_credit_exposure_process_id_ace')
  BEGIN
     
	IF  OBJECT_ID('tempdb..#cpty_unique_list') IS NOT NULL
		DROP TABLE #cpty_unique_list
	IF OBJECT_ID('tempdb..#temp_counterparty_credit_data') IS NOT NULL
		DROP TABLE #temp_counterparty_credit_data
	IF OBJECT_ID('tempdb..#min_violation') IS NOT NULL
		DROP TABLE #min_violation
	IF OBJECT_ID('tempdb..#credit_limit_violated') IS NOT NULL
		DROP TABLE #credit_limit_violated
	IF OBJECT_ID('tempdb..#max_violation') IS NOT NULL
		DROP TABLE #max_violation
	IF OBJECT_ID('tempdb..#limit_violation') IS NOT NULL
		DROP TABLE #limit_violation
      -- Same counterparty can mapped in multiple subsidiary so collect only one information. --adiha_process.dbo.alert_credit_exposure_process_id_ace 
      SELECT DISTINCT counterparty_id,
			as_of_date,
			internal_counterparty_id,
			contract_id
      INTO   #cpty_unique_list
      FROM  staging_table.alert_credit_exposure_process_id_ace

      SELECT ced.source_counterparty_id,
             ccl.internal_counterparty_id,
             Max(sc1.counterparty_name)
             internal_counterparty,
             ccl.contract_id,
             Max(cg.contract_name)  AS [CONTRACT],
             a.as_of_date,
             Max(sc.counterparty_name)  [Counterparty],
             Round(Sum(Isnull(d_effective_exposure_to_us, 0)), 2) [effective exposure],
             Round(Sum(limit_available_to_them), 2) limit_available,
             Round(Sum(ced.limit_provided), 0)  [Limit]
		INTO   #temp_counterparty_credit_data
		FROM   #cpty_unique_list a
        INNER JOIN credit_exposure_summary ced ON a.counterparty_id = ced.source_counterparty_id
                AND a.as_of_date = ced.as_of_date
                AND ( ced.internal_counterparty_id = a.internal_counterparty_id OR NULLIF(a.internal_counterparty_id, '') IS NULL)
                AND ( ced.contract_id = a.contract_id OR NULLIF(a.contract_id, '') IS NULL )
		INNER JOIN source_counterparty sc ON ced.source_counterparty_id=sc.source_counterparty_id
        LEFT JOIN counterparty_credit_limits AS ccl ON a.counterparty_id = ccl.counterparty_id
			AND ( a.internal_counterparty_id = ccl.internal_counterparty_id OR NULLIF(ccl.internal_counterparty_id, '') IS NULL)
            AND ( a.contract_id = ccl.contract_id OR NULLIF(ccl.contract_id, '') IS NULL )
        LEFT JOIN source_counterparty sc1 ON sc1.source_counterparty_id = a.internal_counterparty_id
        LEFT JOIN contract_group cg ON cg.contract_id = ccl.contract_id
      WHERE  ced.as_of_date = a.as_of_date
      GROUP  BY ced.source_counterparty_id,
                ccl.internal_counterparty_id,
                ccl.contract_id,
                a.as_of_date
      ORDER  BY ced.source_counterparty_id,
                ccl.internal_counterparty_id,
				ccl.contract_id,
                a.as_of_date

      SELECT [source_counterparty_id],
             internal_counterparty,
             [contract],
             [counterparty],
             [effective exposure],
             limit_available,
             limit,
             ccl.max_threshold,
             ccl.min_threshold
      INTO   #credit_limit_violated
      FROM   #temp_counterparty_credit_data a
             INNER JOIN counterparty_credit_info cci
                     ON a.[source_counterparty_id] = cci.counterparty_id
             OUTER apply (SELECT TOP(1) ccl.internal_counterparty_id,
                                        ccl.contract_id,
                                        ccl.effective_date,
                                        Isnull(ccl.min_threshold, 0)
                                        min_threshold
                                        ,
                         Isnull(ccl.max_threshold, 0) max_threshold
                          FROM   counterparty_credit_limits ccl
                          WHERE  ccl.counterparty_id = a.source_counterparty_id
                                 AND ( ccl.internal_counterparty_id =
                                       a.internal_counterparty_id
                                        OR NULLIF(ccl.internal_counterparty_id,
                                           ''
                                           ) IS
                                           NULL )
                                 AND ( ccl.contract_id = a.contract_id
                                        OR NULLIF(ccl.contract_id, '') IS NULL )
                                 AND a.as_of_date >= ccl.effective_date
                          ORDER  BY
                    Isnull(NULLIF(ccl.internal_counterparty_id, ''), 9999999),
                    Isnull(NULLIF(ccl.contract_id, ''), 9999999),
                    ccl.effective_date) ccl

      SELECT [source_counterparty_id],
             internal_counterparty,
             [contract],
             [counterparty],
             [effective exposure],
             limit_available,
             limit,
             ( ( Isnull(min_threshold, 0) * [limit] ) / 100 ) [Min Threshold],
             ( ( Isnull(max_threshold, 0) * [limit] ) / 100 ) [Max Threshold],
             'Minimum Threshold Reached'
             [Notification Type]
      INTO   #min_violation
      FROM   #credit_limit_violated
      WHERE  ( [effective exposure] > ( ( Isnull(min_threshold, 100) * [limit] )
                                        /
                                        100 ) )
             AND limit_available > 0

      SELECT [source_counterparty_id],
             internal_counterparty,
             [contract],
             [counterparty],
             [effective exposure],
             limit_available,
             limit,
             ( ( Isnull(min_threshold, 0) * [limit] ) / 100 )
             [Min Threshold],
             ( ( Isnull(max_threshold, 100) * [limit] ) / 100 )
             [Max Threshold],
             'Maximum Threshold Reached and Counterparty is blocked'
             [Notification Type]
      INTO   #max_violation
      FROM   #credit_limit_violated
      WHERE  ( [effective exposure] > ( ( Isnull(max_threshold, 100) * [limit] )
                                        /
                                        100 ) )
             AND limit_available < 0

      SELECT [source_counterparty_id],
             internal_counterparty,
             [contract],
             [counterparty],
             [effective exposure],
             limit_available,
             limit,
             ( ( Isnull(min_threshold, 0) * [limit] ) / 100 )   [Min Threshold],
             ( ( Isnull(max_threshold, 100) * [limit] ) / 100 ) [Max Threshold],
             'Limit Violation'
             [Notification Type]
      INTO   #limit_violation
      FROM   #credit_limit_violated
      WHERE  ( [effective exposure] < ( ( Isnull(max_threshold, 100) * [limit] )
                                        /
                                        100 ) )
             AND limit_available < 0

      SELECT [Counterparty],
			internal_counterparty [Internal Counterparty],
            [Contract],
           REPLACE(CONVERT(VARCHAR, CAST(ROUND([Effective Exposure],0) AS MONEY), 1), '.00', '') [Effective Exposure],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Limit],0) AS MONEY), 1), '.00', '')                 [Limit],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Min threshold],0)AS MONEY), 1), '.00', '')     [Min threshold],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Max threshold],0) AS MONEY), 1), '.00', '') [Max threshold],
			REPLACE(CONVERT(VARCHAR, CAST(ROUND(limit_available,0)  AS MONEY), 1), '.00', '')       [ Limit Available],
             'Minimum Threshold Reached' [Notification Type]
		INTO  adiha_process.dbo.credit_limit_violation_process_id_clv 
      FROM   #min_violation
      UNION ALL
      SELECT [Counterparty],
			internal_counterparty [Internal Counterparty],
            [Contract],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Effective Exposure],0) AS MONEY), 1), '.00', '') [Effective Exposure],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Limit],0) AS MONEY), 1), '.00', '')                 [Limit],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Min threshold],0)AS MONEY), 1), '.00', '')     [Min threshold],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Max threshold],0) AS MONEY), 1), '.00', '') [Max threshold],
			REPLACE(CONVERT(VARCHAR, CAST(ROUND(limit_available,0)  AS MONEY), 1), '.00', '')       [ Limit Available],
             'Maximum Threshold Reached and Counterparty is blocked'
             [Notification Type]
      FROM   #max_violation
      UNION ALL
      SELECT 
			[Counterparty],
			internal_counterparty [Internal Counterparty],
            [Contract],
           REPLACE(CONVERT(VARCHAR, CAST(ROUND([Effective Exposure],0) AS MONEY), 1), '.00', '') [Effective Exposure],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Limit],0) AS MONEY), 1), '.00', '')                 [Limit],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Min threshold],0)AS MONEY), 1), '.00', '')     [Min threshold],
            REPLACE(CONVERT(VARCHAR, CAST(ROUND([Max threshold],0) AS MONEY), 1), '.00', '') [Max threshold],
			REPLACE(CONVERT(VARCHAR, CAST(ROUND(limit_available,0)  AS MONEY), 1), '.00', '')       [ Limit Available],
            'Limit Violation'     [Notification Type]
      FROM   #limit_violation

	DECLARE @counterparty_id VARCHAR(MAX)  
    SELECT @counterparty_id = COALESCE(@counterparty_id+',' ,'') + cast(source_counterparty_id as varchar)
    FROM (SELECT 
				DISTINCT sc.source_counterparty_id
           FROM adiha_process.dbo.credit_limit_violation_process_id_clv  clvp 
		   INNER JOIN source_counterparty AS sc ON sc.counterparty_name = clvp.[Counterparty] 
			WHERE [Notification Type] = 'Maximum Threshold Reached and Counterparty is blocked') t

		DELETE ccbt
		FROM counterparty_credit_block_trading ccbt
		INNER JOIN #cpty_unique_list cul ON cul.counterparty_id = ccbt.counterparty_id
			AND cul.contract_id = ccbt.[contract]
			AND ISNULL(cul.internal_counterparty_id, -1) = COALESCE(ccbt.internal_counterparty_id, cul.internal_counterparty_id, -1)
		INNER JOIN counterparty_contract_address cca ON cca.counterparty_id = cul.counterparty_id
			AND cul.contract_id = cca.contract_id
			AND ISNULL(cul.internal_counterparty_id, -1) = COALESCE(cca.internal_counterparty_id, cul.internal_counterparty_id, -1)

		INSERT INTO counterparty_credit_block_trading (
			counterparty_contract_address_id,
			counterparty_id, 
			[contract], 
			internal_counterparty_id,
			buysell_allow,
			buy_sell)
		SELECT DISTINCT
			cca.counterparty_contract_address_id,
			cca.counterparty_id, 
			cca.contract_id, 
			cca.internal_counterparty_id,
			'y',
			'3'
		FROM counterparty_contract_address cca
		INNER JOIN #cpty_unique_list cul ON cul.counterparty_id = cca.counterparty_id
			AND cul.contract_id = cca.contract_id
			AND ISNULL(cul.internal_counterparty_id, -1) = COALESCE(cca.internal_counterparty_id, cul.internal_counterparty_id, -1)
	  
		IF NOT EXISTS (SELECT 1 FROM adiha_process.dbo.credit_limit_violation_process_id_clv) 
        BEGIN 
            RETURN 
        END 
		
		DECLARE @top_counterparty_id INT
		DECLARE @top_contract_id INT
		DECLARE @top_internal_counterparty_id INT 

		SELECT TOP(1) @top_counterparty_id = counterparty_id, 
			@top_contract_id = contract_id 
		FROM adiha_process.dbo.alert_credit_exposure_process_id_ace 
		ORDER BY contract_id DESC

		DELETE a 
		FROM adiha_process.dbo.alert_credit_exposure_process_id_ace a
		LEFT JOIN (
		SELECT * FROM adiha_process.dbo.alert_credit_exposure_process_id_ace
				WHERE counterparty_id = @top_counterparty_id 
				AND contract_id = @top_contract_id											
		) b ON a.counterparty_id = b.counterparty_id AND a.contract_id=b.contract_id
		WHERE b.counterparty_id IS NULL

  END