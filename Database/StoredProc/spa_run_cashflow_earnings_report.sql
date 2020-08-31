
/****** Object:  StoredProcedure [dbo].[spa_run_cashflow_earnings_report]    Script Date: 07/28/2010 16:20:44 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_cashflow_earnings_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_cashflow_earnings_report]
/****** Object:  StoredProcedure [dbo].[spa_run_cashflow_earnings_report]    Script Date: 07/28/2010 16:20:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_run_cashflow_earnings_report] 
					@as_of_date varchar(50),
					@sub_entity_id varchar(500), 
					@strategy_entity_id varchar(100) = NULL, 
					@book_entity_id varchar(100) = NULL, 
					@summary_option char(1), 
					@counterparty_id NVARCHAR(1000)= NULL, 
					@tenor_from varchar(50)= null,
					@tenor_to varchar(50) = null,
					@trader_id int = null,
					@include_item char(1)='n', -- to include item in cash flow hedge
					@source_system_book_id1 int=NULL, 
					@source_system_book_id2 int=NULL, 
					@source_system_book_id3 int=NULL, 
					@source_system_book_id4 int=NULL, 
					@transaction_type VARCHAR(500)=null,
					@deal_id_from int=null,
					@deal_id_to int=null,
					@deal_id varchar(100)=null,
					@round_value char(1) = '0',
					@counterparty char(1) = 'a', --i means only internal and e means only external, a means all
					@cpty_type_id int = NULL,  
					@curve_source_id INT=4500,
					@deal_sub_type_id CHAR(1)='t',
					@deal_date_from varchar(20)=NULL,
					@deal_date_to varchar(20)=NULL,
					@phy_fin varchar(1)='b',
					@deal_type_id int=NULL,
					@term_start VARCHAR(20)=NULL,
					@term_end VARCHAR(20)=NULL,
					@settlement_date_from VARCHAR(20)=NULL,
					@settlement_date_to VARCHAR(20)=NULL,
					@settlement_only CHAR(1)='n',
					@model_type INT=NULL,
					@drill_sub VARCHAR(100)=NULL,
					@drill_strategy VARCHAR(100)=NULL,
					@drill_book VARCHAR(100)=NULL,
					@drill_counterparty VARCHAR(100)=NULL,
					@drill_deal_ref_id VARCHAR(100)=NULL,
					@drill_deal_date VARCHAR(100)=NULL,
					@drill_exp_date VARCHAR(100)=NULL,
					@drill_model_name VARCHAR(100)=NULL,
					@drill_model_type VARCHAR(100)=NULL,
					@drill_category VARCHAR(100)=NULL,

					--END
					@batch_process_id varchar(50)=NULL,
					@batch_report_param varchar(1000)=NULL
					
					
AS
---------------------------------------------------------------
SET NOCOUNT ON

Declare @Sql varchar(MAX)
DECLARE @str_batch_table varchar(MAX)   
DECLARE @process_id varchar(50)
DECLARE @drill varchar(1)

set @drill_exp_date = dbo.FNAStdDate(@drill_exp_date)
     
if @drill_category=''
	SET @drill_category = NULL

	IF ( @deal_id_from IS NOT NULL AND @deal_id_to IS NULL )
		SET @deal_id_to = @deal_id_from
	ELSE IF ( @deal_id_from IS NULL AND @deal_id_to IS NOT NULL ) 
		SET @deal_id_from = @deal_id_to

	if @tenor_from is null and @tenor_to is not null

		set @tenor_from = @tenor_to

	if @tenor_from is not null and @tenor_to is null


	SET @tenor_to = @tenor_from 
	SET @str_batch_table=''        

	IF @batch_process_id is not null  

	BEGIN      
		SELECT @str_batch_table = dbo.FNABatchProcess('s', @batch_process_id, @batch_report_param, NULL, NULL, NULL)   
	END



	CREATE TABLE #books (fas_book_id int) 

	SELECT @drill_model_type =  DESCRIPTION FROM cash_flow_model_type_detail WHERE model_type_id =@drill_model_type

	SET @Sql=        

	'INSERT INTO  #books

	SELECT distinct book.entity_id fas_book_id FROM portfolio_hierarchy book (nolock) INNER JOIN

			Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            

			source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id         

	WHERE (fas_deal_type_value_id IS NULL OR fas_deal_type_value_id BETWEEN 400 AND 401) 

	'   
	+CASE WHEN  @sub_entity_id IS NOT NULL THEN ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') ' ELSE '' END
	+CASE WHEN  @strategy_entity_id IS NOT NULL THEN ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))' ELSE '' END
	+CASE WHEN  @book_entity_id IS NOT NULL THEN ' AND (book.entity_id IN(' + @book_entity_id + ')) ' ELSE '' END

	EXEC (@Sql)





	CREATE TABLE #temp_pnl
	(
		Sub varchar(100) COLLATE DATABASE_DEFAULT,
		Strategy varchar(100) COLLATE DATABASE_DEFAULT,
		Book varchar(100) COLLATE DATABASE_DEFAULT,
		source_deal_header_id int,
		deal_id varchar(50) COLLATE DATABASE_DEFAULT,
		term_start datetime,
		leg INT,
		hedge_or_item varchar(5) COLLATE DATABASE_DEFAULT,
		counterparty_name varchar(100) COLLATE DATABASE_DEFAULT,
		pnl float,
		first_day_pnl_threshold float,
		pnl_as_of_date datetime,
		deal_date datetime,
		physical_financial_flag varchar(1) COLLATE DATABASE_DEFAULT,
		sbm1 varchar(50) COLLATE DATABASE_DEFAULT,
		sbm2 varchar(50) COLLATE DATABASE_DEFAULT,
		sbm3 varchar(50) COLLATE DATABASE_DEFAULT,
		sbm4 varchar(50) COLLATE DATABASE_DEFAULT,
		fas_deal_type_value_id int ,
		sub_id int,
		volume FLOAT,
		term_end DATETIME,
		block_type INT,
		block_definition_id INT,
		model_type INT,
		model_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		model_desc VARCHAR(100) COLLATE DATABASE_DEFAULT,
		Category VARCHAR(100) COLLATE DATABASE_DEFAULT,
		category_value FLOAT,
		formula_id INT,
		model_id INT,
		currency_name VARCHAR(100) COLLATE DATABASE_DEFAULT,
		settlement_date DATETIME
	
	)



SET @Sql = 

'
INSERT INTO #temp_pnl
select	
		max(sub.entity_name) Sub, max(stra.entity_name) Strategy, max(book.entity_name) Book,

		sdh.source_deal_header_id, max(sdh.deal_id) deal_id, 

		sdd.term_start, 
		sdd.leg,

		case when (max(ssbm.fas_deal_type_value_id) = 400) then ''Der'' else ''Item'' end hedge_or_item, 

		max(sc.counterparty_name) counterparty_name,

		SUM(dcced.value) und_pnl,

		max(isnull(first_day_pnl_threshold, 0)) first_day_pnl_threshold,

		MAX(dce.as_of_date) pnl_as_of_date,

		max(sdh.deal_date) deal_date,

		max(sdh.physical_financial_flag) physical_financial_flag,

		MAX(CASE WHEN (sb1.source_book_id < 0) THEN NULL ELSE sb1.source_system_book_id END) sbm1,

		MAX(CASE WHEN (sb2.source_book_id < 0) THEN NULL ELSE sb2.source_system_book_id END) sbm2,

		MAX(CASE WHEN (sb3.source_book_id < 0) THEN NULL ELSE sb3.source_system_book_id END) sbm3,

		MAX(CASE WHEN (sb4.source_book_id < 0) THEN NULL ELSE sb4.source_system_book_id END) sbm4,

		MAX(ssbm.fas_deal_type_value_id) fas_deal_type_value_id,max(sub.entity_id) sub_id,
		SUM(sdd.deal_volume),
		MAX(sdd.term_end),
		MAX(ISNULL(spcd.block_type,sdh.block_type))block_type,
		MAX(ISNULL(spcd.block_define_id,sdh.block_define_id)) block_definition_id,
		(dce.model_type)	,
		(cfmt.model_name),
		(cfmtd.description),
		(sd1.code) as Category,
		SUM(dcced.value) as category_value,
		dcced.formula_id,
		MAX(cfmt.model_id),
		MAX(cur.currency_name),
		dcced.settlement_date
from	#books b 
		INNER JOIN source_system_book_map ssbm ON ssbm.fas_book_id = b.fas_book_id 
		INNER JOIN source_deal_header sdh on sdh.source_system_book_id1 = ssbm.source_system_book_id1 
				  AND sdh.source_system_book_id2 = ssbm.source_system_book_id2 
				  AND sdh.source_system_book_id3 = ssbm.source_system_book_id3 
				  AND sdh.source_system_book_id4 = ssbm.source_system_book_id4  
		INNER JOIN source_counterparty sc on sc.source_counterparty_id = sdh.counterparty_id 
		INNER JOIN	portfolio_hierarchy book on book.entity_id = ssbm.fas_book_id
		INNER JOIN portfolio_hierarchy stra on stra.entity_id = book.parent_entity_id 
		INNER JOIN portfolio_hierarchy sub on sub.entity_id = stra.parent_entity_id
		INNER JOIN fas_strategy fs on fs.fas_strategy_id = stra.entity_id
		INNER JOIN source_book sb1 ON sb1.source_book_id = sdh.source_system_book_id1
		INNER JOIN source_book sb2 ON sb2.source_book_id = sdh.source_system_book_id2
		INNER JOIN source_book sb3 ON sb3.source_book_id = sdh.source_system_book_id3
		INNER JOIN source_book sb4 ON sb4.source_book_id = sdh.source_system_book_id4
		INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
				--AND sdd.term_start=sdp.term_start and sdd.leg=1
		INNER JOIN deal_calc_cashflow_earnings dce ON dce.source_deal_header_id=sdh.source_deal_header_id
				 AND dce.term_start=sdd.term_start
				 AND dce.leg=sdd.leg
				 AND dce.source_deal_header_id=sdh.source_deal_header_id
		INNER JOIN cash_flow_model_type_detail cfmtd ON cfmtd.model_type_id=dce.model_type
		INNER JOIN cash_flow_model_type cfmt ON cfmt.model_id=cfmtd.model_id
		LEFT OUTER JOIN source_price_curve_def spcd ON sdd.curve_id=spcd.source_curve_def_id	
		LEFT OUTER JOIN formula_nested fn ON fn.formula_group_id=cfmtd.formula_id
		LEFT OUTER JOIN static_data_value sd1 ON sd1.value_id=fn.show_value_id
		LEFT OUTER JOIN deal_calc_cashflow_earnings_detail dcced ON sdh.source_deal_header_id=dcced.deal_id
				AND dcced.formula_id=fn.formula_group_id
				AND dce.as_of_date=dcced.as_of_date
				AND dce.term_start=dcced.term_start
				AND sdd.leg=dcced.leg		
				AND dcced.sequence_number=fn.sequence_order
				
		LEFT JOIN(select MAX(sequence_order) sequence_order, formula_group_id FROM formula_nested group by formula_group_id) mfn
				ON mfn.formula_group_id=fn.formula_group_id and fn.sequence_order<>mfn.sequence_order
		LEFT JOIN source_currency cur on cur.source_currency_id=sdd.fixed_price_currency_id
	'

	SET @Sql = @Sql + ' WHERE 1=1 
				AND dcced.settlement_date IS NOT NULL
				AND sdd.leg=1
				AND dce.as_of_date='''+@as_of_date+''''
			
		

	if @model_type IS NOT NULL
		SET @Sql = @Sql + ' AND cfmtd.model_type_id = ' + cast(@model_type as varchar)

	If @trader_id IS NOT NULL 
   		SET @Sql = @Sql + ' AND sdh.trader_id = ' + cast(@trader_id as varchar)

	If @deal_type_id IS NOT NULL 
   		SET @Sql = @Sql + ' AND sdh.source_deal_type_id = ' + cast(@deal_type_id as varchar)

	If @deal_sub_type_id IS NOT NULL 
   		SET @Sql = @Sql + ' AND sdh.deal_sub_type_type_id = ' + cast(@deal_sub_type_id as varchar)


	If @counterparty_id IS NOT NULL 

   		SET @Sql = @Sql +  ' AND (sdh.counterparty_id IN (' + @counterparty_id + ')) '

	If @counterparty IS NOT NULL AND  @counterparty <> 'a'
		SET @sql = @sql + ' AND sc.int_ext_flag = '''+@counterparty+''''

	If @source_system_book_id1 IS NOT NULL 

   		SET @Sql = @Sql +  ' AND (sdh.source_system_book_id1 IN (' + cast(@source_system_book_id1 as varchar)+ ')) '

	If @source_system_book_id2 IS NOT NULL 

   		SET @Sql = @Sql +  ' AND (sdh.source_system_book_id2 IN (' + cast(@source_system_book_id2 as varchar) + ')) '

	If @source_system_book_id3 IS NOT NULL 

   		SET @Sql = @Sql +  ' AND (sdh.source_system_book_id3 IN (' + cast(@source_system_book_id3 as varchar) + ')) '

	If @source_system_book_id4 IS NOT NULL 

   		SET @Sql = @Sql +  ' AND (sdh.source_system_book_id4 IN (' + cast(@source_system_book_id4 as varchar) + ')) '



	If @cpty_type_id IS NOT NULL
   		SET @Sql = @Sql + + ' AND sc.type_of_entity = ' + CAST(@cpty_type_id AS VARCHAR) 

	if @transaction_type is not null 
		SET @Sql = @Sql +  ' AND ssbm.fas_deal_type_value_id IN( ' + cast(@transaction_type as varchar(500))+')'

	IF (@deal_date_from IS NOT NULL)
		SET @Sql = @Sql +' AND convert(varchar(10),sdh.deal_date,120)>='''+convert(varchar(10),@deal_date_from,120) +''''

	IF (@deal_date_to IS NOT NULL)
		SET @Sql = @Sql +' AND convert(varchar(10),sdh.deal_date,120) <='''+convert(varchar(10),@deal_date_to,120) +''''


	If isnull(@phy_fin, 'b') <> 'b'
   		SET @Sql = @Sql + ' AND sdh.physical_financial_flag = ''' + @phy_fin + ''''
						
	if @deal_id_from IS NOT NULL
		SET @Sql = @Sql +' AND sdh.source_deal_header_id BETWEEN ' + cast(@deal_id_from as varchar) +' AND ' + CAST(@deal_id_to AS VARCHAR)

	if @deal_id IS NOT NULL
		SET @Sql = @Sql +' AND sdh.deal_id = ''' + @deal_id + ''''

	If @tenor_from  IS NOT NULL AND @tenor_to IS NOT NULL
   		SET @Sql = @Sql + ' AND sdd.term_start BETWEEN ''' + @tenor_from + ''' AND ''' +  @tenor_to + ''''


	IF (@term_start IS NOT NULL)
		SET @Sql = @Sql +' AND convert(varchar(10),sdd.term_start,120) >='''+convert(varchar(10),@term_start,120) +''''

	IF (@term_end IS NOT NULL)
		SET @Sql = @Sql +' AND convert(varchar(10),sdd.term_end,120)<='''+convert(varchar(10),@term_end,120) +''''



	IF (@drill_model_name IS NOT NULL)
		SET @Sql = @Sql +' AND cfmt.model_name=LTRIM(RTRIM('''+@drill_model_name+'''))'

	IF (@drill_category IS NOT NULL)
		SET @Sql = @Sql +' AND sd1.code=LTRIM(RTRIM('''+@drill_category+'''))'

	IF (@drill_model_type IS NOT NULL)
		SET @Sql = @Sql +' AND cfmtd.description=LTRIM(RTRIM('''+@drill_model_type+'''))'

	SET @sql=@sql+
				' GROUP BY sdh.source_deal_header_id,sdd.term_start,sdd.leg,sd1.code,dce.model_type,cfmt.model_name,cfmtd.description,dcced.formula_id,dcced.settlement_date'




	EXEC(@Sql)

	IF @summary_option = 's'

		Set @Sql = 

		' select	
			MAX([dbo].[FNAHyperLinkText](10182300,model_name,model_id)) AS [Model],
			dbo.FNADateformat(dbo.FNAGetContractMonth(settlement_date)) [Term],	
			model_desc [Model Type],
			round(sum(ISNULL(pnl,0)), ' +@round_value + ') [Value],
			MAX(currency_name) [Currency]

		 ' + @str_batch_table +

		' from #temp_pnl

		group by dbo.FNADateformat(dbo.FNAGetContractMonth(settlement_date)),model_name,model_desc

		order by model_name,CAST(dbo.FNADateformat(dbo.FNAGetContractMonth(settlement_date)) AS DATETIME)'

	IF @summary_option = 'c'

		Set @Sql = 

		' select	Sub, Strategy, Book, hedge_or_item [Type], counterparty_name Counterparty, round(sum(pnl), ' +@round_value + ') [Value]

		 ' + @str_batch_table +

		' from #temp_pnl

		group by Sub, Strategy, Book, hedge_or_item, counterparty_name 

		order by Sub, Strategy, Book, hedge_or_item, counterparty_name '

	ELSE IF @summary_option = 't'

		Set @Sql = 

		'select Sub, Strategy, Book, hedge_or_item [Type], counterparty_name Counterparty, dbo.FNADateFormat(term_start) Expiration, 

				round(sum(pnl), ' +@round_value + ') [Value]

		 ' + @str_batch_table +

		' from #temp_pnl

		group by Sub, Strategy, Book, hedge_or_item, counterparty_name, term_start 

		order by Sub, Strategy, Book, hedge_or_item, counterparty_name, term_start ' 

	ELSE IF @summary_option = 'q'

		Set @Sql = 

		'select Sub, hedge_or_item [Type], counterparty_name Counterparty, dbo.FNADateFormat(term_start) Expiration, 

				round(sum(pnl), ' +@round_value + ') [Value]

		 ' + @str_batch_table +

		' from #temp_pnl

		group by Sub, hedge_or_item, counterparty_name, term_start 

		order by Sub, hedge_or_item, counterparty_name, term_start '

	ELSE IF @summary_option = 'p'

		Set @Sql = 

		'select Sub, hedge_or_item [Type], counterparty_name Counterparty, round(sum(pnl), ' +@round_value + ') [Value]

		 ' + @str_batch_table +

		' from #temp_pnl

		group by Sub, hedge_or_item, counterparty_name 

		order by Sub, hedge_or_item, counterparty_name '

	ELSE IF @summary_option = 'r'

		Set @Sql = 

		'select Sub, hedge_or_item [Type], dbo.FNADateFormat(term_start) Expiration, round(sum(pnl), ' +@round_value + ') [Value]

		 ' + @str_batch_table +

		' 	from #temp_pnl

		group by Sub, hedge_or_item, term_start 

		order by Sub, hedge_or_item, term_start '

	ELSE IF @summary_option = 'd'

		set @Sql = 

		'SELECT  Sub, Strategy, Book, counterparty_name Counterparty, 

				dbo.FNAHyperLink(10131010,(cast(source_deal_header_id as varchar) + '' ('' + deal_id +  '')''),source_deal_header_id,'''+isNull(@batch_process_id,'-1') +''') AS [Ref ID], 

				dbo.FNADateFormat(deal_date) DealDate,

				dbo.FNADateFormat(pnl_as_of_date) PNLDate,		

				hedge_or_item [Type], 

				MAX(case when (physical_financial_flag) = ''p'' then ''Phy'' else ''Fin'' end) [Phy/Fin],

				dbo.FNADateFormat(term_start) AS [Expiration],

				SUM(round(ISNULL(category_value,0), ' +@round_value + ')) [Value]

			' + @str_batch_table +

					' from  	#temp_pnl
					group by Sub, Strategy, Book, counterparty_name,dbo.FNAHyperLink(10131010,(cast(source_deal_header_id as varchar) + '' ('' + deal_id +  '')''),source_deal_header_id,'''+isNull(@batch_process_id,'-1') +'''),
					dbo.FNADateFormat(deal_date),dbo.FNADateFormat(pnl_as_of_date),hedge_or_item,dbo.FNADateFormat(term_start)
					order by Sub, Strategy, Book, hedge_or_item, dbo.FNADateFormat(term_start) 

	' 

	ELSE IF @summary_option = 'f'
	BEGIN
	
	CREATE TABLE #temp([ID] INT identity(1,1),[RowNo] INT,[Description] VARCHAR(500) COLLATE DATABASE_DEFAULT,[Formula_Str] VARCHAR(1000) COLLATE DATABASE_DEFAULT,[Formula] VARCHAR(1000) COLLATE DATABASE_DEFAULT,[Value] FLOAT)
	CREATE TABLE #temp_f(formula varchar(2000) COLLATE DATABASE_DEFAULT)  


	INSERT INTO #temp([RowNo],[Description],[Formula_Str],[Formula],[Value])
	SELECT  DISTINCT
		dcced.sequence_number AS [RowNo],
		fn.description1 AS [Description],
		dcced.formula_str as [Formula_Str],
		dbo.FNAFormulaFormat(fe.formula,'r') AS [Formula],
		dcced.[value] AS [Value]
	FROM
		#temp_pnl tp
		INNER JOIN cash_flow_model_type_detail cfmtd ON tp.model_type=cfmtd.model_type_id
		INNER JOIN deal_calc_cashflow_earnings_detail dcced ON tp.source_deal_header_id=dcced.deal_id
			AND dcced.formula_id=cfmtd.formula_id
		    AND tp.pnl_as_of_date=dcced.as_of_date
		    AND tp.term_start=dcced.term_start
		    AND tp.leg=dcced.leg	
		INNER JOIN(SELECT formula_id,deal_id,term_start 
			from deal_calc_cashflow_earnings_detail	WHERE (@drill_exp_date IS NULL OR dbo.FNAGetContractMonth(settlement_date)=dbo.FNAGetContractMonth(LTRIM(RTRIM(@drill_exp_date))))
					GROUP BY formula_id,deal_id,term_start) a
			ON a.formula_id=cfmtd.formula_id
		    AND a.deal_id=dcced.deal_id
		    AND a.term_start=dcced.term_start

		INNER  JOIN formula_nested fn On fn.formula_group_id=dcced.formula_id 
				AND fn.sequence_order=dcced.sequence_number
		INNER  JOIN formula_editor fe on fe.formula_id=fn.formula_id
	WHERE 1=1
		AND (@drill_counterparty IS NULL OR tp.counterparty_name=LTRIM(RTRIM(@drill_counterparty)))
		AND (@drill_deal_date IS NULL OR dbo.FNADateFormat(tp.deal_date)=LTRIM(RTRIM(@drill_deal_date)))
		AND (@drill_deal_ref_id IS NULL OR CAST(tp.source_deal_header_id As varchar)+' ('+tp.deal_id+')'=LTRIM(RTRIM(@drill_deal_ref_id)))
		AND ((tp.model_name=LTRIM(RTRIM(@drill_model_name))  AND @drill_model_name IS NOT NULL) OR @drill_model_name IS NULL)
		AND ((tp.model_desc=LTRIM(RTRIM(@drill_model_type))  AND @drill_model_type IS NOT NULL) OR @drill_model_type IS NULL)
		AND ((tp.category=LTRIM(RTRIM(@drill_category)) AND @drill_category IS NOT NULL) OR @drill_category IS NULL)




	DECLARE @ID INT, @formula_str VARCHAR(1000)

	DECLARE cur1 CURSOR FOR
	SELECT 
		[ID],[Formula_Str] FROM #temp
	OPEN cur1
	FETCH NEXT FROM cur1 INTO @ID,@formula_str
	WHILE @@FETCH_STATUS=0
	BEGIN
		
		set @formula_str=replace(@formula_str,'','''')  
		
			INSERT INTO #temp_f(formula)  
			exec spa_drill_down_function_call_temp @formula_str  

			update #temp SET formula_str=formula+'<br><em>'+(select formula FROM #temp_f)+'</b></em>'  WHERE [ID]=@ID
			DELETE FROM #temp_f  
		FETCH NEXT FROM cur1 INTO @ID,@formula_str
	END
			
	CLOSE cur1
	DEALLOCATE cur1
	
	SELECT  [RowNo] as [Row No],[Description],[Formula_Str] as [Formula],MAX([Value]) AS [Value] FROM #temp GROUP BY [RowNo],[Description],[Formula_Str]

	RETURN

END	


EXEC(@Sql)

----exec spa_Create_MTM_Period_Report '2004-12-31', '30', '208', '223', 'u', 'a', 'a', 'l',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n',NULL,NULL,NULL,NULL,NULL,'n','n','y','n','2','a','m','n',NULL
--	
--
--
--
--if @batch_process_id is not null
--BEGIN
--	exec spa_print '@str_batch_table'  
--	 SELECT @str_batch_table=dbo.FNABatchProcess('u',@batch_process_id,@batch_report_param,GETDATE(),NULL,NULL)   
--		   exec spa_print @str_batch_table
--	 EXEC(@str_batch_table)                   
--    
--
--	IF @settlement_only='y'
--	set @report_name='Run Settlement Report'        
--	ELSE 
--	 set @report_name='Run MTM Report'          
--   
--	SELECT @str_batch_table=dbo.FNABatchProcess('c',@batch_process_id,@batch_report_param,GETDATE(),'spa_Create_MTM_Period_Report',@report_name)         
--	EXEC spa_print @str_batch_table
--	EXEC(@str_batch_table)        
--	EXEC spa_print 'finsh Run MTM Report'
--	return
--
--END

--********************************************************************   



--------- ============================== 

-- ***************** FOR BATCH PROCESSING **********************************    
 
IF  @batch_process_id IS NOT NULL        
BEGIN        
	 SELECT @str_batch_table = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL)         
	 EXEC(@str_batch_table)        
	 DECLARE @report_name VARCHAR(100)        

	 SET @report_name = 'Financial Forecast Report'        
	        
	 SELECT @str_batch_table = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_run_cashflow_earnings_report', @report_name)         
	 EXEC(@str_batch_table)        
	        
END        
-- ********************************************************************   



