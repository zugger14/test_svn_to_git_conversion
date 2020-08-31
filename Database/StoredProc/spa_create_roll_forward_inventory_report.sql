
/****** Object:  StoredProcedure [dbo].[spa_create_roll_forward_inventory_report]    Script Date: 12/15/2010 23:10:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_create_roll_forward_inventory_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_create_roll_forward_inventory_report]
/****** Object:  StoredProcedure [dbo].[spa_create_roll_forward_inventory_report]    Script Date: 12/15/2010 23:10:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec spa_run_wght_avg_inventory_cost_report 135, '5/31/2001', '6/30/2006'

CREATE PROCEDURE [dbo].[spa_create_roll_forward_inventory_report] 
				@summary_option CHAR(1)='s',
				@as_of_date_from datetime,
				@as_of_date_to datetime = null,
				@gl_account_id VARCHAR(100)=NULL,
				@gl_code INT=NULL,
				@inventory_group_id INT=NULL,
				@report_option CHAR(1)='f',
				@drill_as_of_date VARCHAR(100)=null,
				@group_name VARCHAR(100)=null,
				@drill_account_name VARCHAR(100)=null,
				@drill_gl_name VARCHAR(100)=null,
				@drill_term VARCHAR(100)=NULL,
				
				@batch_process_id VARCHAR(50) = NULL,  
				@batch_report_param VARCHAR(500) = NULL,   
				@enable_paging INT = 0,  --'1'=enable, '0'=disable  
				@page_size INT = NULL,  
				@page_no INT = NULL  
					

AS
SET NOCOUNT ON 

DECLARE @sql VARCHAR(8000)
DECLARE @str_batch_table VARCHAR(8000)
DECLARE @user_login_id VARCHAR(50)
DECLARE @sql_paging VARCHAR(8000)
DECLARE @is_batch bit


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

IF @as_of_date_from IS NOT NULL
   AND @as_of_date_to IS NULL
    SET @as_of_date_to = @as_of_date_from

IF @as_of_date_from IS NULL
   AND @as_of_date_to IS NOT NULL
    SET @as_of_date_from = @as_of_date_to

DECLARE @wght_avg_cost_group_by INT

--DEFAULT WGHT AVG COST GROUPING APPROACH: 0 means jurisdiction-> 1 means by jurisdiction, state -> 2 means jurisdiction, state, technology



CREATE TABLE #ssbm(
		fas_book_id int,
		stra_book_id int,
		sub_entity_id int
	)
	----------------------------------
	SET @sql=
	'INSERT INTO #ssbm
	SELECT
		 book.entity_id fas_book_id,book.parent_entity_id stra_book_id, stra.parent_entity_id sub_entity_id 
	FROM
		source_system_book_map ssbm 
	INNER JOIN
		portfolio_hierarchy book (nolock) 
	ON	
		 ssbm.fas_book_id = book.entity_id 
	INNER JOIN
		Portfolio_hierarchy stra (nolock)
	 ON
		 book.parent_entity_id = stra.entity_id 

	WHERE 1=1 '

	EXEC(@sql)

CREATE TABLE #wacog(
	[id] INT IDENTITY(1,1),
	[Inventory_Group] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[Inventory_Name] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[GL_Name] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[GL_Code] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[as_of_date] DATETIME,
	[term] DATETIME,
	[Inventory_Value] NUMERIC(38,6),
	[Units] NUMERIC(38,6),
	[Wght_Avg_Cost] NUMERIC(38,6),
	[gl_account_id] INT,
	[UOM] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	Currency VARCHAR(20) COLLATE DATABASE_DEFAULT
)

CREATE TABLE #wacog_pre(
	[Inventory_Group] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[Inventory_Name] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[GL_Name] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[GL_Code] VARCHAR(100) COLLATE DATABASE_DEFAULT,
	[as_of_date] DATETIME,
	[term]  DATETIME,
	[Inventory_Value] NUMERIC(38,6),
	[Units] NUMERIC(38,6),
	[Wght_Avg_Cost] NUMERIC(38,6),
	[gl_account_id] INT
)


	SET @sql= 'INSERT INTO #wacog([Inventory_Group],[Inventory_Name],[GL_Name],[GL_Code],[as_of_date],[term],[Inventory_Value],[Units],[Wght_Avg_Cost],[gl_account_id],[UOM],Currency)
				SELECT [Group],[Inventory Name],[GL Name],[GL Code],[Date],[Term],[Inventory],[Units],[Wght Avg Cost],gl_account_id,uom_id,currency_name FROM('
	IF @report_option = 'a' AND @drill_term IS NULL
		SET @sql= @sql +' SELECT 	
			iatg.group_name AS [Group],
			glact.account_type_name AS [Inventory Name],
			gsm.gl_account_name [GL Name],
			gsm.gl_account_number [GL Code],
			(wavg.as_of_date) [Date],
			NULL AS [Term],
			wavg.total_inventory [Inventory],
			wavg.total_units [Units],
			wavg.wght_avg_cost [Wght Avg Cost],
			glact.gl_account_id,
			su.uom_id,
			sc.currency_name	
		FROM  
			inventory_account_type glact
			LEFT  JOIN calcprocess_inventory_wght_avg_cost wavg on wavg.gl_account_id=glact.gl_account_id 
			LEFT JOIN static_data_value sdv on sdv.value_id=glact.account_type_value_id
			LEFT JOIN gl_system_mapping gsm on gsm.gl_number_id=glact.gl_number_id
			LEFT JOIN inventory_account_type_group iatg ON glact.group_id=iatg.group_id
			LEFT JOIN source_uom su ON su.source_uom_id=wavg.uom_id
			LEFT JOIN source_currency sc ON sc.source_currency_id=wavg.currency_id
		WHERE	1=1
		AND (as_of_date) between ('''+CAST(@as_of_date_from AS VARCHAR(20))+''') and ('''+CAST(@as_of_date_to AS VARCHAR(20))+''') '
		+CASE WHEN @gl_account_id IS NOT NULL THEN ' AND glact.gl_account_id='''+@gl_account_id+'''' ELSE '' END
		+CASE WHEN @gl_code IS NOT NULL THEN ' AND glact.gl_number_id='+CAST(@gl_code AS VARCHAR) ELSE '' END
		+CASE WHEN @inventory_group_id IS NOT NULL THEN ' AND glact.group_id='+CAST(@inventory_group_id AS VARCHAR) ELSE '' END
		+CASE WHEN @drill_as_of_date IS NOT NULL THEN ' AND as_of_date='''+@drill_as_of_date+'''' ELSE '' END
		+CASE WHEN @drill_account_name IS NOT NULL THEN ' AND account_type_name='''+@drill_account_name+'''' ELSE '' END
		+' UNION ALL'

		
	SET @sql=@sql+
		'
		select 	
			iatg.group_name AS [Group],
			glact.account_type_name AS [Inventory Name],
			gsm.gl_account_name [GL Name],
			gsm.gl_account_number [GL Code],
			(wavg.as_of_date) [Date],
			(wavg.term_date) AS [Term],
			wavg.total_inventory [Inventory],
			wavg.total_units [Units],
			wavg.wght_avg_cost [Wght Avg Cost],
			glact.gl_account_id,
			su.uom_id,
			sc.currency_name		
		FROM  
			inventory_account_type glact
			LEFT  JOIN calcprocess_inventory_wght_avg_cost_forward wavg on wavg.gl_account_id=glact.gl_account_id 
			LEFT JOIN static_data_value sdv on sdv.value_id=glact.account_type_value_id
			LEFT JOIN gl_system_mapping gsm on gsm.gl_number_id=glact.gl_number_id
			LEFT JOIN inventory_account_type_group iatg ON glact.group_id=iatg.group_id
			LEFT JOIN source_uom su ON su.source_uom_id=wavg.uom_id
			LEFT JOIN source_currency sc ON sc.source_currency_id=wavg.currency_id
		WHERE	1=1
		AND (as_of_date) between ('''+CAST(@as_of_date_from AS VARCHAR(20))+''') and ('''+CAST(@as_of_date_to AS VARCHAR(20))+''') '
		+CASE WHEN @gl_account_id IS NOT NULL THEN ' AND glact.gl_account_id='''+@gl_account_id+'''' ELSE '' END
		+CASE WHEN @gl_code IS NOT NULL THEN ' AND glact.gl_number_id='+CAST(@gl_code AS VARCHAR) ELSE '' END
		+CASE WHEN @inventory_group_id IS NOT NULL THEN ' AND glact.group_id='+CAST(@inventory_group_id AS VARCHAR) ELSE '' END
		+CASE WHEN @drill_as_of_date IS NOT NULL THEN ' AND as_of_date='''+@drill_as_of_date+'''' ELSE '' END
		+CASE WHEN @drill_term IS NOT NULL  THEN ' AND wavg.term_date='''+@drill_term+'''' ELSE '' END
		+CASE WHEN @drill_account_name IS NOT NULL THEN ' AND account_type_name='''+@drill_account_name+'''' ELSE '' END
		+'
		) a
		ORDER BY [Inventory Name], [GL Name],[Date],[Term]'
	--print @sql
	EXEC(@sql)

	IF @summary_option='s'
		BEGIN
			DECLARE @sql_select VARCHAR(MAX)
			
			SET @sql_select = 'SELECT 
								dbo.FNADATEFORMAT(cur.as_of_date)[As of Date],
								cur.[Inventory_Group] AS [Inventory Group],
								cur.[Inventory_Name] AS [Inventory Name],
								dbo.FNADATEFORMAT(cur.[term])[Term],
								pre.[Units] AS [Prior Volume],
								--pre.[Inventory_Value][Prior Inventory Value],
								pre.[inventory_Value] AS [Prior Inventory Value],
								pre.[Wght_Avg_Cost][Prior WACOG],
								ISNULL(cur.[Units],0)-ISNULL(pre.[Units],0) AS [Current Volume],
								cur.[Units] [Total Volume],
								--ISNULL(cur.[Units],0)+ISNULL(pre.[Units],0) AS [Volume],
								cur.[UOM] AS [UOM],
								ISNULL(cur.[Inventory_Value],0)-ISNULL(pre.[Inventory_Value],0) [Current Inventory Value],
								ISNULL(cur.[Inventory_Value],0) AS [Total Inventory Value],
								cur.[Wght_Avg_Cost] AS [WACOG],
								cur.[Currency]
								--cur.[Wght_Avg_Cost] AS [WACOG]
								'+@str_batch_table+'				
								FROM
									#wacog cur
									LEFT JOIN #wacog pre ON cur.[id]-1=pre.[id]
									AND cur.[gl_account_id] = pre.gl_account_id'
				--LEFT JOIN (SELECT SUM(Inventory_Value),[gl_account_id] FROM #wacog GROUP BY [gl_account_id] WHERE ) net
				--LEFT JOIN (SELECT gl_account_id,[Units],[Wght_Avg_Cost],[Inventory_Value] FROM #wacog_pre ) pre
				-- ON a.gl_account_id=pre.gl_account_id
			--PRINT @sql_select
			EXEC (@sql_select)
		END
	ELSE IF @summary_option='d'
		BEGIN
			SET @sql='
				SELECT
					dbo.FNADATEFORMAT(a.as_of_date)[As of Date],
					a.[Inventory_Group] AS [Inventory Group],
					a.[Inventory_Name] AS [Inventory Name],
					dbo.FNAHyperLinkText(10131010, cid.source_deal_header_id,cid.source_deal_header_id) [Deal ID],
					dbo.FNADATEFORMAT(cid.term_date)[Term],
					cid.[Units] [Volume],
					[UOM] AS [UOM],
					ISNULL(sd.code,CASE WHEN sdh.header_buy_sell_flag=''b'' THEN ''Buy'' Else ''Sell'' END) AS [Activity Type],				
					--a.[Wght_Avg_Cost] AS [Inventory Cost],
					cid.[Inventory]/ISNULL(NULLIF(cid.[Units],0),1)  AS [Inventory Cost],
					cid.[Inventory] AS [Inventory Value]' + @str_batch_table + '				
				FROM
					#wacog a
					INNER JOIN calcprocess_inventory_deals cid ON a.gl_account_id=cid.gl_account_id
						AND a.as_of_date=cid.as_of_date
						AND a.term =(cid.term_date)
					'+CASE WHEN @drill_term IS NULL THEN ' AND cid.calc_type = ''s'' ' ELSE ' AND cid.calc_type = ''f''' END+'	
					LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id=cid.source_deal_header_id
					LEFT JOIN static_data_value sd ON sd.value_id=sdh.assignment_type_value_id
				ORDER BY 
					sdh.source_deal_header_id, cid.term_date
				'	
			EXEC(@sql)
		END
	ELSE IF @summary_option='a'
		BEGIN
			DECLARE @sql_select1 VARCHAR(MAX)
			
			SET @sql_select1 = '
			SELECT
				a.[Inventory_Name] AS [Inventory Name],
				dbo.FNADATEFORMAT(a.as_of_date)[Date],
				a.[Inventory_Value] AS [Inventory Value],
				a.[Units] AS [Inventory Volume],
				''MWh'' AS [UOM],	
				a.[Wght_Avg_Cost] AS [WACOG],
				a.[Currency]' + @str_batch_table + '
			FROM
				#wacog a'
		EXEC (@sql_select1)		
		END
EXEC spa_print 'STORED PROCEDURE spa_create_roll_forward_inventory_report ADDED.'
/************************************* Object: 'spa_create_roll_forward_inventory_report' END *************************************/
/*******************************************2nd Paging Batch START**********************************************/


--update time spent and batch completion message in message board
IF @is_batch = 1
BEGIN
   SELECT @sql_paging = dbo.FNABatchProcess('u', @batch_process_id, @batch_report_param, GETDATE(), NULL, NULL) 
   EXEC(@sql_paging)

   SELECT @sql_paging = dbo.FNABatchProcess('c', @batch_process_id, @batch_report_param, GETDATE(), 'spa_create_roll_forward_inventory_report', 'Roll Forward Inventory Report')
   EXEC(@sql_paging)  

   RETURN
END

IF @enable_paging = 1 AND @page_no IS NULL
BEGIN
   SET @sql_paging = dbo.FNAPagingProcess('t', @batch_process_id, @page_size, @page_no)
   EXEC(@sql_paging)
END


/*******************************************2nd Paging Batch END**********************************************/


GO
