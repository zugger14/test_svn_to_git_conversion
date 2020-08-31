/****** Object:  StoredProcedure [dbo].[spa_calc_true_up]    Script Date: 05/22/2012 15:18:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_calc_true_up]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calc_true_up]
GO

/****** Object:  StoredProcedure [dbo].[spa_calc_true_up]    Script Date: 05/22/2012 15:18:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/***********************************************************
* Description: Populates True up decisions based on Counterparty Contract period configuration 
* Date:   2/17/2016 
* Author: spneupane@pioneersolutionsglobal.com
*
* Changes
* Date		Modified By			Comments
************************************************************
*2016-02-17	spneupane			Initial Version.
*								True up decisions for non formula based true up charge type mapped with different charge type
*								
*2016-02-25	spneupane			True up - Contract Charge type configuration populated from template / contract group detail
*								True up table will be used instead of contract group detail now on because if contract is mapped 
*								to template invoice line item id are not defined in contract group detail. 
*								
								
************************************************************/

CREATE PROCEDURE [dbo].[spa_calc_true_up]
	@prod_date DATETIME = NULL,
	@prod_date_to DATETIME = NULL,
	@as_of_date DATETIME = NULL,
	@contract_id_param VARCHAR(MAX) = NULL,
	@counterparty_id VARCHAR(MAX)= NULL,
	@calc_process_id VARCHAR(255) = NULL,
	@settlement_adjustment CHAR(1) = 'y',
	@estimate_calculation  CHAR(1) = 'n',
	@module_type VARCHAR(50) = 'stlmnt',
	@deal_set_calc CHAR(1) = 'n',
	@cpt_type CHAR(1) = 'e',
	@date_type CHAR(1)  = 't',
	@calc_id VARCHAR(MAX) = NULL,
	@batch_process_id	VARCHAR(120) = NULL, -- 's' - Settlement, 't' Term
	@batch_report_param	VARCHAR(5000) = NULL
	
AS 
BEGIN	

/*
------ Test
	DECLARE @prod_date DATETIME = NULL,
	@prod_date_to DATETIME = NULL,
	@as_of_date DATETIME = NULL,
	@contract_id_param VARCHAR(MAX) = NULL,
	@counterparty_id VARCHAR(MAX)= NULL,
	@calc_process_id VARCHAR(255) = NULL,
	@settlement_adjustment CHAR(1) = 'y',
	@estimate_calculation  CHAR(1) = 'n',
	@module_type VARCHAR(50) = 'stlmnt',
	@deal_set_calc CHAR(1) = 'n',
	@cpt_type CHAR(1) = 'e',
	@date_type CHAR(1)  = 't',
	@calc_id VARCHAR(MAX) = NULL,
	@batch_process_id	VARCHAR(120) = NULL, -- 's' - Settlement, 't' Term
	@batch_report_param	VARCHAR(5000) = NULL

SET @prod_date='2018-02-01'
SET @counterparty_id='7857'
SET @as_of_date='2018-02-28'
SET @settlement_adjustment='n'
SET @contract_id_param = '9238'
SET @estimate_calculation='n'
SET @module_type = 'stlmnt'
SET @deal_set_calc = 'n'
SET @cpt_type = 'e'
SET @date_type = 't'
SET @calc_id = NULL
SET @prod_date_to='2018-02-28'
----*/

	--SET @deal_set_calc ='y'
	DECLARE @total_time VARCHAR(100)
	DECLARE @user_id          VARCHAR(100)
	DECLARE @calc_start_time  DATETIME 

	SET @calc_start_time = GETDATE()

	IF @as_of_date IS NULL
		SET @as_of_date = CONVERT(VARCHAR(10),getdate(),120)

	IF OBJECT_ID('tempdb..#cpty1') IS NOT NULL 
	DROP TABLE #cpty1
	
	IF OBJECT_ID('tempdb..#true_up_inserted_values') IS NOT NULL 
	DROP TABLE #true_up_inserted_values
	
	

	CREATE TABLE #cpty1(counterparty_id INT)
	IF @calc_id IS NOT NULL
	BEGIN
		INSERT INTO #cpty1 
		SELECT DISTINCT civv.counterparty_id FROM dbo.SplitCommaSeperatedValues(@calc_id) a INNER JOIN calc_invoice_volume_variance civv ON a.[item] = civv.calc_id

		SELECT @counterparty_id = ISNULL(@counterparty_id,'') + ','+  CAST(civv.counterparty_id AS VARCHAR) FROM dbo.SplitCommaSeperatedValues(@calc_id) a INNER JOIN calc_invoice_volume_variance civv ON a.[item] = civv.calc_id
		SELECT @contract_id_param = ISNULL(@contract_id_param,'') + ','+  CAST(civv.contract_id AS VARCHAR) FROM dbo.SplitCommaSeperatedValues(@calc_id) a INNER JOIN calc_invoice_volume_variance civv ON a.[item] = civv.calc_id
		
		SELECT @counterparty_id= SUBSTRING(@counterparty_id,2,LEN(@counterparty_id))
		SELECT @contract_id_param= SUBSTRING(@contract_id_param,2,LEN(@contract_id_param))

	END
	ELSE
	BEGIN
		IF @counterparty_id IS NOT NULL
			INSERT INTO #cpty1 SELECT DISTINCT [item] FROM dbo.SplitCommaSeperatedValues(@counterparty_id)
		ELSE 
			INSERT INTO #cpty1 SELECT source_counterparty_id FROM source_counterparty
	END

		-- Invoice Line Item Id Based On Template and Defined in Contracts
	IF OBJECT_ID ('tempdb..#contract_group_detail') IS NOT NULL
		DROP TABLE #contract_group_detail

	CREATE TABLE #contract_group_detail
	(
		counterparty_id            INT,
		contract_id                INT,
		term_start                 DATETIME,
		term_end				   DATETIME,
		invoice_line_item_id       INT,
		true_up_charge_type_id     INT,
		true_up_no_month           INT,
		true_up_applies_to         CHAR(1) COLLATE DATABASE_DEFAULT,
		is_true_up                 CHAR(1) COLLATE DATABASE_DEFAULT
	)

	INSERT INTO #contract_group_detail
	SELECT cpt.counterparty_id, contract_item.contract_id, contract_item.term_start,contract_item.term_end, invoice_line_item_id, true_up_charge_type_id, true_up_no_month, true_up_applies_to, is_true_up FROM counterparty_contract_address cca
	INNER JOIN #cpty1 cpt ON cca.counterparty_id = cpt.counterparty_id
	CROSS APPLY(
	SELECT cg.contract_id,
		   cg.term_start,
		   cg.term_end,
		   cctd.invoice_line_item_id,
		   ISNULL(NULLIF(cctd.true_up_charge_type_id,0), cctd.invoice_line_item_id) true_up_charge_type_id,
		   cctd.true_up_no_month,
		   cctd.true_up_applies_to,
		   ISNULL(cctd.is_true_up,'1') is_true_up
	FROM   contract_group cg
		   LEFT JOIN contract_charge_type cct
				ON  cct.contract_charge_type_id = cg.contract_charge_type_id
		   LEFT JOIN contract_charge_type_detail cctd
				ON  cctd.contract_charge_type_id = cct.contract_charge_type_id
	WHERE  1 = 1
		   AND cctd.invoice_line_item_id IS NOT NULL
		   AND ((@contract_id_param IS NOT NULL AND cg.contract_id IN (SELECT item FROM   dbo.SplitCommaSeperatedValues(@contract_id_param))) OR @contract_id_param IS NULL)
	UNION ALL
	SELECT cgd.contract_id,
		   cg.term_start,
		    cg.term_end,
		   cgd.invoice_line_item_id,
		   ISNULL(NULLIF(cgd.true_up_charge_type_id,0),cgd.invoice_line_item_id),
		   cgd.true_up_no_month,
		   cgd.true_up_applies_to,
		   cgd.is_true_up
	FROM   contract_group_detail cgd
		   INNER JOIN contract_group cg
				ON  cgd.contract_id = cg.contract_id
	WHERE  1 = 1
		   AND ((@contract_id_param IS NOT NULL AND cg.contract_id IN (SELECT item FROM   dbo.SplitCommaSeperatedValues(@contract_id_param))) OR @contract_id_param IS NULL)
		   AND cg.contract_charge_type_id IS NULL -- Exclude Charge type based on Contract component template 	                     
	) contract_item
	WHERE cca.contract_id = contract_item.contract_id


	DECLARE @term_start DATETIME, @term_end DATETIME, @process_id VARCHAR(200),@invoice_line_item_id VARCHAR(MAX)
	SET @term_start = @prod_date
	SET @term_end = @prod_date_to
	IF @calc_id IS NOT NULL
		BEGIN

			SELECT @prod_date = prod_date,@prod_date_to=prod_date_to,@as_of_date=as_of_date FROM calc_invoice_volume_variance WHERE calc_id IN(SELECT item FROM   dbo.SplitCommaSeperatedValues(@calc_id))
		
		END


 
	--True up periods according to counterparty / contracts
	   IF OBJECT_ID('tempdb..#trueup_period') IS NOT NULL
		  DROP TABLE tempdb..#trueup_period
		  
	   CREATE TABLE #trueup_period
	   (
	   	counterparty_id          INT,
	   	contract_id              INT,
	   	invoice_line_item_id     INT,
	   	true_up_charge_type_id	 INT,
	   	is_true_up               CHAR(1) COLLATE DATABASE_DEFAULT,
	   	term_start               DATETIME,
	   	term_end                 DATETIME,
	   	ifbs_field_id			 INT
	   )
	   INSERT INTO #trueup_period
	   SELECT DISTINCT temp_period.counterparty_id,
		      temp_period.contract_id,
		      temp_period.invoice_line_item_id,
		      temp_period.true_up_charge_type_id,
		      temp_period.is_true_up,
		      civv1.prod_date,
		      CONVERT(VARCHAR(10),  CASE WHEN temp_period.term_end>contract_end THEN CONVERT(VARCHAR(7),temp_period.contract_end,120)+'-01' ELSE temp_period.term_end END, 126),
		      temp_period.charge_type_id
		  FROM (
	   SELECT cca.counterparty_id,
		      rs_ctd.contract_id,
		      rs_ctd.invoice_line_item_id,
		      rs_ctd.true_up_charge_type_id,
		      rs_ctd.is_true_up,
		      rs_ctd.true_up_applies_to,
		      rs_ctd.true_up_no_month,
			 CASE 
				--WHEN @term_start IS NOT NULL THEN CASE WHEN @term_start>=@prod_date THEN NULL ELSE @term_start END
				WHEN rs_ctd.true_up_applies_to = 'y' 
				    AND rs_ctd.is_true_up = 'y' 
				    AND DATEDIFF(MONTH, YEAR(CAST(YEAR(@prod_date_to) AS VARCHAR(4)) + '-01-01'), DATEADD(MONTH, -1, @prod_date_to)) <> 0 
					   THEN CAST(YEAR(@prod_date_to) AS VARCHAR(4)) + '-01-01'
				WHEN rs_ctd.true_up_applies_to = 'p' 
				    AND rs_ctd.is_true_up = 'y' 
				    AND DATEDIFF(MONTH, YEAR(@prod_date_to), DATEADD(MONTH, -1, @prod_date_to)) <> 0 
					   THEN CONVERT(VARCHAR(10),DATEADD(DAY,-DAY(DATEADD(MONTH, -rs_ctd.true_up_no_month, @prod_date_to)) + 1,DATEADD(MONTH, - rs_ctd.true_up_no_month, @prod_date_to)),126)
				WHEN rs_ctd.true_up_applies_to = 'p' 
				    AND rs_ctd.is_true_up = 'y' 
					   THEN @prod_date
				WHEN rs_ctd.true_up_applies_to = 'c'
				    AND rs_ctd.is_true_up = 'y'
				    THEN ISNULL(cca.contract_start_date,rs_ctd.term_start) 				 
				ELSE @prod_date END term_start,
			 CASE 
				WHEN @term_end IS NOT NULL THEN  CASE WHEN @term_end>=@prod_date_to THEN DATEADD(m,-1,@prod_date_to) ELSE @term_end END
				WHEN rs_ctd.true_up_applies_to IN('y','p','c') 
				AND rs_ctd.is_true_up = 'y' 
				AND DATEDIFF(MONTH,YEAR(@prod_date_to),DATEADD(MONTH, -1, @prod_date_to)) <> 0 
				    THEN
				    	 CASE WHEN ISNULL(rs_ctd.true_up_charge_type_id, 0) = 0 THEN CONVERT(VARCHAR(10),@prod_date_to,126)
				    		  WHEN ISNULL(rs_ctd.true_up_charge_type_id, 0) <> 0 THEN CONVERT(VARCHAR(10),DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, @prod_date_to), 0)),126)  
				    		  ELSE CONVERT(VARCHAR(10),@prod_date_to,126)
				    	 END
				ELSE @prod_date_to END term_end,
				rs_ctd.term_start contract_start,
				rs_ctd.term_end contract_end,
				rs_ctd.charge_type_id
	   FROM #cpty1 cpty
	   LEFT JOIN  counterparty_contract_address cca 
		  ON cpty.counterparty_id = cca.counterparty_id
	   OUTER APPLY (
	              SELECT *
	              FROM   #contract_group_detail cgd
	              LEFT JOIN contract_component_mapping AS ccm ON cgd.true_up_charge_type_id = ccm.contract_component_id
	              WHERE  cpty.counterparty_id = cgd.counterparty_id
	                     AND cca.contract_id = cgd.contract_id
	                     AND ISNULL(cgd.is_true_up, 'n') = 'y'                      
	          ) rs_ctd
	   ) temp_period
	   OUTER APPLY (SELECT MIN(prod_date) prod_date FROM calc_invoice_volume_variance WHERE counterparty_id=temp_period.counterparty_id 
			AND contract_id=temp_period.contract_id AND prod_date >= CONVERT(VARCHAR(10), CASE WHEN temp_period.term_start<contract_start THEN CONVERT(VARCHAR(7),temp_period.contract_start,120)+'-01' ELSE temp_period.term_start END, 126)
			)  civv1
	   WHERE DATEDIFF(MONTH, temp_period.Term_Start, temp_period.Term_End) >= 0 AND is_true_up = 'y'

	-- for prior period adjustments
	   INSERT INTO #trueup_period
	   SELECT DISTINCT tgd.counterparty_id,
		      tgd.contract_id,
		      tgd.invoice_line_item_id,
		      tgd.true_up_charge_type_id,
		      ISNULL(tgd.is_true_up,'n'),
		      civv1.prod_date,
		      CONVERT(VARCHAR(10),  CASE WHEN @term_end>COALESCE(cca.contract_end_date,cg.term_end,'9999-01-01') THEN CONVERT(VARCHAR(7),COALESCE(cca.contract_end_date,cg.term_end,'9999-01-01'),120)+'-01' ELSE @term_end END, 120),
		      tgd.invoice_line_item_id
		FROM 
			#contract_group_detail tgd
			INNER JOIN counterparty_contract_address cca ON cca.counterparty_id = tgd.counterparty_id AND cca.contract_id=tgd.contract_id
			INNER JOIN contract_group cg ON cg.contract_id = cca.contract_id
			OUTER APPLY (SELECT MIN(prod_date) prod_date FROM calc_invoice_volume_variance WHERE counterparty_id=tgd.counterparty_id 
			AND contract_id=tgd.contract_id AND prod_date >= CONVERT(VARCHAR(10), CASE WHEN @term_start<COALESCE(cca.contract_start_date,cg.term_start,'1900-01-01') THEN CONVERT(VARCHAR(7),COALESCE(cca.contract_start_date,cg.term_start,'1900-01-01'),120)+'-01' ELSE @term_start END, 126)
			)  civv1
			LEFT JOIN contract_group_detail cgd ON cgd.contract_id = cg.contract_id AND cgd.true_up_charge_type_id = tgd.invoice_line_item_id
		WHERE
			cgd.[ID] IS NULL
			AND ISNULL(tgd.is_true_up,'n') = 'n'
	




		DECLARE @_prod_date_from VARCHAR(10) = CONVERT(VARCHAR(10),@prod_date,120)
		DECLARE @_prod_date_to VARCHAR(10) = CONVERT(VARCHAR(10),@prod_date_to,120)
		
		
		
		DELETE FROM #trueup_period WHERE term_start IS NULL
		SELECT @term_start = ISNULL(MIN(term_start),@_prod_date_from), @term_end = ISNULL(MAX(term_end), @_prod_date_to) FROM #trueup_period
		SET @process_id = REPLACE(newid(),'-','_')



	   -- invoice line item id
	   SELECT @invoice_line_item_id  = COALESCE(@invoice_line_item_id +  ',', '')  + CAST(cgd.invoice_line_item_id AS VARCHAR(10))  FROM #contract_group_detail cgd
	   WHERE ((@contract_id_param IS NOT NULL AND cgd.contract_id IN (select item from dbo.SplitCommaSeperatedValues(@contract_id_param))) OR @contract_id_param IS NULL)
	   


	   EXEC [spa_calc_invoice] 
			@prod_date  = @term_start,
			@counterparty_id  = @counterparty_id,
			@as_of_date  = @as_of_date,
			@process_id  = @process_id,
			@test_run  = 'y',
			@settlement_adjustment  = 'y',
			@sub_entity_id  = -1,
			@contract_id_param  = @contract_id_param,
			@estimate_calculation  = 'n',
			@module_type  = 'stlmnt',
			@invoice_line_item_id  =  @invoice_line_item_id,
			@deal_id  = NULL,
			@deal_ref_id  = NULL,
			@deal_set_calc  = @deal_set_calc,
			@cpt_type  = 'e',
			@deal_list_table  = NULL ,
			@date_type  = 't',
			@calc_id = NULL,
			@prod_date_to  = @term_end,
			@call_from_true_up = 'y'


		
	DECLARE @calc_result_table VARCHAR(200), @calc_result_detail_table VARCHAR(200), @calc_invoice_volume VARCHAR(255), @table_calc_invoice_volume_variance VARCHAR(200)
	DECLARE @sql VARCHAR(MAX)
	DECLARE @user_login_id VARCHAR(255) = dbo.FNADBUSER()

	SET @calc_result_table = dbo.FNAProcessTableName('formula_calc_result', @user_login_id,@process_id)
	SET @calc_result_detail_table = dbo.FNAProcessTableName('formula_calc_result_detail', @user_login_id,@process_id)
	SET @table_calc_invoice_volume_variance = dbo.FNAProcessTableName('calc_invoice_volume_variance', @user_login_id,@process_id)
	SET @calc_invoice_volume = dbo.FNAProcessTableName('calc_invoice_volume', @user_login_id,@process_id)	




	-- Delete True up data for that production month		
	SET @sql = 'DELETE citu
				FROM   calc_invoice_true_up citu
						INNER JOIN '+@calc_result_table+' civv
							ON  citu.counterparty_id = civv.counterparty_id
							AND citu.contract_id = civv.contract_id'+
							CASE WHEN @calc_id IS NOT NULL THEN ' INNER JOIN dbo.SplitCommaSeperatedValues('''+@calc_id+''') a ON a.[item] = civv.calc_id ' ELSE '
							AND citu.prod_date = 
								''' +  @_prod_date_from + '''' END
							--AND citu.as_of_date = 
							--	''' +  CONVERT(VARCHAR(10), @as_of_date ,120)+ '''
								--AND civv.is_true_up=''y'''
	EXEC(@sql)
    
    -- Delete True up data for that true up period
    SET @sql = 'DELETE citu
    FROM   calc_invoice_true_up citu
           INNER JOIN #trueup_period tp
                ON  citu.counterparty_id = tp.counterparty_id
                AND citu.contract_id = tp.contract_id
                AND citu.prod_date BETWEEN tp.term_start AND tp.term_end'
				+CASE WHEN @calc_id IS NOT NULL THEN ' INNER JOIN dbo.SplitCommaSeperatedValues('''+@calc_id+''') a ON a.[item] = citu.calc_id ' ELSE
				 ' INNER JOIN Calc_Invoice_Volume_variance civv on citu.calc_id = civv.calc_id AND civv.prod_date =''' + @_prod_date_from  + '''' 
				+ ' AND civv.as_of_date =''' + CONVERT(VARCHAR(10), @as_of_date ,120) + '''' END
				+ ' AND citu.true_up_calc_id IS NULL'
	EXEC(@sql)

	--	Monthly Breakdown of trueup period 
	IF OBJECT_ID('tempdb..#term_breakdown') IS NOT NULL 
		DROP TABLE tempdb..#term_breakdown
	
	CREATE TABLE #term_breakdown
		(term_start DATETIME,term_end DATETIME)
		
	INSERT INTO #term_breakdown
	SELECT DATEADD(MONTH,n -1,tp.ts) [term_start], 
	CAST(CAST(DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, DATEADD(MONTH,n -1,tp.ts)) + 1, 0)) AS DATE) AS DATETIME)
	FROM seq
	CROSS APPLY(SELECT MIN(term_start) ts, MAX(term_end) te
					FROM #trueup_period) tp
	WHERE n <= DATEDIFF(MONTH,tp.ts,tp.te) + 1
	
	
	IF OBJECT_ID('tempdb..#true_up_deal_volumes') IS NOT NULL 
	DROP TABLE tempdb..#true_up_deal_volumes
	
	CREATE TABLE #true_up_deal_volumes
	(prod_date DATETIME,prod_date_to DATETIME, as_of_date DATETIME, counterparty_id INT, contract_id INT, charge_type_id INT, invoice_line_item_id INT, true_up_charge_type_id INT,term_start DATETIME, term_end DATETIME, [value] FLOAT,volume FLOAT,source_deal_header_id INT)
	
	INSERT INTO #true_up_deal_volumes
	SELECT @prod_date, @prod_date_to, ifbs.as_of_date, cgd.counterparty_id,cgd.contract_id,ccm.charge_type_id,tp.invoice_line_item_id,cgd.invoice_line_item_id [true_up_charge_type_id],tb.term_start,
			tb.term_end,ifbs.value,ifbs.volume,sdh.source_deal_header_id 
	FROM    #contract_group_detail cgd
			LEFT JOIN contract_component_mapping AS ccm
				ON  cgd.invoice_line_item_id = ccm.contract_component_id
			LEFT JOIN index_fees_breakdown_settlement AS ifbs
				ON  ccm.charge_type_id = ifbs.field_id
				AND ifbs.as_of_date = @as_of_date
			INNER JOIN #term_breakdown tb
				ON  ifbs.term_start = tb.term_start
				AND ifbs.term_end = tb.term_end
			INNER JOIN source_deal_header AS sdh
				ON  ifbs.source_deal_header_id = sdh.source_deal_header_id
				AND  sdh.counterparty_id = cgd.counterparty_id
				AND sdh.contract_id = cgd.contract_id
			INNER JOIN #trueup_period tp ON tp.true_up_charge_type_id = cgd.invoice_line_item_id
	UNION ALL
	SELECT @prod_date, @prod_date_to, sds.as_of_date, cgd.counterparty_id,cgd.contract_id,ccm.charge_type_id,tp.invoice_line_item_id,cgd.invoice_line_item_id [true_up_charge_type_id],
			tb.term_start,tb.term_end,sds.contract_value [value],sds.volume,sdh.source_deal_header_id 
	FROM    #contract_group_detail cgd
			INNER JOIN contract_component_mapping AS ccm
				ON  cgd.invoice_line_item_id = ccm.contract_component_id
				AND ccm.charge_type_id = -5500
			INNER JOIN source_deal_header AS sdh
				ON  sdh.counterparty_id = cgd.counterparty_id
				AND sdh.contract_id = cgd.contract_id
			INNER JOIN source_deal_settlement AS sds
				ON  sds.source_deal_header_id = sdh.source_deal_header_id
				AND sds.as_of_date = @as_of_date
			INNER JOIN #term_breakdown tb
				ON  tb.term_start = sds.term_start
				AND tb.term_end = sds.term_end
			INNER JOIN #trueup_period tp ON tp.true_up_charge_type_id = cgd.invoice_line_item_id
	

    IF OBJECT_ID('tempdb..#true_up_volumes') IS NOT NULL
		DROP TABLE tempdb..#true_up_volumes
		
	CREATE TABLE #true_up_volumes
	(
		as_of_date           DATETIME,
		prod_date            DATETIME,
		prod_date_to         DATETIME,
		invoice_line_item_id INT,
		counterparty_id      INT,
		contract_id          INT,
		formula_group_id     INT,
		[value]              FLOAT,
		volume               FLOAT,
		finalized            CHAR(1) COLLATE DATABASE_DEFAULT,
		is_final_result		 CHAR(1) COLLATE DATABASE_DEFAULT,
		calc_id				 INT,
		invoice_type		 CHAR(1)
	)
	            
	
	SET @sql ='INSERT INTO #true_up_volumes (as_of_date, prod_date, prod_date_to, invoice_line_item_id, counterparty_id, contract_id, formula_group_id, [value], volume, finalized, is_final_result,calc_id,invoice_type)
	SELECT civv.as_of_date,
	       dbo.FNAGetContractMonth(calc.prod_date),
	       civv.prod_date_to,
	       calc.invoice_line_item_id,
	       civv.counterparty_id,
	       civv.contract_id,
	       calc.formula_group_id,
	       SUM(calc.formula_eval_value) [value],
	       0 volume,
	       0,--civ.finalized,
	       calc.is_final_result,
		   civv.calc_id,
		   civv.invoice_type
	FROM   ' + @table_calc_invoice_volume_variance + ' civv
	       INNER JOIN ' + @calc_result_table + ' calc
	            ON  civv.calc_id = calc.calc_id
	CROSS APPLY (
			SELECT tp.counterparty_id,
			       tp.contract_id,
			       MIN(tp.term_start)     term_start,
			       MAX(tp.term_end)       term_end
			FROM   #trueup_period         tp
			GROUP BY
			       tp.counterparty_id,
			       tp.contract_id
	) period	
	WHERE  calc.is_final_result = ''y'' 
	       AND calc.prod_date BETWEEN period.term_start AND period.term_end
	       AND civv.counterparty_id = period.counterparty_id
               AND civv.contract_id = period.contract_id
	GROUP BY   civv.as_of_date,dbo.FNAGetContractMonth(calc.prod_date),civv.prod_date_to,calc.invoice_line_item_id, civv.counterparty_id,civv.contract_id, calc.formula_group_id ,calc.is_final_result,civv.calc_id,civv.invoice_type  '
	EXEC (@sql)
	
	--PRINT @sql
	SET @sql ='
		UPDATE tuv
			SET tuv.volume = vol.volume
		FROM
			#true_up_volumes tuv
			CROSS APPLY (
					SELECT tp.counterparty_id,
						   tp.contract_id,
						   MIN(tp.term_start)     term_start,
						   MAX(tp.term_end)       term_end
					FROM   #trueup_period         tp
					GROUP BY
						   tp.counterparty_id,
						   tp.contract_id
				) period 
			CROSS APPLY(SELECT SUM(CAST(CASE WHEN a.formula_group_id IS NOT NULL THEN a.formula_eval_value ELSE a.volume END AS FLOAT)) volume,
				   dbo.fnagetcontractmonth(a.prod_date) prod_date,
				   a.invoice_line_item_id,a.counterparty_id,a.contract_id
			FROM ' + @calc_result_table + ' a
				   LEFT JOIN formula_nested fn
						ON  fn.formula_group_id = a.formula_id
						AND fn.sequence_order = a.formula_sequence_number
						AND fn.show_value_id = 1200	
			WHERE a.counterparty_id = tuv.counterparty_id 
				AND a.contract_id = tuv.contract_id 
				AND a.prod_date BETWEEN period.term_start AND period.term_end
				AND a.invoice_line_item_id = tuv.invoice_line_item_id
				AND a.calc_id = tuv.calc_id
			GROUP BY
				   dbo.fnagetcontractmonth(a.prod_date),
				   a.invoice_line_item_id,a.counterparty_id,a.contract_id
		) vol	
		WHERE tuv.prod_date = vol.prod_date AND tuv.invoice_line_item_id = vol.invoice_line_item_id
		AND tuv.counterparty_id = vol.counterparty_id AND tuv.contract_id = vol.contract_id'

	EXEC (@sql)
		


	INSERT INTO calc_invoice_true_up (calc_id,counterparty_id, contract_id, true_up_month, sequence_id, as_of_date, formula_id, prod_date, prod_date_to, invoice_line_item_id,  [value], volume, is_final_result,invoice_type)
	SELECT 
	NULL calc_id, v.counterparty_id,
	       v.contract_id,
	       v.prod_date,
	       1,
	       CONVERT(VARCHAR(10), v.as_of_date,120),
	       v.formula_group_id,
	       CONVERT(VARCHAR(10), v.prod_date,120),
	       CONVERT(VARCHAR(10), v.prod_date_to,120),
	       ISNULL(true_up_item.[true_up_charge_type_id],cgd.invoice_line_item_id),
	       (
	           v.[value] - dbo.FNARPriorFinalizedAmount(
	               v.contract_id,
	               v.counterparty_id,
	               v.prod_date,
	               v.invoice_line_item_id,
				   v.invoice_type
	           ) - dbo.FNARPriorFinalizedAmount(
	               v.contract_id,
	               v.counterparty_id,
	               v.prod_date,
	               true_up_item.[true_up_charge_type_id],
				   v.invoice_type
	           )
	       ) [value],
	       (
	           v.volume - dbo.FNARPriorFinalizedVol(
	               v.contract_id,
	               v.counterparty_id,
	               v.prod_date,
	               v.invoice_line_item_id,
				   v.invoice_type
	           ) - dbo.FNARPriorFinalizedVol(
	               v.contract_id,
	               v.counterparty_id,
	               v.prod_date,
	               true_up_item.[true_up_charge_type_id],
				   v.invoice_type
	           )
	       ) volume,
	       v.is_final_result,
		   v.invoice_type
	FROM   #true_up_volumes v
	INNER JOIN #contract_group_detail cgd
		ON v.contract_id = cgd.contract_id
		AND v.counterparty_id = cgd.counterparty_id
		AND v.invoice_line_item_id = cgd.true_up_charge_type_id
	OUTER APPLY (
	    SELECT cgd.invoice_line_item_id [true_up_charge_type_id]
	    FROM   #trueup_period cgd
	    WHERE  v.contract_id = cgd.contract_id
			AND v.counterparty_id = cgd.counterparty_id 
			AND cgd.is_true_up = 'y'
			AND cgd.true_up_charge_type_id = v.invoice_line_item_id
	) true_up_item
	CROSS APPLY(SELECT MAX(finalized) finalized FROM  Calc_invoice_Volume_variance 
		            WHERE  counterparty_id = v.counterparty_id
		            AND contract_id = v.contract_id
		            AND prod_date = v.prod_date
					AND invoice_type = v.invoice_type
					AND ISNULL(finalized,'n') = 'y' 
		) civv
	LEFT JOIN calc_invoice_true_up citp ON citp.counterparty_id = v.counterparty_id
		AND citp.contract_id = v.contract_id
		AND citp.true_up_month = v.prod_date
		AND citp.invoice_line_item_id =  ISNULL(true_up_item.[true_up_charge_type_id],cgd.invoice_line_item_id)
	WHERE v.volume <> 0 AND civv.finalized = 'y' AND citp.calc_id IS NULL
	AND  (
	           v.[value] - dbo.FNARPriorFinalizedAmount(
	               v.contract_id,
	               v.counterparty_id,
	               v.prod_date,
	               v.invoice_line_item_id,
				   v.invoice_type
	           ) - dbo.FNARPriorFinalizedAmount(
	               v.contract_id,
	               v.counterparty_id,
	               v.prod_date,
	               true_up_item.[true_up_charge_type_id],
				   v.invoice_type
	           )
	       ) <> 0
	AND ISNULL(cgd.is_true_up,'n') = 'y'
	UNION ALL
	SELECT civv.calc_id, t.counterparty_id,
	       t.contract_id,
	       t.term_start [true_up_month],
	       1,
	       civv.as_of_date,
	       NULL,
	       t.term_start,
	       t.term_end,
	       t.invoice_line_item_id,
	       (t.[value] - cfv.[value]) [value],
	       (t.volume - cfv.volume) [volume],
	       'y' [is_final_result],
		   civv.invoice_type
	FROM   #true_up_deal_volumes t
	       INNER JOIN calc_formula_value cfv
	            ON  t.term_start = cfv.prod_date
	            AND t.counterparty_id = cfv.counterparty_id
	            AND t.contract_id = cfv.contract_id
	            AND t.true_up_charge_type_id = cfv.invoice_line_item_id
	            AND ISNULL(finalized, 'n') = 'y'
	            AND cfv.source_deal_header_id = t.source_deal_header_id
			OUTER APPLY (
					SELECT CASE WHEN (ISNULL(cg.neting_rule, 'n') = 'y'OR ISNULL(apply_netting_rule, 'n') = 'y') THEN 1 ELSE 0 END [active]
					FROM   contract_group cg
							INNER JOIN counterparty_contract_address cca
								ON  cfv.counterparty_id = cca.counterparty_id
								AND cca.contract_id = cfv.contract_id
					WHERE  cfv.contract_id = cg.contract_id
				) netting
	       INNER JOIN Calc_invoice_Volume_variance civv 
		            ON  civv.as_of_date = t.as_of_date
		            AND civv.counterparty_id = t.counterparty_id
		            AND civv.contract_id = t.contract_id
		            AND civv.prod_date = t.prod_date
					AND ISNULL(civv.finalized,'n') = 'y' 
		INNER JOIN source_deal_header sdh ON t.source_deal_header_id = sdh.source_deal_header_id
		LEFT JOIN calc_invoice_true_up citp ON citp.counterparty_id = civv.counterparty_id
			AND citp.contract_id = civv.contract_id
			AND citp.true_up_month = civv.prod_date
			AND citp.invoice_line_item_id =  t.invoice_line_item_id
		WHERE 
		t.[value] - cfv.[value] <> 0 AND citp.calc_id IS NULL
		AND sdh.header_buy_sell_flag = CASE 
		                                WHEN netting.active = 0 AND civv.invoice_type = 'i' THEN 's'
		                                WHEN netting.active = 0 AND civv.invoice_type = 'r' THEN 'b'
		                                ELSE sdh.header_buy_sell_flag

		                           END


		-- True up decisions with formula mapped in contract charge types 
		SET @sql ='INSERT INTO calc_invoice_true_up (calc_id, counterparty_id, contract_id, true_up_month,invoice_line_item_id, invoice_number, formula_id, sequence_id, as_of_date, prod_date, prod_date_to, [value],is_final_result, volume,invoice_type)  
		SELECT NULL [calc_id],
			   calc.counterparty_id,
			   calc.contract_id,
			   calc.prod_date true_up_month,
			   calc.invoice_line_item_id,
			   NULL               invoice_number,
			   calc.formula_id,
			   calc.formula_sequence_number,
			   CONVERT(VARCHAR(10), calc.as_of_date, 120),
			   ' + '''' +  @_prod_date_from + ''',
			   ''' + @_prod_date_to + ''',
			   SUM(calc.formula_eval_value),
			   calc.is_final_result,
			   MAX(vol.volume),
			   civv.invoice_type
		FROM   ' + @calc_result_table + ' calc
			   INNER JOIN #contract_group_detail cgd
					ON  calc.contract_id = cgd.contract_id
					AND calc.counterparty_id = cgd.counterparty_id 
					AND cgd.is_true_up = ''y''
					AND cgd.invoice_line_item_id = calc.invoice_line_item_id
					AND ISNULL(cgd.true_up_charge_type_id, 0) = 0
				OUTER APPLY(
						SELECT SUM(CAST(a.formula_eval_value AS FLOAT)) volume
						FROM   ' + @calc_result_table + ' a
							   INNER JOIN formula_nested fn
									ON  fn.formula_group_id = a.formula_id
									AND fn.sequence_order = a.formula_sequence_number
									AND fn.show_value_id = 1200
									AND a.contract_id = calc.contract_id
									AND a.counterparty_id = calc.counterparty_id
									AND a.prod_date = calc.prod_date
									AND a.as_of_date = calc.as_of_date
									AND a.invoice_line_item_id = cgd.invoice_line_item_id
					) vol
					INNER JOIN '+@table_calc_invoice_volume_variance+' civv ON civv.calc_id=calc.calc_id
					LEFT JOIN calc_invoice_true_up citp ON citp.counterparty_id = calc.counterparty_id
						AND citp.contract_id = calc.contract_id
						AND citp.true_up_month = calc.prod_date
						AND citp.invoice_line_item_id =  calc.invoice_line_item_id
			WHERE citp.calc_id IS NULL
			GROUP BY calc.counterparty_id, calc.contract_id, calc.prod_date,calc.invoice_line_item_id,calc.formula_id, calc.formula_sequence_number,calc.as_of_date, calc.is_final_result,civv.invoice_type
			HAVING SUM(calc.formula_eval_value) <> 0'
		EXEC (@sql)
	

		CREATE TABLE #true_up_inserted_values(calc_id INT,contract_id INT,counterparty_id INT,as_of_date DATETIME, prod_date DATETIME, prod_date_to DATETIME, invoice_line_item_id INT, is_final_result CHAR(1) COLLATE DATABASE_DEFAULT,true_up_month DATETIME)
		-- Update Calc ID and Invoice Number
		UPDATE citu SET citu.calc_id = civv.calc_id, citu.invoice_number = ISNULL(civv.invoice_number, citu.calc_id),citu.as_of_date = civv.as_of_date
		output inserted.calc_id,inserted.contract_id,inserted.counterparty_id,inserted.as_of_date,inserted.prod_date,inserted.prod_date_to,inserted.invoice_line_item_id,inserted.is_final_result,inserted.true_up_month into #true_up_inserted_values	
		FROM   calc_invoice_true_up citu			
		       INNER JOIN Calc_invoice_Volume_variance civv 
		            ON  civv.counterparty_id = citu.counterparty_id
		            AND civv.contract_id = citu.contract_id
		            AND civv.prod_date = @prod_date
		            AND citu.calc_id IS NULL
					AND civv.invoice_type = citu.invoice_type
					--AND ISNULL(civv.finalized,'n') = 'y'
				CROSS APPLY(SELECT MAX(as_of_date) as_of_date FROM Calc_invoice_Volume_variance WHERE  counterparty_id = civv.counterparty_id
		            AND contract_id = civv.contract_id
		            AND prod_date = civv.prod_date
				) civv1
			WHERE
				civv.as_of_date = civv1.as_of_date


		DELETE FROM #true_up_inserted_values WHERE ISNULL(is_final_result,'n') <> 'y'

		DELETE 
			citp
		FROM 
			#true_up_inserted_values tuiv
			INNER JOIN Calc_invoice_Volume_variance civv ON tuiv.calc_id = civv.netting_calc_id AND tuiv.true_up_month = civv.prod_date
			INNER JOIN calc_invoice_true_up citp ON citp.calc_id = civv.calc_id AND citp.invoice_line_item_id = tuiv.invoice_line_item_id


		INSERT INTO calc_invoice_true_up (calc_id, counterparty_id, contract_id, true_up_month,invoice_line_item_id, formula_id, sequence_id, as_of_date, prod_date, prod_date_to, [value],is_final_result, volume,invoice_type)  
		SELECT 
			civv.calc_id, civv.counterparty_id, civv.contract_id, tuiv.true_up_month,tuiv.invoice_line_item_id, MAX(citp.formula_id), MAX(citp.sequence_id), civv.as_of_date, citp.prod_date, citp.prod_date_to, SUM(citp.[value]),'y' is_final_result, SUM(citp.volume),MAX(citp.invoice_type)
		FROM 
			#true_up_inserted_values tuiv
			INNER JOIN calc_invoice_true_up citp ON tuiv.calc_id = citp.calc_id
				AND citp.invoice_line_item_id = tuiv.invoice_line_item_id
				AND citp.is_final_result = 'y'
				AND tuiv.true_up_month = citp.true_up_month
			INNER JOIN Calc_invoice_Volume_variance civv1 ON civv1.calc_id = tuiv.calc_id
			CROSS APPLY(SELECT calc_id, counterparty_id, contract_id, as_of_date, prod_date, prod_date_to FROM 
				Calc_invoice_Volume_variance  WHERE  calc_id = civv1.netting_calc_id
			) civv
			LEFT JOIN calc_invoice_true_up citp1 ON citp1.counterparty_id = citp.counterparty_id
						AND citp1.contract_id = citp.contract_id
						AND citp1.true_up_month = citp.true_up_month
						AND citp1.invoice_line_item_id =  citp.invoice_line_item_id
		WHERE citp1.calc_id IS NULL
		GROUP BY 
			civv.calc_id, civv.counterparty_id, civv.contract_id, tuiv.true_up_month,tuiv.invoice_line_item_id,civv.as_of_date, citp.prod_date, citp.prod_date_to

		IF @batch_process_id IS NOT NULL
		BEGIN	

			DECLARE @url VARCHAR(5000),@desc VARCHAR(5000),@job_name VARCHAR(200)
			SET @job_name = 'batch_' + @batch_process_id
			SET @user_id = dbo.FNADBUser()

			IF EXISTS(SELECT 'X' FROM #true_up_inserted_values)
			BEGIN
				SET @sql='
					INSERT INTO process_settlement_invoice_log
					(   
						process_id,
						code,
						module,
						counterparty_id,
						prod_date,
						[description],
						nextsteps	   
					)   
					SELECT DISTINCT
						'''+@batch_process_id+''',
						''Success'',
						''True-Up'',
						sc.source_counterparty_id,
						MAX(dbo.FNAGetcontractMonth('''+CAST(@as_of_date AS VARCHAR)+''')),
						''True-Up Calculation Completed for counterparty' +':''+sc.counterparty_name+'' '+ 'contract' +': '' + ISNULL(cg.contract_name,'''') + '' for Production Month : ''+CONVERT(VARCHAR(10),MAX(civv.prod_date),120)+''. True Up Month : ''+CONVERT(VARCHAR(10),MIN(tuiv.prod_date),120)+'' to ''+CONVERT(VARCHAR(10),MAX(tuiv.prod_date),120),
						''Please Check Data''
					FROM   
						#true_up_inserted_values tuiv
						INNER JOIN Calc_invoice_Volume_variance civv ON tuiv.calc_id = ISNULL(civv.netting_calc_id,civv.calc_id) --AND tuiv.true_up_month = civv.prod_date
						INNER JOIN source_counterparty sc ON sc.source_counterparty_id = civv.counterparty_id
						INNER JOIN contract_group cg ON cg.contract_id = civv.contract_id
					GROUP BY sc.source_counterparty_id,sc.counterparty_name,cg.contract_name
					'	
		
					EXEC(@sql)


				SET @total_time=CAST(DATEPART(mi,getdate()-@calc_start_time) AS VARCHAR)+ ' min '+ CAST(DATEPART(s,getdate()-@calc_start_time) AS VARCHAR)+' sec'

				SET @url = './dev/spa_html.php?__user_name__=''' + @user_id + '''&spa=exec spa_get_settlement_invoice_log ''' + @batch_process_id + ''''

				SET @desc = '<a target="_blank" href="' + @url + '">True Up Calculation Completed:  As of Date  ' + dbo.FNAContractmonthFormat(@as_of_date)+ '.</a> (Elapsed Time: '+@total_time+')'	 
				END
				ELSE
				BEGIN
					SET @desc = 'No Data Found to calculate True-Up.'
				END

				EXEC spa_message_board 'i',
						 @user_id,
						 NULL,
						 'True-Up Calculation',
						 @desc,
						 '',
						 '',
						 's',
						 @job_name 
			END

END
