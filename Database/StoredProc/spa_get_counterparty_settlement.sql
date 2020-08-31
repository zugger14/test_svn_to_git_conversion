
/****** Object:  StoredProcedure [dbo].[spa_get_counterparty_SETtlement]    Script Date: 10/15/2009 22:37:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_counterparty_SETtlement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_counterparty_SETtlement]
/****** Object:  StoredProcedure [dbo].[spa_get_counterparty_SETtlement]    Script Date: 10/15/2009 22:37:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--****************************************
-- This report is used to generate list of counterparty for the selected subsidiary to process
--for reconciliation. Also used for generating exception report
-- flag 's' - list all the  counterparty forselected sub
-- flag 'r' - list all counterparty for selected sub for selected production month which receives invoice
-- flag 'n' - list all counterparty for selected sub for selected production month which dows not receive invoice
-- flag 'e' - generate exception report for selected sub
-- EXEC spa_get_counterparty_SETtlement 'r',230,'07/01/2006','08/01/2006','n','n'
--  EXEC spa_get_counterparty_SETtlement 's',193,NULL,NULL,'n','n',NULL,'n','n',NULL,NULL,'e'
--*****************************************
CREATE PROCEDURE [dbo].[spa_get_counterparty_settlement]
		@flag char(1)=NULL,
		@sub_id int=NULL,
		@prod_date datetime='9999-01-01',
		@as_of_date datetime='9999-01-01',
		@noinvoice char(1)='y',
		@nocalculate char(1)=null,
		@prod_date_to datetime=NULL,
		@nomv90data char(1)=NULL, -- y=generator which do not have meterid
		@onemeter char(1)=NULL,-- y= one meterid which has mulltiple generator
		@recorderid varchar(100)=NULL,
		@counterparty_id int=null,
		@counterparty_flag VARCHAR(5)='e',
		@estimate_calculation CHAR(1)='n',
		@contract_id INT=NULL,
		@cpt_type CHAR(1) = NULL,
		@date_type CHAR(1) = NULL -- 's' settlement date, 't' term

AS

DECLARE @sql VARCHAR(8000)

CREATE TABLE #temp_date([id] INT IDENTITY,prod_date DATETIME)
DECLARE @count INT
DECLARE @prod_date_new DATETIME
DECLARE @table_calc_invoice_volume_variance VARCHAR(50)
	IF @estimate_calculation IS NULL
		SET @estimate_calculation='n'
		
	IF @estimate_calculation='y'
		BEGIN
			SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance_estimates'
		END
	ELSE
		BEGIN
			SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance'
		END

IF @prod_date_to IS NULL
	SET @prod_date_to = @prod_date
	
SET @counterparty_flag=isnull(@counterparty_flag,'e')
IF @counterparty_flag='e'
   SET @counterparty_flag='i'',''e'''

	IF @flag='s' -- select list of counterparty for the sub
	BEGIN

		SET @sql='
		select distinct
			max(sc.source_counterparty_id) [Counterparty ID],
			max(sc.counterparty_name) Counterparty,
			max(cg.contract_id) as contract

		from
			source_counterparty sc 
			INNER JOIN '+@table_calc_invoice_volume_variance+' civ on sc.source_counterparty_id=civ.counterparty_id
			LEFT JOIN contract_group cg on cg.contract_id=civ.contract_id
			WHERE 1=1 '+
		CASE WHEN @sub_id is not null THEN 
			' AND civ.sub_id='+cast(@sub_id as varchar) ELSE '' END +
		CASE WHEN @counterparty_id is not null THEN 
			' AND sc.source_counterparty_id='+cast(@counterparty_id as varchar) ELSE '' END +
		 +' And int_ext_flag in('''+@counterparty_flag+''')'+
		' group by sc.source_counterparty_id ORDER BY max(sc.counterparty_name)'


		EXEC(@sql)
		RETURN
	END



	IF @flag='o' -- select list of counterparty for the sub to populate the combos
	BEGIN

		SET @sql='
		select distinct
			sc.source_counterparty_id [Counterparty ID],
			sc.counterparty_name Counterparty
		from
			source_counterparty sc 
			inner join '+@table_calc_invoice_volume_variance+' civ on sc.source_counterparty_id=civ.counterparty_id
			inner join contract_group cg on cg.contract_id=civ.contract_id
			WHERE 1=1  '+
		CASE WHEN @sub_id is not null THEN 
			' AND civ.sub_id='+cast(@sub_id AS VARCHAR) ELSE '' END +
		CASE WHEN @counterparty_id is not null THEN 
			' AND sc.source_counterparty_id='+cast(@counterparty_id AS VARCHAR) ELSE '' END +
		 +' And int_ext_flag in('''+@counterparty_flag+''')'+
		' ORDER BY sc.counterparty_name '

	EXEC(@sql)
	RETURN
	END



--******************************************************            
--CREATE source book map table and build index            
--*********************************************************            
	SET @sql = ''            
		CREATE TABLE #ssbm(            
		 source_system_book_id1 int,            
		 source_system_book_id2 int,            
		 source_system_book_id3 int,            
		 source_system_book_id4 int,            
		 fas_deal_type_value_id int,            
		 book_deal_type_map_id int,            
		 fas_book_id int,            
		 stra_book_id int,            
		 sub_entity_id int            
		)            
----------------------------------            
	SET @sql=            
	'INSERT INTO #ssbm            
	SELECT            
	  source_system_book_id1,source_system_book_id2,source_system_book_id3,source_system_book_id4,fas_deal_type_value_id,            
	  book_deal_type_map_id,book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id             
	FROM            
	 source_system_book_map ssbm             
	 INNER JOIN portfolio_hierarchy book (nolock) ON ssbm.fas_book_id = book.entity_id             
	 INNER JOIN Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id	            
	WHERE 1=1 '            
	IF @sub_id IS NOT NULL            
	  SET @sql = @sql + ' AND stra.parent_entity_id IN  ( ' + cast (@sub_id as varchar)+ ') '             

	   
	EXEC (@sql)         


	 --------------------------------------------------------------            
	CREATE  INDEX [IX_PH1] ON [#ssbm]([source_system_book_id1])                  
	CREATE  INDEX [IX_PH2] ON [#ssbm]([source_system_book_id2])                  
	CREATE  INDEX [IX_PH3] ON [#ssbm]([source_system_book_id3])                  
	CREATE  INDEX [IX_PH4] ON [#ssbm]([source_system_book_id4])                  
	CREATE  INDEX [IX_PH5] ON [#ssbm]([fas_deal_type_value_id])                  
	CREATE  INDEX [IX_PH6] ON [#ssbm]([fas_book_id])                  
	CREATE  INDEX [IX_PH7] ON [#ssbm]([stra_book_id])                  
	CREATE  INDEX [IX_PH8] ON [#ssbm]([sub_entity_id])                  
            
--******************************************************            
--END of source book map table and build index            
--*********************************************************            


	create table #temp_counterparty
	(
		counterparty_id int,
		counterparty_name varchar(100) COLLATE DATABASE_DEFAULT,
		generator_id int,
		legal_entity_value_id int,
		contract_id int
	)

	insert into #temp_counterparty(counterparty_id,counterparty_name,generator_id,legal_entity_value_id,contract_id)
	select source_counterparty_id,counterparty_name,max(generator_id),max(legal_entity_value_id),contract_id
	from
	(
	select 
		source_counterparty_id,counterparty_name,rg.generator_id,rg.legal_entity_value_id,cg.contract_id
	from 
		source_counterparty sc 
		inner join rec_generator rg on sc.source_counterparty_id=isnull(rg.ppa_Counterparty_id,'')
		inner join contract_group cg on cg.contract_id=rg.ppa_Contract_id
		WHERE isnull(term_END,'9999-01-01')>=dbo.FNAGetContractMonth(@prod_date)
		AND ISNULL(sc.int_ext_flag,'e') = ISNULL(@cpt_type,'e')
		
	UNION
	select 
		source_counterparty_id,counterparty_name,sdh.generator_id as generator_id,@sub_id as legal_entity_value_id,cg.contract_id
	from 
		source_counterparty sc 
		inner join source_deal_header sdh on sc.source_counterparty_id = CASE WHEN @cpt_type = 'b' THEN sdh.broker_id ELSE sdh.counterparty_id END
		inner join contract_group cg on cg.contract_id=sdh.Contract_id
		inner join #ssbm ssbm ON sdh.source_system_book_id1=ssbm.source_system_book_id1
			AND sdh.source_system_book_id2=ssbm.source_system_book_id2
			AND sdh.source_system_book_id3=ssbm.source_system_book_id3
			AND sdh.source_system_book_id4=ssbm.source_system_book_id4             
	  WHERE 
			isnull(cg.term_END,'9999-01-01')>=dbo.FNAGetContractMonth(@prod_date)
			AND ISNULL(sc.int_ext_flag,'e') = ISNULL(@cpt_type,'e')
	) a
	group by 
		source_counterparty_id,counterparty_name,contract_id
	
	

-----------------------------------------------------------------------------------
	IF @flag='r' OR @flag='c' -- SETtlement invoice which receive invoice
		BEGIN
		SET @sql=
		'
		SELECT 
			sc.counterparty_id,
			counterparty_name '+CASE WHEN @cpt_type = 'm' THEN '[Model Group]' ELSE 'Counterparty' END +',
			cg.contract_name '+CASE WHEN @cpt_type = 'm' THEN '[Model Detail]' ELSE 'Contract' END +',
			'+CASE WHEN @cpt_type = 'm' THEN ' MAX(CASE WHEN civ.counterparty_id is null THEN ''No'' ELSE ''Yes'' END) as [Calculated]'
			 ELSE 
			 ' MAX(CASE WHEN civ.counterparty_id is null THEN ''No'' ELSE dbo.FNAHyperLinkTextComp9(10221000,''Yes'',sc.counterparty_id,dbo.FNAGetSQLStandardDate(civ.prod_date),dbo.FNAGetSQLStandardDate(civ.as_of_date),'''+@estimate_calculation+''',CONVERT(VARCHAR(10),civ.settlement_date,120),cg.contract_id,cg.contract_name, civ.invoice_number) END) as [Shadow Calc]' END +',		
			'+CASE WHEN @cpt_type = 'm' THEN '' ELSE ' CASE WHEN MAX(ih1.invoice_id) is null THEN ''No'' ELSE MAX(dbo.FNAHyperLinkText3(10221312,''Yes'',ih1.invoice_id,dbo.fnagetcontractmonth(ih1.production_month))) END as [Invoice Entered],' END +'
			MAX(dbo.FNADateformat(civ.settlement_date)) [SettlementDate],
			MAX(dbo.FNADateformat(civ.prod_date)) [ProdDate],
			cg.contract_id [ContractID],MAX(ih1.invoice_id) invoice_id
		FROM
		#temp_counterparty sc
			inner join contract_group cg on cg.contract_id=sc.Contract_id
			INNER JOIN counterparty_contract_address cca ON cca.counterparty_id = sc.counterparty_id AND cca.contract_id = sc.contract_id					
			left join '+@table_calc_invoice_volume_variance+' civ on civ.counterparty_id=sc.counterparty_id 
			AND cg.contract_id = civ.contract_id
			AND '+CASE WHEN @date_type='s' THEN 'civ.settlement_date' ELSE 'civ.prod_date' END +' BETWEEN '''+cast(@prod_date as varchar)+''' AND '''+cast(@prod_date_to as varchar)+'''
			and (civ.as_of_date)=('''+cast(@as_of_date as varchar)+''')
			'+CASE WHEN @contract_id IS NOT NULL THEN ' AND civ.contract_id = '+CAST(@contract_id AS VARCHAR) ELSE '' END+
			' left join invoice_header ih1 on ih1.counterparty_id=sc.counterparty_id
			AND ih1.contract_id = sc.contract_id
			and dbo.FNAGetContractMonth(ih1.production_month)=dbo.FNAGetContractMonth(civ.prod_date)
			and (ih1.as_of_date)=('''+cast(@as_of_date as varchar)+''')
			AND civ.invoice_type = ''r''
			LEFT JOIN recorder_generator_map rgm on rgm.generator_id=ISNULL(sc.generator_id,-1)

		WHERE 1=1 
		'+

		CASE WHEN @sub_id is not null THEN 
			' AND sc.legal_entity_value_id='+cast(@sub_id as varchar) ELSE '' END+

		CASE WHEN @noinvoice ='y' THEN 
			'  AND ih1.invoice_id is null ' ELSE '' END+

		CASE WHEN @nocalculate ='y' THEN 
			' AND civ.counterparty_id is null' ELSE '' END+

		CASE WHEN @nomv90data ='y' THEN 
			' AND sc.generator_id not in (select generator_id from recorder_generator_map) ' ELSE '' END+


		CASE WHEN @onemeter ='y' THEN 
			' AND sc.generator_id  in (select distinct generator_id from recorder_generator_map WHERE recorderid in(
			(select recorderid from recorder_generator_map group by recorderid having count(distinct generator_id)>1))) ' ELSE '' END+

		CASE WHEN @recorderid IS NOT NULL THEN 
			' AND rgm.recorderid = '''+@recorderid+''' ' ELSE '' END+

		CASE WHEN @counterparty_id is not null THEN 
			' AND sc.counterparty_id= '+ cast(@counterparty_id as varchar) ELSE '' END +

		+CASE WHEN @contract_id IS NOT NULL THEN ' AND cg.contract_id='+CAST(@contract_id AS VARCHAR) ELSE '' END+

		' GROUP BY sc.counterparty_id,counterparty_name,cg.contract_name,cg.contract_id ORDER BY sc.counterparty_name ' 
		EXEC spa_print @sql
		EXEC(@sql)

	END

	ELSE IF @flag='n' -- which does not receive invoice
		BEGIN
		SET @sql=
		'select distinct
			sc.counterparty_id,counterparty_name [Counterparty],
			CASE WHEN civ.counterparty_id is null THEN ''No'' ELSE dbo.FNAHyperLinkText8(10221000,''Yes'',sc.counterparty_id,dbo.fnagetcontractmonth('+CASE WHEN @date_type='s' THEN 'civ.settlement_date' ELSE 'civ.prod_date' END +'),(civ.as_of_date),'''+@estimate_calculation+''') END as  [Shadow Calc]		
		from
			#temp_counterparty sc
			LEFT join contract_group cg on cg.contract_id=sc.Contract_id
			left join '+@table_calc_invoice_volume_variance+' civ on civ.counterparty_id=sc.counterparty_id
			AND dbo.FNAGetcontractMonth('+CASE WHEN @date_type='s' THEN 'civ.settlement_date' ELSE 'civ.prod_date' END +')=dbo.FNAGetContractMonth('''+cast(@prod_date as varchar)+''') and
			(civ.as_of_date)=('''+cast(@as_of_date as varchar)+''')
			left join recorder_generator_map rgm on rgm.generator_id=sc.generator_id

		WHERE 1=1 and cg.receive_invoice <>''y'' '+

		CASE WHEN @sub_id is not null THEN 
			' AND sc.legal_entity_value_id='+cast(@sub_id as varchar) ELSE '' END+
		CASE WHEN @nocalculate ='y' THEN 
			' AND civ.counterparty_id is null ' ELSE '' END+

		CASE WHEN @nomv90data ='y' THEN 
			' AND sc.generator_id not in (select generator_id from recorder_generator_map) ' ELSE '' END+


		CASE WHEN @onemeter ='y' THEN 
			' AND sc.generator_id  in (select distinct generator_id from recorder_generator_map WHERE recorderid in(
			(select recorderid from recorder_generator_map group by recorderid having count(distinct generator_id)>1))) ' ELSE '' END+

		CASE WHEN @recorderid IS NOT NULL THEN 
			' AND rgm.recorderid = '''+@recorderid+''' ' ELSE '' END +

		CASE WHEN @counterparty_id is not null THEN 
			' AND sc.counterparty_id='+cast(@counterparty_id as varchar) ELSE '' END +

		' ORDER BY sc.counterparty_name '

		EXEC spa_print @sql
		EXEC(@sql)
	END

	ELSE IF @flag='e' -- generate exception report
	BEGIN
		SET @prod_date_new=dateadd(month,-1,@prod_date)

		WHILE dbo.FNAGETCONTRACTMONTH(@prod_date_new)<dbo.FNAGETCONTRACTMONTH(dateadd(month,-1,@prod_date_to))
		BEGIN
			SET @prod_date_new=dateadd(month,1,@prod_date_new)
			insert into #temp_date(prod_date)
			 select dbo.FNAGETCONTRACTMONTH(@prod_date_new)
			
		END
		
		SET @sql='
		select 
			DISTINCT
			sc.source_counterparty_id [Counterparty ID],
			ph.entity_name Subsidiary,
			dbo.FNADateformat(tmp.prod_date) [Production Month],
			sc.counterparty_name Counterparty,
			CASE WHEN cg.receive_invoice=''y'' THEN ''Yes'' ELSE ''No'' END [Receive Invoice],
			CASE WHEN ISNULL(ih.invoice_id,ih1.invoice_id) is null THEN 
				CASE WHEN cg.receive_invoice=''y'' THEN ''<font color=red>No</font>'' ELSE ''No'' END
				 ELSE dbo.FNAHyperLinkText3(10221300,''Yes'',ISNULL(ih.invoice_id,ih1.invoice_id),dbo.fnagetcontractmonth(ISNULL(ih.production_month,ih1.production_month))) END as [Invoice Received],
			  CASE WHEN civ.counterparty_id is null THEN ''<font color=red>No</font>'' ELSE dbo.FNAHyperLinkText3test(174,''Yes'',sc.source_counterparty_id,dbo.fnagetcontractmonth(civ.prod_date)) END as Processed
		from
			source_counterparty sc 
			inner join rec_generator rg on sc.source_counterparty_id=rg.ppa_Counterparty_id
			inner join contract_group cg on cg.contract_id=rg.ppa_Contract_id
			LEFT join portfolio_hierarchy ph on ph.entity_id='+CASE WHEN @sub_id IS NOT NULL THEN cast(@sub_id as varchar) ELSE 'cg.sub_id' END +'
			cross join #temp_date tmp
			left join (select max(finalized) finalized,max(invoice_id) invoice_id,prod_date,counterparty_id,as_of_date,settlement_date from 
			'+@table_calc_invoice_volume_variance+' group by prod_date,counterparty_id,as_of_date,settlement_date) civ on civ.counterparty_id=sc.source_counterparty_id
			AND dbo.FNAGetcontractMonth('+CASE WHEN @date_type='s' THEN 'civ.settlement_date' ELSE 'civ.prod_date' END +')=dbo.FNAGetContractMonth(tmp.prod_date)
			left join invoice_header ih on ih.invoice_id=civ.invoice_Id
			left join invoice_header ih1 on ih1.counterparty_id=sc.source_counterparty_id
			and dbo.FNAGetContractMonth(ih1.production_month)=dbo.FNAGetContractMonth(tmp.prod_date)
			and (ih1.as_of_date)=('''+cast(@as_of_date as varchar)+''')
			left join recorder_generator_map rgm on rgm.generator_id=rg.generator_id
		 WHERE 1=1  and ISNULL(civ.finalized,'''')<>''y'''+
 			' and isnull(cg.term_END,''9999-01-01'')>=tmp.prod_date'+
 			' AND ISNULL(sc.int_ext_flag,''e'') = ISNULL('''+@cpt_type+''',''e'')'+
		CASE WHEN @nomv90data ='y' THEN 
			' AND rg.generator_id not in (select generator_id from recorder_generator_map) ' ELSE '' END+

		CASE WHEN @onemeter ='y' THEN 
			' AND rg.generator_id  in (select distinct generator_id from recorder_generator_map WHERE recorderid in(
			(select recorderid from recorder_generator_map group by recorderid having count(distinct generator_id)>1))) ' ELSE '' END+

		CASE WHEN @recorderid IS NOT NULL THEN 
			' AND rgm.recorderid = '''+@recorderid+''' ' ELSE '' END +

		CASE WHEN @sub_id is not null THEN 
			' AND rg.legal_entity_value_id='+cast(@sub_id as varchar) ELSE '' END +

		CASE WHEN @counterparty_id is not null THEN 
			' AND sc.source_counterparty_id='+cast(@counterparty_id as varchar) ELSE '' END +

		' ORDER BY dbo.FNADateformat(tmp.prod_date),sc.counterparty_name '

		EXEC spa_print @sql
		EXEC(@sql)
	END

	ELSE IF @flag='f' 
	BEGIN

		SET @prod_date_new=dateadd(month,-1,@prod_date)

		WHILE dbo.FNAGETCONTRACTMONTH(@prod_date_new)<dbo.FNAGETCONTRACTMONTH(dateadd(month,-1,@prod_date_to))
		BEGIN
			SET @prod_date_new=dateadd(month,1,@prod_date_new)
			insert into #temp_date(prod_date)
			 select dbo.FNAGETCONTRACTMONTH(@prod_date_new)
			
		END

		SET @sql='
		select 
			DISTINCT
			sc.source_counterparty_id [Counterparty ID],
			ph.entity_name Subsidiary,
			dbo.FNADateformat(tmp.prod_date) [Production Month],
			sc.counterparty_name Counterparty,
			CASE WHEN cg.receive_invoice=''y'' THEN ''Yes'' ELSE ''No'' END [Receive Invoice],
			CASE WHEN ISNULL(ih.invoice_id,ih1.invoice_id) is null THEN 
				CASE WHEN cg.receive_invoice=''y'' THEN ''<font color=red>No</font>'' ELSE ''No'' END
				 ELSE dbo.FNAHyperLinkText3(10221300,''Yes'',ISNULL(ih.invoice_id,ih1.invoice_id),dbo.fnagetcontractmonth(ISNULL(ih.production_month,ih1.production_month))) END as [Invoice Received],
			CASE WHEN civ.counterparty_id is null THEN ''<font color=red>No</font>'' ELSE dbo.FNAHyperLinkText8(10221000,''Yes'',sc.counterparty_id,dbo.fnagetcontractmonth(civ.prod_date),(civ.as_of_date),'''+@estimate_calculation+''') END as Processed		
		from
			source_counterparty sc 
			inner join rec_generator rg on sc.source_counterparty_id=rg.ppa_Counterparty_id
			inner join contract_group cg on cg.contract_id=rg.ppa_Contract_id
			inner join portfolio_hierarchy ph on ph.entity_id=cg.sub_id
			cross join #temp_date tmp
			left join (select max(finalized) finalized,max(invoice_id) invoice_id,prod_date,counterparty_id,invoice_type from 
			'+@table_calc_invoice_volume_variance+' group by prod_date,counterparty_id,invoice_type) civ on civ.counterparty_id=sc.source_counterparty_id  and
			dbo.FNAGetcontractMonth('+CASE WHEN @date_type='s' THEN 'civ.settlement_date' ELSE 'civ.prod_date' END +')=dbo.FNAGetContractMonth(tmp.prod_date)
			left join invoice_header ih on ih.invoice_id=civ.invoice_Id
			left join invoice_header ih1 on ih1.counterparty_id=sc.source_counterparty_id
			and dbo.FNAGetContractMonth(ih1.production_month)=dbo.FNAGetContractMonth(tmp.prod_date)
			and (ih1.as_of_date)=('''+cast(@as_of_date as varchar)+''')
			AND civ.invoice_type = ''r''
			left join recorder_generator_map rgm on rgm.generator_id=rg.generator_id
		 WHERE 1=1  and ISNULL(civ.finalized,'''')=''y'''+
 			' and isnull(cg.term_END,''9999-01-01'')>=tmp.prod_date'+

		CASE WHEN @counterparty_id is not null THEN 
			' AND sc.source_counterparty_id='+cast(@counterparty_id as varchar) ELSE '' END +

		' ORDER BY dbo.FNADateformat(tmp.prod_date),sc.counterparty_name '


		EXEC(@sql)
	END
