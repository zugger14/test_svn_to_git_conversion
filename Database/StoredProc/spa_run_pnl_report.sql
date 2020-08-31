
/****** Object:  StoredProcedure [dbo].[spa_run_wacog_report]    Script Date: 11/11/2010 13:03:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_pnl_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_pnl_report]
Go
/******************************
Profit and Loss report for Scheduling
Author: Annal Shrestha
Date Created:2010-11-11
Desc: calcluate Profit and loss of the transactions. Derive from formula defined in Contrcat Charge Type for the transactions

spa_run_pnl_report - Parameters
	@summary_option			->'s' Summary, 'd' detail
	@sub_entity_id			-> Subsidiary
	@strategy_entity_id		-> Strategy 
	@book_entity_id			-> Book 
	@commodity_id			-> Commodity 
	@delivery_path			-> Delivery Path  
	@term_start				-> Term Start of Transactions
	@term_end				-> Term End   of Transactions
	@counterparty			-> Counterparty 
	@pipeline_counterparty	-> Counterparty who owns pipeline 
	@location				-> Location 
	@location_type			-> Location Type 
	@location_group			-> Location Group 
	@source_system_book1	-> Source system Book1 
	@source_system_book2	-> Source system Book2 
	@source_system_book3	-> Source system Book3 
	@source_system_book4	-> Source system Book4 

***********************************/

CREATE PROC [dbo].[spa_run_pnl_report]
	@summary_option			CHAR(1)='s',
	@sub_entity_id			VARCHAR(100)=NULL,
	@strategy_entity_id		VARCHAR(100)=NULL,
	@book_entity_id			VARCHAR(100)=NULL,
	@commodity_id			INT=NULL,
	@delivery_path			INT=NULL,
	@term_start				DATETIME=NULL,
	@term_end				DATETIME=NULL,
	@counterparty			VARCHAR(500)=NULL,
	@pipeline_counterparty	VARCHAR(500)=NULL,
	@location				VARCHAR(500)=NULL,
	@location_type			INT=NULL,
	@location_group			VARCHAR(500)=NULL,
	@source_system_book1	INT=NULL,
	@source_system_book2	INT=NULL,
	@source_system_book3	INT=NULL,
	@source_system_book4	INT=NULL,
	@drill_counterparty		VARCHAR(100)=NULL,
	@drill_term				VARCHAR(100)=NULL


AS
SET NOCOUNT ON
BEGIN

	DECLARE @sql_stmt VARCHAR(MAX)


	IF @drill_term IS NOT NULL
		BEGIN
			SET @term_start=@drill_term+'-01'
			SET @term_end=DATEADD(month,1,@drill_term+'-01')-1
			SET @drill_term=NULL
		END
	
	CREATE TABLE #books (fas_subsidiary_id int, fas_strategy_id int, fas_book_id int, hedge_type_value_id int, legal_entity_id int) 

	SET @sql_stmt=        
		'INSERT INTO  #books       
		SELECT distinct stra.parent_entity_id, stra.entity_id, book.entity_id, fs.hedge_type_value_id, legal_entity
		FROM portfolio_hierarchy book (nolock) INNER JOIN
				Portfolio_hierarchy stra (nolock) ON book.parent_entity_id = stra.entity_id LEFT OUTER JOIN            
				source_system_book_map ssbm ON ssbm.fas_book_id = book.entity_id LEFT OUTER JOIN
				fas_strategy fs ON fs.fas_strategy_id = book.parent_entity_id LEFT OUTER JOIN
				fas_books fb ON fb.fas_book_id = ssbm.fas_book_id
		WHERE (ssbm.fas_deal_type_value_id = 400 OR 
						(fs.hedge_type_value_id = 151 AND ssbm.fas_deal_type_value_id = 401) OR 
						ssbm.fas_deal_type_value_id = 407)
	'   
	              
	IF @sub_entity_id IS NOT NULL        
	  SET @sql_stmt = @sql_stmt + ' AND stra.parent_entity_id IN  ( ' + @sub_entity_id + ') '         
	 IF @strategy_entity_id IS NOT NULL        
	  SET @sql_stmt = @sql_stmt + ' AND (stra.entity_id IN(' + @strategy_entity_id + ' ))'        
	 IF @book_entity_id IS NOT NULL        
	  SET @sql_stmt = @sql_stmt + ' AND (book.entity_id IN(' + @book_entity_id + ')) '        
	 IF @source_system_book1 IS NOT NULL        
	  SET @sql_stmt = @sql_stmt + ' AND (ssbm.source_system_book_id1 IN(' + @source_system_book1 + ')) '        
	 IF @source_system_book2 IS NOT NULL        
	  SET @sql_stmt = @sql_stmt + ' AND (ssbm.source_system_book_id2 IN(' + @source_system_book2 + ')) '        
	 IF @source_system_book3 IS NOT NULL        
	  SET @sql_stmt = @sql_stmt + ' AND (ssbm.source_system_book_id3 IN(' + @source_system_book3 + ')) '        
	 IF @source_system_book4 IS NOT NULL        
	  SET @sql_stmt = @sql_stmt + ' AND (ssbm.source_system_book_id4 IN(' + @source_system_book4 + ')) '        
	        
	 	            
	EXEC (@sql_stmt)


-------------########## Create Temp Tables

----- Create table to collect deals
	CREATE TABLE #temp_deals (
		[ID] INT IDENTITY(1,1),
		[subsidiary_id] int NOT NULL,
		[strategy_id] int NOT NULL,
		[book_id] int NOT NULL,
		[source_deal_header_id] [int] NOT NULL,
		[term_start] [DATETIME] NOT NULL,
		[physical_financial_flag] [char](1) COLLATE DATABASE_DEFAULT  NULL,
		[source_counterparty_id] [int] NULL,
		[Value] FLOAT,
		[deal_volume] FLOAT,	
		[fixed_price] FLOAT,
		[price_adder] FLOAT,
		[price_multiplier] FLOAT,
		[formula] VARCHAR(5000) COLLATE DATABASE_DEFAULT,
		[buy_sell_flag] CHAR(1) COLLATE DATABASE_DEFAULT,
		[deal_type] INT,
		[contract_charge_type_id] INT,
		[counterparty_id] INT,
		[counterparty] VARCHAR(100) COLLATE DATABASE_DEFAULT,
		[source_deal_detail_id] INT
	) ON [PRIMARY]


----- Create table to insert final values
	CREATE TABLE #final_value(
		[counterparty_id] INT,
		[contract_id] INT,
		[term_date] DATETIME,
		[charge_type_id] INT,
		[Volume] FLOAT,
		[Value] FLOAT,
		deal_id INT
	)

-- Create Table to Insert formula to evaluate	

	CREATE TABLE #temp_formula(
		contract_charge_type_id INT,
		counterparty_id INT,
		charge_type_id INT,
		formula_id INT,
		formula VARCHAR(500) COLLATE DATABASE_DEFAULT,
		formula_sequence INT,
		[ID] INT,
		granularity INT,
		charge_type_sequence INT
	)

-----###########################
	SET @sql_stmt='       
		INSERT INTO #temp_deals 

	(			[subsidiary_id] ,
				[strategy_id] ,
				[book_id]  ,
				[source_deal_header_id],
				[term_start],
				[physical_financial_flag],
				[Value],
				[deal_volume],	
				[fixed_price],
				[price_adder],
				[price_multiplier],
				[formula],
				[buy_sell_flag],
				[deal_type],
				[contract_charge_type_id],
				[counterparty_id],
				[counterparty],
				[source_deal_detail_id]
		)
		SELECT		
				(book.fas_subsidiary_id) subsidiary_id,
				(book.fas_strategy_id) strategy_id,
				(book.fas_book_id) book_id,
				sdh.source_deal_header_id,
				sdd.term_start,
				(sdh.physical_financial_flag) physical_financial_flag,
				((sdd.fixed_price+sdd.price_adder)*sdd.price_multiplier*sdd.deal_volume) AS [Value],
				(sdd.deal_volume),
				ISNULL((sdd.fixed_price),0),
				ISNULL((sdd.price_adder),0),
				ISNULL((sdd.price_multiplier),1)*case (sdd.buy_sell_flag) WHEN ''b'' THEN -1 ELSE 1 END,
				(dbo.FNAFormulaText(sdd.term_start,sdd.term_start,0, 0,fe.formula,0,0,0,4500,NULL)),
				sdd.buy_sell_flag,
				sdh.source_deal_type_id,
				a.contract_charge_type_id,
				sdh.counterparty_id,
				sc.counterparty_name,
				sdd.source_deal_detail_id				
		FROM 		
				#books book INNER JOIN 
				source_system_book_map sbm ON book.fas_book_id = sbm.fas_book_id INNER JOIN
				source_deal_header sdh ON	  sdh.source_system_book_id1 = sbm.source_system_book_id1 AND 
											  sdh.source_system_book_id2 = sbm.source_system_book_id2 AND 
											  sdh.source_system_book_id3 = sbm.source_system_book_id3 AND 
											  sdh.source_system_book_id4 = sbm.source_system_book_id4 
				INNER JOIN source_deal_detail sdd on sdd.source_deal_header_id=sdh.source_deal_header_id
				LEFT JOIN formula_editor fe on sdd.formula_id=fe.formula_id
				LEFT JOIN source_deal_detail_template sddt ON sddt.template_id=sdh.template_id AND sdd.leg=sddt.leg	
				LEFT JOIN source_counterparty sc ON sc.source_counterparty_id=sdh.counterparty_id
				LEFT JOIN source_minor_location sml ON sml.source_minor_location_id=sdd.location_id
				LEFT JOIN(select MAX(contract_charge_type_id) contract_charge_type_id,deal_type FROM  contract_charge_type GROUP BY deal_type) a
				ON a.deal_type=sdh.source_deal_type_id

		WHERE	1=1'
		+ CASE WHEN @commodity_id IS NOT NULL THEN ' AND sddt.commodity_id='+CAST(@commodity_id AS VARCHAR) ELSE '' END
		+ CASE WHEN @term_start IS NOT NULL THEN ' AND sdd.term_start>='''+CAST(@term_start AS VARCHAR)+'''' ELSE '' END
		+ CASE WHEN @term_end IS NOT NULL THEN ' AND sdd.term_end<='''+CAST(@term_end AS VARCHAR)+'''' ELSE '' END
		+ CASE WHEN @counterparty IS NOT NULL THEN ' AND sdh.counterparty_id IN('+@counterparty+')' ELSE '' END
		+ CASE WHEN @pipeline_counterparty IS NOT NULL THEN ' AND sdh.counterparty IN('+@counterparty+')' ELSE '' END
		+ CASE WHEN @location IS NOT NULL THEN ' AND sdd.location_id IN('+@location+')' ELSE '' END
		+ CASE WHEN @location_group IS NOT NULL THEN ' AND sml.source_major_location_id IN('+@location_group+')' ELSE '' END
		+ CASE WHEN @drill_counterparty IS NOT NULL THEN ' AND sc.counterparty_name	='''+@drill_counterparty+'''' ELSE '' END


		EXEC(@sql_stmt)


	-- Get the value from Settlement First
	INSERT INTO #final_value(
		[counterparty_id],
		[contract_id],
		[term_date],
		[charge_type_id],
		[Volume],
		[Value],
		deal_id
	)
	SELECT
		td.counterparty_id,
		NULL,
		civd.prod_date,
		civd.invoice_line_item_id,
		SUM(civd.volume),
		SUM(civd.[value]),
		civd.deal_id
	FROM
		calc_invoice_volume_detail civd
		INNER JOIN #temp_deals td ON td.source_deal_detail_id=civd.deal_id
	GROUP BY 
		td.counterparty_id,civd.prod_date,civd.invoice_line_item_id,civd.deal_id


--- Collect Formula
	INSERT INTO #temp_formula(
		contract_charge_type_id,
		counterparty_id,
		charge_type_id,
		formula_id,
		formula,
		formula_sequence,
		[ID],
		granularity,
		charge_type_sequence
		
	)

	SELECT DISTINCT
		cctd.contract_charge_type_id,
		td.counterparty_id counterparty_id,
		cctd.invoice_Line_item_id AS charge_type_id,
		cctd.formula_id formula_id,
		REPLACE(ISNULL(fe1.formula,fe.formula),' ','') formula,
		ISNULL(fn.sequence_order,0) formula_sequence,
		cctd.[ID] [ID],
		COALESCE(fn.granularity,cctd.volume_granularity,NULL) granularity,
		cctd.sequence_order
		
	FROM
		#temp_deals td
		INNER JOIN contract_charge_type cct ON  cct.contract_charge_type_id=td.contract_charge_type_id
		LEFT JOIN contract_charge_type_detail cctd ON  cctd.contract_charge_type_id=cct.contract_charge_type_id
		AND cctd.prod_type='p' 
		LEFT JOIN formula_editor fe ON  cctd.formula_id=fe.formula_id
		LEFT JOIN formula_nested fn ON  fe.formula_id=fn.formula_group_id
		LEFT JOIN formula_editor fe1 ON  fe1.formula_id=fn.formula_id
		LEFT JOIN #final_value fv ON td.source_deal_detail_id=fv.deal_id
	WHERE
		fv.deal_id IS NULL


		
----###### Evaluate formula
	DECLARE @counterparty_id INT
	DECLARE @charge_type_id INT
	DECLARE @formula_id INT
	DECLARE @formula VARCHAR(MAX)
	DECLARE @charge_type_sequence INT
	DECLARE @formula_sequence INT
	DECLARE @granularity INT
	DECLARE @contract_charge_type_id INT
	DECLARE @term_date DATETIME
	DECLARE @volume FLOAT
	DECLARE @deal_id INT



	CREATE TABLE #formula_value(
		invoice_line_item_id INT,
		counterparty_id INT,
		contract_id INT,
		prod_date VARCHAR(20) COLLATE DATABASE_DEFAULT, 
		formula_value FLOAT,
		Volume FLOAT,
		sequence_number INT, 	
		formula_str VARCHAR(2000) COLLATE DATABASE_DEFAULT,
		formula_id INT,
		deal_id INT
	)





	DECLARE CURSOR1 CURSOR FOR
			SELECT 
				contract_charge_type_id,counterparty_id,charge_type_id,formula_id,formula,formula_sequence,ISNULL(granularity,980)
			FROM #temp_formula
			WHERE 1=1 ORDER BY	charge_type_sequence,formula_sequence
	 OPEN CURSOR1
	 FETCH  next FROM CURSOR1 INTO @contract_charge_type_id,@counterparty_id,@charge_type_id,@formula_id,@formula,@formula_sequence,@granularity

	 WHILE @@FETCH_STATUS=0
	 BEGIN
				
				DECLARE CURSOR2 CURSOR for 
				SELECT term_start,deal_volume,source_deal_detail_id
					FROM #temp_deals where counterparty_id=@counterparty_id AND contract_charge_type_id=@contract_charge_type_id
				--GROUP BY source_deal_detail_id 
				OPEN CURSOR2
				FETCH  next FROM CURSOR2 into @term_date,@volume,@deal_id
				
				WHILE @@FETCH_STATUS=0
				BEGIN
					

					SET @sql_stmt = 'INSERT INTO #formula_value(counterparty_id,Volume,invoice_line_item_id,contract_id,prod_date,formula_value,sequence_Number,formula_str,formula_id,deal_id)
					SELECT 
					''' +cast(@counterparty_id AS varchar)+ ''',''' +cast(@Volume AS varchar)+ ''',''' +cast(@charge_type_id AS varchar)+ ''',NULL, ''' +cast(@term_date AS varchar)+''','+
 					CASE WHEN @formula_id is null THEN CAST(0 AS varchar) ELSE  
					dbo.FNAFormulaTextContract(cast(@term_date AS varchar),@volume, @volume,0,0,@formula,0,1,1,-1,cast(@counterparty_id AS varchar),
					-1,cast(@charge_type_id AS varchar),cast(@formula_sequence AS varchar),
					0,0,0,0,0,0,0,0,cast(@granularity AS varchar),-1,cast(@term_date as varchar),0) END+ ','''+cast(@formula_sequence AS varchar)+''','''+
			
					REPLACE(ISNULL(dbo.FNAFormulaTextContract(cast(@term_date AS varchar),@volume, @volume,0,0,@formula,0,1,1,NULL,cast(@counterparty_id AS varchar),
					NULL,cast(@charge_type_id AS varchar),cast(@formula_sequence AS varchar),
					0,0,0,0,0,0,0,0,cast(@granularity AS varchar),NULL,cast(@term_date as varchar),0),'NULL'),'''','''''')+''','''+cast(ISNULL(@formula_id,'') AS varchar)+''','''+cast(ISNULL(@deal_id,'') AS varchar)+''''
					

					--select @sql_stmt
					EXEC(@sql_stmt)	

--
--								INSERT INTO calc_formula_value(
--										invoice_line_item_id,seq_number,prod_date,counterparty_id,contract_id,value,formula_id,calc_id,[hour],formula_str,deal_id
--										)
--									SELECT 
--											invoice_line_item_id,sequence_number,prod_date,@counterparty_id,contract_id,ISNULL(formula_value,0),@formula_id,@calc_id,0,formula_str,@source_deal_detail_id
--									FROM 
--										#formula_value 
--									where 
--										invoice_line_item_id=@invoice_line_item_id and contract_id=@contract_id 
--										and sequence_number=@sequence_number AND @formula_id IS NOT NULL
--										and ISNULL(deal_id,-1)=ISNULL(@source_deal_detail_id,-1)

					FETCH  next FROM CURSOR2 into @term_date,@volume,@deal_id
				END
				CLOSE CURSOR2
				DEALLOCATE CURSOR2	

		FETCH  next FROM CURSOR1
		INTO
		@contract_charge_type_id,@counterparty_id,@charge_type_id,@formula_id,@formula,@formula_sequence,@granularity
		
	 END	
	CLOSE CURSOR1
	DEALLOCATE CURSOR1		
	

----**********************************
--Ths last line of the formula will be an answer

	SELECT * into  #formula_value1 FROM #formula_value WHERE sequence_number<=0

	INSERT INTO #formula_value1(
			counterparty_id,
			Volume,
			invoice_line_item_id,
			contract_id,
			prod_date,
			formula_value,
			sequence_Number,
			formula_str,
			deal_id
		)
	SELECT 
			a.counterparty_id,
			a.Volume,
			a.invoice_line_item_id,
			a.contract_id,
			a.prod_date,
			a.formula_value,
			a.sequence_Number,
			a.formula_str,
			deal_id
	FROM 
		#formula_value a inner join
		(SELECT max(sequence_Number) sequence_Number,invoice_line_item_id FROM #formula_value GROUP BY invoice_line_item_id) b ON  
		a.sequence_Number=b.sequence_Number and a.invoice_line_item_id=b.invoice_line_item_id
		WHERE a.sequence_Number <>0 


------######## Insert into Final Values
		-- Get the value from Settlement First
	INSERT INTO #final_value(
		[counterparty_id],
		[contract_id],
		[term_date],
		[charge_type_id],
		[Volume],
		[Value],
		deal_id
	)
	SELECT
		fv.counterparty_id,
		NULL,
		fv.prod_date,
		fv.invoice_line_item_id,
		SUM(fv.volume),
		SUM(fv.formula_value),
		fv.deal_id
	FROM
		#formula_value1 fv
	GROUP BY fv.counterparty_id,fv.prod_date,fv.invoice_line_item_id,fv.deal_id



	IF @summary_option='s'
		BEGIN
			SELECT 
				sc.counterparty_name [Counterparty],
				dbo.FNAContractmonthformat(fv.term_date) Term,
				SUM(fv.[value]) Total
			FROM
				#final_value fv
				LEFT JOIN source_counterparty sc ON sc.source_counterparty_id=fv.counterparty_id
			GROUP BY sc.counterparty_name,dbo.FNAContractmonthformat(fv.term_date)	
			ORDER BY sc.counterparty_name,dbo.FNAContractmonthformat(fv.term_date)
	
		END

	ELSE IF @summary_option='d'
		BEGIN
			SELECT 
				sc.counterparty_name [Counterparty],
				dbo.FNADateformat(fv.term_date) Term,
				dbo.FNAHyperLinkText(10131010,CAST(sdh.source_deal_header_id AS VARCHAR) + '('+sdh.deal_id+')',sdh.source_deal_header_id) AS [Deal ID],
				sd.code [Charge Type],				
				SUM(fv.[value]) Total
				
			FROM
				#final_value fv
				LEFT JOIN source_counterparty sc ON sc.source_counterparty_id=fv.counterparty_id
				LEFT JOIN static_data_value sd ON sd.value_id=fv.charge_type_id
				LEFT JOIN source_deal_detail sdd ON sdd.source_deal_detail_id=fv.deal_id
				LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id=sdd.source_deal_header_id
			GROUP BY sc.counterparty_name,dbo.FNADateformat(fv.term_date),sd.code,dbo.FNAHyperLinkText(10131010,CAST(sdh.source_deal_header_id AS VARCHAR) + '('+sdh.deal_id+')',sdh.source_deal_header_id)
		
	END
END



