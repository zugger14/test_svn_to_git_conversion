
/*************************************View: 'Cash Collateral Balance View' START*************************************/
BEGIN TRY
		BEGIN TRAN
	

	declare @new_ds_alias varchar(10) = 'SCCBV'
	/** IF DATA SOURCE ALIAS ALREADY EXISTS ON DESTINATION, RAISE ERROR **/
	if exists(select top 1 1 from data_source where alias = 'SCCBV' and name <> 'Cash Collateral Balance View')
	begin
		select top 1 @new_ds_alias = 'SCCBV' + cast(s.n as varchar(5))
		from seq s
		left join data_source ds on ds.alias = 'SCCBV' + cast(s.n as varchar(5))
		where ds.data_source_id is null
			and s.n < 10

		--RAISERROR ('Datasource alias already exists on system.', 16, 1);
	end

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL

	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Cash Collateral Balance View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	AND NOT EXISTS (SELECT 1 FROM map_function_category WHERE [function_name] = 'Cash Collateral Balance View' AND '106500' = '106501') 
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id, system_defined,category)
		SELECT TOP 1 1 AS [type_id], 'Cash Collateral Balance View' AS [name], @new_ds_alias AS ALIAS, 'Standard Cash Collateral Balance View' AS [description],null AS [tsql], @report_id_data_source_dest AS report_id,'1' AS [system_defined]
			,'106500' AS [category]
	END

	UPDATE data_source
	SET alias = @new_ds_alias, description = 'Standard Cash Collateral Balance View'
	, [tsql] = CAST('' AS VARCHAR(MAX)) + 'DECLARE @_as_of_date DATETIME --= ''2017-04-01''

DECLARE @_as_of_to_date DATETIME --= ''2017-05-31''

DECLARE @_interest_rate_curve_id VARCHAR(20) --= ''4483''

DECLARE @_internal_counterparty_id VARCHAR(10)

IF OBJECT_ID(''tempdb..#tmp_cash_balance_123'') IS NOT NULL

    DROP TABLE #tmp_cash_balance_123

IF OBJECT_ID(''tempdb..#tmp_cash_balance'') IS NOT NULL

    DROP TABLE #tmp_cash_balance

IF OBJECT_ID(''tempdb..#tmp_cash_balance2'') IS NOT NULL

    DROP TABLE #tmp_cash_balance2

IF OBJECT_ID(''tempdb..#tmp_cash_balance3'') IS NOT NULL

    DROP TABLE #tmp_cash_balance3

	

IF OBJECT_ID(''tempdb..#tmp_cash_balance4'') IS NOT NULL

    DROP TABLE #tmp_cash_balance4

IF OBJECT_ID(''tempdb..#tmp_cash_balance_result'') IS NOT NULL

    DROP TABLE #tmp_cash_balance_result

SET @_as_of_date = ''@as_of_date''

IF ''@as_of_to_date''<>''NULL''

    SET @_as_of_to_date = ''@as_of_to_date''

IF ''@interest_rate_curve_id''<>''NULL''

    SET @_interest_rate_curve_id = ''@interest_rate_curve_id''

IF ''@internal_counterparty_id''<>''NULL''

    SET @_internal_counterparty_id = ''@internal_counterparty_id''

DECLARE @_sql VARCHAR(MAX)

create table #tmp_cash_balance_123(

	counterparty_id	int,

	counterparty_name	Nvarchar(200) COLLATE DATABASE_DEFAULT,

	counterparty_code	Nvarchar(200) COLLATE DATABASE_DEFAULT,

	contract_id	int,

	contract	Nvarchar(200) COLLATE DATABASE_DEFAULT,

	eff_date	datetime,

	amount	float,

	cash_in	float,

	cash_out	float,

	enhance_type	int,

	interest_rate	int,

	interest_rate_value	float,

	maturity_date	datetime,

	as_of_date	datetime,

	source_curve_def_id	int,

	time_months	int,

	counterparty_credit_info_id	int,

	internal_counterparty_id	int,

	internal_counterparty_code	Nvarchar(200) COLLATE DATABASE_DEFAULT,

	internal_counterparty_name	Nvarchar(200) COLLATE DATABASE_DEFAULT,

	guarantee_counterparty_id	int,

	guarantee_counterparty_name	Nvarchar(200) COLLATE DATABASE_DEFAULT,

	guarantee_counterparty_code	Nvarchar(200) COLLATE DATABASE_DEFAULT,

	interest_rate_curve	varchar(200) COLLATE DATABASE_DEFAULT

)

SET @_sql = 

    ''INSERT INTO #tmp_cash_balance_123

SELECT DISTINCT

	sc.source_counterparty_id [counterparty_id]

	,sc.counterparty_name [counterparty_name]

	,sc.counterparty_id [counterparty_code]

	,cce.contract_id

	,cg.[contract_name] [contract]

	,cce.eff_date

	,cce.amount

	,CASE WHEN cce.margin = ''''y'''' THEN cce.amount ELSE '''''''' END [cash_in]

	,CASE WHEN cce.margin = ''''n'''' THEN cce.amount ELSE '''''''' END [cash_out]

	,cce.enhance_type

	--,cca.interest_rate

	,spcd.source_curve_def_id interest_rate

	,ISNULL(spc.curve_value, 0) [interest_rate_value]

	,spc.maturity_date

	,spc.as_of_date

	,spc.source_curve_def_id

	,(year(cce.eff_date) * 12 + MONTH(cce.eff_date)) - (year(''''''+CAST(@_as_of_date AS VARCHAR(20)) 

   +'''''') * 12 + MONTH(''''''+CAST(@_as_of_date AS VARCHAR(20))+

    '''''')) [time_months] 

	,cci.counterparty_credit_info_id

	,cce.internal_counterparty [internal_counterparty_id]

	,sc1.counterparty_id [internal_counterparty_code]

	,sc1.counterparty_name [internal_counterparty_name]

	,cce.guarantee_counterparty [guarantee_counterparty_id]

	,scg.counterparty_name [guarantee_counterparty_name]

	,scg.counterparty_id [guarantee_counterparty_code]

	,spcd.curve_name [interest_rate_curve]

FROM source_counterparty sc

INNER JOIN counterparty_credit_info cci on sc.source_counterparty_id = cci.Counterparty_id

INNER JOIN counterparty_credit_enhancements cce 

	on cci.counterparty_credit_info_id = cce.counterparty_credit_info_id   ''

IF @_internal_counterparty_id IS NOT NULL

    SET @_sql+= '' AND cce.internal_counterparty = ''''''+CAST(@_internal_counterparty_id AS VARCHAR(10)) 

       +''''''''

SET @_sql+= 

    ''	AND cce.enhance_type = (SELECT value_id FROM static_data_value AS sdv WHERE sdv.code = ''''cash'''' AND sdv.[type_id] = 10100)

left JOIN source_counterparty sc1 ON sc1.source_counterparty_id = cce.internal_counterparty

LEFT JOIN source_counterparty scg on scg.source_counterparty_id = cce.guarantee_counterparty

--LEFT JOIN (select distinct contract_ID from counterparty_contract_address cca where cca.counterparty_id = sc.source_counterparty_id) cca ON cca.contract_id = cce.contract_id

LEFT JOIN contract_group cg on cg.contract_id = cce.contract_id

LEFT JOIN counterparty_contract_address cca on cca.counterparty_id = sc.source_counterparty_id AND cca.contract_id = cg.contract_id 

AND cca.internal_counterparty_id = ISNULL(cce.internal_counterparty,cca.internal_counterparty_id )

LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = isnull(cca.interest_rate,'' + isnull(@_interest_rate_curve_id,''-1'') + '')

LEFT JOIN source_price_curve spc on spc.source_curve_def_id = spcd.source_curve_def_id

	and CONVERT(date, spc.maturity_date) = CONVERT(date, cce.eff_date)

''

IF @_as_of_to_date IS NOT NULL

    SET @_sql+= '' WHERE cce.eff_date <= ''''''+CAST(@_as_of_to_date AS VARCHAR(20)) 

       +''''''''

--PRINT(@_sql)

EXEC (@_sql)

--select * from #tmp_cash_balance_123

--RETURN

SELECT tcb1.counterparty_id

      ,MAX(tcb1.counterparty_name) [counterparty_name]

      ,MAX(tcb1.counterparty_code) [counterparty_code]

      ,tcb1.contract_id [contract_id]

      ,MAX(tcb1.[contract]) [contract]

      ,tcb1.eff_date [eff_date]

      ,SUM(tcb1.[cash_in]) [cash_in]

      ,SUM(tcb1.[cash_out]) [cash_out]

      ,SUM(tcb1.[cash_in])- SUM(tcb1.[cash_out]) [amount]

      ,MAX(tcb1.enhance_type) [enhance_type]

      ,MAX(tcb1.interest_rate) [interest_rate]

      ,CASE 

            WHEN (tcb1.eff_date<@_as_of_date) THEN 0

            ELSE MAX(tcb1.[interest_rate_value])

       END [interest_rate_value]

      ,MAX(tcb1.maturity_date) [maturity_date]

      ,MAX(tcb1.as_of_date)   [as_of_date]

      ,MAX(tcb1.source_curve_def_id) [source_curve_def_id]

      ,MAX(tcb1.time_months) [time_months]

      ,MAX(tcb1.counterparty_credit_info_id) [counterparty_credit_info_id]

      ,MAX(tcb1.internal_counterparty_id) [internal_counterparty_id]

      ,MAX(tcb1.internal_counterparty_code) [internal_counterparty_code]

      ,MAX(tcb1.internal_counterparty_name) [internal_counterparty_name]

      ,MAX(tcb1.guarantee_counterparty_id) [guarantee_counterparty_id]

      ,MAX(tcb1.counterparty_name) [guarantee_counterparty_name]

      ,MAX(tcb1.counterparty_id) [guarantee_counterparty_code]

      ,MAX(tcb1.interest_rate_curve) [interest_rate_curve]

       INTO  #tmp_cash_balance

FROM   #tmp_cash_balance_123 tcb1

GROUP BY

       tcb1.counterparty_id

      ,tcb1.internal_counterparty_id

      ,tcb1.contract_id

      ,tcb1.eff_date

--select * from #tmp_cash_balance

SELECT tcb.*

      ,RANK() OVER(

           PARTITION BY tcb.counterparty_id

          ,tcb.internal_counterparty_id

          ,tcb.contract_id ORDER BY tcb.eff_date

          ,tcb.cash_in

          ,tcb.cash_out

       ) [rank]

       INTO                  #tmp_cash_balance2

FROM   #tmp_cash_balance     tcb

--select * from #tmp_cash_balance2

SELECT MAX(tcb2.counterparty_id) [counterparty_id]

      ,MAX(tcb2.counterparty_name) [counterparty_name]

      ,MAX(tcb2.counterparty_code) [counterparty_code]

      ,MAX(tcb2.contract_id) [contract_id]

      ,MAX(tcb2.[contract]) [contract]

      ,MAX(tcb2.eff_date) [eff_Date]

      ,CASE 

            WHEN (MAX(tcb2.eff_date)<@_as_of_date) THEN ''''

            ELSE MAX(tcb2.[cash_in])

       END [cash_in]

      ,CASE 

            WHEN (MAX(tcb2.eff_date)<@_as_of_date) THEN ''''

            ELSE MAX(tcb2.[cash_out])

       END [cash_out]

      ,MAX(tcb2.[amount]) [amount]

      ,MAX(tcb2.enhance_type) [enhance_type]

      ,MAX(tcb2.interest_rate)  [interest_rate]

      ,MAX(tcb2.[interest_rate_value]) [interest_rate_value]

      ,MAX(tcb2.maturity_date)           maturity_date

      ,MAX(tcb2.as_of_date)           as_of_date

      ,MAX(tcb2.source_curve_def_id)     source_curve_def_id

      ,MAX(tcb2.time_months) [time_months]

      ,SUM(tcb21.amount) [total_amount]

      ,(SUM(tcb21.amount)*MAX(tcb2.[interest_rate_value])/360)/100 [interest]

      ,MAX(tcb2.[rank]) [rank]

      ,MAX(tcb2.counterparty_credit_info_id) counterparty_credit_info_id

      ,MAX(tcb2.internal_counterparty_id) [internal_counterparty_id]

      ,MAX(tcb2.internal_counterparty_code) [internal_counterparty_code]

      ,MAX(tcb2.internal_counterparty_name) [internal_counterparty_name]

      ,MAX(tcb2.guarantee_counterparty_id) [guarantee_counterparty_id]

      ,MAX(tcb2.counterparty_name) [guarantee_counterparty_name]

      ,MAX(tcb2.counterparty_id) [guarantee_counterparty_code]

      ,MAX(tcb2.interest_rate_curve) [interest_rate_curve]

       INTO                              #tmp_cash_balance3

FROM   #tmp_cash_balance2 tcb2

       LEFT JOIN #tmp_cash_balance2 tcb21

            ON  tcb21.counterparty_id = tcb2.counterparty_id

                AND tcb21.internal_counterparty_id = tcb2.internal_counterparty_id

                AND tcb21.contract_id = tcb2.contract_id

                AND tcb2.[rank]>= tcb21.[rank]

GROUP BY

       tcb2.counterparty_id

      ,tcb2.internal_counterparty_id

      ,tcb2.contract_id

      ,tcb2.eff_date

      ,tcb2.[rank]

--order by tcb2.source_counterparty_id, tcb2.contract_id, tcb2.eff_date, tcb2.[rank]

--select * from #tmp_cash_balance3

SELECT MAX(tcb3.counterparty_id)         counterparty_id

      ,MAX(tcb3.counterparty_name)       counterparty_name

      ,MAX(tcb3.counterparty_code)       counterparty_code

      ,MAX(tcb3.contract_id)             contract_id

      ,MAX(tcb3.[contract]) [contract]

      ,MAX(tcb3.eff_date)                eff_date

      ,MAX(tcb3.[cash_in]) [cash_in]

      ,MAX(tcb3.[cash_out]) [cash_out]

      ,MAX(tcb3.[amount]) [amount]

      ,MAX(tcb3.enhance_type)            enhance_type

      ,MAX(tcb3.interest_rate)           interest_rate

      ,MAX(tcb3.[interest_rate_value]) [interest_rate_value]

      ,MAX(tcb3.maturity_date)           maturity_date

      ,MAX(tcb3.as_of_date)           as_of_date

      ,MAX(tcb3.source_curve_def_id)     source_curve_def_id

      ,MAX(tcb3.time_months) [time_months]

      ,MAX(tcb3.total_amount) [total_amount]

      ,ABS(MAX(tcb3.total_amount)) [margin_amount]

      ,MAX(tcb3.interest) [interest]

      ,SUM(tcb31.amount) [ending_amount]

      ,SUM(tcb31.interest) [total_interest]

      ,MAX(tcb3.[rank]) [rank]

      ,MAX(tcb3.counterparty_credit_info_id) counterparty_credit_info_id

      ,MAX(tcb3.internal_counterparty_id) [internal_counterparty_id]

      ,MAX(tcb3.internal_counterparty_code) [internal_counterparty_code]

      ,MAX(tcb3.internal_counterparty_name) [internal_counterparty_name]

      ,MAX(tcb3.guarantee_counterparty_id) [guarantee_counterparty_id]

      ,MAX(tcb3.counterparty_name) [guarantee_counterparty_name]

      ,MAX(tcb3.counterparty_id) [guarantee_counterparty_code]

      ,MAX(tcb3.interest_rate_curve) [interest_rate_curve]

       INTO                              #tmp_cash_balance4

FROM   #tmp_cash_balance3 tcb3

       LEFT JOIN #tmp_cash_balance3 tcb31

            ON  tcb3.counterparty_id = tcb31.counterparty_id

                AND tcb3.contract_id = tcb31.contract_id

                AND tcb3.internal_counterparty_id = tcb31.internal_counterparty_id

GROUP BY

       tcb3.counterparty_id

      ,tcb3.internal_counterparty_id

      ,tcb3.contract_id

      ,tcb3.eff_date

IF OBJECT_ID(''tempdb..#tmp_cash_balance_result'') IS NOT NULL

    DROP TABLE #tmp_cash_balance_result

CREATE TABLE #tmp_cash_balance_result

(

	counterparty_id                 INT

   ,counterparty_name               NVARCHAR(100) COLLATE DATABASE_DEFAULT

   ,counterparty_code               NVARCHAR(100) COLLATE DATABASE_DEFAULT

   ,contract_id                     INT

   ,[contract]                      NVARCHAR(100) COLLATE DATABASE_DEFAULT

   ,eff_date                        VARCHAR(50) COLLATE DATABASE_DEFAULT

   ,cash_in                         FLOAT

   ,cash_out                        FLOAT

   ,cash_balance                    FLOAT

   ,margin_balance                  FLOAT

   ,interest_rate					INT

   ,interest_rate_value             FLOAT

   ,[rank]                          INT

   ,counterparty_credit_info_id     INT

   ,internal_counterparty_id        INT

   ,internal_counterparty_code      NVARCHAR(100) COLLATE DATABASE_DEFAULT

   ,internal_counterparty_name      NVARCHAR(100) COLLATE DATABASE_DEFAULT

   ,guarantee_counterparty_id       INT

   ,guarantee_counterparty_name     NVARCHAR(100) COLLATE DATABASE_DEFAULT

   ,guarantee_counterparty_code     NVARCHAR(100) COLLATE DATABASE_DEFAULT

   ,interest_rate_curve				VARCHAR(100) COLLATE DATABASE_DEFAULT

)

INSERT INTO #tmp_cash_balance_result

SELECT DISTINCT

       counterparty_id

      ,counterparty_name

      ,counterparty_code

      ,contract_id

      ,[contract]

      ,'' Ending Balance''

      ,''''

      ,''''

      ,[ending_amount]

      ,''''

      ,interest_rate

      ,''''

      ,100 [rank]

      ,counterparty_credit_info_id

      ,internal_counterparty_id

      ,internal_counterparty_code

      ,internal_counterparty_name

      ,guarantee_counterparty_id

      ,guarantee_counterparty_name

      ,guarantee_counterparty_code

      ,interest_rate_curve

FROM   #tmp_cash_balance4 --WHERE eff_date >= @_as_of_date

INSERT INTO #tmp_cash_balance_result

SELECT DISTINCT 

       MAX(tbr1.counterparty_id) [counterparty_id]

      ,MAX(tbr1.counterparty_name) [counterparty_name]

      ,MAX(tbr1.counterparty_code) [counterparty_code]

      ,MAX(tbr1.contract_id) [contract_id]

      ,MAX(tbr1.[contract]) [contract]

      ,''   Beginning Balance''

      ,''''

      ,''''

      ,ISNULL(SUM(tcb41.amount) ,0) [total_amount]

      ,''''

      ,max(tbr1.interest_rate)

      ,''''

      ,0 [rank]

      ,MAX(tbr1.counterparty_credit_info_id) [counterparty_credit_info_id]

      ,MAX(tbr1.internal_counterparty_id) [internal_counterparty_id]

      ,MAX(tbr1.internal_counterparty_name) [internal_counterparty_name]

      ,MAX(tbr1.internal_counterparty_code) [internal_counterparty_code]

      ,MAX(tbr1.guarantee_counterparty_id) [guarantee_counterparty_id]

      ,MAX(tbr1.guarantee_counterparty_name) [guarantee_counterparty_name]

      ,MAX(tbr1.guarantee_counterparty_code) [guarantee_counterparty_code]

      ,MAX(tbr1.interest_rate_curve) [interest_rate_curve]

FROM   #tmp_cash_balance_result tbr1

       LEFT JOIN #tmp_cash_balance4 tcb41

            ON  tbr1.counterparty_id = tcb41.counterparty_id

                AND tbr1.contract_id = tcb41.contract_id

                AND tbr1.internal_counterparty_id = tcb41.internal_counterparty_id

                AND tcb41.eff_date<@_as_of_date

GROUP BY

       tbr1.counterparty_id

      ,tbr1.internal_counterparty_id

      ,tbr1.contract_id

/*

insert into #tmp_cash_balance_result

SELECT 

	distinct

	source_counterparty_id

	, counterparty_name

	, contract_id

	, [contract_name]

	, '' Interest''

	, ''''

	, ''''

	, internal_counterparty

	,total_interest

	,''''

	,''''

	,101 [rank]

	,counterparty_credit_info_id

	,internal_counterparty_id

	,internal_counterparty_name

FROM #tmp_cash_balance4 WHERE eff_date >= @_as_of_date

*/

INSERT INTO #tmp_cash_balance_result

SELECT DISTINCT

       counterparty_id

      ,counterparty_name

      ,counterparty_code

      ,contract_id

      ,[contract]

      ,''Total Balance''

      ,''''

      ,''''

       --,[ending_amount] + [total_interest]

      ,[ending_amount]

      ,''''

      ,interest_rate

      ,total_interest

      ,102 [rank]

      ,counterparty_credit_info_id

      ,internal_counterparty_id

      ,internal_counterparty_code

      ,internal_counterparty_name

      ,guarantee_counterparty_id

      ,guarantee_counterparty_name

      ,guarantee_counterparty_code

      ,interest_rate_curve

FROM   #tmp_cash_balance4

WHERE  eff_date>= @_as_of_date

INSERT INTO #tmp_cash_balance_result

SELECT counterparty_id

      ,counterparty_name

      ,counterparty_code

      ,contract_id

      ,[contract]

      ,'' ''+LEFT(CONVERT(VARCHAR ,eff_date ,101) ,10)

      ,[cash_in]

      ,[cash_out]

      ,total_amount

      ,margin_amount

      ,interest_rate

      ,interest

      ,[rank]

      ,counterparty_credit_info_id

      ,internal_counterparty_id

      ,internal_counterparty_code

      ,internal_counterparty_name

      ,guarantee_counterparty_id

      ,guarantee_counterparty_name

      ,guarantee_counterparty_code

      ,interest_rate_curve

FROM   #tmp_cash_balance4

WHERE  eff_date>= @_as_of_date

SELECT @_as_of_date [as_of_date]

      ,@_as_of_to_date [as_of_to_date]

      ,t.counterparty_id

      ,counterparty_code

      ,counterparty_name

      ,contract_id

      ,t.[contract]

      ,eff_date

      ,CASE 

            WHEN cash_in=0 THEN ''''

            ELSE cash_in

       END  [cash_in]

      ,CASE 

            WHEN cash_out=0 THEN ''''

            ELSE cash_out

       END  [cash_out]

      ,cash_balance

      ,margin_balance

      ,interest_rate_value interest_rate

      ,t.interest_rate [interest_rate_curve_id]

      ,--scc.commodity_name [product],

       sdt.deal_type_id [deal_type]

      ,t.counterparty_credit_info_id

      ,t.internal_counterparty_id

      ,t.internal_counterparty_code

      ,t.internal_counterparty_name

      ,t.guarantee_counterparty_id

      ,t.guarantee_counterparty_name

      ,t.guarantee_counterparty_code

      , t.interest_rate_curve

       --[__batch_report__]

FROM   #tmp_cash_balance_result t

       LEFT JOIN counterparty_credit_block_trading ccbt

            ON  t.counterparty_credit_info_id = ccbt.counterparty_credit_info_id

                AND t.contract_id = ccbt.[contract]

                    -- AND t.internal_counterparty = ccbt.internal_counterparty_id

                    

       LEFT JOIN source_commodity scc

            ON  scc.source_commodity_id = ccbt.comodity_id

       LEFT JOIN source_deal_type sdt

            ON  sdt.source_deal_type_id = ccbt.deal_type_id

WHERE  t.counterparty_id IS NOT     NULL

ORDER BY

       t.counterparty_id

      ,internal_counterparty_id

      ,contract_id

      ,[rank]

     

--Droping temp table is important here as without dropping gave SQL Aborted issue when running report multiple times (with two tablix using same data source)

--IF OBJECT_ID(''#tmp_cash_balance_123'') IS NOT NULL

--    DROP TABLE #tmp_cash_balance_123

----IF OBJECT_ID(''tempdb..#tmp_cash_balance'') IS NOT NULL

--    DROP TABLE #tmp_cash_balance

----IF OBJECT_ID(''tempdb..#tmp_cash_balance2'') IS NOT NULL

--    DROP TABLE #tmp_cash_balance2

----IF OBJECT_ID(''tempdb..#tmp_cash_balance3'') IS NOT NULL

--    DROP TABLE #tmp_cash_balance3

----IF OBJECT_ID(''tempdb..#tmp_cash_balance4'') IS NOT NULL

--    DROP TABLE #tmp_cash_balance4

----IF OBJECT_ID(''tempdb..#tmp_cash_balance_result'') IS NOT NULL

--    DROP TABLE #tmp_cash_balance_result', report_id = @report_id_data_source_dest,
	system_defined = '1'
	,category = '106500' 
	WHERE [name] = 'Cash Collateral Balance View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
		
	

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'as_of_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As of Date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 1, required_filter = 1
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'as_of_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_date' AS [name], 'As of Date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 1 AS key_column, 1 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'as_of_to_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'As Of To Date'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'as_of_to_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'as_of_to_date' AS [name], 'As Of To Date' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'cash_balance'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Cash Balance'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'cash_balance'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cash_balance' AS [name], 'Cash Balance' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'cash_in'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Cash In'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'cash_in'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cash_in' AS [name], 'Cash In' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'cash_out'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Cash Out'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'cash_out'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'cash_out' AS [name], 'Cash Out' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'contract'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'contract'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract' AS [name], 'Contract' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'contract_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Contract ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = 'browse_contract_counterparty', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 1, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'contract_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract_id' AS [name], 'Contract ID' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_contract_counterparty' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'counterparty_code'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Code'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'counterparty_code'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_code' AS [name], 'Counterparty Code' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'counterparty_credit_info_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty Credit Info Id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'counterparty_credit_info_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_credit_info_id' AS [name], 'Counterparty Credit Info Id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty ID'
			   , reqd_param = 0, widget_id = 7, datatype_id = 4, param_data_source = 'browse_counterparty', param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 1, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_id' AS [name], 'Counterparty ID' AS ALIAS, 0 AS reqd_param, 7 AS widget_id, 4 AS datatype_id, 'browse_counterparty' AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Counterparty'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'counterparty_name' AS [name], 'Counterparty' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'deal_type'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Deal Type'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'deal_type'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'deal_type' AS [name], 'Deal Type' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'eff_date'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Eff Date'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'eff_date'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'eff_date' AS [name], 'Eff Date' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'guarantee_counterparty_code'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Guarantee Counterparty Code'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'guarantee_counterparty_code'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'guarantee_counterparty_code' AS [name], 'Guarantee Counterparty Code' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'guarantee_counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Guarantee Counterparty Id'
			   , reqd_param = 0, widget_id = 1, datatype_id = 4, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'guarantee_counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'guarantee_counterparty_id' AS [name], 'Guarantee Counterparty Id' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 4 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'guarantee_counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Guarantee Counterparty Name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'guarantee_counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'guarantee_counterparty_name' AS [name], 'Guarantee Counterparty Name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'interest_rate'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Interest Rate'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'interest_rate'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'interest_rate' AS [name], 'Interest Rate' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'interest_rate_curve'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Interest Rate Curve'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'interest_rate_curve'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'interest_rate_curve' AS [name], 'Interest Rate Curve' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'internal_counterparty_code'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Counterparty Code'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'internal_counterparty_code'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_counterparty_code' AS [name], 'Internal Counterparty Code' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'internal_counterparty_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Counterparty Id'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_source_counterparty_maintain @flag = ''c'', @int_ext_flag = ''i''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 1, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'internal_counterparty_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_counterparty_id' AS [name], 'Internal Counterparty Id' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_source_counterparty_maintain @flag = ''c'', @int_ext_flag = ''i''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'internal_counterparty_name'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Internal Counterparty Name'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'internal_counterparty_name'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'internal_counterparty_name' AS [name], 'Internal Counterparty Name' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'margin_balance'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Margin Balance'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0, required_filter = NULL
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'margin_balance'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'margin_balance' AS [name], 'Margin Balance' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column, NULL AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Cash Collateral Balance View'
	            AND dsc.name =  'interest_rate_curve_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'Interest Rate Curve Id'
			   , reqd_param = 1, widget_id = 2, datatype_id = 4, param_data_source = 'EXEC spa_source_price_curve_def_maintain @flag = ''l'', @source_curve_type_value_id = ''579,577''', param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 2, key_column = 1, required_filter = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Cash Collateral Balance View'
			AND dsc.name =  'interest_rate_curve_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column, required_filter)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'interest_rate_curve_id' AS [name], 'Interest Rate Curve Id' AS ALIAS, 1 AS reqd_param, 2 AS widget_id, 4 AS datatype_id, 'EXEC spa_source_price_curve_def_maintain @flag = ''l'', @source_curve_type_value_id = ''579,577''' AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,2 AS column_template, 1 AS key_column, 0 AS required_filter				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Cash Collateral Balance View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Cash Collateral Balance View'
		AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	LEFT JOIN #data_source_column tdsc ON tdsc.column_id = dsc.data_source_column_id
	WHERE tdsc.column_id IS NULL
	
COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN;
		
			DECLARE @error_msg VARCHAR(1000)
             	SET @error_msg = ERROR_MESSAGE()
             	RAISERROR (@error_msg, 16, 1);
	END CATCH
	
	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	
/*************************************View: 'Cash Collateral Balance View' END***************************************/

