
----/****** Object:  StoredProcedure [dbo].[spa_run_settlement_invoice_report]    Script Date: 10/08/2009 13:46:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_run_settlement_invoice_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_run_settlement_invoice_report]
/****** Object:  StoredProcedure [dbo].[spa_run_settlement_invoice_report]    Script Date: 10/08/2009 13:46:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*********************
Created By: Anal Shrestha
Created On:12-15-2008
exec [dbo].[spa_run_settlement_invoice_report] 'z',null,null,'2011-01-31',null,'2011-01-01'

SP to get the broker FEE
EXEC spa_get_calc_history NULL,NULL,'2008-01-01','2009-12-31'
*************************/
CREATE PROC [dbo].[spa_run_settlement_invoice_report]
	@summary_option VARCHAR(5) = 'a', -- 'a'-> Monthly by Counterparty, 'b'-> Monthly charges by Counterparty, 'c'->Detailed by Prod Date,''' 
	@counterparty_id VARCHAR(MAX) = NULL,
	@contract_id  VARCHAR(MAX) = NULL,
	@as_of_date_from DATETIME,
	@as_of_date_to DATETIME = NULL,
	@settlement_date_from DATETIME,
	@settlement_date_to DATETIME = NULL,
	@prod_date_from DATETIME,
	@prod_date_to DATETIME = NULL,
	@show_recent_calculation CHAR(1) = NULL,
	@drill_counterparty VARCHAR(100) = NULL,
	@drill_contract VARCHAR(100) = NULL,
	@drill_prod_month VARCHAR(100) = NULL,
	@drill_as_of_date VARCHAR(100) = NULL,
	@drill_line_item VARCHAR(100) = NULL,
	@deal_id VARCHAR(500) = NULL,
	@ref_id VARCHAR(50) = NULL,
	@model_type CHAR(1) = NULl, -- f- financial model
	@deal_list_table    VARCHAR(MAX) = NULL,
	@round_value CHAR(1) = '0',
	@invoice_type CHAR(1) = NULL,
	@workflow_status INT = NULL,
	@batch_process_id VARCHAR(250) = NULL,
	@batch_report_param VARCHAR(500) = NULL, 
	@enable_paging INT = 0, --'1' = enable, '0' = disable
	@page_size INT = NULL,
	@page_no INT = NULL	
AS

--EXEC spa_run_settlement_invoice_report 'd','3830','1073','2014-11-01',NULL,NULL,NULL,NULL,'2011-01-01','n',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2'
--EXEC spa_run_settlement_invoice_report 'z','3889','1183',null,'2015-07-24',null,null,null,null,'y',null,null,null,null,null,null,null,null,'15085','2'
--EXEC spa_run_settlement_invoice_report 'z',null,null,null,null,null,null,null,null,'y',null,null,null,null,null,null,null,null,null,'2'
--declare
--@summary_option VARCHAR(5) = 'z', -- 'a'-> Monthly by Counterparty, 'b'-> Monthly charges by Counterparty, 'c'->Detailed by Prod Date,''' 
--	@counterparty_id VARCHAR(MAX) = null,
--	@contract_id  VARCHAR(MAX) = null,
--	@as_of_date_from DATETIME = null,
--	@as_of_date_to DATETIME = null,
--	@settlement_date_from DATETIME,
--	@settlement_date_to DATETIME = NULL,
--	@prod_date_from DATETIME,
--	@prod_date_to DATETIME = null,
--	@show_recent_calculation CHAR(1) = 'y',
--	@drill_counterparty VARCHAR(100) = NULL,
--	@drill_contract VARCHAR(100) = NULL,
--	@drill_prod_month VARCHAR(100) = NULL,
--	@drill_as_of_date VARCHAR(100) = NULL,
--	@drill_line_item VARCHAR(100) = NULL,
--	@deal_id VARCHAR(500) = NULL,
--	@ref_id VARCHAR(50) = NULL,
--	@model_type CHAR(1) = NULl, -- f- financial model
--	@deal_list_table    VARCHAR(200) = null,
--	@round_value CHAR(1) = '2',
--	@enable_paging INT = 0, --'1' = enable, '0' = disable
--	@batch_process_id VARCHAR(250) = NULL,
--	@batch_report_param VARCHAR(500) = NULL, 
--	@page_size INT = NULL,
--	@page_no INT = NULL	
SET NOCOUNT ON

BEGIN

	DECLARE @sql_str                             VARCHAR(MAX)
	DECLARE @sql_str2                             VARCHAR(MAX)
	DECLARE @sel_str                             VARCHAR(MAX)
	DECLARE @where_str                           VARCHAR(MAX)
	DECLARE @group_str                           VARCHAR(MAX)
	DECLARE @table_calc_invoice_volume_variance  VARCHAR(50)
	DECLARE @table_calc_formula_value            VARCHAR(50)
	DECLARE @table_calc_invoice_volume           VARCHAR(50)
	DECLARE	@group_by							 VARCHAR(MAX)
	DECLARE @cpt_clm_name							 VARCHAR(50)
	DECLARE @contract_clm_name					 VARCHAR(50)
	DECLARE @convert_uom						 INT
	DECLARE @counterparty_type					VARCHAR(5)
	
	DECLARE @mwh INT
	SELECT @mwh=source_uom_id FROM source_uom WHERE uom_id='MWh'
	SET @convert_uom=COALESCE(@convert_uom,@mwh,-1)
	
	IF @model_type = 'f'
	BEGIN
		SET @cpt_clm_name = '[Model Group]'
		SET @contract_clm_name = '[Model]'	
		SET @counterparty_type = 'm'
	END	
	ELSE
	BEGIN
		SET @cpt_clm_name =  'Counterparty'
		SET @contract_clm_name =  'Contract'
		SET @counterparty_type = 'i'',''e'',''b'',''c'''			
	END
	
	--IF @estimate_calculation='y'
	--BEGIN
	--	SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance_estimates'
	--	SET @table_calc_invoice_volume = 'calc_invoice_volume_estimates'
	--	SET @table_calc_formula_value = 'calc_formula_value_estimates'

	--END
	--ELSE
	BEGIN
		SET @table_calc_invoice_volume_variance = 'calc_invoice_volume_variance'
		SET @table_calc_invoice_volume = 'calc_invoice_volume'
		SET @table_calc_formula_value = 'calc_formula_value'
	END
	
	CREATE TABLE #temp ( deal_id VARCHAR(30) COLLATE DATABASE_DEFAULT)
 
	IF @deal_id IS NOT NULL 
	BEGIN
		DECLARE @sql_deal VARCHAR(MAX)

		IF ISNUMERIC(@deal_id) = 0
			SET @sql_deal = 'INSERT INTO #temp
							 SELECT deal_id
							 FROM   ' + @deal_id
		ELSE
			SET @sql_deal = 'INSERT INTO #temp
							 SELECT ' + @deal_id
		EXEC (@sql_deal)
	END
	
	--CREATE TABLE #temp_filter (deal_id VARCHAR(500) COLLATE DATABASE_DEFAULT)
	
	
		IF @deal_list_table IS NOT NULL
		BEGIN
			INSERT INTO #temp
			SELECT s.item FROM dbo.SplitCommaSeperatedValues(@deal_list_table) s
		END

	
	

	--IF @deal_id IS NOT NULL 
	--BEGIN
	--	DECLARE @sql_deal VARCHAR(MAX)

	--	IF ISNUMERIC(@deal_id)=0
	--		SET @sql_deal = 'INSERT INTO #temp
	--						 SELECT deal_id
	--						 FROM   ' + @deal_id
	--	ELSE
			--SET @sql_deal = 'INSERT INTO #temp_filter
							 --SELECT * from  dbo.SplitCommaSeperatedValues('''+ @deal_filter_id +''')'
		--EXEC (@sql_deal)
	--END
			
	IF @as_of_date_to IS NULL AND @as_of_date_from IS NOT NULL
		SET @as_of_date_to=@as_of_date_from

	IF @as_of_date_to IS NOT NULL AND @as_of_date_from IS NULL
		SET @as_of_date_from=@as_of_date_to

	IF @prod_date_to IS NULL AND @prod_date_from IS NOT NULL
		SET @prod_date_to=@prod_date_from
		
	IF @prod_date_to IS NOT NULL AND @prod_date_from IS NULL
		SET @prod_date_from=@prod_date_to

	IF @settlement_date_to IS NULL AND @settlement_date_from IS NOT NULL
		SET @settlement_date_to=@settlement_date_from
		
	IF @settlement_date_to IS NOT NULL AND @settlement_date_from IS NULL
		SET @settlement_date_from=@settlement_date_to
		
	/*******************************************1st Paging Batch START**********************************************/
		DECLARE @str_batch_table  VARCHAR(8000)
		DECLARE @user_login_id    VARCHAR(50)
		DECLARE @sql_paging       VARCHAR(8000)
		DECLARE @is_batch         BIT


		SET @str_batch_table = ''
		SET @user_login_id = dbo.FNADBUser() 
		SET @is_batch = CASE WHEN @batch_process_id IS NOT NULL AND @batch_report_param IS NOT NULL THEN 1 ELSE 0 END 


		IF @is_batch = 1
		   SET @str_batch_table = ' INTO ' + dbo.FNAProcessTableName('batch_report', @user_login_id, @batch_process_id)


		IF @enable_paging = 1 --paging processing
		BEGIN
		   IF @batch_process_id IS NULL
			  SET @batch_process_id = dbo.FNAGetNewID()

		   SET @str_batch_table = dbo.FNAPagingProcess('p', @batch_process_id, @page_size, @page_no)

		   --retrieve data from paging table instead of main table
		   IF @page_no IS NOT NULL 
		   BEGIN
			  SET @sql_paging = dbo.FNAPagingProcess('s', @batch_process_id, @page_size, @page_no) 
			  EXEC (@sql_paging) 
			  RETURN 
		   END
		END
	/*******************************************1st Paging Batch END**********************************************/

	CREATE TABLE #calc_formula_value
	(
		invoice_line_item_id  INT,
		formula_id            INT,
		prod_date             DATETIME,
		volume                FLOAT,
		uom_id                INT,
		as_of_date            DATETIME,
		seq_number            INT,
		calc_id               INT,
		deal_id               VARCHAR(200) COLLATE DATABASE_DEFAULT,
		deal_filter_id			  VARCHAR(200) COLLATE DATABASE_DEFAULT	
	)
	
	--set @sql_str ='
	--	INSERT INTO 
	--			#calc_formula_value
	--	 select
	--		invoice_line_item_id,a.formula_id,
	--		a.prod_date as prod_date,
	--		MAX(case when show_value_id=1200 then (value) else NULL end) as volume,
	--		max(b.uom_id),
	--		civv.as_of_date,
	--		a.seq_number,
	--		a.calc_id,
	--		a.deal_id
	--	FROM
	--		'+@table_calc_invoice_volume_variance+' civv inner join 
	--		'+@table_calc_formula_value+' a on civv.calc_id=a.calc_id
	--		left join formula_nested b ON a.formula_id=b.formula_group_id
	--			AND a.seq_number=b.sequence_order
	--		LEFT JOIN rec_generator rg on rg.ppa_counterparty_id=civv.counterparty_id
	--	WHERE 1=1 and show_value_id=1200'
	--		+ CASE WHEN  @as_of_date_from IS NOT NULL THEN ' AND civv.as_of_date between '''+CAST(@as_of_date_from as VARCHAR)+''' AND '''+CAST(@as_of_date_to AS VARCHAR)+''''	ELSE '' END			
	--		+ CASE WHEN  @counterparty_id is not null then ' And a.counterparty_id IN('+@counterparty_id+')' else '' end+
	--		+ CASE WHEN  @contract_id IS NOT NULL THEN ' AND a.contract_id IN('+@contract_id+')' ELSE '' END+
	--	'GROUP BY
	--		invoice_line_item_id,a.formula_id,a.prod_date,
	--		civv.as_of_date,a.seq_number,a.calc_id,a.deal_id
	--	'	

	--exec(@sql_str)

	SET @where_str=
		+ CASE WHEN  @as_of_date_from IS NOT NULL THEN ' AND civv.as_of_date between '''+CAST(@as_of_date_from as VARCHAR)+''' AND '''+CAST(@as_of_date_to AS VARCHAR)+''''	ELSE '' END			
		+ CASE WHEN  @counterparty_id IS NOT NULL THEN ' AND civv.counterparty_id IN('+@counterparty_id+')' ELSE '' END
		+ CASE WHEN  @contract_id IS NOT NULL THEN ' AND civv.contract_id IN('+@contract_id+')' ELSE '' END

	CREATE TABLE #estimate_value
	(
		invoice_line_item_id  INT,
		prod_date             DATETIME,
		volume                FLOAT,
		uom_id                INT,
		as_of_date            DATETIME,
		calc_id               INT
		--deal_filter
	)
	
	SET @sql_str='INSERT INTO #estimate_value 					
				  SELECT 
					civ.invoice_line_item_id,
					civ.prod_date,	
					civ.volume,
					ISNULL(civ.uom_id,civv.uom) UOM,
					civv.as_of_date,
					civv.calc_id					   
				 FROM
					(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id FROM calc_invoice_volume_variance_estimates civv WHERE 1=1 '+@where_str+'
						GROUP BY prod_date,counterparty_id,contract_id)a
					INNER JOIN calc_invoice_volume_variance_estimates civv ON civv.as_of_date=a.as_of_date
						AND civv.prod_date=a.prod_date
						AND civv.counterparty_id=a.counterparty_id
						AND civv.contract_id=a.contract_id
					INNER JOIN dbo.calc_invoice_volume_estimates civ ON civ.calc_id=civv.calc_id	
				WHERE 1=1 '+@where_str+'' 		

	EXEC(@sql_str)

	IF @summary_option='a'
	BEGIN
		SET @sql_str='
		SELECT [AsOfDate] AS [As of Date],
			   [Counterparty] '+@cpt_clm_name+',
   			   [Invoice Type],			   
			   [Invoice Status] AS [Workflow Status],
			   [ProdDate] AS [Deliver Month],
			   [SettlementDate]  AS [Invoice Date],
			   [Payment Date] AS [Payment Date],
			   CAST(SUM([Amount]) AS NUMERIC(38,'+@round_value+')) AS [Amount],
			   [Currency]'
			   +@str_batch_table+
			   ' 
		FROM   ( SELECT 
						dbo.fnadateformat(CONVERT(VARCHAR(10),civv.as_of_date,102)) as [AsOfDate],
						max(sc.counterparty_name) AS [Counterparty],
						CASE WHEN civv.invoice_type = ''i'' THEN ''Invoice'' ELSE ''Remittance'' END AS [Invoice Type],
						dbo.fnadateformat(CONVERT(VARCHAR(10),civ.prod_date, 102)) [ProdDate],
						dbo.fnadateformat(civv.settlement_date) as [SettlementDate],
						SUM(CAST(isnull(civ.[value], 0) AS Numeric(20,'+@round_value+'))) as [Amount],
						cur.currency_name as [Currency],
						civ.invoice_line_item_id,
						ws.code [Invoice Status],
						dbo.fnadateformat(civv.payment_date) [Payment Date]
					FROM
						source_counterparty sc 
						'+CASE WHEN @show_recent_calculation = 'y' THEN	
						'OUTER APPLY(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id,invoice_type FROM calc_invoice_volume_variance WHERE counterparty_id=sc.source_counterparty_id'+ CASE WHEN  @as_of_date_from IS NOT NULL THEN ' AND as_of_date between '''+CAST(@as_of_date_from as VARCHAR)+''' AND '''+CAST(@as_of_date_to AS VARCHAR)+''''	ELSE '' END +' GROUP BY prod_date,counterparty_id,contract_id,invoice_type ) a
						INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=a.counterparty_id AND civv.contract_id=a.contract_id AND civv.prod_date=a.prod_date AND civv.as_of_date=a.as_of_date AND civv.invoice_type=a.invoice_type' 
						ELSE ' INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=sc.source_counterparty_id' END+'
						LEFT JOIN calc_invoice_volume civ on civv.calc_id=civ.calc_id AND civ.apply_cash_calc_detail_id IS NULL
						LEFT JOIN  static_data_value charge_type ON charge_type.value_id=civ.invoice_line_item_id
						LEFT JOIN calc_invoice_volume_variance_estimates civve on civve.counterparty_id=sc.source_counterparty_id
						LEFT JOIN calc_invoice_volume_estimates cive on civve.calc_id=cive.calc_id
						LEFT JOIN contract_group cg ON cg.contract_id=civv.contract_id
						LEFT join source_currency cur ON cur.source_currency_id=cg.currency
						LEFT JOIN netting_group ng ON ng.netting_group_id=civv.netting_group_id
						LEFT JOIN static_data_value ws ON ws.value_id = civv.invoice_status
				WHERE 1=1 '+@where_str
				+ CASE WHEN  @prod_date_from IS NOT NULL THEN ' AND civv.prod_date between '''+CAST(@prod_date_from as VARCHAR)+''' AND '''+CAST(@prod_date_to AS VARCHAR)+'''' ELSE '' END		
				+ CASE WHEN  @settlement_date_from IS NOT NULL THEN ' AND civv.settlement_date between '''+CAST(@settlement_date_from as VARCHAR)+''' AND '''+CAST(@settlement_date_to AS VARCHAR)+'''' ELSE '' END			
				+ CASE WHEN @invoice_type IS NOT NULL THEN ' AND civv.invoice_type = ''' + @invoice_type + '''' ELSE '' END
				+ CASE WHEN @workflow_status IS NOT NULL THEN ' AND civv.invoice_status = ''' + CAST(@workflow_status AS VARCHAR) + '''' ELSE '' END
				+ ' AND sc.int_ext_flag IN(''' + @counterparty_type + ''')'			
				+'GROUP BY civv.as_of_date,civ.invoice_line_item_id,civv.counterparty_id,civ.prod_date,civv.invoice_type,civv.settlement_date,cur.currency_name,ISNULL(ng.netting_group_name,cg.contract_name),ws.code,civv.payment_date
				) a GROUP BY [Invoice Type],[Invoice Status],[AsOfDate],[Counterparty],[ProdDate],[Currency],[SettlementDate],[Payment Date]'
				+' ORDER BY AsOfDate,2,3,4'

	END			
	ELSE IF @summary_option='b'
	BEGIN
		SET @sql_str='
					SELECT 
						dbo.fnadateformat(CONVERT(VARCHAR(10),civv.as_of_date,102)) as [As of Date],
						max(sc.counterparty_name) AS '+@cpt_clm_name+',
						max(ISNULL(ng.netting_group_name,cg.contract_name)) AS '+@contract_clm_name+',
						CASE WHEN civv.invoice_type = ''i'' THEN ''Invoice'' ELSE ''Remittance'' END AS [Invoice Type],
						ws.code [Workflow Status],
						dbo.fnadateformat(CONVERT(VARCHAR(10),civv.prod_date, 102)) as [Deliver Month],
						dbo.fnadateformat(civv.settlement_date) as [Invoice Date],
						dbo.fnadateformat(civv.payment_date) [Payment Date],
						charge_type.description as [Charge Type],
						 MAX(CASE WHEN civ.status =''v'' THEN ''Voided'' WHEN ISNULL(civ.finalized,''n'') =  ''y'' THEN ''Final'' ELSE ''Initial'' END) AS [Accounting Status],
						(SUM(CASE WHEN civ.volume IS NOT NULL THEN civ.volume ELSE NULL END)) [Volume],
						SUM(CAST(isnull(civ.[value], 0) AS Numeric(20,'+@round_value+'))) as [Amount],
						cur.currency_name as [Currency]
					'+@str_batch_table+'	
					FROM
						source_counterparty sc 
						'+CASE WHEN @show_recent_calculation = 'y' THEN	
						'OUTER APPLY(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id,invoice_type FROM calc_invoice_volume_variance WHERE counterparty_id=sc.source_counterparty_id'+ CASE WHEN  @as_of_date_from IS NOT NULL THEN ' AND as_of_date between '''+CAST(@as_of_date_from as VARCHAR)+''' AND '''+CAST(@as_of_date_to AS VARCHAR)+''''	ELSE '' END +' GROUP BY prod_date,counterparty_id,contract_id,invoice_type ) a
						INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=a.counterparty_id AND civv.contract_id=a.contract_id AND civv.prod_date=a.prod_date AND civv.as_of_date=a.as_of_date AND civv.invoice_type=a.invoice_type' 
						ELSE ' INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=sc.source_counterparty_id' END+'
						INNER JOIN calc_invoice_volume civ on civ.calc_id=civv.calc_id AND civ.apply_cash_calc_detail_id IS NULL
						LEFT JOIN  static_data_value charge_type ON charge_type.value_id=civ.invoice_line_item_id
						LEFT JOIN contract_group cg ON cg.contract_id=civv.contract_id
						LEFT join source_currency cur ON cur.source_currency_id=cg.currency
						LEFT JOIN netting_group ng ON ng.netting_group_id=civv.netting_group_id
						LEFT JOIN static_data_value ws ON ws.value_id = civv.invoice_status
				WHERE 1=1 '+@where_str
				+ CASE WHEN  @prod_date_from IS NOT NULL THEN ' AND civv.prod_date between '''+CAST(@prod_date_from as VARCHAR)+''' AND '''+CAST(@prod_date_to AS VARCHAR)+'''' ELSE '' END		
				+ CASE WHEN  @settlement_date_from IS NOT NULL THEN ' AND civv.settlement_date between '''+CAST(@settlement_date_from as VARCHAR)+''' AND '''+CAST(@settlement_date_to AS VARCHAR)+'''' ELSE '' END			
				+ CASE WHEN @invoice_type IS NOT NULL THEN ' AND civv.invoice_type = ''' + @invoice_type + '''' ELSE '' END
				+ CASE WHEN @workflow_status IS NOT NULL THEN ' AND civv.invoice_status = ''' + CAST(@workflow_status AS VARCHAR) + '''' ELSE '' END
				+ ' AND sc.int_ext_flag IN(''' + @counterparty_type + ''')'	
				+'GROUP BY civv.invoice_type,civv.counterparty_id,civv.as_of_date,civv.prod_date,charge_type.description,civv.settlement_date,cur.currency_name,ISNULL(ng.netting_group_name,cg.contract_name),ws.code,civv.payment_date'
				+' ORDER BY 1,2,3,4,5,6'

	END			
	ELSE IF @summary_option='c'
	BEGIN
		SET @sql_str='
					SELECT 
						dbo.fnadateformat(civv.as_of_date) as [As Of Date],
						dbo.fnadateformat(civ.prod_date) as [Deliver Month],
						dbo.fnadateformat(civv.settlement_date) as [Invoice Date],
						dbo.fnadateformat(civv.payment_date) [Payment Date],
						max(sc.counterparty_name) AS '+@cpt_clm_name+',
						max(ISNULL(ng.netting_group_name,cg.contract_name)) AS '+@contract_clm_name+',
						CASE WHEN civv.invoice_type = ''i'' THEN ''Invoice'' ELSE ''Remittance'' END AS [Invoice Type],
						ws.code [Workflow Status],
						charge_type.description AS [Charge Type],
							MAX(CASE WHEN civ.status =''v'' THEN ''Voided'' WHEN ISNULL(civ.finalized,''n'') =  ''y'' THEN ''Final'' ELSE ''Initial'' END) AS [Accounting Status],
						(SUM(CASE WHEN civ.volume IS NOT NULL THEN civ.volume ELSE NULL END)) [Volume],
						SUM(CAST(isnull(civ.[value], 0) AS Numeric(20,'+@round_value+'))) as [Amount],
						cur.currency_name as [Currency]
					'+@str_batch_table+'	
					FROM
						source_counterparty sc 
						'+CASE WHEN @show_recent_calculation = 'y' THEN	
						'OUTER APPLY(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id,invoice_type FROM calc_invoice_volume_variance WHERE counterparty_id=sc.source_counterparty_id'+ CASE WHEN  @as_of_date_from IS NOT NULL THEN ' AND as_of_date between '''+CAST(@as_of_date_from as VARCHAR)+''' AND '''+CAST(@as_of_date_to AS VARCHAR)+''''	ELSE '' END +' GROUP BY prod_date,counterparty_id,contract_id,invoice_type ) a
						INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=a.counterparty_id AND civv.contract_id=a.contract_id AND civv.prod_date=a.prod_date AND civv.as_of_date=a.as_of_date AND civv.invoice_type=a.invoice_type' 
						ELSE ' INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=sc.source_counterparty_id' END+'
						INNER JOIN calc_invoice_volume civ on civv.calc_id=civ.calc_id AND civ.apply_cash_calc_detail_id IS NULL
						LEFT JOIN  static_data_value charge_type ON charge_type.value_id=civ.invoice_line_item_id
						LEFT JOIN contract_group cg ON cg.contract_id=civv.contract_id
						LEFT join source_currency cur ON cur.source_currency_id=cg.currency
						LEFT JOIN netting_group ng ON ng.netting_group_id=civv.netting_group_id
						LEFT JOIN static_data_value ws ON ws.value_id = civv.invoice_status
				WHERE 1=1 '+@where_str
				+ CASE WHEN  @prod_date_from IS NOT NULL THEN ' AND civ.prod_date between '''+CAST(@prod_date_from as VARCHAR)+''' AND '''+CAST(@prod_date_to AS VARCHAR)+'''' ELSE '' END	
				+ CASE WHEN  @settlement_date_from IS NOT NULL THEN ' AND civv.settlement_date between '''+CAST(@settlement_date_from as VARCHAR)+''' AND '''+CAST(@settlement_date_to AS VARCHAR)+'''' ELSE '' END				
				+ CASE WHEN @invoice_type IS NOT NULL THEN ' AND civv.invoice_type = ''' + @invoice_type + '''' ELSE '' END
				+ CASE WHEN @workflow_status IS NOT NULL THEN ' AND civv.invoice_status = ''' + CAST(@workflow_status AS VARCHAR) + '''' ELSE '' END
				+ ' AND sc.int_ext_flag IN(''' + @counterparty_type + ''')'		
				+'GROUP BY civv.invoice_type,civv.counterparty_id,civv.as_of_date,civ.prod_date,charge_type.description,civv.settlement_date,cur.currency_name,ISNULL(ng.netting_group_name,cg.contract_name),ws.code,civv.payment_date'
				+' ORDER BY 1,2,3,4,5,6'
	END			
	ELSE IF @summary_option='d'
	BEGIN
		SET @sql_str='
					SELECT 
						dbo.fnadateformat(civv.as_of_date) as [As of Date],
						max(sc.counterparty_name) AS '+@cpt_clm_name+',
						ISNULL(ng.netting_group_name,cg.contract_name) AS '+@contract_clm_name+',
						CASE WHEN civv.invoice_type = ''i'' THEN ''Invoice'' ELSE ''Remittance'' END AS [Invoice Type],
						ws.code [Workflow Status],
						dbo.fnadateformat(civ.prod_date) as [Deliver Month],
						dbo.fnadateformat(civv.settlement_date) as [Invoice Date],
						dbo.fnadateformat(civv.payment_date) [Payment Date],
						charge_type.description AS [Charge Type],
						MAX(CASE WHEN civ.status =''v'' THEN ''Voided'' WHEN ISNULL(civ.finalized,''n'') =  ''y'' THEN ''Final'' ELSE ''Initial'' END) AS [Accounting Status],
						(SUM(CASE WHEN civ.volume IS NOT NULL THEN civ.volume ELSE NULL END)) [Volume],
						SUM(CAST(isnull(civ.[value], 0) AS Numeric(20,'+@round_value+'))) as [Amount],
						MAX(cur.currency_name) as [Currency]
					'+@str_batch_table+'	
					FROM
						source_counterparty sc 
						'+CASE WHEN @show_recent_calculation = 'y' THEN	
						'OUTER APPLY(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id,invoice_type FROM calc_invoice_volume_variance WHERE counterparty_id=sc.source_counterparty_id'+ CASE WHEN  @as_of_date_from IS NOT NULL THEN ' AND as_of_date between '''+CAST(@as_of_date_from as VARCHAR)+''' AND '''+CAST(@as_of_date_to AS VARCHAR)+''''	ELSE '' END +' GROUP BY prod_date,counterparty_id,contract_id,invoice_type ) a
						INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=a.counterparty_id AND civv.contract_id=a.contract_id AND civv.prod_date=a.prod_date AND civv.as_of_date=a.as_of_date AND civv.invoice_type=a.invoice_type' 
						ELSE ' INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=sc.source_counterparty_id' END+'
						INNER JOIN calc_invoice_volume civ on civv.calc_id=civ.calc_id AND civ.apply_cash_calc_detail_id IS NULL
						LEFT JOIN  static_data_value charge_type ON charge_type.value_id=civ.invoice_line_item_id
						LEFT JOIN contract_group cg ON cg.contract_id=civv.contract_id
						LEFT join source_currency cur ON cur.source_currency_id=cg.currency
						LEFT JOIN netting_group ng ON ng.netting_group_id=civv.netting_group_id
						LEFT JOIN static_data_value ws ON ws.value_id = civv.invoice_status
				WHERE 1=1 '+@where_str
				+ CASE WHEN  @prod_date_from IS NOT NULL THEN ' AND civ.prod_date between '''+CAST(@prod_date_from as VARCHAR)+''' AND '''+CAST(@prod_date_to AS VARCHAR)+'''' ELSE '' END	
				+ CASE WHEN  @settlement_date_from IS NOT NULL THEN ' AND civv.settlement_date between '''+CAST(@settlement_date_from as VARCHAR)+''' AND '''+CAST(@settlement_date_to AS VARCHAR)+'''' ELSE '' END			
				+ CASE WHEN @invoice_type IS NOT NULL THEN ' AND civv.invoice_type = ''' + @invoice_type + '''' ELSE '' END
				+ CASE WHEN @workflow_status IS NOT NULL THEN ' AND civv.invoice_status = ''' + CAST(@workflow_status AS VARCHAR) + '''' ELSE '' END
				+ ' AND sc.int_ext_flag IN(''' + @counterparty_type + ''')'	
				+'GROUP BY civv.invoice_type,civv.counterparty_id,civv.as_of_date,civ.prod_date,civv.settlement_date,ISNULL(ng.netting_group_name,cg.contract_name),charge_type.description,ws.code,civv.payment_date'
				+' ORDER BY 1,2,3,4,5,6'

	END			
	ELSE IF @summary_option='f'
	BEGIN
		IF @drill_Counterparty IS NOT NULL
			SELECT @counterparty_id=source_counterparty_id FROM source_counterparty WHERE counterparty_name=@drill_Counterparty

		IF @drill_Contract IS NOT NULL
			SELECT @contract_id=contract_id FROM contract_group WHERE contract_name=@drill_Contract
		SET @sql_str='
			select 
					 max(dbo.FNACONTRACTMONTHFORMAT(cfv.prod_date)) [Production Month],  
					 ISNULL(fn.sequence_order,1) [Row No],
					 ISNULL(description1,sd.description) [Desc1],  
					 ISNULL(description2,sd.description) [Desc2],  
					 dbo.fnaformulaformat(fe.formula,''r'') [Formula],SUM(cfv.value) [Value] 
				'+@str_batch_table+'	  
				 from   
					 '+@table_calc_formula_value+' cfv   
					 LEFT join   formula_nested fn  on fn.formula_group_id=cfv.formula_id and fn.sequence_order=cfv.seq_number  
					 left join formula_editor fe on fe.formula_id=ISNULL(fn.formula_Id,cfv.formula_id)  
					 INNER join '+@table_calc_invoice_volume+' civ on civ.calc_id=cfv.calc_id AND civ.apply_cash_calc_detail_id IS NULL 
					 INNER join '+@table_calc_invoice_volume_variance+' civv ON civv.calc_id=cfv.calc_id 
					 and civ.invoice_line_item_id=cfv.invoice_Line_item_id  and isnull(civ.manual_input,''n'')=''n''
					 inner join static_data_value sd on sd.value_id=civ.invoice_line_item_id      
				where  
					 civv.counterparty_id='+CAST(@counterparty_id AS VARCHAR)+'
					 and (cfv.prod_date)=('''+CAST(@drill_prod_month AS VARCHAR)+''')   
					 AND civv.as_of_date=dbo.fnagetcontractmonth('''+CAST(@drill_as_of_date AS VARCHAR)+''')	
					 and sd.description='''+@drill_line_item+''' 
				group by   
					 fn.sequence_order,ISNULL(description2,sd.description),
					 ISNULL(description1,sd.description),dbo.fnaformulaformat(fe.formula,''r'')  
				 order by   
				 fn.sequence_order '
		EXEC(@sql_str)	 
	END
	ELSE IF @summary_option='z'
	BEGIN
		
			SELECT source_deal_header_id,
			       term_start,
			       MAX(COALESCE(float_price,0.00)) float_price,
			       MAX(COALESCE(deal_price,0.00)) deal_price 
			INTO #tmp_ddd
			FROM   source_deal_settlement
			WHERE
				((set_type = 's' AND @as_of_date_to>=term_end) OR (set_type = 'f' AND as_of_date = @as_of_date_to))
			GROUP BY source_deal_header_id, term_start

		 
		
		DECLARE @where_str1 VARCHAR(MAX)
	
		SET @where_str1 = CASE WHEN  @as_of_date_from IS NOT NULL THEN ' AND civv.as_of_date between '''+CAST(@as_of_date_from as VARCHAR)+''' AND '''+CAST(@as_of_date_to AS VARCHAR)+''''	ELSE '' END			
							+ CASE WHEN  @prod_date_from IS NOT NULL THEN ' AND c.prod_date between '''+CAST(@prod_date_from as VARCHAR)+''' AND '''+CAST(@prod_date_to AS VARCHAR)+''''	ELSE '' END	
							+ CASE WHEN  @counterparty_id IS NOT NULL THEN ' AND c.counterparty_id IN('+@counterparty_id+')' ELSE '' END
							+ CASE WHEN  @contract_id IS NOT NULL THEN ' AND c.contract_id IN('+@contract_id+')' ELSE '' END
							+ CASE WHEN @deal_id IS NOT NULL THEN ' AND ISNULL(sdh1.source_deal_header_id,sdh.source_deal_header_id) IN (SELECT deal_id FROM #temp) ' ELSE '' END 
							+ CASE WHEN @ref_id IS NOT NULL THEN ' AND ISNULL(sdh1.deal_id,sdh.deal_id) = ''' + CAST(@ref_id AS VARCHAR(50)) + '''' ELSE '' END 
							
		SET @sql_str='SELECT sc.counterparty_name [Counterparty Name], CONVERT(VARCHAR(7), c.prod_date, 120) [Month],
		                     --dbo.FNAHyperLinkText(10131024,CAST(ISNULL(sdh1.source_deal_header_id,sdh.source_deal_header_id) AS VARCHAR), ISNULL(sdh1.source_deal_header_id,sdh.source_deal_header_id))
		                     ISNULL(sdh1.source_deal_header_id,sdh.source_deal_header_id)  [Deal ID],
		                     MAX(ISNULL(sdh1.deal_id,sdh.deal_id)) [Ref ID],     
		                     ref.source_deal_header_id [Parent ID],
		                     CASE COALESCE(sdd.buy_sell_flag,sdd1.buy_sell_flag,mx.buy_sell_flag) WHEN ''b'' THEN ''Buy'' WHEN ''s'' THEN ''Sell'' ELSE NULL END [Buy/Sell],
		                     sdv.code [Category], sml.Location_Name Location,MAX(sdv_reg.code) Region,
		                     dbo.fnadateformat(COALESCE(sdd.Term_start,sdd1.Term_start, CONVERT(VARCHAR(7), c.prod_date, 120)+''-01'')) [Term Start],
		                     dbo.fnadateformat(COALESCE(sdd.Term_end,sdd1.Term_end,DATEADD(MONTH,1,CONVERT(VARCHAR(7), c.prod_date, 120)+''-01'')-1 )) [Term End],
		                     cg.contract_name Contract,ct.code [Charge Type],
		                     SUM(COALESCE(sdd.standard_yearly_volume,sdd1.standard_yearly_volume,mx.standard_yearly_volume)*CASE WHEN COALESCE(sdd.buy_sell_flag,sdd1.buy_sell_flag,mx.buy_sell_flag)=''s'' THEN -1 ELSE 1 END *ISNULL(conv2.conversion_factor,1)) SYV,
		                     CASE WHEN COALESCE(sdd.buy_sell_flag,sdd1.buy_sell_flag,mx.buy_sell_flag)=''s'' THEN -1 ELSE 1 END *
		                     SUM(COALESCE(sdd.deal_volume,sdd1.deal_volume,mx_term.deal_volume)*ISNULL(conv2.conversion_factor,1)) [Contracted Volume],
		                     CASE WHEN COALESCE(sdd.buy_sell_flag,sdd1.buy_sell_flag,mx.buy_sell_flag)=''s'' THEN -1 ELSE 1 END *SUM(COALESCE(sdd.total_volume,sdd1.total_volume)*ISNULL(conv.conversion_factor,1)) [Forecasted Volume],
		                     SUM(sds.allocation_volume*ISNULL(conv1.conversion_factor,1)) [Allocated Volume],	SUM(c.volume) [Settlement Volume],
		                     --SUM(CASE WHEN ISNULL(sdh1.source_deal_type_id,sdh.source_deal_type_id) = 2 AND ct.code=''Commodity'' THEN sds.volume*ISNULL(uc.conversion_factor,1) ELSE 0 END+ISNULL(cfv1.value,0)*ISNULL(uc1.conversion_factor,1)) [PNL Volume],		                     
		                     SUM(CASE WHEN fn.formula_group_id IS NOT NULL THEN ISNULL(c.volume,0)*ISNULL(uc1.conversion_factor,1) ELSE NULL END) [PNL Volume],		
		                     --MAX(ssu.uom_name) SettlementVolumeUOM,
		                     ISNULL(MAX(ssu_fn.uom_name), MAX(ssu.uom_name)) [Settlement Volume UOM],
		                     
		                     CASE ISNULL(sdh1.physical_financial_flag,sdh.physical_financial_flag) WHEN  ''f'' THEN ''Fin'' WHEN ''p'' THEN ''Phys''                          
		                          ELSE NULL  END [Phys/Fin],
		                     CASE WHEN ISNULL(sdh1.physical_financial_flag,sdh.physical_financial_flag)= ''p''
		                      THEN CASE WHEN  MAX(COALESCE(sdd.formula_id,sdd1.formula_id,mx.formula_id)) IS  NULL THEN ISNULL(MAX(sds.deal_price),MAX(sds1.deal_price)) ELSE NULL  END
		                      ELSE  ISNULL(MAX(sds.deal_price),MAX(sds1.deal_price)) END/ISNULL(NULLIF(MAX(ISNULL(conv1.conversion_factor,1)),0),1) [Fixed Price],
							 CASE WHEN  MAX(COALESCE(sdd.formula_id,sdd1.formula_id,mx.formula_id)) IS  NULL THEN NULL ELSE
							 NULLIF(ROUND(CASE WHEN COALESCE(sdd.buy_sell_flag, sdd1.buy_sell_flag, mx.buy_sell_flag) = ''s'' THEN
								 ABS((SUM(c.value)-ISNULL(CASE WHEN ISNULL(sdh1.physical_financial_flag,sdh.physical_financial_flag)= ''p''
								  THEN CASE WHEN  MAX(COALESCE(sdd.formula_id,sdd1.formula_id,mx.formula_id)) IS  NULL THEN ISNULL(MAX(sds.deal_price),MAX(sds1.deal_price)) ELSE NULL  END
								  ELSE  ISNULL(MAX(sds.deal_price),MAX(sds1.deal_price)) END,0)/ISNULL(NULLIF(MAX(ISNULL(conv1.conversion_factor,1)),0),1)* ABS(SUM(c.volume)))/ISNULL(NULLIF(SUM(c.volume),0),1))
							 ELSE
								 ABS((SUM(c.value)+ISNULL(CASE WHEN ISNULL(sdh1.physical_financial_flag,sdh.physical_financial_flag)= ''p''
								  THEN CASE WHEN  MAX(COALESCE(sdd.formula_id,sdd1.formula_id,mx.formula_id)) IS  NULL THEN ISNULL(MAX(sds.deal_price),MAX(sds1.deal_price)) ELSE NULL  END
								  ELSE  ISNULL(MAX(sds.deal_price),MAX(sds1.deal_price)) END,0)/ISNULL(NULLIF(MAX(ISNULL(conv1.conversion_factor,1)),0),1)* ABS(SUM(c.volume)))/ISNULL(NULLIF(SUM(c.volume),0),1))
							END,6),0) END [Floating Price],															 
							 ABS(SUM(c.value)/ISNULL(NULLIF(SUM(c.volume),0),1)) [Settlement Price],
							 MAX(scur.currency_name) [Price Currency],
		                     MAX(CASE WHEN ISNULL(cgd.timeofuse,18900)=18900 THEN ISNULL(sdh1.description1,sdh.description1) ELSE ISNULL(sdh1.description2,sdh.description2) END) [Floating Price Formula],
		                     SUM(c.value) [Settlement EUR]
		              '+@str_batch_table+' 
		              FROM   
					  	 source_counterparty sc 
							'+CASE WHEN @show_recent_calculation = 'y' THEN	
							'OUTER APPLY(SELECT MAX(as_of_date) as_of_date,prod_date,counterparty_id,contract_id,invoice_type FROM calc_invoice_volume_variance WHERE counterparty_id=sc.source_counterparty_id'+ CASE WHEN  @as_of_date_from IS NOT NULL THEN ' AND as_of_date between '''+CAST(@as_of_date_from as VARCHAR)+''' AND '''+CAST(@as_of_date_to AS VARCHAR)+''''	ELSE '' END +' GROUP BY prod_date,counterparty_id,contract_id,invoice_type ) a
							INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=a.counterparty_id AND civv.contract_id=a.contract_id AND civv.prod_date=a.prod_date AND civv.as_of_date=a.as_of_date AND civv.invoice_type=a.invoice_type' 
							ELSE ' INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=sc.source_counterparty_id' END+'
								 INNER JOIN calc_formula_value c ON civv.calc_id=c.calc_id
							 LEFT JOIN calc_invoice_volume civ ON civ.calc_id=c.calc_id AND civ.invoice_line_item_id=c.invoice_line_item_id AND civ.apply_cash_calc_detail_id IS NULL
		                     LEFT JOIN source_deal_header sdh ON  sdh.source_deal_header_id = ISNULL(c.source_deal_header_id,-1)
		                     
		                     LEFT JOIN source_deal_detail sdd ON  sdd.source_deal_detail_id = ISNULL(c.deal_id,-1)
		                     LEFT JOIN source_deal_header sdh1 ON  sdh1.source_deal_header_id = sdd.source_deal_header_id
		                     LEFT JOIN contract_group_detail cgd ON c.invoice_line_item_id=cgd.invoice_line_item_id
								 AND  c.contract_id=cgd.contract_id AND  cgd.Prod_type=''P''
							 OUTER APPLY(SELECT source_deal_header_id,MAX(leg) leg,MAX(buy_sell_flag) buy_sell_flag,Term_start,Term_end,SUM(standard_yearly_volume) standard_yearly_volume,SUM(deal_volume) deal_volume,SUM(total_volume) total_volume,MAX(formula_id) formula_id,MAX(category) category,MAX(location_id) location_id,MAX(curve_id) curve_id,MAX(profile_code) profile_code 
									FROM source_deal_detail sdd1 WHERE  sdd1.source_deal_header_id = sdh.source_deal_header_id
									AND sdd1.term_start=civv.prod_date GROUP BY source_deal_header_id,Term_start,Term_end) sdd1									
							 LEFT JOIN (SELECT source_deal_header_id,MAX(buy_sell_flag) buy_sell_flag ,MAX(category)  category,MAX(formula_id) formula_id,MAX(standard_yearly_volume) standard_yearly_volume	FROM source_deal_detail
									GROUP BY source_deal_header_id
									) mx ON mx.source_deal_header_id=ISNULL(sdh1.source_deal_header_id,sdh.source_deal_header_id)'
					SET @sql_str2 = ' LEFT JOIN (SELECT source_deal_header_id,CONVERT(VARCHAR(7),term_start,120)  term_start,SUM(deal_volume) deal_volume ,SUM(total_volume) total_volume FROM source_deal_detail
									GROUP BY source_deal_header_id,CONVERT(VARCHAR(7),term_start,120)
									) mx_term ON mx_term.source_deal_header_id=ISNULL(sdh1.source_deal_header_id,sdh.source_deal_header_id)	AND mx_term.term_start=	CONVERT(VARCHAR(7),c.prod_date,120)	
		                    '+CASE WHEN @show_recent_calculation = 'y' THEN 
		                    'OUTER APPLY(SELECT max(as_of_date) as_of_date,source_deal_header_id,SUM(volume) volume,MAX(deal_price) deal_price,MAX(volume_uom) volume_uom,SUM(allocation_volume) allocation_volume
								  FROM source_deal_settlement  WHERE  source_deal_header_id = ISNULL(sdd.source_deal_header_id,sdd1.source_deal_header_id)
		                          AND term_start=ISNULL(sdd.term_start,sdd1.term_start)
		                          AND ((set_type = ''s'' ) OR (set_type = ''f''))
		                          AND leg = ISNULL(sdd.leg,leg) GROUP BY source_deal_header_id ) sds' ELSE '
		                    OUTER APPLY(SELECT source_deal_header_id,SUM(volume) volume,MAX(deal_price) deal_price,MAX(volume_uom) volume_uom,SUM(allocation_volume) allocation_volume
								  FROM source_deal_settlement  WHERE  source_deal_header_id = ISNULL(sdd.source_deal_header_id,sdd1.source_deal_header_id)
		                          AND term_start=ISNULL(sdd.term_start,sdd1.term_start)
		                          AND ((set_type = ''s'' AND '''+CAST(@as_of_date_to AS VARCHAR)+'''>=term_end) OR (set_type = ''f'' AND as_of_date = '''+CAST(@as_of_date_to AS VARCHAR)+'''))
		                          AND leg = ISNULL(sdd.leg,leg) GROUP BY source_deal_header_id) sds' END + '
							 LEFT JOIN #tmp_ddd sds1 ON sds1.source_deal_header_id=c.source_deal_header_id AND sds1.term_start=CONVERT(VARCHAR(8),c.prod_date,120)+''01''
							 LEFT JOIN source_deal_header REF ON  ref.source_deal_header_id = ISNULL(sdh1.close_reference_id,sdh.close_reference_id)
		                     LEFT JOIN static_data_value sdv ON  sdv.value_id = COALESCE(sdd.category,sdd1.category,mx.category)
		                     LEFT JOIN contract_group cg ON  c.contract_id = cg.contract_id
		                     LEFT JOIN static_data_value ct ON  ct.value_id = c.invoice_line_item_id
		                     LEFT JOIN source_uom ssu ON  ssu.source_uom_id = cg.volume_uom
		                     
		                     LEFT JOIN source_currency scur ON  cg.currency = scur.source_currency_id
		                     LEFT JOIN source_minor_Location sml ON sml.source_minor_location_id=ISNULL(sdd.location_id,sdd1.location_id)
		                     LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id=ISNULL(sdd.curve_id,sdd1.curve_id)
		                     LEFT JOIN rec_volume_unit_conversion conv ON  conv.from_source_uom_id = sds.volume_uom
								AND conv.to_source_uom_id = cg.volume_uom
		                     LEFT JOIN rec_volume_unit_conversion conv1 ON  conv1.from_source_uom_id = spcd.display_uom_id
								AND conv1.to_source_uom_id = cg.volume_uom	
							 LEFT JOIN rec_volume_unit_conversion conv2 ON  conv2.from_source_uom_id = sdd.deal_volume_uom_id
								AND conv2.to_source_uom_id = cg.volume_uom	
							 LEFT JOIN static_data_value sdv_reg ON sdv_reg.value_id=COALESCE(sml.region,sdd.profile_code,sdd1.profile_code)							
							 LEFT JOIN formula_nested fn ON fn.formula_group_id = c.formula_id AND fn.show_value_id=1206							 
							 LEFT JOIN formula_nested fn_uom ON fn_uom.formula_group_id = c.formula_id AND fn_uom.show_value_id IS NOT NULL 
							 LEFT JOIN source_uom ssu_fn ON  ssu_fn.source_uom_id = fn_uom.uom_id
							 
							 LEFT JOIN  calc_formula_value cfv1 ON c.calc_id=cfv1.calc_id						
								AND cfv1.invoice_line_item_id=c.invoice_line_item_id
								AND cfv1.formula_id = fn.formula_group_id
								AND cfv1.seq_number=fn.sequence_order
								AND ISNULL(cfv1.source_deal_header_id,-1)=ISNULL(c.source_deal_header_id,-1)
								AND ISNULL(cfv1.deal_id,-1)=ISNULL(c.deal_id,-1)
								AND ISNULL(cgd.include_charges,''n'') = ''y''
							LEFT JOIN rec_volume_unit_conversion uc on uc.from_source_uom_id=spcd.display_uom_id AND uc.to_source_uom_id='+CAST(@convert_uom AS VARCHAR) +'
							LEFT JOIN rec_volume_unit_conversion uc1 on uc1.from_source_uom_id=civv.UOM AND uc1.to_source_uom_id='+CAST(@convert_uom AS VARCHAR) +'	
		              WHERE  c.is_final_result=''y''
		              ' 
		            IF EXISTS(SELECT 1 FROM #temp)
		            BEGIN
		            	SET @sql_str2 = @sql_str2 + ' AND ISNULL(sdh1.source_deal_header_id,sdh.source_deal_header_id) IN (SELECT deal_id FROM #temp) '
		            END
					SET @group_by = 
					' GROUP BY sc.counterparty_name, 
								CONVERT(VARCHAR(7), c.prod_date, 120),
								ISNULL(sdh1.source_deal_header_id, sdh.source_deal_header_id), 
								ref.source_deal_header_id, 
								sdv.code,
								COALESCE(sdd.Term_start, sdd1.Term_start, CONVERT(VARCHAR(7), c.prod_date, 120)+''-01''),
								COALESCE(sdd.Term_end, sdd1.Term_end, dateadd(month, 1, CONVERT(VARCHAR(7), c.prod_date, 120)+''-01'')-1 ),
								cg.contract_name, 
								ct.code, 
								ISNULL(sdh1.physical_financial_flag, sdh.physical_financial_flag),
								sml.Location_Name, 
								COALESCE(sdd.buy_sell_flag, sdd1.buy_sell_flag, mx.buy_sell_flag)'           
		              
	END 
	
	EXEC spa_print @sql_str 
	EXEC spa_print @sql_str2 
	EXEC spa_print @where_str1
	EXEC spa_print @group_by
	
	
	EXEC(@sql_str + @sql_str2+@where_str1+@group_by)
	
END
	
	
/*******************************************2nd Paging Batch START**********************************************/
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)

   --TODO: modify sp and report name
   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_run_settlement_invoice_report', 'Contract Settlement Report')
   EXEC(@sql_paging)  

   RETURN
END

--if it is first call from paging, return total no. of rows and process id instead of actual data
IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END
/*******************************************2nd Paging Batch END**********************************************/






