BEGIN TRY
		BEGIN TRAN
	

	DECLARE @report_id_data_source_dest INT 
	
	SELECT @report_id_data_source_dest = report_id
	FROM report r
	WHERE r.[name] = NULL

	IF EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Storage View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
			
	BEGIN
		UPDATE data_source
		SET alias = 'sv', description = ''
		, [tsql] = CAST('' AS VARCHAR(MAX)) + 'declare @_commodity_id INT=''50'',
	@_curve_id INT=NULL,
	@_contract_id INT=NULL,
	@_location_id VARCHAR(MAX)=NULL,
	@_term_start DATE = ''@term_start'',
	@_term_end DATE	= ''@term_end''
/*
declare @_commodity_id INT=''50'',
	@_curve_id INT=NULL,
	@_contract_id INT=NULL,
	@_location_id VARCHAR(MAX)=NULL,
	@_term_start DATE = ''2016-03-01'',
	@_term_end DATE	= ''2016-04-30''
	
--*/


BEGIN
	---###########Declare Variables
	DECLARE @_Sql_Select VARCHAR(8000)
	DECLARE @_location_group varchar(30)
	,@_exclude_int_deal_sub_types varchar(30)
	,@_include_deal_types varchar(30)	,@_include_deal_sub_types varchar(30)
	set @_location_group	=''Storage''
	select @_exclude_int_deal_sub_types =''151,152''
	,@_include_deal_types =''39'',	 --Storage
	@_include_deal_sub_types =''1169,1170''	-- injection, withdrawal
	
	SELECT @_include_deal_types = d.source_deal_type_id 
	FROM source_deal_type d 
	WHERE d.source_deal_type_name = ''storage''


	SELECT @_include_deal_sub_types = STUFF(
		(SELECT '',''  + CAST(d.source_deal_type_id AS VARCHAR)
		FROM source_deal_type d 
		WHERE d.source_deal_type_name in( ''injection'',''withdrawal'')
		FOR XML PATH(''''))
	, 1, 1, '''')	  

	--####### create temporary tables for selected hierarchy
	if object_id(''tempdb..#books'') is not null
	drop table #books
	CREATE TABLE #books (fas_book_id int) 

	INSERT INTO  #books
	 SELECT distinct 
				book.entity_id fas_book_id 
	 FROM 
			portfolio_hierarchy book (nolock)
			INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id           
			LEFT OUTER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id
	 WHERE 
			(fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) 
	  
	AND (''@sub_id'' = ''NULL'' OR stra.parent_entity_id IN (@sub_id)) 
	AND (''@stra_id'' = ''NULL'' OR stra.entity_id IN (@stra_id)) 
	AND (''@book_id'' = ''NULL'' OR book.entity_id IN (@book_id))
	
--select * from #books
----######## Get the require output
--PRIOR BALANCE
	if object_id(''tempdb..#temp'') is not null
	drop table #temp
	CREATE TABLE #temp (
		counterparty_id VARCHAR(250),
		location_id INT,
		curve_id INT ,
		[Counterparty] VARCHAR(250),
		[Location]  VARCHAR(250),
		[Index]  VARCHAR(250),
		[Date] DATETIME,
		[Injection] FLOAT,
		[Withdrawal] FLOAT,
		[Daily Average Balance] FLOAT,
		[UOM]  VARCHAR(250)	,
		source_deal_header_id int ,
		contract_id int,	[contract_name] varchar(100),
		[Injection_amt] FLOAT,
		[Withdrawal_amt] FLOAT,

		row_id int identity(1,1)
		 
	)

	

--CURRENT PERIOD								  
	SET @_Sql_Select=''
	INSERT INTO #temp (
		counterparty_id ,sdd.location_id ,sdd.curve_id  ,
		[Counterparty] ,[Location] ,[Index],[Date],[Injection],
		[Withdrawal],[Daily Average Balance] ,[UOM] 
		,contract_id ,contract_name	 ,[Injection_amt] ,[Withdrawal_amt]
	)
	SELECT
		max(sc.counterparty_id) counterparty_id,
		sdd.location_id,
		max(sdd.curve_id) curve_id,
		max(sc.counterparty_name) [Counterparty],
		ml.location_name [Location],
		max(spcd.curve_name) [Index],
		(sdd.term_start) as [Date],
		SUM(CASE WHEN buy_sell_flag=''''s'''' THEN deal_volume ELSE 0 END) AS [Injection],
		SUM(CASE WHEN buy_sell_flag=''''b'''' THEN deal_volume ELSE 0 END) AS [Withdrawal],
		SUM(CASE WHEN buy_sell_flag=''''b'''' THEN -1 ELSE 1 END* deal_volume) AS [Daily Average Balance],
		max(su.uom_name) [UOM]
		,max(sdh.contract_id) contract_id,isnull(cg.contract_name,'''''''') 
		,SUM(CASE WHEN sdd.buy_sell_flag=''''s'''' THEN sds.settlement_amount ELSE 0 END) [Injection_amt]
		,SUM(CASE WHEN sdd.buy_sell_flag=''''b'''' THEN sds.settlement_amount ELSE 0 END) [Withdrawal_amt]
	FROM #books b 
		INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = b.fas_book_id
		INNER JOIN source_deal_header sdh ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
				AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
				AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
				AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
				and sdh.source_deal_type_id=''+@_include_deal_types+''
				and sdh.deal_sub_type_type_id in (''+@_include_deal_sub_types+'')
		INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
		INNER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id
		inner JOIN source_minor_location ml on ml.source_minor_location_id=sdd.location_id
		inner JOIN source_major_location mj on mj.source_major_location_id=ml.source_major_location_ID and mj.location_name=''''''+@_location_group+''''''
		outer apply
			( select max(as_of_date) as_of_date from source_deal_settlement where source_deal_header_id=sdh.source_deal_header_id and term_start=sdd.term_start and leg=sdd.leg ) mx
		left join   source_deal_settlement sds on sds.source_deal_header_id=sdh.source_deal_header_id 
			and sds.term_start=sdd.term_start and sds.leg=sdd.leg	and sds.as_of_date=mx.as_of_date		LEFT JOIN source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id
		LEFT JOIN source_uom su on su.source_uom_id=sdd.deal_volume_uom_id
		left join contract_group  cg on cg.contract_id=sdh.contract_id
	WHERE 1=1 and isnull(sdh.internal_deal_subtype_value_id,-1) not in ('' + @_exclude_int_deal_sub_types  +'') ''
		+ '' AND sdd.term_start between ''''''+CAST(@_term_start AS VARCHAR)+'''''' AND ''''''+CAST(@_term_end AS VARCHAR)+''''''''				 
		+ CASE WHEN @_commodity_id IS NOT NULL THEN '' AND spcd.commodity_id=''+CAST(@_commodity_id AS VARCHAR) ELSE '''' END
		+ CASE WHEN @_curve_id IS NOT NULL THEN '' AND sdd.curve_id=''+CAST(@_curve_id AS VARCHAR) ELSE '''' END
		+ CASE WHEN @_contract_id IS NOT NULL THEN '' AND sdh.contract_id=''+CAST(@_contract_id AS VARCHAR) ELSE '''' END
		+ CASE WHEN @_location_id IS NOT NULL THEN '' AND sdd.location_id IN ('' + @_location_id + '')'' ELSE '''' END
		
	+'' GROUP BY 
		ml.location_name,isnull(cg.contract_name,'''''''') ,sdd.term_start,sdd.location_id
	 Order by
			ml.location_name,isnull(cg.contract_name,''''''''),sdd.term_start
				''


	print @_Sql_Select		
	EXEC(@_Sql_Select)

--SELECT * FROM #temp
--- Now out the result showing the rolling sum
	if object_id(''tempdb..#tmp_rpt_data'') is not null
	drop table #tmp_rpt_data
	SELECT 
				a.[Location] [Location]
				,case when  grouping(a.[Date] )=1 then '''' else a.[contract_name] end [Contract],
				a.[Date]	Term  
			,	round(sum(a.[Injection]),2) [Injection],
				round(sum(a.injection_amt),2)  InjectionAmount,
				round(sum(a.[Withdrawal]),2)  [Withdrawal],
				round(sum(a.[Withdrawal_amt]),2) [WithdrawalAmount],
				round(SUM(wa.wacog),2)  WACOG,
				 SUM(a.[Daily Average Balance])  [Balance],
				 cast(sum(a.[Withdrawal_amt]+a.injection_amt) as numeric(30,2))  [BalanceAmount] ,
				MAX(a.[UOM]) [UOM],rowid=IDENTITY(int,1,1)
				into  #tmp_rpt_data
	
	--  select * from #tmp_rpt_data
	--select a.*
	--,wa.wacog	
	FROM
			#temp a outer apply
			(
				select top(1) term from dbo.calcprocess_storage_wacog 
				 where location_id=a.location_id and term<  @_term_start 
					 and isnull(contract_id,-1) =isnull(a.contract_id,-1) and a.[Date]=''1900-01-01''
				 order by 	term desc
			) tm
		 left join dbo.calcprocess_storage_wacog wa
				 on wa.location_id=a.location_id and wa.term= isnull(tm.term,a.[date]) 
					 and isnull(wa.contract_id,-1) =isnull(a.contract_id,-1) 

		GROUP BY
				a.[Location],a.[contract_name],a.[Date]
		order by a.[Location],a.[contract_name],isnull(a.[Date],''9999-01-01'')

		--select * from #tmp_rpt_data
		set @_Sql_Select = ''select [Location] location,[Contract] contract,Term term_start, [Injection] [injection],[InjectionAmount] [injection_amt],[Withdrawal] [withdrawal],[WithdrawalAmount] [withdrawal_amt] ,WACOG [wacog]
			,round(b.[Balance],2) [balance]
			, b.[BalanceAmount] [balance_amt]
			,[UOM] [uom]
			, ''''@sub_id'''' [sub_id], ''''@stra_id'''' [stra_id], ''''@book_id'''' [book_id], CONVERT(DATETIME, ''''@term_end'''', 21) [term_end]
			--[__batch_report__]
		from #tmp_rpt_data	 a
			outer apply
								(select min(rowid) from_id,max(rowid) to_id from #tmp_rpt_data where Location=a.Location and isnull([Contract],'''''''')  =isnull(a.[Contract],'''''''')
			) rg
			outer apply
			(
				select sum(balance) [Balance],round(sum(BalanceAmount),2) BalanceAmount from  #tmp_rpt_data where rowid<=a.rowid and  rowid between  rg.from_id and rg.to_id
								)  b 
		order by Term''
			exec(@_Sql_Select)
END', report_id = @report_id_data_source_dest 
		WHERE [name] = 'Storage View'
			AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1)
	END	
	

	IF NOT EXISTS (SELECT 1 
	           FROM data_source 
	           WHERE [name] = 'Storage View'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		INSERT INTO data_source([type_id], [name], [alias], [description], [tsql], report_id)
		SELECT TOP 1 1 AS [type_id], 'Storage View' AS [name], 'sv' AS ALIAS, '' AS [description],'declare @_commodity_id INT=''50'',
	@_curve_id INT=NULL,
	@_contract_id INT=NULL,
	@_location_id VARCHAR(MAX)=NULL,
	@_term_start DATE = ''@term_start'',
	@_term_end DATE	= ''@term_end''
/*
declare @_commodity_id INT=''50'',
	@_curve_id INT=NULL,
	@_contract_id INT=NULL,
	@_location_id VARCHAR(MAX)=NULL,
	@_term_start DATE = ''2016-03-01'',
	@_term_end DATE	= ''2016-04-30''
	
--*/


BEGIN
	---###########Declare Variables
	DECLARE @_Sql_Select VARCHAR(8000)
	DECLARE @_location_group varchar(30)
	,@_exclude_int_deal_sub_types varchar(30)
	,@_include_deal_types varchar(30)	,@_include_deal_sub_types varchar(30)
	set @_location_group	=''Storage''
	select @_exclude_int_deal_sub_types =''151,152''
	,@_include_deal_types =''39'',	 --Storage
	@_include_deal_sub_types =''1169,1170''	-- injection, withdrawal
	
	SELECT @_include_deal_types = d.source_deal_type_id 
	FROM source_deal_type d 
	WHERE d.source_deal_type_name = ''storage''


	SELECT @_include_deal_sub_types = STUFF(
		(SELECT '',''  + CAST(d.source_deal_type_id AS VARCHAR)
		FROM source_deal_type d 
		WHERE d.source_deal_type_name in( ''injection'',''withdrawal'')
		FOR XML PATH(''''))
	, 1, 1, '''')	  

	--####### create temporary tables for selected hierarchy
	if object_id(''tempdb..#books'') is not null
	drop table #books
	CREATE TABLE #books (fas_book_id int) 

	INSERT INTO  #books
	 SELECT distinct 
				book.entity_id fas_book_id 
	 FROM 
			portfolio_hierarchy book (nolock)
			INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id           
			LEFT OUTER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id
	 WHERE 
			(fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) 
	  
	AND (''@sub_id'' = ''NULL'' OR stra.parent_entity_id IN (@sub_id)) 
	AND (''@stra_id'' = ''NULL'' OR stra.entity_id IN (@stra_id)) 
	AND (''@book_id'' = ''NULL'' OR book.entity_id IN (@book_id))
	
--select * from #books
----######## Get the require output
--PRIOR BALANCE
	if object_id(''tempdb..#temp'') is not null
	drop table #temp
	CREATE TABLE #temp (
		counterparty_id VARCHAR(250),
		location_id INT,
		curve_id INT ,
		[Counterparty] VARCHAR(250),
		[Location]  VARCHAR(250),
		[Index]  VARCHAR(250),
		[Date] DATETIME,
		[Injection] FLOAT,
		[Withdrawal] FLOAT,
		[Daily Average Balance] FLOAT,
		[UOM]  VARCHAR(250)	,
		source_deal_header_id int ,
		contract_id int,	[contract_name] varchar(100),
		[Injection_amt] FLOAT,
		[Withdrawal_amt] FLOAT,

		row_id int identity(1,1)
		 
	)

	

--CURRENT PERIOD								  
	SET @_Sql_Select=''
	INSERT INTO #temp (
		counterparty_id ,sdd.location_id ,sdd.curve_id  ,
		[Counterparty] ,[Location] ,[Index],[Date],[Injection],
		[Withdrawal],[Daily Average Balance] ,[UOM] 
		,contract_id ,contract_name	 ,[Injection_amt] ,[Withdrawal_amt]
	)
	SELECT
		max(sc.counterparty_id) counterparty_id,
		sdd.location_id,
		max(sdd.curve_id) curve_id,
		max(sc.counterparty_name) [Counterparty],
		ml.location_name [Location],
		max(spcd.curve_name) [Index],
		(sdd.term_start) as [Date],
		SUM(CASE WHEN buy_sell_flag=''''s'''' THEN deal_volume ELSE 0 END) AS [Injection],
		SUM(CASE WHEN buy_sell_flag=''''b'''' THEN deal_volume ELSE 0 END) AS [Withdrawal],
		SUM(CASE WHEN buy_sell_flag=''''b'''' THEN -1 ELSE 1 END* deal_volume) AS [Daily Average Balance],
		max(su.uom_name) [UOM]
		,max(sdh.contract_id) contract_id,isnull(cg.contract_name,'''''''') 
		,SUM(CASE WHEN sdd.buy_sell_flag=''''s'''' THEN sds.settlement_amount ELSE 0 END) [Injection_amt]
		,SUM(CASE WHEN sdd.buy_sell_flag=''''b'''' THEN sds.settlement_amount ELSE 0 END) [Withdrawal_amt]
	FROM #books b 
		INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = b.fas_book_id
		INNER JOIN source_deal_header sdh ON sdh.source_system_book_id1 = ssbm.source_system_book_id1 
				AND sdh.source_system_book_id2 = ssbm.source_system_book_id2
				AND sdh.source_system_book_id3 = ssbm.source_system_book_id3
				AND sdh.source_system_book_id4 = ssbm.source_system_book_id4
				and sdh.source_deal_type_id=''+@_include_deal_types+''
				and sdh.deal_sub_type_type_id in (''+@_include_deal_sub_types+'')
		INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
		INNER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id
		inner JOIN source_minor_location ml on ml.source_minor_location_id=sdd.location_id
		inner JOIN source_major_location mj on mj.source_major_location_id=ml.source_major_location_ID and mj.location_name=''''''+@_location_group+''''''
		outer apply
			( select max(as_of_date) as_of_date from source_deal_settlement where source_deal_header_id=sdh.source_deal_header_id and term_start=sdd.term_start and leg=sdd.leg ) mx
		left join   source_deal_settlement sds on sds.source_deal_header_id=sdh.source_deal_header_id 
			and sds.term_start=sdd.term_start and sds.leg=sdd.leg	and sds.as_of_date=mx.as_of_date		LEFT JOIN source_price_curve_def spcd on spcd.source_curve_def_id=sdd.curve_id
		LEFT JOIN source_uom su on su.source_uom_id=sdd.deal_volume_uom_id
		left join contract_group  cg on cg.contract_id=sdh.contract_id
	WHERE 1=1 and isnull(sdh.internal_deal_subtype_value_id,-1) not in ('' + @_exclude_int_deal_sub_types  +'') ''
		+ '' AND sdd.term_start between ''''''+CAST(@_term_start AS VARCHAR)+'''''' AND ''''''+CAST(@_term_end AS VARCHAR)+''''''''				 
		+ CASE WHEN @_commodity_id IS NOT NULL THEN '' AND spcd.commodity_id=''+CAST(@_commodity_id AS VARCHAR) ELSE '''' END
		+ CASE WHEN @_curve_id IS NOT NULL THEN '' AND sdd.curve_id=''+CAST(@_curve_id AS VARCHAR) ELSE '''' END
		+ CASE WHEN @_contract_id IS NOT NULL THEN '' AND sdh.contract_id=''+CAST(@_contract_id AS VARCHAR) ELSE '''' END
		+ CASE WHEN @_location_id IS NOT NULL THEN '' AND sdd.location_id IN ('' + @_location_id + '')'' ELSE '''' END
		
	+'' GROUP BY 
		ml.location_name,isnull(cg.contract_name,'''''''') ,sdd.term_start,sdd.location_id
	 Order by
			ml.location_name,isnull(cg.contract_name,''''''''),sdd.term_start
				''


	print @_Sql_Select		
	EXEC(@_Sql_Select)

--SELECT * FROM #temp
--- Now out the result showing the rolling sum
	if object_id(''tempdb..#tmp_rpt_data'') is not null
	drop table #tmp_rpt_data
	SELECT 
				a.[Location] [Location]
				,case when  grouping(a.[Date] )=1 then '''' else a.[contract_name] end [Contract],
				a.[Date]	Term  
			,	round(sum(a.[Injection]),2) [Injection],
				round(sum(a.injection_amt),2)  InjectionAmount,
				round(sum(a.[Withdrawal]),2)  [Withdrawal],
				round(sum(a.[Withdrawal_amt]),2) [WithdrawalAmount],
				round(SUM(wa.wacog),2)  WACOG,
				 SUM(a.[Daily Average Balance])  [Balance],
				 cast(sum(a.[Withdrawal_amt]+a.injection_amt) as numeric(30,2))  [BalanceAmount] ,
				MAX(a.[UOM]) [UOM],rowid=IDENTITY(int,1,1)
				into  #tmp_rpt_data
	
	--  select * from #tmp_rpt_data
	--select a.*
	--,wa.wacog	
	FROM
			#temp a outer apply
			(
				select top(1) term from dbo.calcprocess_storage_wacog 
				 where location_id=a.location_id and term<  @_term_start 
					 and isnull(contract_id,-1) =isnull(a.contract_id,-1) and a.[Date]=''1900-01-01''
				 order by 	term desc
			) tm
		 left join dbo.calcprocess_storage_wacog wa
				 on wa.location_id=a.location_id and wa.term= isnull(tm.term,a.[date]) 
					 and isnull(wa.contract_id,-1) =isnull(a.contract_id,-1) 

		GROUP BY
				a.[Location],a.[contract_name],a.[Date]
		order by a.[Location],a.[contract_name],isnull(a.[Date],''9999-01-01'')

		--select * from #tmp_rpt_data
		set @_Sql_Select = ''select [Location] location,[Contract] contract,Term term_start, [Injection] [injection],[InjectionAmount] [injection_amt],[Withdrawal] [withdrawal],[WithdrawalAmount] [withdrawal_amt] ,WACOG [wacog]
			,round(b.[Balance],2) [balance]
			, b.[BalanceAmount] [balance_amt]
			,[UOM] [uom]
			, ''''@sub_id'''' [sub_id], ''''@stra_id'''' [stra_id], ''''@book_id'''' [book_id], CONVERT(DATETIME, ''''@term_end'''', 21) [term_end]
			--[__batch_report__]
		from #tmp_rpt_data	 a
			outer apply
								(select min(rowid) from_id,max(rowid) to_id from #tmp_rpt_data where Location=a.Location and isnull([Contract],'''''''')  =isnull(a.[Contract],'''''''')
			) rg
			outer apply
			(
				select sum(balance) [Balance],round(sum(BalanceAmount),2) BalanceAmount from  #tmp_rpt_data where rowid<=a.rowid and  rowid between  rg.from_id and rg.to_id
								)  b 
		order by Term''
			exec(@_Sql_Select)
END' AS [tsql], @report_id_data_source_dest AS report_id
	END 
	

	IF OBJECT_ID('tempdb..#data_source_column', 'U') IS NOT NULL
		DROP TABLE #data_source_column	
	CREATE TABLE #data_source_column(column_id INT)	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'balance'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'balance'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'balance'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'balance' AS [name], 'balance' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'balance_amt'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'balance_amt'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'balance_amt'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'balance_amt' AS [name], 'balance_amt' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'book_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'book_id'
			   , reqd_param = 1, widget_id = 5, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'book_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'book_id' AS [name], 'book_id' AS ALIAS, 1 AS reqd_param, 5 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'contract'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'contract'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'contract'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'contract' AS [name], 'contract' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'injection'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'injection'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'injection'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'injection' AS [name], 'injection' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'injection_amt'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'injection_amt'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'injection_amt'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'injection_amt' AS [name], 'injection_amt' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'location'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'location'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'location'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'location' AS [name], 'location' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'stra_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'stra_id'
			   , reqd_param = 1, widget_id = 4, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'stra_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'stra_id' AS [name], 'stra_id' AS ALIAS, 1 AS reqd_param, 4 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'sub_id'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'sub_id'
			   , reqd_param = 1, widget_id = 3, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'sub_id'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'sub_id' AS [name], 'sub_id' AS ALIAS, 1 AS reqd_param, 3 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'term_end'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'term_end'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'term_end'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_end' AS [name], 'term_end' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'term_start'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'term_start'
			   , reqd_param = 1, widget_id = 6, datatype_id = 2, param_data_source = NULL, param_default_value = NULL, append_filter = 0, tooltip = NULL, column_template = 4, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'term_start'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'term_start' AS [name], 'term_start' AS ALIAS, 1 AS reqd_param, 6 AS widget_id, 2 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 0 AS append_filter, NULL  AS tooltip,4 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'uom'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'uom'
			   , reqd_param = 0, widget_id = 1, datatype_id = 5, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 0, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'uom'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'uom' AS [name], 'uom' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 5 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,0 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'wacog'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'wacog'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'wacog'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'wacog' AS [name], 'wacog' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'withdrawal'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'withdrawal'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'withdrawal'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'withdrawal' AS [name], 'withdrawal' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	IF EXISTS (SELECT 1 
	           FROM data_source_column dsc 
	           INNER JOIN data_source ds on ds.data_source_id = dsc.source_id 
	           WHERE ds.[name] = 'Storage View'
	            AND dsc.name =  'withdrawal_amt'
				AND ISNULL(report_id, -1) =  ISNULL(@report_id_data_source_dest, -1))
	BEGIN
		UPDATE dsc  
		SET alias = 'withdrawal_amt'
			   , reqd_param = 0, widget_id = 1, datatype_id = 3, param_data_source = NULL, param_default_value = NULL, append_filter = 1, tooltip = NULL, column_template = 2, key_column = 0
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		FROM data_source_column dsc
		INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		WHERE ds.[name] = 'Storage View'
			AND dsc.name =  'withdrawal_amt'
			AND ISNULL(report_id, -1) = ISNULL(@report_id_data_source_dest, -1)
	END	
	ELSE
	BEGIN
		INSERT INTO data_source_column(source_id, [name], ALIAS, reqd_param, widget_id
		, datatype_id, param_data_source, param_default_value, append_filter, tooltip, column_template, key_column)
		OUTPUT INSERTED.data_source_column_id INTO #data_source_column(column_id)
		SELECT TOP 1 ds.data_source_id AS source_id, 'withdrawal_amt' AS [name], 'withdrawal_amt' AS ALIAS, 0 AS reqd_param, 1 AS widget_id, 3 AS datatype_id, NULL AS param_data_source, NULL AS param_default_value, 1 AS append_filter, NULL  AS tooltip,2 AS column_template, 0 AS key_column				
		FROM sys.objects o
		INNER JOIN data_source ds ON ds.[name] = 'Storage View'
			AND ISNULL(ds.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		LEFT JOIN report r ON r.report_id = ds.report_id
			AND ds.[type_id] = 2
			AND ISNULL(r.report_id , -1) = ISNULL(@report_id_data_source_dest, -1)
		WHERE ds.type_id = (CASE WHEN r.report_id IS NULL THEN ds.type_id ELSE 2 END)
	END 
	
	

	DELETE dsc
	FROM data_source_column dsc 
	INNER JOIN data_source ds ON ds.data_source_id = dsc.source_id 
		AND ds.[name] = 'Storage View'
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
	