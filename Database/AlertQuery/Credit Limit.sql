IF EXISTS (
       SELECT *
       FROM   adiha_process.sys.tables
       WHERE  [name] = 'alert_counterparty_process_id_ac'
   )
BEGIN
	-- Same counterparty can mapped in multiple subsidiary so collect only one information.	--adiha_process.dbo.alert_counterparty_process_id_ac
	SELECT DISTINCT counterparty_id,as_of_date,internal_counterparty_id, contract_id
	INTO #cpty_unique_list
	FROM staging_table.alert_counterparty_process_id_ac	

    SELECT ced.Source_Counterparty_ID
          ,a.internal_counterparty_id
          ,MAX(sc1.counterparty_name)     internal_counterparty
          ,a.contract_id
          ,MAX(cg.contract_name)       AS [CONTRACT]
          ,a.as_of_date
          ,MAX(ced.counterparty_name) [Counterparty]
          ,ROUND(SUM(ISNULL(d_net_exposure_to_us ,0)) ,2) net_exposure
          ,ROUND(SUM(limit_available_to_them) ,2) limit_available
          ,ROUND(
               SUM(
                   ced.limit_provided+ced.collateral_received+ced.cash_collateral_received
               )
              ,0
           ) [Limit]
    INTO   #temp_counterparty_credit_data
    FROM   #cpty_unique_list a
           INNER JOIN credit_exposure_detail ced
                ON  a.counterparty_id = ced.Source_Counterparty_ID
                    AND a.as_of_date = ced.as_of_date
                    AND (
                            ced.internal_counterparty_id=a.internal_counterparty_id
                            OR NULLIF(a.internal_counterparty_id ,'') IS NULL
                        )
                    AND (
                            ced.contract_id=a.contract_id
                            OR NULLIF(a.contract_id ,'') IS NULL
                        )
           LEFT JOIN counterparty_credit_limits AS ccl
                ON  a.counterparty_id = ccl.counterparty_id
                    AND (
                            a.internal_counterparty_id=ccl.internal_counterparty_id
                            OR NULLIF(ccl.internal_counterparty_id ,'') IS NULL
                        )
                    AND (
                            a.contract_id=ccl.contract_id
                            OR NULLIF(ccl.contract_id ,'') IS NULL
                        )
           LEFT JOIN source_counterparty sc1
                ON  sc1.source_counterparty_id = a.internal_counterparty_id
           LEFT JOIN contract_group cg
                ON  cg.contract_id = a.contract_id
    WHERE  ced.as_of_date = a.as_of_date
    GROUP BY
           ced.Source_Counterparty_ID
          ,a.internal_counterparty_id
          ,a.contract_id
          ,a.as_of_date
    ORDER BY
           ced.Source_Counterparty_ID
          ,a.internal_counterparty_id
          ,a.contract_id
          ,a.as_of_date
    
    
    
    SELECT [Source_Counterparty_ID]
          ,internal_counterparty
          ,[CONTRACT]
          ,[Counterparty]
          ,net_exposure
          ,limit_available
          ,limit
          ,((ISNULL(ccl.min_threshold ,0)*[Limit])/100) [Min Threshold]
          ,((ISNULL(ccl.max_threshold ,100)*[Limit])/100) [Max Threshold]
          ,'Minimum Threshold Violation Warning' [Notification Type]
    INTO     #min_violated
    FROM   #temp_counterparty_credit_data a
           INNER JOIN counterparty_credit_info cci
                ON  a.Source_Counterparty_ID = cci.Counterparty_id
           OUTER APPLY (
        SELECT TOP(1) ccl.internal_counterparty_id
              ,ccl.contract_id
              ,ccl.effective_date
              ,ISNULL(ccl.min_threshold ,0) min_threshold
              ,ISNULL(ccl.max_threshold ,0) max_threshold
        FROM   counterparty_credit_limits ccl
        WHERE  ccl.counterparty_id = a.Source_Counterparty_ID
               AND (
                       ccl.internal_counterparty_id=a.internal_counterparty_id
                       OR NULLIF(ccl.internal_counterparty_id ,'') IS NULL
                   )
               AND (
                       ccl.contract_id=a.contract_id
                       OR NULLIF(ccl.contract_id ,'') IS NULL
                   )
               AND a.as_of_date>= ccl.effective_date
        ORDER BY
               ISNULL(NULLIF(ccl.internal_counterparty_id ,'') ,9999999)
              ,ISNULL(NULLIF(ccl.contract_id ,'') ,9999999)
              ,ccl.effective_date
    ) ccl
    WHERE  (
               limit_available>0
               AND net_exposure>((ISNULL(ccl.min_threshold ,0)*a.limit)/100)
           )
    
    
    SELECT [Source_Counterparty_ID]
          ,internal_counterparty
          ,[CONTRACT]
          ,[Counterparty]
          ,net_exposure
          ,limit_available
          ,limit
          ,((ISNULL(ccl.min_threshold ,0)*[Limit])/100) [Min Threshold]
          ,((ISNULL(ccl.max_threshold ,100)*[Limit])/100) [Max Threshold]
          ,'Maximum Threshold Violated Warning' 
           [Notification Type]
           INTO     #max_violated
    FROM   #temp_counterparty_credit_data a
           INNER JOIN counterparty_credit_info cci
                ON  a.[Source_Counterparty_ID] = cci.Counterparty_id
           OUTER APPLY (
        SELECT TOP(1) ccl.internal_counterparty_id
              ,ccl.contract_id
              ,ccl.effective_date
              ,ISNULL(ccl.min_threshold ,0) min_threshold
              ,ISNULL(ccl.max_threshold ,0) max_threshold
        FROM   counterparty_credit_limits ccl
        WHERE  ccl.counterparty_id = a.Source_Counterparty_ID
               AND (
                       ccl.internal_counterparty_id=a.internal_counterparty_id
                       OR NULLIF(ccl.internal_counterparty_id ,'') IS NULL
                   )
               AND (
                       ccl.contract_id=a.contract_id
                       OR NULLIF(ccl.contract_id ,'') IS NULL
                   )
               AND a.as_of_date>= ccl.effective_date
        ORDER BY
               ISNULL(NULLIF(ccl.internal_counterparty_id ,'') ,9999999)
              ,ISNULL(NULLIF(ccl.contract_id ,'') ,9999999)
              ,ccl.effective_date
    )               ccl
    WHERE  (
               limit_available<0
               AND net_exposure > ((ISNULL(ccl.max_threshold ,100)*[Limit])/100)
               AND net_exposure > 0
           )
    
    SELECT [Source_Counterparty_ID]
          ,internal_counterparty
          ,[CONTRACT]
          ,[Counterparty]
          ,net_exposure
          ,limit_available
          ,limit
          ,((ISNULL(ccl.min_threshold ,0)*[Limit])) [Min Threshold]
          ,((ISNULL(ccl.max_threshold ,100)*[Limit])/100) [Max Threshold]
          ,'Credit Limit Violation Alert' [Notification Type]
           INTO     #credit_limit_violated
    FROM   #temp_counterparty_credit_data a
           INNER JOIN counterparty_credit_info cci
                ON  a.[Source_Counterparty_ID] = cci.Counterparty_id
           OUTER APPLY (
        SELECT TOP(1) ccl.internal_counterparty_id
              ,ccl.contract_id
              ,ccl.effective_date
              ,ISNULL(ccl.min_threshold ,0) min_threshold
              ,ISNULL(ccl.max_threshold ,0) max_threshold
        FROM   counterparty_credit_limits ccl
        WHERE  ccl.counterparty_id = a.Source_Counterparty_ID
               AND (
                       ccl.internal_counterparty_id=a.internal_counterparty_id
                       OR NULLIF(ccl.internal_counterparty_id ,'') IS NULL
                   )
               AND (
                       ccl.contract_id=a.contract_id
                       OR NULLIF(ccl.contract_id ,'') IS NULL
                   )
               AND a.as_of_date>= ccl.effective_date
        ORDER BY
               ISNULL(NULLIF(ccl.internal_counterparty_id ,'') ,9999999)
              ,ISNULL(NULLIF(ccl.contract_id ,'') ,9999999)
              ,ccl.effective_date
    )               ccl
    WHERE  (
               limit_available<0
               AND net_exposure < ((ISNULL(ccl.max_threshold ,100)*[Limit])/100)
               AND net_exposure > 0
           )
    
    SELECT [Counterparty]
          ,internal_counterparty [Internal Counterparty]
          ,[CONTRACT] [Contract]
          ,CONVERT(VARCHAR,CAST(ISNULL([net_exposure],0) AS MONEY), 1)  [Net Exposure]
		  ,CONVERT(VARCHAR,CAST(ISNULL([Limit],0)AS MONEY),1) [Limit]
          ,CONVERT(VARCHAR,CAST(ISNULL([limit_available],0) AS MONEY),1) [Limit Available]
          ,CONVERT(VARCHAR,CAST(ISNULL([Min Threshold],0) AS MONEY),1) [Min Threshold]
          ,CONVERT(VARCHAR,CAST(ISNULL([Max Threshold],0) AS MONEY),1) [Max Threshold]
          ,[Notification Type]
          INTO adiha_process.dbo.credit_limit_violation_process_id_clv
    FROM   #min_violated
    
    UNION ALL
    
    SELECT [Counterparty]
          ,internal_counterparty [Internal Counterparty]
          ,[CONTRACT] [Contract]
          ,CONVERT(VARCHAR,CAST(ISNULL([net_exposure],0) AS MONEY), 1)  [Net Exposure]
		  ,CONVERT(VARCHAR,CAST(ISNULL([Limit],0)AS MONEY),1) [Limit]
          ,CONVERT(VARCHAR,CAST(ISNULL([limit_available],0) AS MONEY),1) [Limit Available]
          ,CONVERT(VARCHAR,CAST(ISNULL([Min Threshold],0) AS MONEY),1) [Min Threshold]
          ,CONVERT(VARCHAR,CAST(ISNULL([Max Threshold],0) AS MONEY),1) [Max Threshold]
          ,[Notification Type]
    FROM   #max_violated
    
    UNION ALL
    
    SELECT [Counterparty]
          ,internal_counterparty [Internal Counterparty]
          ,[CONTRACT] [Contract]
          ,CONVERT(VARCHAR,CAST(ISNULL([net_exposure],0) AS MONEY), 1)  [Net Exposure]
		  ,CONVERT(VARCHAR,CAST(ISNULL([Limit],0)AS MONEY),1) [Limit]
          ,CONVERT(VARCHAR,CAST(ISNULL([limit_available],0) AS MONEY),1) [Limit Available]
          ,CONVERT(VARCHAR,CAST(ISNULL([Min Threshold],0) AS MONEY),1) [Min Threshold]
          ,CONVERT(VARCHAR,CAST(ISNULL([Max Threshold],0) AS MONEY),1) [Max Threshold]
          ,[Notification Type]
    FROM   #credit_limit_violated
    
    IF NOT EXISTS (
           SELECT 1
           FROM   adiha_process.dbo.credit_limit_violation_process_id_clv
       )
    BEGIN
       RETURN
    END
    
    DROP TABLE #min_violated
    
    DROP TABLE #max_violated
    
    DROP TABLE #credit_limit_violated
END